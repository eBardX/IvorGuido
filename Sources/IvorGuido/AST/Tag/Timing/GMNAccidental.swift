// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARAccidental`, `kARAccidentalParams` (`"S,style,,o"`,
// `TagParameterStrings.cpp:32`). Range setting: `ONLY` — `\accidental` takes a
// body and nothing else.

/// An accidental-display override (`\acc`, `\accidental`).
///
/// `\accidental` takes a body and nothing else.
public struct GMNAccidental {

    // MARK: Public Initializers

    /// Creates a new accidental override with the provided identifier, style,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter style:      The accidental style, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                style: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.style = style
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible.** `ARAccidental::getStyle` reads it *without*
    // `usedefault` (`ARAccidental.cpp:39–47`) and recognizes only
    // `"cautionary"` and `"none"`, returning `kUnknown` for absence and for
    // anything else — three states the declared (empty) default cannot stand
    // in for.
    //
    // Left a `String`: guidolib matches two literals and falls through on
    // everything else, which is an open grammar rather than an enumeration
    // (shape aggressively, values conservatively).

    /// The accidental style written for this tag (`style`), or `nil` if none
    /// was written.
    ///
    /// The recognized values are `cautionary` and `none`; anything else is
    /// ignored when the score is rendered.
    public let style: String?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  style: binding.string(named: "style"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNAccidental: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("accidental")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["style"] = style.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNAccidental: Equatable {
}

// MARK: - Sendable

extension GMNAccidental: Sendable {
}
