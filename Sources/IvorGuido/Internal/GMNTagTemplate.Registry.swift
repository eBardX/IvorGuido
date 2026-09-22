// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagTemplate {

    // MARK: Internal Nested Types

    // Every tag name guidolib dispatches, mapped to its class's template.
    //
    // Built by walking `ARFactory::createTag` (`ARFactory.cpp:606–1650`) for
    // name → class, then each class for its own `getParamsStr()`, its
    // `setupTagParameters` chain, and its `rangesetting`. Four hazards
    // govern the transcription:
    //
    //   1. **`createTag` is the authority, not `Tags.cpp`.** `Tags.cpp`
    //      declares 162 name constants, but `createTag` dispatches two more
    //      as bare literals — `"DrHoos"` and `"DrRenz"` (`:1613,:1619`) —
    //      and leaves four of the 162 undispatched: `\bembel`,
    //      `\shortFermata` (its branch is commented out, `:1298–1305`),
    //      `\splitChord`, and `\chord`. Those four are absent here, so
    //      `template(for:)` returns `nil` and they stay `.custom`. The
    //      third literal, `"..."` (`:1625`), cannot be a `GMNTag.Name` at
    //      all and so cannot appear either.
    //   2. **Transcribe per class, never per hierarchy.** `ARSegno : ARJump`
    //      overrides `getParamsStr()` to `""` while still *supporting*
    //      `kARJumpParams` — hence the empty `slotSpecification` alongside a
    //      non-empty `parameterSpecifications`.
    //   3. **`\bowing` and `\dynamic` are not names.** They are abstract
    //      bases; only the names their subclasses are dispatched under
    //      appear here.
    //   4. **`\tie` shares `kARBowingParams` with `\slur` verbatim** — it is
    //      an `ARBowing` subclass, not a timing tag.
    internal enum Registry {
    }
}

// MARK: -

extension GMNTagTemplate.Registry {

    // MARK: Internal Type Properties

    // Every dispatched tag name the registry knows.
    internal static let names = Set(Self.templatesByName.keys)

    // Every name `ARFactory::createTag` dispatches to an
    // `ARDummyRangeEnd` — the closing half of an open span, and the whole
    // of ``GMNTag/Span/end``.
    //
    // This is also the authority for which names are *opening* halves:
    // `\repeatBegin` reads like one but is not, because `\repeatEnd` is an
    // `ARRepeatEnd` of its own rather than a range end.
    internal static let rangeEndNames: Set<String> = ["accelEnd",
                                                      "beamEnd",
                                                      "crescEnd",
                                                      "decrescEnd",
                                                      "dimEnd",
                                                      "diminuendoEnd",
                                                      "fBeamEnd",
                                                      "glissandoEnd",
                                                      "ritEnd",
                                                      "slurEnd",
                                                      "staccEnd",
                                                      "tieEnd",
                                                      "tremEnd",
                                                      "tremoloEnd",
                                                      "trillEnd",
                                                      "tupletEnd",
                                                      "voltaEnd"]

    // MARK: Internal Type Methods

    // Returns which part of a spanning construct the given name is.
    //
    // Derived from ``rangeEndNames`` rather than from a second table: a
    // name is an opening half exactly when replacing its `Begin` suffix
    // with `End` names an `ARDummyRangeEnd`. That is what excludes
    // `\repeatBegin`, whose counterpart is a real tag with its own
    // parameters.
    internal static func span(of name: GMNTag.Name) -> GMNTag.Span {
        let stringValue = name.stringValue

        if Self.rangeEndNames.contains(stringValue) {
            return .end
        }

        guard stringValue.hasSuffix("Begin")
        else { return .whole }

        let base = stringValue.dropLast("Begin".count)

        return Self.rangeEndNames.contains(base + "End") ? .begin : .whole
    }

