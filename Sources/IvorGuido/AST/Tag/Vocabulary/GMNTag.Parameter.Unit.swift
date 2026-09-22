// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNTag.Parameter {

    // MARK: Public Nested Types

    /// A unit of measurement for a Guido Music Notation tag parameter.
    public enum Unit: String {
        /// Centimeters.
        case cm

        /// Half-spaces (Guido-specific relative unit).
        case hs

        /// Inches.
        case `in`

        /// Meters.
        case m

        /// Millimeters.
        case mm

        /// Picas.
        case pc

        /// Points.
        case pt

        /// Relative location.
        case rl
    }
}

// MARK: - Equatable

extension GMNTag.Parameter.Unit: Equatable {
}

// MARK: - Sendable

extension GMNTag.Parameter.Unit: Sendable {
}
