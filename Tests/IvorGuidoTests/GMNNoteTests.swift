// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNNoteTests {
}

// MARK: -

extension GMNNoteTests {
    @Test
    func equatable() {
        let note1 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note3 = GMNNote(pitch: GMNPitch(name: .d, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))

        #expect(note1 == note2)
        #expect(note1 != note3)
    }

    @Test
    func `init`() {
        let pitch = GMNPitch(name: .c, accidental: .sharp, octave: 5)
        let duration = fdur(1, 8)
        let note = GMNNote(pitch: pitch, duration: duration)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
    }

    @Test
    func init_differentDurations() {
        let pitch = GMNPitch(name: .e, accidental: .natural, octave: 4)
        let note1 = GMNNote(pitch: pitch, duration: fdur(1, 4))
        let note2 = GMNNote(pitch: pitch, duration: mdur(500))
        let note3 = GMNNote(pitch: pitch, duration: fdur(1, 4, 1))

        #expect(note1.duration != note2.duration)
        #expect(note1.duration != note3.duration)
    }
}
