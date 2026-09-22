// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARUnits`, `kARUnitsParams` (`"S,type,cm,r"`,
// `TagParameterStrings.cpp:84`). Range setting: `NO` — `\units` takes no body.

/// A default-unit setting (`\units`).
///
/// `\units` takes no body.
///
/// The tag sets the unit that a bare number is read in from here on. The AST
/// simply records what was written; it does not apply the setting.
public struct GMNUnits {

    // MARK: Public Initializers

    /// Creates a new default-unit setting with the provided identifier, unit,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter type:       The unit a bare number is read in.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                type: String,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.type = type
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // Required, even though `ARUnits` reads it with `usedefault=true`
    // (`ARUnits.cpp:34–35`), which for any optional parameter would make it a
    // candidate for omission. Requiredness settles it first.
    //
    // Left a `String`: `ARUnits` stores the spelling and hands it to
    // `gd_convertUnits` unchecked, so the vocabulary is that function's, not
    // this tag's.

    /// The unit a bare number is read in (`type`).
    ///
    /// Required, so a `\units` without it stays reserved. The spelling is
    /// kept as written and checked only when the score is rendered.
    public let type: String

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let type = binding.string(named: "type")
        else { return nil }

        self.init(ident: ident,
                  type: type,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNUnits: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("units")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["type": .string(type)]
    }
}

// MARK: - Equatable

extension GMNUnits: Equatable {
}

// MARK: - Sendable

extension GMNUnits: Sendable {
}
