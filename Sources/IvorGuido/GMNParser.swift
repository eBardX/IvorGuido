// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for Guido Music Notation.
public struct GMNParser {

    // MARK: Public Initializers

    /// Creates a new Guido Music Notation parser.
    public init() {
        self.tokenizer = GMNTokenizer(tracing: .silent)
    }

    // MARK: Internal Instance Properties

    private let tokenizer: GMNTokenizer
}

// MARK: -

extension GMNParser {

    // MARK: Public Instance Methods

    /// Parses UTF-8 encoded Guido Music Notation data and returns the
    /// resulting score.
    ///
    /// - Parameter data:   The UTF-8 encoded GMN data to parse.
    /// - Returns:          The parsed score.
    ///
    /// - Throws:           A ``GMNParseError`` if parsing fails.
    public func parse(_ data: Data) throws -> GMNScore {
         guard let input = String(data: data,
                                  encoding: .utf8)
         else { throw GMNParseError.dataConversionFailed }

        var matcher = try Matcher(tokens: tokenizer.tokenize(input))

        return try matcher.matchScore()
    }
}
