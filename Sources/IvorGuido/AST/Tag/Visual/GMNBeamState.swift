// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARBeamState`, which overrides `getParamsStr()` to `""`
// (`ARBeamState.h:60`) and derives from `ARMusicalTag` rather than
// `ARMTParameter`, so `ARFactory::addTagParameter` discards anything written
// to it (`ARFactory.cpp:2012–2016`). Range setting: `NO` — none of the three
// names takes a body.

/// An automatic-beaming setting (`\beamsAuto`, `\beamsFull`, `\beamsOff`).
///
/// None of the three names takes a body.
///
/// Like ``GMNMerge``, this payload has no `appearance` of its own: the tag
/// accepts no parameters at all, not even the common appearance ones. One
/// written with a parameter has it dropped by ``GMNNormalizer``, which records
/// ``GMNNormalizer/Change/droppedUnacceptedParameters(_:)``, so the loss is
/// announced rather than silent.
public struct GMNBeamState {

    // MARK: Public Initializers

    /// Creates a new automatic-beaming setting with the provided identifier,
    /// kind, and body.
    ///
    /// - Parameter ident: The numeric identifier written after this tag’s
    ///                    name. Defaults to `nil`.
    /// - Parameter kind:  Which automatic-beaming setting this tag selects.
    /// - Parameter body:  The symbols scoped to this tag. Defaults to none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                body: [GMNSymbol] = []) {
        self.body = body
        self.ident = ident
        self.kind = kind
    }

    // MARK: Public Instance Properties

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which automatic-beaming setting this tag selects.
    public let kind: Kind
}

// MARK: - GMNTagPayload

extension GMNBeamState: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var appearance: GMNTag.Appearance {
        GMNTag.Appearance()
    }

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNBeamState: Equatable {
}

// MARK: - Sendable

extension GMNBeamState: Sendable {
}
