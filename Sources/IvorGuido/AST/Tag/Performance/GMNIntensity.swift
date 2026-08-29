// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARIntens : ARFontAble`, `kARIntensParams`
// (`"S,type,,r;S,before,,o;S,after,,o;S,font,Times,o;U,fsize,10pt,o;S,fattrib,i,o;S,autopos,off,o"`,
// `TagParameterStrings.cpp:58`). Range setting: `NO` — `\intensity` takes no
// body.
//
// ## Four of the seven slots are the font
//
// `font`, `fsize`, and `fattrib` are `kARFontAbleParams` names redeclared as
// positional slots of this tag's own, with defaults of its own. They live in
// `textStyle` all the same; only where they are emitted differs.
// `textformat` is the one font parameter this tag does *not* redeclare, so
// it has no slot.

/// A dynamic marking (`\intensity`, aliases `\intens`, `\i`).
///
/// `\intensity` takes no body. Its positional parameters are `type`,
/// `before`, `after`, `font`, `fsize`, `fattrib`, and `autopos`, in that
/// order — `fattrib` defaults to `i`, which is how a dynamic marking comes
/// out italic without anyone writing it. `textformat` has no positional slot
/// and must always be written named.
public struct GMNIntensity {

    // MARK: Public Initializers

    /// Creates a new dynamic marking with the provided identifier, type,
    /// texts, automatic positioning, text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter type:       The dynamic marking itself.
    /// - Parameter before:     The text drawn before the marking, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter after:      The text drawn after the marking, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter autopos:    Whether the marking is positioned
    ///                         automatically, as written, or `nil` if it was
    ///                         not written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                type: String,
                before: String? = nil,
                after: String? = nil,
                autopos: String? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.after = after
        self.appearance = appearance
        self.autopos = autopos
        self.before = before
        self.body = body
        self.ident = ident
        self.textStyle = textStyle
        self.type = type
    }

    // MARK: Public Instance Properties

    /// The text drawn after the marking (`after`), or `nil` if none was
    /// written.
    public let after: String?

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARIntens.cpp:49–50`), so absence leaves whichever default
    // the constructor was given — which is the score-wide
    // `\auto<intensAutoPos>` setting, not this template’s `off`.

    /// Whether the marking is positioned automatically (`autopos`), as
    /// written, or `nil` if it was not written.
    public let autopos: String?

    // **Non-omissible, proven** — same read as `after` and `type`
    // (`ARIntens.cpp:43–48`): each is read without `usedefault` and yields the
    // empty string when absent, so the declared default is never applied.

    /// The text drawn before the marking (`before`), or `nil` if none was
    /// written.
    public let before: String?

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The font parameters written for this tag.
    ///
    /// Three of the four are also this tag’s own positional slots — see the
    /// type’s discussion.
    public let textStyle: GMNTag.TextStyle

    /// The dynamic marking itself (`type`), as in `"pp"` or `"ff"`.
    ///
    /// Required, so an `\intensity` without it stays reserved. The
    /// vocabulary is open: the string is matched against a symbol table only
    /// when the score is rendered.
    public let type: String

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let type = binding.string(named: "type")
        else { return nil }

        self.init(ident: ident,
                  type: type,
                  before: binding.string(named: "before"),
                  after: binding.string(named: "after"),
                  autopos: binding.string(named: "autopos"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNIntensity: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("intensity")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["after"] = after.map { .string($0) }
        values["autopos"] = autopos.map { .string($0) }
        values["before"] = before.map { .string($0) }
        values["type"] = .string(type)

        return values
    }
}

// MARK: - Equatable

extension GMNIntensity: Equatable {
}

// MARK: - Sendable

extension GMNIntensity: Sendable {
}
