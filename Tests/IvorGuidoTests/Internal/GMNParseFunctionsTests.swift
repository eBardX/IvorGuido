// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNParseFunctionsTests {
}

// MARK: -

extension GMNParseFunctionsTests {
    @Test
    func convertString_escapes() {
        #expect(convertString("'\\n'") == "\n")
        #expect(convertString("'\\\\'") == "\\")
        #expect(convertString("'\\\"'") == "\"")
    }

    @Test
    func convertString_failure() {
        #expect(convertString("") == nil)
        #expect(convertString("bogus") == nil)
        #expect(convertString("'I know what it's like to be dead.'") == nil)
    }

    @Test
    func convertString_success() {
        #expect(convertString("''") == "")              // swiftlint:disable:this empty_string
        #expect(convertString("\"\"") == "")            // swiftlint:disable:this empty_string
        #expect(convertString("'foo 1'") == "foo 1")
        #expect(convertString("\"foo 2\"") == "foo 2")
        #expect(convertString("'I know what it\\'s like to be dead.'") == "I know what it's like to be dead.")
    }

    @Test
    func parseDuration_failure() {
        #expect(parseDuration("") == nil)
    }

    @Test
    func parseDuration_invalidInput() {
        #expect(parseDuration("*") == nil)
        #expect(parseDuration("*abc") == nil)
        #expect(parseDuration("*1....") == nil)
        #expect(parseDuration("/") == nil)
    }

    @Test
    func parseDuration_success() {
        #expect(parseDuration("...") == (nil, nil, 3))
        #expect(parseDuration("..") == (nil, nil, 2))
        #expect(parseDuration(".") == (nil, nil, 1))
        #expect(parseDuration("*2") == (2, 1, nil))
        #expect(parseDuration("*2/4..") == (2, 4, 2))
        #expect(parseDuration("*2ms") == (2, nil, nil))
        #expect(parseDuration("*3..") == (3, 1, 2))
        #expect(parseDuration("*3/4") == (3, 4, nil))
        #expect(parseDuration("/16") == (1, 16, nil))
        #expect(parseDuration("/2...") == (1, 2, 3))
    }

    @Test
    func parseNote_failure() {
        #expect(parseNote("") == nil)
    }

    @Test
    func parseNote_solfege() {
        #expect(parseNote("do/4") == ((.c, nil, nil), (1, 4, nil)))
        #expect(parseNote("sol-1") == ((.g, nil, 2), nil))
    }

    @Test
    func parseNote_success() {
        #expect(parseNote("a&-1/2") == ((.a, .flat, 2), (1, 2, nil)))
        #expect(parseNote("a&&2/4.") == ((.a, .doubleFlat, 5), (1, 4, 1)))
        #expect(parseNote("b&1.") == ((.b, .flat, 4), (nil, nil, 1)))
        #expect(parseNote("c#/16") == ((.c, .sharp, nil), (1, 16, nil)))
        #expect(parseNote("d##*2ms") == ((.d, .doubleSharp, nil), (2, nil, nil)))
        #expect(parseNote("e") == ((.e, nil, nil), nil))
        #expect(parseNote("e&...") == ((.e, .flat, nil), (nil, nil, 3)))
        #expect(parseNote("empty*7/4") == ((.empty, nil, nil), (7, 4, nil)))
        #expect(parseNote("f#0/8") == ((.f, .sharp, 3), (1, 8, nil)))
        #expect(parseNote("g-1*3/4") == ((.g, nil, 2), (3, 4, nil)))
        #expect(parseNote("g#/4") == ((.g, .sharp, nil), (1, 4, nil)))
        #expect(parseNote("h#1/4") == ((.b, .sharp, 4), (1, 4, nil)))
    }

    @Test
    func parsePitch_chromatic() {
        #expect(parsePitch("ais") == (.a, .sharp, nil))
        #expect(parsePitch("cis") == (.c, .sharp, nil))
        #expect(parsePitch("dis") == (.d, .sharp, nil))
        #expect(parsePitch("fis") == (.f, .sharp, nil))
        #expect(parsePitch("gis") == (.g, .sharp, nil))
    }

    @Test
    func parsePitch_failure() {
        #expect(parsePitch("") == nil)
    }

    @Test
    func parsePitch_solfege() {
        #expect(parsePitch("do") == (.c, nil, nil))
        #expect(parsePitch("fa") == (.f, nil, nil))
        #expect(parsePitch("la") == (.a, nil, nil))
        #expect(parsePitch("mi") == (.e, nil, nil))
        #expect(parsePitch("re") == (.d, nil, nil))
        #expect(parsePitch("si") == (.b, nil, nil))
        #expect(parsePitch("sol") == (.g, nil, nil))
        #expect(parsePitch("ti") == (.b, nil, nil))
    }

