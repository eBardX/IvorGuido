// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNDurationTests {
}

// MARK: -

extension GMNDurationTests {
    @Test
    func equatable() {
        let frac1a = makeDuration(1, 4)
        let frac1b = makeDuration(1, 4)
        let frac2 = makeDuration(1, 8)
        let dots1a = makeDuration(1, 4, dots: 1)
        let dots1b = makeDuration(1, 4, dots: 1)
        let dots2 = makeDuration(1, 4, dots: 2)
        let ms1a = makeDuration(500)
        let ms1b = makeDuration(500)
        let ms2 = makeDuration(250)

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
        let duration = makeDuration(3, 8)

        guard case let .fraction(numer, denom)? = duration.base
        else {
            Issue.record("Expected fraction")
            return
        }

        #expect(numer == 3)
        #expect(denom == 8)
        #expect(duration.dots == nil)
    }

    @Test
    func fractionDots() {
        let duration = makeDuration(1, 4, dots: 2)

        guard case let .fraction(numer, denom)? = duration.base
        else {
            Issue.record("Expected fraction")
            return
        }

        #expect(numer == 1)
        #expect(denom == 4)
        #expect(duration.dots == 2)
    }

    @Test
    func init_dots_success() {
        let d1 = GMNDuration(dots: 1)
        let d3 = GMNDuration(dots: 3)

        #expect(d1.base == nil)
        #expect(d1.dots == 1)
        #expect(d1.numerator == nil)
        #expect(d1.denominator == nil)
        #expect(d1.milliseconds == nil)
        #expect(d3.base == nil)
        #expect(d3.dots == 3)
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
        #expect(duration.dots == nil)
    }

    @Test
    func init_fractionDots_failure() {
        // The invalid-dot-count case belongs to `DotCount` itself (see
        // `GMNDurationDotCountTests`) — an invalid dot count can no longer
        // reach `GMNDuration`'s initializer at all.
        #expect(GMNDuration(numerator: 0,
                            denominator: 4,
                            dots: 1) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 0,
                            dots: 1) == nil)
    }

    @Test
    func init_fractionDots_success() throws {
        let noDots = try #require(GMNDuration(numerator: 1,
                                              denominator: 4))
        let d1 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 1))
        let d2 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 2))
        let d3 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 3))

        #expect(noDots.numerator == 1)
        #expect(noDots.denominator == 4)
        #expect(noDots.dots == nil)
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
        #expect(duration.dots == nil)
    }

    @Test
    func init_millisecondsDots_success() throws {
        let duration = try #require(GMNDuration(milliseconds: 500,
                                                dots: 2))

        #expect(duration.milliseconds == 500)
        #expect(duration.dots == 2)
    }

    @Test
    func milliseconds() {
        let duration = makeDuration(500)

        guard case let .milliseconds(ms)? = duration.base
        else {
            Issue.record("Expected milliseconds")
            return
        }

        #expect(ms == 500)
    }
}
