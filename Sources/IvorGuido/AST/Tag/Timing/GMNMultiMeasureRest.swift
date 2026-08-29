// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARMMRest`, `kARMMRestParams` (`"I,count,,r"`,
// `TagParameterStrings.cpp:64`). Range setting: `ONLY` — the rest the tag
// stands in for is its body.

/// A multiple-measure rest (`\mrest`).
///
/// The rest the tag stands in for is its body.
public struct GMNMultiMeasureRest {

    // MARK: Public Initializers

    /// Creates a new multiple-measure rest with the provided identifier,
    /// measure count, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter count:      The number of measures the rest spans.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                count: Int,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.count = count
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The number of measures the rest spans (`count`).
    ///
    /// Required, so a `\mrest` without it stays reserved. There is no
    /// default to fall back on.
    public let count: Int

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let count = binding.integer(named: "count")
        else { return nil }

        self.init(ident: ident,
                  count: count,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNMultiMeasureRest: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("mrest")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["count": .integer(count, nil)]
    }
}

// MARK: - Equatable

extension GMNMultiMeasureRest: Equatable {
}

// MARK: - Sendable

extension GMNMultiMeasureRest: Sendable {
}
