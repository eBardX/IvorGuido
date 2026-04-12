// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNChord {

    // MARK: Public Nested Types

    /// A single segment within a chord.
    public struct Segment {

        // MARK: Public Initializers

        /// Creates a new chord segment with the provided symbols.
        ///
        /// If `symbols` contains a nested chord, this initializer returns
        /// `nil`.
        ///
        /// - Parameter symbols:    The symbols that make up this segment.
        public init?(symbols: [GMNSymbol]) {
            guard !Self._containsNestedChord(symbols)
            else { return nil }

            self.symbols = symbols
        }

        // MARK: Public Instance Properties

        /// The symbols that make up this segment.
        public let symbols: [GMNSymbol]
    }
}

// MARK: -

extension GMNChord.Segment {

    // MARK: Private Type Methods

    private static func _containsNestedChord(_ symbols: [GMNSymbol]) -> Bool {
        for symbol in symbols {
            switch symbol {
            case .chord:
                return true

            case let .tag(tag):
                if _containsNestedChord(tag.symbols) {
                    return true
                }

            default:
                break
            }
        }

        return false
    }
}

// MARK: - Equatable

extension GMNChord.Segment: Equatable {
}

// MARK: - Sendable

extension GMNChord.Segment: Sendable {
}
