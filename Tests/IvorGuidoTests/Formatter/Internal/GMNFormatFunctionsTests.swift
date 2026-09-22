// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNFormatFunctionsTests {
}

// MARK: -

extension GMNFormatFunctionsTests {
    @Test
    func formatChord_joinsSegmentsWithComma() {
        let note1 = makeNote(makePitch(.c))
        let note2 = makeNote(makePitch(.e))
        let segment1 = makeChordSegment([.note(note1)])
        let segment2 = makeChordSegment([.note(note2)])
        let chord = makeChord([segment1, segment2])

        #expect(formatChord(chord) == "{c,e}")
    }

    @Test
    func formatDuration_dotsOnlyNoBase() {
        #expect(formatDuration(makeDuration(dots: 2)) == "..")
    }

    @Test
    func formatDuration_fractionBase() {
        #expect(formatDuration(makeDuration(1, 4)) == "*1/4")
    }

    @Test
    func formatDuration_fractionBase_denominatorOneOmitsSlash() {
        #expect(formatDuration(makeDuration(3, 1)) == "*3")
    }

    @Test
    func formatDuration_fractionBaseWithDots() {
        #expect(formatDuration(makeDuration(1, 4, dots: 3)) == "*1/4...")
    }

    @Test
    func formatDuration_millisecondsBase() {
        #expect(formatDuration(makeDuration(500)) == "*500ms")
    }

    @Test
    func formatDuration_omittedBaseNoDots_writesNothing() {
        #expect(formatDuration(nil).isEmpty)
    }

    @Test
    func formatNote_combinesPitchAndDuration() {
        let note = makeNote(makePitch(.c, .sharp, 4), makeDuration(1, 8))

        #expect(formatNote(note) == "c#4*1/8")
    }

    @Test(arguments: [(GMNPitch.Accidental.doubleFlat, "c&&"),
                      (.doubleSharp, "c##"),
                      (.flat, "c&"),
                      (.omitted, "c"),
                      (.sharp, "c#")])
    func formatPitch_accidentals(_ pair: (accidental: GMNPitch.Accidental, expected: String)) {
        let pitch = makePitch(.c, pair.accidental)

        #expect(formatPitch(pitch) == pair.expected)
    }

    @Test
    func formatPitch_impliedSharpCarriedByName_notDuplicated() {
        let pitch = makePitch(.cis, .impliedSharp)

        #expect(formatPitch(pitch) == "cis")
    }

    @Test
    func formatPitch_octaveOmitted() {
        let pitch = makePitch(.c)

        #expect(formatPitch(pitch) == "c")
    }

    @Test
    func formatPitch_octaveWritten() {
        let pitch = makePitch(.c, 4)

        #expect(formatPitch(pitch) == "c4")
    }

    @Test
    func formatRest_combinesRestMarkerAndDuration() {
        #expect(formatRest(makeRest(makeDuration(1, 2))) == "_*1/2")
    }

    @Test
    func formatSegment_joinsSymbolsWithSpace() {
        let note1 = GMNSymbol.note(makeNote(makePitch(.c)))
        let note2 = GMNSymbol.note(makeNote(makePitch(.d)))
        let segment = makeChordSegment([note1, note2])

        #expect(formatSegment(segment) == "c d")
    }

    @Test
    func formatSymbol_note() {
        let note = makeNote(makePitch(.c))

        #expect(formatSymbol(.note(note)) == "c")
    }

    @Test
    func formatSymbol_rest() {
        #expect(formatSymbol(.rest(makeRest(nil))) == "_")
    }

    @Test
    func formatSymbol_tablature() {
        let tablature = makeTablature(1, "3")

        #expect(formatSymbol(.tablature(tablature)) == "s1:3:")
    }

    @Test
    func formatSymbol_tag() {
        let tag = makeTag(makeTagName("bar"))

        #expect(formatSymbol(.tag(tag)) == "\\bar")
    }

    @Test
    func formatSymbol_variable_writesNameVerbatim() {
        #expect(formatSymbol(.variable("seq")) == "$seq")
    }

