// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNPitch {

    // MARK: Public Nested Types

    /// The accidental applied to a pitch.
    public enum Accidental {
        /// A double flat (𝄫), lowering the pitch by two semitones.
        case doubleFlat

        /// A double sharp (𝄪), raising the pitch by two semitones.
        case doubleSharp

        /// A flat (♭), lowering the pitch by one semitone.
        case flat

        /// A sharp (♯) implied by the pitch name (viz. “cis”, “dis”, “fis”,
        /// “gis”, or “ais”).
        case impliedSharp

        /// No accidental was written in the source. Guido Music Notation has
        /// no explicit natural sign — an omitted accidental already means
        /// the unmodified pitch, and accidentals never carry over between
        /// notes.
        case omitted

        /// A sharp (♯), raising the pitch by one semitone.
        case sharp
    }
}

// MARK: - Equatable

extension GMNPitch.Accidental: Equatable {
}

// MARK: - Sendable

extension GMNPitch.Accidental: Sendable {
}
