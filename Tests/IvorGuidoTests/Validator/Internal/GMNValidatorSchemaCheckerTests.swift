// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// `SchemaChecker`'s two halves: the `rangesetting`/body contract, and the
// three parameter cases of `GMNValidator.Issue` — mechanisms 4, 8, and 9 —
// which lived in `GMNNormalizer.Rejector` until the normalizer was made
// total.
//
// A parameter is either repaired before validation (`GMNNormalizer.Editor`)
// or judged by the parameter half below; what the body half judges is a
// tag's *body*, which no repair can settle: repairing it would mean
// inventing or discarding music.
//
// The parameter judgement is not a parse-time rejection: it has to fire on
// the *normalized* shape, or a score gets refused for a defect the
// normalizer would have repaired. `\volta<m="1.">` settles it. `mark` is
// required, the tag supplies it under the name guidolib renamed in 1.5.5,
// and a parse-time `checkRequired` would refuse a score that is merely
// denormalized. So the check runs in `GMNValidator`, which takes a
// normalized score by construction, on what the repair chain produced. The
// `repairFirst` section below is the half that makes the placement
// load-bearing rather than incidental — every case there is one a
// parser-side check would have refused. The normalizer itself no longer
// refuses anything: it repairs, and the defects it cannot repair travel to
// the validator on an untyped lane.
//
// The body issues are ones guidolib merely warns about, and both are fatal
// all the same. `aScoreWithIssuesDoesNotFormat` asserts that directly,
// because it is the property easiest to break by accident.
struct GMNValidatorSchemaCheckerTests {
}

// MARK: -

extension GMNValidatorSchemaCheckerTests {
    @Test
    func aBareSpanEndIsNotReported() throws {
        #expect(try issues("[\\beamBegin c d \\beamEnd]").isEmpty)
    }

    @Test
    func aBodyOnATagThatTakesNoneIsReported() throws {
        #expect(try issues("[\\title<\"Prelude\">(c)]") == [.unexpectedTagBody(makeTagName("title"))])
    }

    @Test
    func aMissingBodyOnATagThatRequiresOneIsReported() throws {
        #expect(try issues("[\\beam c]") == [.missingTagBody(makeTagName("beam"))])
    }

    @Test
    func anOpenSpanIsNotReportedForHavingNoBody() throws {
        // The half of the check that would otherwise fire on every
        // well-formed open span in the corpus: `\beamBegin` shares
        // `\beam`'s `ONLY` template, and neither half can carry a body by
        // construction.
        #expect(try issues("[\\beamBegin:1 c d \\beamEnd:1]").isEmpty)
    }

    @Test
    func anUndispatchedNameIsNeverRejected() throws {
        // No template, so nothing to judge against — and guidolib accepts the
        // name and builds an `ARTDummy` for it (`ARFactory.cpp:1636–1640`),
        // so there is no defect to report.
        #expect(try issues("[\\bembel<\"a\",\"b\",\"c\",\"d\",\"e\"> c]").isEmpty)
    }

    @Test
    func anUndispatchedNameIsNotReported() throws {
        // No template, so nothing to check against — and guidolib builds an
        // `ARTDummy` for the name rather than complaining, so there is no
        // defect to report.
        #expect(try issues("[\\bembel<bogus=1> c]").isEmpty)
    }

    @Test
    func anUnsupportedParameterIsNotReported() throws {
        // `checkExist` is repaired, not reported: the normalizer drops the
        // parameter and the tag promotes, so nothing reaches the validator.
        #expect(try issues("[\\beam<bogus=1>(c d)]").isEmpty)
    }

    @Test
    func aRangeCapableTagIsNotReportedEitherWay() throws {
        // `RANGEDC` — `\octava` is legal both ways, so neither form is an
        // issue.
        #expect(try issues("[\\octava<1> c]").isEmpty)
        #expect(try issues("[\\octava<1>(c d)]").isEmpty)
    }

