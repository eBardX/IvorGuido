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
        self.variables = variables
        self.voices = voices
    }

    // MARK: Public Instance Properties

    /// The score-level variable definitions.
    public let variables: [GMNVariable]

    /// The voices that make up the score.
    public let voices: [GMNVoice]
}

// MARK: - Equatable

extension GMNScore: Equatable {
}

// MARK: - Sendable

extension GMNScore: Sendable {
}
