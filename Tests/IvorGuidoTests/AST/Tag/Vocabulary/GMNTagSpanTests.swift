// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// A closing half carries no parameters, stated executably.
//
// An invariant a node can check *alone* is enforced at construction, and
// everything cross-node is enforced by the stage that mints the score.
//
// One case per spanning payload, because the eleven are eleven types and no
// protocol reaches their initializers. What is *not* repeated eleven times is
// the rule itself: ten of them guard through `GMNTagPayload.carriesNoParameters`
// and `GMNVolta` states it against its fields, for the reason its own comment
// gives.
struct GMNTagSpanTests {
}

// MARK: -

extension GMNTagSpanTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.Span.begin == .begin)
        #expect(GMNTag.Span.begin != .end)
        #expect(GMNTag.Span.begin != .whole)
        #expect(GMNTag.Span.end != .whole)
    }

    @Test
    func caseSetIsExactlyThree() {
        // Exhaustive by compilation. The range form and the open form are
        // separate cases precisely because they are never interchanged.
        #expect(suffix(.begin) == "Begin")
        #expect(suffix(.end) == "End")
        #expect(suffix(.whole).isEmpty)
    }

    @Test
    func spanBeginAndWhole_areUnaffected() {
        #expect(GMNSlur(curve: .up,
                        span: .begin) != nil)
        #expect(GMNSlur(curve: .up,
                        span: .whole) != nil)
        #expect(GMNVolta(mark: "1.",
                         span: .begin) != nil)
    }

    @Test
    func spanEnd_admitsABareOne() {
        // The shape the parser actually produces, and the one the normalizer
        // repairs a written `\slurEnd<dx=2hs>` into.
        #expect(GMNSlur(span: .end) != nil)
        #expect(GMNTie(span: .end) != nil)
        #expect(GMNTuplet(span: .end) != nil)
        #expect(GMNVolta(mark: "",
                         span: .end) != nil)
    }

    @Test
    func spanEnd_admitsABody() {
        // `body` is not a parameter. Whether a closing half may carry one is
        // a question about `rangesetting`, which the validator answers
        // (`unexpectedTagBody`) — so refusing it here would move a check
        // between stages under cover of a constructibility phase.
        let note = GMNSymbol.note(makeNote(makePitch(.c, 4),
                                           makeDuration(1, 4)))

        #expect(GMNSlur(span: .end,
                        body: [note]) != nil)
    }

    @Test
    func spanEnd_refusesACommonParameterToo() {
        // The half that is easy to forget. `kCommonParams` lives on
        // `appearance` rather than in the payload's own fields, and the
        // span-end repair drops it as squarely as it drops the rest — so a
        // guard reading only `parameterValues` would have let `\slurEnd`
        // keep a colour.
        let red = GMNTag.Appearance(color: "red")

        #expect(GMNSlur(span: .end,
                        appearance: red) == nil)
        #expect(GMNTie(span: .end,
                       appearance: red) == nil)
        #expect(GMNTuplet(span: .end,
                          appearance: red) == nil)
        #expect(GMNVolta(mark: "",
                         span: .end,
                         appearance: red) == nil)
    }

    @Test
    func spanEnd_refusesAPayloadParameter() {
        #expect(GMNArticulation(kind: .staccato,
                                type: "above",
                                span: .end) == nil)
        #expect(GMNBeam(kind: .normal,
                        durations: "1/8",
                        span: .end) == nil)
        #expect(GMNDynamicRamp(direction: .crescendo,
                               thickness: GMNLength(2, unit: .hs),
                               span: .end) == nil)
        #expect(GMNGlissando(fill: "yes",
                             span: .end) == nil)
        #expect(GMNOrnament(kind: .trill,
                            note: "c",
                            span: .end) == nil)
        #expect(GMNSlur(curve: .up,
                        span: .end) == nil)
        #expect(GMNTempoChange(direction: .accelerando,
                               before: "accel.",
                               span: .end) == nil)
        #expect(GMNTie(r3: 0.5,
                       span: .end) == nil)
        #expect(GMNTremolo(style: "///",
                           span: .end) == nil)
        #expect(GMNTuplet(format: "-3-",
                          span: .end) == nil)
        #expect(GMNVolta(mark: "1.",
                         span: .end) == nil)
    }
}
