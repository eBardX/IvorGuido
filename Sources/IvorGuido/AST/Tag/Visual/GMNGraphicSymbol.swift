// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARSymbol`, `kARSymbolParams`
// (`"S,file,,r;S,position,mid,o;I,w,,o;I,h,,o"`,
// `TagParameterStrings.cpp:76`). Range setting: `RANGEDC` (`ARSymbol.cpp:26`)
// — it may be written with a body or without one.

/// An imported graphic (`\symbol`, alias `\s`).
///
/// It may be written with a body or without one.
///
/// ## The one payload not named for its tag
///
/// Every other payload is `GMN` plus its tag name; this one cannot be,
/// because ``GMNSymbol`` is already the AST’s central enum of notes, rests,
/// chords, and tags.
public struct GMNGraphicSymbol {

    // MARK: Public Initializers

    /// Creates a new imported graphic with the provided identifier, file,
    /// position, size, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter file:       The path of the graphic to draw.
    /// - Parameter position:   Where the graphic sits relative to the staff,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter width:      The fixed width, or `nil` if none was written.
    ///                         Defaults to `nil`.
    /// - Parameter height:     The fixed height, or `nil` if none was written.
    ///                         Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                file: String,
                position: String? = nil,
                width: Int? = nil,
                height: Int? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.file = file
        self.height = height
        self.ident = ident
        self.position = position
        self.width = width
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The path of the graphic to draw (`file`).
    ///
    /// Required by the template, so a `\symbol` without it never promotes to
    /// this payload and stays reserved.
    public let file: String

    // **Non-omissible, proven.** `ARSymbol::getFixedHeight` reads it *without*
    // a default and answers `0` when it is absent (`ARSymbol.cpp:37–41`), so
    // the declared default is never applied and condition 1 fails outright.
    //
    // `ARSymbol` reads `h` as a `TagParameterInt` and as nothing else
    // (`ARSymbol.cpp:42`), matching the template's `I`. It was once exempted
    // instead, on a by-name reading of the ambiguity grep that conflated
    // this class with `ARBowing` and `ARPageFormat` — see
    // `GMNTagTemplate.alternateParameterKinds`.

    /// The fixed height in virtual units (`h`), or `nil` if none was written.
    ///
    /// It must be a whole number: an `h` written as a float or a string is
    /// inert, and the normalizer drops it.
    public let height: Int?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven** — read without a default, like `height`
    // (`ARSymbol.cpp:43–47`).

    /// Where the graphic sits relative to the staff (`position`), or `nil` if
    /// none was written.
    ///
    /// A different vocabulary from the `above`/`below` one the articulations
    /// use, which is why this is not a ``GMNTag/Placement``: `top`, `bot`, and
    /// `bottom` are recognized, and everything else means the middle.
    public let position: String?

    // **Non-omissible, proven** — read without a default, like `height`
    // (`ARSymbol.cpp:31–35`), and likewise one of the four ambiguously typed
    // names.

    /// The fixed width in virtual units (`w`), or `nil` if none was written.
    public let width: Int?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let file = binding.string(named: "file")
        else { return nil }

        self.init(ident: ident,
                  file: file,
                  position: binding.string(named: "position"),
                  width: binding.integer(named: "w"),
                  height: binding.integer(named: "h"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNGraphicSymbol: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("symbol")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["file"] = .string(file)
        values["h"] = height.map { .integer($0, nil) }
        values["position"] = position.map { .string($0) }
        values["w"] = width.map { .integer($0, nil) }

        return values
    }
}

// MARK: - Equatable

extension GMNGraphicSymbol: Equatable {
}

// MARK: - Sendable

extension GMNGraphicSymbol: Sendable {
}
