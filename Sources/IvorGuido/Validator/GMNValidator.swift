// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that validates a Guido Music Notation score.
public struct GMNValidator {

    // MARK: Public Initializers

    /// Creates a new Guido Music Notation validator.
    public init() {
    }
}

// MARK: -

extension GMNValidator {

    // MARK: Public Instance Methods

    /// Validates the provided score and returns any issues found.
    ///
    /// - Parameter score:  The score to validate.
    ///
    /// - Returns:  A tuple of the validated score and an array of ``Issue``
    ///             values. An empty issues array means the score is fully
    ///             conformant.
    ///
    ///             The score in the tuple is a copy of `score` with
    ///             ``GMNScore/isValidated`` set to `true` **only if no issue
    ///             was found**; otherwise `score` is returned unchanged, and
    ///             re-validating after fixing the issues is required. Every
    ///             issue is fatal — there is no grading, and no issue is
    ///             advisory. See ``Issue``.
    ///
    /// - Throws:   ``Error/notNormalized`` if ``GMNScore/isNormalized`` is
    ///             `false`. Call ``GMNNormalizer/normalize(_:)`` before
    ///             calling this method.
    public func validate(_ score: GMNScore) throws(Error) -> (GMNScore, [Issue]) {
        guard !score.isValidated
        else { return (score, []) }

        guard score.isNormalized
        else { throw Error.notNormalized }

        var checker = Checker(score: score)

        let issues = checker.checkScore()

        guard issues.isEmpty
        else { return (score, issues) }

        return (GMNScore(variables: score.variables,
                         voices: score.voices,
                         isNormalized: score.isNormalized,
                         isValidated: true), issues)
    }
}

// MARK: - Sendable

extension GMNValidator: Sendable {
}
