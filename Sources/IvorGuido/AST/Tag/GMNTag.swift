// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A Guido Music Notation tag.
///
/// Every tag is one of a fixed set of typed payloads, or — when no payload
/// fits — one of the two untyped ones, ``GMNReservedTag`` and
/// ``GMNCustomTag``. A payload says what its tag *means*: that `\tempo` takes
/// a text string and a metronome spec, that `\slurBegin` and `\slurEnd`
/// are two halves of one construct, that `\headsLeft` and `\headsRight` are
/// one tag with two settings. None of that was expressible when a tag was a
/// single struct of name, identifier, parameters, and symbols.
///
/// ## The two untyped lanes are not the same thing
///
/// They divide on one question — **does GMN reserve the name?** — and the
/// answer is what each initializer checks, so the two lanes are exclusive
/// and exhaustive at every stage:
///
/// - ``reserved(_:)`` — the name is reserved, and either no payload claims
///   it (`\port`, `\DrHoos`, `\DrRenz`, permanently) or what was written has
///   not been repaired yet. The second kind is gone by the time
///   ``GMNNormalizer/normalize(_:)`` returns.
/// - ``custom(_:)`` — the name is not reserved. A consumer extension, or a
///   tag Guido Music Notation declares and never builds. It round-trips and
///   realizes as a no-op.
///
/// The distinction matters because “GMN reserves this name” and “IvorGuido
/// types this tag” are different properties, and one untyped case could only
/// say the second.
///
/// ## Promotion is total
///
/// Turning a written tag into a case is a total, idempotent function of its
/// name and parameters, with the two untyped lanes as the fallback. It never
/// throws and never discards: an unrecognized name, a parameter the tag does
/// not accept, or a value of the wrong type all leave the tag untyped and
/// intact, exactly as written.
///
/// Because promotion is total it is also re-runnable, which is what lets the
/// normalizer repair a tag and promote it a second time. One visible
/// consequence: **a parsed score is less typed than a normalized one.**
///
/// ## Reading a tag without switching
///
/// The properties in this type’s forwarding surface — ``name``, ``ident``,
/// ``body``, ``appearance``, ``span``, ``rangeSetting`` — answer for *any*
/// case, so a consumer that only needs, say, the canonical name never has to
/// switch over the enum at all.
public enum GMNTag {
    /// An accidental-display override (`\accidental`).
    case accidental(GMNAccidental)

    /// A brace or bracket joining staves (`\accolade`).
    case accolade(GMNAccolade)

    /// A microtonal detuning (`\alter`).
    case alter(GMNAlter)

    /// An arpeggiated chord (`\arpeggio`).
    case arpeggio(GMNArpeggio)

    /// An articulation (`\accent`, `\staccato`, `\fermata`, and their
    /// relatives).
    case articulation(GMNArticulation)

    /// A score-wide automatic-layout setting (`\auto`).
    case auto(GMNAuto)

    /// A barline-drawing style setting (`\barFormat`).
    case barFormat(GMNBarFormat)

    /// A barline (`|`, `\bar`, `\doubleBar`, `\endBar`).
    case barLine(GMNBarLine)

    /// A beam (`\beam`, `\fBeam`).
    case beam(GMNBeam)

    /// An automatic-beaming setting (`\beamsAuto`, `\beamsFull`,
    /// `\beamsOff`).
    case beamState(GMNBeamState)

    /// A breath mark (`\breathMark`).
    case breathMark(GMNBreathMark)

    /// A clef (`\clef`).
    case clef(GMNClef)

    /// A note cluster (`\cluster`).
    case cluster(GMNCluster)

    /// A voice color setting (`\color`).
    case color(GMNColor)

    /// A cue-note passage (`\cue`).
    case cue(GMNCue)

    /// A tag GMN does not reserve, carried as written.
    case custom(GMNCustomTag)

    /// A notated-duration override (`\displayDuration`).
    case displayDuration(GMNDisplayDuration)

    /// A dot-drawing setting (`\dotFormat`).
    case dotFormat(GMNDotFormat)

    /// A gradual dynamic change (`\crescendo`, `\diminuendo`).
    case dynamicRamp(GMNDynamicRamp)

    /// A fingering indication (`\fingering`).
    case fingering(GMNFingering)

