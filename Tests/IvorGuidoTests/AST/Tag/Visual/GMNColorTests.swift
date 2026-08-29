// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNColorTests {
}

// MARK: -

extension GMNColorTests {
    @Test
    func aBareColourTagIsRejected() {
        // `color` is the one required parameter, so `checkRequired` fails and
        // nothing promotes.
        expectRejected("[\\color]",
                       .missingRequiredParameter(makeTagName("color"), "color"))
    }

    @Test(arguments: ["color", "colour"])
    func bothSpellingsPromote(_ name: String) throws {
        guard case let .color(color) = try normalizedTag("[\\\(name)<\"0xff0000\">]")
        else {
            Issue.record("Expected colour tag")
            return
        }

        #expect(color.color == "0xff0000")
    }

    @Test
    func canonicalNameIsTheLongForm() {
        // `\colour` is the alias; `\color` is what `Tags.cpp` declares first
        // and what `ARColor::getGMNName` answers.
        #expect(GMNColor(color: "red").name == makeTagName("color"))
    }

    @Test
    func equatable() {
        let a = GMNColor(color: "red")
        let b = GMNColor(color: "red")
        let c = GMNColor(color: "blue")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let color = GMNColor(color: "red")

        #expect(color.appearance.isEmpty)
        #expect(color.body.isEmpty)
        #expect(color.color == "red")
        #expect(color.ident == nil)
    }

    @Test
    func theColourIsNotAlsoInTheAppearance() throws {
        // `color` is one parameter, and this payload keeps it in `color`.
        // Holding it in both places would make the same value answer to two
        // fields that could then disagree.
        guard case let .color(color) = try normalizedTag("[\\color<\"red\",dx=2hs>]")
        else {
            Issue.record("Expected colour tag")
            return
        }

        #expect(color.color == "red")
        #expect(color.appearance.color == nil)
        #expect(color.appearance.dx == GMNLength(2, unit: .hs))
    }
}
