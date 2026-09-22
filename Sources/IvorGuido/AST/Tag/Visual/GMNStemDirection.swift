// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTStem`, `kARTStemParams` (`"U,length,7.0,o"`,
// `TagParameterStrings.cpp:82`). Range setting: `RANGEDC` (`ARTStem.cpp:31`) —
// each of the four may be written with a body or without one.

/// A stem-direction setting (`\stemsAuto`, `\stemsDown`, `\stemsOff`,
/// `\stemsUp`).
///
/// Each of the four may be written with a body or without one.
public struct GMNStemDirection {

    // MARK: Public Initializers

    /// Creates a new stem-direction setting with the provided identifier,
    /// kind, length, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which way the stems point.
    /// - Parameter length:     The stem length, or `nil` if none was written.
    ///                         Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                length: GMNLength? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.kind = kind
        self.length = length
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which way the stems point.
    public let kind: Kind

    // **Non-omissible, proven.**
    // `GRGlobalStem.cpp:375,895` and `GRVoiceManager.cpp:2029,2098` inspect
    // authorship with `TagIsSet()`, so an absent `length` and an explicit
    // `length=7` are different scores whatever the declared default says.

    /// The stem length (`length`), or `nil` if none was written.
    public let length: GMNLength?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  kind: Kind,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  kind: kind,
                  length: binding.length(named: "length"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNStemDirection: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["length"] = length?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNStemDirection: Equatable {
}

// MARK: - Sendable

extension GMNStemDirection: Sendable {
}