    /// A glissando (`\glissando`).
    case glissando(GMNGlissando)

    /// A grace-note group (`\grace`).
    case grace(GMNGrace)

    /// An imported graphic (`\symbol`).
    case graphicSymbol(GMNGraphicSymbol)

    /// A chord symbol (`\harmony`).
    case harmony(GMNHarmony)

    /// An instrument name (`\instrument`).
    case instrument(GMNInstrument)

    /// A dynamic marking (`\intensity`).
    case intensity(GMNIntensity)

    /// A navigation mark (`\coda`, `\segno`, `\fine`, and their relatives).
    case jump(GMNJump)

    /// A key signature (`\key`).
    case key(GMNKey)

    /// A forced layout break (`\newSystem`, `\newPage`).
    case layoutBreak(GMNLayoutBreak)

    /// A line of lyrics (`\lyrics`).
    case lyrics(GMNLyrics)

    /// A rehearsal mark (`\mark`).
    case mark(GMNMark)

    /// A merged-voice passage (`\merge`).
    case merge(GMNMerge)

    /// A time signature (`\meter`).
    case meter(GMNMeter)

    /// A multiple-measure rest (`\mrest`).
    case multiMeasureRest(GMNMultiMeasureRest)

    /// A notehead-drawing setting (`\noteFormat`).
    case noteFormat(GMNNoteFormat)

    /// A notehead placement (`\headsLeft`, `\headsRight`, and their
    /// relatives).
    case noteHeads(GMNNoteHeads)

    /// An octave transposition (`\octava`).
    case octava(GMNOctava)

    /// An ornament (`\trill`, `\mordent`, `\turn`).
    case ornament(GMNOrnament)

    /// A page size and margin setting (`\pageFormat`).
    case pageFormat(GMNPageFormat)

    /// A pedal indication (`\pedalOn`, `\pedalOff`).
    case pedal(GMNPedal)

    /// A repeat mark (`\repeatBegin`, `\repeatEnd`).
    case repeatMark(GMNRepeat)

    /// A tag GMN reserves that no typed payload fits, carried as written.
    case reserved(GMNReservedTag)

    /// A rest-drawing setting (`\restFormat`).
    case restFormat(GMNRestFormat)

    /// A shared-location passage (`\shareLocation`).
    case shareLocation(GMNShareLocation)

    /// A slur (`\slur`).
    case slur(GMNSlur)

    /// An explicit horizontal space (`\space`).
    case space(GMNSpace)

    /// A raw musical glyph (`\special`).
    case special(GMNSpecial)

    /// A staff assignment (`\staff`).
    case staff(GMNStaff)

    /// A staff-drawing setting (`\staffFormat`).
    case staffFormat(GMNStaffFormat)

    /// A staff visibility switch (`\staffOn`, `\staffOff`).
    case staffVisibility(GMNStaffVisibility)

    /// A stem-direction setting (`\stemsUp`, `\stemsDown`, and their
    /// relatives).
    case stemDirection(GMNStemDirection)

    /// A system placement setting (`\systemFormat`).
    case systemFormat(GMNSystemFormat)

    /// A tempo marking (`\tempo`).
    case tempo(GMNTempo)

    /// A gradual tempo change (`\accelerando`, `\ritardando`).
    case tempoChange(GMNTempoChange)

    /// A text string (`\text`) or a label (`\label`).
    case text(GMNText)

    /// A tie (`\tie`).
    case tie(GMNTie)

    /// A page-level text block (`\title`, `\composer`, `\footer`).
    case titleBlock(GMNTitleBlock)

    /// A tremolo (`\tremolo`).
    case tremolo(GMNTremolo)

    /// A tuplet (`\tuplet`).
    case tuplet(GMNTuplet)

    /// A default-unit setting (`\units`).
    case units(GMNUnits)

    /// An ending bracket (`\volta`).
    case volta(GMNVolta)
}

// MARK: -

extension GMNTag {

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// Every tag accepts `color`, `dx`, `dy`, and `size`, so every case can
    /// answer this. All four are non-omissible — see ``GMNTag/Appearance``.
    public var appearance: Appearance {
        payload.appearance
    }

    /// The symbols scoped to this tag, or an empty array if it has no body.
    public var body: [GMNSymbol] {
        payload.body
    }

