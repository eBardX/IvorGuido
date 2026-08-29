// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTokens

private import XestiTools

extension GMNParser {

    // MARK: Internal Nested Types

    internal struct Matcher {

        // MARK: Internal Initializers

        internal init(tokens: [Tokenizer.Token]) {
            self.tokenMatcher = TokenMatcher(tokens)
        }

        // MARK: Internal Instance Properties

        internal private(set) var diagnostics: [GMNParser.Diagnostic] = []

        // MARK: Private Instance Properties

        private var tokenMatcher: TokenMatcher<[Tokenizer.Token]>
    }
}

// MARK: -

extension GMNParser.Matcher {

    // MARK: Internal Instance Methods

    internal mutating func matchScore() throws(GMNParser.Error) -> (GMNScore, [GMNParser.Diagnostic]) {
        //
        // score => variables? voices
        //
        let variables = try _matchVariables()
        let voices = try _matchVoices()

        guard !tokenMatcher.hasMore
        else { throw GMNParser.Error.trailingGarbage }

        return (GMNScore(variables: variables,
                         voices: voices),
                diagnostics)
    }

    // Matches a bare `symbols*` sequence (no surrounding `[...]`) and
    // requires every token to be consumed. Used for the best-effort,
    // declaration-time pre-parse of a string-valued variable's body (see
    // `GMNParser._expandVariableSymbols(_:)`).
    internal mutating func matchSymbolsExhaustively() throws(GMNParser.Error) -> [GMNSymbol] {
        let symbols = try _matchSymbols()

        guard !tokenMatcher.hasMore
        else { throw GMNParser.Error.trailingGarbage }

        return symbols
    }

    // MARK: Private Instance Methods

    // Records omission verbatim (`nil` duration / `octave = nil`) rather
    // than consulting or mutating any per-voice inheritance state. Replaying
    // that inheritance (`lastDuration` / `lastOctave`, per guidolib
    // `GuidoParser.cpp:155–260`) is the resolver's job, not the parser's.
    private func _makeDuration(_ result: ParseDurationResult?) -> GMNDuration? {
        guard let result
        else { return nil }

        let dots = result.dots.flatMap { GMNDuration.DotCount(uintValue: $0) }

        if let denom = result.denominator,
           let numer = result.numerator,
           let duration = GMNDuration(numerator: numer,
                                      denominator: denom,
                                      dots: dots) {
            return duration
        }

        if let numer = result.numerator,
           let duration = GMNDuration(milliseconds: numer,
                                      dots: dots) {
            return duration
        }

        if let dots {    // dots > 0
            return GMNDuration(dots: dots)
        }

        return nil
    }

    private func _makePitch(_ result: ParsePitchResult) -> GMNPitch {
        GMNPitch(name: result.name,
                 accidental: result.accidental ?? .omitted,
                 octave: result.octave)
    }

    private mutating func _matchChord() throws(GMNParser.Error) -> GMNSymbol? {
        //
        // chord => <curlyBracketOpen> symbol[inChord]+ (<comma> symbol[inChord]+)* <curlyBracketClose>
        //
        guard tokenMatcher.readIfMatches(.curlyBracketOpen) != nil
        else { return nil }

        var segments: [GMNChord.Segment] = []

        while true {
            var symbols: [GMNSymbol] = []
            var musicSymbolSeen = false

            while let symbol = try _matchSymbol(true) {
                symbols.append(symbol)

                if symbol.isMusic {
                    guard !musicSymbolSeen
                    else { throw GMNParser.Error.invalidChordSegment(symbols) }

                    musicSymbolSeen = true
                }
            }

            guard musicSymbolSeen
            else { throw GMNParser.Error.invalidChordSegment(symbols) }

            guard let segment = GMNChord.Segment(symbols: symbols)
            else { throw GMNParser.Error.nestedChord }

            segments.append(segment)

            guard tokenMatcher.readIfMatches(.comma) != nil
            else { break }
        }

        do {
            try tokenMatcher.readMustMatch(.curlyBracketClose)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        return .chord(GMNChord(segments: segments).require())
    }

    private mutating func _matchNote() throws(GMNParser.Error) -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches([.note])
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw GMNParser.Error.invalidNote(token.value) }

        if token.value.contains("<") {
            diagnostics.append(.vestigialCount(String(token.value)))
        }

        let note = GMNNote(pitch: _makePitch(result.pitch),
                           duration: _makeDuration(result.duration))

