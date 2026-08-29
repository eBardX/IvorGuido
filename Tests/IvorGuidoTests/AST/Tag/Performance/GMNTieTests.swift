// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTieTests {
}

// MARK: -

extension GMNTieTests {
    @Test(arguments: [(GMNTag.Span.whole, "tie"),
                      (.begin, "tieBegin"),
                      (.end, "tieEnd")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        #expect(GMNTie(span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNTie(curve: .up).require()
        let b = GMNTie(curve: .up).require()
        let c = GMNTie(curve: .down).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let tie = GMNTie().require()

        #expect(tie.appearance.isEmpty)
        #expect(tie.body.isEmpty)
        #expect(tie.controlPoints.isEmpty)
        #expect(tie.curve == nil)
        #expect(tie.h == nil)
        #expect(tie.ident == nil)
        #expect(tie.r3 == nil)
        #expect(tie.span == .whole)
    }

    @Test
    func itHasSlursShapeVerbatim() throws {
        // `ARTie : ARBowing` adds neither a template nor a read — a
        // transcription trap, and the reason grouping payloads by
        // what a tag *means* rather than by what it *accepts* would have put
        // this one in the timing bucket with a template it does not have.
        guard case let .tie(tie) = try normalizedTag("[\\tie<\"down\",1hs,2hs,3hs,4hs,0.25,5hs>(c c)]")
        else {
            Issue.record("Expected tie tag")
            return
        }

        #expect(tie.controlPoints == GMNTag.ControlPoints(dx1: GMNLength(1, unit: .hs),
                                                          dy1: GMNLength(2, unit: .hs),
                                                          dx2: GMNLength(3, unit: .hs),
                                                          dy2: GMNLength(4, unit: .hs)))
        #expect(tie.curve == .down)
        #expect(tie.h == GMNLength(5, unit: .hs))
        #expect(tie.r3 == 0.25)
    }

    @Test
    func spanEndEmitsNoParameters() throws {
        guard case let .tie(tie) = try normalizedTag("[\\tieEnd]")
        else {
            Issue.record("Expected tie tag")
            return
        }

        #expect(tie.parameterValues.isEmpty)
        #expect(tie.span == .end)
    }
}
