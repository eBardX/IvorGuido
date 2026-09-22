// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARHarmony : ARFontAble`, `kARHarmonyParams`
// (`"S,text,,r;U,dy,-1,o;S,textformat,lt,o;S,font,Arial,o;U,fsize,18pt,o"`,
// `TagParameterStrings.cpp:56`) on top of `kARFontAbleParams`. Range setting:
// `RANGEDC` — `\harmony` may be written with or without a body.

/// A chord symbol (`\harmony`).
///
/// `\harmony` may be written with or without a body.
///
/// `\harmony` has no `position` parameter — `\harmony<position="below">` is
/// rejected — so this payload carries no ``GMNTag/Placement``.
///
/// `dy` is one of this tag’s own positional slots, with a default of `-1`,
/// which changes where it is emitted but not how it is written; it is carried
/// in ``appearance`` like every other common parameter.
public struct GMNHarmony {

    // MARK: Public Initializers

    /// Creates a new chord symbol with the provided identifier, text, text
    /// style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter text:       The chord symbol itself.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                text: String,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// Its `dy` is this tag’s own second positional slot — see the type’s
    /// discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The chord symbol itself (`text`).
    ///
    /// Required, so a `\harmony` without it stays reserved. The
    /// chord-symbol vocabulary is open, and the text is left unparsed here.
    public let text: String

    /// The font parameters written for this tag.
    ///
    /// Three of the four — `textformat`, `font`, `fsize` — are also this tag’s
    /// own positional slots, with defaults of its own. That changes where they
    /// are emitted, not how they are modeled.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: "text")
        else { return nil }

        self.init(ident: ident,
                  text: text,
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNHarmony: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("harmony")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["text"] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNHarmony: Equatable {
}

// MARK: - Sendable

extension GMNHarmony: Sendable {
}
