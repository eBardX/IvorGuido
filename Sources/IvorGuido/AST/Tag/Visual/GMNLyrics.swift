// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARLyrics : ARFontAble`, `kARLyricsParams`
// (`"S,text,,r;U,dy,-3,o;S,textformat,ct,o;U,fsize,12pt,o;S,autopos,off,o"`,
// `TagParameterStrings.cpp:61`). Range setting: `ONLY` (`ARLyrics.cpp:24`) —
// the notes the lyrics are sung to are its body.

/// A line of lyrics (`\lyrics`).
///
/// The notes the lyrics are sung to are its body.
///
/// Three of the five positional parameters are borrowed from elsewhere: `dy`
/// is a common appearance parameter, and `textformat` and `fsize` are font
/// parameters, each with a default of this tag’s own. They live in
/// ``appearance`` and ``textStyle`` all the same; only where they are emitted
/// differs.
public struct GMNLyrics {

    // MARK: Public Initializers

    /// Creates a new line of lyrics with the provided identifier, text,
    /// automatic positioning, text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter text:       The text to sing.
    /// - Parameter autopos:    Whether the lyrics are positioned
    ///                         automatically, as written, or `nil` if it was
    ///                         not written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                text: String,
                autopos: String? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.autopos = autopos
        self.body = body
        self.ident = ident
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag, `dy` among them
    /// — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    // **Non-omissible, proven.** Read with `usedefault=true`, but assigned
    // only when it reads `"on"` (`ARLyrics.cpp:26–27`) — so absence leaves
    // whichever default the constructor was given, which is the score-wide
    // `\auto<lyricsAutoPos>` setting rather than this template’s `off`.

    /// Whether the lyrics are positioned automatically (`autopos`), as
    /// written, or `nil` if it was not written.
    ///
    /// Not a `Bool`: `"on"` alone turns it on, and every other spelling means
    /// off — so `"off"` and `"maybe"` mean the same thing but are not the
    /// same text.
    public let autopos: String?

    /// The symbols scoped to this tag — the notes the lyrics are sung to.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The text to sing (`text`).
    ///
    /// Required by the template, so a `\lyrics` without it never promotes to
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
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: "text")
        else { return nil }

        self.init(ident: ident,
                  text: text,
                  autopos: binding.string(named: "autopos"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNLyrics: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("lyrics")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["autopos"] = autopos.map { .string($0) }
        values["text"] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNLyrics: Equatable {
}

// MARK: - Sendable

extension GMNLyrics: Sendable {
}
