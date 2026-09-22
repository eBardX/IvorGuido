// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagControlPointsTests {
}

// MARK: -

extension GMNTagControlPointsTests {
    @Test
    func absentDiffersFromZero() {
        // `ARBowing` records authorship outright in `fParSet`, so an
        // explicit `dx1=0` is a different score from no `dx1` at all.
        #expect(GMNTag.ControlPoints() != GMNTag.ControlPoints(dx1: GMNLength(0)))
    }

    @Test
    func equatable() {
        let a = GMNTag.ControlPoints(dx1: GMNLength(2, unit: .hs),
                                     dy1: GMNLength(1, unit: .hs))
        let b = GMNTag.ControlPoints(dx1: GMNLength(2, unit: .hs),
                                     dy1: GMNLength(1, unit: .hs))
        let c = GMNTag.ControlPoints(dx1: GMNLength(2, unit: .hs),
                                     dy2: GMNLength(1, unit: .hs))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let points = GMNTag.ControlPoints()

        #expect(points.dx1 == nil)
        #expect(points.dx2 == nil)
        #expect(points.dy1 == nil)
        #expect(points.dy2 == nil)
    }

    @Test
    func init_storesAllOffsets() {
        let points = GMNTag.ControlPoints(dx1: GMNLength(2, unit: .hs),
                                          dy1: GMNLength(1, unit: .hs),
                                          dx2: GMNLength(-2, unit: .hs),
                                          dy2: GMNLength(1, unit: .hs))

        #expect(points.dx1 == GMNLength(2, unit: .hs))
        #expect(points.dy1 == GMNLength(1, unit: .hs))
        #expect(points.dx2 == GMNLength(-2, unit: .hs))
        #expect(points.dy2 == GMNLength(1, unit: .hs))
    }

    @Test
    func isEmpty() {
        #expect(GMNTag.ControlPoints().isEmpty)

        #expect(!GMNTag.ControlPoints(dx1: GMNLength(0)).isEmpty)
        #expect(!GMNTag.ControlPoints(dy1: GMNLength(0)).isEmpty)
        #expect(!GMNTag.ControlPoints(dx2: GMNLength(0)).isEmpty)
        #expect(!GMNTag.ControlPoints(dy2: GMNLength(0)).isEmpty)
    }
}
