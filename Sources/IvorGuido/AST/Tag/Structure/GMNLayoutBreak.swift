// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARNewSystem` and `ARNewPage`. Neither overrides `getParamsStr()`
// nor adds a parameter map of its own, so `kCommonParams` is the entire schema
// and all four common parameters bind **positionally** (`ARMusicalTag.h:61`).
// Range setting: `NO` — a layout break takes no body.
//
// `ARNewSystem` derives from `ARMTParameter` and `ARNewPage` from
// `ARMusicalTag` directly, and `ARFactory::addTagParameter` records a
// parameter only for the former (`ARFactory.cpp:2012–2016`). A `\newPage`
// written with any parameter at all does not promote to this payload as
// parsed (see `GMNTagPromoter`).

/// A forced layout break (`\newLine`, `\newSystem`, `\newPage`).
///
/// A layout break takes no body.
///
/// ## The two kinds are not interchangeable
///
/// `\newSystem<dx=2hs>` carries an offset; `\newPage<dx=2hs>` carries
/// nothing. ``GMNNormalizer`` drops the parameter from a `\newPage` and
/// records ``GMNNormalizer/Change/droppedUnacceptedParameters(_:)``, so what
/// is thrown away is announced rather than lost silently. `\newSystem` is
/// untouched by that repair.
public struct GMNLayoutBreak {

    // MARK: Public Initializers

    /// Creates a new layout break with the provided identifier, kind,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which layout break this is.
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

    // Its whole schema. All four are non-omissible.

    /// The common appearance parameters written for this tag — the whole of
    /// what it accepts.
    ///
    /// Always empty for ``Kind/newPage``, which accepts no parameters at all.
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

    /// Which layout break this is.
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

extension GMNLayoutBreak: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch kind {
        case .newPage:
            GMNTag.Name("newPage")

        case .newSystem:
            GMNTag.Name("newSystem")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        [:]
    }
}

// MARK: - Equatable

extension GMNLayoutBreak: Equatable {
}

// MARK: - Sendable

extension GMNLayoutBreak: Sendable {
}
