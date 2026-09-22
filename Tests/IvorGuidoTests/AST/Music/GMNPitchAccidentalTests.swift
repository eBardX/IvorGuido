// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNPitchAccidentalTests {
}

// MARK: -

extension GMNPitchAccidentalTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNPitch.Accidental.doubleFlat == .doubleFlat)
        #expect(GMNPitch.Accidental.doubleFlat != .flat)
    }

    @Test
    func caseSetIsExactlySix() {
        // The switch in `pitchAccidentalLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(pitchAccidentalLabel(.doubleFlat) == "doubleFlat")
        #expect(pitchAccidentalLabel(.flat) == "flat")
        #expect(pitchAccidentalLabel(.sharp) == "sharp")
        #expect(pitchAccidentalLabel(.impliedSharp) == "impliedSharp")
        #expect(pitchAccidentalLabel(.doubleSharp) == "doubleSharp")
        #expect(pitchAccidentalLabel(.omitted) == "omitted")
    }
}
