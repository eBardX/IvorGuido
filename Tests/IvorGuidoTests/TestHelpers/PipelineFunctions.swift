// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// Asserts both properties at once: `input` canonicalizes to `expected`,
// and `expected` is a fixed point of the pipeline.
internal func assertCanonicalizes(_ input: String,
                                  to expected: String,
                                  sourceLocation: SourceLocation = #_sourceLocation) throws {
    let output = try canonicalize(input)

    #expect(output == expected,
            sourceLocation: sourceLocation)

    try assertIsIdempotent(output,
                           sourceLocation: sourceLocation)
}

// `format(parse(format(parse(x)))) == format(parse(x))`, expressed over
// the already-canonicalized text.
internal func assertIsIdempotent(_ canonical: String,
                                 sourceLocation: SourceLocation = #_sourceLocation) throws {
    #expect(try canonicalize(canonical) == canonical,
            sourceLocation: sourceLocation)
}

internal func assertIsStable(_ input: String,
                             sourceLocation: SourceLocation = #_sourceLocation) throws {
    let score = try normalizeScore(input)
    let roundTripped = try normalizeScore(formatScore(score))

    #expect(roundTripped == score,
            sourceLocation: sourceLocation)
}

internal func bind(_ name: String,
                   _ parameters: [GMNTag.Parameter]) throws -> GMNTagBinder.Binding {
    let tagName = try #require(GMNTag.Name(stringValue: name))
    let template = try #require(GMNTagTemplate.Registry.template(for: tagName))

    return GMNTagBinder.bind(parameters, to: template)
}

// Runs the whole pipeline — `parse → normalize → validate → format` — and
// returns the score's canonical text. See `GMNFormatter` for the seven rules
// that text obeys.
internal func canonicalize(_ input: String) throws -> String {
    try formatScore(normalizeScore(input))
}

// The same, for a score the parser will no longer produce. A `$variable`
// no declaration answers is `GMNParser.Error.unresolvableVariableReference`,
// so the exemption these cases are about is reachable only by hand now —
// and still has to hold, because the editor runs over a hand-built score
// too.
internal func edit(_ name: String,
                   _ parameters: [GMNTag.Parameter]) -> (GMNTag, [GMNNormalizer.Change]) {
    let tag = makeTag(makeTagName(name), parameters: parameters)

    var editor = GMNNormalizer.Editor(score: makeScore([], [makeVoice([.tag(tag)])]))

    let (normalized, changes) = editor.editScore()

    guard case let .tag(edited) = normalized.voices[0].symbols[0]
    else {
        Issue.record("Expected tag symbol")

        return (tag, changes)
    }

    return (edited, changes)
}

// Returns the whole `GMNTag` rather than its generic payload: an alias
// whose canonical name is already typed (`acc`, `oct`) is canonicalized
// *and then promoted*, so it does not come back on the `.generic` lane
// at all. Its canonical name is read through the forwarding property,
// which answers for every case.
internal func editSingleTag(_ name: GMNTag.Name) -> (GMNTag, [GMNNormalizer.Change]) {
    let tag = makeTag(name)
    let score = makeScore([], [makeVoice([.tag(tag)])])
    var editor = GMNNormalizer.Editor(score: score)
    let (normalized, changes) = editor.editScore()

    guard case let .tag(resultTag) = normalized.voices[0].symbols[0]
    else {
        Issue.record("Expected tag symbol")
        return (tag, changes)
    }

    return (resultTag, changes)
}

// Parses `input` and runs the editor over it, returning the first symbol
// of the first voice as a tag together with the changes recorded.
internal func editedTagAndChanges(_ input: String) throws -> (GMNTag, [GMNNormalizer.Change]) {
    let (parsed, _) = try GMNParser().parse(Data(input.utf8))

    var editor = GMNNormalizer.Editor(score: parsed)

    let (normalized, changes) = editor.editScore()

    guard case let .tag(tag) = normalized.voices[0].symbols[0]
    else {
        Issue.record("Expected tag symbol")
        return (makeTag(makeTagName("bembel")), changes)
    }

    return (tag, changes)
}