    @Test
    func aScoreWithIssuesDoesNotFormat() throws {
        // FLIPPED IN PHASE 4, and it is the assertion this plan exists to
        // reverse. It read `aScoreWithIssuesStillFormats` on the argument
        // that guidolib warns on a `rangesetting` mismatch and renders the
        // score anyway — true of guidolib, and not what this library is for.
        // Formatting requires a validated score, and an issue is now enough
        // to withhold that.
        let (parsed, _) = try GMNParser().parse(Data("[\\slur c]".utf8))
        let (normalized, _) = GMNNormalizer().normalize(parsed)
        let (validated, issues) = try GMNValidator().validate(normalized)

        #expect(!issues.isEmpty)
        #expect(!validated.isValidated)

        #expect(throws: GMNFormatter.Error.notValidated) {
            try GMNFormatter().format(validated)
        }
    }

    @Test
    func aSpanEndIsNeverReported() throws {
        // A closing half has no schema to check against — its range setting
        // is the shared one — and a parameter written there is repaired by
        // the normalizer rather than reported here.
        #expect(try issues("[\\beamBegin c d \\beamEnd<dx=2hs>]").isEmpty)
    }

    @Test
    func everyPayloadRestatesItsRequiredParametersFaithfully() throws {
        // The check that keeps the typed lane honest. A payload reports its
        // parameters through `namedParameters`, which is what the validator
        // binds; if a payload could not hold something its template requires,
        // the round trip would lose it and a score the parser had just
        // accepted would fail validation.
        //
        // Asserted against the binding rather than through `SchemaChecker` —
        // the binding is what the requiredness check reads, and going straight
        // to it says which payload is at fault when one is.
        for name in GMNTagTemplate.Registry.names.sorted() {
            let tagName = try #require(GMNTag.Name(stringValue: name))
            let tag = makePromotedTag(name, parameters: requiredParameters(tagName))
            let parameters = tag.payload.namedParameters
            let template = try #require(GMNTagTemplate.Registry.template(for: tagName,
                                                                         parameters: parameters))
            let binding = GMNTagBinder.bind(parameters,
                                            to: template)

            #expect(binding.missingRequiredParameterNames.isEmpty,
                    Comment(rawValue: "\\\(name): \(binding.missingRequiredParameterNames)"))

            // The other half of the round trip. `checkExist` is not an `Issue`
            // — the normalizer drops an unsupported parameter — so a
            // payload that restated a parameter its own template does not
            // support would otherwise go unnoticed, and silently lose it to
            // the repair.
            #expect(binding.unsupportedParameterNames.isEmpty,
                    Comment(rawValue: "\\\(name): \(binding.unsupportedParameterNames)"))
        }
    }

    @Test
    func everythingReachingTheValidatorBlocks() throws {
        // FLIPPED IN PHASE 4, replacing `nothingReachingTheValidatorBlocks`.
        // The two remaining issues are a `\slur` scoping nothing and a
        // `\title` scoping something; both now withhold validation.
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
    func mechanism4_aFullButNotOverfullListIsAccepted() throws {
        // The boundary. `kARMeterParams` has five slots and five positionals
        // fill them exactly.
        #expect(try issues("[\\meter<\"4/4\",\"on\",\"off\",\"off\",\"off\"> c]").isEmpty)
    }

    @Test
    func mechanism4_aNamedParameterStillConsumesItsSlot() throws {
        // The detail that makes this catchable at all. The index guidolib
        // uses for an unnamed parameter is its position in the *written*
        // list, not a running count of the unnamed ones, so a named parameter
        // pushes everything after it along.
        #expect(try issues("[\\clef<type=\"treble\",\"bogus\"> c]")
                == [.unboundPositionalParameter(makeTagName("clef"),
                                                index: 1)])
    }

    @Test
    func mechanism4_excessPositionals_areRejected() throws {
        // The author lost track of the template, and guidolib silently
        // discards from the first unbound
        // parameter onward (`ARMusicalTag.cpp:101–104`), so four of the nine
        // written parameters vanish without a word. `kARMeterParams` has five
        // slots, so binding stops at written position 5.
        #expect(try issues("[\\meter<\"4/4\",1,2,3,4,5,6,7,8> c]")
                == [.unboundPositionalParameter(makeTagName("meter"),
                                                index: 5)])
    }

    @Test
    func mechanism8_aHandBuiltTagIsJudgedByTheSameRule() throws {
        // Both lanes through one code path. A payload restates its parameters
        // explicitly named, so a score built by hand binds against the same
        // template a written one does — which is what stops the rejection
        // being bypassable by not going through the parser.
        let tag = makeTag(makeTagName("clef"))
        let score = makeScore([], [makeVoice([.tag(tag)])])

        let (normalized, _) = GMNNormalizer().normalize(score)
        let (validated, issues) = try GMNValidator().validate(normalized)

        #expect(issues == [.missingRequiredParameter(makeTagName("clef"), "type")])
        #expect(!validated.isValidated)
    }

    @Test
    func mechanism8_aMissingRequiredParameter_isRejected() throws {
        #expect(try issues("[\\clef c]")
                == [.missingRequiredParameter(makeTagName("clef"), "type")])
    }

    @Test
    func mechanism8_aPositionalOverwritingARequiredParameter_isRejected() throws {
        // The valuable one. `"Allegro"` is written second, so it binds to
        // slot 1 — `bpm` — overwriting the bpm that *was* written and leaving
        // required `tempo` with nothing. guidolib warns and renders a tempo
        // mark with no tempo in it; rejecting improves on that.
        #expect(try issues("[\\tempo<bpm=\"1/4=120\",\"Allegro\"> c]")
                == [.missingRequiredParameter(makeTagName("tempo"), "tempo")])
    }

    @Test(arguments: ["[\\slur<curve=\"banana\">(c d)]",
                      "[\\accent<position=\"banana\">(c)]"])
    func mechanism9_aValueOutsideAClosedVocabulary_isRejected(_ input: String) throws {
        // The residual: everything binds, nothing is ill-typed, and the
        // builder still refused — because the *value* is one the tag's own
        // class does not recognize. guidolib substitutes its own default and
        // renders, discarding what was written.
        #expect(try !issues(input).isEmpty)
    }

    @Test
    func mechanism9_isTheResidualAndNotAnyOldGenericTag() throws {
        // Being generic proves nothing on its own, which is why
        // `GMNTagPromoter.isUnreadable(_:)` runs promotion rather than
        // reasoning about it. `\key<2>` is generic for a reason the model
        // accounts for — `ARKey` reads `key` under two types — and a name no
        // payload claims is generic by design.
        for input in ["[\\key<2> c]",
                      "[\\DrHoos<inverse=1> c]",
                      "[\\port c]",
                      "[\\bembel<bogus=1> c]"] {
            #expect(try issues(input).isEmpty,
                    Comment(rawValue: input))
        }
    }

    @Test
    func mechanism9_namesTheTagAndNotTheParameter() throws {
        #expect(try issues("[\\slur<curve=\"banana\">(c d)]")
                == [.unreadableParameterValue(makeTagName("slur"))])
    }

    @Test
    func onlyTwoKindsOfTagAreStillGenericAfterNormalization() throws {
        // The invariant the three rejections buy, stated over the whole
        // registry rather than as a comment. Every dispatched name promotes
        // once its required parameters are supplied, except the three no
        // payload claims — so `GMNTag.generic(_:)` now means either "guidolib
        // does not dispatch this name" or "one of those three", and nothing
        // else.
        //
        // `GMNTag` splits this into `.reserved` and `.custom`; it is
        // asserted here because these rejections are what make it true.
        for name in GMNTagTemplate.Registry.names.sorted() {
            let tagName = try #require(GMNTag.Name(stringValue: name))
            let tag = makePromotedTag(name, parameters: requiredParameters(tagName))

            guard tag.untypedPayload != nil
            else { continue }

            #expect(GMNTagPromoter.namesWithoutPayload.contains(name),
                    Comment(rawValue: "\\\(name) is dispatched but did not promote"))
        }
    }

    @Test
    func repairFirst_anAliasIsNamedByItsCanonicalSpelling() throws {
        // The rejection reads the canonicalized name, so the error says
        // `\slur` for a tag written `\sl`. Reporting the alias would name a
        // template the reader would have to translate first.
        #expect(try issues("[\\sl<curve=\"banana\">(c d)]")
                == [.unreadableParameterValue(makeTagName("slur"))])
    }

    @Test
    func repairFirst_anExpandedVariableIsJudgedAfterSubstitution() throws {
        // And mechanism 9 from that angle: the value the builder refuses is
        // not one that was written anywhere. `varParam` substitutes before
        // `ARFactory` is reached, so this is guidolib's own reading order.
        #expect(try issues("$x = \"banana\"; [\\slur<curve=$x>(c d)]")
                == [.unreadableParameterValue(makeTagName("slur"))])
    }

    @Test
    func repairFirst_anInertParameterGoesBeforeRequirednessIsJudged() throws {
        // `\accolade`'s `id` is required, and a string written there is inert
        // — `ARStaff` is the only class that reads `id` under two types. So
        // the drop is what *creates* the defect, and the order still has to
        // be repair-then-judge: judging first would have accepted a tag
        // guidolib reads as having no id at all (`GRAccolade.cpp:90–95`
        // defaults it to `0`).
        #expect(try issues("[\\accolade<id=\"brace\",range=\"1-2\"> c]")
                == [.missingRequiredParameter(makeTagName("accolade"), "id")])
    }

    @Test
    func repairFirst_aRenamedParameterSatisfiesRequiredness() throws {
        // The case that settles where the check belongs. `ARVolta::getMark()`
        // looks up only `mark`, which is required; `m` is what guidolib
        // called it before 1.5.5. As written the tag is missing a required
        // parameter, and a parse-time `checkRequired` would refuse a score
        // the normalizer repairs one step later.
        let (normalized, _) = try normalizedScoreAndChanges("[\\volta<m=\"1.\">(c)]")

        guard case let .tag(.volta(volta)) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected the repaired \\volta to promote")

            return
        }

        #expect(volta.mark == "1.")
    }

    @Test
    func repairFirst_aSpanEndCannotOverrunATemplateItNoLongerUses() throws {
        // Mechanism 4 from the same angle. `\beamEnd`'s template is the
        // shared range-end one, so five positionals overrun it as written —
        // and the whole list is dropped before anything judges it.
        let (_, changes) = try normalizedScoreAndChanges("[\\beamBegin c d \\beamEnd<1,2,3,4,5>]")

        #expect(changes.contains { $0 == .droppedSpanEndParameters(makeTagName("beamEnd")) })
    }
}
