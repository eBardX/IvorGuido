// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARCluster`, `kARClusterParams` (`"U,hdx,0hs,o;U,hdy,0hs,o"`,
// `TagParameterStrings.cpp:43`). Range setting: `ONLY` — `\cluster` takes the
// notes it clusters as its body.

/// A note cluster (`\cluster`).
///
/// `\cluster` takes the notes it clusters as its body.
public struct GMNCluster {

    // MARK: Public Initializers

    /// Creates a new cluster with the provided identifier, head offsets,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter hdx:        The horizontal head offset, or `nil` if none
    ///                         was written. Defaults to `nil`.
    /// - Parameter hdy:        The vertical head offset, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                hdx: GMNLength? = nil,
                hdy: GMNLength? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.hdx = hdx
        self.hdy = hdy
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, provisionally.** `ARCluster::setTagParameters` reads it
    // with `usedefault=true` (`ARCluster.cpp:55–56`), which satisfies the
    // usedefault half of the omissibility test, and it is not on the
    // `TagIsSet()` blocklist — but treated as non-omissible for now, pending
    // a check that the getter is its only reader. The
    // formatter takes the safe branch and never drops it.

    /// The horizontal offset of the cluster’s note heads (`hdx`), or `nil` if
    /// none was written.
    public let hdx: GMNLength?

    // **Non-omissible, provisionally** — same verdict and same reasoning as
    // `hdx` (`ARCluster.cpp:57–58`).

    /// The vertical offset of the cluster’s note heads (`hdy`), or `nil` if
    /// none was written.
    public let hdy: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  hdx: binding.length(named: "hdx"),
                  hdy: binding.length(named: "hdy"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNCluster: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("cluster")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["hdx"] = hdx?.parameterValue
        values["hdy"] = hdy?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNCluster: Equatable {
}

// MARK: - Sendable

extension GMNCluster: Sendable {
}
