// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNTag.Parameter {

    // MARK: Public Nested Types

    /// The name of a Guido Music Notation tag parameter.
    ///
    /// A valid name is an identifier: non-empty, starting with an ASCII
    /// letter or underscore, and containing only ASCII letters, digits, or
    /// underscores thereafter.
    public struct Name: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid tag parameter name.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns:  `true` if `stringValue` is non-empty, starts with an
        ///             ASCII letter or underscore, and contains only ASCII
        ///             letters, digits, or underscores thereafter.
        public static func isValid(_ stringValue: String) -> Bool {
            guard let first = stringValue.first,
                  first.isASCII,
                  first.isLetter || first == "_"
            else { return false }

            return stringValue.dropFirst().allSatisfy {
                $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_")
            }
        }

        // MARK: Public Initializers

        /// Creates a new tag parameter name from the provided string, or
        /// `nil` if it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be a valid
        ///                          identifier.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this tag parameter name.
        public let stringValue: String
    }
}
