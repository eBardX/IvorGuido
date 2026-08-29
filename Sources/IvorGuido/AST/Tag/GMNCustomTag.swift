// © 2025–2026 John Gary Pusey (see LICENSE.md)
//
// "Recognized" throughout this type means `ARFactory::createTag` has a branch
// for the name.

/// A Guido Music Notation tag whose name GMN does not reserve, carried in
/// its untyped, as-written form.
///
/// This is the payload of ``GMNTag/custom(_:)``, one of the two untyped lanes
/// of the tag model, and it is exactly the shape every tag had before the
/// model was typed: a name, an optional identifier, a flat list of parameters,
/// and a body of scoped symbols. Nothing here is interpreted — the parameters
/// are whatever was written, in the order they were written, bound to nothing.
///
/// This is how GMN accommodates third-party extension: a name outside its
/// reserved vocabulary is not an error, but a custom tag that round-trips
/// intact and realizes as a no-op, ready for a consumer or a downstream tool
/// to give it meaning.
///
/// ## What lands here
///
/// A name outside GMN’s reserved vocabulary: `\bembel`, `\splitChord`,
/// `\shortFermata`, `\chord`, and anything a consumer invents. Nothing reads
/// what was written to such a tag, so there is no schema to bind against and
/// nothing to model. It round-trips byte for byte and realizes as a no-op.
///
/// ## What does *not* land here
///
/// A reserved name that failed to promote is ``GMNTag/reserved(_:)``, not
/// this. The distinction is enforced by ``init(ident:name:parameters:body:)``,
/// which fails for a reserved name — so a `GMNCustomTag` never carries a
/// reserved name, at any stage, and the case cannot be used as a general
/// escape hatch.
public struct GMNCustomTag {

    // MARK: Public Type Aliases

    /// The optional numeric identifier of a custom tag.
    public typealias Ident = GMNTag.Ident

    /// The name of a custom tag.
    public typealias Name = GMNTag.Name

    /// A single parameter supplied to a custom tag.
    public typealias Parameter = GMNTag.Parameter

    // MARK: Public Initializers

    /// Creates a new custom tag with the provided identifier, name,
    /// parameters, and body, or `nil` if `name` is one GMN reserves.
    ///
    /// A reserved name belongs on the ``GMNTag/reserved(_:)`` lane whether or
    /// not a payload claims it yet. Refusing it here is what makes “no custom
    /// tag has a reserved name” an invariant of *every* stage rather than a
    /// convention the parser happens to keep.
    ///
    /// - Parameter ident:      The optional numeric identifier of this tag.
    /// - Parameter name:       The name of this tag.
    /// - Parameter parameters: The parameters supplied to this tag, as
    ///                         written.
    /// - Parameter body:       The symbols scoped to this tag.
    public init?(ident: Ident?,
                 name: Name,
                 parameters: [Parameter],
                 body: [GMNSymbol]) {
        guard !GMNTagTemplate.Registry.names.contains(name.stringValue)
        else { return nil }

        self.init(unchecked: ident,
                  name: name,
                  parameters: parameters,
                  body: body)
    }

    // MARK: Public Instance Properties

    /// The symbols scoped to this tag.
    public let body: [GMNSymbol]

    /// The optional numeric identifier of this tag.
    public let ident: Ident?

    /// The name of this tag, as written.
    ///
    /// There is nothing to canonicalize: an alias is an alias *of* a reserved
    /// name, and no reserved name can reach this type.
    public let name: Name

    /// The parameters supplied to this tag, in the order they were written.
    ///
    /// Unbound, and unbindable — there is no schema for this name, so a
    /// parameter here is neither positional nor named in any sense GMN would
    /// honor. It is preserved so the tag round-trips.
    public let parameters: [Parameter]

    // MARK: Internal Initializers

    // Creates a custom tag without testing `name` against the registry.
    //
    // `GMNTag.untyped(ident:name:parameters:body:)` branches on that very
    // test and is the only caller, so the check would be the same one twice
    // and its failure branch would be unreachable. This exists to keep that
    // branch from having to be written, not to let anything skip the rule.
    internal init(unchecked ident: Ident?,
                  name: Name,
                  parameters: [Parameter],
                  body: [GMNSymbol]) {
        self.body = body
        self.ident = ident
        self.name = name
        self.parameters = parameters
    }
}

// MARK: - GMNUntypedTag

extension GMNCustomTag: GMNUntypedTag {

    // MARK: Internal Instance Properties

    // Empty, always. `kCommonParams` is read off a binding, and an
    // undispatched name has no template to bind against — which matches
    // guidolib, whose `ARTDummy` never receives a parameter in the first
    // place.
    internal var appearance: GMNTag.Appearance {
        GMNTag.Appearance()
    }

    // Empty, always, for the same reason as `appearance`.
    //
    // Conformance requires it, but the formatter never reads it for this
    // type: a custom tag never promoted, so it has no slot order to be
    // emitted in and `formatUntypedTag(_:)` writes back exactly what was
    // written instead — the canonical-form rules apply only to the typed cases.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNCustomTag: Equatable {
}

// MARK: - Sendable

extension GMNCustomTag: Sendable {
}