    // Returns the template for the given tag name, or `nil` if guidolib
    // does not dispatch it.
    //
    // A `nil` result is not an error: it is precisely the set of names
    // that must remain `.custom`.
    //
    // `parameters` matters for exactly one name. `\pageFormat` overrides
    // `checkTagParameters` and builds its positional template from what
    // was written (`ARPageFormat.cpp:136–149`), so a caller that is
    // about to bind — or to emit — must say what it has. Every other
    // name ignores the argument, which is why it defaults to none.
    internal static func template(for name: GMNTag.Name,
                                  parameters: [GMNTag.Parameter] = []) -> GMNTagTemplate? {
        if name.stringValue == "pageFormat",
           _isPageFormatNamedByType(parameters) {
            return pageFormatByTypeTemplate
        }

        return templatesByName[name.stringValue]
    }

    // MARK: Private Type Properties

    // `\pageFormat`'s other template — the one guidolib builds when the
    // page is named rather than measured. See
    // `GMNTagTemplate.Specification.arPageFormatByType`.
    private static let pageFormatByTypeTemplate =
        GMNTagTemplate(slotSpecification: Specification.arPageFormatByType,
                       parameterSpecifications: [Specification.arPageFormatByType],
                       rangeSetting: .no)

    // MARK: Private Type Methods

    // Whether a `\pageFormat` carrying these parameters names its page
    // instead of measuring it.
    //
    // guidolib's own test is `params.size() && params[0]->isString()`
    // (`ARPageFormat.cpp:140`) — the *first written* parameter, named or
    // not. That test cannot be used verbatim here, because the formatter
    // asks the same question of a payload, whose parameters are all
    // named and carry no meaningful order. The rule below agrees with
    // guidolib's wherever a `\pageFormat` binds cleanly at all:
    //
    //   - `type` is required in the by-type template and *removed* from
    //     the other, so a promoted by-type payload always carries it and
    //     a by-size one never can. That settles every all-named list.
    //   - A leading unnamed string is guidolib's test unchanged, and
    //     settles `\pageFormat<"A4",1cm>`.
    //
    // The one written form the two rules disagree on is a list whose
    // first parameter is a *named* string yet which measures the page,
    // as in `\pageFormat<color="red",21cm,29.7cm>`. guidolib picks the
    // by-type template there, fails `checkRequired` on the missing
    // `type`, warns — and then reads `w` and `h` out of the map anyway,
    // because `getParameter` consults the bound values and not the
    // template. So it behaves exactly as the by-size reading, which is
    // what this promotes to.
    private static func _isPageFormatNamedByType(_ parameters: [GMNTag.Parameter]) -> Bool {
        if parameters.contains(where: { $0.name?.stringValue == "type" }) {
            return true
        }

        guard let first = parameters.first,
              first.name == nil,
              case .string = first.value
        else { return false }

        return true
    }
}

// MARK: -

extension GMNTagTemplate.Registry {

    // MARK: Internal Type Aliases

    // One row of the transcription: the names guidolib dispatches to a class,
    // and that class's template.
    internal typealias Entry = (names: [String], template: GMNTagTemplate)

    // MARK: Internal Type Properties

    // The transcription itself, before it is flattened into a lookup.
    //
    // Internal rather than private so the consistency test can check that no
    // name is declared twice — a duplicate would otherwise vanish silently
    // into the dictionary, taking one of the two templates with it.
    //
    // One entry per guidolib class, or per set of classes sharing an
    // identical shape. The comment on each entry names the class or classes
    // it transcribes. The rows are split across several builders purely to
    // keep each one within SwiftLint's function-length budget; the split
    // points carry no meaning.
    //
    // A `slotSpecification` of `Specification.common` is not a shorthand for
    // "no slots": it means the class never overrides `getParamsStr()`, so
    // `ARMusicalTag`'s base implementation (`ARMusicalTag.h:61`) hands
    // `kCommonParams` itself to `checkTagParameters`, and `color`/`dx`/`dy`/
    // `size` really are that tag's positional slots. Contrast the classes
    // that override it to `""` and have no positional slots at all.
    internal static let entries: [Entry] = {
        var entries: [Entry] = []

        Self._addFirst(to: &entries)
        Self._addSecond(to: &entries)
        Self._addThird(to: &entries)
        Self._addFourth(to: &entries)
        Self._addFifth(to: &entries)

        return entries
    }()

