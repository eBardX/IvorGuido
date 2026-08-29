// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagPlacementTests {
}

// MARK: -

extension GMNTagPlacementTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.Placement.above == .above)
        #expect(GMNTag.Placement.above != .below)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch below is exhaustive by compilation, so adding or
        // removing a case breaks this test rather than passing silently.
        // guidolib's third state, `kDefaultPosition`, is modelled as a `nil`
        // `Placement` and deliberately has no case of its own.
        #expect(positionString(.above) == "above")
        #expect(positionString(.below) == "below")
    }
}
