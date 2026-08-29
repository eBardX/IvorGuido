// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNDurationBaseTests {
}

// MARK: -

extension GMNDurationBaseTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNDuration.Base.fraction(1, 4) == .fraction(1, 4))
        #expect(GMNDuration.Base.fraction(1, 4) != .fraction(1, 8))
        #expect(GMNDuration.Base.fraction(1, 4) != .milliseconds(250))
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `durationBaseLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently. The two are not interchangeable: a fraction is a metric
        // duration and milliseconds are wall-clock.
        #expect(durationBaseLabel(.fraction(1, 4)) == "fraction")
        #expect(durationBaseLabel(.milliseconds(750)) == "milliseconds")
    }

    @Test
    func fraction_carriesBothHalves() {
        guard case let .fraction(numerator, denominator) = GMNDuration.Base.fraction(3, 8)
        else {
            Issue.record("Expected a fraction base")

            return
        }

        #expect(denominator == 8)
        #expect(numerator == 3)
    }

    @Test
    func milliseconds_carriesItsValue() {
        guard case let .milliseconds(value) = GMNDuration.Base.milliseconds(750)
        else {
            Issue.record("Expected a milliseconds base")

            return
        }

        #expect(value == 750)
    }
}
