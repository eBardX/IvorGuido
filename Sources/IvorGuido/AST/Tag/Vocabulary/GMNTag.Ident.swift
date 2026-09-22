// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNTag {

    // MARK: Public Nested Types

    /// The numeric identifier suffix of a Guido Music Notation tag (the `n`
    /// in `\tieBegin:n`).
    ///
    /// Any unsigned integer is a valid identifier, including `0`: `\tag:0`
    /// is legal, and `0` is preserved distinctly from an absent identifier
    /// (`nil`).
    public struct Ident: UIntRepresentable {

        // MARK: Public Initializers

        /// Creates a new tag identifier with the provided value.
        ///
        /// - Parameter uintValue:  The identifier value.
        public init?(uintValue: UInt) {
            guard Self.isValid(uintValue)
            else { return nil }

            self.uintValue = uintValue
        }

        // MARK: Public Instance Properties

        /// The unsigned integer value of this tag identifier.
        public let uintValue: UInt
    }
}
