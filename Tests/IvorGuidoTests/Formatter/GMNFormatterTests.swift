// © 2026 John Gary Pusey (see LICENSE.md)

// One test file per source file: the formatter is one source file, so its canonicalization and
// AST-stability suites all belong here.
// swiftlint:disable file_length

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// The third canonicalization property, stated over the AST rather than over
// text: for a normalized score `s`, `normalize(parse(format(s))) == s`.
//
// Note the `normalize` on the left. Without it the re-parsed score is
// legitimately *less typed* than `s`: the parser promotes only what binds
// cleanly and leaves everything else `.generic`, and it is the normalizer
// that repairs an ill-typed parameter and re-promotes. Comparing the bare
// re-parse against `s` would therefore fail by design rather than by defect.
//
// `GMNScore`'s `Equatable` conformance excludes `isNormalized` and
// `isValidated`, so the two sides compare on content alone.
//
// Each case documents a *spelling decision*: given this input, the pipeline
// `parse → normalize → validate → format` emits exactly this canonical text.
// Where input and expected coincide, the input was already canonical — that
// is an assertion about the input, not the absence of one.
//
// Every case additionally asserts idempotence, the property that actually
// catches formatter bugs: re-formatting canonical text changes nothing.
//
// See `GMNFormatter` for the seven rules of canonical form. As typed tag
// payloads land (Phases 4–7), some expectations below move off their inputs;
// those cases carry a marker naming the phase that changes them.
struct GMNFormatterTests {
}

// MARK: -

extension GMNFormatterTests {
    @Test
    func format_canonical_accidentalForms() throws {
        try assertCanonicalizes("[c# d## e& f&& g]",
                                to: "[c# d## e& f&& g]")
    }

    // A feathered beam supports every `kARBeamParams` name but declares only
    // its own two as slots, so a corner written on one must go out named.
    @Test
    func format_canonical_aFeatheredBeamEmitsAgainstItsOwnSlotOrder() throws {
        try assertCanonicalizes("[\\fBeam<dx1=1hs,durations=\"1/16,1/4\">(c d)]",
                                to: "[\\fBeam<\"1/16,1/4\",dx1=1hs>(c d)]")
    }

    // FLIPPED IN PHASE 3. A required parameter that was never written used to
    // keep the tag `.generic`, so `\oct` was echoed under its canonical name
    // with nothing else changed. `checkRequired` is a rejection now, and a
    // name guidolib does not dispatch is what is left to echo unchanged.
    @Test
    func format_canonical_anUndispatchedNameIsEchoedAsWritten() throws {
        try assertCanonicalizes("[\\bembel<curve=\"banana\"> c]",
                                to: "[\\bembel<curve=\"banana\"> c]")
    }

    // ... and one holding a *declared* `$variable` is expanded first and then
    // dropped like any other unsupported value, so both changes are recorded
    // and the parameter still goes. guidolib does the same two things in the
    // same order: `varParam` substitutes the reference, then `checkExist`
    // warns about the name and nothing ever reads it.
    //
    // Only an *unresolved* reference survives the drop, and that score does
    // not format at all — `unresolvableVariableReference` is the one blocking
    // issue, matching guidolib's `YYABORT`. See
    // `GMNPipelineStrictnessTests.mechanism2_leavesAnUnresolvedVariableReferenceAlone`.
    @Test
    func format_canonical_anUnsupportedParameterHoldingADeclaredVariableIsExpandedThenDropped() throws {
        try assertCanonicalizes("$x = 1; [\\beam<bogus=$x>(c d)]",
                                to: "$x = 1;\n[\\beam(c d)]")
    }

    // The visible half of the `checkExist` repair. guidolib's
    // `getParamsStr()` would echo `bogus` back where IvorGuido drops it —
    // a serialization difference the arbiter rule permits, since what
    // guidolib settles is what the score means, and the parameter is
    // unreachable in both.
    @Test
    func format_canonical_anUnsupportedParameterIsDroppedFromTheOutput() throws {
        try assertCanonicalizes("[\\beam<bogus=1>(c d)]",
                                to: "[\\beam(c d)]")
    }

    @Test
    func format_canonical_arpeggioKeepsADirectionGuidolibIgnores() throws {
        try assertCanonicalizes("[\\arpeggio<\"sideways\">({c,e,g})]",
                                to: "[\\arpeggio<\"sideways\">({c,e,g})]")
    }

    // Eight names, eight templates. `\bow` requires its `type` in slot 0
    // while `\accent` declares no `type` at all and opens with `position`.
    @Test
    func format_canonical_articulationEmitsAgainstItsOwnKindsTemplate() throws {
        try assertCanonicalizes("[\\bow<type=\"up\">(c) \\accent<position=\"below\">(d)]",
                                to: "[\\bow<\"up\">(c) \\accent<\"below\">(d)]")
    }

    // The two names a class reads under two C++ types keep the spelling they
    // were written in, on both sides. Collapsing `2` onto `"2"` — or the
    // reverse — would be a re-spelling, and this AST does not make those.
    @Test(arguments: ["[\\key<2> c]",
                      "[\\key<\"2\"> c]",
                      "[\\staff<\"upper\"> c]",
                      "[\\staff<2> c]"])
    func format_canonical_aSecondReadKeepsTheSpellingItWasWrittenIn(_ input: String) throws {
        try assertCanonicalizes(input,
                                to: input)
    }

