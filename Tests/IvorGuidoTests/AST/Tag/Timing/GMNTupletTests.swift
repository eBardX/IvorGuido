// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTupletTests {
}

// MARK: -

extension GMNTupletTests {
    @Test(arguments: [(GMNTag.Span.begin, "tupletBegin"),
                      (GMNTag.Span.end, "tupletEnd"),
                      (GMNTag.Span.whole, "tuplet")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        // The `format` follows the span too: required for the two halves that
        // carry parameters, refused for the one that carries none.
        #expect(GMNTuplet(format: pair.span == .end ? nil : "-3-",
                          span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func endHalfWithAParameterIsRepaired() throws {
        // An `…End` tag is an `ARDummyRangeEnd` and carries no parameters.
        // One written there has nowhere to go, so the parser
        // leaves the tag generic and the normalizer drops it.
        guard case let .tuplet(tuplet) = try normalizedTag("[\\tupletEnd<dx=2hs>]")
        else {
            Issue.record("Expected tuplet tag")
            return
        }

        #expect(tuplet.parameterValues.isEmpty)
        #expect(tuplet.span == .end)
    }

    @Test
    func equatable() {
        let a = GMNTuplet(format: "-3-").require()
        let b = GMNTuplet(format: "-3-").require()
        let c = GMNTuplet(format: "-3-",
                          span: .begin).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let tuplet = GMNTuplet(format: "-3-").require()

        #expect(tuplet.appearance.isEmpty)
        #expect(tuplet.body.isEmpty)
        #expect(tuplet.bold == nil)
        #expect(tuplet.dispNote == nil)
        #expect(tuplet.dy1 == nil)
        #expect(tuplet.dy2 == nil)
        #expect(tuplet.format == "-3-")
        #expect(tuplet.ident == nil)
        #expect(tuplet.lineThickness == nil)
        #expect(tuplet.position == nil)
        #expect(tuplet.span == .whole)
        #expect(tuplet.textSize == nil)
    }

    @Test
    func init_fromBindingRequiresFormatExceptAtASpanEnd() {
        #expect(GMNTuplet(ident: nil,
                          binding: makeBinding("tuplet"),
                          span: .whole,
                          body: []) == nil)

        #expect(GMNTuplet(ident: nil,
                          binding: makeBinding("tupletEnd"),
                          span: .end,
                          body: []) != nil)
    }

    @Test
    func init_refusesAMissingFormatExceptAtASpanEnd() {
        // The public initializer enforces what the binding one already did.
        // `kARTupletParams` flags `format` required, so `\tuplet` and
        // `\tupletBegin` must carry one; the closing half carries nothing at
        // all, which is the one case a `nil` format is correct for.
        #expect(GMNTuplet(format: nil) == nil)
        #expect(GMNTuplet(format: nil,
                          span: .begin) == nil)
        #expect(GMNTuplet(format: nil,
                          span: .end) != nil)
        #expect(GMNTuplet(format: "-3-") != nil)
        #expect(GMNTuplet(format: "-3-",
                          span: .begin) != nil)
        #expect(GMNTuplet(format: "-3-",
                          span: .end) == nil)
    }

    @Test
    func positionParsesOpenly() throws {
        // `\tuplet` is the fully open case: `below` means below and anything
        // else at all means above (`ARTuplet.cpp:146–152`).
        for (written, expected) in [("below", GMNTag.Placement.below),
                                    ("above", GMNTag.Placement.above),
                                    ("banana", GMNTag.Placement.above)] {
            guard case let .tuplet(tuplet) = try normalizedTag("[\\tuplet<\"-3-\",\"\(written)\">(c d e)]")
            else {
                Issue.record("Expected tuplet tag")
                return
            }

            #expect(tuplet.position == expected)
        }
    }

    @Test
    func promotes() throws {
        guard case let .tuplet(tuplet) = try normalizedTag("[\\tuplet<\"-3-\",dy1=2hs>(c d e)]")
        else {
            Issue.record("Expected tuplet tag")
            return
        }

        #expect(tuplet.body.count == 3)
        #expect(tuplet.dy1 == GMNLength(2, unit: .hs))
        #expect(tuplet.format == "-3-")
        #expect(tuplet.span == .whole)
    }

    @Test
    func promotesTheBeginHalf() throws {
        guard case let .tuplet(tuplet) = try normalizedTag("[\\tupletBegin:1<\"3:2\"> c \\tupletEnd:1]")
        else {
            Issue.record("Expected tuplet tag")
            return
        }

        #expect(tuplet.format == "3:2")
        #expect(tuplet.ident == makeTagIdent(1))
        #expect(tuplet.span == .begin)
    }
}
