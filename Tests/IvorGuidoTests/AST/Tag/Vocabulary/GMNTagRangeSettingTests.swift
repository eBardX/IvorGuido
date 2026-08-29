// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagRangeSettingTests {
}

// MARK: -

extension GMNTagRangeSettingTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.RangeSetting.no == .no)
        #expect(GMNTag.RangeSetting.no != .only)
        #expect(GMNTag.RangeSetting.no != .either)
        #expect(GMNTag.RangeSetting.only != .either)
    }

    @Test
    func caseSetIsExactlyThree() {
        // Exhaustive by compilation, matching guidolib's
        // `RANGE { NO, ONLY, RANGEDC }` one for one.
        #expect(rangeName(.either) == "RANGEDC")
        #expect(rangeName(.no) == "NO")
        #expect(rangeName(.only) == "ONLY")
    }
}
