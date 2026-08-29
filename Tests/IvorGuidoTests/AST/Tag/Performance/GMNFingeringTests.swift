// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNFingeringTests {
}

// MARK: -

extension GMNFingeringTests {
    @Test
    func canonicalNameIsFingering() {
        #expect(GMNFingering(text: "1").name == makeTagName("fingering"))
    }

    @Test
    func dyIsOneOfTheInheritedSlots() throws {
        // `kARTextParams` redeclares `dy` as slot 1, so an unnamed length
        // there binds it — and it still lives in `appearance`.
        guard case let .fingering(fingering) = try normalizedTag("[\\fingering<\"1\",-2hs>(c)]")
        else {
            Issue.record("Expected fingering tag")
            return
        }

        #expect(fingering.appearance.dy == GMNLength(-2, unit: .hs))
    }

    @Test
    func equatable() {
        let a = GMNFingering(text: "1")
        let b = GMNFingering(text: "1")
        let c = GMNFingering(text: "2")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let fingering = GMNFingering(text: "1")

        #expect(fingering.appearance.isEmpty)
        #expect(fingering.body.isEmpty)
        #expect(fingering.ident == nil)
        #expect(fingering.position == nil)
        #expect(fingering.text == "1")
        #expect(fingering.textStyle.isEmpty)
    }

    @Test
    func isRejectedWhenThePositionIsOutsideTheVocabulary() {
        expectRejected("[\\fingering<\"1\",position=\"sideways\">(c)]",
                       .unreadableParameterValue(makeTagName("fingering")))
    }

    @Test
    func isRejectedWithoutTheRequiredText() {
        expectRejected("[\\fingering(c)]",
                       .missingRequiredParameter(makeTagName("fingering"), "text"))
    }

    @Test
    func positionIsSupportedButHasNoSlot() throws {
        // `ARFingering` never overrides `getParamsStr()`, so unnamed
        // parameters bind against `kARTextParams` while `position` comes only
        // from `kARFingeringParams`. The second unnamed parameter here binds
        // `dy`, not `position` — which is exactly the trap the
        // positional-prefix rule exists to prevent.
        guard case let .fingering(fingering) = try normalizedTag("[\\fingering<\"1\",\"below\">(c)]")
        else {
            Issue.record("Expected fingering tag")
            return
        }

        #expect(fingering.appearance.dy == nil)
        #expect(fingering.position == nil)

        // Written named, it lands where it belongs.
        guard case let .fingering(named) = try normalizedTag("[\\fingering<\"1\",position=\"below\">(c)]")
        else {
            Issue.record("Expected fingering tag")
            return
        }

        #expect(named.position == .below)
    }

    @Test
    func theTextIsNotSplitOnCommas() throws {
        // `ARFingering::scanText` splits it for rendering; re-joining it
        // would be a rewrite this AST has no authority to make.
        guard case let .fingering(fingering) = try normalizedTag("[\\fingering<\"1,3\">(c)]")
        else {
            Issue.record("Expected fingering tag")
            return
        }

        #expect(fingering.text == "1,3")
    }
}
