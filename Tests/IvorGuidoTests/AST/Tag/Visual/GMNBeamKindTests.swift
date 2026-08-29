// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNBeamKindTests {
}

// MARK: -

extension GMNBeamKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNBeam.Kind.normal == .normal)
        #expect(GMNBeam.Kind.normal != .feathered)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `beamKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(beamKindLabel(.feathered) == "feathered")
        #expect(beamKindLabel(.normal) == "normal")
    }

    @Test
    func kind_aliasTagName() {
        // guidolib spells the normal beam five ways; every one of them is
        // the same kind, and the span is carried separately.
        #expect(GMNBeam.Kind.kind(forTagName: "b") == .normal)
        #expect(GMNBeam.Kind.kind(forTagName: "beamBegin") == .normal)
        #expect(GMNBeam.Kind.kind(forTagName: "beamEnd") == .normal)
        #expect(GMNBeam.Kind.kind(forTagName: "bm") == .normal)
        #expect(GMNBeam.Kind.kind(forTagName: "fBeamBegin") == .feathered)
        #expect(GMNBeam.Kind.kind(forTagName: "fBeamEnd") == .feathered)
    }

    @Test
    func kind_canonicalTagName() {
        #expect(GMNBeam.Kind.kind(forTagName: "beam") == .normal)
        #expect(GMNBeam.Kind.kind(forTagName: "fBeam") == .feathered)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNBeam.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName_spellsTheSpanIntoTheName() {
        // The span is not a parameter: a half-beam is a differently named
        // tag, so the name has to carry it.
        #expect(GMNBeam.Kind.normal.tagName(for: .begin) == "beamBegin")
        #expect(GMNBeam.Kind.normal.tagName(for: .end) == "beamEnd")
        #expect(GMNBeam.Kind.normal.tagName(for: .whole) == "beam")
        #expect(GMNBeam.Kind.feathered.tagName(for: .begin) == "fBeamBegin")
        #expect(GMNBeam.Kind.feathered.tagName(for: .end) == "fBeamEnd")
        #expect(GMNBeam.Kind.feathered.tagName(for: .whole) == "fBeam")
    }
}
