// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A chord in a Guido Music Notation voice, consisting of one or more
/// segments.
public struct GMNChord {

    // MARK: Public Initializers

    /// Creates a new chord with the provided segments, or `nil` if
    /// `segments` is empty.
    ///
    /// - Parameter segments:   The segments that make up this chord. Must
    ///                         not be empty.
    public init?(segments: [Segment]) {
        guard Self._isValid(segments)
        else { return nil }

        self.segments = segments
    }

    // MARK: Public Instance Properties

    /// The segments that make up this chord.
    public let segments: [Segment]
}

// MARK: -

extension GMNChord {

    // MARK: Private Type Methods

    private static func _isValid(_ segments: [Segment]) -> Bool {
        !segments.isEmpty
    }
}

// MARK: - Equatable

extension GMNChord: Equatable {
}

// MARK: - Sendable

extension GMNChord: Sendable {
}