    // The other side of the same decision: a parameter written on a span end
    // is dropped by the normalizer, so it is gone from the output. This is
    // the one place the repair is visible to a caller who only formats —
    // before it, the tag stayed generic and echoed back as written.
    @Test
    func format_canonical_aSpanEndParameterIsDroppedFromTheOutput() throws {
        try assertCanonicalizes("[\\slurEnd<dx=2hs>]",
                                to: "[\\slurEnd]")
    }

    // One payload, three templates: `\title` and `\composer` call their
    // required slot `name` while `\footer` calls it `text`.
    @Test
    func format_canonical_aTitleBlockEmitsAgainstItsOwnKindsTemplate() throws {
        try assertCanonicalizes("[\\title<name=\"Sonata\"> \\footer<text=\"page 1\">]",
                                to: "[\\title<\"Sonata\"> \\footer<\"page 1\">]")
    }

    // Rule 6: `|` when the barline carries nothing, `\bar<…>` the moment it
    // carries anything. Both directions, since the payload decides its own
    // name.
    @Test
    func format_canonical_bareBarLineKeepsTheShorthand() throws {
        try assertCanonicalizes("[c | d]",
                                to: "[c | d]")
    }

    @Test
    func format_canonical_bareBarLineWrittenLongCollapsesToTheShorthand() throws {
        try assertCanonicalizes("[c \\bar d]",
                                to: "[c | d]")
    }

    @Test
    func format_canonical_barLineWithNoGapKeepsThePositionalPrefix() throws {
        try assertCanonicalizes("[c \\bar<displayMeasNum=\"true\",measNum=4> d]",
                                to: "[c \\bar<\"true\",4> d]")
    }

    // Unchanged: a bare barline stays `|` (rule 6). `guido.y:180` rewrites
    // the token to a parameterless, identless `\bar`, so the two spellings
    // are provably identical here — and only here.
    @Test
    func format_canonical_barShorthand() throws {
        try assertCanonicalizes("[c | d]",
                                to: "[c | d]")
    }

    @Test
    func format_canonical_basic() throws {
        try assertCanonicalizes("[s1:4: s2:x:*1/8]",
                                to: "[s1:4: s2:x:*1/8]")
    }

    // Rule 1 over the tranche's aliases. Both beam families are symmetric,
    // so unlike bucket C there is no short span spelling to preserve.
    @Test
    func format_canonical_beamAliasesCanonicalizeInBothForms() throws {
        try assertCanonicalizes("[\\bm(c d) \\b(e f) \\beamBegin g \\beamEnd a]",
                                to: "[\\beam(c d) \\beam(e f) \\beamBegin g \\beamEnd a]")
    }

    // `kARBeamParams` opens with `dy`, a `kCommonParams` name redeclared as
    // the tag's own — so it takes slot 0 and the corners follow it, rather
    // than sorting last as a common parameter normally would.
    @Test
    func format_canonical_beamEmitsTheVerticalOffsetFirstAndTheCornersAfterIt() throws {
        try assertCanonicalizes("[\\beam<dx1=1hs,dy=2hs>(c d)]",
                                to: "[\\beam<2hs,1hs>(c d)]")
    }

    // Rule 1 again, over this tranche's three aliases. `\set` joins them:
    // `ARFactory.cpp:1322–1327` builds it a bare `ARAuto`, the same object
    // `\auto` gets, so the two spellings are one tag.
    @Test(arguments: [("\\accol<1,\"1-2\">", "\\accolade<1,\"1-2\">"),
                      ("\\instr<\"Horn\">", "\\instrument<\"Horn\">"),
                      ("\\newLine", "\\newSystem"),
                      ("\\set<endBar=\"off\">", "\\auto<\"off\">")])
    func format_canonical_bucketBTagNamesAreCanonical(_ pair: (input: String, expected: String)) throws {
        try assertCanonicalizes("[\(pair.input) c]",
                                to: "[\(pair.expected) c]")
    }

    @Test
    func format_canonical_colourAliasCanonicalizesAndItsColourIsPositional() throws {
        try assertCanonicalizes("[\\colour<color=\"red\"> c]",
                                to: "[\\color<\"red\"> c]")
    }

    @Test
    func format_canonical_declarations() throws {
        try assertCanonicalizes("$tempo = 120;\n$pi = 3.14;\n$title = \"My Song\";\n[c]",
                                to: "$tempo = 120;\n$pi = 3.14;\n$title = \"My Song\";\n[c]")
    }

    @Test
    func format_canonical_diatonicNames() throws {
        try assertCanonicalizes("[a b c d e f g h]",
                                to: "[a b c d e f g h]")
    }

    @Test
    func format_canonical_dotsOnlyFormStaysOmittedBase() throws {
        try assertCanonicalizes("[c*1/4 d. e..]",
                                to: "[c*1/4 d. e..]")
    }

    // Rule 1 over the tranche's asymmetric span names. `\crescendo` and
    // `\accelerando` have a long range form but only a short `Begin`/`End`
    // pair, so the short spelling *is* canonical there — which is why the
    // normalizer's alias entries rewriting these to `\crescendoBegin` and
    // `\accelerandoEnd` had to go: those names do not exist.
    @Test
    func format_canonical_dynamicRampSpanHalvesKeepTheirShortNames() throws {
        try assertCanonicalizes("[\\crescBegin c d \\crescEnd e]",
                                to: "[\\crescBegin c d \\crescEnd e]")
    }

    @Test
    func format_canonical_emptyName() throws {
        try assertCanonicalizes("[empty]",
                                to: "[empty]")
    }

