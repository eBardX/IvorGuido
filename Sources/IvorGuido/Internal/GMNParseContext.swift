// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal struct GMNParseContext {

    // MARK: Internal Initializers

    internal init() {
        self.lastDuration = Self.defaultDuration
        self.lastOctave = Self.defaultOctave
    }

    // MARK: Internal Instance Properties

    internal var lastDuration: GMNDuration
    internal var lastOctave: GMNPitch.Octave
}

// MARK: -

extension GMNParseContext {

    // MARK: Private Type Properties

    private static let defaultDuration = GMNDuration(numerator: 1,
                                                     denominator: 4)!  // swiftlint:disable:this force_unwrapping
    private static let defaultOctave   = GMNPitch.Octave(4)              // standard octave equivalent of Guido octave 1
}

// MARK: - Sendable

extension GMNParseContext: Sendable {
}
