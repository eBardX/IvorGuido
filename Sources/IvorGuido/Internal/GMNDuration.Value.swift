// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNDuration {

    // MARK: Internal Nested Types

    internal enum Value {
        case fraction(UInt, UInt)           // numerator: >0, denominator: >0
        case fractionDots(UInt, UInt, UInt) // numerator: >0, denominator: >0, dots: 1...3
        case milliseconds(UInt)             // milliseconds: >0
    }
}

// MARK: - Equatable

extension GMNDuration.Value: Equatable {
}

// MARK: - Sendable

extension GMNDuration.Value: Sendable {
}