    @Test
    func formatTablature_basic() {
        let tablature = makeTablature(3, "5")

        #expect(formatTablature(tablature) == "s3:5:")
    }

    @Test
    func formatTablature_escapesDelimiterInFret() {
        // `:` is the fret field's own delimiter, so a literal `:` inside the
        // fret value must be escaped to stay round-trippable.
        let tablature = makeTablature(1, "x:y")

        #expect(formatTablature(tablature) == "s1:x\\:y:")
    }

    @Test
    func formatTag_barShorthand_noBackslash() {
        let tag = makeTag(makeTagName("|"))

        #expect(formatTag(tag) == "|")
    }

    @Test
    func formatTag_ordinaryName_addsBackslash() {
        let tag = makeTag(makeTagName("slur"))

        #expect(formatTag(tag) == "\\slur")
    }

    @Test
    func formatTag_withIdent() {
        let tag = makeTag(makeTagName("tie"), ident: makeTagIdent(1))

        #expect(formatTag(tag) == "\\tie:1")
    }

    @Test
    func formatTag_withParameters() {
        let tag = makeTag(makeTagName("tempo"),
                          parameters: [makeTagParameter(.string("Allegro")),
                                       makeTagParameter(.integer(120, nil))])

        #expect(formatTag(tag) == "\\tempo<\"Allegro\",120>")
    }

    @Test
    func formatTag_withSymbols() {
        let note = GMNSymbol.note(makeNote(makePitch(.c)))
        let tag = makeTag(makeTagName("slur"), body: [note])

        #expect(formatTag(tag) == "\\slur(c)")
    }

    @Test
    func formatTagParameter_floating_namedWithUnit() {
        #expect(formatTagParameter(makeTagParameter("dx", .floating(1.5, .cm))) == "dx=1.5cm")
    }

    @Test
    func formatTagParameter_floating_unnamed() {
        #expect(formatTagParameter(makeTagParameter(.floating(0.5, nil))) == "0.5")
    }

    @Test
    func formatTagParameter_integer_namedWithUnit() {
        #expect(formatTagParameter(makeTagParameter("n", .integer(3, .pt))) == "n=3pt")
    }

    @Test
    func formatTagParameter_parameter_unnamed() {
        #expect(formatTagParameter(makeTagParameter(.parameter("raw"))) == "raw")
    }

    @Test
    func formatTagParameter_string_quotesAndEscapes() {
        #expect(formatTagParameter(makeTagParameter(.string("a\"b"))) == "\"a\\\"b\"")
    }

    @Test
    func formatTagParameter_variable_namedWithoutQuoting() {
        #expect(formatTagParameter(makeTagParameter("m", .variable("mark"))) == "m=$mark")
    }

    @Test
    func formatVariableDeclaration_appendsSemicolon() {
        let variable = makeVariable("x", .integer(3))

        #expect(formatVariableDeclaration(variable) == "$x = 3;")
    }

    @Test
    func formatVariableValue_floating() {
        #expect(formatVariableValue(.floating(3.14)) == "3.14")
    }

    @Test
    func formatVariableValue_integer() {
        #expect(formatVariableValue(.integer(42)) == "42")
    }

    @Test
    func formatVariableValue_string_escapesBackslash() {
        #expect(formatVariableValue(.string("a\\b")) == "\"a\\\\b\"")
    }

    @Test
    func formatVariableValue_string_escapesNewline() {
        #expect(formatVariableValue(.string("a\nb")) == "\"a\\nb\"")
    }

    @Test
    func formatVariableValue_string_quoted() {
        #expect(formatVariableValue(.string("hi")) == "\"hi\"")
    }

    @Test
    func formatVoice_joinsSymbolsWithSpaceInBrackets() {
        let note1 = GMNSymbol.note(makeNote(makePitch(.c)))
        let note2 = GMNSymbol.note(makeNote(makePitch(.d)))

        #expect(formatVoice(makeVoice([note1, note2])) == "[c d]")
    }
}
