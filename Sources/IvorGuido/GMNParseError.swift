// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that can occur while parsing Guido Music Notation.
public enum GMNParseError {
    /// The UTF-8 data could not be converted to a string.
    case dataConversionFailed

    /// The end of input was reached prematurely.
    case endOfInput

    /// A chord segment contains invalid symbols.
    case invalidChordSegment([GMNSymbol])

    /// The note token is malformed.
    case invalidNote(Substring)

    /// The number token is malformed.
    case invalidNumber(Substring)

    /// The parameter unit token is unrecognized.
    case invalidParameterUnit(Substring)

    /// The rest token is malformed.
    case invalidRest(Substring)

    /// The string token is malformed.
    case invalidString(Substring)

    /// The tablature token is malformed.
    case invalidTablature(Substring)

    /// A tag name is missing.
    case missingTagName

    /// A variable value is missing.
    case missingVariableValue

    /// A chord was nested inside another chord.
    case nestedChord

    /// The input contains unexpected content after a valid score.
    case trailingGarbage
}

// MARK: - EnhancedError

extension GMNParseError: EnhancedError {
    public var category: Category? {
        Category("IvorGuido")
    }

    public var message: String {
        switch self {
        case .dataConversionFailed:
            "Failed to convert UTF-8 data to string"

        case .endOfInput:
            "End of input reached prematurely"

        case let .invalidChordSegment(symbols):
            "Invalid chord segment: \(symbols)"

        case let .invalidNote(value):
            "Invalid note: ‘\(value)’"

        case let .invalidNumber(value):
            "Invalid number: ‘\(value)’"

        case let .invalidParameterUnit(value):
            "Invalid parameter unit: ‘\(value)’"

        case let .invalidRest(value):
            "Invalid rest: ‘\(value)’"

        case let .invalidString(value):
            "Invalid string: ‘\(value)’"

        case let .invalidTablature(value):
            "Invalid tablature: ‘\(value)’"

        case .missingTagName:
            "Missing tag name"

        case .missingVariableValue:
            "Missing variable value"

        case .nestedChord:
            "Nested chords are disallowed"

        case .trailingGarbage:
            "Input contains trailing garbage"
        }
    }
}

// MARK: - Equatable

extension GMNParseError: Equatable {
}

// MARK: - Sendable

extension GMNParseError: Sendable {
}
