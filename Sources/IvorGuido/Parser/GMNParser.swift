// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A type that parses Guido Music Notation UTF-8 data into a score.
///
/// ## A parsed score is less typed than a normalized one
///
/// The parser promotes a tag to a typed ``GMNTag`` case only when what was
/// written binds cleanly: a name GMN reserves, every parameter one the
/// tag accepts, every value of the declared type. It never repairs and never
/// discards, so anything else arrives intact on one of the two untyped lanes:
/// an alias such as `\bm`, a deprecated parameter name, or a value of the
/// wrong type lands on ``GMNTag/reserved(_:)``, since the name is
/// reserved, and a name GMN does not reserve lands on ``GMNTag/custom(_:)``.
///
/// Repairing those is ``GMNNormalizer``’s job, and promotion runs again
/// afterwards on what the repair left behind. `\bm<dy=2hs>` and
/// `\staccato<0.5>` are therefore both reserved out of the parser and typed
/// out of the normalizer. The pipeline already requires normalization before
/// formatting, and ``GMNScore/isNormalized`` already marks the distinction,
/// so this fits the existing contract rather than adding to it — but a
/// consumer that switches over ``GMNTag`` should read a *normalized* score.
public struct GMNParser {

    // MARK: Public Initializers

    /// Creates a new Guido Music Notation parser.
    public init() {
    }
}

// MARK: -

extension GMNParser {

    // MARK: Public Instance Methods

    /// Parses UTF-8 encoded Guido Music Notation data and returns the
    /// resulting score together with any diagnostics.
    ///
    /// - Parameter data:   The UTF-8 encoded GMN data to parse.
    ///
    /// - Returns:  The parsed score and the diagnostics accumulated while
    ///             parsing it (empty if none applied).
    ///
    /// - Throws:   ``Error`` if parsing fails.
    public func parse(_ data: Data) throws(GMNParser.Error) -> (GMNScore, [Diagnostic]) {
        guard let input = String(data: data,
                                 encoding: .utf8)
        else { throw GMNParser.Error.dataConversionFailed }

        let tokenizer = GMNTokenizer(tracing: .silent)

        var matcher = try Matcher(tokens: tokenizer.tokenize(input))
        let (score, diagnostics) = try matcher.matchScore()
        var variables: [GMNVariable] = []

        for variable in score.variables {
            let expandedVariable = try _expandVariableSymbols(variable,
                                                              using: tokenizer)

            variables.append(expandedVariable)
        }

        let expanded = GMNScore(variables: variables,
                                voices: score.voices)

        try _checkVariableReferences(expanded)

        return (expanded, diagnostics)
    }

    // MARK: Private Instance Methods

    // Rejects both ways a `$var` reference can fail to answer.
    //
    // **Undeclared, in either position** — `unresolvableVariableReference`.
    // guidolib `YYABORT`s at the reference point (`GuidoParser.cpp`
    // `variableSymbols` and `varParam` alike), and nothing downstream of the
    // parser could answer the name either: declarations are a prologue only
    // (`gmn: score | variables score`), so the environment is complete before
    // the first reference and a name unanswered here is unanswered for good.
    //
    // **Declared but unable to supply symbols, in symbol position** —
    // `nonSymbolVariableReference`. A number, or a string whose body does not
    // lex as GMN. guidolib rejects these by a route that leaves it no choice:
    // `variableSymbols` pushes the body onto the lexer's stream stack
    // (`GuidoParser.cpp:345–361`) and a bare `42` is not a symbol, so the
    // grammar fails. IvorGuido pre-parses the body once at declaration time
    // instead, which left `symbols == nil` with nothing to say about it —
    // `$x = 42; [$x c]` parsed, validated, and resolved to a single event,
    // silently discarding the reference.
    //
    // Redeclaration takes the last binding, matching guidolib's `fEnv` map
    // (`variableDecl` assigns).
    private func _checkVariableReferences(_ score: GMNScore) throws(GMNParser.Error) {
        let variables = Dictionary(score.variables.map { ($0.name, $0) }) { _, latest in latest }

        for variable in score.variables {
            try _checkVariableReferences(variable.symbols ?? [],
                                         variables)
        }

        for voice in score.voices {
            try _checkVariableReferences(voice.symbols,
                                         variables)
        }
    }

    private func _checkVariableReferences(_ symbols: [GMNSymbol],
                                          _ variables: [GMNVariable.Name: GMNVariable]) throws(GMNParser.Error) {
        for symbol in symbols {
            switch symbol {
            case let .chord(chord):
                for segment in chord.segments {
                    try _checkVariableReferences(segment.symbols,
                                                 variables)
                }

            case .note,
                 .rest,
                 .tablature:
                break

            case let .tag(tag):
                // Only an untyped lane can hold a reference at all:
                // `.variable` is a `GMNTag.Parameter.Value` case, and a
                // parameter carrying one never binds to a typed field, so such
                // a tag is always untyped out of the parser.
                if let untyped = tag.untypedPayload {
                    for parameter in untyped.parameters {
                        guard case let .variable(name) = parameter.value,
                              variables[name] == nil
                        else { continue }

                        throw GMNParser.Error.unresolvableVariableReference(name)
                    }
                }

                try _checkVariableReferences(tag.body,
                                             variables)

            case let .variable(name):
                guard let variable = variables[name]
                else { throw GMNParser.Error.unresolvableVariableReference(name) }

                guard variable.symbols == nil
                else { break }

                throw GMNParser.Error.nonSymbolVariableReference(name)
            }
        }
    }

    // Best-effort, declaration-time pre-parse of a string-valued variable's
    // body into `[GMNSymbol]`. guidolib re-lexes a `$var` body inline at
    // each reference point instead (`GuidoParser.cpp:345–361`); this is a
    // single, declaration-time approximation of that — see
    // `GMNVariable.symbols`.
    //
    // If the body doesn't even tokenize as GMN, it's treated as an ordinary
    // (non-GMN) string value and `symbols` stays `nil`, silently. If it does
    // tokenize but fails to match cleanly as a `symbols*` sequence, that's
    // treated as a genuine parse error inside a GMN-valued body and thrown.
    //
    // **An empty body yields `[]`, not `nil`, and the difference is load
    // bearing.** guidolib pushes the body onto its lexer stream and pops it
    // again on the first character read (`GuidoParser.cpp` `get`), so
    // `$x = ""` is legal and contributes nothing at each reference. `nil`
    // means something else entirely — this variable cannot supply symbols at
    // all — and `_checkVariableReferences(_:)` rejects a symbol-position
    // reference to one. Conflating the two is what let `$x = 42; [$x c]`
    // silently drop its reference.
    private func _expandVariableSymbols(_ variable: GMNVariable,
                                        using tokenizer: GMNTokenizer) throws(GMNParser.Error) -> GMNVariable {
        guard case let .string(body) = variable.value,
              let tokens = try? tokenizer.tokenize(body)
        else { return variable }

        guard !tokens.isEmpty
        else { return GMNVariable(name: variable.name,
                                  value: variable.value,
                                  symbols: []) }

        var subMatcher = Matcher(tokens: tokens)
        let symbols = try subMatcher.matchSymbolsExhaustively()

        return GMNVariable(name: variable.name,
                           value: variable.value,
                           symbols: symbols)
    }
}

// MARK: - Sendable

extension GMNParser: Sendable {
}
