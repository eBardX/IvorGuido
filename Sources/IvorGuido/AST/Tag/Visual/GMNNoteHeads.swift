// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTHead`, which declares no template of its own and never
// overrides `getParamsStr()` (`ARTHead.h`), so `kCommonParams` is both the
// whole of what it accepts *and* its positional slots — an exception to the
// rule that those parameters are always named, and the reason
// `\headsLeft<"red">` is legal and means `color="red"`. Range setting:
// `RANGEDC`
// (`ARTHead.cpp:24`) — each of the five may be written with a body or without
// one.

/// A notehead placement (`\headsCenter`, `\headsLeft`, `\headsNormal`,
/// `\headsReverse`, `\headsRight`).
///
/// Each of the five may be written with a body or without one.
public struct GMNNoteHeads {

    // MARK: Public Initializers

    /// Creates a new notehead placement with the provided identifier, kind,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Where the notehead goes.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.kind = kind
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// These are also this tag’s four positional slots — see the type’s
    /// discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Where the notehead goes.
    public let kind: Kind

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  kind: Kind,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  kind: kind,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNNoteHeads: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNNoteHeads: Equatable {
}

// MARK: - Sendable

extension GMNNoteHeads: Sendable {
}
