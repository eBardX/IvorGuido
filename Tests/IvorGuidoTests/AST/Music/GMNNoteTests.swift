// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNNoteTests {
}

// MARK: -

extension GMNNoteTests {
    @Test
    func `init`() {
        let pitch = makePitch(.c, .sharp, 5)
        let duration = makeDuration(1, 8)
        let note = GMNNote(pitch: pitch, duration: duration)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
    }

    @Test
    func equatable() {
        let note1 = GMNNote(pitch: makePitch(.c, 4),
                            duration: makeDuration(1, 4))
        let note2 = GMNNote(pitch: makePitch(.c, 4),
                            duration: makeDuration(1, 4))
        let note3 = GMNNote(pitch: makePitch(.d, 4),
                            duration: makeDuration(1, 4))

        #expect(note1 == note2)
        #expect(note1 != note3)
    }

    @Test
    func init_differentDurations() {
        let pitch = makePitch(.e, 4)
        let note1 = GMNNote(pitch: pitch, duration: makeDuration(1, 4))
        let note2 = GMNNote(pitch: pitch, duration: makeDuration(500))
        let note3 = GMNNote(pitch: pitch, duration: makeDuration(1, 4, dots: 1))

        #expect(note1.duration != note2.duration)
        #expect(note1.duration != note3.duration)
    }
}
