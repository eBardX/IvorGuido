// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNParser {

    // MARK: Public Nested Types

    /// A diagnostic message produced by ``GMNParser`` for a form that Guido
    /// silently accepts rather than rejects. Unlike ``Error``, encountering a
    /// diagnostic never aborts parsing.
    public enum Diagnostic {
        /// A `\`-escape sequence in a string or fret was not one of the six
        /// Guido Music Notation recognizes (`\'`, `\"`, `\\`, `\n`, `\;`,
        /// `\ `); the backslash and the following character were passed
        /// through verbatim. The associated value is the two-character escape
        /// sequence that was passed through.
        case unrecognizedEscape(String)

        /// A vestigial `<n>` count suffix was accepted and discarded on a
        /// note or rest token — dead grammar, which nothing reads. The
        /// associated value is the raw token text that carried the suffix.
        case vestigialCount(String)
    }
}

// MARK: -

extension GMNParser.Diagnostic {

    // MARK: Public Instance Properties

    /// A human-readable description of this diagnostic.
    public var message: String {
        switch self {
        case let .unrecognizedEscape(value):
            "Unrecognized escape ‘\(value)’ was passed through verbatim"

        case let .vestigialCount(value):
            "Vestigial count suffix was accepted and discarded: ‘\(value)’"
        }
    }
}

// MARK: - Equatable

extension GMNParser.Diagnostic: Equatable {
}

// MARK: - Sendable

extension GMNParser.Diagnostic: Sendable {
}
