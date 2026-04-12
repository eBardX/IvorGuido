// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

@Suite
struct GMNParseErrorTests {
}

// MARK: -

extension GMNParseErrorTests {
    @Test
    func test_category() {
        let error = GMNParseError.dataConversionFailed

        #expect(error.category?.description == "IvorGuido")
    }

    @Test
    func test_equatable() {
        let err1a = GMNParseError.dataConversionFailed
        let err1b = GMNParseError.dataConversionFailed
        let err2 = GMNParseError.endOfInput
        let err3a = GMNParseError.invalidNote("c")
        let err3b = GMNParseError.invalidNote("c")
        let err3c = GMNParseError.invalidNote("d")

        #expect(err1a == err1b)
        #expect(err1a != err2)
        #expect(err3a == err3b)
        #expect(err3a != err3c)
    }

    @Test
    func test_message_dataConversionFailed() {
        #expect(GMNParseError.dataConversionFailed.message == "Failed to convert UTF-8 data to string")
    }

    @Test
    func test_message_endOfInput() {
        #expect(GMNParseError.endOfInput.message == "End of input reached prematurely")
    }

    @Test
    func test_message_invalidChordSegment() {
        let note = GMNNote(pitch: GMNPitch(letter: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: .fraction(1, 4))
        let symbols: [GMNSymbol] = [.note(note)]
        let message = GMNParseError.invalidChordSegment(symbols).message

        #expect(message.hasPrefix("Invalid chord segment:"))
    }

    @Test
    func test_message_invalidNote() {
        #expect(GMNParseError.invalidNote("xyz").message == "Invalid note: \u{2018}xyz\u{2019}")
    }

    @Test
    func test_message_invalidNumber() {
        #expect(GMNParseError.invalidNumber("abc").message == "Invalid number: \u{2018}abc\u{2019}")
    }

    @Test
    func test_message_invalidParameterUnit() {
        #expect(GMNParseError.invalidParameterUnit("xx").message == "Invalid parameter unit: \u{2018}xx\u{2019}")
    }

    @Test
    func test_message_invalidRest() {
        #expect(GMNParseError.invalidRest("bad").message == "Invalid rest: \u{2018}bad\u{2019}")
    }

    @Test
    func test_message_invalidString() {
        #expect(GMNParseError.invalidString("bad").message == "Invalid string: \u{2018}bad\u{2019}")
    }

    @Test
    func test_message_invalidTablature() {
        #expect(GMNParseError.invalidTablature("bad").message == "Invalid tablature: \u{2018}bad\u{2019}")
    }

    @Test
    func test_message_missingTagName() {
        #expect(GMNParseError.missingTagName.message == "Missing tag name")
    }

    @Test
    func test_message_missingVariableValue() {
        #expect(GMNParseError.missingVariableValue.message == "Missing variable value")
    }

    @Test
    func test_message_nestedChord() {
        #expect(GMNParseError.nestedChord.message == "Nested chords are disallowed")
    }

    @Test
    func test_message_trailingGarbage() {
        #expect(GMNParseError.trailingGarbage.message == "Input contains trailing garbage")
    }
}
