// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A note in a Guido Music Notation voice, consisting of a pitch and a
/// duration.
public struct GMNNote {

    // MARK: Public Initializers

    /// Creates a new note with the provided pitch and duration.
    ///
    /// - Parameter pitch:      The pitch of this note.
    /// - Parameter duration:   The duration of this note.
    public init(pitch: GMNPitch,
                duration: GMNDuration) {
        self.duration = duration
        self.pitch = pitch
    }

    // MARK: Public Instance Properties

    /// The duration of this note.
    public let duration: GMNDuration

    /// The pitch of this note.
    public let pitch: GMNPitch
}

// MARK: - Equatable

extension GMNNote: Equatable {
}

// MARK: - Sendable

extension GMNNote: Sendable {
}
