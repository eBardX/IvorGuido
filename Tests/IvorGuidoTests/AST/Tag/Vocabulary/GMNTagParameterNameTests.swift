// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagParameterNameTests {
}

// MARK: -

extension GMNTagParameterNameTests {
    @Test
    func equatable() {
        let a = GMNTag.Parameter.Name(stringValue: "dx")
        let b = GMNTag.Parameter.Name(stringValue: "dx")
        let c = GMNTag.Parameter.Name(stringValue: "dy")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_nilForInvalidName() {
        #expect(GMNTag.Parameter.Name(stringValue: "") == nil)
        #expect(GMNTag.Parameter.Name(stringValue: "1dx") == nil)
    }

    @Test
    func init_storesValue() {
        #expect(GMNTag.Parameter.Name(stringValue: "fsize")?.stringValue == "fsize")
    }

    @Test
    func isValid_digitsAndUnderscoresAfterTheFirst() {
        // The eight unit spellings are all legal parameter names too, which
        // is why the tokenizer decides between them on the following
        // character rather than on the spelling.
        #expect(GMNTag.Parameter.Name.isValid("dx1"))
        #expect(GMNTag.Parameter.Name.isValid("d_x"))
        #expect(GMNTag.Parameter.Name.isValid("_dx"))
        #expect(GMNTag.Parameter.Name.isValid("hs"))
    }

    @Test
    func isValid_emptyIsInvalid() {
        #expect(!GMNTag.Parameter.Name.isValid(""))
    }

    @Test
    func isValid_leadingDigitIsInvalid() {
        #expect(!GMNTag.Parameter.Name.isValid("1dx"))
    }

    @Test
    func isValid_nonASCIIIsInvalid() {
        // `isLetter` alone would admit these, so the ASCII guard is what
        // actually decides them.
        #expect(!GMNTag.Parameter.Name.isValid("é"))
        #expect(!GMNTag.Parameter.Name.isValid("dé"))
    }

    @Test
    func isValid_punctuationIsInvalid() {
        #expect(!GMNTag.Parameter.Name.isValid("d-x"))
        #expect(!GMNTag.Parameter.Name.isValid("d x"))
    }

    @Test
    func isValid_simpleName() {
        #expect(GMNTag.Parameter.Name.isValid("dx"))
        #expect(GMNTag.Parameter.Name.isValid("color"))
    }
}
