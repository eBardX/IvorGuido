// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTempoMetronomeTests {
}

// MARK: -

extension GMNTempoMetronomeTests {
    @Test
    func beatUnit_doesNotNormalizeTheFraction() {
        let value = GMNTempo.Metronome.BeatUnit(2, 8).require()

        #expect(value.denominator == 8)
        #expect(value.numerator == 2)
        #expect(value.stringValue == "2/8")
    }

    @Test
    func equatable() {
        let a = GMNTempo.Metronome("1/4=120")
        let b = GMNTempo.Metronome("1/4=120")
        let c = GMNTempo.Metronome("1/4=60")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_readsANoteEquivalence() {
        #expect(GMNTempo.Metronome("1/4=3/8") == .equivalence(unit: GMNTempo.Metronome.BeatUnit(1, 4).require(),
                                                              equivalent: GMNTempo.Metronome.BeatUnit(3, 8).require()))
    }

    @Test
    func init_readsARate() {
        #expect(GMNTempo.Metronome("1/2=90") == .rate(unit: GMNTempo.Metronome.BeatUnit(1, 2).require(),
                                                      beats: 90))
    }

    @Test(arguments: ["", "120", "1/4", "1/4=", "=120", "x/4=120", "1/4=120=60", "1/4=120 or so"])
    func init_refusesAnythingElse(_ specification: String) {
        // Stricter than `sscanf`, deliberately: reading a prefix would
        // silently discard the rest. See ``GMNTempo/Metronome``.
        #expect(GMNTempo.Metronome(specification) == nil)
    }

    @Test(arguments: ["1/4=120", "3/8=1/4"])
    func stringValueRoundTrips(_ specification: String) throws {
        let parsed = try #require(GMNTempo.Metronome(specification))

        #expect(parsed.stringValue == specification)
    }
}
