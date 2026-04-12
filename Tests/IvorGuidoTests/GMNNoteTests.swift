// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNNoteTests {
}

// MARK: -

extension GMNNoteTests {
    @Test
    func test_equatable() {
        let note1 = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                            duration: .fraction(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                            duration: .fraction(1, 4))
        let note3 = GMNNote(pitch: GMNPitch(letter: .d, accidental: .natural, octave: 4),
                            duration: .fraction(1, 4))

        #expect(note1 == note2)
        #expect(note1 != note3)
    }

    @Test
    func test_init() {
        let pitch = GMNPitch(letter: .c, accidental: .sharp, octave: 5)
        let duration = GMNDuration.fraction(1, 8)
        let note = GMNNote(pitch: pitch, duration: duration)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
    }

    @Test
    func test_init_differentDurations() {
        let pitch = GMNPitch(letter: .e, accidental: .natural, octave: 4)
        let note1 = GMNNote(pitch: pitch, duration: .fraction(1, 4))
        let note2 = GMNNote(pitch: pitch, duration: .milliseconds(500))
        let note3 = GMNNote(pitch: pitch, duration: .fractionDots(1, 4, 1))

        #expect(note1.duration != note2.duration)
        #expect(note1.duration != note3.duration)
    }
}
