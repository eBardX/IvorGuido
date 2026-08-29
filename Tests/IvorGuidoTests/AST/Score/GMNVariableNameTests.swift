// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNVariableNameTests {
}

// MARK: -

extension GMNVariableNameTests {
    @Test
    func equatable() {
        let a = GMNVariable.Name(stringValue: "x")
        let b = GMNVariable.Name(stringValue: "x")
        let c = GMNVariable.Name(stringValue: "y")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_nilForInvalidName() {
        #expect(GMNVariable.Name(stringValue: "") == nil)
        #expect(GMNVariable.Name(stringValue: "1x") == nil)
    }

    @Test
    func init_storesValue() {
        #expect(GMNVariable.Name(stringValue: "tempo1")?.stringValue == "tempo1")
    }

    @Test
    func isValid_digitsAndUnderscoresAfterTheFirst() {
        #expect(GMNVariable.Name.isValid("a1"))
        #expect(GMNVariable.Name.isValid("a_1"))
        #expect(GMNVariable.Name.isValid("_x"))
    }

    @Test
    func isValid_emptyIsInvalid() {
        #expect(!GMNVariable.Name.isValid(""))
    }

    @Test
    func isValid_leadingDigitIsInvalid() {
        // The first character is a letter or an underscore; a digit there
        // would make `$1` ambiguous against a positional parameter.
        #expect(!GMNVariable.Name.isValid("1x"))
    }

    @Test
    func isValid_nonASCIIIsInvalid() {
        // `isLetter` alone would admit these, so the ASCII guard is what
        // actually decides them.
        #expect(!GMNVariable.Name.isValid("é"))
        #expect(!GMNVariable.Name.isValid("aé"))
    }

    @Test
    func isValid_punctuationIsInvalid() {
        #expect(!GMNVariable.Name.isValid("a-b"))
        #expect(!GMNVariable.Name.isValid("a b"))
    }

    @Test
    func isValid_simpleName() {
        #expect(GMNVariable.Name.isValid("x"))
        #expect(GMNVariable.Name.isValid("tempo"))
    }
}
