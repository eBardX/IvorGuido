// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A pitch in a Guido Music Notation note, consisting of a name, an
/// accidental, and an octave.
public struct GMNPitch {

    // MARK: Public Initializers

    /// Creates a new pitch with the provided name, accidental, and octave.
    ///
    /// - Parameter name:       The name of this pitch.
    /// - Parameter accidental: The accidental of the pitch. Use `.omitted`
    ///                         when no accidental was written in the source.
    /// - Parameter octave:     The octave number of this pitch, or `nil` when
    ///                         no octave was written in the source — Guido
    ///                         Music Notation then inherits the previous
    ///                         pitch’s octave.
    public init(name: Name,
                accidental: Accidental,
                octave: Octave?) {
        self.accidental = accidental
        self.name = name
        self.octave = octave
    }

    // MARK: Public Instance Properties

    /// The accidental of this pitch. `.omitted` means no accidental was
    /// written in the source.
    public let accidental: Accidental

    /// The name of this pitch.
    public let name: Name

    /// The octave number of this pitch, or `nil` if no octave was written in
    /// the source (inherits the previous pitch’s octave).
    public let octave: Octave?
}

// MARK: - Equatable

extension GMNPitch: Equatable {
}

// MARK: - Sendable

extension GMNPitch: Sendable {
}
