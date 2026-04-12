// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNDurationTests {
}

// MARK: -

extension GMNDurationTests {
    @Test
    func test_equatable() {
        let frac1a = GMNDuration.fraction(1, 4)
        let frac1b = GMNDuration.fraction(1, 4)
        let frac2 = GMNDuration.fraction(1, 8)
        let dots1a = GMNDuration.fractionDots(1, 4, 1)
        let dots1b = GMNDuration.fractionDots(1, 4, 1)
        let dots2 = GMNDuration.fractionDots(1, 4, 2)
        let ms1a = GMNDuration.milliseconds(500)
        let ms1b = GMNDuration.milliseconds(500)
        let ms2 = GMNDuration.milliseconds(250)

        #expect(frac1a == frac1b)
        #expect(frac1a != frac2)
        #expect(dots1a == dots1b)
        #expect(dots1a != dots2)
        #expect(ms1a == ms1b)
        #expect(ms1a != ms2)
        #expect(frac1a != ms2)
    }

    @Test
    func test_fraction() {
        let duration = GMNDuration.fraction(3, 8)

        guard case let .fraction(numer, denom) = duration.value
        else {
            Issue.record("Expected fraction")
            return
        }

        #expect(numer == 3)
        #expect(denom == 8)
    }

    @Test
    func test_fractionDots() {
        let duration = GMNDuration.fractionDots(1, 4, 2)

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
    func test_init_fraction_failure() {
        #expect(GMNDuration(numerator: 0,
                            denominator: 4) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 0) == nil)
        #expect(GMNDuration(numerator: 0,
                            denominator: 0) == nil)
    }

    @Test
    func test_init_fraction_success() throws {
        let duration = try #require(GMNDuration(numerator: 1,
                                                denominator: 4))

        #expect(duration == .fraction(1, 4))
    }

    @Test
    func test_init_fractionDots_failure() {
        #expect(GMNDuration(numerator: 0,
                            denominator: 4,
                            dots: 1) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 0,
                            dots: 1) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 4,
                            dots: 0) == nil)
        #expect(GMNDuration(numerator: 1,
                            denominator: 4,
                            dots: 4) == nil)
    }

    @Test
    func test_init_fractionDots_success() throws {
        let d1 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 1))
        let d2 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 2))
        let d3 = try #require(GMNDuration(numerator: 1,
                                          denominator: 4,
                                          dots: 3))

        #expect(d1 == .fractionDots(1, 4, 1))
        #expect(d2 == .fractionDots(1, 4, 2))
        #expect(d3 == .fractionDots(1, 4, 3))
    }

    @Test
    func test_init_milliseconds_failure() {
        #expect(GMNDuration(milliseconds: 0) == nil)
    }

    @Test
    func test_init_milliseconds_success() throws {
        let duration = try #require(GMNDuration(milliseconds: 500))

        #expect(duration == .milliseconds(500))
    }

    @Test
    func test_milliseconds() {
        let duration = GMNDuration.milliseconds(500)

        guard case let .milliseconds(ms) = duration.value
        else {
            Issue.record("Expected milliseconds")
            return
        }

        #expect(ms == 500)
    }
}
