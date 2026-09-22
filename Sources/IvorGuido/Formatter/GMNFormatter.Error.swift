// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNFormatter {

    // MARK: Public Nested Types

    /// An error that occurs when formatting a Guido Music Notation score.
    public enum Error {
        /// ``GMNFormatter/format(_:)`` was called on a score whose
        /// ``GMNScore/isValidated`` flag is `false`.
        ///
        /// Call ``GMNValidator/validate(_:)`` before
        /// ``GMNFormatter/format(_:)``.
        case notValidated
    }
}

// MARK: - EnhancedError

extension GMNFormatter.Error: EnhancedError {

    // MARK: Public Instance Properties

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorGuido")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notValidated:
            "Score must be validated before formatting; call GMNValidator.validate(_:) first"
        }
    }
}

// MARK: - Equatable

extension GMNFormatter.Error: Equatable {
}

// MARK: - Sendable

extension GMNFormatter.Error: Sendable {
}
