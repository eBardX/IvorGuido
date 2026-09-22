// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNDotFormatTests {
}

// MARK: -

extension GMNDotFormatTests {
    @Test
    func aBareTagPromotes() throws {
        guard case let .dotFormat(format) = try normalizedTag("[\\dotFormat]")
        else {
            Issue.record("Expected dot-format tag")
            return
        }

        #expect(format.appearance.isEmpty)
    }

    @Test
    func canonicalName() {
        #expect(GMNDotFormat().name == makeTagName("dotFormat"))
    }

    @Test
    func equatable() {
        let a = GMNDotFormat(appearance: GMNTag.Appearance(color: "red"))
        let b = GMNDotFormat(appearance: GMNTag.Appearance(color: "red"))
        let c = GMNDotFormat()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let format = GMNDotFormat()

        #expect(format.appearance.isEmpty)
        #expect(format.body.isEmpty)
        #expect(format.ident == nil)
    }

    @Test
    func itHasNoPositionalSlots() throws {
        // `ARDotFormat` overrides `getParamsStr()` to `""`, so an unnamed
        // parameter has nowhere to bind — unlike `\headsLeft`, whose slots
        // are the inherited `kCommonParams`.
        //
        // FLIPPED IN PHASE 3 for the unnamed half: the tag used to stay
        // generic around the parameter, and the score is refused now.
        expectRejected("[\\dotFormat<\"red\">]",
                       .unboundPositionalParameter(makeTagName("dotFormat"),
                                                   index: 0))

        guard case let .dotFormat(named) = try normalizedTag("[\\dotFormat<color=\"red\",dy=1hs>]")
        else {
            Issue.record("Expected a dot-format tag")
            return
        }

        #expect(named.appearance.color == "red")
        #expect(named.appearance.dy == GMNLength(1, unit: .hs))
    }

    @Test
    func itTakesABodyOrNot() throws {
        // Range setting `RANGEDC`.
        guard case let .dotFormat(ranged) = try normalizedTag("[\\dotFormat<color=\"red\">(c d)]")
        else {
            Issue.record("Expected dot-format tag")
            return
        }

        #expect(ranged.body.count == 2)
    }
}
