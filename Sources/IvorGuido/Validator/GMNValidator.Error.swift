// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNValidator {

    // MARK: Public Nested Types

    /// An error thrown when a score operation requires prior normalization.
    public enum Error {
        /// ``GMNValidator/validate(_:)`` was called on a score whose
        /// ``GMNScore/isNormalized`` flag is `false`.
        ///
        /// Call ``GMNNormalizer/normalize(_:)`` before
        /// ``GMNValidator/validate(_:)``.
        case notNormalized
    }
}

// MARK: - EnhancedError

extension GMNValidator.Error: EnhancedError {

    // MARK: Public Instance Properties

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorGuido")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notNormalized:
            "Score must be normalized before validation; call GMNNormalizer.normalize(_:) first"
        }
    }
}

// MARK: - Equatable

extension GMNValidator.Error: Equatable {
}

// MARK: - Sendable

extension GMNValidator.Error: Sendable {
}
