// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARText : ARFontAble` and `ARLabel : ARText`, both on
// `kARTextParams` (`"S,text,,r;U,dy,-1,o;S,textformat,lt,o;U,fsize,12pt,o"`,
// `TagParameterStrings.cpp:78`). Range setting: `RANGEDC` (`ARText.cpp:39`) —
// either may be written with a body or without one.

/// A text string (`\text`, alias `\t`) or a label (`\label`).
///
/// Either may be written with a body or without one.
///
/// The two tags accept identical parameters, and ``kind`` is what keeps them
/// apart; see ``GMNText/Kind`` for why that matters. Three of the four
/// positional parameters are borrowed from elsewhere — `dy` from the common
/// appearance parameters, `textformat` and `fsize` from the font ones — so
/// they live in ``appearance`` and ``textStyle``.
public struct GMNText {

    // MARK: Public Initializers

    /// Creates a new text string with the provided identifier, kind, text,
    /// text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which of the two text tags this is.
    /// - Parameter text:       The text to draw.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                text: String,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.kind = kind
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag, `dy` among them
    /// — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which of the two text tags this is.
    public let kind: Kind

    // **Non-omissible, proven** in the other direction from most: read
    // *without* a default and assigned only when present (`ARText.cpp:46–49`),
    // so the declared empty default is never applied.

    /// The text to draw (`text`).
    ///
    /// Required by the template, so a `\text` without it never promotes to
    /// this payload and stays reserved.
    public let text: String

    /// The font parameters written for this tag.
    ///
    /// Two of the four are also this tag’s own positional slots — see the
    /// type’s discussion.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   kind: Kind,
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: "text")
        else { return nil }

        self.init(ident: ident,
                  kind: kind,
                  text: text,
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNText: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["text"] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNText: Equatable {
}

// MARK: - Sendable

extension GMNText: Sendable {
}
