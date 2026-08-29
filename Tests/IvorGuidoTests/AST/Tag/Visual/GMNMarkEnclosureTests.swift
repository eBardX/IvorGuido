// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNMarkEnclosureTests {
}

// MARK: -

extension GMNMarkEnclosureTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNMark.Enclosure.bracket == .bracket)
        #expect(GMNMark.Enclosure.bracket != .circle)
    }

    @Test
    func caseSetIsExactlyEight() {
        // The switch in `markEnclosureLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(markEnclosureLabel(.bracket) == "bracket")
        #expect(markEnclosureLabel(.circle) == "circle")
        #expect(markEnclosureLabel(.diamond) == "diamond")
        #expect(markEnclosureLabel(.none) == "none")
        #expect(markEnclosureLabel(.oval) == "oval")
        #expect(markEnclosureLabel(.rectangle) == "rectangle")
        #expect(markEnclosureLabel(.square) == "square")
        #expect(markEnclosureLabel(.triangle) == "triangle")
    }

    @Test
    func guidoValue() {
        // `.none` is a written enclosure guidolib spells "none", not the
        // absence of one — an absent enclosure is a `nil` `Enclosure`.
        let none: GMNMark.Enclosure = .none

        #expect(GMNMark.Enclosure.bracket.guidoValue == "bracket")
        #expect(GMNMark.Enclosure.circle.guidoValue == "circle")
        #expect(GMNMark.Enclosure.diamond.guidoValue == "diamond")
        #expect(none.guidoValue == "none")
        #expect(GMNMark.Enclosure.oval.guidoValue == "oval")
        #expect(GMNMark.Enclosure.rectangle.guidoValue == "rectangle")
        #expect(GMNMark.Enclosure.square.guidoValue == "square")
        #expect(GMNMark.Enclosure.triangle.guidoValue == "triangle")
    }

    @Test
    func init_guidoValueRoundTrips() {
        #expect(GMNMark.Enclosure(guidoValue: "bracket") == .bracket)
        #expect(GMNMark.Enclosure(guidoValue: "circle") == .circle)
        #expect(GMNMark.Enclosure(guidoValue: "diamond") == .diamond)
        #expect(GMNMark.Enclosure(guidoValue: "none") == GMNMark.Enclosure.none)
        #expect(GMNMark.Enclosure(guidoValue: "oval") == .oval)
        #expect(GMNMark.Enclosure(guidoValue: "rectangle") == .rectangle)
        #expect(GMNMark.Enclosure(guidoValue: "square") == .square)
        #expect(GMNMark.Enclosure(guidoValue: "triangle") == .triangle)
    }

    @Test
    func init_unknownGuidoValue() {
        #expect(GMNMark.Enclosure(guidoValue: "bembel") == nil)
    }
}
