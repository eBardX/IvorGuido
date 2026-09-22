// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNAccidentalTests {
}

// MARK: -

extension GMNAccidentalTests {
    @Test
    func absentStyleDiffersFromWrittenOne() {
        // Non-omissible: `getStyle` reads it without `usedefault`, so absent
        // and `style="none"` are two different results.
        #expect(GMNAccidental() != GMNAccidental(style: "none"))
    }

    @Test
    func canonicalNameIsTheLongForm() {
        #expect(GMNAccidental().name == makeTagName("accidental"))
    }

    @Test
    func dropsAnUnsupportedName() throws {
        // `\accidental<mode=x>` has an unsupported name — `checkExist` fails
        // and no `getParameter` call can reach it — so the normalizer drops
        // it and the tag promotes carrying nothing.
        guard case let .accidental(accidental) = try normalizedTag("[\\accidental<mode=\"x\">(c)]")
        else {
            Issue.record("Expected accidental tag")
            return
        }

        #expect(accidental.style == nil)
    }

    @Test
    func equatable() {
        let a = GMNAccidental(style: "cautionary")
        let b = GMNAccidental(style: "cautionary")
        let c = GMNAccidental(style: "none")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let accidental = GMNAccidental()

        #expect(accidental.appearance.isEmpty)
        #expect(accidental.body.isEmpty)
        #expect(accidental.ident == nil)
        #expect(accidental.style == nil)
    }

    @Test
    func init_fromBinding() {
        let accidental = GMNAccidental(ident: makeTagIdent(3),
                                       binding: makeBinding("accidental",
                                                            [makeTagParameter(.string("cautionary")),
                                                             makeTagParameter("dx", .integer(2, .hs))]),
                                       body: [])

        #expect(accidental.appearance.dx == GMNLength(2, unit: .hs))
        #expect(accidental.ident == makeTagIdent(3))
        #expect(accidental.style == "cautionary")
    }

    @Test(arguments: ["acc", "accidental"])
    func promotesFromEitherName(_ name: String) throws {
        guard case let .accidental(accidental) = try normalizedTag("[\\\(name)<\"none\">(c)]")
        else {
            Issue.record("Expected accidental tag")
            return
        }

        #expect(accidental.body.count == 1)
        #expect(accidental.style == "none")
    }
}