    @Test
    func format_canonical_explicitOctave() throws {
        try assertCanonicalizes("[c1 d5 e-1 f2]",
                                to: "[c1 d5 e-1 f2]")
    }

    // `position` is *supported but has no slot* on `\fingering`, since the
    // positional template is the inherited `kARTextParams`. So it is always
    // named, and `dy` — which does have a slot — is not.
    @Test
    func format_canonical_fingeringEmitsPositionNamedAndDyPositionally() throws {
        try assertCanonicalizes("[\\fing<\"1\",position=\"below\",dy=-2hs>(c)]",
                                to: "[\\fingering<\"1\",-2hs,position=\"below\">(c)]")
    }

    @Test
    func format_canonical_fractionForm() throws {
        try assertCanonicalizes("[c*3/4]",
                                to: "[c*3/4]")
    }

    @Test
    func format_canonical_germanChromaticNames() throws {
        try assertCanonicalizes("[ais cis dis fis gis]",
                                to: "[ais cis dis fis gis]")
    }

    // `\harmony` redeclares `dy` as its own slot 1, so it emits positionally
    // there rather than sorting last with the other common parameters.
    @Test
    func format_canonical_harmonyEmitsItsOwnDyPositionally() throws {
        try assertCanonicalizes("[\\harmony<dy=-2hs,text=\"Cmaj7\"> c]",
                                to: "[\\harmony<\"Cmaj7\",-2hs> c]")
    }

    @Test
    func format_canonical_identifierSuffix() throws {
        try assertCanonicalizes("[\\tieBegin:1 c \\tieEnd:1 d]",
                                to: "[\\tieBegin:1 c \\tieEnd:1 d]")
    }

    // A gap ends the positional run (rule 2): `\intensity` skipping `before`
    // and `after` must write `font` named, because positionally that string
    // would bind to `before`.
    @Test
    func format_canonical_intensityWithAGapSwitchesToNamed() throws {
        try assertCanonicalizes("[\\i<\"pp\",font=\"Arial\"> c]",
                                to: "[\\intensity<\"pp\",font=\"Arial\"> c]")
    }

    @Test
    func format_canonical_markKeepsItsEnclosureAndLyricsItsAutoPosition() throws {
        try assertCanonicalizes("[\\mark<\"A\",\"square\"> \\lyrics<\"la\",autopos=\"on\">(c d)]",
                                to: "[\\mark<\"A\",\"square\"> \\lyrics<\"la\",autopos=\"on\">(c d)]")
    }

    @Test
    func format_canonical_millisecondsForm() throws {
        try assertCanonicalizes("[c*500ms]",
                                to: "[c*500ms]")
    }

    @Test
    func format_canonical_millisecondsFormWithDots() throws {
        try assertCanonicalizes("[c*500ms.]",
                                to: "[c*500ms.]")
    }

    @Test
    func format_canonical_multipleVoices() throws {
        try assertCanonicalizes("{[c d e], [g a b]}",
                                to: "{[c d e], [g a b]}")
    }

    // Unchanged: `dx` and `dy` come from `kCommonParams`, which has no
    // positional slot and is entirely non-omissible, so both are always
    // named and always emitted.
    @Test
    func format_canonical_namedParameterWithUnit() throws {
        try assertCanonicalizes("[\\staffFormat<dx=5hs,dy=-2.5pt> c]",
                                to: "[\\staffFormat<dx=5hs,dy=-2.5pt> c]")
    }

    // A `\newPage` carrying a parameter used to echo exactly as written,
    // because it never promoted. guidolib discards what was written before
    // binding (`ARFactory.cpp:2012–2016`), so the normalizer now drops it and
    // records `droppedUnacceptedParameters`, and the tag promotes.
    @Test
    func format_canonical_newPageWithAParameterLosesIt() throws {
        try assertCanonicalizes("[\\newPage<dx=2hs> c]",
                                to: "[\\newPage c]")
    }

    // `\newSystem`'s whole schema is `kCommonParams`, which for this one tag
    // therefore *does* bind and emit positionally.
    @Test
    func format_canonical_newSystemEmitsCommonParametersPositionally() throws {
        // CHANGED IN PHASE 4 — the body went away. `ARNewSystem` inherits the
        // default `rangesetting = NO`, so guidolib strips the range with a
        // warning and the validator now refuses it; nothing about which
        // parameters bind positionally depends on the body.
        try assertCanonicalizes("[\\newSystem<color=\"red\"> c]",
                                to: "[\\newSystem<\"red\"> c]")
    }

    @Test
    func format_canonical_numeratorOnlyForm() throws {
        try assertCanonicalizes("[c*3]",
                                to: "[c*3]")
    }

    @Test
    func format_canonical_omittedDurationStaysOmitted() throws {
        try assertCanonicalizes("[c d]",
                                to: "[c d]")
    }

    @Test
    func format_canonical_omittedOctaveStaysOmitted() throws {
        try assertCanonicalizes("[c1 d]",
                                to: "[c1 d]")
    }

    @Test
    func format_canonical_ornamentAliasCanonicalizesAndKeepsItsRepeatParameter() throws {
        try assertCanonicalizes("[\\mord<\"d\",repeat=\"false\">(c)]",
                                to: "[\\mordent<\"d\",repeat=\"false\">(c)]")
    }

