// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A variable definition in a Guido Music Notation score.
public struct GMNVariable {

    // MARK: Public Initializers

    /// Creates a new variable definition with the provided name and value.
    ///
    /// - Parameter name:   The name of this variable.
    /// - Parameter value:  The value of this variable.
    public init(name: String,
                value: Value) {
        self.name = name
        self.value = value
    }

    // MARK: Public Instance Properties

    /// The name of this variable.
    public let name: String

    /// The value of this variable.
    public let value: Value
}

// MARK: - Equatable

extension GMNVariable: Equatable {
}

// MARK: - Sendable

extension GMNVariable: Sendable {
}
