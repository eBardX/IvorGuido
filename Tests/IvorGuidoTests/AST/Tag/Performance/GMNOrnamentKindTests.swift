// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNOrnamentKindTests {
}

// MARK: -

extension GMNOrnamentKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNOrnament.Kind.mordent == .mordent)
        #expect(GMNOrnament.Kind.mordent != .trill)
    }

    @Test
    func caseSetIsExactlyThree() {
        // The switch in `ornamentKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(ornamentKindLabel(.mordent) == "mordent")
        #expect(ornamentKindLabel(.trill) == "trill")
        #expect(ornamentKindLabel(.turn) == "turn")
    }

    @Test
    func kind_aliasTagName() {
        // guidolib spells several of these more than one way; each
        // alias lands on the same case as its canonical name.
        #expect(GMNOrnament.Kind.kind(forTagName: "mord") == .mordent)
        #expect(GMNOrnament.Kind.kind(forTagName: "trillBegin") == .trill)
        #expect(GMNOrnament.Kind.kind(forTagName: "trillEnd") == .trill)
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNOrnament.Kind.kind(forTagName: "mordent") == .mordent)
        #expect(GMNOrnament.Kind.kind(forTagName: "trill") == .trill)
        #expect(GMNOrnament.Kind.kind(forTagName: "turn") == .turn)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNOrnament.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNOrnament.Kind.mordent.tagName == "mordent")
        #expect(GMNOrnament.Kind.trill.tagName == "trill")
        #expect(GMNOrnament.Kind.turn.tagName == "turn")
    }
}
