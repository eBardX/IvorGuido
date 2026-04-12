// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing

@Suite
struct GMNParserTests {
}

// MARK: -

extension GMNParserTests {
    @Test
    func test_parse_chord() throws {
        let input = "[ {c, e, g} ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

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
    func test_parse_chordWithTags() throws {
        let input = "[ {\\accent(c), e, g} ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
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
    func test_parse_dataConversionFailed() throws {
        let data = Data([0xFF, 0xFE])
        let parser = GMNParser()

        #expect(throws: GMNParseError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func test_parse_multipleVoices() throws {
        let input = "{ [c d e], [g a b] }"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

        #expect(score.voices.count == 2)
        #expect(score.voices[0].symbols.count == 3)
        #expect(score.voices[1].symbols.count == 3)
    }

    @Test
    func test_parse_noteWithAccidental() throws {
        let input = "[ c# d& e&& f## ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 4)

        guard case let .note(note1) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note1.pitch.letter == .c)
        #expect(note1.pitch.accidental == .sharp)

        guard case let .note(note2) = symbols[1]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note2.pitch.letter == .d)
        #expect(note2.pitch.accidental == .flat)
    }

    @Test
    func test_parse_noteWithDuration() throws {
        let input = "[ c/4 d/8 e*3/4 ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .note(note1) = symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note1.pitch.letter == .c)

        guard case let .fraction(n, d) = note1.duration.value
        else {
            Issue.record("Expected fraction duration")
            return
        }

        #expect(n == 1)
        #expect(d == 4)
    }

    @Test
    func test_parse_noteWithExcessiveAccidental() throws {
        let input = "[ c### ]"
        let data = Data(input.utf8)
        let parser = GMNParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func test_parse_rest() throws {
        let input = "[ c _/4 d ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 3)

        guard case let .rest(rest) = symbols[1]
        else {
            Issue.record("Expected rest symbol")
            return
        }

        guard case let .fraction(n, d) = rest.duration.value
        else {
            Issue.record("Expected fraction duration")
            return
        }

        #expect(n == 1)
        #expect(d == 4)
    }

    @Test
    func test_parse_simpleNotes() throws {
        let input = "[ c d e f g ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

        #expect(score.variables.isEmpty)
        #expect(score.voices.count == 1)
        #expect(score.voices[0].symbols.count == 5)

        guard case let .note(note) = score.voices[0].symbols[0]
        else {
            Issue.record("Expected note symbol")
            return
        }

        #expect(note.pitch.letter == .c)
    }

    @Test
    func test_parse_tagWithParameters() throws {
        let input = "[ \\tempo<\"Allegro\", 120> (c d e) ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 1)

        guard case let .tag(tag) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag.name == "\\tempo")
        #expect(tag.parameters.count == 2)
        #expect(tag.symbols.count == 3)
        #expect(tag.parameters[0].stringValue == "Allegro")
        #expect(tag.parameters[1].integerValue == 120)
    }

    @Test
    func test_parse_tagWithoutParameters() throws {
        let input = "[ \\slurBegin c d e \\slurEnd ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)
        let symbols = score.voices[0].symbols

        #expect(symbols.count == 5)

        guard case let .tag(tag1) = symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(tag1.name == "\\slurBegin")
        #expect(tag1.parameters.isEmpty)
        #expect(tag1.symbols.isEmpty)
    }

    @Test
    func test_parse_variables() throws {
        let input = "$tempo = 120; [ c d e ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

        #expect(score.variables.count == 1)
        #expect(score.variables[0].name == "$tempo")

        guard case let .integer(value) = score.variables[0].value
        else {
            Issue.record("Expected integer variable value")
            return
        }

        #expect(value == 120)
    }

    @Test
    func test_parse_variablesFloating() throws {
        let input = "$pi = 3.14; [ c ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

        #expect(score.variables.count == 1)

        guard case let .floating(value) = score.variables[0].value
        else {
            Issue.record("Expected floating variable value")
            return
        }

        #expect(value == 3.14)
    }

    @Test
    func test_parse_variablesString() throws {
        let input = "$title = \"My Song\"; [ c ]"
        let data = Data(input.utf8)
        let parser = GMNParser()
        let score = try parser.parse(data)

        #expect(score.variables.count == 1)

        guard case let .string(value) = score.variables[0].value
        else {
            Issue.record("Expected string variable value")
            return
        }

        #expect(value == "My Song")
    }
}
