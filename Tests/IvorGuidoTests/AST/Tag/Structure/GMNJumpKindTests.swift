// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNJumpKindTests {
}

// MARK: -

extension GMNJumpKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNJump.Kind.coda == .coda)
        #expect(GMNJump.Kind.coda != .daCapo)
    }

    @Test
    func caseSetIsExactlyEight() {
        // The switch in `jumpKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(jumpKindLabel(.coda) == "coda")
        #expect(jumpKindLabel(.daCapo) == "daCapo")
        #expect(jumpKindLabel(.daCapoAlFine) == "daCapoAlFine")
        #expect(jumpKindLabel(.daCoda) == "daCoda")
        #expect(jumpKindLabel(.dalSegno) == "dalSegno")
        #expect(jumpKindLabel(.dalSegnoAlFine) == "dalSegnoAlFine")
        #expect(jumpKindLabel(.fine) == "fine")
        #expect(jumpKindLabel(.segno) == "segno")
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNJump.Kind.kind(forTagName: "coda") == .coda)
        #expect(GMNJump.Kind.kind(forTagName: "daCapo") == .daCapo)
        #expect(GMNJump.Kind.kind(forTagName: "daCapoAlFine") == .daCapoAlFine)
        #expect(GMNJump.Kind.kind(forTagName: "daCoda") == .daCoda)
        #expect(GMNJump.Kind.kind(forTagName: "dalSegno") == .dalSegno)
        #expect(GMNJump.Kind.kind(forTagName: "dalSegnoAlFine") == .dalSegnoAlFine)
        #expect(GMNJump.Kind.kind(forTagName: "fine") == .fine)
        #expect(GMNJump.Kind.kind(forTagName: "segno") == .segno)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNJump.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNJump.Kind.coda.tagName == "coda")
        #expect(GMNJump.Kind.daCapo.tagName == "daCapo")
        #expect(GMNJump.Kind.daCapoAlFine.tagName == "daCapoAlFine")
        #expect(GMNJump.Kind.daCoda.tagName == "daCoda")
        #expect(GMNJump.Kind.dalSegno.tagName == "dalSegno")
        #expect(GMNJump.Kind.dalSegnoAlFine.tagName == "dalSegnoAlFine")
        #expect(GMNJump.Kind.fine.tagName == "fine")
        #expect(GMNJump.Kind.segno.tagName == "segno")
    }
}
