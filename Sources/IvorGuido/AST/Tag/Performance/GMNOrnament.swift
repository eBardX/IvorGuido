// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTrill`, `kARTrillParams`
// (`"S,note,,o;S,type,prall,o;F,detune,0.0,o;S,accidental,,o;I,dur,32,o;S,begin,on,o;U,adx,0hs,o;U,ady,0hs,o;S,tr,true,o;S,wavy,true,o;S,position,above,o;S,repeat,true,o"`,
// `TagParameterStrings.cpp:81`). Range setting: `ONLY` — the notes the
// ornament covers are its body.

/// An ornament (`\trill`, `\mordent`, `\turn`).
///
/// The notes the ornament covers are its body.
///
/// Only `\trill` has an open-span form, spelled `\trillBegin` and
/// `\trillEnd`. ``span`` is therefore ``GMNTag/Span/whole`` for
/// ``Kind/mordent`` and ``Kind/turn``.
public struct GMNOrnament {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new ornament with the provided identifier, kind, parameters,
    /// span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which ornament this is.
    /// - Parameter note:       The trilled note, or `nil` if none was written.
    ///                         Defaults to `nil`.
    /// - Parameter type:       The ornament’s shape, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter detune:     The trilled note’s microtonal offset, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter accidental: How the trilled note’s accidental is drawn, or
    ///                         `nil` if none was written. Defaults to `nil`.
    /// - Parameter dur:        The ornament’s playback subdivision, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter begin:      Whether the ornament begins on the auxiliary
    ///                         note, as written, or `nil` if it was not
    ///                         written. Defaults to `nil`.
    /// - Parameter adx:        The horizontal offset of the accidental, or
    ///                         `nil` if none was written. Defaults to `nil`.
    /// - Parameter ady:        The vertical offset of the accidental, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter tr:         Whether the `tr` glyph is drawn, as written, or
    ///                         `nil` if it was not written. Defaults to `nil`.
    /// - Parameter wavy:       Whether the wavy line is drawn, as written, or
    ///                         `nil` if it was not written. Defaults to `nil`.
    /// - Parameter position:   Which side of the staff the ornament sits on,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter repeats:    Whether the ornament repeats, as written, or
    ///                         `nil` if it was not written. Defaults to `nil`.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 kind: Kind,
                 note: String? = nil,
                 type: String? = nil,
                 detune: Double? = nil,
                 accidental: String? = nil,
                 dur: Int? = nil,
                 begin: String? = nil,
                 adx: GMNLength? = nil,
                 ady: GMNLength? = nil,
                 tr: String? = nil,
                 wavy: String? = nil,
                 position: GMNTag.Placement? = nil,
                 repeats: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.accidental = accidental
        self.adx = adx
        self.ady = ady
        self.appearance = appearance
        self.begin = begin
        self.body = body
        self.detune = detune
        self.dur = dur
        self.ident = ident
        self.kind = kind
        self.note = note
        self.position = position
        self.repeats = repeats
        self.span = span
        self.tr = tr
        self.type = type
        self.wavy = wavy

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARTrill.cpp:96–102`); guidolib recognizes `cautionary`
    // and `force` and silently ignores anything else.

    /// How the trilled note’s accidental is drawn (`accidental`), or `nil` if
    /// none was written.
    ///
    /// The recognized values are `cautionary` and `force`; anything else is
    /// ignored when the score is rendered.
    public let accidental: String?

    /// The horizontal offset of the accidental (`adx`), or `nil` if none was
    /// written.
    public let adx: GMNLength?

    /// The vertical offset of the accidental (`ady`), or `nil` if none was
    /// written.
    public let ady: GMNLength?

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// Whether the ornament begins on the auxiliary note (`begin`), as
    /// written, or `nil` if it was not written.
    public let begin: String?

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, provisionally.** Read with `usedefault=true` and only
    // where the tag also carries a `note` (`ARTrill.cpp:127`), which puts it
    // in the provisional bucket.

    /// The trilled note’s microtonal offset (`detune`), or `nil` if none was
    /// written.
    public let detune: Double?

    // **Non-omissible for want of a reader.** `kARTrillParams` declares it and
    // `ARTrill` never reads it, so condition 1 — which asks what the reader
    // does with `usedefault` — has nothing to answer. It is legal to write and
    // must round-trip, the same unusual case as `\jump`’s `id`.

    /// The ornament’s playback subdivision (`dur`), or `nil` if none was
    /// written.
    public let dur: Int?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\trillBegin:1 …
    /// \trillEnd:1`.
    public let ident: GMNTag.Ident?

