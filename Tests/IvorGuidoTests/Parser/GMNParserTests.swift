// © 2026 John Gary Pusey (see LICENSE.md)

// One test file per source file: the parser's grammar is one source file, so its characterization,
// variable-reference and variable-symbol suites all belong here.
// swiftlint:disable file_length

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// Golden tests pinning the parser's behavior. These snippets exist so the
// lossless-AST remodel and its inheritance-replay migration have a visible,
// controlled diff against what the parser produced before them.
//
// The AST is lossless: an omitted duration base or octave is preserved as
// `nil` (`GMNDuration.base`, `GMNPitch.octave`) rather than resolved to a
// default or inherited value. The resolved-value assertions this suite used
// to make were dropped along with the resolver they characterized.
//
// The `$var` reference split has closed. A reference no declaration answers
// used to be `GMNValidator.Issue.unresolvableVariableReference`, the one
// blocking issue in the model, while a *declared* reference that could not
// supply symbols was already `GMNParser.Error.nonSymbolVariableReference`.
// guidolib `YYABORT`s on both — `variableSymbols` and `varParam` alike — and
// so does this parser now.
//
// Nothing downstream could have answered the name anyway: declarations are a
// prologue only (`gmn: score | variables score`), so the environment is
// complete before the first reference and a name unanswered at the parser is
// unanswered for good. That is what distinguishes this rejection from the
// three the *normalizer* makes, each of which had to wait for a repair.
//
// Tests for the parser-side half of variable expansion: a best-effort,
// declaration-time pre-parse of a string-valued variable's body into
// `GMNVariable.symbols`. Splicing that fragment in at each reference point
// is not implemented anywhere in IvorGuido.
struct GMNParserTests {
}

// MARK: -

extension GMNParserTests {
    @Test
    func aDeclaredReferenceIsAccepted() throws {
        let (score, _) = try GMNParser().parse(Data("$x = 1; [ \\beam<dy=$x>(c d) ]".utf8))

        #expect(score.variables.count == 1)
    }

    @Test
    func aRedeclaredNameIsAnsweredByEitherDeclaration() throws {
        // The environment is a map to guidolib and a list here, and the
        // question this asks is only whether the name is answered at all —
        // which last-wins and first-wins agree on.
        let (score, _) = try GMNParser().parse(Data("$x = 1; $x = 2; [ \\beam<dy=$x>(c d) ]".utf8))

        #expect(score.variables.count == 2)
    }

    @Test
    func aReferenceInAVariableBodyToALaterDeclarationIsAccepted() throws {
        // Declarations are a prologue, so the whole of it is in scope for any
        // of it. `$a` refers forward to `$b` and the parser has both by the
        // time it checks.
        let (score, _) = try GMNParser().parse(Data("$a = \"$b c\"; $b = \"d\"; [ $a ]".utf8))

        #expect(score.variables.count == 2)
    }

    @Test
    func chord_durationOmissionIsPreservedAcrossSegmentsAndBeyond() throws {
        let score = try parse("[ {c*1/8, e} d ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 2)

        guard case let .chord(chord) = symbols[0],
              case let .note(second) = symbols[1]
        else {
            Issue.record("Expected chord and note symbols")
            return
        }

        guard case let .note(first) = chord.segments[0].symbols[0],
              case let .note(omitted) = chord.segments[1].symbols[0]
        else {
            Issue.record("Expected note symbols in chord segments")
            return
        }

        #expect(first.duration == makeDuration(1, 8))
        #expect(omitted.duration == nil)
        #expect(second.duration == nil)
    }

    @Test
    func chord_segments() throws {
        let score = try parse("[ {c, e, g} ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 1)

        guard case let .chord(chord) = symbols[0]
        else {
            Issue.record("Expected chord symbol")
            return
        }

        #expect(chord.segments.count == 3)

        let names = try chord.segments.map { segment -> GMNPitch.Name in
            guard case let .note(note) = segment.symbols[0]
            else {
                Issue.record("Expected note symbol in chord segment")
                throw GMNParser.Error.trailingGarbage
            }

            return note.pitch.name
        }

        #expect(names == [.c, .e, .g])
    }

    @Test
    func comment_lineStyleIsIgnored() throws {
        let input = "[ c % this is a comment\n d ]"
        let score = try parse(input)
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.c, .d])
    }

