// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

struct GMNValidatorTests {
}

// MARK: -

extension GMNValidatorTests {
    @Test
    func validate_alreadyValidated_shortCircuits() throws {
        let score = makeScore([], [makeVoice()])
        let (normalized, _) = GMNNormalizer().normalize(score)
        let (validated, _) = try GMNValidator().validate(normalized)
        let (again, issues) = try GMNValidator().validate(validated)

        #expect(again.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_anyIssueLeavesIsValidatedFalse() throws {
        // FLIPPED IN PHASE 4, and this is the assertion the phase exists for.
        // It read `validate_everyIssueStillValidates`: nothing blocked, so a
        // score came back validated whatever it carried. There is no grading
        // now — being an issue is what makes an issue fatal.
        let (validated, issues) = try validate("[ \\slur ]")

        #expect(issues == [.missingTagBody(makeTagName("slur"))])
        #expect(!validated.isValidated)
    }

    @Test
    func validate_normalizedScore_flipsIsValidated() throws {
        let score = makeScore([], [makeVoice()])
        let (normalized, _) = GMNNormalizer().normalize(score)
        let (validated, issues) = try GMNValidator().validate(normalized)

        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_notNormalized_throws() {
        let score = makeScore([], [makeVoice()])

        #expect(throws: GMNValidator.Error.notNormalized) {
            try GMNValidator().validate(score)
        }
    }

    @Test
    func validate_resolvableVariableReference_validatesClean() throws {
        let (validated, issues) = try validate("$seq = \"c d e\"; [ $seq ]")

        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_unknownTagName_validatesClean() throws {
        let (validated, issues) = try validate("[ \\notARealGuidoTag c ]")

        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }
}
