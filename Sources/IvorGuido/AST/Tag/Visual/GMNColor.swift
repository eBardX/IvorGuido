// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARColor`, `kARColorParams` (`"S,color,black,r"`,
// `TagParameterStrings.cpp:45`). Range setting: `NO` — `\color` takes no body.
// Line 44 of that file holds a commented-out four-channel form; the live
// declaration is the single string parameter.
//
// `TagParameterStrings.cpp:44` holds a commented-out four-channel form; the
// live declaration is the single string parameter.

/// A voice color setting (`\color`, alias `\colour`).
///
/// `\color` takes no body.
///
/// ## Its one parameter is also a common parameter
///
/// `\color` is the one tag whose own parameter is nothing but one every tag
/// already accepts. What differs here is that it is **required** and is the
/// first positional parameter, which is why `\color<"red">` is legal.
///
/// That makes ``color`` and ``GMNTag/Appearance/color`` the same parameter,
/// and this payload holds it in the former, since the tag cannot exist
/// without it. This payload’s ``appearance`` therefore never carries a
/// color, and one set on a hand-built value is ignored.
public struct GMNColor {

    // MARK: Public Initializers

    /// Creates a new voice color setting with the provided identifier,
    /// color, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter color:      The color to apply to the voices that follow.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag, other than the color itself.
    ///                         Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                color: String,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.color = color
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag, other than the
    /// color itself — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The color to apply to the voices that follow (`color`).
    ///
    /// Required, so a `\color` without it stays reserved. The grammar is
    /// open, admitting an HTML color name or an `0xrrggbb` / `0xrrggbbaa`
    /// string.
    public let color: String

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let color = binding.string(named: "color")
        else { return nil }

        // The colour is deliberately *not* read back out of `appearance`: it
        // is one parameter, and `color` above is where this payload keeps it.
        self.init(ident: ident,
                  color: color,
                  appearance: GMNTag.Appearance(dx: binding.length(named: "dx"),
                                                dy: binding.length(named: "dy"),
                                                size: binding.double(named: "size")),
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNColor: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("color")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["color": .string(color)]
    }
}

// MARK: - Equatable

extension GMNColor: Equatable {
}

// MARK: - Sendable

extension GMNColor: Sendable {
}
