// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARMark : ARText : ARFontAble`, `kARMarkParams`
// (`"S,text,,r;S,enclosure,none,o;U,dy,0,o"`, `TagParameterStrings.cpp:62`).
// Range setting: `NO` (`ARMark.cpp:22`) — `\mark` takes no body.

/// A rehearsal mark (`\mark`).
///
/// `\mark` takes no body.
///
/// `dy` is one of this tag’s own positional parameters as well as a common
/// appearance one, so `\mark<"A",dy=2hs>` is legal and `\mark`’s third
/// unnamed parameter binds to it. It is one parameter either way, and this
/// payload keeps it in ``appearance`` where every other tag’s `dy` lives.
public struct GMNMark {

    // MARK: Public Initializers

    /// Creates a new rehearsal mark with the provided identifier, text,
    /// enclosure, text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter text:       The text of the mark.
    /// - Parameter enclosure:  The shape drawn around the text, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                text: String,
                enclosure: Enclosure? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.enclosure = enclosure
        self.ident = ident
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag, `dy` among them
    /// — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, proven.** `ARMark::setTagParameters` reads it *without*
    // a default and assigns only when it is present (`ARMark.cpp:45–47`), so
    // absence leaves the constructor’s `kNoEnclosure` rather than applying the
    // template’s `none` — the same value by coincidence, reached by a path
    // that never consults the default.

    /// The shape drawn around the text (`enclosure`), or `nil` if none was
    /// written.
    public let enclosure: Enclosure?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The text of the mark (`text`).
    ///
    /// Required by the template, so a `\mark` without it never promotes to
    /// this payload and stays reserved.
    public let text: String

    /// The font parameters written for this tag.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: "text"),
              !Self._hasUnreadableEnclosure(binding)
        else { return nil }

        self.init(ident: ident,
                  text: text,
                  enclosure: binding.string(named: "enclosure").flatMap { Enclosure(guidoValue: $0) },
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: -

extension GMNMark {

    // MARK: Private Type Methods

    // Whether an `enclosure` was written that the closed vocabulary cannot
    // read — see `Enclosure.init?(guidoValue:)` for why that stops the tag
    // promoting rather than reading as ``Enclosure/none``.
    private static func _hasUnreadableEnclosure(_ binding: GMNTagBinder.Binding) -> Bool {
        guard let written = binding.string(named: "enclosure")
        else { return false }

        return Enclosure(guidoValue: written) == nil
    }
}

// MARK: - GMNTagPayload

extension GMNMark: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("mark")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["enclosure"] = enclosure.map { .string($0.guidoValue) }
        values["text"] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNMark: Equatable {
}

// MARK: - Sendable

extension GMNMark: Sendable {
}
