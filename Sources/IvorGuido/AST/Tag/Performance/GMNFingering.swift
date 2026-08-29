// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARFingering : ARText : ARFontAble`, `kARFingeringParams`
// (`"S,position,,o;U,fsize,10pt,o;"`, `TagParameterStrings.cpp:52`). Range
// setting: `ONLY` — the notes the fingering applies to are its body.
//
// ## Its positional slots come from its base class
//
// `ARFingering` never overrides `getParamsStr()`, so `checkTagParameters`
// binds unnamed parameters against `kARTextParams` — `text`, `dy`,
// `textformat`, `fsize` — while the supported set adds `kARFingeringParams`
// on top. `position` is therefore *supported but has no slot*. This is the
// same base-class split the registry test pins for this tag by name.
//
// ## `dy` is one of those inherited slots
//
// `kARTextParams` redeclares `dy` — a `kCommonParams` name — as its second
// positional slot. The value still lives in `appearance`; only its emission
// order differs, exactly as for `GMNHarmony`.

/// A fingering indication (`\fingering`, alias `\fing`).
///
/// The notes the fingering applies to are written as its body.
///
/// The positional parameters are `text`, `dy`, `textformat`, and `fsize`, in
/// that order. ``position`` has no positional slot and must always be written
/// named — `\fingering<"1","below">` binds `"below"` to `dy`, not to
/// `position`.
public struct GMNFingering {

    // MARK: Public Initializers

    /// Creates a new fingering with the provided identifier, text, position,
    /// text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter text:       The fingering itself.
    /// - Parameter position:   Which side of the staff the fingering sits on,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                text: String,
                position: GMNTag.Placement? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.position = position
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// Its `dy` is one of this tag’s inherited positional slots — see the
    /// type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven.** `ARFingering::setTagParameters` reads it
    // without `usedefault` and assigns only when present
    // (`ARFingering.cpp:47–53`), so absence leaves the constructor's own
    // position — a third state neither `above` nor `below` stands in for.

    /// Which side of the staff the fingering sits on (`position`), or `nil`
    /// if none was written.
    ///
    /// A `position` outside the closed vocabulary keeps the tag reserved
    /// rather than promoting to this payload; see
    /// ``GMNTag/Placement/init(guidoValue:)``.
    public let position: GMNTag.Placement?

    // Left a `String` rather than a list, although `ARFingering::scanText`
    // splits it on commas (`ARFingering.cpp:29–43`): the split is a rendering
    // detail, and re-joining it would be a rewrite this AST has no authority
    // to make.

    /// The fingering itself (`text`).
    ///
    /// Required, so a `\fingering` without it stays reserved. Several
    /// fingerings may be written as one comma-separated string.
    public let text: String

    // `fsize` is declared a second time by `kARFingeringParams` with a
    // different default. That changes where it is emitted, not how it is
    // modelled.

    /// The font parameters written for this tag.
    ///
    /// Two of the four — `textformat` and `fsize` — are also among this tag’s
    /// positional slots, which changes where they are emitted but not how
    /// they are written.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: "text"),
              !binding.hasUnreadablePlacement(named: "position")
        else { return nil }

        self.init(ident: ident,
                  text: text,
                  position: binding.placement(named: "position"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNFingering: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("fingering")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["position"] = position.map { .string($0.guidoValue) }
        values["text"] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNFingering: Equatable {
}

// MARK: - Sendable

extension GMNFingering: Sendable {
}
