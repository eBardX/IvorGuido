// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNPitchNameTests {
}

// MARK: -

extension GMNPitchNameTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNPitch.Name.a == .a)
        #expect(GMNPitch.Name.a != .ais)
    }

    @Test
    func caseSetIsExactlyTwentyTwo() {
        // The switch in `pitchNameLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(pitchNameLabel(.a) == "a")
        #expect(pitchNameLabel(.ais) == "ais")
        #expect(pitchNameLabel(.b) == "b")
        #expect(pitchNameLabel(.c) == "c")
        #expect(pitchNameLabel(.cis) == "cis")
        #expect(pitchNameLabel(.d) == "d")
        #expect(pitchNameLabel(.dis) == "dis")
        #expect(pitchNameLabel(.do) == "do")
        #expect(pitchNameLabel(.e) == "e")
        #expect(pitchNameLabel(.empty) == "empty")
        #expect(pitchNameLabel(.f) == "f")
        #expect(pitchNameLabel(.fa) == "fa")
        #expect(pitchNameLabel(.fis) == "fis")
        #expect(pitchNameLabel(.g) == "g")
        #expect(pitchNameLabel(.gis) == "gis")
        #expect(pitchNameLabel(.h) == "h")
        #expect(pitchNameLabel(.la) == "la")
        #expect(pitchNameLabel(.mi) == "mi")
        #expect(pitchNameLabel(.re) == "re")
        #expect(pitchNameLabel(.si) == "si")
        #expect(pitchNameLabel(.sol) == "sol")
        #expect(pitchNameLabel(.ti) == "ti")
    }
}