// Asserts that the pipeline refuses `input`, and says with which issue.
//
// The counterpart of `normalizedTag(_:)`, and what replaced a good many
// "stays untyped" assertions. A tag left untyped by a defect in what was
// written is not observable as such: `GMNValidator` reports the defect and
// withholds validation, so the thing to state about such an input is which
// issue it was refused for.
//
// `contains` rather than `==`, because an input written to exercise a
// parameter defect may raise a body issue on the same tag as well.
internal func expectRejected(_ input: String,
                             _ issue: GMNValidator.Issue,
                             sourceLocation: SourceLocation = #_sourceLocation) {
    guard let found = try? issues(input)
    else {
        Issue.record("Expected \(issue.message), but the pipeline threw",
                     sourceLocation: sourceLocation)

        return
    }

    #expect(found.contains(issue),
            Comment(rawValue: "Expected \(issue.message), got \(found.map(\.message))"),
            sourceLocation: sourceLocation)
}

// Validates and formats an already-normalized score, returning its canonical
// text.
internal func formatScore(_ score: GMNScore) throws -> String {
    let (validated, _) = try GMNValidator().validate(score)
    let data = try GMNFormatter().format(validated)

    return String(bytes: data,
                  encoding: .utf8).require()
}

internal func isCustom(_ score: GMNScore) -> Bool {
    guard case let .tag(tag) = score.voices[0].symbols[0],
          case .custom = tag
    else { return false }

    return true
}

// Whether the given input leaves a known name untyped with no diagnostic
// at any stage — the definition of a silent mechanism.
//
// `.custom` is the only lane that says nothing about why a tag is untyped,
// and its initializer refuses every dispatched name, so no known name can
// reach it. `.reserved` is not silent — it names the reason — which is why
// the predicate tests that lane rather than `untypedPayload != nil`.
//
// An input the pipeline refuses is the opposite of silent, so a throw
// answers `false` rather than propagating. Three of the nine mechanisms
// reach here that way.
internal func isSilent(_ input: String) -> Bool {
    guard let (tag, changes, issues) = try? runPipeline(input),
          case .custom = tag
    else { return false }

    return changes.isEmpty && issues.isEmpty
}

internal func isReserved(_ name: GMNTag.Name) -> Bool {
    guard case .reserved = promote(name)
    else { return false }

    return true
}

internal func isReserved(_ tag: GMNTag?) -> Bool {
    guard case .reserved = tag
    else { return false }

    return true
}

internal func isUntyped(_ tag: GMNTag?) -> Bool {
    tag?.untypedPayload != nil
}

internal func issues(_ input: String) throws -> [GMNValidator.Issue] {
    try GMNValidator().validate(normalizeScore(input)).1
}

internal func matcher(_ input: String) throws -> GMNParser.Matcher {
    try GMNParser.Matcher(tokens: GMNTokenizer(tracing: .silent).tokenize(input))
}

// Parses and normalizes, stopping short of validation and formatting. The
// AST-stability property is stated over *normalized* scores, so this is the
// form both of its sides are compared in.
internal func normalizeScore(_ input: String) throws -> GMNScore {
    let (parsed, _) = try GMNParser().parse(Data(input.utf8))
    let (normalized, _) = GMNNormalizer().normalize(parsed)

    return normalized
}

internal func normalizedScoreAndChanges(_ input: String) throws -> (GMNScore, [GMNNormalizer.Change]) {
    let (parsed, _) = try GMNParser().parse(Data(input.utf8))

    return GMNNormalizer().normalize(parsed)
}

// Parses and normalizes `input`, then returns the first symbol of its first
// voice as a tag. This is the form a typed payload is observed in: promotion
// runs in the parser and again after the normalizer's repair step.
internal func normalizedTag(_ input: String) throws -> GMNTag {
    guard case let .tag(tag) = try normalizeScore(input).voices[0].symbols[0]
    else { throw GMNParser.Error.missingTagName }

    return tag
}

