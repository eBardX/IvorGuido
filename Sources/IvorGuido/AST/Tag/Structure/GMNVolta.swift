// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARVolta`, `kARVoltaParams` (`"S,mark,,r;S,format,,o"`,
// `TagParameterStrings.cpp:85`). Range setting: `ONLY` (`ARVolta.cpp:28`) —
// the range form must carry a body, and the `Begin`/`End` form is what
// `ARFactory` builds instead when there is none (`ARFactory.cpp:1596–1602`,
// which calls `setAllowRange(0)`).
//
// The normalizer rewrites a parameter named `m` to `mark`, a 1.5.5-era
// upgrade that survives from before this payload existed. It can still fire on
// a hand-built tag — and when it does, the repaired tag promotes to this
// payload — but it can never fire on parsed input at all: `guido.l:143` lexes
// a bare `m` as a UNIT token unconditionally. Which is very likely why
// guidolib renamed it.

/// An ending bracket (`\volta`, `\voltaBegin`, `\voltaEnd`).
///
/// The range form must carry a body; the `Begin`/`End` form is what a
/// bodyless `\volta` becomes instead.
///
/// The bracket’s text can only be written positionally — `\volta<"1.">` —
/// since `\volta<m="1.">` does not parse. The parameter is named `mark`.
public struct GMNVolta {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new ending bracket with the provided identifier, mark,
    /// format, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter mark:       The text drawn in the bracket. Must be empty
    ///                         when `span` is ``GMNTag/Span/end``, which
    ///                         carries no parameters at all.
    /// - Parameter format:     The bracket’s shape, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 mark: String,
                 format: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.format = format
        self.ident = ident
        self.mark = mark
        self.span = span

        // Stated against the fields rather than through
        // `carriesNoParameters`, which the ten other spanning payloads use.
        // This is the only one whose own parameter is *required*, so its
        // `parameterValues` suppresses the whole map for a closing half —
        // and a predicate reading that map would therefore be satisfied by
        // construction and could never fire.
        guard span != .end || (mark.isEmpty && format == nil && appearance.isEmpty)
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag — the passage the bracket covers when
    /// ``span`` is ``GMNTag/Span/whole``, and empty otherwise.
    public let body: [GMNSymbol]

    // **Omissible, provisionally.** Read with `usedefault=true`
    // (`ARVolta.cpp:51–54`) and absent from the `TagIsSet()` blocklist — but
    // treated as non-omissible for now, so nothing is omitted. Absence is
    // preserved instead.

    /// The bracket’s shape (`format`), or `nil` if none was written.
    ///
    /// An open grammar rather than a fixed set: the `|` and `-` characters in
    /// the spelling are what select the shape.
    public let format: String?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\voltaBegin:1 …
    /// \voltaEnd:1`.
    public let ident: GMNTag.Ident?

    // **Non-omissible**, moot for a required parameter.

    /// The text drawn in the bracket (`mark`).
    ///
    /// Required, so a `\volta` without it stays reserved. Always empty when
    /// ``span`` is ``GMNTag/Span/end``, which carries no parameters at all —
    /// the initializer refuses any other combination rather than accepting a
    /// mark it would then have to drop.
    public let mark: String

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      mark: "",
                      span: .end,
                      body: body)

            return
        }

        guard let mark = binding.string(named: "mark")
        else { return nil }

        self.init(ident: ident,
                  mark: mark,
                  format: binding.string(named: "format"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNVolta: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("voltaBegin")

        case .end:
            GMNTag.Name("voltaEnd")

        case .whole:
            GMNTag.Name("volta")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        guard span != .end
        else { return [:] }

        var values: [String: GMNTag.Parameter.Value] = ["mark": .string(mark)]

        values["format"] = format.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNVolta: Equatable {
}

// MARK: - Sendable

extension GMNVolta: Sendable {
}
