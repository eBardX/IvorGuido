// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido

// Tuple equality for the `parse…` results, which are tuple typealiases
// and so have no `Equatable` conformance of their own to test against.

// swiftlint:disable:next static_operator
internal func == (lhs: (String, UInt?),
                  rhs: (String, UInt?)) -> Bool {
    lhs.0 == rhs.0
    && lhs.1 == rhs.1
}

// swiftlint:disable:next static_operator
internal func == (lhs: ParseDurationResult?,
                  rhs: ParseDurationResult?) -> Bool {
    lhs?.denominator == rhs?.denominator
    && lhs?.dots == rhs?.dots
    && lhs?.numerator == rhs?.numerator
}

// swiftlint:disable:next static_operator
internal func == (lhs: ParseNoteResult?,
                  rhs: ParseNoteResult?) -> Bool {
    lhs?.duration == rhs?.duration
    && lhs?.pitch == rhs?.pitch
}

// swiftlint:disable:next static_operator
internal func == (lhs: ParsePitchResult?,
                  rhs: ParsePitchResult?) -> Bool {
    lhs?.accidental == rhs?.accidental
    && lhs?.name == rhs?.name
    && lhs?.octave == rhs?.octave
}

// swiftlint:disable:next static_operator
internal func == (lhs: ParseRestResult?,
                  rhs: ParseRestResult?) -> Bool {
    lhs?.0 == rhs?.0
    && lhs?.duration == rhs?.duration
}

// swiftlint:disable:next static_operator
internal func == (lhs: ParseTablatureResult?,
                  rhs: ParseTablatureResult?) -> Bool {
    lhs?.duration == rhs?.duration
    && lhs?.fret.unrecognizedEscape == rhs?.fret.unrecognizedEscape
    && lhs?.fret.value == rhs?.fret.value
    && lhs?.tabString == rhs?.tabString
}
