// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARNotations : ARMTParameter`, with no template of its own and no
// parameter map (`ARNotations.h`), so `kCommonParams` is the whole of what it
// accepts. Range setting: `NO` — neither name takes a body.

/// A pedal indication (`\pedalOn`, `\pedalOff`).
///
/// Neither name takes a body.
///
/// Unusually, the common appearance parameters *are* this tag’s positional
/// slots: `color`, `dx`, `dy`, and `size`, in that order. That is why
/// `\pedalOn<"red">` is legal and means `color="red"`.
public struct GMNPedal {

    // MARK: Public Initializers

    /// Creates a new pedal indication with the provided identifier, kind,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which way the pedal moves.
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

    /// Which way the pedal moves.
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

extension GMNPedal: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNPedal: Equatable {
}

// MARK: - Sendable

extension GMNPedal: Sendable {
}
