// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARMerge`, which overrides `getParamsStr()` to `""`
// (`ARMerge.h:39`) and derives from `ARMusicalTag` rather than
// `ARMTParameter`, so `ARFactory::addTagParameter` discards anything written
// to it (`ARFactory.cpp:2012–2016`). Range setting: `ONLY` — the notes to
// merge are its body.
//
// A `\merge` written with a parameter does not promote as parsed (see
// `GMNTagPromoter`); the normalizer drops the parameter and the tag promotes
// on the second pass.

/// A merged-voice passage (`\merge`).
///
/// The notes to merge are its body.
///
/// `\merge` takes no parameters of any kind — not even the common appearance
/// parameters — which is why it has no `appearance` of its own. A `\merge`
/// written with one has it dropped by ``GMNNormalizer``, which records
/// ``GMNNormalizer/Change/droppedUnacceptedParameters(_:)``.
public struct GMNMerge {

    // MARK: Public Initializers

    /// Creates a new merged-voice passage with the provided identifier and
    /// body.
    ///
    /// - Parameter ident: The numeric identifier written after this tag’s
    ///                    name. Defaults to `nil`.
    /// - Parameter body:  The symbols scoped to this tag. Defaults to none.
    public init(ident: GMNTag.Ident? = nil,
                body: [GMNSymbol] = []) {
        self.body = body
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The symbols scoped to this tag — the notes to merge.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?
}

// MARK: - GMNTagPayload

extension GMNMerge: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var appearance: GMNTag.Appearance {
        GMNTag.Appearance()
    }

    internal var name: GMNTag.Name {
        GMNTag.Name("merge")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNMerge: Equatable {
}

// MARK: - Sendable

extension GMNMerge: Sendable {
}
