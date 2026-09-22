// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNDuration {

    // MARK: Internal Nested Types

    // The base note value, before augmentation dots. A `nil` base means none
    // was written in the source text at all (e.g. `c.`): the dots still
    // augment whatever base is inherited from a prior symbol.
    internal enum Base {
        case fraction(UInt, UInt) // numerator: >0, denominator: >0, already reduced
        case milliseconds(UInt)   // milliseconds: >0
    }
}

// MARK: - Equatable

extension GMNDuration.Base: Equatable {
}

// MARK: - Sendable

extension GMNDuration.Base: Sendable {
}
