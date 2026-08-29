// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNChordSegmentTests {
}

// MARK: -

extension GMNChordSegmentTests {
    @Test
    func equatable() {
        let a = makeChordSegment([.note(makeNote(makePitch(.c, 4)))])
        let b = makeChordSegment([.note(makeNote(makePitch(.c, 4)))])
        let c = makeChordSegment([.note(makeNote(makePitch(.d, 4)))])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_emptySymbols() {
        // A segment is one voice of a chord, so an empty one has nothing to
        // sound and is not representable.
        #expect(GMNChord.Segment(symbols: []) == nil)
    }

    @Test
    func init_nestedChordInATagBody() {
        // The guard recurses into tag bodies, so a chord buried under a tag
        // is refused as squarely as a bare one.
        let inner = makeChord([makeChordSegment([.note(makeNote(makePitch(.c, 4)))])])
        let tag = makeTag(makeTagName("slur"),
                          body: [.chord(inner)])

        #expect(GMNChord.Segment(symbols: [.tag(tag)]) == nil)
    }

    @Test
    func init_nestedChordIsRefused() {
        // guidolib has no chord-within-a-chord, and the AST does not invent
        // one.
        let inner = makeChord([makeChordSegment([.note(makeNote(makePitch(.c, 4)))])])

        #expect(GMNChord.Segment(symbols: [.chord(inner)]) == nil)
    }

    @Test
    func init_storesSymbols() {
        let symbols: [GMNSymbol] = [.note(makeNote(makePitch(.c, 4))),
                                    .note(makeNote(makePitch(.e, 4)))]
        let segment = GMNChord.Segment(symbols: symbols)

        #expect(segment?.symbols == symbols)
    }

    @Test
    func init_tagWithoutANestedChordIsAdmitted() {
        let tag = makeTag(makeTagName("slur"),
                          body: [.note(makeNote(makePitch(.c, 4)))])

        #expect(GMNChord.Segment(symbols: [.tag(tag)]) != nil)
    }
}
