// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNPitch {

    // MARK: Public Nested Types

    /// The octave number of a pitch in Guido Music Notation, where `1` is
    /// the octave of the 440 Hz `a` and every octave begins at `c` (so `c1`
    /// is the `c` just below `a1`).
    ///
    /// The GMN specification (§2.1.3, “Octave”) allows any integer here, but
    /// states that “the usage of octaves beyond the range of -3..+5 is
    /// discouraged.” `Octave` enforces that recommended range as a hard
    /// requirement.
    public struct Octave: IntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the provided value is
        /// a valid octave number.
        ///
        /// - Parameter intValue:   The value to validate.
        ///
        /// - Returns:  `true` if the value is in the range -3...5; otherwise,
        ///             `false`.
        public static func isValid(_ intValue: Int) -> Bool {
            (-3...5).contains(intValue)
        }

        // MARK: Public Initializers

        /// Creates an `Octave` instance with the provided value, or `nil` if
        /// the value is not valid.
        ///
        /// - Parameter intValue:   The octave number. Must be in the range
        ///                         -3...5.
        public init?(intValue: Int) {
            guard Self.isValid(intValue)
            else { return nil }

            self.intValue = intValue
        }

        // MARK: Public Instance Properties

        /// The integer value of this octave.
        public let intValue: Int
    }
}
