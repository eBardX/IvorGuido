// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNDurationDotCountTests {
}

// MARK: -

extension GMNDurationDotCountTests {
    @Test
    func comparable_ordersByValue() {
        let low: GMNDuration.DotCount = 1
        let high: GMNDuration.DotCount = 3

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func equatable() {
        let a = GMNDuration.DotCount(uintValue: 2)
        let b = GMNDuration.DotCount(uintValue: 2)
        let c = GMNDuration.DotCount(uintValue: 1)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_nilForValueAboveThree() {
        #expect(GMNDuration.DotCount(uintValue: 4) == nil)
    }

    @Test
    func init_nilForZero() {
        #expect(GMNDuration.DotCount(uintValue: 0) == nil)
    }

    @Test
    func init_storesValue() {
        let dotCount = GMNDuration.DotCount(uintValue: 2)

        #expect(dotCount?.uintValue == 2)
    }

    @Test
    func integerLiteral() {
        let dotCount: GMNDuration.DotCount = 3

        #expect(dotCount.uintValue == 3)
    }

    @Test
    func isValid_boundsAreValid() {
        #expect(GMNDuration.DotCount.isValid(1))
        #expect(GMNDuration.DotCount.isValid(3))
    }

    @Test
    func isValid_valueAboveRangeIsInvalid() {
        #expect(!GMNDuration.DotCount.isValid(4))
    }

    @Test
    func isValid_zeroIsInvalid() {
        #expect(!GMNDuration.DotCount.isValid(0))
    }
}
