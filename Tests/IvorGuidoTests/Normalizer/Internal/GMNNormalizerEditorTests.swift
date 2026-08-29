// © 2026 John Gary Pusey (see LICENSE.md)

// One test file per source file: the editor is one source file, so its repair and alias-table suites
// all belong here.
// swiftlint:disable file_length

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// Four repairs, each answering one of the mechanisms that used to leave a
// known tag name on the `.generic` lane with nothing said about it.
//
// They share one shape and one exemption. The shape: guidolib provably never
// reads the thing being dropped, so removing it cannot change what the score
// means, and recording a `Change` turns a silent loss into an announced one.
// The exemption: a `$variable` reference no declaration answers is never
// touched, because guidolib substitutes a reference before `ARFactory` builds
// anything and `YYABORT`s when it cannot — so the reference is live whatever
// tag it was written on, and dropping it would silence the one blocking issue.
//
// `GMNNormalizerEditorTests` holds these repairs directly;
// `GMNPipelineStrictnessTests` holds the same four measured end to end.
//
// The alias tables are pruned down to the `.generic` lane rather than
// deleted. Nothing could be pruned further: every entry is still reachable.
// What these cases establish instead is the two properties that make
// keeping them safe.
//
//   - **Agreement.** Each alias points at the same name the typed payload
//     reports. If the two ever disagreed, a score would canonicalize one way
//     through the `.generic` lane and the other way through promotion, and
//     `GMNCanonicalizationTests` would only catch it for whichever names it
//     happened to list.
//   - **Reachability, and only on the `.generic` lane.** A tag that promoted
//     never consults the table, so a bare `\bm` produces no
//     `.canonicalizedTagName` change at all — the payload had already made
//     the name moot. A tag that failed to promote does consult it, which is
//     the whole reason it survives.
//
// The table is still reached, and is still what lets a repaired alias
// promote — but its role as a *fallback*, rewriting a name that would
// otherwise reach the formatter, no longer has a reachable case in written
// GMN. See `noAliasCanReachTheFormatterAnyMore`.
struct GMNNormalizerEditorTests {
}

// MARK: -

extension GMNNormalizerEditorTests {
    @Test
    func anAliasThatCannotPromoteAsWrittenIsRewrittenAndThenPromotes() throws {
        // ... and the rewrite fires when it is what makes the repair
        // possible. `\sl<bogus=1>` cannot promote in the parser, so it takes
        // the generic lane; the rewrite to `\slur` is what gives the repaired
        // tag a payload to promote into, since `GMNSlur` knows nothing about
        // the alias.
        let (normalized, changes) = try GMNNormalizer().normalize(parse("[\\sl<bogus=1>(c d)]"))

        guard case .tag(.slur) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected the repaired tag to promote to a slur")
            return
        }

