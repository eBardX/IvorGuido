// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A parsed Guido Music Notation score.
public struct GMNScore {

    // MARK: Public Initializers

    /// Creates a new score with the provided variables and voices.
    ///
    /// - Parameter variables:  The score-level variable definitions.
    /// - Parameter voices:     The voices that make up the score.
    public init(variables: [GMNVariable],
                voices: [GMNVoice]) {
        self.init(variables: variables,
                  voices: voices,
                  isNormalized: false,
                  isValidated: false)
    }

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this score has been normalized.
    ///
    /// `false` for scores produced by ``init(variables:voices:)`` until the
    /// pipeline’s normalizer stage returns a copy with this flag set to
    /// `true`.
    public let isNormalized: Bool

    /// A Boolean value indicating whether this score has been validated.
    ///
    /// `false` until the pipeline’s validator stage returns a copy with this
    /// flag set to `true`.
    public let isValidated: Bool

    /// The score-level variable definitions.
    public let variables: [GMNVariable]

    /// The voices that make up the score.
    public let voices: [GMNVoice]

    // MARK: Internal Initializers

    internal init(variables: [GMNVariable],
                  voices: [GMNVoice],
                  isNormalized: Bool,
                  isValidated: Bool) {
        self.isNormalized = isNormalized
        self.isValidated = isValidated
        self.variables = variables
        self.voices = voices
    }
}

// MARK: - Equatable

extension GMNScore: Equatable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether two scores are equal.
    ///
    /// Two scores are equal when their ``variables`` and ``voices`` match;
    /// ``isNormalized`` and ``isValidated`` are intentionally excluded
    /// because they are metadata, not content.
    ///
    /// - Parameter lhs:    The first score to compare.
    /// - Parameter rhs:    The second score to compare.
    ///
    /// - Returns:  `true` if the two scores are equal; otherwise, `false`.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.variables == rhs.variables
        && lhs.voices == rhs.voices
    }
}

// MARK: - Sendable

extension GMNScore: Sendable {
}
