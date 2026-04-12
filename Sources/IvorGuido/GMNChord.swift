// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A chord in a Guido Music Notation voice, consisting of one or more
/// segments.
public struct GMNChord {

    // MARK: Public Initializers

    /// Creates a new chord with the provided segments.
    ///
    /// - Parameter segments:   The segments that make up this chord.
    public init(segments: [Segment]) {
        self.segments = segments
    }

    // MARK: Public Instance Properties

    /// The segments that make up this chord.
    public let segments: [Segment]
}

// MARK: - Equatable

extension GMNChord: Equatable {
}

// MARK: - Sendable

extension GMNChord: Sendable {
}
