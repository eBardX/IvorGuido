// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNPitch {

    // MARK: Public Nested Types

    /// The accidental applied to a pitch.
    public enum Accidental {
        /// A double flat (𝄫), lowering the pitch by two semitones.
        case doubleFlat

        /// A flat (♭), lowering the pitch by one semitone.
        case flat

        /// A natural (♮), canceling any previous accidental.
        case natural

        /// A sharp (♯), raising the pitch by one semitone.
        case sharp

        /// A sharp (♯) implied by the pitch name (viz. “cis”, “dis”, “fis”,
        /// “gis”, or “ais”).
        case impliedSharp

        /// A double sharp (𝄪), raising the pitch by two semitones.
        case doubleSharp
    }
}

// MARK: - Equatable

extension GMNPitch.Accidental: Equatable {
}

// MARK: - Sendable

extension GMNPitch.Accidental: Sendable {
}
