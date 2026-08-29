// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARStaffOn` and `ARStaffOff`, two classes that differ in nothing
// but their name. Both override `getParamsStr()` to `""` (`ARStaffOn.h:47`,
// `ARStaffOff.h:51`) and add no map of their own, so `kCommonParams` is the
// whole schema and — because the empty override means those four have no
// positional slot — every parameter must be written named. Range setting:
// `NO` for both.

/// A staff visibility switch (`\staffOn`, `\staffOff`).
public struct GMNStaffVisibility {

    // MARK: Public Initializers

    /// Creates a new staff visibility switch with the provided identifier,
    /// kind, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which way the staff is switched.
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

    /// The common appearance parameters written for this tag — its entire
    /// parameter vocabulary.
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

    /// Which way the staff is switched.
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

extension GMNStaffVisibility: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNStaffVisibility: Equatable {
}

// MARK: - Sendable

extension GMNStaffVisibility: Sendable {
}
