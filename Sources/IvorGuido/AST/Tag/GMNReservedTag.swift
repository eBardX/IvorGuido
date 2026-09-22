// © 2026 John Gary Pusey (see LICENSE.md)

// "Recognized" throughout this type means `ARFactory::createTag` has a branch
// for the name.

/// A Guido Music Notation tag whose name GMN reserves but no typed payload
/// claims, carried in its untyped, as-written form.
///
/// This is the payload of ``GMNTag/reserved(_:)``, one of the two untyped
/// lanes of the tag model: a name, an optional identifier, a flat list of
/// parameters, and a body of scoped symbols. Nothing here is interpreted — the
/// parameters are whatever was written, in the order they were written, bound
/// to nothing.
///
/// ## What lands here, and for how long
///
/// Three names land here **permanently**, by decision rather than by
/// omission: `\port`, which GMN reserves but treats as a no-op, and
/// `\DrHoos` and `\DrRenz`, which fall outside the 59-payload catalog. The
/// catalog is closed, so this set does not grow or shrink.
///
/// Everything else that lands here is **temporary, and lasts until the
/// normalizer runs**. The parser never repairs and never discards, so a tag
/// whose parameters do not yet bind cleanly arrives here intact: an unknown
/// parameter, a raw identifier, a `$variable`, a unit on a slot that cannot
/// carry one, a value of the wrong type. ``GMNNormalizer`` repairs each of
/// those and re-runs promotion, which is why **a parsed score is less typed
/// than a normalized one**.
///
/// After ``GMNNormalizer/normalize(_:)`` returns, the only names left on this
/// lane are the three above and the ones a defect no repair could reach kept
/// off a typed lane. Staying here is what carries such a tag to
/// ``GMNValidator``, which reports it — see ``GMNValidator/Issue``.
///
/// ## What does *not* land here
///
/// A name GMN does not reserve at all is ``GMNTag/custom(_:)``, not this.
/// The distinction is drawn where tags are built, by the parser, which tests
/// the name and sends it down one lane or the other.
///
/// ## Read, never written
///
/// This payload has no public initializer. Every value of it comes from
/// ``GMNParser``, and the reason is that its admission rule is *reservation*
/// rather than the three permanent names above: a lossless parser has to
/// carry `\beam<bogus=1>` before the normalizer repairs it, so any rule
/// narrow enough to keep a hand-built score well formed would be too narrow
/// for the parser. Rather than pick one and lose the other, the lane is
/// readable but not constructible — a hand-built tag reaches its meaning
/// through a typed payload, or through ``GMNCustomTag`` for a name GMN does
/// not reserve.
///
/// The three permanent residents are the price: none of `\port`, `\DrHoos`,
/// or `\DrRenz` can be written into a hand-built score, though each still
/// round-trips a parsed one untouched.
public struct GMNReservedTag {

    // MARK: Public Type Aliases

    /// The optional numeric identifier of a reserved tag.
    public typealias Ident = GMNTag.Ident

    /// The name of a reserved tag.
    public typealias Name = GMNTag.Name

    /// A single parameter supplied to a reserved tag.
    public typealias Parameter = GMNTag.Parameter

    // MARK: Public Instance Properties

    /// The symbols scoped to this tag.
    public let body: [GMNSymbol]

    /// The optional numeric identifier of this tag.
    public let ident: Ident?

    /// The name of this tag, as written — an alias such as `\bm` is *not*
    /// canonicalized here.
    ///
    /// Canonicalizing it is the normalizer’s job, and it happens on this lane
    /// only: a typed payload has no name to canonicalize, because the case
    /// itself is the canonical identity.
    public let name: Name

    /// The parameters supplied to this tag, in the order they were written.
    ///
    /// Unbound, so a parameter here may be positional or named, may repeat a
    /// name, and may carry a value of a type the tag does not accept.
    public let parameters: [Parameter]

    // MARK: Internal Initializers

    // Creates a reserved tag without testing `name` against the registry.
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

// MARK: -

extension GMNReservedTag {

    // MARK: Internal Instance Properties

    // This tag's parameters bound against its own template.
    //
    // Never `nil` in practice — the initializer admits only names the
    // registry knows, and every such name has a template. The optionality is
    // `template`'s, carried through rather than force-unwrapped away.
    internal var binding: GMNTagBinder.Binding? {
        guard let template
        else { return nil }

        return GMNTagBinder.bind(parameters,
                                 to: template)
    }

    // The guidolib parameter schema for this tag's name.
    //
    // `parameters` is passed because `\pageFormat` has two templates and
    // chooses between them by what was written.
    internal var template: GMNTagTemplate? {
        GMNTagTemplate.Registry.template(for: name,
                                         parameters: parameters)
    }
}

// MARK: - GMNUntypedTag

extension GMNReservedTag: GMNUntypedTag {

    // MARK: Internal Instance Properties

    // The `kCommonParams` parameters written for this tag, read off its
    // binding.
    internal var appearance: GMNTag.Appearance {
        binding?.appearance ?? GMNTag.Appearance()
    }

    // This tag's bound parameters.
    //
    // Conformance requires it, but the formatter never reads it for this
    // type: a reserved tag never promoted, so it has no slot order to be
    // emitted in and `formatUntypedTag(_:)` writes back exactly what was
    // written instead — the canonical-form rules apply only to the typed cases.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        binding?.values ?? [:]
    }
}

// MARK: - Equatable

extension GMNReservedTag: Equatable {
}

// MARK: - Sendable

extension GMNReservedTag: Sendable {
}
