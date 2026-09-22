// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNDynamicRampTests {
}

// MARK: -

extension GMNDynamicRampTests {
    @Test(arguments: [(GMNDynamicRamp.Direction.crescendo, GMNTag.Span.whole, "crescendo"),
                      (.crescendo, .begin, "crescBegin"),
                      (.crescendo, .end, "crescEnd"),
                      (.diminuendo, .whole, "diminuendo"),
                      (.diminuendo, .begin, "diminuendoBegin"),
                      (.diminuendo, .end, "diminuendoEnd")])
    func canonicalNameFollowsTheDirectionAndSpan(_ triple: (direction: GMNDynamicRamp.Direction,
                                                            span: GMNTag.Span,
                                                            expected: String)) {
        // `\crescendo` is asymmetric: guidolib dispatches no
        // `\crescendoBegin`, so the short spelling is canonical for its open
        // halves even though its range form has a long one.
        #expect(GMNDynamicRamp(direction: triple.direction,
                               span: triple.span).require().name == makeTagName(triple.expected))
    }

    @Test
    func equatable() {
        let a = GMNDynamicRamp(direction: .crescendo, dx1: GMNLength(1, unit: .hs)).require()
        let b = GMNDynamicRamp(direction: .crescendo, dx1: GMNLength(1, unit: .hs)).require()
        let c = GMNDynamicRamp(direction: .diminuendo, dx1: GMNLength(1, unit: .hs)).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test(arguments: [("cresc", GMNDynamicRamp.Direction.crescendo),
                      ("crescendo", .crescendo),
                      ("decresc", .diminuendo),
                      ("decrescendo", .diminuendo),
                      ("dim", .diminuendo),
                      ("diminuendo", .diminuendo)])
    func everyAliasPromotesToItsDirection(_ pair: (name: String, direction: GMNDynamicRamp.Direction)) throws {
        guard case let .dynamicRamp(ramp) = try normalizedTag("[\\\(pair.name)(c d)]")
        else {
            Issue.record("Expected dynamic ramp tag")
            return
        }

        #expect(ramp.direction == pair.direction)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let ramp = GMNDynamicRamp(direction: .crescendo).require()

        #expect(ramp.appearance.isEmpty)
        #expect(ramp.autopos == nil)
        #expect(ramp.body.isEmpty)
        #expect(ramp.deltaY == nil)
        #expect(ramp.direction == .crescendo)
        #expect(ramp.dx1 == nil)
        #expect(ramp.dx2 == nil)
        #expect(ramp.ident == nil)
        #expect(ramp.span == .whole)
        #expect(ramp.thickness == nil)
    }

    @Test
    func itHasTwoEndpointsAndNotFour() throws {
        // `kARDynamicParams` declares no `dy1`/`dy2` — the payload carries
        // `dx1`/`dx2` rather than borrowing `GMNTag.ControlPoints` with holes
        // in it — so writing one is unsupported and the normalizer drops it.
        guard case let .dynamicRamp(ramp) = try normalizedTag("[\\crescendo<dy1=1hs>(c d)]")
        else {
            Issue.record("Expected dynamic-ramp tag")
            return
        }

        #expect(ramp.dx1 == nil)
        #expect(ramp.dx2 == nil)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .dynamicRamp(ramp) =
              try normalizedTag("[\\crescendo<1hs,2hs,4hs,0.5,\"on\">(c d)]")
        else {
            Issue.record("Expected dynamic ramp tag")
            return
        }

        #expect(ramp.autopos == "on")
        #expect(ramp.deltaY == GMNLength(4, unit: .hs))
        #expect(ramp.dx1 == GMNLength(1, unit: .hs))
        #expect(ramp.dx2 == GMNLength(2, unit: .hs))
        #expect(ramp.thickness == GMNLength(0.5))
    }

    @Test
    func spanEndEmitsNoParameters() throws {
        guard case let .dynamicRamp(ramp) = try normalizedTag("[\\crescEnd]")
        else {
            Issue.record("Expected dynamic ramp tag")
            return
        }

        #expect(ramp.parameterValues.isEmpty)
        #expect(ramp.span == .end)
    }
}