    // Neither hand-built template declares `color`, so `\pageFormat` is the
    // one tag of this tranche whose `color` has no slot at all.
    @Test
    func format_canonical_pageFormatColorIsAlwaysNamed() throws {
        try assertCanonicalizes("[\\pageFormat<\"a4\",color=\"red\"> c]",
                                to: "[\\pageFormat<\"a4\",color=\"red\"> c]")
    }

    @Test
    func format_canonical_pageFormatMeasuredBySizeEmitsWidthAndHeightFirst() throws {
        try assertCanonicalizes("[\\pageFormat<h=29.7cm,w=21cm> c]",
                                to: "[\\pageFormat<21cm,29.7cm> c]")
    }

    // `\pageFormat` is the only tag whose positional template guidolib picks
    // per tag, so both halves are pinned. A named page's slot 1 is the *left
    // margin*; a measured page's slots 0 and 1 are the width and height.
    @Test
    func format_canonical_pageFormatNamedByTypeEmitsMarginsFromSlotOne() throws {
        try assertCanonicalizes("[\\pageFormat<\"a4\",lm=1cm> c]",
                                to: "[\\pageFormat<\"a4\",1cm> c]")
    }

    @Test
    func format_canonical_parameterizedBarLineUsesTheLongForm() throws {
        // `measNum` is slot 1 and slot 0 is a gap, so rule 2 emits it named.
        try assertCanonicalizes("[c \\bar<measNum=4> d]",
                                to: "[c \\bar<measNum=4> d]")
    }

    // `\pedalOn` and `\breathMark` sit at the two extremes of rule 2's
    // positional-slot exception: the first inherits `kCommonParams` as its
    // positional
    // template, the second overrides `getParamsStr()` to `""` and has none.
    @Test
    func format_canonical_pedalEmitsCommonParametersPositionallyAndBreathMarkNamed() throws {
        try assertCanonicalizes("[\\pedalOn<color=\"red\"> c \\breathMark<dx=2hs> \\pedalOff]",
                                to: "[\\pedalOn<\"red\"> c \\breathMark<dx=2hs> \\pedalOff]")
    }

    // Unchanged: `Begin`/`End` form is never rewritten into range form
    // (rule 7).
    @Test
    func format_canonical_positionForm() throws {
        try assertCanonicalizes("[\\slurBegin c d \\slurEnd]",
                                to: "[\\slurBegin c d \\slurEnd]")
    }

    // CHANGED IN PHASE 4, and not as the plan expected. `tempo` and `bpm`
    // are slots 0 and 1 of `kARTempoParams`, so the positional prefix itself
    // is canonical (rule 2) — but `bpm` is declared `S`, and `ARTempo` reads
    // it with `getParameter<TagParameterString>` (`ARTempo.cpp:85`). A bare
    // `120` is a `TagParameterInt`, which that `dynamic_cast` returns null
    // for, so guidolib ignores it outright. It is an inert parameter and the
    // normalizer's repair step drops it.
    //
    // The surviving `"Allegro"` keeps its positional spelling because the
    // shortened list still binds it to `tempo`.
    @Test
    func format_canonical_positionWithParametersForm() throws {
        try assertCanonicalizes("[\\tempo<\"Allegro\",120> c]",
                                to: "[\\tempo<\"Allegro\"> c]")
    }

    // A bpm written the way `ARTempo::ParseBpm` actually reads it — as a
    // string — survives, and the positional prefix with it.
    @Test
    func format_canonical_positionWithParametersFormWithStringMetronome() throws {
        try assertCanonicalizes("[\\tempo<\"Allegro\",\"1/4=120\"> c]",
                                to: "[\\tempo<\"Allegro\",\"1/4=120\"> c]")
    }

    // Unchanged: range form is never rewritten into `Begin`/`End` form
    // (rule 7).
    @Test
    func format_canonical_rangeForm() throws {
        try assertCanonicalizes("[\\slur(c d e)]",
                                to: "[\\slur(c d e)]")
    }

    // The same repair where a *later* parameter survives: dropping the inert
    // `0.5` in place would rebind `"above"` from `position` to `type`, so
    // the survivor is restated named instead.
    @Test
    func format_canonical_rangeWithInertLeadingParameterForm() throws {
        try assertCanonicalizes("[\\staccato<0.5,\"above\">(c d)]",
                                to: "[\\staccato<position=\"above\">(c d)]")
    }

    // CHANGED IN PHASE 4. `kARStaccatoParams` has no slot that accepts a
    // float, so `TagParameterMap::get<T>`'s `dynamic_cast` reduces `0.5` to
    // null and guidolib reads the tag as a bare `\staccato`. The
    // normalizer's repair step drops the inert parameter and logs it as a
    // `Change`. `\staccato` itself is still untyped — this is the repair
    // acting on the `.generic` lane.
    @Test
    func format_canonical_rangeWithParametersForm() throws {
        try assertCanonicalizes("[\\staccato<0.5>(c d)]",
                                to: "[\\staccato(c d)]")
    }

    // `\tag` is not a name `ARFactory::createTag` dispatches, so it never
    // promotes and stays `.generic` forever. Its parameters used to be echoed
    // as written; a raw identifier is now dropped anyway, because the grammar
    // discards one below dispatch (`guido.y:188`) and so the repair needs no
    // template to justify it.
    @Test
    func format_canonical_rawNamedParameterForm() throws {
        try assertCanonicalizes("[\\tag<mode=rawIdent> c]",
                                to: "[\\tag c]")
    }

