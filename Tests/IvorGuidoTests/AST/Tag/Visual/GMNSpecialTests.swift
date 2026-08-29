// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNSpecialTests {
}

// MARK: -

extension GMNSpecialTests {
    @Test
    func aBareSpecialTagIsRejected() {
        expectRejected("[\\special]",
                       .missingRequiredParameter(makeTagName("special"), "char"))
    }

    @Test
    func aLiteralCharacterSurvivesAsWritten() throws {
        guard case let .special(special) = try normalizedTag("[\\special<\"a\">]")
        else {
            Issue.record("Expected special tag")
            return
        }

        #expect(special.character == "a")
    }

    @Test
    func aNumericSpellingSurvivesAsWritten() throws {
        // `ARSpecial::string2char` folds `"a"`, `"\\xa0"`, `"\\o130"`, and
        // `"\\88"` to one byte apiece. Storing the byte would lose which
        // spelling was written, and the four are not the same text — so the
        // payload keeps the string.
        guard case let .special(special) = try normalizedTag(#"[\special<"\\xa0">]"#)
        else {
            Issue.record("Expected special tag")
            return
        }

        #expect(special.character == #"\xa0"#)
    }

    @Test
    func canonicalName() {
        #expect(GMNSpecial(character: "a").name == makeTagName("special"))
    }

    @Test
    func equatable() {
        let a = GMNSpecial(character: "\\xa0")
        let b = GMNSpecial(character: "\\xa0")
        let c = GMNSpecial(character: "\\o130")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let special = GMNSpecial(character: "a")

        #expect(special.appearance.isEmpty)
        #expect(special.body.isEmpty)
        #expect(special.character == "a")
        #expect(special.ident == nil)
    }
}
