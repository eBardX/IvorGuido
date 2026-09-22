// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// A characterization suite for nine distinct mechanisms that can leave a
// **known** tag name untyped after normalization — a name guidolib
// dispatches, that IvorGuido nonetheless fails to promote to a typed
// payload. Each `mechanismN_…` case exercises one mechanism and pins the
// current disposition (repaired, rejected, modelled, or left as a
// deliberately reserved lane); the surrounding comment explains why.
//
// Measured 2026-08-03 by running `parse → normalize → validate` over each
// input.
struct GMNNormalizerTests {
}

// MARK: -

extension GMNNormalizerTests {
    @Test
    func aHandBuiltScoreReachesAPathTheParserRefuses() throws {
        // `[$x]` with `$x = 1` is `GMNParser.Error.nonSymbolVariableReference`
        // — a bare `42` is not a symbol on guidolib's lexer stream either —
        // but the same score built by hand walks the whole pipeline
        // unremarked, because nothing downstream of the parser re-checks it.
        //
        // This is a cross-node invariant enforced by the stage that mints
        // the score, and this one is enforced by a stage a hand-built score
        // never passes through. `UsingIvorGuido.md` is where that limit is
        // said out loud.
        #expect(throws: GMNParser.Error.nonSymbolVariableReference("x")) {
            try GMNParser().parse(Data("$x = 1; [$x]".utf8))
        }

        let variable = makeVariable("x", .integer(1))
        let voice = makeVoice([.variable("x")])
        let score = makeScore([variable], [voice])
        let (normalized, changes) = GMNNormalizer().normalize(score)
        let (validated, issues) = try GMNValidator().validate(normalized)