        #expect(changes.contains { $0 == .canonicalizedTagName(makeTagName("sl"), makeTagName("slur")) })
    }

    @Test
    func aPromotedAliasReportsNoCanonicalizationChange() throws {
        // The `.generic`-lane restriction, stated as an observable: `\bm`
        // promotes in the parser, so the normalizer has nothing to rewrite
        // and says so by reporting no change. This is a public-API
        // behaviour shift, documented on `GMNNormalizer.Change`.
        let (_, changes) = try GMNNormalizer().normalize(parse("[\\bm(c d)]"))

        #expect(!changes.contains { if case .canonicalizedTagName = $0 { true } else { false } })
    }

    @Test
    func aVoltaWrittenWithTheCurrentNameReportsNoRename() throws {
        let (_, changes) = try GMNNormalizer().normalize(parse("[\\volta<mark=\"1.\">(c)]"))

        #expect(!changes.contains { if case .renamedParameter = $0 { true } else { false } })
    }

    @Test(arguments: [("acc", "accidental"),
                      ("accel", "accelerando"),
                      ("accol", "accolade"),
                      ("b", "beam"),
                      ("bm", "beam"),
                      ("colour", "color"),
                      ("cresc", "crescendo"),
                      ("decresc", "diminuendo"),
                      ("decrescBegin", "diminuendoBegin"),
                      ("decrescEnd", "diminuendoEnd"),
                      ("decrescendo", "diminuendo"),
                      ("dim", "diminuendo"),
                      ("dimBegin", "diminuendoBegin"),
                      ("dimEnd", "diminuendoEnd"),
                      ("fing", "fingering"),
                      ("i", "intensity"),
                      ("instr", "instrument"),
                      ("intens", "intensity"),
                      ("mord", "mordent"),
                      ("newLine", "newSystem"),
                      ("oct", "octava"),
                      ("pizz", "pizzicato"),
                      ("rit", "ritardando"),
                      ("s", "symbol"),
                      ("sl", "slur"),
                      ("stacc", "staccato"),
                      ("t", "text"),
                      ("ten", "tenuto"),
                      ("trem", "tremolo"),
                      ("tremBegin", "tremoloBegin"),
                      ("tremEnd", "tremoloEnd")])
    func editScore_canonicalizesTagNameAlias(_ pair: (alias: String, canonical: String)) {
        let (resultTag, changes) = editSingleTag(makeTagName(pair.alias))

        #expect(resultTag.name == makeTagName(pair.canonical))
        #expect(changes == [.canonicalizedTagName(makeTagName(pair.alias), makeTagName(pair.canonical))])
    }

    @Test
    func editScore_canonicalizesTagNameInsideChordSegment() {
        let innerTag = makeTag(makeTagName("stacc"))
        let segment = makeChordSegment([.tag(innerTag)])
        let chord = makeChord([segment])
        let score = makeScore([], [makeVoice([.chord(chord)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        // The canonicalized tag re-promotes, so the result is typed; the
        // `changes` assertion is what this test is really about.
        guard case let .chord(resultChord) = normalized.voices[0].symbols[0],
              case let .tag(.articulation(resultTag)) = resultChord.segments[0].symbols[0]
        else {
            Issue.record("Expected chord and tag symbols")
            return
        }

        #expect(resultTag.name == makeTagName("staccato"))
        #expect(changes == [.canonicalizedTagName(makeTagName("stacc"), makeTagName("staccato"))])
    }

    @Test
    func editScore_canonicalizesTagNameInsideTagBody() {
        let innerTag = makeTag(makeTagName("sl"))
        let outerTag = makeTag(makeTagName("staffFormat"), body: [.tag(innerTag)])
        let score = makeScore([], [makeVoice([.tag(outerTag)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        // The outer tag promotes; what matters here is that the recursion
        // reaches a body regardless of which lane its owner ends up in.
        guard case let .tag(.staffFormat(resultOuterTag)) = normalized.voices[0].symbols[0],
              case let .tag(.slur(resultInnerTag)) = resultOuterTag.body[0]
        else {
            Issue.record("Expected nested tag symbols")
            return
        }

        #expect(resultInnerTag.name == makeTagName("slur"))
        #expect(changes == [.canonicalizedTagName(makeTagName("sl"), makeTagName("slur"))])
    }

    @Test
    func editScore_canonicalizesTagNameInsideVariablesOwnBody() {
        let innerTag = makeTag(makeTagName("mord"))
        let variable = makeVariable("orn", .string("\\mord"), [.tag(innerTag)])
        let score = makeScore([variable], [makeVoice()])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        guard let resultSymbols = normalized.variables[0].symbols,
              case let .tag(.ornament(resultTag)) = resultSymbols[0]
        else {
            Issue.record("Expected tag symbol in variable body")
            return
        }

        #expect(resultTag.name == makeTagName("mordent"))
        #expect(changes == [.canonicalizedTagName(makeTagName("mord"), makeTagName("mordent"))])
    }

    @Test
    func editScore_dropsAnInertParameter() throws {
        // `kARStaccatoParams` declares `type` as `S`, so the float is cast
        // away by `TagParameterMap::get<TagParameterString>` and guidolib
        // reads a bare `\staccato`.
        // Dropping it also makes the tag promotable, so the repaired result
        // is read off the typed payload rather than off a parameter list.
        let (tag, changes) = try editedTagAndChanges("[\\staccato<0.5>(c d)]")

        guard case let .articulation(resultTag) = tag
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(resultTag.type == nil)
        #expect(changes == [.droppedInertParameter(makeTagName("staccato"), "type")])
    }

    @Test
    func editScore_dropsAnUnsupportedParameter() throws {
        // `checkExist`: `bogus` is absent from `\beam`'s accumulated
        // template, so no `getParameter` call can find it. Dropping it is
        // also what lets the tag promote.
        let (tag, changes) = try editedTagAndChanges("[\\beam<bogus=1>(c d)]")

        guard case .beam = tag
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(changes == [.droppedUnsupportedParameter(makeTagName("beam"), "bogus")])
    }

    @Test
    func editScore_dropsARawIdentifier() throws {
        let (tag, changes) = try editedTagAndChanges("[\\beam<foo>(c d)]")

        #expect(parameterValues(tag).isEmpty)
        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("beam"), "foo")])
    }

    @Test
    func editScore_dropsARawIdentifierAtASpanEnd() throws {
        // A raw identifier is dropped everywhere now, but at a span end it is
        // dropped for the span end's reason and reported under the span end's
        // change — `_dropSpanEndParameters` runs first and takes the whole
        // list at once.
        let (tag, changes) = try editedTagAndChanges("[\\slurEnd<foo>]")

        #expect(tag.span == .end)
        #expect(changes == [.droppedSpanEndParameters(makeTagName("slurEnd"))])
    }

    @Test
    func editScore_dropsARawIdentifierOnAnUndispatchedName() throws {
        // The discard happens in the grammar (`guido.y:188`), below dispatch,
        // so no template is consulted and an unknown name is treated the same.
        let (tag, changes) = try editedTagAndChanges("[\\bembel<foo>]")

        #expect(parameterValues(tag).isEmpty)
        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("bembel"), "foo")])
    }

    @Test
    func editScore_dropsARawIdentifierWithoutShiftingWhatFollowsIt() throws {
        // The property that makes removing one safe: `GMNTagBinder` skips a
        // raw identifier *without consuming an index*, so `"4/4"` was already
        // bound to slot 0 and stays there. Were it counted, this would come
        // back as a `\meter` whose `type` was never set.
        let (tag, changes) = try editedTagAndChanges("[\\meter<foo,\"4/4\"> c]")

        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("meter"), "foo")])

        guard case let .meter(meter) = tag
        else {
            Issue.record("Expected meter tag")
            return
        }

        #expect(meter.type == "4/4")
    }

    @Test
    func editScore_dropsARawIdentifierWrittenUnderAName() throws {
        // guidolib attaches a name only to a non-null parameter, so a named
        // raw identifier is discarded name and all.
        let (_, changes) = try editedTagAndChanges("[\\beam<mode=foo>(c d)]")

        #expect(changes == [.droppedRawIdentifierParameter(makeTagName("beam"), "foo")])
    }

    @Test
    func editScore_dropsAResolvedVariableAtASpanEndWithTheRest() throws {
        // ... and it is only the *unresolved* ones that are exempt. A
        // declaration answers this one, so guidolib substitutes it and
        // `ARDummyRangeEnd` then reads nothing, exactly as with a literal.
        let (tag, changes) = try editedTagAndChanges("$x = 2; [\\slurEnd<dx=$x>]")

        #expect(tag.span == .end)
        #expect(changes == [.droppedSpanEndParameters(makeTagName("slurEnd"))])
    }

    @Test
    func editScore_dropsASpanEndParameter() throws {
        // `ARDummyRangeEnd` supports no parameters at all, so the offset is
        // written to something that will never read it.
        // Dropping it is also what lets the tag promote.
        let (tag, changes) = try editedTagAndChanges("[\\slurEnd<dx=2hs>]")

        #expect(tag.span == .end)
        #expect(changes == [.droppedSpanEndParameters(makeTagName("slurEnd"))])
    }

    @Test
    func editScore_dropsASpanEndParameterUnderAnAlias() throws {
        // The drop reads the canonical name, so `\decrescEnd` is recognized
        // as the span end it is only after canonicalization has run.
        let (tag, changes) = try editedTagAndChanges("[\\decrescEnd<dx=2hs>]")

        #expect(tag.span == .end)
        #expect(changes == [.canonicalizedTagName(makeTagName("decrescEnd"),
                                                  makeTagName("diminuendoEnd")),
                            .droppedSpanEndParameters(makeTagName("diminuendoEnd"))])
    }

    @Test
    func editScore_dropsAUnitWrittenOnAFloatingSlot() throws {
        let (tag, changes) = try editedTagAndChanges("[\\beam<size=1.5cm>(c d)]")

        #expect(changes == [.droppedParameterUnit(makeTagName("beam"), "size")])

        guard case let .beam(beam) = tag
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.appearance.size == 1.5)
    }

    @Test
    func editScore_dropsAUnitWrittenOnAnIntegerSlot() throws {
        // This repair was originally written for `F` alone, and an `I`
        // field is just as bare a scalar: `\coda<id=2hs>` promoted and the
        // unit went with nothing recorded. `ARJump` never reads `id` at all,
        // so `2hs` and `2` mean exactly as much as each other to guidolib —
        // what was wrong was losing the difference in silence.
        let (_, changes) = try editedTagAndChanges("[\\coda<id=2hs>]")

        #expect(changes == [.droppedParameterUnit(makeTagName("coda"), "id")])
    }

    @Test
    func editScore_dropsAUnitWrittenOnASecondReadsSlot() throws {
        // `key` declares `S` and is read a second time as an `I`
        // (`ARKey.cpp:88–96`), so `2hs` is read — under the second read — and
        // neither read is a `U`. Measuring only the declared kind would have
        // missed it and introduced the very silent loss closed elsewhere.
        let (tag, changes) = try editedTagAndChanges("[\\key<2hs> c]")

        #expect(changes == [.droppedParameterUnit(makeTagName("key"), "key")])

        guard case let .key(key) = tag
        else {
            Issue.record("Expected key tag")
            return
        }

        #expect(key.key == .number(2))
    }

    @Test
    func editScore_dropsAUnitWrittenPositionallyOnAFloatingSlot() throws {
        // The slot is found through `boundNames`, not through the written
        // name, so a positional spelling is repaired the same way.
        // `kARAlterParams` opens with `F,detune,0.0,r`.
        let (_, changes) = try editedTagAndChanges("[\\alter<0.5cm>(c)]")

        #expect(changes == [.droppedParameterUnit(makeTagName("alter"), "detune")])
    }

    @Test
    func editScore_dropsEveryParameterAtOnceOnSuchAClass() throws {
        // Reported once for the tag, as at a span end: all of them go for the
        // same single reason, and there is no surviving list whose positional
        // spelling could shift.
        let (tag, changes) = try editedTagAndChanges("[\\newPage<dx=2hs,dy=1hs,color=\"red\">]")

        #expect(parameterValues(tag).isEmpty)
        #expect(changes == [.droppedUnacceptedParameters(makeTagName("newPage"))])
    }

    // The six dispatched names whose classes are not `ARMTParameter`s, so
    // that `ARFactory::addTagParameter` discards everything written to them
    // before binding (`ARFactory.cpp:2012–2016`). Read as a list rather than
    // derived, because the point is that these six and no others behave this
    // way.
    @Test(arguments: ["beamsAuto",
                      "beamsFull",
                      "beamsOff",
                      "merge",
                      "newPage",
                      "port"])
    func editScore_dropsEveryParameterOnAClassThatKeepsNone(_ name: String) throws {
        let (tag, changes) = try editedTagAndChanges("[\\\(name)<dx=2hs>]")

        #expect(parameterValues(tag).isEmpty,
                Comment(rawValue: "\\\(name)"))
        #expect(changes == [.droppedUnacceptedParameters(makeTagName(name))],
                Comment(rawValue: "\\\(name)"))
    }

    @Test
    func editScore_dropsEveryWriteToAnInertName() throws {
        // Both parameters bind to `type`, and the float overwrites the
        // string, leaving guidolib with no meter at all. Keeping the first
        // would resurrect a value guidolib had already discarded.
        let (tag, changes) = try editedTagAndChanges("[\\meter<\"4/4\",type=0.5> c]")

        let resultTag = try #require(tag.untypedPayload, "Expected an untyped tag")

        #expect(resultTag.parameters.isEmpty)
        #expect(changes.count == 2)
    }

    @Test
    func editScore_dropsInertAndUnsupportedInOnePass() throws {
        // The two sets are disjoint — an ill-typed value is measured against
        // a slot, and an unsupported name has none — and each is reported
        // under its own heading, in written order.
        let (tag, changes) = try editedTagAndChanges("[\\staccato<0.5,bogus=1>(c d)]")

        guard case let .articulation(articulation) = tag
        else {
            Issue.record("Expected articulation tag")
            return
        }

        #expect(articulation.type == nil)
        #expect(changes == [.droppedInertParameter(makeTagName("staccato"), "type"),
                            .droppedUnsupportedParameter(makeTagName("staccato"), "bogus")])
    }

    @Test
    func editScore_expandsInsideAVariablesOwnSymbols() throws {
        // The environment is a prologue, complete before any reference, so it
        // is the same one everywhere — including inside a declaration's own
        // stashed fragment.
        let (parsed, _) = try GMNParser().parse(Data("$x = 2; $y = \"\\beam<dy=$x>(c d)\"; [$y]".utf8))

        var editor = GMNNormalizer.Editor(score: parsed)

        let (_, changes) = editor.editScore()

        #expect(changes == [.expandedVariableReference(makeTagName("beam"), "x")])
    }

    @Test
    func editScore_keepsAnUnresolvedVariableAtASpanEnd() {
        // The exemption every drop honours. guidolib substitutes a reference
        // before `ARFactory` builds anything, so an undeclared name aborts
        // the parse whatever tag it was written on — a closing half never
        // gets as far as having no slots. IvorGuido's parser aborts on one
        // too, so this is stated over a hand-built tag; the editor must
        // still not swallow the reference.
        let (tag, changes) = edit("slurEnd",
                                  [makeTagParameter("dx", .variable("missing"))])

        #expect(parameterValues(tag) == [.variable("missing")])
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_keepsAnUnresolvedVariableOnSuchAClass() {
        let (tag, changes) = edit("newPage",
                                  [makeTagParameter("dx", .variable("missing"))])

        #expect(parameterValues(tag) == [.variable("missing")])
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_keepsAnUnsupportedParameterHoldingAVariable() throws {
        // The exception. guidolib substitutes a `$variable` before
        // `ARFactory` is reached and `YYABORT`s when it does not resolve, so
        // the reference is live whatever name it was written under. The tag
        // stays generic around it rather than losing it to the drop.
        let (tag, changes) = edit("beam",
                                  [makeTagParameter("bogus", .variable("x"))])

        let resultTag = try #require(tag.untypedPayload, "Expected an untyped tag")

        #expect(resultTag.parameters == [makeTagParameter("bogus", .variable("x"))])
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_keepsAParameterMatchingASecondRead() throws {
        // FLIPPED IN PHASE 2 — the parameter survives as it always did, but
        // the tag it belongs to is typed now rather than stranded.
        //
        // `ARKey` reads `key` as a string *and*, failing that, as an integer
        // (`ARKey.cpp:88–96`), so a bare number there is not inert. The
        // template records the second read, the repair leaves the value alone
        // because it is not ill-typed, and promotion carries it.
        let (tag, changes) = try editedTagAndChanges("[\\key<2> c]")

        guard case let .key(key) = tag
        else {
            Issue.record("Expected key tag")
            return
        }

        #expect(key.key == .number(2))
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_keepsPositionalSpellingWhenNothingShifts() throws {
        // `bpm` is slot 1 and declared `S`, so the trailing integer is inert;
        // dropping it leaves `"Allegro"` still bound to slot 0.
        // Dropping it also makes the tag promotable, so the survivor is read
        // off the payload.
        let (tag, _) = try editedTagAndChanges("[\\tempo<\"Allegro\",120> c]")

        guard case let .tempo(resultTag) = tag
        else {
            Issue.record("Expected tempo tag")
            return
        }

        #expect(resultTag.tempo == "Allegro")
        #expect(resultTag.metronome == nil)
    }

    @Test
    func editScore_leavesABareSpanEndAlone() throws {
        let (_, changes) = try editedTagAndChanges("[\\slurEnd]")

        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesABareSuchATagAlone() throws {
        let (_, changes) = try editedTagAndChanges("[\\newPage]")

        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesAnUndeclaredReferenceAlone() {
        // Left exactly as written. The report of it moved to
        // `GMNParser.Error.unresolvableVariableReference`, so a *parsed*
        // score can no longer carry one this far; the editor still must not
        // invent a substitution for a name it has no declaration for.
        let (tag, changes) = edit("bembel",
                                  [makeTagParameter("v", .variable("missing"))])

        #expect(parameterValues(tag) == [.variable("missing")])
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesASiblingThatDoesAcceptParametersAlone() throws {
        // `ARNewSystem` *is* an `ARMTParameter`, so the pair of layout-break
        // tags differ here despite reading as siblings. This is the assertion
        // that would catch the repair being keyed on anything but
        // `acceptsParameters`.
        let (tag, changes) = try editedTagAndChanges("[\\newSystem<dx=2hs>]")

        #expect(changes.isEmpty)

        guard case let .layoutBreak(layoutBreak) = tag
        else {
            Issue.record("Expected layoutBreak tag")
            return
        }

        #expect(layoutBreak.appearance.dx == GMNLength(2, unit: .hs))
    }

    @Test
    func editScore_leavesASymbolPositionReferenceAlone() throws {
        // The two positions are different mechanisms. A symbol-position
        // reference is a textual macro re-lexed in place
        // (`variableSymbols`), and splicing it in is not implemented
        // anywhere in IvorGuido; only the tag-parameter position is
        // `varParam`'s typed substitution.
        let (parsed, _) = try GMNParser().parse(Data("$x = \"c d\"; [$x]".utf8))

        var editor = GMNNormalizer.Editor(score: parsed)

        let (normalized, changes) = editor.editScore()

        #expect(normalized.voices[0].symbols == [.variable("x")])
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesAUnitlessFloatingSlotAlone() throws {
        let (_, changes) = try editedTagAndChanges("[\\beam<size=1.5>(c d)]")

        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesAUnitOnALengthSlotAlone() throws {
        // `U` is what `GMNLength` models, unit and all, so there is nothing
        // to make explicit and nothing to lose. The two kinds are told apart
        // by the template, never by how the value was written.
        let (tag, changes) = try editedTagAndChanges("[\\beam<dx=1.5cm>(c d)]")

        #expect(changes.isEmpty)

        guard case let .beam(beam) = tag
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.appearance.dx == GMNLength(1.5, unit: .cm))
    }

    @Test
    func editScore_leavesAWholeTagsParametersAlone() throws {
        // Only a closing half has no schema. The range form keeps everything
        // it was written with.
        let (tag, changes) = try editedTagAndChanges("[\\slur<dx=2hs>(c d)]")

        #expect(tag.span == .whole)
        #expect(changes.isEmpty)
    }

    @Test(arguments: ["accidental", "accelerando", "beam", "staccato", "slur", "symbol"])
    func editScore_leavesCanonicalTagNameUnchanged(_ canonical: String) {
        let (resultTag, changes) = editSingleTag(makeTagName(canonical))

        #expect(resultTag.name == makeTagName(canonical))
        #expect(changes.isEmpty)
    }

    @Test(arguments: ["accelBegin",
                      "accelEnd",
                      "crescBegin",
                      "crescEnd",
                      "ritBegin",
                      "ritEnd",
                      "staccBegin",
                      "staccEnd"])
    func editScore_leavesShortSpanNamesWithNoLongFormAlone(_ name: String) {
        // These eight used to be rewritten to `accelerandoBegin`,
        // `staccatoEnd`, and the like — names `Tags.cpp` does not declare and
        // `ARFactory::createTag` does not dispatch, so the rename turned a
        // legal tag into an unknown one. The short spelling is the canonical
        // one here; `diminuendoBegin` and `tremoloEnd` keep their entries
        // because those long forms do exist.
        let (resultTag, changes) = editSingleTag(makeTagName(name))

        #expect(resultTag.name == makeTagName(name))
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_leavesTheUnitOnAParameterItIsAboutToDeleteAnyway() throws {
        // `bogus` is unsupported, so the whole parameter goes. Stripping its
        // unit first would record a repair of something already on its way
        // out, and the change list is meant to read as what happened.
        let (_, changes) = try editedTagAndChanges("[\\beam<bogus=2hs>(c d)]")

        #expect(changes == [.droppedUnsupportedParameter(makeTagName("beam"), "bogus")])
    }

    @Test
    func editScore_leavesUnnamedAndOtherNamedParametersAlone() {
        let tag = makeTag(makeTagName("volta"),
                          parameters: [makeTagParameter(.string("unnamed")),
                                       makeTagParameter("format", .string("|-|"))])
        let score = makeScore([], [makeVoice([.tag(tag)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        guard case let .tag(.volta(resultTag)) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(resultTag.mark == "unnamed")
        #expect(resultTag.format == "|-|")
        #expect(changes.isEmpty)
    }

    @Test
    func editScore_neverAttachesAUnitWhenSubstituting() throws {
        // The one detail that makes substitution differ from re-reading the
        // written text. `dy` is `U,dy,0,o` and would happily have taken a
        // unit; `varParam` attaches none, so `2` arrives bare.
        let (tag, changes) = try editedTagAndChanges("$x = 2; [\\beam<dy=$x>(c d)]")

        #expect(changes == [.expandedVariableReference(makeTagName("beam"), "x")])

        guard case let .beam(beam) = tag
        else {
            Issue.record("Expected beam tag")
            return
        }

        #expect(beam.appearance.dy == GMNLength(2))
    }

    @Test
    func editScore_renamesBeforeDroppingTheUnread() throws {
        // Order is load-bearing. `m` is not a name `ARVolta` supports, so
        // dropping the unread first would delete the very parameter the
        // rename exists to repair — `\volta<m="1.">` would lose its mark
        // instead of gaining one. Only the rename is recorded.
        let (tag, changes) = try editedTagAndChanges("[\\volta<m=\"1.\">(c)]")

        guard case let .volta(volta) = tag
        else {
            Issue.record("Expected volta tag")
            return
        }

        #expect(volta.mark == "1.")
        #expect(changes == [.renamedParameter(makeTagName("volta"), "m", "mark")])
    }

    @Test
    func editScore_renamesVoltaBeginMarkParameter() {
        let tag = makeTag(makeTagName("voltaBegin"),
                          ident: makeTagIdent(1),
                          parameters: [makeTagParameter("m", .string("1"))])
        let score = makeScore([], [makeVoice([.tag(tag)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        guard case let .tag(.volta(resultTag)) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(resultTag.mark == "1")
        #expect(resultTag.span == .begin)
        #expect(changes == [.renamedParameter(makeTagName("voltaBegin"), "m", "mark")])
    }

    @Test
    func editScore_renamesVoltaMarkParameter() {
        let tag = makeTag(makeTagName("volta"), parameters: [makeTagParameter("m", .string("1,2"))])
        let score = makeScore([], [makeVoice([.tag(tag)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        // The rename makes the tag promotable, so the result is read off the
        // typed payload rather than off a parameter list.
        guard case let .tag(.volta(resultTag)) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(resultTag.mark == "1,2")
        #expect(changes == [.renamedParameter(makeTagName("volta"), "m", "mark")])
    }

    @Test
    func editScore_repairThenPromoteYieldsATypedPayload() throws {
        // The full lifecycle of an inert parameter: the tag parses
        // generic, the repair drops the inert `hidden`, and promotion — run
        // a second time — succeeds.
        let (tag, changes) = try editedTagAndChanges("[\\octava<1,hidden=0.5>(c)]")

        guard case let .octava(octava) = tag
        else {
            Issue.record("Expected octava tag")
            return
        }

        #expect(changes == [.droppedInertParameter(makeTagName("octava"), "hidden")])
        #expect(octava.hidden == nil)
        #expect(octava.offset == 1)
    }

    @Test
    func editScore_restatesSurvivorsNamedWhenAPositionWouldShift() throws {
        let (tag, _) = try editedTagAndChanges("[\\staccato<0.5,\"above\">(c d)]")

        guard case let .articulation(resultTag) = tag
        else {
            Issue.record("Expected articulation tag")
            return
        }

        // The survivor was restated named. Had it been left positional it
        // would have shifted into slot 0 and bound to `type` instead — which
        // the typed payload now shows directly.
        #expect(resultTag.position == .above)
        #expect(resultTag.type == nil)
    }

    @Test(arguments: [("$x = 2;", GMNTag.Parameter.Value.integer(2, nil)),
                      ("$x = 2.5;", GMNTag.Parameter.Value.floating(2.5, nil)),
                      ("$x = \"red\";", GMNTag.Parameter.Value.string("red"))])
    func editScore_substitutesByDeclaredType(_ declaration: String,
                                             _ expected: GMNTag.Parameter.Value) throws {
        // `varParam` switches on the declared type — `kString`, `kInt`,
        // `kFloat` — and this is written to an unsupported name so that the
        // substituted value survives to be looked at rather than being read
        // into a payload field.
        let (tag, changes) = try editedTagAndChanges("\(declaration) [\\bembel<v=$x>]")

        #expect(parameterValues(tag) == [expected])
        #expect(changes == [.expandedVariableReference(makeTagName("bembel"), "x")])
    }

    @Test
    func editScore_substitutesTheLastDeclarationOfAName() throws {
        // guidolib's `fEnv` is a map, so a redeclared name resolves to its
        // last value. The AST keeps both declarations, so the agreement has
        // to be built rather than inherited.
        let (tag, _) = try editedTagAndChanges("$x = 1; $x = 2; [\\bembel<v=$x>]")

        #expect(parameterValues(tag) == [.integer(2, nil)])
    }

    @Test
    func editScore_voltaEndDoesNotRenameParameters() {
        // `voltaEnd` constructs a generic `ARDummyRangeEnd` that takes no
        // parameters — an `m` there is never meaningful, so it is dropped
        // outright rather than renamed to a `mark` nothing would read. The
        // rename table is not consulted at all: only
        // `droppedSpanEndParameters` is recorded.
        let tag = makeTag(makeTagName("voltaEnd"),
                          ident: makeTagIdent(1),
                          parameters: [makeTagParameter("m", .string("1"))])
        let score = makeScore([], [makeVoice([.tag(tag)])])
        var editor = GMNNormalizer.Editor(score: score)
        let (normalized, changes) = editor.editScore()

        guard case let .tag(resultTag) = normalized.voices[0].symbols[0]
        else {
            Issue.record("Expected tag symbol")
            return
        }

        #expect(resultTag.span == .end)
        #expect(changes == [.droppedSpanEndParameters(makeTagName("voltaEnd"))])
    }

    @Test
    func everyAliasAgreesWithTheNameItsPayloadReports() {
        // The closure property. Promote the alias with the parameters its own
        // template requires, and the payload's canonical name must be exactly
        // what the table would have rewritten it to.
        for (alias, canonical) in GMNNormalizer.Editor.tagNameAliases.sorted(by: { $0.key < $1.key }) {
            let promoted = makePromotedTag(alias, parameters: requiredParameters(alias))

            guard promoted.untypedPayload != nil
            else {
                let detail = "\\\(alias) promotes to a payload named "
                    + "\(promoted.name.stringValue), but the alias table "
                    + "rewrites it to \(canonical)"

                #expect(promoted.name.stringValue == canonical,
                        Comment(rawValue: detail))

                continue
            }

            Issue.record("\\\(alias) did not promote, so the two canonicalizations cannot be compared")
        }
    }

    @Test
    func everyAliasKeyIsADispatchedName() {
        // If a key were *not* in the registry it could never promote, and the
        // table would be the only thing that knew about it — a second,
        // shadow name universe. Every key being dispatched is what makes the
        // table purely a fallback.
        for alias in GMNNormalizer.Editor.tagNameAliases.keys.sorted() {
            #expect(GMNTagTemplate.Registry.names.contains(alias),
                    "the alias \(alias) is not a name the registry dispatches")
        }
    }

    @Test
    func everyAliasTargetIsADispatchedName() {
        // Rule 1 again: canonicalizing to a name guidolib does not declare
        // would turn a legal tag into an unknown one. This is the check that
        // caught the eight `accelBegin`-style entries that were removed.
        for canonical in Set(GMNNormalizer.Editor.tagNameAliases.values).sorted() {
            #expect(GMNTagTemplate.Registry.names.contains(canonical),
                    "the canonical name \(canonical) is not a name the registry dispatches")
        }
    }

    @Test
    func noAliasCanReachTheFormatterAnyMore() {
        // The interesting half: the table's *fallback* role — rewriting a
        // tag that will still be generic when the formatter sees it, so
        // that rule 1 holds — has no reachable case left in a parsed score.
        //
        // The reason is the invariant three normalizer rejections buy: after
        // normalization the only generic tags are undispatched names and the
        // three no payload claims, and no alias key is either. The one
        // example that used to reach it, `\sl<curve="banana">`, is refused
        // now.
        //
        // The table is not dead — see the case above, and the fallback still
        // has to hold for a score built by hand, which no rejection guards.
        // But nothing written can exercise it, and a comment claiming
        // otherwise would be wrong.
        for alias in GMNNormalizer.Editor.tagNameAliases.keys.sorted() {
            guard let formatted = try? canonicalize("[\\\(alias) c]")
            else { continue }

            #expect(!formatted.contains("\\\(alias) "),
                    Comment(rawValue: "\\\(alias) reached the formatter: \(formatted)"))
        }
    }

    @Test
    func theRenamableParameterTargetsAreSupported() throws {
        // `\volta`'s `m` → `mark`. The new name has to be one the tag
        // actually supports, or the rename would produce a parameter that
        // stops the tag promoting instead of starting it.
        for (name, rename) in GMNNormalizer.Editor.renamableParameter.sorted(by: { $0.key < $1.key }) {
            let template = try #require(GMNTagTemplate.Registry.template(for: makeTagName(name)))

            #expect(template.supportedParameters.contains { $0.name == rename.new },
                    "\(name) does not support the renamed parameter \(rename.new)")
            #expect(!template.supportedParameters.contains { $0.name == rename.old },
                    "\(name) still supports \(rename.old), so the rename is not a deprecation")
        }
    }

    @Test
    func theVoltaRenameFiresAndThenLetsTheTagPromote() throws {
        // `renamableParameter` behaves differently from `tagNameAliases`: the
        // rename is not a last resort for a tag that failed to promote, it is
        // what *causes* the tag to promote. `GMNVolta` binds `mark` and knows
        // nothing about `m`, so `\volta<m="1.">` cannot promote in the parser
        // — it is repaired on the `.generic` lane and re-promoted, exactly
        // like an inert parameter.
        let (normalized, changes) = try GMNNormalizer().normalize(parse("[\\volta<m=\"1.\">(c)]"))

        #expect(changes.contains { $0 == .renamedParameter(makeTagName("volta"), "m", "mark") })

        guard case let .tag(tag) = normalized.voices[0].symbols[0],
              case let .volta(volta) = tag
        else {
            Issue.record("Expected the repaired \\volta to promote")
            return
        }

        #expect(volta.mark == "1.")
    }
}
