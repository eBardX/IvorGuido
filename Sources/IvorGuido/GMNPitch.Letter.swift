// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNPitch {
    /// The letter name of a pitch.
    public enum Letter {
        /// The pitch letter A.
        case a

        /// The pitch letter B.
        case b

        /// The pitch letter C.
        case c

        /// The pitch letter D.
        case d

        /// The pitch letter E.
        case e

        /// The pitch letter F.
        case f

        /// The pitch letter G.
        case g

        /// An empty pitch (no letter name).
        case empty
    }
}

// MARK: - Equatable

extension GMNPitch.Letter: Equatable {
}

// MARK: - Sendable

extension GMNPitch.Letter: Sendable {
}
