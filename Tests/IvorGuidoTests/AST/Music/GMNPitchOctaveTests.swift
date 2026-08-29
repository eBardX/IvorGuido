// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNPitchOctaveTests {
}

// MARK: -

extension GMNPitchOctaveTests {
    @Test
    func comparable_ordersByValue() {
        let low: GMNPitch.Octave = -3
        let high: GMNPitch.Octave = 5

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func equatable() {
        let a = GMNPitch.Octave(intValue: 1)
        let b = GMNPitch.Octave(intValue: 1)
        let c = GMNPitch.Octave(intValue: 2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_nilForValueAboveRange() {
        #expect(GMNPitch.Octave(intValue: 6) == nil)
    }

    @Test
    func init_nilForValueBelowRange() {
        #expect(GMNPitch.Octave(intValue: -4) == nil)
    }

    @Test
    func init_storesValue() {
        let octave = GMNPitch.Octave(intValue: 3)

        #expect(octave?.intValue == 3)
    }

    @Test
    func integerLiteral() {
        let octave: GMNPitch.Octave = -2

        #expect(octave.intValue == -2)
    }

    @Test
    func isValid_boundsAreValid() {
        #expect(GMNPitch.Octave.isValid(-3))
        #expect(GMNPitch.Octave.isValid(5))
    }

    @Test
    func isValid_valueAboveRangeIsInvalid() {
        #expect(!GMNPitch.Octave.isValid(6))
    }

    @Test
    func isValid_valueBelowRangeIsInvalid() {
        #expect(!GMNPitch.Octave.isValid(-4))
    }
}
