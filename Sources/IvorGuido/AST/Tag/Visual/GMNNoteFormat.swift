// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARNoteFormat`, `kARNoteFormatParams` (`"S,style,standard,o"`,
// `TagParameterStrings.cpp:65`). Range setting: `RANGEDC` — it may be written
// with a body or without one.

/// A notehead-drawing setting (`\noteFormat`).
///
/// It may be written with a body or without one.
public struct GMNNoteFormat {

    // MARK: Public Initializers

    /// Creates a new notehead-drawing setting with the provided identifier,
    /// style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter style:      The notehead style, or `nil` if none was
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

    // **Non-omissible, provisionally.** `ARNoteFormat::getTPStyle` reads it
    // with `usedefault=true` (`ARNoteFormat.cpp:37`) and no consumer inspects
    // it with `TagIsSet()` — but treated as non-omissible for now: its one
    // reader, `GRSingleNote.cpp:1102–1104`, guards on the pointer rather than
    // on the value, so absence is not obviously unobservable.

    /// The notehead style (`style`), as in `"diamond"`, or `nil` if none was
    /// written.
    ///
    /// The vocabulary is open: the string is resolved against a glyph table
    /// only when the score is rendered.
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

extension GMNNoteFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("noteFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["style"] = style.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNNoteFormat: Equatable {
}

// MARK: - Sendable

extension GMNNoteFormat: Sendable {
}
