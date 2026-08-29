// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// `Checker` walks; `SchemaChecker` judges. These cases are about the walk, so
// each one hides the same defect somewhere different and expects it to be
// found — `\slur` is `rangesetting ONLY`, so a `\slur` with no body is the
// smallest issue that can be planted anywhere.
//
// FLIPPED IN PHASE 3. Five of these used to plant an undeclared `$variable`
// instead. That is now `GMNParser.Error.unresolvableVariableReference`, thrown
// where guidolib `YYABORT`s, so the traversal it was exercising had to be
// re-stated over the issues that remain. `GMNParserVariableReferenceTests`
// covers the same five positions on the parser side.
struct GMNValidatorCheckerTests {
}

// MARK: -

extension GMNValidatorCheckerTests {
    @Test
    func checkScore_reachesAVoiceSymbol() {
        let voice = makeVoice([.tag(makeTag(makeTagName("slur")))])
        let score = makeScore([], [voice])
        var checker = GMNValidator.Checker(score: score)

        #expect(checker.checkScore() == [.missingTagBody(makeTagName("slur"))])
    }

    @Test
    func checkScore_reachesInsideAChordSegment() {
        let segment = makeChordSegment([.tag(makeTag(makeTagName("slur")))])
        let chord = makeChord([segment])
        let voice = makeVoice([.chord(chord)])
        let score = makeScore([], [voice])
        var checker = GMNValidator.Checker(score: score)

        #expect(checker.checkScore() == [.missingTagBody(makeTagName("slur"))])
    }

    @Test
    func checkScore_reachesInsideATagBody() {
        let tag = makeTag(makeTagName("beam"),
                          body: [.tag(makeTag(makeTagName("slur")))])
        let voice = makeVoice([.tag(tag)])
        let score = makeScore([], [voice])
        var checker = GMNValidator.Checker(score: score)

        // The outer `\beam` is `ONLY` too, and it has a body, so the only
        // issue is the inner one.
        #expect(checker.checkScore() == [.missingTagBody(makeTagName("slur"))])
    }

    @Test
    func checkScore_reachesInsideAVariablesOwnBody() {
        // The stashed pre-parse fragment: `$a`'s body is itself GMN, and a
        // defect written there is as real as one written in a voice.
        let variable = makeVariable("a",
                                    .string("\\slur"),
                                    [.tag(makeTag(makeTagName("slur")))])
        let score = makeScore([variable], [makeVoice()])
        var checker = GMNValidator.Checker(score: score)

        #expect(checker.checkScore() == [.missingTagBody(makeTagName("slur"))])
    }

    @Test
    func checkScore_resolvableReferenceIsNotTheCheckersBusiness() {
        // A `$variable` reference reaches here having already been answered
        // by the parser, and splicing it in is not this checker's job, so the
        // walk passes over both positions without looking.
        let variable = makeVariable("seq", .string("c d e"))
        let voice = makeVoice([.variable("seq")])
        let score = makeScore([variable], [voice])
        var checker = GMNValidator.Checker(score: score)

        #expect(checker.checkScore().isEmpty)
    }

    @Test
    func checkScore_unknownTagName_noIssue() {
        // Unknown tag names are never an issue — guidolib accepts any
        // syntactically valid tag name via a no-op `ARTDummy` fallback
        // (`ARFactory.cpp:1634`).
        let tag = makeTag(makeTagName("notARealGuidoTag"))
        let voice = makeVoice([.tag(tag)])
        let score = makeScore([], [voice])
        var checker = GMNValidator.Checker(score: score)

        #expect(checker.checkScore().isEmpty)
    }
}
