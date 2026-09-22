// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARSpecial`, `kARSpecialParams` (`"S,char,,r"`,
// `TagParameterStrings.cpp:72`). Range setting: `NO` — `\special` takes no
// body.

/// A raw musical glyph (`\special`).
///
/// `\special` takes no body.
public struct GMNSpecial {

    // MARK: Public Initializers

    /// Creates a new musical glyph with the provided identifier, character,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter character:  The character to display.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                character: String,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.character = character
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The character to display (`char`).
    ///
    /// Required, so a `\special` without it stays reserved. Four spellings
    /// are accepted — a literal character, or a number prefixed `\x`
    /// (hexadecimal), `\o` (octal), or `\` (decimal) — and this is a
    /// `String` rather than a `Character` so that which one was written
    /// survives the round trip.
    public let character: String

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let character = binding.string(named: "char")
        else { return nil }

        self.init(ident: ident,
                  character: character,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNSpecial: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("special")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["char": .string(character)]
    }
}

// MARK: - Equatable

extension GMNSpecial: Equatable {
}

// MARK: - Sendable

extension GMNSpecial: Sendable {
}