    @Test
    func parsePitch_success() {
        #expect(parsePitch("a&-1") == (.a, .flat, 2))
        #expect(parsePitch("a&&2") == (.a, .doubleFlat, 5))
        #expect(parsePitch("b&1") == (.b, .flat, 4))
        #expect(parsePitch("c#") == (.c, .sharp, nil))
        #expect(parsePitch("d##") == (.d, .doubleSharp, nil))
        #expect(parsePitch("e") == (.e, nil, nil))
        #expect(parsePitch("e&") == (.e, .flat, nil))
        #expect(parsePitch("empty") == (.empty, nil, nil))
        #expect(parsePitch("f#0") == (.f, .sharp, 3))
        #expect(parsePitch("g-1") == (.g, nil, 2))
        #expect(parsePitch("g#") == (.g, .sharp, nil))
        #expect(parsePitch("h#1") == (.b, .sharp, 4))
    }

    @Test
    func parseRest_failure() {
        #expect(parseRest("") == nil)
    }

    @Test
    func parseRest_invalidInput() {
        #expect(parseRest("x") == nil)
        #expect(parseRest("__") == nil)
    }

    @Test
    func parseRest_success() {
        #expect(parseRest("_") == ("_", nil))
        #expect(parseRest("_*3/4") == ("_", (3, 4, nil)))
        #expect(parseRest("_/16") == ("_", (1, 16, nil)))
        #expect(parseRest("_/2...") == ("_", (1, 2, 3)))
    }

    @Test
    func parseTablature_failure() {
        #expect(parseTablature("") == nil)
    }

    @Test
    func parseTablature_invalidInput() {
        #expect(parseTablature("abc") == nil)
        #expect(parseTablature("s1:5") == nil)
    }

    @Test
    func parseTablature_success() {
        #expect(parseTablature("s1:4:") == (1, "4", nil))
        #expect(parseTablature("s2:x:") == (2, "x", nil))
        #expect(parseTablature("s3:5:/8") == (3, "5", (1, 8, nil)))
        #expect(parseTablature("s4:x:/4") == (4, "x", (1, 4, nil)))
    }

    @Test
    func splitTagNameIdent() {
        #expect(IvorGuido.splitTagNameIdent("\\slurBegin") == ("\\slurBegin", nil))
        #expect(IvorGuido.splitTagNameIdent("\\slurEnd:1") == ("\\slurEnd", 1))
        #expect(IvorGuido.splitTagNameIdent("\\tieBegin:2") == ("\\tieBegin", 2))
        #expect(IvorGuido.splitTagNameIdent("\\tieEnd:3") == ("\\tieEnd", 3))
    }
}

// MARK: - Private Functions

// swiftlint:disable:next static_operator
private func == (lhs: ParseDurationResult?,
                 rhs: ParseDurationResult?) -> Bool {
    lhs?.denominator == rhs?.denominator
    && lhs?.dots == rhs?.dots
    && lhs?.numerator == rhs?.numerator
}

// swiftlint:disable:next static_operator
private func == (lhs: ParseNoteResult?,
                 rhs: ParseNoteResult?) -> Bool {
    lhs?.duration == rhs?.duration
    && lhs?.pitch == rhs?.pitch
}

// swiftlint:disable:next static_operator
private func == (lhs: ParsePitchResult?,
                 rhs: ParsePitchResult?) -> Bool {
    lhs?.accidental == rhs?.accidental
    && lhs?.letter == rhs?.letter
    && lhs?.octave == rhs?.octave
}

// swiftlint:disable:next static_operator
private func == (lhs: ParseRestResult?,
                 rhs: ParseRestResult?) -> Bool {
    lhs?.0 == rhs?.0
    && lhs?.duration == rhs?.duration
}

// swiftlint:disable:next static_operator
private func == (lhs: ParseTablatureResult?,
                 rhs: ParseTablatureResult?) -> Bool {
    lhs?.duration == rhs?.duration
    && lhs?.fret == rhs?.fret
    && lhs?.tabString == rhs?.tabString
}

// swiftlint:disable:next static_operator
private func == (lhs: (String, UInt?),
                 rhs: (String, UInt?)) -> Bool {
    lhs.0 == rhs.0
    && lhs.1 == rhs.1
}
