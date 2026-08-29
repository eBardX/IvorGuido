// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARSpace`, `kARSpaceParams` (`"U,dd,,r"`,
// `TagParameterStrings.cpp:71`). Range setting: `NO` — `\space` takes no body.

/// An explicit horizontal space (`\space`).
///
/// `\space` takes no body.
public struct GMNSpace {

    // MARK: Public Initializers

    /// Creates a new space with the provided identifier, distance, appearance,
    /// and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter distance:   How much space to insert.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                distance: GMNLength,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.distance = distance
        self.ident = ident
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

    // **Non-omissible**, moot for a required parameter: read without
    // `usedefault` and assigned only when present (`ARSpace.cpp:30–31`).

    /// How much space to insert (`dd`).
    ///
    /// Required by the template, so a `\space` without it never promotes to
    /// this payload and stays reserved.
    public let distance: GMNLength

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let distance = binding.length(named: "dd")
        else { return nil }

        self.init(ident: ident,
                  distance: distance,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNSpace: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("space")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["dd": distance.parameterValue]
    }
}

// MARK: - Equatable

extension GMNSpace: Equatable {
}

// MARK: - Sendable

extension GMNSpace: Sendable {
}
