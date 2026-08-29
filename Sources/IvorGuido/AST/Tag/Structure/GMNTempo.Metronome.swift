// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTempo {

    // MARK: Public Nested Types

    // guidolib: `ARTempo::ParseBpm` (`ARTempo.cpp:91–111`), which tries
    // exactly two `sscanf` patterns and **silently ignores** anything matching
    // neither. Those two patterns are the two cases here.
    //
    // `bpm` is declared `S`, so an unparseable spelling is a perfectly
    // well-typed string as far as the template is concerned — it is not a
    // value guidolib's own `dynamic_cast` would discard, and the
    // normalizer's repair step neither can nor should drop it.
    //
    // The parse here is stricter than `sscanf` in one respect: `sscanf` stops
    // at the first character it cannot use and reports success on what it had,
    // so guidolib accepts `1/4=120 or so`. Reading that as `1/4=120` would
    // silently discard the rest of the string, so it is refused instead.

    /// A tempo’s metronome specification — the `bpm` parameter of a
    /// ``GMNTempo``.
    ///
    /// ## Anything else keeps the tag reserved
    ///
    /// ``GMNTempo`` declines to promote a tag whose `bpm` this type cannot
    /// read, leaving it reserved, where the string round-trips exactly as
    /// written. Trailing text that is not part of the specification is
    /// refused rather than quietly discarded, so `\tempo<"A","1/4=120 or
    /// so">` keeps its text intact.
    public enum Metronome {

        /// A note equivalence, `a/b=x/y` — one `unit` note lasts as long as
        /// one `equivalent` note.
        case equivalence(unit: BeatUnit,
                         equivalent: BeatUnit)

        /// A metronome rate, `a/b=x` — `beats` `unit` notes per minute.
        case rate(unit: BeatUnit,
                  beats: Int)

        // MARK: Public Initializers

        /// Creates a metronome specification by reading the given text, or
        /// returns `nil` if it matches neither pattern.
        ///
        /// - Parameter specification: The text of a `bpm` parameter.
        public init?(_ specification: String) {
            let sides = specification.split(separator: "=",
                                            omittingEmptySubsequences: false)

            guard sides.count == 2,
                  let unit = BeatUnit(specification: sides[0])
            else { return nil }

            if let equivalent = BeatUnit(specification: sides[1]) {
                self = .equivalence(unit: unit,
                                    equivalent: equivalent)
            } else if let beats = Int(sides[1]) {
                self = .rate(unit: unit,
                             beats: beats)
            } else {
                return nil
            }
        }
    }
}

// MARK: -

extension GMNTempo.Metronome {

    // MARK: Public Instance Properties

    /// The specification as it appears in a `bpm` parameter.
    public var stringValue: String {
        switch self {
        case let .equivalence(unit, equivalent):
            "\(unit.stringValue)=\(equivalent.stringValue)"

        case let .rate(unit, beats):
            "\(unit.stringValue)=\(beats)"
        }
    }
}

// MARK: - Equatable

extension GMNTempo.Metronome: Equatable {
}

// MARK: - Sendable

extension GMNTempo.Metronome: Sendable {
}
