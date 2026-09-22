// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNBeamStateKindTests {
}

// MARK: -

extension GMNBeamStateKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNBeamState.Kind.auto == .auto)
        #expect(GMNBeamState.Kind.auto != .full)
    }

    @Test
    func caseSetIsExactlyThree() {
        // The switch in `beamStateKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(beamStateKindLabel(.auto) == "auto")
        #expect(beamStateKindLabel(.full) == "full")
        #expect(beamStateKindLabel(.off) == "off")
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNBeamState.Kind.kind(forTagName: "beamsAuto") == .auto)
        #expect(GMNBeamState.Kind.kind(forTagName: "beamsFull") == .full)
        #expect(GMNBeamState.Kind.kind(forTagName: "beamsOff") == .off)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNBeamState.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNBeamState.Kind.auto.tagName == "beamsAuto")
        #expect(GMNBeamState.Kind.full.tagName == "beamsFull")
        #expect(GMNBeamState.Kind.off.tagName == "beamsOff")
    }
}
