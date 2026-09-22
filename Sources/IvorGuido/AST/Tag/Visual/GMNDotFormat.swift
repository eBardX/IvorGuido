// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARDotFormat`, which overrides `getParamsStr()` to `""`
// (`ARDotFormat.h:47`) and declares no template of its own, so `kCommonParams`
// is the whole of what it accepts. Range setting: `RANGEDC` — it may be
// written with a body or without one.

/// A dot-drawing setting (`\dotFormat`).
///
/// It may be written with a body or without one.
///
/// ## It exists only to carry the common parameters
///
/// The Guido documentation says as much: `\dotFormat` “is a way to
/// introduce common parameters to dots”. So ``appearance`` is not incidental
/// here, it is the entire tag — and since the tag has **no positional
/// parameters**, every one of the four must be written named.
public struct GMNDotFormat {

    // MARK: Public Initializers

    /// Creates a new dot-drawing setting with the provided identifier,
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

    /// The common appearance parameters written for this tag — all this tag
    /// carries.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
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

extension GMNDotFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("dotFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNDotFormat: Equatable {
}

// MARK: - Sendable

extension GMNDotFormat: Sendable {
}
