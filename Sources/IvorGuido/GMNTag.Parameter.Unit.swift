// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNTag.Parameter {

    // MARK: Public Nested Types

    /// A unit of measurement for a Guido Music Notation tag parameter.
    public enum Unit: String {
        /// Centimeters.
        case cm = "cm"

        /// Half-spaces (Guido-specific relative unit).
        case hs = "hs"

        /// Inches.
        case `in` = "in"

        /// Meters.
        case m = "m"

        /// Millimeters.
        case mm = "mm"

        /// Picas.
        case pc = "pc"

        /// Points.
        case pt = "pt"

        /// Relative units.
        case rl = "rl"
    }
}

// MARK: - Equatable

extension GMNTag.Parameter.Unit: Equatable {
}

// MARK: - Sendable

extension GMNTag.Parameter.Unit: Sendable {
}
