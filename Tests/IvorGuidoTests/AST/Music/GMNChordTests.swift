// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNChordTests {
}

// MARK: -

extension GMNChordTests {
    @Test
    func `init`() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let segment = makeChordSegment([.note(note)])
        let chord = makeChord([segment])

        #expect(chord.segments.count == 1)
        #expect(chord.segments[0].symbols.count == 1)
    }

    @Test
    func equatable() {
        let note1 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let note2 = makeNote(makePitch(.e, 4),
                             makeDuration(1, 4))
        let seg1 = makeChordSegment([.note(note1)])
        let seg2 = makeChordSegment([.note(note2)])
        let chord1 = makeChord([seg1])
        let chord2 = makeChord([seg1])
        let chord3 = makeChord([seg2])

        #expect(chord1 == chord2)
        #expect(chord1 != chord3)
    }

    @Test
    func init_multipleSegments() {
        let note1 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let note2 = makeNote(makePitch(.e, 4),
                             makeDuration(1, 4))
        let seg1 = makeChordSegment([.note(note1)])
        let seg2 = makeChordSegment([.note(note2)])
        let chord = makeChord([seg1, seg2])

        #expect(chord.segments.count == 2)
    }

    @Test
    func init_nilForEmptySegments() {
        let chord = GMNChord(segments: [])

        #expect(chord == nil)
    }

    @Test
    func segment_equatable() {
        let note1 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let note2 = makeNote(makePitch(.e, 4),
                             makeDuration(1, 4))
        let seg1 = makeChordSegment([.note(note1)])
        let seg2 = makeChordSegment([.note(note1)])
        let seg3 = makeChordSegment([.note(note2)])

        #expect(seg1 == seg2)
        #expect(seg1 != seg3)
    }

    @Test
    func segment_init_failure_nestedChord() {
        let innerNote = makeNote(makePitch(.c, 4),
                                 makeDuration(1, 4))
        let innerSegment = makeChordSegment([.note(innerNote)])
        let innerChord = makeChord([innerSegment])
        let segment = GMNChord.Segment(symbols: [.chord(innerChord)])

        #expect(segment == nil)
    }

    @Test
    func segment_init_failure_nestedChordInTag() {
        let innerNote = makeNote(makePitch(.c, 4),
                                 makeDuration(1, 4))
        let innerSegment = makeChordSegment([.note(innerNote)])
        let innerChord = makeChord([innerSegment])
        let tag = makeTag(makeTagName("slur"), body: [.chord(innerChord)])
        let segment = GMNChord.Segment(symbols: [.tag(tag)])

        #expect(segment == nil)
    }

    @Test
    func segment_init_nilForEmptySymbols() {
        let segment = GMNChord.Segment(symbols: [])

        #expect(segment == nil)
    }

    @Test
    func segment_init_success() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let segment = GMNChord.Segment(symbols: [.note(note)])

        #expect(segment != nil)
        #expect(segment?.symbols.count == 1)
    }

    @Test
    func segment_init_success_withTag() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let tag = makeTag(makeTagName("accent"), body: [.note(note)])
        let segment = GMNChord.Segment(symbols: [.tag(tag)])

        #expect(segment != nil)
    }
}
