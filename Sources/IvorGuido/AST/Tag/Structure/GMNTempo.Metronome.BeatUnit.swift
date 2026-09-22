// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTempo.Metronome {

    // MARK: Public Nested Types

    // guidolib reads both sides with `%d/%d` into a `TYPE_DURATION` and then
    // normalizes (`ARTempo.cpp:96–107`). This type deliberately does **not**
    // normalize, which keeps the round-trip exact.

    /// The note that gets the beat, written as a fraction of a whole note, as
    /// it appears on either side of a `bpm` specification.
    ///
    /// The fraction is kept exactly as written and is never reduced: `2/8`
    /// and `1/4` mean the same thing, but only one of them was written.
    public struct BeatUnit {

        // MARK: Public Initializers

        // `ARTempo::ParseBpm` hands both sides straight to `Fraction::set`,
        // which asserts `denom != 0` (`Fraction.cpp:88`). That assertion is
        // guidolib naming the domain; a release build of it computes `n / 0`
        // instead, which is behaviour rather than meaning and is not what this
        // package transcribes.

        /// Creates a new beat unit with the provided numerator and
        /// denominator, or `nil` if the denominator is zero.
        ///
        /// - Parameter numerator:   The fraction’s numerator.
        /// - Parameter denominator: The fraction’s denominator.
        public init?(_ numerator: Int,
                     _ denominator: Int) {
            guard denominator != 0
            else { return nil }

            self.denominator = denominator
            self.numerator = numerator
        }

        // MARK: Public Instance Properties

        /// The fraction’s denominator, as written.
        public let denominator: Int

        /// The fraction’s numerator, as written.
        public let numerator: Int

        // MARK: Internal Initializers

        // Reads `a/b`, or `nil` if the text is not exactly that.
        internal init?(specification: Substring) {
            let parts = specification.split(separator: "/",
                                            omittingEmptySubsequences: false)

            guard parts.count == 2,
                  let numerator = Int(parts[0]),
                  let denominator = Int(parts[1]),
                  let value = Self(numerator,
                                   denominator)
            else { return nil }

            self = value
        }
    }
}

// MARK: -

extension GMNTempo.Metronome.BeatUnit {

    // MARK: Public Instance Properties

    /// The beat unit as it appears in a `bpm` specification.
    public var stringValue: String {
        "\(numerator)/\(denominator)"
    }
}

// MARK: - Equatable

extension GMNTempo.Metronome.BeatUnit: Equatable {
}

// MARK: - Sendable

extension GMNTempo.Metronome.BeatUnit: Sendable {
}
