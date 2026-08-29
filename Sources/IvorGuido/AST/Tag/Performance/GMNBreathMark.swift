// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARBreathMark : ARMTParameter`, no template of its own. Range
// setting: `NO` — `\breathMark` takes no body.
//
// ## Zero positional slots
//
// `ARBreathMark` overrides `getParamsStr()` to `""` (`ARBreathMark.h:42`), one
// of eighteen classes that do. It adds no parameter map either, so
// `kCommonParams` is the whole of what it accepts — and since those four never
// occupy a positional slot, every parameter this tag can carry is written
// named.

/// A breath mark (`\breathMark`).
///
/// `\breathMark` takes no body and accepts nothing but the common appearance
/// parameters, all of which must be written named — `\breathMark<dy=2hs>`
/// rather than `\breathMark<2hs>`.
public struct GMNBreathMark {

    // MARK: Public Initializers

    /// Creates a new breath mark with the provided identifier, appearance, and
    /// body.
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

    /// The common appearance parameters written for this tag.
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

extension GMNBreathMark: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("breathMark")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNBreathMark: Equatable {
}

// MARK: - Sendable

extension GMNBreathMark: Sendable {
}