    @Test
    func format_canonical_referenceInSymbolPosition() throws {
        try assertCanonicalizes("$seq = \"c d e\";\n[$seq f]",
                                to: "$seq = \"c d e\";\n[$seq f]")
    }

    // The two positions diverge here. A symbol-position reference is a
    // textual macro nothing in IvorGuido splices, so it round-trips
    // untouched; a tag-parameter one is `varParam`'s typed substitution, so
    // the normalizer performs it and only the declaration is left to
    // round-trip.
    @Test
    func format_canonical_referenceInTagParameterPosition() throws {
        // CHANGED IN PHASE 4 — the body went away, for the same reason as
        // `newSystemEmitsCommonParametersPositionally`: `ARTempo` takes the
        // default `rangesetting = NO`. The substitution under test is in the
        // parameter list either way.
        try assertCanonicalizes("$x = \"Allegro\";\n[\\tempo<$x> c]",
                                to: "$x = \"Allegro\";\n[\\tempo<\"Allegro\"> c]")
    }

    // Substitution is by *declared* type, and the result is then judged like
    // anything else written there. `\tempo`'s first slot is `S`, so an `int`
    // variable lands ill-typed, `TagParameterMap::get<TagParameterString>`
    // casts it away, and the inert-parameter repair drops it — leaving a
    // `\tempo` guidolib reads as having no tempo at all, which is exactly what
    // guidolib does with it.
    //
    // FLIPPED IN PHASE 3: what that left is a `\tempo` missing its required
    // `tempo`, which is now a rejection rather than something to echo. The
    // reading order is unchanged and is what the rejection depends on —
    // substitute, judge, and only then refuse.
    @Test
    func format_canonical_referenceInTagParameterPositionIsJudgedAfterSubstitution() {
        expectRejected("$x = 120;\n[\\tempo<$x>(c)]",
                       .missingRequiredParameter(makeTagName("tempo"),
                                                 GMNTag.Parameter.Name("tempo")))
    }

    @Test
    func format_canonical_repeatEndEmitsItsBarParametersNamed() throws {
        try assertCanonicalizes("[c \\repeatEnd<measNum=5>]",
                                to: "[c \\repeatEnd<measNum=5>]")
    }

    @Test
    func format_canonical_restWithAndWithoutDuration() throws {
        try assertCanonicalizes("[c*1/2 _ _*1/8]",
                                to: "[c*1/2 _ _*1/8]")
    }

    @Test
    func format_canonical_segments() throws {
        try assertCanonicalizes("[{c,e,g}]",
                                to: "[{c,e,g}]")
    }

    @Test
    func format_canonical_segmentWithTag() throws {
        try assertCanonicalizes("[{\\accent(c),e,g}]",
                                to: "[{\\accent(c),e,g}]")
    }

    // `\segno` has no positional slots, so its supported parameters are
    // emitted named even though the identical `\coda` writes one positionally.
    @Test
    func format_canonical_segnoParametersAreAlwaysNamed() throws {
        try assertCanonicalizes("[\\segno<id=3> c]",
                                to: "[\\segno<id=3> c]")
    }

    // `\shareLocation` has no positional slots of its own, so everything it
    // carries is emitted named — the opposite of `\systemFormat` below.
    @Test
    func format_canonical_shareLocationParametersAreAlwaysNamed() throws {
        try assertCanonicalizes("[\\shareLocation<dx=2hs>(c e) ]",
                                to: "[\\shareLocation<dx=2hs>(c e)]")
    }

    @Test
    func format_canonical_slurEmitsItsWholeTemplatePositionally() throws {
        try assertCanonicalizes("[\\sl<\"down\",1hs,2hs,3hs,4hs,0.25,5hs>(c d)]",
                                to: "[\\slur<\"down\",1hs,2hs,3hs,4hs,0.25,5hs>(c d)]")
    }

    @Test
    func format_canonical_solfegeNames() throws {
        try assertCanonicalizes("[do re mi fa sol la si ti]",
                                to: "[do re mi fa sol la si ti]")
    }

    // Re-spelling this as `curve="up"` would be licensed by guidolib's
    // semantics, since it reads any `curve` other than `down` as up and the
    // two inputs are one score to it — but licensed is not required, and
    // re-spelling it would substitute one string for another with nothing
    // said. `\slur` declines to promote instead — as it already does for an
    // unreadable `position` — so there is nothing to echo, because the
    // score is refused. The two readings agree on everything except what to
    // do about it, and neither ever re-spells. The case lives in
    // `GMNNormalizerRejectionTests` with the behaviour —
    // `mechanism9_namesTheTagAndNotTheParameter`.

    // From the formatter's side: a span end emits nothing, not even the
    // `kCommonParams` its shared template nominally offers.
    @Test
    func format_canonical_spanEndsEmitNoParameters() throws {
        try assertCanonicalizes("[\\glissandoBegin:1 c \\glissandoEnd:1 \\tieBegin:2 d \\tieEnd:2]",
                                to: "[\\glissandoBegin:1 c \\glissandoEnd:1 \\tieBegin:2 d \\tieEnd:2]")
    }

    @Test
    func format_canonical_staccatoAliasCanonicalizesButItsSpanHalvesKeepTheShortName() throws {
        try assertCanonicalizes("[\\stacc(c) \\staccBegin d \\staccEnd e]",
                                to: "[\\staccato(c) \\staccBegin d \\staccEnd e]")
    }

