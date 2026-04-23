// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    /// A parameter passed to a Guido Music Notation tag.
    public enum Parameter {
        /// A floating-point parameter, with an optional name and optional
        /// unit.
        case floating(String?, Double, Unit?)

        /// An integer parameter, with an optional name and optional unit.
        case integer(String?, Int, Unit?)

        /// A raw (unquoted) string parameter, with an optional name.
        case parameter(String?, String)

        /// A quoted string parameter, with an optional name.
        case string(String?, String)

        /// A variable-reference parameter, with an optional name.
        case variable(String?, String)
    }
}

// MARK: -

extension GMNTag.Parameter {

    // MARK: Public Instance Properties

    /// The floating-point value of this parameter, or `nil` if this parameter
    /// is not a floating-point parameter.
    public var floatingValue: Double? {
        switch self {
        case let .floating(_, value, _):
            value

        default:
            nil
        }
    }

    /// The integer value of this parameter, or `nil` if this parameter is not
    /// an integer parameter.
    public var integerValue: Int? {
        switch self {
        case let .integer(_, value, _):
            value

        default:
            nil
        }
    }

    /// The name of this parameter, or `nil` if this parameter is unnamed.
    public var name: String? {
        switch self {
        case let .floating(name, _, _),
            let .integer(name, _, _),
            let .parameter(name, _),
            let .string(name, _),
            let .variable(name, _):
            name
        }
    }

    /// The quoted string value of this parameter, or `nil` if this parameter
    /// is not a quoted string parameter.
    public var stringValue: String? {
        switch self {
        case let .string(_, value):
            value

        default:
            nil
        }
    }

    /// The unit of this parameter, or `nil` if this parameter has no unit or
    /// is not a numeric parameter.
    public var unit: Unit? {
        switch self {
        case let .floating(_, _, unit),
            let .integer(_, _, unit):
            unit

        default:
            nil
        }
    }

    // MARK: Public Instance Method

    /// Returns `true` if this parameter is unnamed or its name equals
    /// `pname`.
    ///
    /// - Parameter pname:  The name to compare against.
    /// - Returns:          `true` if this parameter has no name or if its
    ///                     name equals `pname`; otherwise, `false`.
    public func hasNameOrNil(_ pname: String) -> Bool {
        guard let name
        else { return true }

        return name == pname
    }
}

// MARK: - Equatable

extension GMNTag.Parameter: Equatable {
}

// MARK: - Sendable

extension GMNTag.Parameter: Sendable {
}
