// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNVariable {
    /// The value of a Guido Music Notation variable.
    public enum Value {
        /// A floating-point value.
        case floating(Double)

        /// An integer value.
        case integer(Int)

        /// A string value.
        case string(String)
    }
}

// MARK: - Equatable

extension GMNVariable.Value: Equatable {
}

// MARK: - Sendable

extension GMNVariable.Value: Sendable {
}