    // MARK: Private Type Aliases

    // Shorthand, so each entry below reads close to the guidolib source it
    // transcribes.
    private typealias Specification = GMNTagTemplate.Specification

    // MARK: Private Type Properties

    private static let templatesByName: [String: GMNTagTemplate] = {
        var result: [String: GMNTagTemplate] = [:]

        for entry in Self.entries {
            for name in entry.names {
                result[name] = entry.template
            }
        }

        return result
    }()

    // MARK: Private Type Methods

    private static func _addFifth(to entries: inout [Entry]) {
        // ARStaffFormat.
        entries.append((["staffFormat"],
                        GMNTagTemplate(slotSpecification: Specification.arStaffFormat,
                                       parameterSpecifications: [Specification.arStaffFormat],
                                       rangeSetting: .no)))

        // ARStaffOff, ARStaffOn — zero positional slots
        // (`ARStaffOff.h:51`, `ARStaffOn.h:47`).
        entries.append((["staffOff", "staffOn"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARTStem, `ARTStem.cpp:30`.
        entries.append((["stemsAuto", "stemsDown", "stemsOff", "stemsUp"],
                        GMNTagTemplate(slotSpecification: Specification.arTStem,
                                       parameterSpecifications: [Specification.arTStem],
                                       rangeSetting: .either)))

        // ARSymbol, `ARSymbol.cpp:28`.
        entries.append((["s", "symbol"],
                        GMNTagTemplate(slotSpecification: Specification.arSymbol,
                                       parameterSpecifications: [Specification.arSymbol],
                                       rangeSetting: .either)))

        // ARSystemFormat — no template of its own and no map, so
        // `kCommonParams` is the whole schema (`ARSystemFormat.h:45–56`).
        entries.append((["systemFormat"],
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARTempo : ARFontAble.
        entries.append((["tempo"],
                        GMNTagTemplate(slotSpecification: Specification.arTempo,
                                       parameterSpecifications: [Specification.fontAble, Specification.arTempo],
                                       rangeSetting: .no)))

        // ARLabel, ARText — `ARLabel` explicitly returns `kARTextParams`
        // (`ARLabel.h:29`) and adds nothing. `ARText.cpp:39`.
        entries.append((["label", "t", "text"],
                        GMNTagTemplate(slotSpecification: Specification.arText,
                                       parameterSpecifications: [Specification.fontAble, Specification.arText],
                                       rangeSetting: .either)))

        // ARTitle : ARText, `ARTitle.cpp:28`.
        //
        // Both `\title` and `\composer` call
        // `clearTagDefaultParameter(kTextStr)` immediately after
        // `setupTagParameters` (`ARTitle.cpp:31`, `ARComposer.cpp:30`),
        // removing the `text` they would otherwise inherit from `ARText` —
        // guidolib's own comment says it is "to avoid a warning regarding
        // inherited required parameter". Without that removal `text` would
        // still be *required* here, and every `\title<"…">` ever written would
        // fail `checkRequired` and stay reserved. `\footer` has the same line
        // commented out (`ARFooter.cpp:29`), but declares `text` as its own
        // required slot 0 regardless, so it is unaffected either way.
        entries.append((["title"],
                        GMNTagTemplate(slotSpecification: Specification.arTitle,
                                       parameterSpecifications: [Specification.fontAble,
                                                                 Specification.arText,
                                                                 Specification.arTitle],
                                       clearedParameterNames: ["text"],
                                       rangeSetting: .no)))

        // ARTremolo, `ARTremolo.cpp:42`.
        entries.append((["trem", "tremBegin", "tremolo", "tremoloBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arTremolo,
                                       parameterSpecifications: [Specification.arTremolo],
                                       rangeSetting: .only)))

        // ARTrill — one class for all three ornaments (`ARTrill.cpp:34`).
        entries.append((["mord", "mordent", "trill", "trillBegin", "turn"],
                        GMNTagTemplate(slotSpecification: Specification.arTrill,
                                       parameterSpecifications: [Specification.arTrill],
                                       rangeSetting: .only)))

        // ARTuplet, `ARTuplet.cpp:39`.
        entries.append((["tuplet", "tupletBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arTuplet,
                                       parameterSpecifications: [Specification.arTuplet],
                                       rangeSetting: .only)))

        // ARUnits.
        entries.append((["units"],
                        GMNTagTemplate(slotSpecification: Specification.arUnits,
                                       parameterSpecifications: [Specification.arUnits],
                                       rangeSetting: .no)))

        // ARVolta, `ARVolta.cpp:28`.
        entries.append((["volta", "voltaBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arVolta,
                                       parameterSpecifications: [Specification.arVolta],
                                       rangeSetting: .only)))
    }

    private static func _addFirst(to entries: inout [Entry]) {
        // ARAccelerando (`TempoChange : ARFontAble`), `ARAccelerando.cpp:25`.
        entries.append((["accel", "accelBegin", "accelerando"],
                        GMNTagTemplate(slotSpecification: Specification.arAccelerando,
                                       parameterSpecifications: [Specification.fontAble, Specification.arAccelerando],
                                       rangeSetting: .only)))

        // ARAccidental, `ARAccidental.cpp:27`.
        entries.append((["acc", "accidental"],
                        GMNTagTemplate(slotSpecification: Specification.arAccidental,
                                       parameterSpecifications: [Specification.arAccidental],
                                       rangeSetting: .only)))

        // ARAccent, ARHarmonic, ARMarcato, ARTenuto — pure `ARArticulation`
        // subclasses adding neither a template nor a map.
        entries.append((["accent", "harmonic", "marcato", "ten", "tenuto"],
                        GMNTagTemplate(slotSpecification: Specification.arArticulation,
                                       parameterSpecifications: [Specification.arArticulation],
                                       rangeSetting: .only)))

        // ARAccolade.
        entries.append((["accol", "accolade"],
                        GMNTagTemplate(slotSpecification: Specification.arAccolade,
                                       parameterSpecifications: [Specification.arAccolade],
                                       rangeSetting: .no)))

        // ARAlter, `ARAlter.cpp:32`.
        entries.append((["alter"],
                        GMNTagTemplate(slotSpecification: Specification.arAlter,
                                       parameterSpecifications: [Specification.arAlter],
                                       rangeSetting: .either)))

        // ARArpeggio, `ARArpeggio.cpp:26`.
        entries.append((["arpeggio"],
                        GMNTagTemplate(slotSpecification: Specification.arArpeggio,
                                       parameterSpecifications: [Specification.arArpeggio],
                                       rangeSetting: .only)))

        // ARAuto — `\set` is dispatched to the same class (`:1123`).
        entries.append((["auto", "set"],
                        GMNTagTemplate(slotSpecification: Specification.arAuto,
                                       parameterSpecifications: [Specification.arAuto],
                                       rangeSetting: .no)))

        // ARBar, ARDoubleBar, ARFinishBar (`ARFinishBar.h:44`). `"|"` is
        // here because `guido.y:180` rewrites the bare token to `\bar` with
        // no parameters and no ident.
        entries.append((["|", "bar", "doubleBar", "endBar"],
                        GMNTagTemplate(slotSpecification: Specification.arBar,
                                       parameterSpecifications: [Specification.arBar],
                                       rangeSetting: .no)))

        // ARBarFormat.
        entries.append((["barFormat"],
                        GMNTagTemplate(slotSpecification: Specification.arBarFormat,
                                       parameterSpecifications: [Specification.arBarFormat],
                                       rangeSetting: .no)))

        // ARBeam, `ARBeam.cpp:27`.
        entries.append((["b", "beam", "beamBegin", "bm"],
                        GMNTagTemplate(slotSpecification: Specification.arBeam,
                                       parameterSpecifications: [Specification.arBeam],
                                       rangeSetting: .only)))

        // ARBeamState — zero positional slots (`ARBeamState.h:60`), and not
        // an `ARMTParameter`, so written parameters are discarded outright.
        entries.append((["beamsAuto", "beamsFull", "beamsOff"],
                        GMNTagTemplate(acceptsParameters: false,
                                       slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARBow : ARArticulation, `ARBow.cpp:29`.
        entries.append((["bow"],
                        GMNTagTemplate(slotSpecification: Specification.arBow,
                                       parameterSpecifications: [Specification.arArticulation, Specification.arBow],
                                       rangeSetting: .either)))

        // ARBreathMark — zero positional slots (`ARBreathMark.h:42`).
        entries.append((["breathMark"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARClef.
        entries.append((["clef"],
                        GMNTagTemplate(slotSpecification: Specification.arClef,
                                       parameterSpecifications: [Specification.arClef],
                                       rangeSetting: .no)))

        // ARCluster, `ARCluster.cpp:28`.
        entries.append((["cluster"],
                        GMNTagTemplate(slotSpecification: Specification.arCluster,
                                       parameterSpecifications: [Specification.arCluster],
                                       rangeSetting: .only)))
    }

    private static func _addFourth(to entries: inout [Entry]) {
        // AROctava, `AROctava.cpp:28`.
        entries.append((["oct", "octava"],
                        GMNTagTemplate(slotSpecification: Specification.arOctava,
                                       parameterSpecifications: [Specification.arOctava],
                                       rangeSetting: .either)))

        // ARPageFormat — the by-size half of a template guidolib picks per
        // tag; `template(for:parameters:)` returns the other half when the
        // page is named. This is also what a `\pageFormat` with no
        // parameters at all binds against, matching `ARPageFormat.cpp:145`,
        // where an empty list takes the `else` branch.
        entries.append((["pageFormat"],
                        GMNTagTemplate(slotSpecification: Specification.arPageFormatBySize,
                                       parameterSpecifications: [Specification.arPageFormatBySize],
                                       rangeSetting: .no)))

        // ARPizzicato : ARArticulation, `ARPizzicato.cpp:32`.
        entries.append((["pizz", "pizzicato"],
                        GMNTagTemplate(slotSpecification: Specification.arPizzicato,
                                       parameterSpecifications: [Specification.arArticulation, Specification.arPizzicato],
                                       rangeSetting: .only)))

        // ARTDummy — `\port` is dispatched to a genuine no-op
        // (`ARFactory.cpp:1212`) rather than falling through, so it is a
        // known name with the base schema. `ARTDummy` is not an
        // `ARMTParameter`, so its parameters are discarded too.
        entries.append((["port"],
                        GMNTagTemplate(acceptsParameters: false,
                                       slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARRepeatBegin — inherits `getParamsStr()`, adds `sARRepeatMap`
        // (`ARRepeatBegin.cpp:23`).
        entries.append((["repeatBegin"],
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [Specification.arRepeat],
                                       rangeSetting: .no)))

        // ARRepeatEnd : ARBar — binds positions against `kARBarParams`,
        // supports `kARRepeatParams` too (`ARRepeatEnd.h:44`).
        entries.append((["repeatEnd"],
                        GMNTagTemplate(slotSpecification: Specification.arBar,
                                       parameterSpecifications: [Specification.arBar, Specification.arRepeat],
                                       rangeSetting: .either)))

        // ARRestFormat — zero positional slots (`ARRestFormat.h:54`),
        // `ARRestFormat.h:47`.
        entries.append((["restFormat"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .either)))

        // ARRitardando (`TempoChange : ARFontAble`), `ARRitardando.cpp:26`.
        entries.append((["rit", "ritBegin", "ritardando"],
                        GMNTagTemplate(slotSpecification: Specification.arRitardando,
                                       parameterSpecifications: [Specification.fontAble, Specification.arRitardando],
                                       rangeSetting: .only)))

        // ARSegno : ARJump — a transcription trap. Overrides `getParamsStr()`
        // to `""` (`ARSegno.h:42`) while still supporting `kARJumpParams`,
        // so `m` and `id` must always be written named.
        entries.append((["segno"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [Specification.arJump],
                                       rangeSetting: .no)))

        // ARShareLocation — zero positional slots (`ARShareLocation.h:33`),
        // `ARShareLocation.h:29`.
        entries.append((["shareLocation"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .only)))

        // ARSlur, ARTie — both `ARBowing`, verbatim the same shape
        // (`ARBowing.cpp:29`).
        entries.append((["sl", "slur", "slurBegin", "tie", "tieBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arBowing,
                                       parameterSpecifications: [Specification.arBowing],
                                       rangeSetting: .only)))

        // ARSpace.
        entries.append((["space"],
                        GMNTagTemplate(slotSpecification: Specification.arSpace,
                                       parameterSpecifications: [Specification.arSpace],
                                       rangeSetting: .no)))

        // ARSpecial.
        entries.append((["special"],
                        GMNTagTemplate(slotSpecification: Specification.arSpecial,
                                       parameterSpecifications: [Specification.arSpecial],
                                       rangeSetting: .no)))

        // ARStaccato : ARArticulation — inherits `ARArticulation`'s `ONLY`.
        entries.append((["stacc", "staccBegin", "staccato"],
                        GMNTagTemplate(slotSpecification: Specification.arStaccato,
                                       parameterSpecifications: [Specification.arArticulation, Specification.arStaccato],
                                       rangeSetting: .only)))

        // ARStaff. `id` is read as an int and then as a string
        // (`ARStaff.cpp:50–64`).
        entries.append((["staff"],
                        GMNTagTemplate(slotSpecification: Specification.arStaff,
                                       parameterSpecifications: [Specification.arStaff],
                                       rangeSetting: .no,
                                       alternateParameterKinds: ["id": .string])))
    }

    private static func _addSecond(to entries: inout [Entry]) {
        // ARColor.
        entries.append((["color", "colour"],
                        GMNTagTemplate(slotSpecification: Specification.arColor,
                                       parameterSpecifications: [Specification.arColor],
                                       rangeSetting: .no)))

        // ARComposer : ARText : ARFontAble, `ARComposer.cpp:27`, which takes
        // `text` back out of the inherited set — see `\title` below.
        entries.append((["composer"],
                        GMNTagTemplate(slotSpecification: Specification.arComposer,
                                       parameterSpecifications: [Specification.fontAble,
                                                                 Specification.arText,
                                                                 Specification.arComposer],
                                       clearedParameterNames: ["text"],
                                       rangeSetting: .no)))

        // ARCrescendo, ARDiminuendo — both `ARDynamic`, `ARDynamic.cpp:30`.
        entries.append((["cresc",
                         "crescBegin",
                         "crescendo",
                         "decresc",
                         "decrescBegin",
                         "decrescendo",
                         "dim",
                         "dimBegin",
                         "diminuendo",
                         "diminuendoBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arDynamic,
                                       parameterSpecifications: [Specification.arDynamic],
                                       rangeSetting: .only)))

        // ARCue : ARFontAble, `ARCue.cpp:25`.
        entries.append((["cue"],
                        GMNTagTemplate(slotSpecification: Specification.arCue,
                                       parameterSpecifications: [Specification.fontAble, Specification.arCue],
                                       rangeSetting: .only)))

        // ARDisplayDuration, `ARDisplayDuration.cpp:27`.
        entries.append((["dispDur", "displayDuration"],
                        GMNTagTemplate(slotSpecification: Specification.arDisplayDuration,
                                       parameterSpecifications: [Specification.arDisplayDuration],
                                       rangeSetting: .only)))

        // ARDotFormat — zero positional slots (`ARDotFormat.h:47`),
        // `ARDotFormat.cpp:26`.
        entries.append((["dotFormat"],
                        GMNTagTemplate(slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .either)))

        // ARDrHoos — literal-dispatched, `ARFactory.cpp:1613`.
        entries.append((["DrHoos"],
                        GMNTagTemplate(slotSpecification: Specification.arDrHoos,
                                       parameterSpecifications: [Specification.arDrHoos],
                                       rangeSetting: .no)))

        // ARDrRenz — literal-dispatched, `ARFactory.cpp:1619`.
        entries.append((["DrRenz"],
                        GMNTagTemplate(slotSpecification: Specification.arDrRenz,
                                       parameterSpecifications: [Specification.arDrRenz],
                                       rangeSetting: .no)))

        // ARDummyRangeEnd : ARTagEnd — inherits `getParamsStr()`, so its
        // positional slots are `kCommonParams`. It supports nothing beyond
        // them, which is why a closing half carries no parameters.
        entries.append((rangeEndNames.sorted(),
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARFeatheredBeam : ARBeam, `ARFeatheredBeam.cpp:31`.
        entries.append((["fBeam", "fBeamBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arFeatheredBeam,
                                       parameterSpecifications: [Specification.arBeam, Specification.arFeatheredBeam],
                                       rangeSetting: .only)))

        // ARFermata : ARArticulation, `ARFermata.cpp:30`.
        entries.append((["fermata"],
                        GMNTagTemplate(slotSpecification: Specification.arFermata,
                                       parameterSpecifications: [Specification.arArticulation, Specification.arFermata],
                                       rangeSetting: .either)))

        // ARFingering : ARText — binds positions against `kARTextParams`
        // (inherited `getParamsStr()`) while supporting `kARFingeringParams`
        // on top. `ARFingering.cpp:26`.
        entries.append((["fing", "fingering"],
                        GMNTagTemplate(slotSpecification: Specification.arText,
                                       parameterSpecifications: [Specification.fontAble,
                                                                 Specification.arText,
                                                                 Specification.arFingering],
                                       rangeSetting: .only)))

        // ARFooter : ARText, `ARFooter.cpp:27`.
        entries.append((["footer"],
                        GMNTagTemplate(slotSpecification: Specification.arFooter,
                                       parameterSpecifications: [Specification.fontAble,
                                                                 Specification.arText,
                                                                 Specification.arFooter],
                                       rangeSetting: .no)))

        // ARGlissando, `ARGlissando.cpp:30`.
        entries.append((["glissando", "glissandoBegin"],
                        GMNTagTemplate(slotSpecification: Specification.arGlissando,
                                       parameterSpecifications: [Specification.arGlissando],
                                       rangeSetting: .only)))

        // ARGrace, `ARGrace.cpp:25`.
        entries.append((["grace"],
                        GMNTagTemplate(slotSpecification: Specification.arGrace,
                                       parameterSpecifications: [Specification.arGrace],
                                       rangeSetting: .only)))
    }

    private static func _addThird(to entries: inout [Entry]) {
        // ARHarmony : ARFontAble, `ARHarmony.cpp:28`.
        entries.append((["harmony"],
                        GMNTagTemplate(slotSpecification: Specification.arHarmony,
                                       parameterSpecifications: [Specification.fontAble, Specification.arHarmony],
                                       rangeSetting: .either)))

        // ARTHead — inherits `getParamsStr()`, `ARTHead.cpp:24`.
        entries.append((["headsCenter", "headsLeft", "headsNormal", "headsReverse", "headsRight"],
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .either)))

        // ARInstrument : ARFontAble.
        entries.append((["instr", "instrument"],
                        GMNTagTemplate(slotSpecification: Specification.arInstrument,
                                       parameterSpecifications: [Specification.fontAble, Specification.arInstrument],
                                       rangeSetting: .no)))

        // ARIntens : ARFontAble.
        entries.append((["i", "intens", "intensity"],
                        GMNTagTemplate(slotSpecification: Specification.arIntens,
                                       parameterSpecifications: [Specification.fontAble, Specification.arIntens],
                                       rangeSetting: .no)))

        // ARCoda, ARDaCapo, ARDaCapoAlFine, ARDaCoda, ARDalSegno,
        // ARDalSegnoAlFine, ARFine — pure `ARJump` subclasses. `\segno` is
        // the odd one out and has its own entry below.
        entries.append((["coda",
                         "daCapo",
                         "daCapoAlFine",
                         "daCoda",
                         "dalSegno",
                         "dalSegnoAlFine",
                         "fine"],
                        GMNTagTemplate(slotSpecification: Specification.arJump,
                                       parameterSpecifications: [Specification.arJump],
                                       rangeSetting: .no)))

        // ARKey. `key` is read as a string and then as an int
        // (`ARKey.cpp:88–96`).
        entries.append((["key"],
                        GMNTagTemplate(slotSpecification: Specification.arKey,
                                       parameterSpecifications: [Specification.arKey],
                                       rangeSetting: .no,
                                       alternateParameterKinds: ["key": .integer])))

        // ARLyrics : ARFontAble, `ARLyrics.cpp:30`.
        entries.append((["lyrics"],
                        GMNTagTemplate(slotSpecification: Specification.arLyrics,
                                       parameterSpecifications: [Specification.fontAble, Specification.arLyrics],
                                       rangeSetting: .only)))

        // ARMMRest, `ARMMRest.cpp:21`.
        entries.append((["mrest"],
                        GMNTagTemplate(slotSpecification: Specification.arMMRest,
                                       parameterSpecifications: [Specification.arMMRest],
                                       rangeSetting: .only)))

        // ARMark : ARText, `ARMark.cpp:38`.
        entries.append((["mark"],
                        GMNTagTemplate(slotSpecification: Specification.arMark,
                                       parameterSpecifications: [Specification.fontAble,
                                                                 Specification.arText,
                                                                 Specification.arMark],
                                       rangeSetting: .no)))

        // ARMerge — zero positional slots (`ARMerge.h:43`), `ARMerge.h:26`,
        // and not an `ARMTParameter`.
        entries.append((["merge"],
                        GMNTagTemplate(acceptsParameters: false,
                                       slotSpecification: "",
                                       parameterSpecifications: [],
                                       rangeSetting: .only)))

        // ARMeter.
        entries.append((["meter"],
                        GMNTagTemplate(slotSpecification: Specification.arMeter,
                                       parameterSpecifications: [Specification.arMeter],
                                       rangeSetting: .no)))

        // ARNewSystem — neither overrides `getParamsStr()` nor adds a map,
        // so `kCommonParams` is the whole schema.
        entries.append((["newLine", "newSystem"],
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARNewPage — same schema as `ARNewSystem`, but `ARNewPage` derives
        // from `ARMusicalTag` rather than `ARMTParameter`, so guidolib
        // discards anything written to it. The two layout-break tags are
        // *not* interchangeable in this one respect.
        entries.append((["newPage"],
                        GMNTagTemplate(acceptsParameters: false,
                                       slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARNotations, `ARFactory.cpp:1200–1211`.
        entries.append((["pedalOff", "pedalOn"],
                        GMNTagTemplate(slotSpecification: Specification.common,
                                       parameterSpecifications: [],
                                       rangeSetting: .no)))

        // ARNoteFormat, `ARNoteFormat.cpp:29`.
        entries.append((["noteFormat"],
                        GMNTagTemplate(slotSpecification: Specification.arNoteFormat,
                                       parameterSpecifications: [Specification.arNoteFormat],
                                       rangeSetting: .either)))
    }
}
