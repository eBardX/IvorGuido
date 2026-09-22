// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNValidator {

    // MARK: Internal Nested Types

    internal struct Checker {

        // MARK: Internal Initializers

        internal init(score: GMNScore) {
            self.issues = []
            self.score = score
        }

        // MARK: Private Instance Properties

        private let score: GMNScore

        private var issues: [Issue]
    }
}

// MARK: -

extension GMNValidator.Checker {

    // MARK: Internal Instance Methods

    internal mutating func checkScore() -> [GMNValidator.Issue] {
        for variable in score.variables {
            if let symbols = variable.symbols {
                _checkSymbols(symbols)
            }
        }

        for voice in score.voices {
            _checkSymbols(voice.symbols)
        }

        return issues
    }

    // MARK: Private Instance Methods

    private mutating func _checkSymbol(_ symbol: GMNSymbol) {
        switch symbol {
        case let .chord(chord):
            for segment in chord.segments {
                _checkSymbols(segment.symbols)
            }

        case let .tag(tag):
            _checkTag(tag)

        // A `$variable` reference is settled at the parser, which rejects one
        // no declaration answers (`GMNParser.Error`), and splicing it in is
        // not implemented anywhere in IvorGuido. Neither is anything this can
        // add to.
        case .note,
             .rest,
             .tablature,
             .variable:
            break
        }
    }

    private mutating func _checkSymbols(_ symbols: [GMNSymbol]) {
        for symbol in symbols {
            _checkSymbol(symbol)
        }
    }

    private mutating func _checkTag(_ tag: GMNTag) {
        issues += GMNValidator.SchemaChecker.check(tag)

        _checkSymbols(tag.body)
    }
}
