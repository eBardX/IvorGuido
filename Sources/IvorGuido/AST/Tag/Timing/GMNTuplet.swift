// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTuplet`, `kARTupletParams`
// (`"S,format,,r;S,position,above,o;U,dy1,0,o;U,dy2,0,o;F,lineThickness,4,o;S,bold,,o;F,textSize,1,o;S,dispNote,,o"`,
// `TagParameterStrings.cpp:83`). Range setting: `ONLY` — the notes the tuplet
// covers are its body.

/// A tuplet (`\tuplet`, `\tupletBegin`, `\tupletEnd`).
///
/// The notes the tuplet covers are its body.
///
/// The three names above are one type, distinguished by ``span``. The range
/// form and the `Begin`/`End` form are never rewritten into each other:
/// ``span`` records which one was written, and the same one is written back.
public struct GMNTuplet {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new tuplet with the provided identifier, format, options,
    /// span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// Also returns `nil` when `span` is anything else and `format` is `nil`.
    /// `format` is required, so `\tuplet` and `\tupletBegin` must carry one;
    /// only the closing half, which carries nothing at all, may omit it.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter format:        The tuplet’s format string, or `nil` for
    ///                            the closing half of an open span. Defaults
    ///                            to `nil`.
    /// - Parameter position:      Which side of the staff the tuplet number
    ///                            sits on, or `nil` if none was written.
    ///                            Defaults to `nil`.
    /// - Parameter dy1:           The vertical offset of the bracket’s left
    ///                            end, or `nil` if none was written. Defaults
    ///                            to `nil`.
    /// - Parameter dy2:           The vertical offset of the bracket’s right
    ///                            end, or `nil` if none was written. Defaults
    ///                            to `nil`.
    /// - Parameter lineThickness: The bracket’s line thickness, or `nil` if
    ///                            none was written. Defaults to `nil`.
    /// - Parameter bold:          Whether the tuplet number is bold, as
    ///                            written, or `nil` if it was not written.
    ///                            Defaults to `nil`.
    /// - Parameter textSize:      The tuplet number’s size scaling factor, or
    ///                            `nil` if none was written. Defaults to
    ///                            `nil`.
    /// - Parameter dispNote:      The note duration the covered notes are
    ///                            drawn as, or `nil` if none was written.
    ///                            Defaults to `nil`.
    /// - Parameter span:          Which part of a spanning construct this tag
    ///                            is. Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance:    The common appearance parameters written for
    ///                            this tag. Defaults to none.
    /// - Parameter body:          The symbols scoped to this tag. Defaults to
    ///                            none.
    public init?(ident: GMNTag.Ident? = nil,
                 format: String? = nil,
                 position: GMNTag.Placement? = nil,
                 dy1: GMNLength? = nil,
                 dy2: GMNLength? = nil,
                 lineThickness: Double? = nil,
                 bold: String? = nil,
                 textSize: Double? = nil,
                 dispNote: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.bold = bold
        self.dispNote = dispNote
        self.dy1 = dy1
        self.dy2 = dy2
        self.format = format
        self.ident = ident
        self.lineThickness = lineThickness
        self.position = position
        self.span = span
        self.textSize = textSize

        guard span != .end || carriesNoParameters,
              span == .end || format != nil
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, proven.** Read without `usedefault`, and assigned only
    // when present (`ARTuplet.cpp:63–64`), so absence leaves the class’s own
    // initial `false` rather than applying a declared default — which is empty
    // here in any case.

    /// Whether the tuplet number is bold (`bold`), as written, or `nil` if it
    /// was not written.
    public let bold: String?

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARTuplet.cpp:67–68`).

    /// The note duration the covered notes are drawn as (`dispNote`), or
    /// `nil` if none was written.
    public let dispNote: String?

    // **Non-omissible, proven.** Read without `usedefault`
    // (`ARTuplet.cpp:139`), *and* inspected for authorship directly:
    // `ARTuplet::isDySet` is `(fDy1 && fDy1->TagIsSet()) || (fDy2 &&
    // fDy2->TagIsSet())` (`ARTuplet.h:97`).

    /// The vertical offset of the bracket’s left end (`dy1`), or `nil` if
    /// none was written.
    public let dy1: GMNLength?

    // **Non-omissible, proven** — same two reasons as `dy1`
    // (`ARTuplet.cpp:140`, `ARTuplet.h:97`).

    /// The vertical offset of the bracket’s right end (`dy2`), or `nil` if
    /// none was written.
    public let dy2: GMNLength?

    /// The tuplet’s format string (`format`), or `nil` if none was written.
    ///
    /// Required, so a `\tuplet` or `\tupletBegin` without it stays reserved,
    /// and the initializer refuses to build one by hand. It is `nil` only for
    /// ``GMNTag/Span/end``, which carries no parameters at all.
    public let format: String?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\tupletBegin:1 …
    /// \tupletEnd:1`.
    public let ident: GMNTag.Ident?

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARTuplet.cpp:141`) and not on the `TagIsSet()` blocklist, which puts
    // it in the provisional bucket; the formatter takes the safe branch.

    /// The bracket’s line thickness (`lineThickness`), or `nil` if none was
    /// written.
    public let lineThickness: Double?

    // **Non-omissible**: `ARTuplet::isPositionAbove` guards on
    // `fPosition->TagIsSet()` (`ARTuplet.cpp:148`), so absence is a third
    // state the declared default `above` cannot stand in for.

    /// Which side of the staff the tuplet number sits on (`position`), or
    /// `nil` if none was written.
    ///
    /// `\tuplet` reads this parameter openly: `below` means below and
    /// **anything else at all** means above. A value outside the vocabulary
    /// therefore comes back re-spelled as `above`, which means the same thing.
    public let position: GMNTag.Placement?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARTuplet.cpp:66`).

    /// The tuplet number’s size scaling factor (`textSize`), or `nil` if none
    /// was written.
    public let textSize: Double?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      span: .end,
                      body: body)

            return
        }

        guard let format = binding.string(named: "format")
        else { return nil }

        self.init(ident: ident,
                  format: format,
                  position: binding.string(named: "position").map { $0 == "below" ? .below : .above },
                  dy1: binding.length(named: "dy1"),
                  dy2: binding.length(named: "dy2"),
                  lineThickness: binding.double(named: "lineThickness"),
                  bold: binding.string(named: "bold"),
                  textSize: binding.double(named: "textSize"),
                  dispNote: binding.string(named: "dispNote"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTuplet: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("tupletBegin")

        case .end:
            GMNTag.Name("tupletEnd")

        case .whole:
            GMNTag.Name("tuplet")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["bold"] = bold.map { .string($0) }
        values["dispNote"] = dispNote.map { .string($0) }
        values["dy1"] = dy1?.parameterValue
        values["dy2"] = dy2?.parameterValue
        values["format"] = format.map { .string($0) }
        values["lineThickness"] = lineThickness.map { .number($0) }
        values["position"] = position.map { .string($0 == .below ? "below" : "above") }
        values["textSize"] = textSize.map { .number($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNTuplet: Equatable {
}

// MARK: - Sendable

extension GMNTuplet: Sendable {
}