    @Test
    func comment_nestedBlockStyleIsIgnored() throws {
        let input = "[ c (* outer (* inner *) still outer *) d ]"
        let score = try parse(input)
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.c, .d])
    }

    @Test
    func duration_denominatorOnlyForm() throws {
        let score = try parse("[ c/8 ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(1, 8)])
    }

    @Test
    func duration_dotsOnlyFormPreservesOmittedBase() throws {
        let score = try parse("[ c*1/4 d. e.. ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(1, 4), makeDuration(dots: 1), makeDuration(dots: 2)])

        let dur1 = try #require(notes[1].duration)
        let dur2 = try #require(notes[2].duration)

        #expect(dur1.base == nil)
        #expect(dur2.base == nil)
    }

    @Test
    func duration_fractionForm() throws {
        let score = try parse("[ c*3/4 ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(3, 4)])
    }

    @Test
    func duration_millisecondsForm() throws {
        let score = try parse("[ c*500ms ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(500)])
    }

    @Test
    func duration_millisecondsFormWithDots() throws {
        // `GMNTokenizer`'s duration alternation used to try the
        // fraction/numerator form before the milliseconds form; a bare
        // "*500" already satisfied that alternative (denominator and dots
        // are both optional), leaving a trailing "ms" unconsumed. The
        // milliseconds alternative is now tried first, and carries its own
        // optional dots, so "ms" durations — with or without dots — are
        // reachable through the full parser for notes, rests, and
        // tablature alike.
        let score = try parse("[ c*500ms. d*250ms.. ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(500, dots: 1), makeDuration(250, dots: 2)])
    }

    @Test
    func duration_numeratorOnlyForm() throws {
        let score = try parse("[ c*3 ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.duration) == [makeDuration(3, 1)])
    }

    @Test
    func duration_omittedIsPreservedAsNil() throws {
        let score = try parse("[ c d/8 e ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes[0].duration == nil)
        #expect(notes[1].duration == makeDuration(1, 8))
        #expect(notes[2].duration == nil)
    }

    @Test
    func floatingVariable_stashesNilSymbols() throws {
        let input = "$pi = 3.14; [ c ]"
        let (score, _) = try GMNParser().parse(Data(input.utf8))

        #expect(score.variables[0].symbols == nil)
    }

    @Test
    func insideAChordSegment_isRejected() throws {
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ { $missing c, e } ]".utf8))
        }
    }

    @Test
    func insideAnotherVariablesOwnBody_isRejected() throws {
        // `$a`'s stashed pre-parse fragment is itself a reference, and `$b` is
        // never declared.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("b")) {
            try GMNParser().parse(Data("$a = \"$b\"; [ $a ]".utf8))
        }
    }

    @Test
    func insideATagBody_isRejected() throws {
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ \\slur( $missing c ) ]".utf8))
        }
    }

    @Test
    func integerVariable_stashesNilSymbols() throws {
        let input = "$x = 3; [ c ]"
        let (score, _) = try GMNParser().parse(Data(input.utf8))

        #expect(score.variables[0].symbols == nil)
    }

    @Test
    func parameterReference_toNonSymbolVariable_isAccepted() throws {
        // The check is at the *reference site*, not the declaration. A
        // number- or prose-valued variable is perfectly usable as a tag
        // parameter — guidolib's `varParam` substitutes it by declared type
        // — and only symbol position requires symbols.
        let (score, _) = try GMNParser().parse(Data("$x = 3; [ \\beam<dy=$x>(c d) ]".utf8))

        #expect(score.variables[0].symbols == nil)
    }

    @Test
    func parse_chord() throws {
        let input = "[ {c, e, g} ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.voices.count == 1)

        let symbols = score.voices[0].symbols

        #expect(symbols.count == 1)

        guard case let .chord(chord) = symbols[0]
        else {
            Issue.record("Expected chord symbol")
            return
        }

        #expect(chord.segments.count == 3)
    }

    @Test
    func parse_chordWithTags() throws {
        let input = "[ {\\accent(c), e, g} ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        guard case let .chord(chord) = symbols[0]
        else {
            Issue.record("Expected chord symbol")
            return
        }

        #expect(chord.segments.count == 3)

        let firstSegSymbols = chord.segments[0].symbols

        guard case .tag = firstSegSymbols[0]
        else {
            Issue.record("Expected tag symbol in first chord segment")
            return
        }
    }

    @Test
    func parse_dataConversionFailed() throws {
        let data = Data([0xff, 0xfe])
        let parser = GMNParser()

        #expect(throws: GMNParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_multipleVoices() throws {
        let input = "{ [c d e], [g a b] }"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.voices.count == 2)
        #expect(score.voices[0].symbols.count == 3)
        #expect(score.voices[1].symbols.count == 3)
    }

    @Test
    func parse_noteWithAccidental() throws {
        let input = "[ c# d& e&& f## ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 4)

        guard case let .note(note1) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note1.pitch.name == .c)
        #expect(note1.pitch.accidental == .sharp)

        guard case let .note(note2) = symbols[1]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note2.pitch.name == .d)
        #expect(note2.pitch.accidental == .flat)
    }

    @Test
    func parse_noteWithDuration() throws {
        let input = "[ c/4 d/8 e*3/4 ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .note(note1) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note1.pitch.name == .c)

        guard case let .fraction(n, d)? = note1.duration?.base
        else {
            Issue.record("Expected fraction duration")
            return
        }

        #expect(n == 1)
        #expect(d == 4)
    }

    @Test
    func parse_noteWithExcessiveAccidental() throws {
        let input = "[ c### ]"
        let data = Data(input.utf8)
        let parser = GMNParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_noteWithOctaveOutOfRange() throws {
        // The GMN spec discourages octaves beyond -3...5 (§2.1.3); `Octave`
        // enforces that range, so a note written outside it fails to parse.
        let input = "[ c6 ]"
        let data = Data(input.utf8)
        let parser = GMNParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_rest() throws {
        let input = "[ c _/4 d ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .rest(rest) = symbols[1]
        else {
            Issue.record("Expected rest symbol")
            return
        }

        guard case let .fraction(n, d)? = rest.duration?.base
        else {
            Issue.record("Expected fraction duration")
            return
        }

        #expect(n == 1)
        #expect(d == 4)
    }

    @Test
    func parse_restAndNoteWithVestigialCount() throws {
        let input = "[ c<3> _<4>/2 d ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .note(note) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note.pitch.name == .c)

        guard case let .rest(rest) = symbols[1]
        else {
            Issue.record("Expected rest symbol")
            return
        }

        guard case let .fraction(n, d)? = rest.duration?.base
        else {
            Issue.record("Expected fraction duration")
            return
        }

        #expect(n == 1)
        #expect(d == 2)
    }

    @Test
    func parse_simpleNotes() throws {
        let input = "[ c d e f g ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.variables.isEmpty)
        #expect(score.voices.count == 1)
        #expect(score.voices[0].symbols.count == 5)

        guard case let .note(note) = score.voices[0].symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note.pitch.name == .c)
        #expect(note.pitch.accidental == .omitted)
    }

    @Test
    func parse_tablatureWithFretEscape() throws {
        let input = "[ s1:a\\ b: ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 1)

        guard case let .tablature(tablature) = symbols[0]
        else {
            Issue.record("Expected tablature symbol")
            return
        }

        #expect(tablature.fret == "a b")
    }

    @Test
    func parse_tagParameterNameWithNoValue_throws() throws {
        // `n=` is matched, but the token that follows (`,`) is not a valid
        // `tagValue` — the underlying token matcher's own error surfaces
        // wrapped in `GMNParser.Error.tokenizationFailed(_:)` rather than
        // propagating unwrapped.
        let input = "[ \\tempo<n=,5>(c) ]"
        let data = Data(input.utf8)
        let parser = GMNParser()

        #expect(throws: GMNParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_tagWithoutParameters() throws {
        let input = "[ \\slurBegin c d e \\slurEnd ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 5)

        guard case let .tag(.slur(tag1)) = symbols[0]
        else {
            Issue.record("Expected slur tag symbol")
            return
        }

        #expect(tag1.name == makeTagName("slurBegin"))
        #expect(tag1.span == .begin)
        #expect(tag1.body.isEmpty)
    }

    @Test
    func parse_tagWithParameters() throws {
        let input = "[ \\tempo<\"Allegro\", 120> (c d e) ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 1)

        guard case let .tag(.reserved(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.name == makeTagName("tempo"))
        #expect(tag.parameters.count == 2)
        #expect(tag.body.count == 3)
        #expect(tag.parameters[0].stringValue == "Allegro")
        #expect(tag.parameters[1].integerValue == 120)
    }

    @Test
    func parse_variableMissingValue_throws() {
        let input = "$x = ; [ c ]"
        let data = Data(input.utf8)
        let parser = GMNParser()

        #expect(throws: GMNParser.Error.missingVariableValue) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_variables() throws {
        let input = "$tempo = 120; [ c d e ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.variables.count == 1)
        #expect(score.variables[0].name == "tempo")

        guard case let .integer(value) = score.variables[0].value
        else {
            Issue.record("Expected integer variable value")
            return
        }

        #expect(value == 120)
    }

    @Test
    func parse_variablesFloating() throws {
        let input = "$pi = 3.14; [ c ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.variables.count == 1)

        guard case let .floating(value) = score.variables[0].value
        else {
            Issue.record("Expected floating variable value")
            return
        }

        #expect(value == 3.14)
    }

    @Test
    func parse_variablesString() throws {
        let input = "$title = \"My Song\"; [ c ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let (score, _) = try parser.parse(data)

        #expect(score.variables.count == 1)

        guard case let .string(value) = score.variables[0].value
        else {
            Issue.record("Expected string variable value")
            return
        }

        #expect(value == "My Song")
    }

    @Test
    func pitch_accidentalForms() throws {
        let score = try parse("[ c# d## e& f&& g ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.accidental) == [.sharp, .doubleSharp, .flat, .doubleFlat, .omitted])
    }

    @Test
    func pitch_diatonicNames() throws {
        let score = try parse("[ a b c d e f g h ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.a, .b, .c, .d, .e, .f, .g, .h])
        #expect(notes.allSatisfy { $0.pitch.accidental == .omitted })
    }

    @Test
    func pitch_emptyName() throws {
        let score = try parse("[ empty ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.empty])
    }

    @Test
    func pitch_explicitOctave() throws {
        let score = try parse("[ c1 d5 e-1 f+2 ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.octave) == [1, 5, -1, 2])
    }

    @Test
    func pitch_germanChromaticNames() throws {
        let score = try parse("[ ais cis dis fis gis ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.ais, .cis, .dis, .fis, .gis])
        #expect(notes.allSatisfy { $0.pitch.accidental == .impliedSharp })
    }

    @Test
    func pitch_octaveOmittedIsPreservedAsNil() throws {
        let score = try parse("[ c1 d e5 f ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.octave) == [1, nil, 5, nil])
    }

    @Test
    func pitch_octaveOmittedWhenNeverSpecified() throws {
        let score = try parse("[ c ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.octave) == [nil])
    }

    @Test
    func pitch_solfegeNames() throws {
        let score = try parse("[ do re mi fa sol la si ti ]")
        let notes = try notes(score.voices[0].symbols)

        #expect(notes.map(\.pitch.name) == [.do, .re, .mi, .fa, .sol, .la, .si, .ti])
    }

    @Test
    func rest_withAndWithoutDuration() throws {
        let score = try parse("[ c*1/2 _ _/8 d ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 4)

        guard case let .note(note1) = symbols[0],
              case let .rest(rest1) = symbols[1],
              case let .rest(rest2) = symbols[2],
              case let .note(note2) = symbols[3]
        else {
            Issue.record("Expected note, rest, rest, note symbols")
            return
        }

        #expect(note1.duration == makeDuration(1, 2))
        #expect(rest1.duration == nil)
        #expect(rest2.duration == makeDuration(1, 8))
        #expect(note2.duration == nil)
    }

    @Test
    func score_multipleVoices() throws {
        let score = try parse("{ [c d e], [g a b] }")

        #expect(score.voices.count == 2)
        #expect(score.voices[0].symbols.count == 3)
        #expect(score.voices[1].symbols.count == 3)
    }

    @Test
    func score_variablesAndMultipleVoicesTogether() throws {
        let input = "$tempo = 120; { [c1 d], [g5 a] }"
        let score = try parse(input)

        #expect(score.variables.count == 1)
        #expect(score.voices.count == 2)

        let notes0 = try notes(score.voices[0].symbols)
        let notes1 = try notes(score.voices[1].symbols)

        #expect(notes0.map(\.pitch.octave) == [1, nil])
        #expect(notes1.map(\.pitch.octave) == [5, nil])
    }

    @Test
    func stringVariable_emptyBody_stashesEmptySymbols() throws {
        // `[]`, not `nil`. guidolib pushes the body onto its lexer stream
        // and pops it again on the first read (`GuidoParser.cpp` `get`), so
        // an empty body is legal and contributes nothing at each reference.
        // `nil` is reserved for a variable that cannot supply symbols at
        // all, which is a rejection — see
        // `symbolReference_toEmptyStringVariable_isAccepted`.
        let input = "$empty = \"\"; [ c ]"
        let (score, _) = try GMNParser().parse(Data(input.utf8))

        #expect(score.variables[0].symbols?.isEmpty == true)
    }

    @Test
    func stringVariable_gmnBody_stashesSymbolsWithOmissionPreserved() throws {
        let input = "$seq = \"a/4 \\slur(b c2/2)\"; [ c ]"
        let (score, _) = try GMNParser().parse(Data(input.utf8))

        let symbols = try #require(score.variables[0].symbols)

        #expect(symbols.count == 2)

        guard case let .note(first) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(first.pitch.name == .a)
        #expect(first.duration == makeDuration(1, 4))

        guard case let .tag(tag) = symbols[1]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.name == makeTagName("slur"))
        #expect(tag.body.count == 2)

        guard case let .note(inner1) = tag.body[0],
              case let .note(inner2) = tag.body[1]
        else {
            Issue.record("Expected note symbols inside tag")
            return
        }

        // `b` has no duration written in the variable's own body — omission
        // is preserved, not resolved against `a/4`.
        #expect(inner1.pitch.name == .b)
        #expect(inner1.duration == nil)

        #expect(inner2.pitch.name == .c)
        #expect(inner2.pitch.octave == 2)
        #expect(inner2.duration == makeDuration(1, 2))
    }

    @Test
    func stringVariable_malformedGMNBody_throwsParseError() throws {
        // Tokenizes as GMN-shaped content (two notes and a stray open
        // parenthesis) but doesn't match cleanly — a genuine parse error
        // inside a GMN-valued body, reported once, here, rather than
        // silently discarded.
        let input = "$bad = \"c d (\"; [ c ]"

        #expect(throws: GMNParser.Error.self) {
            try GMNParser().parse(Data(input.utf8))
        }
    }

    @Test
    func stringVariable_nonGMNBody_stashesNilSymbolsSilently() throws {
        let input = "$title = \"My Song\"; [ c ]"
        let (score, _) = try GMNParser().parse(Data(input.utf8))

        #expect(score.variables[0].symbols == nil)
    }

    @Test
    func symbolPosition_isRejected() throws {
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ $missing c ]".utf8))
        }
    }

    @Test
    func symbolReference_insideAnotherVariablesBody_isChecked() throws {
        // The walk covers variable bodies, not just voices: `$a`'s stashed
        // fragment is itself a reference, and `$b` cannot supply symbols.
        #expect(throws: GMNParser.Error.nonSymbolVariableReference("b")) {
            try GMNParser().parse(Data("$b = 3; $a = \"$b\"; [ $a ]".utf8))
        }
    }

    @Test
    func symbolReference_insideATagBody_isChecked() throws {
        #expect(throws: GMNParser.Error.nonSymbolVariableReference("x")) {
            try GMNParser().parse(Data("$x = 3; [ \\slur( $x c ) ]".utf8))
        }
    }

    @Test
    func symbolReference_takesTheLastDeclaration() throws {
        // guidolib's `fEnv` is a map and `variableDecl` assigns, so a
        // redeclaration wins outright. The first binding here could supply
        // symbols and the second cannot, so the reference is rejected.
        #expect(throws: GMNParser.Error.nonSymbolVariableReference("x")) {
            try GMNParser().parse(Data("$x = \"c d\"; $x = 3; [ $x ]".utf8))
        }
    }

    @Test
    func symbolReference_toEmptyStringVariable_isAccepted() throws {
        // An empty body is not "cannot supply symbols" — it supplies none,
        // which guidolib allows.
        let (score, _) = try GMNParser().parse(Data("$x = \"\"; [ $x c ]".utf8))

        #expect(score.variables[0].symbols?.isEmpty == true)
    }

    @Test
    func symbolReference_toUndeclaredVariable_isTheOtherError() throws {
        // FLIPPED IN PHASE 3. An undeclared name used to be the validator's
        // to report; it is now rejected here too, as a *different* error.
        // The two are worth keeping apart — this one is about a declared
        // variable that cannot supply symbols, and it is a defect only in
        // symbol position, whereas an unanswered name is a defect anywhere.
        // `GMNParserVariableReferenceTests` covers the other.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("nope")) {
            try GMNParser().parse(Data("[ $nope c ]".utf8))
        }
    }

    @Test(arguments: ["$x = 3; [ $x c ]",
                      "$x = 3.5; [ $x c ]",
                      "$x = \"My Song\"; [ $x c ]"])
    func symbolReference_toVariableWithNoSymbols_throws(_ input: String) throws {
        // guidolib pushes the referenced body onto its lexer stream
        // (`GuidoParser.cpp:345–361`), where a bare `3` is not a symbol, so
        // the grammar fails. IvorGuido used to accept all three of these,
        // stash `symbols == nil`, and then silently drop the reference at
        // resolve time — `$x = 3; [ $x c ]` realized one event.
        #expect(throws: GMNParser.Error.nonSymbolVariableReference("x")) {
            try GMNParser().parse(Data(input.utf8))
        }
    }

    @Test
    func tablature_basic() throws {
        let score = try parse("[ s1:3: s2:x:/8 ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 2)

        guard case let .tablature(tab1) = symbols[0],
              case let .tablature(tab2) = symbols[1]
        else {
            Issue.record("Expected tablature symbols")
            return
        }

        #expect(tab1.tabString == 1)
        #expect(tab1.fret == "3")
        #expect(tab1.duration == nil)

        #expect(tab2.tabString == 2)
        #expect(tab2.fret == "x")
        #expect(tab2.duration == makeDuration(1, 8))
    }

    @Test
    func tablature_fretEscape() throws {
        let score = try parse("[ s1:a\\ b: ]")
        let symbols = score.voices[0].symbols

        guard case let .tablature(tablature) = symbols[0]
        else {
            Issue.record("Expected tablature symbol")
            return
        }

        #expect(tablature.fret == "a b")
    }

    @Test
    func tag_barShorthand() throws {
        let score = try parse("[ c | d ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        // `guido.y:180` rewrites the bare token to a `\bar` with no parameters
        // and no ident, so it promotes like any other barline — and, carrying
        // nothing, reports `|` right back.
        guard case let .tag(.barLine(bar)) = symbols[1]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(bar.kind == .single)
        #expect(bar.isBare)
        #expect(bar.name == makeTagName("|"))
        #expect(bar.ident == nil)
    }

    @Test
    func tag_identifierSuffix() throws {
        let score = try parse("[ \\tieBegin:1 c \\tieEnd:1 d ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.tie(begin)) = symbols[0],
              case let .tag(.tie(end)) = symbols[2]
        else {
            Issue.record("Expected tie tag symbols")
            return
        }

        #expect(begin.ident == makeTagIdent(1))
        #expect(end.ident == makeTagIdent(1))
    }

    @Test
    func tag_omittedDurationIsPreservedInAndAfterTagBody() throws {
        let score = try parse("[ \\slur(c d/8) e ]")
        let symbols = score.voices[0].symbols

        // What matters here is the sticky duration, not which lane the
        // enclosing tag ends up in.
        guard case let .tag(.slur(tag)) = symbols[0],
              case let .note(outer) = symbols[1]
        else {
            Issue.record("Expected slur tag and note symbols")
            return
        }

        guard case let .note(inner) = tag.body[1]
        else {
            Issue.record("Expected note symbol in tag body")
            return
        }

        #expect(inner.duration == makeDuration(1, 8))
        #expect(outer.duration == nil)
    }

    @Test
    func tag_positionForm() throws {
        let score = try parse("[ \\slurBegin c d \\slurEnd ]")
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 4)

        // `\\slur` promotes, so the two halves are one payload carrying a
        // span rather than two unrelated names.
        guard case let .tag(.slur(begin)) = symbols[0],
              case let .tag(.slur(end)) = symbols[3]
        else {
            Issue.record("Expected slur tag symbols")
            return
        }

        #expect(begin.span == .begin)
        #expect(begin.body.isEmpty)
        #expect(end.span == .end)
    }

    @Test
    func tag_positionWithParametersForm() throws {
        let score = try parse("[ \\tempo<\"Allegro\", 120> c ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.reserved(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.name == makeTagName("tempo"))
        #expect(tag.parameters.count == 2)
        #expect(tag.parameters[0] == makeTagParameter(.string("Allegro")))
        #expect(tag.parameters[1] == makeTagParameter(.integer(120, nil)))
        #expect(tag.body.isEmpty)
    }

    @Test
    func tag_rangeForm() throws {
        let score = try parse("[ \\slur(c d e) ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.slur(tag)) = symbols[0]
        else {
            Issue.record("Expected slur tag symbol")
            return
        }

        #expect(tag.span == .whole)
        #expect(tag.body.count == 3)
    }

    @Test
    func tag_rangeWithParametersForm() throws {
        let score = try parse("[ \\stacc<0.5> (c d) ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.reserved(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.name == makeTagName("stacc"))
        #expect(tag.parameters == [makeTagParameter(.floating(0.5, nil))])
        #expect(tag.body.count == 2)
    }

    @Test
    func tagParameter_allTypes() throws {
        let input = "$x = 42; [ \\tempo<\"Allegro\", 120, 3.14, $x> c ]"
        let score = try parse(input)
        let symbols = score.voices[0].symbols

        guard case let .tag(.reserved(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.parameters == [makeTagParameter(.string("Allegro")),
                                   makeTagParameter(.integer(120, nil)),
                                   makeTagParameter(.floating(3.14, nil)),
                                   makeTagParameter(.variable("x"))])
    }

    @Test
    func tagParameter_namedWithUnit() throws {
        let score = try parse("[ \\staffFormat<dx=5hs, dy=-2.5pt> c ]")
        let symbols = score.voices[0].symbols

        // `\staffFormat` promotes, so the units are checked on the typed
        // lengths rather than on a written parameter list.
        guard case let .tag(.staffFormat(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.appearance.dx == GMNLength(5, unit: .hs))
        #expect(tag.appearance.dy == GMNLength(-2.5, unit: .pt))
    }

    @Test
    func tagParameter_rawNamedForm() throws {
        let score = try parse("[ \\tag<mode=rawIdent> c ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.custom(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.parameters == [makeTagParameter("mode", .parameter("rawIdent"))])
    }

    @Test
    func tagParameter_rawUnnamedForm() throws {
        // A bare, unquoted identifier with no `name=` prefix is a
        // syntactically legal (if semantically meaningless) `tagarg` in
        // guidolib's own grammar (`guido.y`'s `tagarg: id` production) —
        // guidolib just discards its value. IvorGuido instead preserves it
        // as an unnamed `.parameter` value.
        let score = try parse("[ \\tag<rawIdent> c ]")
        let symbols = score.voices[0].symbols

        guard case let .tag(.custom(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.parameters == [makeTagParameter(.parameter("rawIdent"))])
    }

    @Test
    func tagParameterPosition_isRejected() throws {
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ \\beam<dy=$missing>(c d) ]".utf8))
        }
    }

    @Test
    func tagParameterPosition_onASpanEnd_isRejected() throws {
        // `\beamEnd`'s parameters are dropped wholesale by the normalizer, so
        // this reference had the narrowest escape of all of them.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ \\beamBegin c d \\beamEnd<dx=$missing> ]".utf8))
        }
    }

    @Test
    func tagParameterPosition_underAnUnsupportedName_isRejected() throws {
        // The exemption every normalizer drop honours, now redundant for
        // parsed input. `bogus` is a name `\beam` does not support, so the
        // repair would have deleted the whole parameter — and did not, purely
        // so the reference could still be reported. It is reported earlier
        // instead.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[ \\beam<bogus=$missing>(c d) ]".utf8))
        }
    }

    @Test
    func variable_declarations() throws {
        let input = "$tempo = 120; $pi = 3.14; $title = \"My Song\"; [ c ]"
        let score = try parse(input)

        #expect(score.variables.count == 3)
        #expect(score.variables[0] == makeVariable("tempo", .integer(120)))
        #expect(score.variables[1] == makeVariable("pi", .floating(3.14)))
        #expect(score.variables[2] == makeVariable("title", .string("My Song")))
    }

    @Test
    func variable_referenceInSymbolPosition() throws {
        let input = "$seq = \"c d e\"; [ $seq f ]"
        let score = try parse(input)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 2)
        #expect(symbols[0] == .variable("seq"))

        guard case let .note(note) = symbols[1]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note.pitch.name == .f)
    }

    @Test
    func variable_referenceInTagParameterPosition() throws {
        let input = "$x = 120; [ \\tempo<$x>(c) ]"
        let score = try parse(input)
        let symbols = score.voices[0].symbols

        guard case let .tag(.reserved(tag)) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.parameters == [makeTagParameter(.variable("x"))])
    }

    @Test
    func vestigial_countDiscardedOnNoteAndRest() throws {
        let input = "[ c<3> _<4>/2 d ]"
        let score = try parse(input)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .note(note) = symbols[0],
              case let .rest(rest) = symbols[1]
        else {
            Issue.record("Expected note and rest symbols")
            return
        }

        #expect(note.pitch.name == .c)
        #expect(rest.duration == makeDuration(1, 2))
    }
}
