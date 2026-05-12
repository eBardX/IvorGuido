// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNDurationTests {
}

// MARK: -

extension GMNDurationTests {
    @Test
    func equatable() {
        let frac1a = fdur(1, 4)
        let frac1b = fdur(1, 4)
        let frac2 = fdur(1, 8)
        let dots1a = fdur(1, 4, 1)
        let dots1b = fdur(1, 4, 1)
        let dots2 = fdur(1, 4, 2)
        let ms1a = mdur(500)
        let ms1b = mdur(500)
        let ms2 = mdur(250)

        #expect(frac1a == frac1b)
        #expect(frac1a != frac2)
        #expect(dots1a == dots1b)
        #expect(dots1a != dots2)
        #expect(ms1a == ms1b)
        #expect(ms1a != ms2)
        #expect(frac1a != ms2)
    }

    @Test
    func fraction() {
        let duration = fdur(3, 8)

        guard case let .fractionDots(numer, denom, dots) = duration.value
        else {
            Issue.record("Expected fractionDots")
            return
        }

        #expect(numer == 3)
        #expect(denom == 8)
        #expect(dots == 0)
    }

    @Test
    func fractionDots() {
        let duration = fdur(1, 4, 2)

        guard case let .fractionDots(numer, denom, dots) = duration.value
        else {
            Issue.record("Expected fractionDots")
            return
        }

        #expect(numer == 1)
        #expect(denom == 4)
        #expect(dots == 2)
    }

    @Test
    func init_fraction_failure() {
        #expect(GMNDuration(numerator: 0,
                            denominator: 4) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 0) == nil)
        #expect(GMNDuration(numerator: 0,
                            denominator: 0) == nil)
    }

    @Test
    func init_fraction_success() throws {
        let duration = try #require(GMNDuration(numerator: 1,
                                                denominator: 4))

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 4)
        #expect(duration.dots == 0)
    }

    @Test
    func init_fractionDots_failure() {
        #expect(GMNDuration(numerator: 0,
                            denominator: 4,
                            dots: 1) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 0,
                            dots: 1) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 4,
                            dots: 4) == nil)
    }

    @Test
    func init_fractionDots_success() throws {
        let d0 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 0))
        let d1 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 1))
        let d2 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 2))
        let d3 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 3))

        #expect(d0.numerator == 1)
        #expect(d0.denominator == 4)
        #expect(d0.dots == 0)
        #expect(d1.numerator == 1)
        #expect(d1.denominator == 4)
        #expect(d1.dots == 1)
        #expect(d2.numerator == 1)
        #expect(d2.denominator == 4)
        #expect(d2.dots == 2)
        #expect(d3.numerator == 1)
        #expect(d3.denominator == 4)
        #expect(d3.dots == 3)
    }

    @Test
    func init_milliseconds_failure() {
        #expect(GMNDuration(milliseconds: 0) == nil)
    }

    @Test
    func init_milliseconds_success() throws {
        let duration = try #require(GMNDuration(milliseconds: 500))

        #expect(duration.milliseconds == 500)
    }

    @Test
    func milliseconds() {
        let duration = mdur(500)

        guard case let .milliseconds(ms) = duration.value
        else {
            Issue.record("Expected milliseconds")
            return
        }

        #expect(ms == 500)
    }
}
