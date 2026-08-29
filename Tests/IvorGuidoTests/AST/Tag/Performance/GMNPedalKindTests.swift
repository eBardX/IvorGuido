// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNPedalKindTests {
}

// MARK: -

extension GMNPedalKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNPedal.Kind.off == .off)
        #expect(GMNPedal.Kind.off != .on)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `pedalKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(pedalKindLabel(.off) == "off")
        #expect(pedalKindLabel(.on) == "on")
    }

    @Test
    func tagName() {
        #expect(GMNPedal.Kind.off.tagName == "pedalOff")
        #expect(GMNPedal.Kind.on.tagName == "pedalOn")
    }
}