    @Test
    func format_canonical_staffAndUnitsAndSpaceEmitTheirRequiredSlotPositionally() throws {
        try assertCanonicalizes("[\\staff<id=2> \\units<type=\"cm\"> \\space<dd=3cm> c]",
                                to: "[\\staff<2> \\units<\"cm\"> \\space<3cm> c]")
    }

    // `kARStaffFormatParams` redeclares `size` as a length, so the unit
    // survives the round trip rather than being read as a bare number.
    @Test
    func format_canonical_staffFormatSizeKeepsItsUnit() throws {
        try assertCanonicalizes("[\\staffFormat<size=4pt> c]",
                                to: "[\\staffFormat<size=4pt> c]")
    }

    @Test
    func format_canonical_stemsAndBeamStatesEmitWhatLittleTheyCarry() throws {
        try assertCanonicalizes("[\\beamsOff \\stemsUp<length=5hs> c \\stemsAuto]",
                                to: "[\\beamsOff \\stemsUp<5hs> c \\stemsAuto]")
    }

    @Test
    func format_canonical_stringEscape() throws {
        try assertCanonicalizes("$title = \"she said \\\"hi\\\"\";\n[c]",
                                to: "$title = \"she said \\\"hi\\\"\";\n[c]")
    }

    @Test
    func format_canonical_symbolAliasCanonicalizesAndKeepsItsFixedSize() throws {
        try assertCanonicalizes("[\\s<\"a.png\",w=20,h=30>]",
                                to: "[\\symbol<\"a.png\",w=20,h=30>]")
    }

    // `ARSystemFormat` inherits `kCommonParams` as its whole schema, so those
    // four names *are* its slots.
    @Test
    func format_canonical_systemFormatEmitsCommonParametersPositionally() throws {
        try assertCanonicalizes("[\\systemFormat<color=\"red\"> c]",
                                to: "[\\systemFormat<\"red\"> c]")
    }

    @Test
    func format_canonical_tempoChangeAliasesCanonicalizeButItsSpanHalvesDoNot() throws {
        try assertCanonicalizes("[\\rit(c d) \\accelBegin e \\accelEnd f]",
                                to: "[\\ritardando(c d) \\accelBegin e \\accelEnd f]")
    }

    // `bpm` is re-emitted from the parsed specification, not echoed.
    @Test
    func format_canonical_tempoMetronomeRoundTrips() throws {
        try assertCanonicalizes("[\\tempo<\"Allegro\",\"1/4=120\"> c]",
                                to: "[\\tempo<\"Allegro\",\"1/4=120\"> c]")
    }

    // `\label` and `\text` share a template but not a class — guidolib
    // dispatches on `typeid(ARLabel)` exactly — so only `\t` is an alias.
    @Test
    func format_canonical_textAliasCanonicalizesButLabelIsNotOne() throws {
        try assertCanonicalizes("[\\t<\"hi\"> \\label<\"there\">]",
                                to: "[\\text<\"hi\"> \\label<\"there\">]")
    }

    // `dy` is slot 1 of `kARTextParams`, so a text with no `dy` written must
    // switch to named at the gap — writing `"cb"` positionally there would
    // bind it to `dy` instead of `textformat`.
    @Test
    func format_canonical_textRestatesLaterSlotsNamedAcrossAGap() throws {
        try assertCanonicalizes("[\\text<\"hi\",textformat=\"cb\">]",
                                to: "[\\text<\"hi\",textformat=\"cb\">]")
    }

    // `ARDotFormat` and `ARRestFormat` override `getParamsStr()` to `""`,
    // so even their common parameters are always written named — while
    // `ARTHead` never overrides it at all and so writes them positionally.
    @Test
    func format_canonical_theZeroSlotFormattersEmitNamedAndTheHeadsPositionally() throws {
        try assertCanonicalizes("[\\dotFormat<color=\"red\"> \\restFormat<dy=1hs> \\headsLeft<\"red\">]",
                                to: "[\\dotFormat<color=\"red\"> \\restFormat<dy=1hs> \\headsLeft<\"red\">]")
    }

    // The positional index is the parameter's place in the *written* list,
    // not a running count of unnamed ones (`ARMusicalTag.cpp:85–107`). Here
    // `"on"` is written third, so it binds to slot 2 — `autoMeasuresNum` —
    // and the payload restates it under that name.
    //
    // CHANGED IN PHASE 3. The input was
    // `[\meter<hidden="on",dx=2hs,"4/4"> c]`, which binds `"4/4"` to
    // `autoMeasuresNum` and leaves the required `type` missing; the tag used
    // to stay generic and echo as written, and the score is refused now.
    // Writing `type` first keeps the same lesson with a tag that survives.
    @Test
    func format_canonical_trailingUnnamedParameterBindsByWrittenIndex() throws {
        try assertCanonicalizes("[\\meter<\"4/4\",dx=2hs,\"on\"> c]",
                                to: "[\\meter<\"4/4\",autoMeasuresNum=\"on\",dx=2hs> c]")
    }

    // `\tremolo` is the counterexample: `Tags.cpp` declares the long
    // spelling for all three forms, so rule 1 does apply throughout.
    @Test
    func format_canonical_tremoloSpanHalvesTakeTheirLongNames() throws {
        try assertCanonicalizes("[\\tremBegin c \\tremEnd d]",
                                to: "[\\tremoloBegin c \\tremoloEnd d]")
    }

    // Rule 4: a repeated name collapses, last one wins.
    @Test
    func format_canonical_typedTagDuplicateParametersCollapse() throws {
        try assertCanonicalizes("[\\key<\"D\",key=\"G\"> c]",
                                to: "[\\key<\"G\"> c]")
    }

