// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A rest in a Guido Music Notation voice.
public struct GMNRest {

    // MARK: Public Initializers

    /// Creates a new rest with the provided duration.
    ///
    /// - Parameter duration:   The duration of this rest.
    public init(duration: GMNDuration) {
        self.duration = duration
    }

    // MARK: Public Instance Properties

    /// The duration of this rest.
    public let duration: GMNDuration
}

// MARK: - Equatable

extension GMNRest: Equatable {
}

// MARK: - Sendable

extension GMNRest: Sendable {
}
