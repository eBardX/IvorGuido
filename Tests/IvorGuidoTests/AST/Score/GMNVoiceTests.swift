// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNVoiceTests {
}

// MARK: -

extension GMNVoiceTests {
    @Test
    func `init`() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let voice = GMNVoice(symbols: [.note(note)])

        #expect(voice.symbols.count == 1)
    }

    @Test
    func equatable() {
        let note1 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let note2 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let voice1 = GMNVoice(symbols: [.note(note1)])
        let voice2 = GMNVoice(symbols: [.note(note2)])
        let voice3 = GMNVoice(symbols: [])

        #expect(voice1 == voice2)
        #expect(voice1 != voice3)
    }

    @Test
    func init_empty() {
        let voice = GMNVoice(symbols: [])

        #expect(voice.symbols.isEmpty)
    }
}
