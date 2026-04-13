// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNScoreTests {
}

// MARK: -

extension GMNScoreTests {
    @Test
    func equatable() {
        let voice1 = GMNVoice(symbols: [])
        let voice2 = GMNVoice(symbols: [])
        let score1 = GMNScore(variables: [], voices: [voice1])
        let score2 = GMNScore(variables: [], voices: [voice2])
        let score3 = GMNScore(variables: [], voices: [])

        #expect(score1 == score2)
        #expect(score1 != score3)
    }

    @Test
    func `init`() {
        let variable = GMNVariable(name: "$tempo", value: .integer(120))
        let note = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                           duration: fdur(1, 4))
        let voice = GMNVoice(symbols: [.note(note)])
        let score = GMNScore(variables: [variable], voices: [voice])

        #expect(score.variables.count == 1)
        #expect(score.variables[0].name == "$tempo")
        #expect(score.voices.count == 1)
        #expect(score.voices[0].symbols.count == 1)
    }

    @Test
    func init_empty() {
        let score = GMNScore(variables: [], voices: [])

        #expect(score.variables.isEmpty)
        #expect(score.voices.isEmpty)
    }

    @Test
    func init_multipleVoices() {
        let voice1 = GMNVoice(symbols: [.rest(GMNRest(duration: fdur(1, 4)))])
        let voice2 = GMNVoice(symbols: [.rest(GMNRest(duration: fdur(1, 8)))])
        let score = GMNScore(variables: [], voices: [voice1, voice2])

        #expect(score.voices.count == 2)
        #expect(score.voices[0] != score.voices[1])
    }
}
