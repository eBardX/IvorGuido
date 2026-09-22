// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    /// A parameter passed to a Guido Music Notation tag.
    public struct Parameter {

        // MARK: Public Initializers

        /// Creates a new tag parameter with the provided name and value.
        ///
        /// - Parameter name:   The optional name of this parameter. Defaults
        ///                     to `nil`.
        /// - Parameter value:  The value of this parameter.
        public init(name: Name? = nil,
                    value: Value) {
            self.name = name
            self.value = value
        }

        // MARK: Public Instance Properties

        /// The optional name of this parameter.
        public let name: Name?

        /// The value of this parameter.
        public let value: Value
    }
}

// MARK: -

extension GMNTag.Parameter {

    // MARK: Public Instance Properties

    /// The floating-point value of this parameter, or `nil` if this parameter
    /// is not a floating-point parameter.
    public var floatingValue: Double? {
        switch value {
        case let .floating(value, _):
            value

        default:
            nil
        }
    }

    /// The integer value of this parameter, or `nil` if this parameter is not
    /// an integer parameter.
    public var integerValue: Int? {
        switch value {
        case let .integer(value, _):
            value

        default:
            nil
        }
    }

    /// The quoted string value of this parameter, or `nil` if this parameter is
    /// not a quoted string parameter.
    public var stringValue: String? {
        switch value {
        case let .string(value):
            value

        default:
            nil
        }
    }

    /// The unit of this parameter, or `nil` if this parameter has no unit or is
    /// not a numeric parameter.
    public var unit: Unit? {
        switch value {
        case let .floating(_, unit),
             let .integer(_, unit):
            unit

        default:
            nil
        }
    }
}

// MARK: - Equatable

extension GMNTag.Parameter: Equatable {
}

// MARK: - Sendable

extension GMNTag.Parameter: Sendable {
}
