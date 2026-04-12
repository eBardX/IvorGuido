// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A pitch in a Guido Music Notation note, consisting of a letter, an
/// accidental, and an octave.
public struct GMNPitch {

    // MARK: Public Nested Types

    /// A type for representing the octave number of a pitch.
    public typealias Octave = Int

    // MARK: Public Initializers

    /// Creates a new pitch with the provided letter, accidental, and octave.
    ///
    /// - Parameter letter:         The letter name of this pitch.
    /// - Parameter accidental:     The accidental applied to this pitch.
    /// - Parameter octave:         The octave number of this pitch.
    public init(letter: Letter,
                accidental: Accidental,
                octave: Octave) {
        self.accidental = accidental
        self.letter = letter
        self.octave = octave
    }

    // MARK: Public Instance Properties

    /// The accidental applied to this pitch.
    public let accidental: Accidental

    /// The letter name of this pitch.
    public let letter: Letter

    /// The octave number of this pitch.
    public let octave: Octave
}

// MARK: - Equatable

extension GMNPitch: Equatable {
}

// MARK: - Sendable

extension GMNPitch: Sendable {
}