    // Rule 2's gap: `autoBarlines` is slot 1, so once slot 0 is the only
    // positional one written, everything after a skipped slot is named.
    @Test
    func format_canonical_typedTagGapEndsPositionalRun() throws {
        try assertCanonicalizes("[\\meter<\"4/4\",group=\"on\"> c]",
                                to: "[\\meter<\"4/4\",group=\"on\"> c]")
    }

    // A whole-number magnitude is written without a fractional part, and the
    // unit survives.
    @Test
    func format_canonical_typedTagLengthKeepsItsUnit() throws {
        try assertCanonicalizes("[\\cluster<hdx=2hs,hdy=-1.5pt>(c e)]",
                                to: "[\\cluster<2hs,-1.5pt>(c e)]")
    }

    // Rule 2, the positional prefix: `key` is slot 0 of `kARKeyParams`, so a
    // named spelling of it collapses back to positional.
    @Test
    func format_canonical_typedTagNamedParameterBecomesPositional() throws {
        try assertCanonicalizes("[\\key<key=\"D\"> c]",
                                to: "[\\key<\"D\"> c]")
    }

    // Rule 1: the case *is* the canonical identity, so an alias can no longer
    // reach the formatter at all.
    @Test(arguments: [("\\acc", "\\accidental"),
                      ("\\accidental", "\\accidental"),
                      ("\\oct<1>", "\\octava<1>"),
                      ("\\octava<1>", "\\octava<1>"),
                      ("\\dispDur<1,4>", "\\displayDuration<1,4>"),
                      ("\\displayDuration<1,4>", "\\displayDuration<1,4>")])
    func format_canonical_typedTagNamesAreCanonical(_ pair: (input: String, expected: String)) throws {
        try assertCanonicalizes("[\(pair.input)(c d)]",
                                to: "[\(pair.expected)(c d)]")
    }

    // Rule 3: parameters come back in template order however they were
    // written, and `kCommonParams` sorts last — `hidden` is slot 4 of
    // `kARMeterParams`, `dx` has no slot at all.
    @Test
    func format_canonical_typedTagParametersAreReordered() throws {
        try assertCanonicalizes("[\\meter<\"4/4\",dx=2hs,hidden=\"on\"> c]",
                                to: "[\\meter<\"4/4\",hidden=\"on\",dx=2hs> c]")
    }

    // Rule 7: the `Begin`/`End` form is preserved rather than folded into
    // the range form, and `\tupletEnd` carries no parameters.
    @Test
    func format_canonical_typedTagSpanFormIsPreserved() throws {
        try assertCanonicalizes("[\\tupletBegin:1<\"3:2\"> c d e \\tupletEnd:1]",
                                to: "[\\tupletBegin:1<\"3:2\"> c d e \\tupletEnd:1]")
    }

    // A `$variable` in tag-parameter position is substituted by its declared
    // value, matching `varParam`. The declaration survives — expanding in the
    // parser instead would leave it dangling and destroy round-tripping.
    @Test
    func format_canonical_variableParameterIsExpanded() throws {
        try assertCanonicalizes("$n = 2;\n[\\mrest<$n>(_)]",
                                to: "$n = 2;\n[\\mrest<2>(_)]")
    }

    @Test
    func format_canonical_voltaKeepsItsSpanFormAndIdentifier() throws {
        try assertCanonicalizes("[\\voltaBegin:1<\"1.\"> c \\voltaEnd:1]",
                                to: "[\\voltaBegin:1<\"1.\"> c \\voltaEnd:1]")
    }

    @Test
    func format_isStable_chords() throws {
        try assertIsStable("[{c,e,g} {\\accent(c),e,g}]")
    }

    @Test
    func format_isStable_multipleVoices() throws {
        try assertIsStable("{[c d e], [g a b]}")
    }

    @Test
    func format_isStable_notesAndRests() throws {
        try assertIsStable("[c*1/2 _ d#2*3/4. _*1/8]")
    }

    @Test
    func format_isStable_tablature() throws {
        try assertIsStable("[s1:4: s2:x:*1/8]")
    }

    @Test
    func format_isStable_tagsInBothForms() throws {
        try assertIsStable("[\\slur(c d e) \\tieBegin:1 c \\tieEnd:1 d]")
    }

    @Test
    func format_isStable_tagsWithParameters() throws {
        try assertIsStable("[\\tempo<\"Allegro\",120> \\staffFormat<dx=5hs,dy=-2.5pt> c | d]")
    }

    @Test
    func format_isStable_typedTags() throws {
        try assertIsStable("[\\key<\"D\"> \\meter<\"4/4\",hidden=\"on\"> \\octava<1,dx=2hs>(c d) \\cluster<2hs>(c e)]")
    }

    @Test
    func format_isStable_typedTagsFromBucketB() throws {
        try assertIsStable("[\\clef<\"bass\"> \\instrument<\"Horn\",MIDI=61> \\harmony<\"Cmaj7\",-2hs> c | d]")
    }

    @Test
    func format_isStable_typedTagsFromBucketBPartTwo() throws {
        try assertIsStable("[\\pageFormat<\"a4\",1cm> \\staffFormat<size=4pt> "
                            + "\\tempo<\"Allegro\",\"1/4=120\"> \\staff<2> c]")
    }

