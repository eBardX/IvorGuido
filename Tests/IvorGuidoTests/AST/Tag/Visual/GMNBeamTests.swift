// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBeamTests {
}

// MARK: -

extension GMNBeamTests {
    @Test
    func aFeatheredBeamHasItsOwnSlotOrder() throws {
        // `ARFeatheredBeam` overrides `getParamsStr()` rather than appending
        // to `kARBeamParams`, so its only positional slots are `durations` and
        // `drawDuration` — the corners must be written named.
        guard case let .beam(beam) =
              try normalizedTag("[\\fBeam<\"1/16,1/4\",\"true\",dx1=1hs>(c d)]")
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.controlPoints.dx1 == GMNLength(1, unit: .hs))
        #expect(beam.drawDuration == "true")
        #expect(beam.durations == "1/16,1/4")
        #expect(beam.kind == .feathered)
    }

    @Test(arguments: ["b", "beam", "bm"])
    func allThreeSpellingsPromote(_ name: String) throws {
        guard case let .beam(beam) = try normalizedTag("[\\\(name)(c d)]")
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.kind == .normal)
        #expect(beam.span == .whole)
    }

    @Test
    func anEndHalfCarriesNoParameters() throws {
        // An `…End` is an `ARDummyRangeEnd`, which takes none, so one
        // written with a parameter parses generic and the
        // normalizer drops it.
        guard case let .beam(beam) = try normalizedTag("[\\beamEnd<dx=2hs>]")
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.parameterValues.isEmpty)
        #expect(beam.span == .end)
    }

    @Test
    func bothSpanHalvesPromote() throws {
        guard case let .beam(begin) = try normalizedTag("[\\beamBegin c]"),
              case let .beam(end) = try normalizedTag("[\\fBeamEnd]")
        else {
            Issue.record("Expected beam tags")
            return
        }

        #expect(begin.kind == .normal)
        #expect(begin.span == .begin)
        #expect(end.kind == .feathered)
        #expect(end.span == .end)
    }

    @Test(arguments: [(GMNBeam.Kind.normal, GMNTag.Span.whole, "beam"),
                      (GMNBeam.Kind.normal, .begin, "beamBegin"),
                      (GMNBeam.Kind.normal, .end, "beamEnd"),
                      (GMNBeam.Kind.feathered, .whole, "fBeam"),
                      (GMNBeam.Kind.feathered, .begin, "fBeamBegin"),
                      (GMNBeam.Kind.feathered, .end, "fBeamEnd")])
    func canonicalNameFollowsTheKindAndSpan(_ triple: (kind: GMNBeam.Kind, span: GMNTag.Span, expected: String)) {
        // Both families are symmetric, so unlike the articulations and the
        // dynamic ramps there is no short spelling to preserve.
        #expect(GMNBeam(kind: triple.kind, span: triple.span).require().name == makeTagName(triple.expected))
    }

    @Test
    func equatable() {
        let a = GMNBeam(kind: .normal, controlPoints: GMNBeam.ControlPoints(dx1: GMNLength(1))).require()
        let b = GMNBeam(kind: .normal, controlPoints: GMNBeam.ControlPoints(dx1: GMNLength(1))).require()
        let c = GMNBeam(kind: .normal).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let beam = GMNBeam(kind: .normal).require()

        #expect(beam.appearance.isEmpty)
        #expect(beam.body.isEmpty)
        #expect(beam.controlPoints.isEmpty)
        #expect(beam.drawDuration == nil)
        #expect(beam.durations == nil)
        #expect(beam.ident == nil)
        #expect(beam.kind == .normal)
        #expect(beam.span == .whole)
    }

    @Test
    func theCornersFollowTheOffset() throws {
        guard case let .beam(beam) =
              try normalizedTag("[\\beam<0hs,1hs,2hs,3hs,4hs,5hs,6hs,7hs,8hs>(c d)]")
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.appearance.dy == GMNLength(0, unit: .hs))
        #expect(beam.controlPoints.dx1 == GMNLength(1, unit: .hs))
        #expect(beam.controlPoints.dy1 == GMNLength(2, unit: .hs))
        #expect(beam.controlPoints.dx4 == GMNLength(7, unit: .hs))
        #expect(beam.controlPoints.dy4 == GMNLength(8, unit: .hs))
    }

    @Test
    func theFirstSlotIsTheVerticalOffset() throws {
        // `kARBeamParams` opens with `U,dy,0,o`, a `kCommonParams` name
        // redeclared as this tag's own — so `\beam<2hs>` sets `dy`, and this
        // payload keeps it where every other tag's `dy` lives.
        guard case let .beam(beam) = try normalizedTag("[\\beam<2hs>(c d)]")
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.appearance.dy == GMNLength(2, unit: .hs))
        #expect(beam.controlPoints.isEmpty)
    }
}
