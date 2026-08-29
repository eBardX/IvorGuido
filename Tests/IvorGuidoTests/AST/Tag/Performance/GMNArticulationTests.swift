// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNArticulationTests {
}

// MARK: -

extension GMNArticulationTests {
    @Test
    func aSpanOnAnyOtherKindReportsItsRangeFormName() {
        // Unreachable through promotion — the registry answers `.whole` for
        // the other seven names — but a hand-built tag must still name
        // something guidolib dispatches, and `\staccBegin` would be a
        // different articulation entirely.
        #expect(GMNArticulation(kind: .accent, span: .begin).require().name == makeTagName("accent"))
        #expect(GMNArticulation(kind: .fermata, span: .end).require().name == makeTagName("fermata"))
    }

    @Test
    func aTypeWrittenOnAKindThatDeclaresNoneIsDropped() throws {
        // `\accent` is a bare `ARArticulation`, so `type` is unsupported and
        // the binding fails `checkExist`. The normalizer drops it and the
        // tag promotes with the field it could never have filled left empty.
        guard case let .articulation(articulation) = try normalizedTag("[\\accent<type=\"heavy\">(c)]")
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(articulation.kind == .accent)
        #expect(articulation.type == nil)
    }

    @Test
    func bowRequiresItsTypeAndBindsItFirst() throws {
        // `kARBowParams` is `"S,type,,r"` — the only articulation whose own
        // template both requires a parameter and puts it in slot 0.
        guard case let .articulation(articulation) = try normalizedTag("[\\bow<\"up\">(c)]")
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(articulation.type == "up")

        expectRejected("[\\bow(c)]",
                       .missingRequiredParameter(makeTagName("bow"), "type"))
    }

    @Test(arguments: [(GMNArticulation.Kind.accent, "accent"),
                      (.bow, "bow"),
                      (.fermata, "fermata"),
                      (.harmonic, "harmonic"),
                      (.marcato, "marcato"),
                      (.pizzicato, "pizzicato"),
                      (.staccato, "staccato"),
                      (.tenuto, "tenuto")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNArticulation.Kind, expected: String)) {
        // `\bow` is the one kind whose `type` the template flags required, so
        // it is the one kind that cannot be built bare.
        #expect(GMNArticulation(kind: pair.kind,
                                type: pair.kind == .bow ? "up" : nil).require().name
                == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNArticulation(kind: .accent, position: .above).require()
        let b = GMNArticulation(kind: .accent, position: .above).require()
        let c = GMNArticulation(kind: .marcato, position: .above).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let articulation = GMNArticulation(kind: .accent).require()

        #expect(articulation.appearance.isEmpty)
        #expect(articulation.body.isEmpty)
        #expect(articulation.ident == nil)
        #expect(articulation.kind == .accent)
        #expect(articulation.position == nil)
        #expect(articulation.span == .whole)
        #expect(articulation.type == nil)
    }

    @Test
    func init_refusesABowWithoutAType() {
        // `kARBowParams` flags `type` required, so a bare `\bow` is a tag the
        // validator refuses — and a hand-built payload is judged by the same
        // template a written one is. The other seven kinds are unaffected:
        // three declare no `type` at all and four declare an optional one.
        #expect(GMNArticulation(kind: .bow) == nil)
        #expect(GMNArticulation(kind: .bow,
                                type: "up") != nil)

        // Requiredness and the no-parameters-on-a-closing-half rule close on
        // each other here, which is right: `ARFactory` dispatches no
        // `\bowEnd`, so no closing half of a
        // bow should exist. A `type` makes it fail `carriesNoParameters`;
        // omitting one makes it fail requiredness.
        #expect(GMNArticulation(kind: .bow,
                                span: .end) == nil)
        #expect(GMNArticulation(kind: .bow,
                                type: "up",
                                span: .end) == nil)
    }

    @Test
    func isRejectedWhenThePositionIsOutsideTheVocabulary() {
        // FLIPPED IN PHASE 3. `ARArticulation` warns and leaves
        // `kDefaultPosition`, so guidolib cannot tell this from an absent
        // `position`. Promoting would let the formatter silently drop what was
        // written and the parser never discards, so the tag used to stay
        // generic with the value intact; the score is refused now.
        expectRejected("[\\accent<position=\"sideways\">(c)]",
                       .unreadableParameterValue(makeTagName("accent")))
    }

    @Test
    func onlyStaccatoSpans() throws {
        guard case let .articulation(begin) = try normalizedTag("[\\staccBegin c]"),
              case let .articulation(end) = try normalizedTag("[\\staccEnd]")
        else {
            Issue.record("Expected articulation tags")
            return
        }

        #expect(begin.span == .begin)
        #expect(begin.name == makeTagName("staccBegin"))
        #expect(end.span == .end)
        #expect(end.name == makeTagName("staccEnd"))
    }

    @Test(arguments: ["accent", "harmonic", "marcato", "ten", "tenuto", "fermata", "pizz", "pizzicato", "stacc", "staccato"])
    func promotesEveryNameThatNeedsNothing(_ name: String) throws {
        guard case .articulation = try normalizedTag("[\\\(name)(c)]")
        else {
            Issue.record("Expected \(name) to promote to an articulation")
            return
        }
    }

    @Test
    func promotesThePosition() throws {
        guard case let .articulation(articulation) = try normalizedTag("[\\accent<position=\"below\">(c)]")
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(articulation.kind == .accent)
        #expect(articulation.position == .below)
    }

    @Test
    func spanEndEmitsNoParameters() throws {
        // `\staccEnd` is an `ARDummyRangeEnd`, so one
        // written with a parameter parses generic and the normalizer drops
        // what it could never read.
        guard case let .articulation(articulation) = try normalizedTag("[\\staccEnd<dx=2hs>]")
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(articulation.parameterValues.isEmpty)
        #expect(articulation.span == .end)
    }
}
