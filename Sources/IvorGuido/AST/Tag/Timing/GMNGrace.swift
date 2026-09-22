// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARGrace`, `kARGraceParams` (`"I,i,,o"`,
// `TagParameterStrings.cpp:55`). Range setting: `ONLY` — the grace notes
// themselves are the tag’s body.

/// A grace-note group (`\grace`).
///
/// The grace notes themselves are the tag’s body.
public struct GMNGrace {

    // MARK: Public Initializers

    /// Creates a new grace-note group with the provided identifier, index,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter index:      The grace-note index (`i`), or `nil` if none
    ///                         was written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                index: Int? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.index = index
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag — the grace notes themselves.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible, provisionally.** `ARGrace` declares no
    // `setTagParameters` of its own; the sole reader is `ARGrace::getIndex`,
    // which uses `usedefault=true` (`ARGrace.cpp:30`). That satisfies the
    // usedefault half of the omissibility test, but `kARGraceParams` declares
    // an *empty*
    // default, so there is no default spelling for an omission to stand in for
    // in the first place. The formatter never drops it.

    /// The grace-note index written for this tag (`i`), or `nil` if none was
    /// written.
    public let index: Int?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  index: binding.integer(named: "i"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNGrace: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("grace")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["i"] = index.map { .integer($0, nil) }

        return values
    }
}

// MARK: - Equatable

extension GMNGrace: Equatable {
}

// MARK: - Sendable

extension GMNGrace: Sendable {
}
