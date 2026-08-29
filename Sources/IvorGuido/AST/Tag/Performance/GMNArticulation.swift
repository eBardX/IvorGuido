// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARArticulation` and its seven subclasses, `kARArticulationParams`
// (`"S,position,,o"`, `TagParameterStrings.cpp:36`) plus, for four of the
// eight, a `type` of the subclass’s own — `kARBowParams` (`:40`),
// `kARFermataParams` (`:51`), `kARPizzicatoParams` (`:68`), and
// `kARStaccatoParams` (`:73`). Range setting: `ONLY`, except `\bow` and
// `\fermata`, which are `RANGEDC`.
//
// ## One payload, eight templates
//
// The eight names do not share a template, only a base class. `kind` says
// which name was written, and the formatter takes the slot order from the
// registry entry for that name — so `\bow` emits its required `type` first
// while `\accent`, which declares no `type` at all, emits `position` first.
//
// ## Only `\staccato` has an open-span form
//
// `ARFactory` dispatches `\staccBegin` and `\staccEnd` (`:1346`) and no
// `Begin`/`End` pair for any of the other seven. The two open halves keep
// guidolib's short spelling because it is the only spelling guidolib
// dispatches: there is no `\staccatoBegin`.

/// An articulation (`\accent`, `\staccato`, `\fermata`, and their relatives).
///
/// The eight articulation names do not all take the same parameters: ``kind``
/// says which name was written, and only four of the eight accept a ``type``,
/// each over a vocabulary of its own. A `type` written on a name that does not
/// accept one leaves the tag reserved.
///
/// Only `\staccato` has an open-span form, spelled `\staccBegin` and
/// `\staccEnd`. ``span`` is therefore ``GMNTag/Span/whole`` for every kind but
/// ``Kind/staccato``.
public struct GMNArticulation {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.
    //
    // `kARBowParams` flags `type` required, and it is the only one of the four
    // kinds declaring a `type` that does, so a `\bow` without one is a tag
    // `GMNValidator.validate(_:)` refuses.

    /// Creates a new articulation with the provided identifier, kind, type,
    /// position, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// Also returns `nil` when `kind` is ``Kind/bow`` and `type` is `nil`,
    /// because `\bow` requires its `type`. The two rules together leave
    /// ``Kind/bow`` with no ``GMNTag/Span/end`` form at all, which is correct:
    /// there is no `\bowEnd`.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which articulation this is.
    /// - Parameter type:       The kind-specific variant, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter position:   Which side of the staff the mark sits on, or
    ///                         `nil` if none was written. Defaults to `nil`.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 kind: Kind,
                 type: String? = nil,
                 position: GMNTag.Placement? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.kind = kind
        self.position = position
        self.span = span
        self.type = type

        guard span != .end || carriesNoParameters,
              kind != .bow || type != nil
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which articulation this is.
    public let kind: Kind

    // **Non-omissible, proven.** `ARArticulation::setTagParameters` reads it
    // without `usedefault` and assigns only when present
    // (`ARArticulation.cpp:31–40`), so absence leaves `kDefaultPosition` — a
    // third state neither `above` nor `below` stands in for.

    /// Which side of the staff the mark sits on (`position`), or `nil` if
    /// none was written.
    ///
    /// A `position` outside the closed vocabulary keeps the tag reserved
    /// rather than promoting to this payload; see
    /// ``GMNTag/Placement/init(guidoValue:)``.
    public let position: GMNTag.Placement?

    /// Which part of a spanning construct this tag is.
    ///
    /// Always ``GMNTag/Span/whole`` for every kind but ``Kind/staccato`` —
    /// see the type’s discussion.
    public let span: GMNTag.Span

    // Left a `String` because those are four separate open reads, none of
    // them a C++ enumeration this model commits to.
    //
    // **Non-omissible.** `ARStaccato`, `ARPizzicato`, and `ARBow` each read it
    // without `usedefault` and assign only when present
    // (`ARStaccato.cpp:29–36`, `ARPizzicato.cpp:34–45`, `ARBow.cpp:31–38`).
    // `ARFermata` reads it with `usedefault` (`ARFermata.cpp:46–49`) and so
    // falls into the provisional bucket; the formatter takes the safe
    // branch for all four.

    /// The kind-specific variant (`type`), or `nil` if none was written.
    ///
    /// Only four of the eight kinds accept it, over four unrelated
    /// vocabularies: `up`/`down` for ``Kind/bow``, where the initializer
    /// requires it, `short`/`long` for ``Kind/fermata``, `heavy` for
    /// ``Kind/staccato``, and `buzz`/`snap`/`bartok`/`fingernail` for
    /// ``Kind/pizzicato``.
    public let type: String?

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
                  type: binding.string(named: "type"),
                  position: binding.placement(named: "position"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNArticulation: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        // Only `\stacc` has an open-span form, so only that kind can be
        // spelled `Begin` or `End` at all. A hand-built tag pairing any other
        // kind with a span reports its range-form name: guidolib dispatches
        // no name for the combination, and reporting one of `\stacc`'s would
        // silently change which articulation the tag is. Promotion never
        // builds it — the span comes from the registry, which answers
        // `.whole` for the other seven names.
        guard kind == .staccato
        else { return GMNTag.Name(kind.tagName) }

        switch span {
        case .begin:
            return GMNTag.Name("staccBegin")

        case .end:
            return GMNTag.Name("staccEnd")

        case .whole:
            return GMNTag.Name(kind.tagName)
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["position"] = position.map { .string($0.guidoValue) }
        values["type"] = type.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNArticulation: Equatable {
}

// MARK: - Sendable

extension GMNArticulation: Sendable {
}
