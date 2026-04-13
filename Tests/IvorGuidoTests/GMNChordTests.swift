// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNChordTests {
}

// MARK: -

extension GMNChordTests {
    @Test
    func equatable() throws {
        let note1 = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(letter: .e, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let seg1 = try #require(GMNChord.Segment(symbols: [.note(note1)]))
        let seg2 = try #require(GMNChord.Segment(symbols: [.note(note2)]))
        let chord1 = GMNChord(segments: [seg1])
        let chord2 = GMNChord(segments: [seg1])
        let chord3 = GMNChord(segments: [seg2])

        #expect(chord1 == chord2)
        #expect(chord1 != chord3)
    }

    @Test
    func `init`() throws {
        let note = GMNNote(pitch: GMNPitch(letter: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let segment = try #require(GMNChord.Segment(symbols: [.note(note)]))
        let chord = GMNChord(segments: [segment])

        #expect(chord.segments.count == 1)
        #expect(chord.segments[0].symbols.count == 1)
    }

    @Test
    func init_emptySegments() {
        let chord = GMNChord(segments: [])

        #expect(chord.segments.isEmpty)
    }

    @Test
    func init_multipleSegments() throws {
        let note1 = GMNNote(pitch: GMNPitch(letter: .c,
                                            accidental: .natural,
                                            octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(letter: .e,
                                            accidental: .natural,
                                            octave: 4),
                            duration: fdur(1, 4))
        let seg1 = try #require(GMNChord.Segment(symbols: [.note(note1)]))
        let seg2 = try #require(GMNChord.Segment(symbols: [.note(note2)]))
        let chord = GMNChord(segments: [seg1, seg2])

        #expect(chord.segments.count == 2)
    }

    @Test
    func segment_equatable() throws {
        let note1 = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(letter: .e, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let seg1 = try #require(GMNChord.Segment(symbols: [.note(note1)]))
        let seg2 = try #require(GMNChord.Segment(symbols: [.note(note1)]))
        let seg3 = try #require(GMNChord.Segment(symbols: [.note(note2)]))

        #expect(seg1 == seg2)
        #expect(seg1 != seg3)
    }

    @Test
    func segment_init_failure_nestedChord() throws {
        let innerNote = GMNNote(pitch: GMNPitch(letter: .c,
                                                accidental: .natural,
                                                octave: 4),
                                duration: fdur(1, 4))
        let innerSegment = try #require(GMNChord.Segment(symbols: [.note(innerNote)]))
        let innerChord = GMNChord(segments: [innerSegment])
        let segment = GMNChord.Segment(symbols: [.chord(innerChord)])

        #expect(segment == nil)
    }

    @Test
    func segment_init_failure_nestedChordInTag() throws {
        let innerNote = GMNNote(pitch: GMNPitch(letter: .c,
                                                accidental: .natural,
                                                octave: 4),
                                duration: fdur(1, 4))
        let innerSegment = try #require(GMNChord.Segment(symbols: [.note(innerNote)]))
        let innerChord = GMNChord(segments: [innerSegment])
        let tag = GMNTag(name: "\\slur",
                         ident: nil,
                         parameters: [],
                         symbols: [.chord(innerChord)])
        let segment = GMNChord.Segment(symbols: [.tag(tag)])

        #expect(segment == nil)
    }

    @Test
    func segment_init_success() {
        let note = GMNNote(pitch: GMNPitch(letter: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let segment = GMNChord.Segment(symbols: [.note(note)])

        #expect(segment != nil)
        #expect(segment?.symbols.count == 1)
    }

    @Test
    func segment_init_success_withTag() {
        let note = GMNNote(pitch: GMNPitch(letter: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let tag = GMNTag(name: "\\accent",
                         ident: nil,
                         parameters: [],
                         symbols: [.note(note)])
        let segment = GMNChord.Segment(symbols: [.tag(tag)])

        #expect(segment != nil)
    }
}
