// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A Guido Music Notation tag, which may carry parameters and contain a
/// sequence of symbols.
public struct GMNTag {

    // MARK: Public Initializers

    /// Creates a new tag with the provided name, identifier, parameters, and
    /// symbols.
    ///
    /// - Parameter name:           The name of this tag.
    /// - Parameter ident:          The optional numeric identifier of this
    ///                             tag.
    /// - Parameter parameters:     The parameters supplied to this tag.
    /// - Parameter symbols:        The symbols scoped to this tag.
    public init(name: String,
                ident: UInt?,
                parameters: [Parameter],
                symbols: [GMNSymbol]) {
        self.ident = ident
        self.name = name
        self.parameters = parameters
        self.symbols = symbols
    }

    // MARK: Public Instance Properties

    /// The optional numeric identifier of this tag.
    public let ident: UInt?

    /// The name of this tag.
    public let name: String

    /// The parameters supplied to this tag.
    public let parameters: [Parameter]

    /// The symbols scoped to this tag.
    public let symbols: [GMNSymbol]
}

// MARK: - Equatable

extension GMNTag: Equatable {
}

// MARK: - Sendable

extension GMNTag: Sendable {
}
