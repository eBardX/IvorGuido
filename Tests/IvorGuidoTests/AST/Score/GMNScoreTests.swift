// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNScoreTests {
}

// MARK: -

extension GMNScoreTests {
    @Test
    func `init`() {
        let variable = makeVariable("tempo", .integer(120))
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let voice = makeVoice([.note(note)])
        let score = GMNScore(variables: [variable], voices: [voice])

        #expect(score.variables.count == 1)
        #expect(score.variables[0].name == "tempo")
        #expect(score.voices.count == 1)
        #expect(score.voices[0].symbols.count == 1)
    }

    @Test
    func equatable() {
        let voice1 = makeVoice()
        let voice2 = makeVoice()
        let score1 = GMNScore(variables: [], voices: [voice1])
        let score2 = GMNScore(variables: [], voices: [voice2])
        let score3 = GMNScore(variables: [], voices: [])

        #expect(score1 == score2)
        #expect(score1 != score3)
    }

    @Test
    func equatable_ignoresFlags() {
        let voice = makeVoice()
        let variable = makeVariable("tempo", .integer(120))
        let unflagged = GMNScore(variables: [variable], voices: [voice])
        let flagged = GMNScore(variables: [variable],
                               voices: [voice],
                               isNormalized: true,
                               isValidated: true)

        #expect(unflagged == flagged)
    }

    @Test
    func init_empty() {
        let score = GMNScore(variables: [], voices: [])

        #expect(score.variables.isEmpty)
        #expect(score.voices.isEmpty)
    }

    @Test
    func init_multipleVoices() {
        let voice1 = makeVoice([.rest(makeRest(makeDuration(1, 4)))])
        let voice2 = makeVoice([.rest(makeRest(makeDuration(1, 8)))])
        let score = GMNScore(variables: [], voices: [voice1, voice2])

        #expect(score.voices.count == 2)
        #expect(score.voices[0] != score.voices[1])
    }

    @Test
    func init_publicInit_flagsAreFalse() {
        let score = GMNScore(variables: [], voices: [])

        #expect(!score.isNormalized)
        #expect(!score.isValidated)
    }
}
