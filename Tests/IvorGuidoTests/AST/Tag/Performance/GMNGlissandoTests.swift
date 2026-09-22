// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNGlissandoTests {
}

// MARK: -

extension GMNGlissandoTests {
    @Test(arguments: [(GMNTag.Span.whole, "glissando"),
                      (.begin, "glissandoBegin"),
                      (.end, "glissandoEnd")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        #expect(GMNGlissando(span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNGlissando(fill: "true").require()
        let b = GMNGlissando(fill: "true").require()
        let c = GMNGlissando(fill: "false").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let glissando = GMNGlissando().require()

        #expect(glissando.appearance.isEmpty)
        #expect(glissando.body.isEmpty)
        #expect(glissando.controlPoints.isEmpty)
        #expect(glissando.fill == nil)
        #expect(glissando.ident == nil)
        #expect(glissando.span == .whole)
        #expect(glissando.thickness == nil)
    }

    @Test
    func itCarriesTheQuartetWithoutBeingABowing() throws {
        // The third of the three tags with the full `dx1`/`dy1`/`dx2`/`dy2`
        // set, and the only one that is not an `ARBowing` — so it shares
        // `GMNTag.ControlPoints` with `\slur` and `\tie` while declaring no
        // `curve`, `r3`, or `h` of its own — so a written `curve` is
        // unsupported, and the normalizer drops it rather than letting it
        // reach a field that does not exist.
        guard case let .glissando(glissando) = try normalizedTag("[\\glissando<curve=\"down\">(c e)]")
        else {
            Issue.record("Expected glissando tag")
            return
        }

        #expect(glissando.parameterValues.isEmpty)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .glissando(glissando) =
              try normalizedTag("[\\glissando<1hs,2hs,3hs,4hs,\"true\",0.5>(c e)]")
        else {
            Issue.record("Expected glissando tag")
            return
        }

        #expect(glissando.controlPoints == GMNTag.ControlPoints(dx1: GMNLength(1, unit: .hs),
                                                                dy1: GMNLength(2, unit: .hs),
                                                                dx2: GMNLength(3, unit: .hs),
                                                                dy2: GMNLength(4, unit: .hs)))
        #expect(glissando.fill == "true")
        #expect(glissando.thickness == GMNLength(0.5))
    }

    @Test
    func spanEndEmitsNoParameters() throws {
        guard case let .glissando(glissando) = try normalizedTag("[\\glissandoEnd]")
        else {
            Issue.record("Expected glissando tag")
            return
        }

        #expect(glissando.parameterValues.isEmpty)
        #expect(glissando.span == .end)
    }
}
