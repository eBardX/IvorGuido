// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNRestFormatTests {
}

// MARK: -

extension GMNRestFormatTests {
    @Test
    func canonicalName() {
        #expect(GMNRestFormat().name == makeTagName("restFormat"))
    }

    @Test
    func equatable() {
        let a = GMNRestFormat(appearance: GMNTag.Appearance(dy: GMNLength(2, unit: .hs)))
        let b = GMNRestFormat(appearance: GMNTag.Appearance(dy: GMNLength(2, unit: .hs)))
        let c = GMNRestFormat()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let format = GMNRestFormat()

        #expect(format.appearance.isEmpty)
        #expect(format.body.isEmpty)
        #expect(format.ident == nil)
    }

    @Test
    func itHasNoPositionalSlots() throws {
        // FLIPPED IN PHASE 3 for the unnamed half. With no slots at all there
        // is no name to bind a positional parameter to, so guidolib warns and
        // `break`s (`ARMusicalTag.cpp:101–104`) — losing it. The tag used to
        // stay generic around it; the score is refused now.
        expectRejected("[\\restFormat<\"red\">]",
                       .unboundPositionalParameter(makeTagName("restFormat"),
                                                   index: 0))

        guard case let .restFormat(named) = try normalizedTag("[\\restFormat<color=\"red\">]")
        else {
            Issue.record("Expected a rest-format tag")
            return
        }

        #expect(named.appearance.color == "red")
    }

    @Test
    func itTakesABodyOrNot() throws {
        guard case let .restFormat(bare) = try normalizedTag("[\\restFormat]"),
              case let .restFormat(ranged) = try normalizedTag("[\\restFormat(_ _)]")
        else {
            Issue.record("Expected rest-format tags")
            return
        }

        #expect(bare.body.isEmpty)
        #expect(ranged.body.count == 2)
    }
}
