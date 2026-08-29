// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARCue : ARFontAble`, `kARCueParams` (`"S,name,,o;U,fsize,9pt,o"`,
// `TagParameterStrings.cpp:47`) on top of `kARFontAbleParams`. Range setting:
// `ONLY` — the cue notes are its body.

/// A cue-note passage (`\cue`).
///
/// The cue notes are its body.
///
/// `fsize` is one of this tag’s own positional slots, which changes where it
/// is emitted but not how it is written; it is carried in ``textStyle`` like
/// every other font parameter.
public struct GMNCue {

    // MARK: Public Initializers

    /// Creates a new cue with the provided identifier, name, text style,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter name:       The cue’s description, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                name: String? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.cueName = name
        self.ident = ident
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag — the cue notes themselves.
    public let body: [GMNSymbol]

    // **Non-omissible, provisionally.** `ARCue::getName` reads it with
    // `usedefault=true` (`ARCue.cpp:28`) and it is not on the `TagIsSet()`
    // blocklist, which puts it in the explicitly provisional bucket; the
    // formatter takes the safe branch and emits what was written.

    /// The cue’s description (`name`), or `nil` if none was written.
    ///
    /// Spelled `cueName` rather than `name` because `GMNTagPayload` already
    /// claims `name` for the tag’s own canonical name.
    public let cueName: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The font parameters written for this tag.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  name: binding.string(named: "name"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNCue: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("cue")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["name"] = cueName.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNCue: Equatable {
}

// MARK: - Sendable

extension GMNCue: Sendable {
}