        #expect(changes.isEmpty)
        #expect(issues.isEmpty)
        #expect(validated.isValidated)
    }

    @Test
    func aRedeclaredVariableKeepsBothDeclarations() throws {
        // guidolib's `fEnv` is a map and the second declaration wins
        // outright; our AST keeps both, and we agree with guidolib only by
        // accident, because the checker happens to build its own lookup
        // dictionary last-wins.
        //
        // Mechanism 6's substitution had to decide what a redeclared name
        // resolves to, and answered last-wins, matching `fEnv`. The two
        // declarations still both survive into the formatted text —
        // see `mechanism6_aLastDeclarationWins` for the other half.
        let (parsed, _) = try GMNParser().parse(Data("$x = 1; $x = 2; [c]".utf8))
        let (normalized, changes) = GMNNormalizer().normalize(parsed)

        #expect(normalized.variables.count == 2)
        #expect(normalized.variables.map(\.value) == [.integer(1),
                                                      .integer(2)])
        #expect(changes.isEmpty)

        #expect(try canonicalize("$x = 1; $x = 2; [c]") == "$x = 1;\n$x = 2;\n[c]")
    }

    @Test
    func mechanism1_aNameWithNoPayload_isReservedAndSaysSo() throws {
        // The tag lands on `.reserved`, and there is no lane it could land
        // on that would fail to say why: `.custom` refuses a dispatched name
        // at its initializer. It stays diagnostic-free by design — there is
        // nothing wrong with `\DrHoos<inverse=1>` to report — the lane
        // itself is the report.
        //
        // `\port<1>` is not usable as an example here: `\port` is one of the
        // six `acceptsParameters: false` names, so its `1` is dropped and
        // recorded, reading as mechanism 2's case instead. `\DrHoos`
        // isolates this mechanism — the name is dispatched, the parameter
        // binds cleanly, and the tag is untyped for the one reason this row
        // is about: no payload claims it.
        let (tag, changes, issues) = try runPipeline("[\\DrHoos<inverse=1> c]")

        #expect(isReserved(tag))
        #expect(changes.isEmpty)
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism1_appliesToAllThreeNamesWithoutPayload() throws {
        // All three route to `.reserved`.
        //
        // The set is read from `GMNTagPromoter.namesWithoutPayload` rather
        // than restated, so that a name joining or leaving it is caught here
        // rather than silently narrowing the row.
        for name in GMNTagPromoter.namesWithoutPayload.sorted() {
            let (tag, changes, issues) = try runPipeline("[\\\(name) c]")

            #expect(isReserved(tag),
                    Comment(rawValue: "\\\(name)"))
            #expect(changes.isEmpty,
                    Comment(rawValue: "\\\(name)"))
            #expect(issues.isEmpty,
                    Comment(rawValue: "\\\(name)"))
        }
    }

    @Test
    func mechanism2_aParameterOnAClassThatAcceptsNone_isDroppedAndRecorded() throws {
        // `ARFactory::addTagParameter` guards on
        // `dynamic_cast<ARMTParameter*>` (`ARFactory.cpp:2012–2016`), so
        // `\newPage` throws every parameter written to it away before binding
        // ever happens. Nothing reports it by way of `bind`, since it
        // short-circuits on `!template.acceptsParameters` and returns an
        // empty `values`, so `dx` never reaches `unsupportedParameterNames`
        // for the normalizer to drop — the repair is stated separately, as
        // `_dropUnacceptedParameters`.
        let (tag, changes, issues) = try runPipeline("[\\newPage<dx=2hs> c]")

        #expect(!isUntyped(tag))
        #expect(changes == [.droppedUnacceptedParameters(makeTagName("newPage"))])
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism2_leavesAnUnresolvedVariableReferenceAlone() throws {
        // The reference is refused at the parser rather than reported by
        // the validator, so the drop never gets the chance to swallow it.
        //
        // The exemption itself is load bearing: guidolib
        // substitutes a reference before `ARFactory` is reached, so an
        // undeclared name `YYABORT`s whatever tag it was written on —
        // including one that would have thrown the parameter away a moment
        // later. What changed is where that is said.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try GMNParser().parse(Data("[\\newPage<dx=$missing> c]".utf8))
        }
    }

    @Test
    func mechanism2_reachesTheOneNameWithoutAPayloadThatKeepsNoParameters() throws {
        // `\port` is in both rows: it builds an `ARTDummy`, which keeps no
        // parameters *and* has no payload. So the parameter goes and is
        // recorded, and the tag is still reserved — mechanism 1 outliving
        // mechanism 2's repair on the same tag.
        let (tag, changes, issues) = try runPipeline("[\\port<1> c]")

        #expect(isReserved(tag))
        #expect(parameterValues(tag).isEmpty)
        #expect(changes == [.droppedUnacceptedParameters(makeTagName("port"))])
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism3_appliesToAnUndispatchedNameToo() throws {
        // The discard happens in the grammar, below dispatch, so no template
        // is consulted and an unknown tag name is treated the same. `\bembel`
        // stays generic for want of a template, not for want of the repair.
        let (tag, changes, issues) = try runPipeline("[\\bembel<foo> c]")

        #expect(isUntyped(tag))
        #expect(parameterValues(tag).isEmpty)
        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("bembel"), "foo")])
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism3_aRawIdentifierParameter_isDroppedAndRecorded() throws {
        // Generalizes what `_dropSpanEndParameters` had been doing all
        // along. guidolib discards a raw identifier outright —
        // the grammar reduces it to a null parameter (`guido.y:188`) and
        // `GuidoParser::tagParameter` drops nulls before `ARFactory` is
        // called — and `GMNTagPromoter._isRawIdentifier` is what used to stop
        // the tag promoting over it.
        let (tag, changes, issues) = try runPipeline("[\\beam<foo>(c d)]")

        #expect(!isUntyped(tag))
        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("beam"), "foo")])
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism4_excessPositionals_areRejected() throws {
        // The author lost track of the template, and guidolib silently
        // discards from the first unbound parameter onward — `kARMeterParams`
        // has five slots, so four of these nine vanish without a word. All
        // nine used to survive normalization, which is what made the loss
        // invisible: the score round-tripped byte-for-byte and said nothing.
        //
        // **Reported by the validator, not the parser.** A parse-time
        // rejection can't work here: `\volta<m="1.">` is missing a required
        // parameter as written and has one a rename later. Normalization is
        // total and does the rename; judging only becomes possible once
        // every repair has run, which makes it the validator's job, and
        // `GMNValidatorParameterCheckTests` is where the placement is argued.
        let (_, _, issues) = try runPipeline("[\\meter<\"4/4\",1,2,3,4,5,6,7,8> c]")

        #expect(issues == [.unboundPositionalParameter(makeTagName("meter"),
                                                       index: 5)])
    }

    @Test
    func mechanism5_anAmbiguouslyTypedName_isModelled() throws {
        // Modelled, not rejected. `\key<2>` is legal and meaningful: `ARKey`
        // really does read `key` as a string and then as an integer
        // (`ARKey.cpp:88–96`), so this was *our* modelling gap and not bad
        // input. It is the case most worth keeping straight from the
        // rejected ones.
        //
        // Nothing is reported, and that is the point: there was never a defect
        // in the input to report. The tag is simply typed now.
        let (tag, changes, issues) = try runPipeline("[\\key<2> c]")

        guard case let .key(key) = tag
        else {
            Issue.record("Expected key tag")
            return
        }

        #expect(key.key == .number(2))
        #expect(changes.isEmpty)
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism5_anAmbiguouslyTypedParameterIsNoLongerIllTyped() {
        // `key` binds to an `S` slot, so an integer written there once
        // looked ill-typed and the tag could not promote; but `ARKey` reads
        // the name under both types, so the repair had to be forbidden from
        // dropping it too, and a second property subtracted it back out.
        // Ill-typed and undroppable at once was exactly the state that left
        // the tag stranded and silent.
        //
        // Both halves are gone now. The template records the second read
        // (`GMNTagTemplate.alternateParameterKinds`), so the value is not
        // ill-typed in the first place and `illTypedParameterNames` is once
        // again exactly the set the normalizer may drop.
        let binding = makeBinding("key", [makeTagParameter(.integer(2, nil))])

        #expect(binding.isMatched)
        #expect(binding.illTypedParameterNames.isEmpty)
    }

    @Test
    func mechanism5_aNameReadTwiceElsewhereIsStillInertHere() throws {
        // The same correction from the other side. `id` is read under two
        // types by `ARStaff` and by nothing else, so an `\accol` whose `id` is
        // a string loses it — and, `id` being required there, the tag is left
        // short of a required parameter, which is what guidolib makes of it
        // too (`GRAccolade.cpp:90–95` defaults the id to `0`).
        //
        // The missing required parameter the drop leaves behind is one of
        // the defects the validator reports, so the repair and its
        // consequence are visible only together.
        let (_, _, issues) = try runPipeline("[\\accolade<id=\"brace\",range=\"1-2\"> c]")

        #expect(issues == [.missingRequiredParameter(makeTagName("accolade"), "id")])
    }

    @Test
    func mechanism5_theSecondReadIsPerClassAndNotPerName() throws {
        // Re-run per class, the ambiguity grep yields two name/tag pairs,
        // not the four bare names recorded on the property it replaced: `h`
        // and `w` are read by three classes with one type each,
        // `ARAccolade`'s string accessor has no caller, and `ARJump`'s int
        // read is commented out.
        //
        // So `\symbol<file="x",h="tall">` is inert after all, and it is
        // repaired rather than exempted. `h` is optional, so the tag still
        // promotes once the string is gone.
        let (tag, changes, issues) = try runPipeline("[\\symbol<file=\"x\",h=\"tall\"> c]")

        #expect(!isUntyped(tag))
        #expect(changes.count == 1)
        #expect(issues.isEmpty)
    }

    @Test
    func mechanism6_aLastDeclarationWins() throws {
        // `varParam` reads guidolib's `fEnv`, which is a map, so a redeclared
        // name resolves to its last value. The AST keeps both declarations,
        // so the normalizer has to build that agreement rather than inherit
        // it — see
        // `aRedeclaredVariableKeepsBothDeclarations`, which pins the other
        // half.
        let (tag, _, _) = try runPipeline("$x = 1; $x = 2; [\\beam<dy=$x>(c d)]")

        #expect(!isUntyped(tag))

        #expect(try canonicalize("$x = 1; $x = 2; [\\beam<dy=$x>(c d)]")
                    == "$x = 1;\n$x = 2;\n[\\beam<2>(c d)]")
    }

    @Test
    func mechanism6_anUndeclaredReferenceInParameterPositionIsRejected() throws {
        // This is refused at the parser, which is where guidolib puts it:
        // `varParam` `YYABORT`s on a lookup failure. Not one of the nine
        // mechanisms: it is the *reported* neighbour of mechanism 6, and the
        // exemption that keeps a `$variable` from being dropped along with
        // an unsupported name.
        //
        // Unlike the mechanisms the validator reports, this one needs no
        // repair to wait for. Declarations are a prologue only, so a name
        // unanswered at the parser is unanswered for good.
        #expect(throws: GMNParser.Error.unresolvableVariableReference("missing")) {
            try runPipeline("[\\beam<bogus=$missing>(c d)]")
        }
    }

    @Test
    func mechanism6_aVariableInParameterPosition_isExpandedAndRecorded() throws {
        // Substituted by declared type in the normalizer, **without a
        // unit**, matching guidolib's `varParam`.
        //
        // The declaration prologue is complete before any reference
        // (`gmn: score | variables score`), so the substitution is
        // unambiguous; doing it in the parser instead would destroy
        // round-tripping, which is why the declaration is still there in
        // the formatted text below.
        let (tag, changes, issues) = try runPipeline("$x = 1; [\\beam<dy=$x>(c d)]")

        #expect(!isUntyped(tag))
        #expect(changes == [.expandedVariableReference(makeTagName("beam"), "x")])
        #expect(issues.isEmpty)

        #expect(try canonicalize("$x = 1; [\\beam<dy=$x>(c d)]") == "$x = 1;\n[\\beam<1>(c d)]")
    }

    @Test
    func mechanism6_expansionNeverAttachesAUnit() throws {
        // The one detail that makes substitution differ from re-reading the
        // written text: `varParam` switches on the declared type and attaches
        // no unit, even into a `U` slot that would have taken one. `dy` is
        // `U,dy,0,o`, and `2` arrives bare.
        let (parsed, _) = try GMNParser().parse(Data("$x = 2; [\\beam<dy=$x>(c d)]".utf8))
        let (normalized, _) = GMNNormalizer().normalize(parsed)

        guard case let .tag(.beam(beam)) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected a typed beam")

            return
        }

        #expect(beam.appearance.dy == GMNLength(2))
    }

    @Test
    func mechanism7_aUnitOnAFloatingSlot_isDroppedAndRecorded() throws {
        // The unit goes and the magnitude stays.
        //
        // `\size` is not a name guidolib dispatches — `Registry.names` does
        // not contain it — so `[\size<1.5cm>(c d)]` was generic for want of a
        // template, which is nothing to do with this mechanism. `size` is a
        // *parameter*: `F,size,1.0,o` in `kCommonParams`, so every tag has
        // it, and `\beam<size=1.5cm>` is the mechanism as intended.
        //
        // guidolib renders these: a unit is a field on the value rather than
        // a separate class, so the `dynamic_cast` still succeeds, `checkUnit`
        // merely warns, and the class reads `1.5`. An `F` field is a bare
        // `Double` — `size` is a ratio, not a length — so the unit was never
        // going to survive into the payload, and the repair makes that loss
        // explicit and recorded instead of silent and untyped.
        let (tag, changes, issues) = try runPipeline("[\\beam<size=1.5cm>(c d)]")

        #expect(!isUntyped(tag))
        #expect(changes == [.droppedParameterUnit(makeTagName("beam"), "size")])
        #expect(issues.isEmpty)

        #expect(try canonicalize("[\\beam<size=1.5cm>(c d)]") == "[\\beam<size=1.5>(c d)]")
    }

    @Test
    func mechanism7_aUnitOnALengthSlotIsUntouched() throws {
        // The boundary the repair must not cross. `dx` is `U`, and `GMNLength`
        // carries a unit, so there is nothing to make explicit and nothing to
        // lose. The two kinds are told apart by the template, never by how the
        // value was written.
        let (tag, changes, issues) = try runPipeline("[\\beam<dx=1.5cm>(c d)]")

        #expect(!isUntyped(tag))
        #expect(changes.isEmpty)
        #expect(issues.isEmpty)

        #expect(try canonicalize("[\\beam<dx=1.5cm>(c d)]") == "[\\beam<dx=1.5cm>(c d)]")
    }

    @Test
    func mechanism7_theParserStillCarriesTheUnitThrough() throws {
        // Why `unrepresentableParameterNames` still covers this case rather
        // than being narrowed. Promotion runs in the parser too, and a
        // parsed score round-trips byte-for-byte; a parser that promoted
        // `size=1.5cm` would drop the unit with nothing recorded and nowhere
        // to put it. The blocker stays, and the normalizer strips the unit
        // *before* re-promoting.
        let (parsed, _) = try GMNParser().parse(Data("[\\beam<size=1.5cm>(c d)]".utf8))

        guard case let .tag(.reserved(tag)) = parsed.voices[0].symbols[0]
        else {
            Issue.record("Expected a reserved tag")

            return
        }

        #expect(tag.parameters.map(\.value) == [.floating(1.5, .cm)])
    }

    @Test
    func mechanism8_aMissingRequiredParameter_isRejected() throws {
        // Reported and non-blocking under an earlier design, so the score
        // formatted anyway as a `\clef` guidolib reads as having no clef.
        let (_, _, issues) = try runPipeline("[\\clef c]")

        #expect(issues == [.missingRequiredParameter(makeTagName("clef"), "type")])
    }

    @Test
    func mechanism8_aPositionalOverwritingARequiredParameter_isRejected() throws {
        // The valuable case: `"Allegro"` is written second, so it binds to
        // slot 1 — `bpm` — overwriting the
        // bpm that *was* written and leaving required `tempo` with nothing.
        // Rejecting it improves on guidolib, which warns and renders.
        let (_, _, issues) = try runPipeline("[\\tempo<bpm=\"1/4=120\",\"Allegro\"> c]")

        #expect(issues == [.missingRequiredParameter(makeTagName("tempo"), "tempo")])
    }

    @Test
    func mechanism9_aValueOutsideAClosedVocabulary_isRejected() throws {
        // Reported as `unreadableParameterValue`: everything binds, nothing
        // is ill-typed,
        // and the builder still refused, because re-spelling `"banana"` as a
        // `GMNTag.Curve` is precisely what the parser declines to do.
        let (_, _, issues) = try runPipeline("[\\slur<curve=\"banana\">(c d)]")

        #expect(issues == [.unreadableParameterValue(makeTagName("slur"))])
    }

    @Test
    func normalize_alreadyNormalized_shortCircuitsWithEmptyChanges() {
        let score = makeScore([], [makeVoice()])
        let (normalized, _) = GMNNormalizer().normalize(score)
        let (again, changes) = GMNNormalizer().normalize(normalized)

        #expect(again.isNormalized)
        #expect(changes.isEmpty)
    }

    @Test
    func normalize_canonicalizesAnAliasThatCouldNotPromoteAsWritten() throws {
        // `\sl<curve="banana">` used to be the example of canonicalization
        // keeping an alias out of the formatter — a value outside a closed
        // vocabulary being the one defect no repair reaches. That defect is
        // now a rejection, and with it the last way an alias could reach the
        // formatter went; see `GMNNormalizerAliasTableTests`.
        //
        // What the table still does is *enable* a repair. `\sl<bogus=1>` does
        // not promote in the parser, so it takes the generic lane, and only
        // the rewrite to `\slur` gives the repaired tag a payload to promote
        // into.
        let (parsed, _) = try GMNParser().parse(Data("[ \\sl<bogus=1>(c d) ]".utf8))
        let (normalized, changes) = GMNNormalizer().normalize(parsed)

        guard case .tag(.slur) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected the repaired tag to promote to a slur")
            return
        }

        #expect(changes.contains { $0 == .canonicalizedTagName(makeTagName("sl"), makeTagName("slur")) })
    }

    @Test
    func normalize_freshScore_flipsIsNormalized() {
        let pitch = makePitch(.c)
        let note = makeNote(pitch)
        let voice = makeVoice([.note(note)])
        let score = makeScore([], [voice])
        let (normalized, changes) = GMNNormalizer().normalize(score)

        #expect(normalized.isNormalized)
        #expect(changes.isEmpty)
    }

    @Test
    func normalize_idempotentAfterRealChanges() throws {
        let (parsed, _) = try GMNParser().parse(Data("[ \\bm<bogus=1>(c d) ]".utf8))
        let (firstPass, firstChanges) = GMNNormalizer().normalize(parsed)
        let (secondPass, secondChanges) = GMNNormalizer().normalize(firstPass)

        #expect(!firstChanges.isEmpty)
        #expect(secondChanges.isEmpty)
        #expect(secondPass.voices == firstPass.voices)
    }

    @Test
    func normalize_preservesVariablesAndVoices() {
        let pitch = makePitch(.c)
        let note = makeNote(pitch)
        let voice = makeVoice([.note(note)])
        let variable = makeVariable("tempo", .integer(120))
        let score = makeScore([variable], [voice])
        let (normalized, _) = GMNNormalizer().normalize(score)

        #expect(normalized.variables == [variable])
        #expect(normalized.voices == [voice])
    }

    @Test
    func theSilentMechanismCountIsZero() {
        // A mechanism counts as silent when it leaves a known name untyped
        // with no diagnostic at any stage. Asserting the count directly
        // makes the reduction itself a test, rather than something a reader
        // has to infer from a dozen separate cases.
        //
        // Each of the nine mechanisms is now repaired, rejected, modelled,
        // or — for mechanism 1 — given a lane that names the reason instead
        // of being repaired or rejected. `.reserved` is itself a
        // diagnostic: it says guidolib dispatches the name and IvorGuido
        // models no payload for it, which is the whole of what that
        // mechanism was failing to say.
        let silent = Fixtures.mechanisms.filter(isSilent)

        #expect(silent.isEmpty)
    }

    @Test
    func threeOfTheNineAreRefusedByTheValidator() throws {
        // Rows 4, 8, and 9 raise an issue and are left unvalidated. Everything
        // else validates. Stated over `validate(_:)` rather than
        // over a throw now that the normalizer is total: normalization repairs
        // what it can and hands the rest on, so the refusal is the validator's
        // and shows up as an issue.
        var refused = 0

        for input in Fixtures.mechanisms {
            let (validated, issues) = try GMNValidator().validate(normalizeScore(input))

            if issues.isEmpty {
                #expect(validated.isValidated,
                        Comment(rawValue: input))
            } else {
                #expect(!validated.isValidated,
                        Comment(rawValue: input))

                refused += 1
            }
        }

        #expect(refused == 3)
    }
}