        return .note(note)
    }

    private mutating func _matchParameterUnit() throws(GMNParser.Error) -> GMNTag.Parameter.Unit? {
        guard let token = tokenMatcher.readIfMatches(.unit)
        else { return nil }

        guard let unit = GMNTag.Parameter.Unit(rawValue: String(token.value))
        else { throw GMNParser.Error.invalidParameterUnit(token.value) }

        return unit
    }

    private mutating func _matchRest() throws(GMNParser.Error) -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches([.rest])
        else { return nil }

        guard let result = parseRest(token.value)
        else { throw GMNParser.Error.invalidRest(token.value) }

        if token.value.contains("<") {
            diagnostics.append(.vestigialCount(String(token.value)))
        }

        let rest = GMNRest(duration: _makeDuration(result.duration))

        return .rest(rest)
    }

    private mutating func _matchSymbol(_ inChord: Bool) throws(GMNParser.Error) -> GMNSymbol? {
        //
        // symbol => chord | <note> | <rest> | <tablature> | tag | <variableName>
        //
        if tokenMatcher.nextMatches(.curlyBracketOpen) {
            guard !inChord
            else { throw GMNParser.Error.nestedChord }

            return try _matchChord()
        }

        if tokenMatcher.nextMatches(.note) {
            return try _matchNote()
        }

        if tokenMatcher.nextMatches(.rest) {
            return try _matchRest()
        }

        if tokenMatcher.nextMatches(.tablature) {
            return try _matchTablature()
        }

        if tokenMatcher.nextMatches(.tagName) {
            return try _matchTag(inChord)
        }

        if tokenMatcher.nextMatches(.variableName) {
            return try _matchVariable()
        }

        return nil
    }

    private mutating func _matchSymbols() throws(GMNParser.Error) -> [GMNSymbol] {
        //
        // symbols => symbol*
        //
        var symbols: [GMNSymbol] = []

        while let symbol = try _matchSymbol(false) {
            symbols.append(symbol)
        }

        return symbols
    }

    private mutating func _matchTablature() throws(GMNParser.Error) -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches(.tablature)
        else { return nil }

        guard let result = parseTablature(token.value)
        else { throw GMNParser.Error.invalidTablature(token.value) }

        if let escape = result.fret.unrecognizedEscape {
            diagnostics.append(.unrecognizedEscape(escape))
        }

        let tablature = GMNTablature(tabString: result.tabString,
                                     fret: result.fret.value,
                                     duration: _makeDuration(result.duration)).require()

        return .tablature(tablature)
    }

    private mutating func _matchTag(_ inChord: Bool) throws(GMNParser.Error) -> GMNSymbol? {
        //
        // tag => <tagName> (<angleBracketOpen> tagParameters <angleBracketClose>)? (<roundBracketOpen> symbol+ <roundBracketClose>)?
        //
        guard let token = tokenMatcher.readIfMatches(.tagName)
        else { return nil }

        let (name, ident) = splitTagNameIdent(token.value)

        let parameters: [GMNTag.Parameter]

        if tokenMatcher.readIfMatches(.angleBracketOpen) != nil {
            parameters = try _matchTagParameters()

            do {
                try tokenMatcher.readMustMatch(.angleBracketClose)
            } catch {
                throw GMNParser.Error.tokenizationFailed(String(describing: error))
            }
        } else {
            parameters = []
        }

        var symbols: [GMNSymbol] = []

        if tokenMatcher.readIfMatches(.roundBracketOpen) != nil {
            while let symbol = try _matchSymbol(inChord) {
                symbols.append(symbol)
            }

            do {
                try tokenMatcher.readMustMatch(.roundBracketClose)
            } catch {
                throw GMNParser.Error.tokenizationFailed(String(describing: error))
            }
        } else {
            symbols = []
        }

        return .tag(GMNTagPromoter.promote(ident: ident,
                                           name: name,
                                           parameters: parameters,
                                           body: symbols))
    }

    private mutating func _matchTagParameter() throws(GMNParser.Error) -> GMNTag.Parameter? {
        //
        // tagParameter => (<parameterName> <equalSign>)? tagValue
        //
        if let token = tokenMatcher.readIfMatches(.parameterName) {
            // `readIfMatches` has already consumed the `.parameterName`
            // token, so there's no way to "put it back" if no `=` follows.
            // In that case, this isn't a `name=value` pair after all — it's
            // a bare, unnamed raw-identifier `tagValue` (the `.parameter`
            // case with a `nil` name), so build it directly here instead of
            // delegating to `_matchTagValue`.
            guard tokenMatcher.readIfMatches(.equalSign) != nil
            else { return GMNTag.Parameter(name: nil,
                                           value: .parameter(String(token.value))) }

            return try _matchTagValue(GMNTag.Parameter.Name(String(token.value)))
        }

        return try _matchTagValue(nil)
    }

    private mutating func _matchTagParameters() throws(GMNParser.Error) -> [GMNTag.Parameter] {
        //
        // tagParameters => tagParameter (<comma> tagParameter)*
        //
        var params: [GMNTag.Parameter] = []

        while let param = try _matchTagParameter() {
            params.append(param)

            guard tokenMatcher.readIfMatches(.comma) != nil
            else { break }
        }

        return params
    }

    private mutating func _matchTagValue(_ name: GMNTag.Parameter.Name?) throws(GMNParser.Error) -> GMNTag.Parameter? {
        //
        // tagValue => <floatingValue> <unit>?
        //           | <integerValue> <unit>?
        //           | <parameterName>
        //           | <stringValue>
        //           | <variableName>
        //
        if let token = tokenMatcher.readIfMatches(.floatingValue) {
            guard let value = Double(token.value)
            else { throw GMNParser.Error.invalidNumber(token.value) }

            let unit = try _matchParameterUnit()

            return GMNTag.Parameter(name: name, value: .floating(value, unit))
        }

        if let token = tokenMatcher.readIfMatches(.integerValue) {
            guard let value = Int(token.value)
            else { throw GMNParser.Error.invalidNumber(token.value) }

            let unit = try _matchParameterUnit()

            return GMNTag.Parameter(name: name, value: .integer(value, unit))
        }

        if let token = tokenMatcher.readIfMatches(.parameterName) {
            return GMNTag.Parameter(name: name, value: .parameter(String(token.value)))
        }

        if let token = tokenMatcher.readIfMatches(.stringValue) {
            guard let (cvtValue, unrecognizedEscape) = convertString(token.value)
            else { throw GMNParser.Error.invalidString(token.value) }

            if let unrecognizedEscape {
                diagnostics.append(.unrecognizedEscape(unrecognizedEscape))
            }

            return GMNTag.Parameter(name: name, value: .string(cvtValue))
        }

        if let token = tokenMatcher.readIfMatches(.variableName) {
            return GMNTag.Parameter(name: name, value: .variable(GMNVariable.Name(String(token.value.dropFirst()))))
        }

        return nil
    }

    private mutating func _matchVariable() throws(GMNParser.Error) -> GMNSymbol {
        try .variable(_matchVariableName())
    }

    private mutating func _matchVariableDeclaration() throws(GMNParser.Error) -> GMNVariable {
        //
        // variableDeclaration => <variableName> <equalSign> <floatingValue> <semicolon>
        //                     | <variableName> <equalSign> <integerValue> <semicolon>
        //                     | <variableName> <equalSign> <stringValue> <semicolon>
        //
        let name = try _matchVariableName()

        do {
            try tokenMatcher.readMustMatch(.equalSign)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        guard let value = try _matchVariableValue()
        else { throw GMNParser.Error.missingVariableValue }

        do {
            try tokenMatcher.readMustMatch(.semicolon)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        return GMNVariable(name: name,
                           value: value)
    }

    private mutating func _matchVariableName() throws(GMNParser.Error) -> GMNVariable.Name {
        let token: Tokenizer.Token

        do {
            token = try tokenMatcher.readMustMatch(.variableName)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        return GMNVariable.Name(String(token.value.dropFirst()))
    }

    private mutating func _matchVariables() throws(GMNParser.Error) -> [GMNVariable] {
        //
        // variables => variableDeclaration+
        //
        var variables: [GMNVariable] = []

        while tokenMatcher.nextMatches(.variableName) {
            try variables.append(_matchVariableDeclaration())
        }

        return variables
    }

    private mutating func _matchVariableValue() throws(GMNParser.Error) -> GMNVariable.Value? {
        if let token = tokenMatcher.readIfMatches(.floatingValue) {
            guard let cvtValue = Double(token.value)
            else { throw GMNParser.Error.invalidNumber(token.value) }

            return .floating(cvtValue)
        }

        if let token = tokenMatcher.readIfMatches(.integerValue) {
            guard let cvtValue = Int(token.value)
            else { throw GMNParser.Error.invalidNumber(token.value) }

            return .integer(cvtValue)
        }

        if let token = tokenMatcher.readIfMatches(.stringValue) {
            guard let (cvtValue, unrecognizedEscape) = convertString(token.value)
            else { throw GMNParser.Error.invalidString(token.value) }

            if let unrecognizedEscape {
                diagnostics.append(.unrecognizedEscape(unrecognizedEscape))
            }

            return .string(cvtValue)
        }

        return nil
    }

    private mutating func _matchVoice() throws(GMNParser.Error) -> GMNVoice {
        //
        // voice => <squareBracketOpen> symbol* <squareBracketClose>
        //
        do {
            try tokenMatcher.readMustMatch(.squareBracketOpen)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        let symbols = try _matchSymbols()

        do {
            try tokenMatcher.readMustMatch(.squareBracketClose)
        } catch {
            throw GMNParser.Error.tokenizationFailed(String(describing: error))
        }

        return GMNVoice(symbols: symbols)
    }

    private mutating func _matchVoices() throws(GMNParser.Error) -> [GMNVoice] {
        //
        // voices => <curlyBracketOpen> (voice (<comma> voice)*) <curlyBracketClose>
        //         | voice
        //
        var voices: [GMNVoice] = []

        if tokenMatcher.readIfMatches(.curlyBracketOpen) != nil {
            while !tokenMatcher.nextMatches(.curlyBracketClose) {
                try voices.append(_matchVoice())

                tokenMatcher.readIfMatches(.comma)
            }

            do {
                try tokenMatcher.readMustMatch(.curlyBracketClose)
            } catch {
                throw GMNParser.Error.tokenizationFailed(String(describing: error))
            }
        } else {
            try voices.append(_matchVoice())
        }

        return voices
    }
}
