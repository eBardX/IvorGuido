// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNSlurTests {
}

// MARK: -

extension GMNSlurTests {
    @Test
    func aCurveInsideTheVocabularyPromotes() throws {
        // The other side of the same rule: `up` and `down` are what guidolib
        // spells them, so nothing is substituted and the tag promotes.
        // Case is read leniently — `Up`/`UP` are the same word as `up` — so
        // every casing of both words is covered here, not just the
        // canonical lowercase spelling.
        for (written, expected) in [("up", GMNTag.Curve.up),
                                    ("Up", GMNTag.Curve.up),
                                    ("UP", GMNTag.Curve.up),
                                    ("down", GMNTag.Curve.down),
                                    ("Down", GMNTag.Curve.down),
                                    ("DOWN", GMNTag.Curve.down)] {
            guard case let .slur(slur) = try normalizedTag("[\\slur<curve=\"\(written)\">(c d)]")
            else {
                Issue.record("Expected slur tag for \(written)")
                continue
            }

            #expect(slur.curve == expected)
        }
    }

    @Test
    func anHWrittenAsSomethingOtherThanALengthIsDropped() throws {
        // FLIPPED IN PHASE 2. `h` was exempted from the inert-parameter
        // repair as one of four names guidolib was thought to read under two
        // C++ types. `ARBowing` reads it as a `TagParameterFloat` and nothing
        // else (`ARBowing.cpp:96`), matching the template's `U`; the second
        // type the grep saw belonged to `ARSymbol`. A string here is inert, so
        // it goes, and the slur promotes with no apex height.
        guard case let .slur(slur) = try normalizedTag("[\\slur<h=\"2\">(c d)]")
        else {
            Issue.record("Expected slur tag")
            return
        }

        #expect(slur.h == nil)
    }

    @Test(arguments: [(GMNTag.Span.whole, "slur"),
                      (.begin, "slurBegin"),
                      (.end, "slurEnd")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        #expect(GMNSlur(span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNSlur(curve: .up).require()
        let b = GMNSlur(curve: .up).require()
        let c = GMNSlur(curve: .down).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let slur = GMNSlur().require()

        #expect(slur.appearance.isEmpty)
        #expect(slur.body.isEmpty)
        #expect(slur.controlPoints.isEmpty)
        #expect(slur.curve == nil)
        #expect(slur.h == nil)
        #expect(slur.ident == nil)
        #expect(slur.r3 == nil)
        #expect(slur.span == .whole)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .slur(slur) =
              try normalizedTag("[\\slur<\"down\",1hs,2hs,3hs,4hs,0.25,5hs>(c d)]")
        else {
            Issue.record("Expected slur tag")
            return
        }

        #expect(slur.controlPoints == GMNTag.ControlPoints(dx1: GMNLength(1, unit: .hs),
                                                           dy1: GMNLength(2, unit: .hs),
                                                           dx2: GMNLength(3, unit: .hs),
                                                           dy2: GMNLength(4, unit: .hs)))
        #expect(slur.curve == .down)
        #expect(slur.h == GMNLength(5, unit: .hs))
        #expect(slur.r3 == 0.25)
    }

    @Test
    func spanEndEmitsNoParameters() throws {
        guard case let .slur(slur) = try normalizedTag("[\\slurEnd]")
        else {
            Issue.record("Expected slur tag")
            return
        }

        #expect(slur.parameterValues.isEmpty)
        #expect(slur.span == .end)

        // One written with a parameter parses generic and is repaired by
        // the normalizer, which drops what `ARDummyRangeEnd`
        // could never read and re-promotes.
        guard case let .slur(repaired) = try normalizedTag("[\\slurEnd<dx=2hs>]")
        else {
            Issue.record("Expected slur tag")
            return
        }

        #expect(repaired.parameterValues.isEmpty)
        #expect(repaired.span == .end)
    }

    @Test
    func theCommonOffsetsAreNotTheControlPoints() throws {
        // `ARBowing` *adds* `dx` to both `dx1` and `dx2` rather than
        // substituting it (`ARBowing.cpp:70–77`), so the two sets are
        // independent and neither normalizes into the other.
        guard case let .slur(slur) = try normalizedTag("[\\slur<dx=2hs>(c d)]")
        else {
            Issue.record("Expected slur tag")
            return
        }

        #expect(slur.appearance.dx == GMNLength(2, unit: .hs))
        #expect(slur.controlPoints.isEmpty)
    }

    @Test
    func theCurveParseIsOpenSoAnUnrecognizedValueIsRejected() {
        // FLIPPED IN PHASE 3. `ARBowing`'s `curve` has no third state — only
        // the exact string `down` is down and everything else is up
        // (`ARBowing.cpp:80–92`) — so promoting `banana` would be
        // semantically faithful and would also silently substitute `up` for
        // what the author wrote. The parser does not rewrite, so the tag
        // used to stay generic with the value intact and the validator
        // reported it; it is refused outright now, exactly as an unreadable
        // `position` is.
        expectRejected("[\\slur<curve=\"banana\">(c d)]",
                       .unreadableParameterValue(makeTagName("slur")))
    }
}
