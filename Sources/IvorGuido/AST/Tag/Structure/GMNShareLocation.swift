// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARShareLocation`, which overrides `getParamsStr()` to `""`
// (`ARShareLocation.h:33`) and adds no map of its own. Range setting: `ONLY` —
// the notes that share a location are its body.

/// A shared-location passage (`\shareLocation`).
///
/// The notes that share a location are its body.
///
/// The common appearance parameters are the whole of what it accepts, and
/// every one of them must be written named: `\shareLocation<dx=2hs>(…)`,
/// never `\shareLocation<2hs>(…)`.
///
/// Unlike ``GMNMerge``, which reads similarly, what is written here is kept
/// rather than discarded.
public struct GMNShareLocation {

    // MARK: Public Initializers

    /// Creates a new shared-location passage with the provided identifier,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag — its entire
    /// parameter vocabulary.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag — the notes that share a location.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNShareLocation: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("shareLocation")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNShareLocation: Equatable {
}

// MARK: - Sendable

extension GMNShareLocation: Sendable {
}