    @Test
    func format_isStable_typedTagsFromBucketC() throws {
        try assertIsStable("[\\slur<\"down\",1hs,2hs,3hs,4hs,0.25,5hs>(c d) "
                            + "\\intensity<\"pp\",font=\"Arial\"> \\arpeggio<\"up\">({c,e,g})]")
    }

    @Test
    func format_isStable_typedTagsFromBucketCNestedInEachOther() throws {
        // A decoration's body is rebuilt through the promoter when it
        // promotes to a typed Bucket C payload, so a nested one must
        // survive.
        try assertIsStable("[\\slur(\\stacc(c) \\trill<\"d\">(e)) f]")
    }

    @Test
    func format_isStable_typedTagsFromBucketCSpanning() throws {
        // The three asymmetric span-name families in one score: `\crescendo`
        // and `\accelerando` keep their short open halves, `\tremolo` takes
        // its long ones, and `\stacc` has no long form at all.
        try assertIsStable("[\\crescBegin c \\crescEnd \\accelBegin d \\accelEnd "
                            + "\\tremoloBegin e \\tremoloEnd \\staccBegin f \\staccEnd]")
    }

    @Test
    func format_isStable_typedTagsFromBucketD() throws {
        try assertIsStable("[\\title<\"Sonata\",\"c1\"> \\composer<\"Bach\"> "
                            + "\\beam<2hs,1hs>(c d) \\text<\"hi\",-2hs> \\color<\"red\"> e]")
    }

    @Test
    func format_isStable_typedTagsFromBucketDNestedInEachOther() throws {
        try assertIsStable("[\\beam(\\noteFormat<\"diamond\">(c) \\stemsUp<5hs>(d)) \\lyrics<\"la\">(e)]")
    }

    @Test
    func format_isStable_typedTagsFromBucketDWithNothingToEmit() throws {
        // Five payloads whose stability rests on emitting nothing at all —
        // three that accept no parameter and two whose every parameter is
        // named.
        try assertIsStable("[\\beamsOff \\stemsAuto \\dotFormat \\restFormat \\headsNormal c]")
    }

    @Test
    func format_isStable_typedTagsInBothSpanForms() throws {
        try assertIsStable("[\\tuplet<\"-3-\">(c d e) \\tupletBegin:1<\"3:2\"> c d \\tupletEnd:1]")
    }

    @Test
    func format_isStable_typedTagsNestedInABucketBBody() throws {
        try assertIsStable("[\\cue<\"flute\">(\\acc(c/8) \\oct<1>(d/8)) e]")
    }

    @Test
    func format_isStable_typedTagsNestedInEachOther() throws {
        // The normalizer rebuilds a typed tag through the promoter in order
        // to edit its body, so a nested alias must still canonicalize.
        try assertIsStable("[\\grace(\\acc(c/16) d/16) e]")
    }

    @Test
    func format_isStable_typedTagsSpanningAndSwitching() throws {
        try assertIsStable("[\\repeatBegin \\staffOff c \\staffOn "
                            + "\\voltaBegin:1<\"1.\"> d \\voltaEnd:1 \\repeatEnd]")
    }

    @Test
    func format_isStable_typedTagsWithNoParametersAtAll() throws {
        // `\merge` and `\newPage` accept none, and a bare `\bar` is written
        // `|` — three payloads whose stability rests on emitting nothing.
        try assertIsStable("[\\newPage \\merge(c e) \\coda \\barFormat c]")
    }

    @Test
    func format_isStable_typedTagsWithTheOtherPageFormatTemplate() throws {
        // The by-size half has to survive the round trip through a payload
        // whose parameters are all named and unordered.
        try assertIsStable("[\\pageFormat<21cm,29.7cm,1cm,2cm,3cm,4cm> c]")
    }

    @Test
    func format_isStable_variables() throws {
        // `\tempo<$x>` was the tag here until this became a rejection. An
        // `int` substituted into `\tempo`'s `S` slot is inert, so the repair drops
        // it and the required `tempo` is left missing — which is a rejection
        // now, and so cannot be a stability fixture. `size` is `F`, so `$x`
        // lands in a slot that reads it.
        try assertIsStable("$x = 120;\n$title = \"My Song\";\n$seq = \"c d e\";\n[$seq \\beam<size=$x>(c d)]")
    }

    @Test
    func format_notValidated_throws() {
        let score = makeScore([], [makeVoice()])

        #expect(throws: GMNFormatter.Error.notValidated) {
            try GMNFormatter().format(score)
        }
    }

    @Test
    func format_validatedScore_returnsData() throws {
        let score = makeScore([], [makeVoice()])
        let (normalized, _) = GMNNormalizer().normalize(score)
        let (validated, _) = try GMNValidator().validate(normalized)
        let data = try GMNFormatter().format(validated)

        #expect(String(data: data, encoding: .utf8) == "[]")
    }

    // No fret-escape case: guidolib's fret-string lexer (`guido.l` `FRETTE`)
    // only tokenizes `\` followed by `:` or ` `. `\ ` decodes to a bare
    // space, which needs no escaping on the way back out (the backslash is
    // dropped); `\:` is unrecognized, so guidolib's passthrough keeps *both*
    // characters literally, and the formatter must then conservatively
    // re-escape each of them individually. Neither lexically valid form is
    // its own canonical spelling — an inherent asymmetry in the fret grammar
    // itself, not a formatter defect. `stringEscape()` below demonstrates
    // the escaping mechanism using the much more permissive string-value
    // grammar instead.
}
