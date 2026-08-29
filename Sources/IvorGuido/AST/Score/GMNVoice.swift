// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single voice in a Guido Music Notation score.
public struct GMNVoice {

    // MARK: Public Initializers

    /// Creates a new voice with the provided symbols.
    ///
    /// - Parameter symbols:    The symbols that make up this voice.
    public init(symbols: [GMNSymbol]) {
        self.symbols = symbols
    }

    // MARK: Public Instance Properties

    /// The symbols that make up this voice.
    public let symbols: [GMNSymbol]
}

// MARK: - Equatable

extension GMNVoice: Equatable {
}

// MARK: - Sendable

extension GMNVoice: Sendable {
}
