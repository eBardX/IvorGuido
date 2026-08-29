// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARBarFormat`, `kARBarFormatParams`
// (`"S,style,staff,o;S,range,,o"`, `TagParameterStrings.cpp:37`). Range
// setting: `NO` — `\barFormat` takes no body.

/// A barline-drawing style setting (`\barFormat`).
///
/// `\barFormat` takes no body.
public struct GMNBarFormat {

    // MARK: Public Initializers

    /// Creates a new barline-format setting with the provided identifier,
    /// style, staff range, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter style:      How barlines are drawn, or `nil` if nothing was
    ///                         written. Defaults to `nil`.
    /// - Parameter range:      The staves the setting applies to, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                style: String? = nil,
                range: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.range = range
        self.style = style
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven.** Read without `usedefault` and parsed only
    // when present (`ARBarFormat.cpp:84–86`); the declared default is empty,
    // which `getRanges` would turn into no ranges at all, so absence and a
    // written default are not the same input.

    /// The staves the setting applies to (`range`), or `nil` if none was
    /// written.
    ///
    /// Written as an open syntax of colon-separated `start-end` pairs, and
    /// left unparsed here.
    public let range: String?

    // **Non-omissible.** Read without `usedefault` and assigned only when
    // present (`ARBarFormat.cpp:74–82`), so absent and default-valued reach
    // different code paths — even though the class’s own initial `fStyle`
    // happens to equal the declared default (`ARBarFormat.cpp:38`).

    /// How barlines are drawn (`style`), or `nil` if nothing was written.
    /// Declared default: `staff`.
    ///
    /// The recognized values are `staff` and `system`; anything else is
    /// diagnosed and ignored rather than rejected.
    public let style: String?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  style: binding.string(named: "style"),
                  range: binding.string(named: "range"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNBarFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("barFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["range"] = range.map { .string($0) }
        values["style"] = style.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNBarFormat: Equatable {
}

// MARK: - Sendable

extension GMNBarFormat: Sendable {
}
