// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNValidatorIssueTests {
}

// MARK: -

extension GMNValidatorIssueTests {
    @Test
    func equatable() {
        let a = GMNValidator.Issue.missingTagBody("slur")
        let b = GMNValidator.Issue.missingTagBody("slur")
        let c = GMNValidator.Issue.missingTagBody("beam")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func equatable_parameterIssues() {
        let name = makeTagName("slur")
        let other = makeTagName("tie")

        #expect(GMNValidator.Issue.unreadableParameterValue(name)
                == .unreadableParameterValue(name))
        #expect(GMNValidator.Issue.unreadableParameterValue(name)
                != .unreadableParameterValue(other))
        #expect(GMNValidator.Issue.missingRequiredParameter(name, "dx")
                != .unreadableParameterValue(name))
        #expect(GMNValidator.Issue.unboundPositionalParameter(name, index: 0)
                != .unboundPositionalParameter(name, index: 1))
    }

    @Test
    func everythingBlocks() throws {
        // FLIPPED IN PHASE 4, replacing `nothingBlocks`. There is no
        // `isBlocking` to ask any more: an issue is fatal by being an issue,
        // so the question is only answerable through `validate(_:)`.
        for input in ["[\\slur c]",
                      "[\\title<\"Prelude\">(c)]"] {
            let (validated, issues) = try GMNValidator().validate(normalizeScore(input))

            #expect(!issues.isEmpty,
                    Comment(rawValue: input))
            #expect(!validated.isValidated,
                    Comment(rawValue: input))
        }
    }

    @Test
    func message_missingRequiredParameter() {
        let issue = GMNValidator.Issue.missingRequiredParameter(makeTagName("accolade"),
                                                                GMNTag.Parameter.Name("id"))

        #expect(issue.message == "Missing required parameter ‘id’ on tag ‘\\accolade’")
    }

    @Test
    func message_missingTagBody() {
        let issue = GMNValidator.Issue.missingTagBody("slur")

        #expect(issue.message.contains("\\slur"))
    }

    @Test
    func message_unboundPositionalParameter() {
        // The index is reported one-based, because it names a written
        // parameter rather than an array slot.
        let issue = GMNValidator.Issue.unboundPositionalParameter(makeTagName("slur"),
                                                                  index: 2)

        #expect(issue.message == "Parameter 3 of tag ‘\\slur’ binds to no template slot")
    }

    @Test
    func message_unexpectedTagBody() {
        let issue = GMNValidator.Issue.unexpectedTagBody("composer")

        #expect(issue.message.contains("\\composer"))
    }

    @Test
    func message_unreadableParameterValue() {
        let issue = GMNValidator.Issue.unreadableParameterValue(makeTagName("slur"))

        #expect(issue.message == "Unreadable parameter value on tag ‘\\slur’")
    }
}
