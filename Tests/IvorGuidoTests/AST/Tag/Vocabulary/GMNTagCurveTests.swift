// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagCurveTests {
}

// MARK: -

extension GMNTagCurveTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.Curve.down == .down)
        #expect(GMNTag.Curve.down != .up)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // Exhaustive by compilation. guidolib's `kUndefined` is modelled as a
        // `nil` `Curve` and has no case of its own; `kPUndefined` is a
        // sentinel float, not a direction.
        #expect(curveString(.down) == "down")
        #expect(curveString(.up) == "up")
    }
}
