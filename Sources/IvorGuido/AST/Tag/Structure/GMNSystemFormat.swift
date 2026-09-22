// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARSystemFormat`, a class with no body at all beyond its name and
// ordering (`ARSystemFormat.h:45–58`). It neither overrides `getParamsStr()`
// nor registers a map, so `kCommonParams` is the whole schema. Range setting:
// `NO` — `\systemFormat` takes no body.

/// A system placement setting (`\systemFormat`).
///
/// `\systemFormat` takes no body.
///
/// Unusually, the common appearance parameters *are* this tag’s positional
/// slots — the opposite of ``GMNShareLocation``, which must have all four
/// written named. So `\systemFormat<"red",2hs>` is legal and binds `color`
/// and `dx`.
public struct GMNSystemFormat {

    // MARK: Public Initializers

    /// Creates a new system format with the provided identifier, appearance,
    /// and body.
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
    /// parameter vocabulary, and its positional slots.
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

extension GMNSystemFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("systemFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNSystemFormat: Equatable {
}

// MARK: - Sendable

extension GMNSystemFormat: Sendable {
}