internal func notes(_ symbols: [GMNSymbol]) throws -> [GMNNote] {
    try symbols.map { symbol in
        guard case let .note(note) = symbol
        else {
            Issue.record("Expected note symbol")
            throw GMNParser.Error.trailingGarbage
        }

        return note
    }
}

// The values a tag still carries, for a repair whose whole point is what is
// no longer there. Reads the generic payload, since a tag that promoted has
// no written parameter list left to inspect.
internal func parameterValues(_ tag: GMNTag?) -> [GMNTag.Parameter.Value] {
    guard let untyped = tag?.untypedPayload
    else { return [] }

    return untyped.parameters.map(\.value)
}

internal func parse(_ input: String) throws -> GMNScore {
    try GMNParser().parse(Data(input.utf8)).0
}

internal func promote(_ name: GMNTag.Name) -> GMNTag {
    let parameters = requiredParameters(name)

    return GMNTagPromoter.promote(ident: nil,
                                  name: name,
                                  parameters: parameters,
                                  body: [])
}

internal func promoteBucketC(_ name: String,
                             _ parameters: [GMNTag.Parameter] = []) -> GMNTag? {
    GMNTagPromoter.promoteBucketC(nil,
                                  makeTagName(name),
                                  makeBinding(name, parameters),
                                  parameters,
                                  [])
}

internal func promoteBucketD(_ name: String,
                             _ parameters: [GMNTag.Parameter] = []) -> GMNTag? {
    GMNTagPromoter.promoteBucketD(nil,
                                  makeTagName(name),
                                  makeBinding(name, parameters),
                                  parameters,
                                  [])
}

internal func promoted(_ name: String) -> GMNTag {
    makePromotedTag(name)
}

// One written parameter per required slot, of the kind that slot
// declares. Named rather than positional so that `\segno` and the other
// zero-slot classes are written the only way they can be.
internal func requiredParameters(_ name: GMNTag.Name) -> [GMNTag.Parameter] {
    guard let template = GMNTagTemplate.Registry.template(for: name)
    else { return [] }

    return template.supportedParameters
                   .filter { $0.isRequired }
                   .map {
                       GMNTag.Parameter(name: GMNTag.Parameter.Name($0.name),
                                        value: value(of: $0.kind))
                   }
}

internal func requiredParameters(_ name: String) -> [GMNTag.Parameter] {
    requiredParameters(makeTagName(name))
}

// Runs `parse → normalize → validate` and reports all three of the things
// that matter for a mechanism: which lane the first tag landed on, which
// changes the normalizer recorded, and which issues the validator raised.
internal func runPipeline(_ input: String) throws -> (GMNTag?,
                                                      [GMNNormalizer.Change],
                                                      [GMNValidator.Issue]) {
    let (parsed, _) = try GMNParser().parse(Data(input.utf8))
    let (normalized, changes) = GMNNormalizer().normalize(parsed)
    let (_, issues) = try GMNValidator().validate(normalized)

    let tag: GMNTag? = if case let .tag(tag) = normalized.voices.first?.symbols.first {
        tag
    } else {
        nil
    }

    return (tag, changes, issues)
}

internal func template(_ name: String) throws -> GMNTagTemplate {
    let tagName = try #require(GMNTag.Name(stringValue: name))

    return try #require(GMNTagTemplate.Registry.template(for: tagName))
}

internal func validate(_ input: String) throws -> (GMNScore, [GMNValidator.Issue]) {
    let (parsed, _) = try GMNParser().parse(Data(input.utf8))
    let (normalized, _) = GMNNormalizer().normalize(parsed)

    return try GMNValidator().validate(normalized)
}

internal func value(_ value: GMNTag.Parameter.Value,
                    named name: String? = nil) -> GMNTag.Parameter {
    GMNTag.Parameter(name: name.flatMap { GMNTag.Parameter.Name(stringValue: $0) },
                     value: value)
}

internal func value(of kind: GMNTagTemplate.Slot.Kind) -> GMNTag.Parameter.Value {
    switch kind {
    case .float:
        .floating(1.0, nil)

    case .integer:
        .integer(1, nil)

    case .length:
        .integer(1, .hs)

    case .string:
        .string("x")
    }
}
