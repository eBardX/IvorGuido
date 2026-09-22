// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNDuration {

    // MARK: Public Nested Types

    // guidolib's grammar (`guido.y` `dots`) recognizes exactly one, two, or
    // three dots (`DOT`, `DDOT`, `TDOT`).

    /// The number of augmentation dots written on a duration.
    ///
    /// Guido Music Notation recognizes exactly one, two, or three dots — zero
    /// dots isn’t a `DotCount` value at all; it’s the absence of a
    /// ``GMNDuration/dots``.
    public struct DotCount: UIntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the provided value is
        /// a valid dot count.
        ///
        /// - Parameter uintValue:   The value to validate.
        ///
        /// - Returns:  `true` if the value is in the range 1...3; otherwise,
        ///             `false`.
        public static func isValid(_ uintValue: UInt) -> Bool {
            (1...3).contains(uintValue)
        }

        // MARK: Public Initializers

        /// Creates a new dot count with the provided value, or `nil` if the
        /// value is not valid.
        ///
        /// - Parameter uintValue:   The number of dots. Must be in the range
        ///                          1...3.
        public init?(uintValue: UInt) {
            guard Self.isValid(uintValue)
            else { return nil }

            self.uintValue = uintValue
        }

        // MARK: Public Instance Properties

        /// The unsigned integer value of this dot count.
        public let uintValue: UInt
    }
}
