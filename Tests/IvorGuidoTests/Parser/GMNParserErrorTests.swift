// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNParserErrorTests {
}

// MARK: -

extension GMNParserErrorTests {
    @Test
    func category() {
        let error = GMNParser.Error.dataConversionFailed

        #expect(error.category?.description == "IvorGuido")
    }

    @Test
    func equatable() {
        let err1a = GMNParser.Error.dataConversionFailed
        let err1b = GMNParser.Error.dataConversionFailed
        let err2 = GMNParser.Error.endOfInput
        let err3a = GMNParser.Error.invalidNote("c")
        let err3b = GMNParser.Error.invalidNote("c")
        let err3c = GMNParser.Error.invalidNote("d")

        #expect(err1a == err1b)
        #expect(err1a != err2)
        #expect(err3a == err3b)
        #expect(err3a != err3c)
    }

    @Test
    func message_dataConversionFailed() {
        #expect(GMNParser.Error.dataConversionFailed.message == "Failed to convert UTF-8 data to string")
    }

    @Test
    func message_endOfInput() {
        #expect(GMNParser.Error.endOfInput.message == "End of input reached prematurely")
    }

    @Test
    func message_invalidChordSegment() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let symbols: [GMNSymbol] = [.note(note)]
        let message = GMNParser.Error.invalidChordSegment(symbols).message

        #expect(message.hasPrefix("Invalid chord segment:"))
    }

    @Test
    func message_invalidNote() {
        #expect(GMNParser.Error.invalidNote("xyz").message == "Invalid note: \u{2018}xyz\u{2019}")
    }

    @Test
    func message_invalidNumber() {
        #expect(GMNParser.Error.invalidNumber("abc").message == "Invalid number: \u{2018}abc\u{2019}")
    }

    @Test
    func message_invalidParameterUnit() {
        #expect(GMNParser.Error.invalidParameterUnit("xx").message == "Invalid parameter unit: \u{2018}xx\u{2019}")
    }

    @Test
    func message_invalidRest() {
        #expect(GMNParser.Error.invalidRest("bad").message == "Invalid rest: \u{2018}bad\u{2019}")
    }

    @Test
    func message_invalidString() {
        #expect(GMNParser.Error.invalidString("bad").message == "Invalid string: \u{2018}bad\u{2019}")
    }

    @Test
    func message_invalidTablature() {
        #expect(GMNParser.Error.invalidTablature("bad").message == "Invalid tablature: \u{2018}bad\u{2019}")
    }

    @Test
    func message_missingTagName() {
        #expect(GMNParser.Error.missingTagName.message == "Missing tag name")
    }

    @Test
    func message_missingVariableValue() {
        #expect(GMNParser.Error.missingVariableValue.message == "Missing variable value")
    }

    @Test
    func message_nestedChord() {
        #expect(GMNParser.Error.nestedChord.message == "Nested chords are disallowed")
    }

    @Test
    func message_tokenizationFailed() {
        #expect(GMNParser.Error.tokenizationFailed("boom").message == "Tokenization failed: boom")
    }

    @Test
    func message_trailingGarbage() {
        #expect(GMNParser.Error.trailingGarbage.message == "Input contains trailing garbage")
    }
}
