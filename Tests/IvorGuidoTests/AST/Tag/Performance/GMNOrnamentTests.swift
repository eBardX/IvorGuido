// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNOrnamentTests {
}

// MARK: -

extension GMNOrnamentTests {
    @Test(arguments: [("mord", GMNOrnament.Kind.mordent),
                      ("mordent", .mordent),
                      ("trill", .trill),
                      ("turn", .turn)])
    func allThreeNamesBuildOneClass(_ pair: (name: String, kind: GMNOrnament.Kind)) throws {
        // `ARFactory` selects between the three by constructor argument on a
        // single `ARTrill`, which is why one payload covers all of them.
        guard case let .ornament(ornament) = try normalizedTag("[\\\(pair.name)(c)]")
        else {
            Issue.record("Expected ornament tag")
            return
        }

        #expect(ornament.kind == pair.kind)
    }

    @Test(arguments: [(GMNOrnament.Kind.mordent, "mordent"),
                      (.trill, "trill"),
                      (.turn, "turn")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNOrnament.Kind, expected: String)) {
        #expect(GMNOrnament(kind: pair.kind).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNOrnament(kind: .trill, note: "c").require()
        let b = GMNOrnament(kind: .trill, note: "c").require()
        let c = GMNOrnament(kind: .turn, note: "c").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let ornament = GMNOrnament(kind: .trill).require()

        #expect(ornament.accidental == nil)
        #expect(ornament.adx == nil)
        #expect(ornament.ady == nil)
        #expect(ornament.appearance.isEmpty)
        #expect(ornament.begin == nil)
        #expect(ornament.body.isEmpty)
        #expect(ornament.detune == nil)
        #expect(ornament.dur == nil)
        #expect(ornament.ident == nil)
        #expect(ornament.note == nil)
        #expect(ornament.position == nil)
        #expect(ornament.repeats == nil)
        #expect(ornament.span == .whole)
        #expect(ornament.tr == nil)
        #expect(ornament.type == nil)
        #expect(ornament.wavy == nil)
    }

    @Test
    func isRejectedWhenThePositionIsOutsideTheVocabulary() {
        expectRejected("[\\trill<position=\"sideways\">(c)]",
                       .unreadableParameterValue(makeTagName("trill")))
    }

    @Test
    func onlyTrillSpans() throws {
        guard case let .ornament(begin) = try normalizedTag("[\\trillBegin c]"),
              case let .ornament(end) = try normalizedTag("[\\trillEnd]")
        else {
            Issue.record("Expected ornament tags")
            return
        }

        #expect(begin.span == .begin)
        #expect(end.span == .end)

        // `\mordent` and `\turn` have no `Begin`/`End` form at all, so a
        // hand-built span on either reports the range-form name.
        #expect(GMNOrnament(kind: .mordent, span: .begin).require().name == makeTagName("mordent"))
        #expect(GMNOrnament(kind: .turn, span: .end).require().name == makeTagName("turn"))
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .ornament(ornament) =
              try normalizedTag("[\\trill<\"d\",\"prallprall\",0.5,\"cautionary\",16,\"off\",1hs,2hs,\"false\",\"false\",\"below\",\"false\">(c)]")
        else {
            Issue.record("Expected ornament tag")
            return
        }

        #expect(ornament.accidental == "cautionary")
        #expect(ornament.adx == GMNLength(1, unit: .hs))
        #expect(ornament.ady == GMNLength(2, unit: .hs))
        #expect(ornament.begin == "off")
        #expect(ornament.detune == 0.5)
        #expect(ornament.dur == 16)
        #expect(ornament.note == "d")
        #expect(ornament.position == .below)
        #expect(ornament.repeats == "false")
        #expect(ornament.tr == "false")
        #expect(ornament.type == "prallprall")
        #expect(ornament.wavy == "false")
    }

    @Test
    func repeatIsSpelledRepeatsButEmittedAsGuidolibSpellsIt() {
        // `repeat` is a Swift keyword; the emitted parameter name is not.
        let ornament = GMNOrnament(kind: .trill, repeats: "false").require()

        #expect(ornament.parameterValues["repeat"] == .string("false"))
        #expect(ornament.parameterValues["repeats"] == nil)
    }
}
