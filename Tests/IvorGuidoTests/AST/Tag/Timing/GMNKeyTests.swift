// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNKeyTests {
}

// MARK: -

extension GMNKeyTests {
    @Test
    func absentOptionDiffersFromWrittenDefault() {
        // Both options are proven non-omissible: their presence alone sets a
        // flag in `ARKey::setTagParameters`.
        #expect(GMNKey(key: .name("D")) != GMNKey(key: .name("D"), hideNaturals: "false"))
    }

    @Test
    func canonicalNameIsKey() {
        #expect(GMNKey(key: .name("C")).name == makeTagName("key"))
    }

    @Test
    func equatable() {
        let a = GMNKey(key: .name("D"))
        let b = GMNKey(key: .name("D"))
        let c = GMNKey(key: .name("G"))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let key = GMNKey(key: .name("E&"))

        #expect(key.appearance.isEmpty)
        #expect(key.body.isEmpty)
        #expect(key.free == nil)
        #expect(key.hideNaturals == nil)
        #expect(key.ident == nil)
        #expect(key.key == .name("E&"))
    }

    @Test
    func init_fromBindingRequiresKey() {
        #expect(GMNKey(ident: nil,
                       binding: makeBinding("key"),
                       body: []) == nil)
    }

    @Test
    func promotes() throws {
        guard case let .key(key) = try normalizedTag("[\\key<\"D\",hideNaturals=\"on\"> c]")
        else {
            Issue.record("Expected key tag")
            return
        }

        #expect(key.hideNaturals == "on")
        #expect(key.key == .name("D"))
    }

    @Test
    func promotesWhenTheKeyIsWrittenAsANumber() throws {
        // FLIPPED IN PHASE 2. The template declares the slot `S`, so a bare
        // number looks inert against it, and this tag used to stay generic
        // with nothing reported. `ARKey::setTagParameters` reads `key` a
        // second time as a `TagParameterInt` when the string read comes back
        // null (`ARKey.cpp:88–96`), so the number really does set a key.
        guard case let .key(key) = try normalizedTag("[\\key<2> c]")
        else {
            Issue.record("Expected key tag")
            return
        }

        #expect(key.key == .number(2))
    }

    @Test
    func theTwoSpellingsAreNotInterchangeable() {
        // A number is never re-spelled as a string on the way in, so a
        // `\key<2>` and a `\key<"2">` remain distinguishable and each formats
        // back as it was written.
        #expect(GMNKey(key: .number(2)) != GMNKey(key: .name("2")))
    }
}
