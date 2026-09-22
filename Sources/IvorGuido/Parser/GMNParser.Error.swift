// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension GMNParser {

    // MARK: Public Nested Types

    /// An error that can occur while parsing Guido Music Notation.
    public enum Error {
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

        /// A `$variable` used in symbol position cannot supply symbols.
        ///
        /// Its value is a number, or a string whose body does not lex as
        /// Guido Music Notation — a bare `42` is not a symbol. The associated
        /// value is the referenced variable’s name.
        ///
        /// A reference to an *undeclared* variable is not this error — see
        /// ``unresolvableVariableReference(_:)``.
        case nonSymbolVariableReference(GMNVariable.Name)

        /// The underlying tokenizer or token matcher failed. The associated
        /// value is that foreign error’s own description.
        case tokenizationFailed(String)

        /// The input contains unexpected content after a valid score.
        case trailingGarbage

        // guidolib treats this as a hard parse failure at the reference point
        // (`GuidoParser.cpp` `variableSymbols`/`varParam`, both `YYABORT` on
        // lookup failure), and so does this parser.

        /// A `$variable` reference names no declared variable.
        ///
        /// Either position counts — symbol position
        /// (``GMNSymbol/variable(_:)``) or tag-parameter position
        /// (``GMNTag/Parameter/Value/variable(_:)``), including a reference
        /// inside another variable’s own body. The associated value is the
        /// referenced name.
        ///
        /// This is a hard parse failure. Nothing downstream could answer it
        /// either: the declaration prologue is complete before any reference,
        /// so a name unanswered at the parser is unanswered for good.
        case unresolvableVariableReference(GMNVariable.Name)
    }
}

// MARK: - EnhancedError

extension GMNParser.Error: EnhancedError {

    // MARK: Public Instance Properties

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorGuido")
    }

    /// A human-readable description of this error.
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

        case let .nonSymbolVariableReference(name):
            "Variable ‘$\(name.stringValue)’ holds no symbols and cannot be used in symbol position"

        case let .tokenizationFailed(description):
            "Tokenization failed: \(description)"

        case .trailingGarbage:
            "Input contains trailing garbage"

        case let .unresolvableVariableReference(name):
            "Unresolvable variable reference: ‘$\(name.stringValue)’"
        }
    }
}

// MARK: - Equatable

extension GMNParser.Error: Equatable {
}

// MARK: - Sendable

extension GMNParser.Error: Sendable {
}
