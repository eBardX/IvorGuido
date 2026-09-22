// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNHarmonyTests {
}

// MARK: -

extension GMNHarmonyTests {
    @Test
    func canonicalNameIsHarmony() {
        #expect(GMNHarmony(text: "Cmaj7").name == makeTagName("harmony"))
    }

    @Test
    func carriesItsOwnDyInTheAppearance() throws {
        // `kARHarmonyParams` redeclares `dy` as its second positional slot, so
        // the value binds by position but still lives with the other
        // `kCommonParams` parameters.
        guard case let .harmony(harmony) = try normalizedTag("[\\harmony<\"Cmaj7\",-2hs>]")
        else {
            Issue.record("Expected harmony tag")
            return
        }

        #expect(harmony.appearance.dy == GMNLength(-2, unit: .hs))
    }

    @Test
    func dropsAPositionItNeverDeclared() throws {
        // `ARHarmony::setTagParameters` reads a `position` (`ARHarmony.cpp:36`)
        // that `sARHarmonyMap` never declares (`TagParametersMaps.h:112`), so
        // `checkExist` rejects it and the read is unreachable. The payload
        // therefore carries no `Placement`, and the normalizer drops the
        // parameter rather than keeping a value nothing can read.
        guard case let .harmony(harmony) = try normalizedTag("[\\harmony<\"Cmaj7\",position=\"below\">]")
        else {
            Issue.record("Expected harmony tag")
            return
        }

        #expect(harmony.text == "Cmaj7")
    }

    @Test
    func equatable() {
        let a = GMNHarmony(text: "Cmaj7")
        let b = GMNHarmony(text: "Cmaj7")
        let c = GMNHarmony(text: "Dm")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsOptionalsToEmpty() {
        let harmony = GMNHarmony(text: "G7")

        #expect(harmony.appearance.isEmpty)
        #expect(harmony.body.isEmpty)
        #expect(harmony.ident == nil)
        #expect(harmony.text == "G7")
        #expect(harmony.textStyle.isEmpty)
    }

    @Test
    func isRejectedWithoutTheRequiredText() {
        expectRejected("[\\harmony]",
                       .missingRequiredParameter(makeTagName("harmony"), "text"))
    }

    @Test
    func promotes() throws {
        guard case let .harmony(harmony) = try normalizedTag("[\\harmony<\"Cmaj7\">]")
        else {
            Issue.record("Expected harmony tag")
            return
        }

        #expect(harmony.text == "Cmaj7")
    }
}
