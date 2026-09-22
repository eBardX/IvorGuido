// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBeamControlPointsTests {
}

// MARK: -

extension GMNBeamControlPointsTests {
    @Test
    func equatable() {
        let a = GMNBeam.ControlPoints(dx1: GMNLength(2, unit: .hs))
        let b = GMNBeam.ControlPoints(dx1: GMNLength(2, unit: .hs))
        let c = GMNBeam.ControlPoints(dx1: GMNLength(3, unit: .hs))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEveryPointToNil() {
        let points = GMNBeam.ControlPoints()

        #expect(points.dx1 == nil)
        #expect(points.dx2 == nil)
        #expect(points.dx3 == nil)
        #expect(points.dx4 == nil)
        #expect(points.dy1 == nil)
        #expect(points.dy2 == nil)
        #expect(points.dy3 == nil)
        #expect(points.dy4 == nil)
    }

    @Test
    func init_storesEachPointSeparately() {
        // The eight are positional in the written tag but named here, so a
        // transposed pair would otherwise go unnoticed.
        let points = GMNBeam.ControlPoints(dx1: GMNLength(1, unit: .hs),
                                           dy1: GMNLength(2, unit: .hs),
                                           dx2: GMNLength(3, unit: .hs),
                                           dy2: GMNLength(4, unit: .hs),
                                           dx3: GMNLength(5, unit: .hs),
                                           dy3: GMNLength(6, unit: .hs),
                                           dx4: GMNLength(7, unit: .hs),
                                           dy4: GMNLength(8, unit: .hs))

        #expect(points.dx1 == GMNLength(1, unit: .hs))
        #expect(points.dy1 == GMNLength(2, unit: .hs))
        #expect(points.dx2 == GMNLength(3, unit: .hs))
        #expect(points.dy2 == GMNLength(4, unit: .hs))
        #expect(points.dx3 == GMNLength(5, unit: .hs))
        #expect(points.dy3 == GMNLength(6, unit: .hs))
        #expect(points.dx4 == GMNLength(7, unit: .hs))
        #expect(points.dy4 == GMNLength(8, unit: .hs))
    }

    @Test
    func isEmpty_anySinglePointMakesItNonEmpty() {
        // Each of the eight has to count, or a tag carrying only that one
        // point would format as though it carried none.
        #expect(!GMNBeam.ControlPoints(dx1: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dy1: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dx2: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dy2: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dx3: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dy3: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dx4: GMNLength(1, unit: .hs)).isEmpty)
        #expect(!GMNBeam.ControlPoints(dy4: GMNLength(1, unit: .hs)).isEmpty)
    }

    @Test
    func isEmpty_noPointsAtAll() {
        #expect(GMNBeam.ControlPoints().isEmpty)
    }

    @Test
    func parameterValues_omitsAbsentPoints() {
        let points = GMNBeam.ControlPoints(dx1: GMNLength(2, unit: .hs))

        #expect(points.parameterValues.count == 1)
        #expect(points.parameterValues["dx1"] != nil)
        #expect(points.parameterValues["dy1"] == nil)
    }

    @Test
    func parameterValues_whenEmptyIsEmpty() {
        #expect(GMNBeam.ControlPoints().parameterValues.isEmpty)
    }
}
