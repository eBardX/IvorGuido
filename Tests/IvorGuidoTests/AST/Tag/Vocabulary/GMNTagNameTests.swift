// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagNameTests {
}

// MARK: -

extension GMNTagNameTests {
    @Test
    func equatable() {
        let a = GMNTag.Name(stringValue: "slur")
        let b = GMNTag.Name(stringValue: "slur")
        let c = GMNTag.Name(stringValue: "tie")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_nilForBackslashPrefixedString() {
        // The leading `\` is stripped by the parser before construction —
        // `Name` itself never stores it.
        #expect(GMNTag.Name(stringValue: "\\bar") == nil)
    }

    @Test
    func init_nilForEmptyString() {
        #expect(GMNTag.Name(stringValue: "") == nil)
    }

    @Test
    func init_nilForStringStartingWithDigit() {
        #expect(GMNTag.Name(stringValue: "1bar") == nil)
    }

    @Test
    func init_storesStringValue() {
        let name = GMNTag.Name(stringValue: "slur")

        #expect(name?.stringValue == "slur")
    }

    @Test
    func init_validForBarShorthand() {
        #expect(GMNTag.Name(stringValue: "|") != nil)
    }

    @Test
    func init_validForUnderscorePrefixedIdentifier() {
        #expect(GMNTag.Name(stringValue: "_hidden") != nil)
    }

    @Test
    func isValid_backslashPrefixedStringIsInvalid() {
        #expect(!GMNTag.Name.isValid("\\bar"))
    }

    @Test
    func isValid_bar() {
        #expect(GMNTag.Name.isValid("|"))
    }

    @Test
    func isValid_emptyStringIsInvalid() {
        #expect(!GMNTag.Name.isValid(""))
    }

    @Test
    func isValid_guidolibIdentifier() {
        #expect(GMNTag.Name.isValid("bar"))
        #expect(GMNTag.Name.isValid("slurBegin"))
        #expect(GMNTag.Name.isValid("_hidden"))
        #expect(GMNTag.Name.isValid("tempo2"))
    }

    @Test
    func isValid_stringStartingWithDigitIsInvalid() {
        #expect(!GMNTag.Name.isValid("1bar"))
    }

    @Test
    func isValid_stringWithNonASCIICharacterIsInvalid() {
        #expect(!GMNTag.Name.isValid("bàr"))
    }
}
