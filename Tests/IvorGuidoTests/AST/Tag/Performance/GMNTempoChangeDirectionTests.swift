// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTempoChangeDirectionTests {
}

// MARK: -

extension GMNTempoChangeDirectionTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTempoChange.Direction.accelerando == .accelerando)
        #expect(GMNTempoChange.Direction.accelerando != .ritardando)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `tempoChangeDirectionLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(tempoChangeDirectionLabel(.accelerando) == "accelerando")
        #expect(tempoChangeDirectionLabel(.ritardando) == "ritardando")
    }

    @Test
    func direction_aliasTagName() {
        // guidolib spells each direction several ways, and the span-bearing
        // spellings are directions too — the span is carried separately.
        #expect(GMNTempoChange.Direction.direction(forTagName: "accel") == .accelerando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "accelBegin") == .accelerando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "accelEnd") == .accelerando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "accelerando") == .accelerando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "rit") == .ritardando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "ritBegin") == .ritardando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "ritEnd") == .ritardando)
        #expect(GMNTempoChange.Direction.direction(forTagName: "ritardando") == .ritardando)
    }

    @Test
    func direction_unknownTagName() {
        #expect(GMNTempoChange.Direction.direction(forTagName: "bembel") == nil)
    }

    @Test
    func tagName_spellsTheSpanIntoTheName() {
        // The span is not a parameter: a half is a differently named tag, so
        // the name has to carry it.
        #expect(GMNTempoChange.Direction.accelerando.tagName(for: .begin) == "accelBegin")
        #expect(GMNTempoChange.Direction.accelerando.tagName(for: .end) == "accelEnd")
        #expect(GMNTempoChange.Direction.accelerando.tagName(for: .whole) == "accelerando")
        #expect(GMNTempoChange.Direction.ritardando.tagName(for: .begin) == "ritBegin")
        #expect(GMNTempoChange.Direction.ritardando.tagName(for: .end) == "ritEnd")
        #expect(GMNTempoChange.Direction.ritardando.tagName(for: .whole) == "ritardando")
    }
}