    /// Which ornament this is.
    public let kind: Kind

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARTrill.cpp:92–94`).
    //
    // Left a `String` rather than a `GMNPitch`: `ARTrill` re-reads it through
    // its own accidental scanner against the prevailing key
    // (`ARTrill.cpp:130`), which is a resolution concern rather than a
    // syntactic one.

    /// The trilled note (`note`), or `nil` if none was written.
    public let note: String?

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARTrill.cpp:117–122`).

    /// Which side of the staff the ornament sits on (`position`), or `nil` if
    /// none was written.
    ///
    /// A `position` outside the closed vocabulary keeps the tag reserved
    /// rather than promoting to this payload; see
    /// ``GMNTag/Placement/init(guidoValue:)``.
    public let position: GMNTag.Placement?

    /// Whether the ornament repeats (`repeat`), as written, or `nil` if it
    /// was not written.
    ///
    /// Spelled `repeats` here because `repeat` is a Swift keyword; the
    /// parameter is still written and emitted as `repeat`.
    public let repeats: String?

    /// Which part of a spanning construct this tag is.
    ///
    /// Always ``GMNTag/Span/whole`` for ``Kind/mordent`` and ``Kind/turn`` —
    /// see the type’s discussion.
    public let span: GMNTag.Span

    /// Whether the `tr` glyph is drawn (`tr`), as written, or `nil` if it was
    /// not written.
    public let tr: String?

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARTrill.cpp:132–137`) and not blocklisted.
    //
    // Left a `String`: closed Swift enums here are confined to the
    // enumerated list of C++ enumerations the model commits to, and
    // `ARTrill::TYPE` is not among them.

    /// The ornament’s shape (`type`), or `nil` if none was written.
    ///
    /// The recognized values are `prall`, `prallprall`, `inverted`,
    /// `invertedb`, and `prallinverted`; anything else is ignored when the
    /// score is rendered.
    public let type: String?

    // **Non-omissible, provisionally** — read with `usedefault=true` alongside
    // `tr`, `adx`, and `ady` (`ARTrill.cpp:104–108`).

    /// Whether the wavy line is drawn (`wavy`), as written, or `nil` if it
    /// was not written.
    public let wavy: String?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   kind: Kind,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      kind: kind,
                      span: .end,
                      body: body)

            return
        }

        guard !binding.hasUnreadablePlacement(named: "position")
        else { return nil }

        self.init(ident: ident,
                  kind: kind,
                  note: binding.string(named: "note"),
                  type: binding.string(named: "type"),
                  detune: binding.double(named: "detune"),
                  accidental: binding.string(named: "accidental"),
                  dur: binding.integer(named: "dur"),
                  begin: binding.string(named: "begin"),
                  adx: binding.length(named: "adx"),
                  ady: binding.length(named: "ady"),
                  tr: binding.string(named: "tr"),
                  wavy: binding.string(named: "wavy"),
                  position: binding.placement(named: "position"),
                  repeats: binding.string(named: "repeat"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNOrnament: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        // Only `\trill` has an open-span form, so a hand-built tag pairing
        // either other kind with a span reports its range-form name —
        // guidolib dispatches no name for that combination, and reporting one
        // of `\trill`'s would silently change which ornament the tag is.
        // Promotion never builds it: the span comes from the registry, which
        // answers `.whole` for `\mordent` and `\turn`.
        guard kind == .trill
        else { return GMNTag.Name(kind.tagName) }

        switch span {
        case .begin:
            return GMNTag.Name("trillBegin")

        case .end:
            return GMNTag.Name("trillEnd")

        case .whole:
            return GMNTag.Name(kind.tagName)
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["accidental"] = accidental.map { .string($0) }
        values["adx"] = adx?.parameterValue
        values["ady"] = ady?.parameterValue
        values["begin"] = begin.map { .string($0) }
        values["detune"] = detune.map { .number($0) }
        values["dur"] = dur.map { .integer($0, nil) }
        values["note"] = note.map { .string($0) }
        values["position"] = position.map { .string($0.guidoValue) }
        values["repeat"] = repeats.map { .string($0) }
        values["tr"] = tr.map { .string($0) }
        values["type"] = type.map { .string($0) }
        values["wavy"] = wavy.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNOrnament: Equatable {
}

// MARK: - Sendable

extension GMNOrnament: Sendable {
}
