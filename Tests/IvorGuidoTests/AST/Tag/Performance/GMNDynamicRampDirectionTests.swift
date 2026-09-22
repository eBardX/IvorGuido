// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNDynamicRampDirectionTests {
}

// MARK: -

extension GMNDynamicRampDirectionTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNDynamicRamp.Direction.crescendo == .crescendo)
        #expect(GMNDynamicRamp.Direction.crescendo != .diminuendo)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `dynamicRampDirectionLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(dynamicRampDirectionLabel(.crescendo) == "crescendo")
        #expect(dynamicRampDirectionLabel(.diminuendo) == "diminuendo")
    }

    @Test
    func direction_aliasTagName() {
        // guidolib spells each direction several ways, and the span-bearing
        // spellings are directions too — the span is carried separately.
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "cresc") == .crescendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "crescBegin") == .crescendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "crescEnd") == .crescendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "crescendo") == .crescendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "decresc") == .diminuendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "dim") == .diminuendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "diminuendo") == .diminuendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "diminuendoBegin") == .diminuendo)
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "diminuendoEnd") == .diminuendo)
    }

    @Test
    func direction_unknownTagName() {
        #expect(GMNDynamicRamp.Direction.direction(forTagName: "bembel") == nil)
    }

    @Test
    func tagName_spellsTheSpanIntoTheName() {
        // The span is not a parameter: a half is a differently named tag, so
        // the name has to carry it.
        #expect(GMNDynamicRamp.Direction.crescendo.tagName(for: .begin) == "crescBegin")
        #expect(GMNDynamicRamp.Direction.crescendo.tagName(for: .end) == "crescEnd")
        #expect(GMNDynamicRamp.Direction.crescendo.tagName(for: .whole) == "crescendo")
        #expect(GMNDynamicRamp.Direction.diminuendo.tagName(for: .begin) == "diminuendoBegin")
        #expect(GMNDynamicRamp.Direction.diminuendo.tagName(for: .end) == "diminuendoEnd")
        #expect(GMNDynamicRamp.Direction.diminuendo.tagName(for: .whole) == "diminuendo")
    }
}
