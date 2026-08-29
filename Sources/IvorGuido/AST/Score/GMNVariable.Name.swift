// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNVariable {

    // MARK: Public Nested Types

    /// The name of a Guido Music Notation variable.
    ///
    /// A valid name is an identifier: non-empty, starting with an ASCII
    /// letter or underscore, and containing only ASCII letters, digits, or
    /// underscores thereafter. The leading `$` that marks a variable in Guido
    /// Music Notation source is concrete syntax, not part of the name itself
    /// — it is stripped when a `Name` is parsed and reinstated wherever GMN
    /// text is written back out.
    public struct Name: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid variable name.
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

        /// Creates a new variable name from the provided string, or `nil`
        /// if it is invalid.
        ///
        /// - Parameter stringValue: The string to store, without a leading
        ///                          `$`.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this variable name, without a leading `$`.
        public let stringValue: String
    }
}
