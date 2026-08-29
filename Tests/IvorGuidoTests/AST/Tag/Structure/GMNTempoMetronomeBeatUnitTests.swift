// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// A fraction's denominator is not zero (`Fraction::set`).
//
// An invariant a node can check *alone* is enforced at construction.
// `ARTempo::ParseBpm` calls `mBpmUnit.set(num,
// denom)`, which lands on `Fraction::set`; that asserts `denom != 0`
// (`Fraction.cpp:88`).
struct GMNTempoMetronomeBeatUnitTests {
}

// MARK: -

extension GMNTempoMetronomeBeatUnitTests {
    @Test
    func equatable() {
        let a = GMNTempo.Metronome.BeatUnit(1, 4)
        let b = GMNTempo.Metronome.BeatUnit(1, 4)
        let c = GMNTempo.Metronome.BeatUnit(1, 8)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_admitsAZeroNumerator() {
        // Only the denominator is constrained, and only against zero.
        #expect(GMNTempo.Metronome.BeatUnit(0, 4) != nil)
    }

    @Test
    func init_storesBothHalves() throws {
        let value = try #require(GMNTempo.Metronome.BeatUnit(3, 8))

        #expect(value.denominator == 8)
        #expect(value.numerator == 3)
    }

    @Test
    func init_zeroDenominator() {
        #expect(GMNTempo.Metronome.BeatUnit(1, 0) == nil)
    }

    @Test
    func init_zeroDenominatorIsRejectedByThePipeline() {
        // The consequence of the initializer, seen from the outside: a
        // payload that declines leaves the tag reserved, and the validator's
        // residual check refuses the score.
        expectRejected("[\\tempo<\"Allegro\",bpm=\"1/0=120\">]",
                       .unreadableParameterValue(makeTagName("tempo")))
    }
}
