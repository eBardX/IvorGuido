// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNNoteHeadsKindTests {
}

// MARK: -

extension GMNNoteHeadsKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNNoteHeads.Kind.center == .center)
        #expect(GMNNoteHeads.Kind.center != .left)
    }

    @Test
    func caseSetIsExactlyFive() {
        // The switch in `noteHeadsKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(noteHeadsKindLabel(.center) == "center")
        #expect(noteHeadsKindLabel(.left) == "left")
        #expect(noteHeadsKindLabel(.normal) == "normal")
        #expect(noteHeadsKindLabel(.reverse) == "reverse")
        #expect(noteHeadsKindLabel(.right) == "right")
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNNoteHeads.Kind.kind(forTagName: "headsCenter") == .center)
        #expect(GMNNoteHeads.Kind.kind(forTagName: "headsLeft") == .left)
        #expect(GMNNoteHeads.Kind.kind(forTagName: "headsNormal") == .normal)
        #expect(GMNNoteHeads.Kind.kind(forTagName: "headsReverse") == .reverse)
        #expect(GMNNoteHeads.Kind.kind(forTagName: "headsRight") == .right)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNNoteHeads.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNNoteHeads.Kind.center.tagName == "headsCenter")
        #expect(GMNNoteHeads.Kind.left.tagName == "headsLeft")
        #expect(GMNNoteHeads.Kind.normal.tagName == "headsNormal")
        #expect(GMNNoteHeads.Kind.reverse.tagName == "headsReverse")
        #expect(GMNNoteHeads.Kind.right.tagName == "headsRight")
    }
}