    /// The optional numeric identifier written after this tag’s name, which
    /// pairs the halves of an open span (`\slurBegin:1 … \slurEnd:1`).
    public var ident: Ident? {
        payload.ident
    }

    /// The canonical name of this tag.
    ///
    /// For a typed payload this is the name the case *is*, never an alias.
    /// For ``reserved(_:)`` it is whatever was written, since canonicalizing
    /// that lane is the normalizer’s job; for ``custom(_:)`` there is no alias
    /// to canonicalize, because the name is not one GMN reserves.
    public var name: Name {
        payload.name
    }

    // Taken from guidolib's own `rangesetting` for the tag's class;
    // `ARMusicalTag.cpp:35` is where the `NO` default comes from.

    /// Whether this tag may carry a body, and whether it must.
    ///
    /// An unrecognized name answers ``RangeSetting/no``.
    public var rangeSetting: RangeSetting {
        GMNTagTemplate.Registry.template(for: name)?.rangeSetting ?? .no
    }

    /// Which part of a spanning construct this tag is.
    ///
    /// ``Span/whole`` for every tag that has no `Begin`/`End` form at all,
    /// which is most of them.
    public var span: Span {
        GMNTagTemplate.Registry.span(of: name)
    }
}

// MARK: -

extension GMNTag {

    // MARK: Internal Instance Properties

    // The payload of whichever case this is.
    //
    // The one switch over the enum that every tranche has to touch. Both the
    // public forwarding surface above and the formatter's typed lane read
    // through it, so a new case costs one line here rather than one line in
    // each of six properties.
    internal var payload: any GMNTagPayload {
        switch self {
        case let .accidental(payload):
            payload

        case let .accolade(payload):
            payload

        case let .alter(payload):
            payload

        case let .arpeggio(payload):
            payload

        case let .articulation(payload):
            payload

        case let .auto(payload):
            payload

        case let .barFormat(payload):
            payload

        case let .barLine(payload):
            payload

        case let .beam(payload):
            payload

        case let .beamState(payload):
            payload

        case let .breathMark(payload):
            payload

        case let .clef(payload):
            payload

        case let .cluster(payload):
            payload

        case let .color(payload):
            payload

        case let .cue(payload):
            payload

        case let .custom(payload):
            payload

        case let .displayDuration(payload):
            payload

        case let .dotFormat(payload):
            payload

        case let .dynamicRamp(payload):
            payload

        case let .fingering(payload):
            payload

        case let .glissando(payload):
            payload

        case let .grace(payload):
            payload

        case let .graphicSymbol(payload):
            payload

        case let .harmony(payload):
            payload

        case let .instrument(payload):
            payload

        case let .intensity(payload):
            payload

        case let .jump(payload):
            payload

        case let .key(payload):
            payload

        case let .layoutBreak(payload):
            payload

        case let .lyrics(payload):
            payload

        case let .mark(payload):
            payload

        case let .merge(payload):
            payload

        case let .meter(payload):
            payload

        case let .multiMeasureRest(payload):
            payload

        case let .noteFormat(payload):
            payload

        case let .noteHeads(payload):
            payload

        case let .octava(payload):
            payload

        case let .ornament(payload):
            payload

        case let .pageFormat(payload):
            payload

        case let .pedal(payload):
            payload

        case let .repeatMark(payload):
            payload

        case let .reserved(payload):
            payload

        case let .restFormat(payload):
            payload

        case let .shareLocation(payload):
            payload

        case let .slur(payload):
            payload

        case let .space(payload):
            payload

        case let .special(payload):
            payload

        case let .staff(payload):
            payload

        case let .staffFormat(payload):
            payload

        case let .staffVisibility(payload):
            payload

        case let .stemDirection(payload):
            payload

        case let .systemFormat(payload):
            payload

        case let .tempo(payload):
            payload

        case let .tempoChange(payload):
            payload

        case let .text(payload):
            payload

        case let .tie(payload):
            payload

        case let .titleBlock(payload):
            payload

        case let .tremolo(payload):
            payload

        case let .tuplet(payload):
            payload

        case let .units(payload):
            payload

        case let .volta(payload):
            payload
        }
    }
}

// MARK: - Equatable

extension GMNTag: Equatable {
}

// MARK: - Sendable

extension GMNTag: Sendable {
}
