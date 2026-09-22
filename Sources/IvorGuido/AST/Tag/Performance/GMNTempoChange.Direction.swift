// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTempoChange {

    // MARK: Public Nested Types

    // guidolib: `ARAccelerando` and `ARRitardando`, two subclasses of
    // `TempoChange` that add neither a read nor a parameter map of their own —
    // each declares an identical template under its own name and differs only
    // in which class it is (`ARAccelerando.cpp`, `ARRitardando.cpp`).

    /// Which way a ``GMNTempoChange`` changes the tempo.
    ///
    /// The direction is not a parameter — it is which tag name was written.
    /// Both directions accept exactly the same parameters.
    public enum Direction {
        /// The tempo increases (`\accelerando`, alias `\accel`).
        case accelerando

        /// The tempo decreases (`\ritardando`, alias `\rit`).
        case ritardando
    }
}

// MARK: -

extension GMNTempoChange.Direction {

    // MARK: Internal Type Methods

    // The direction the given tag name selects, or `nil` if it names no
    // tempo change.
    internal static func direction(forTagName name: String) -> Self? {
        switch name {
        case "accel",
             "accelBegin",
             "accelEnd",
             "accelerando":
            .accelerando

        case "rit",
             "ritardando",
             "ritBegin",
             "ritEnd":
            .ritardando

        default:
            nil
        }
    }

    // MARK: Internal Instance Methods

    // The canonical tag name for this direction and span.
    //
    // Both directions are asymmetric in the same way: the range form has a
    // long spelling, but guidolib dispatches only the short `\accelBegin`/
    // `\accelEnd` and `\ritBegin`/`\ritEnd` for the open halves, so those are
    // the canonical spellings there.
    internal func tagName(for span: GMNTag.Span) -> String {
        switch (self, span) {
        case (.accelerando, .begin):
            "accelBegin"

        case (.accelerando, .end):
            "accelEnd"

        case (.accelerando, .whole):
            "accelerando"

        case (.ritardando, .begin):
            "ritBegin"

        case (.ritardando, .end):
            "ritEnd"

        case (.ritardando, .whole):
            "ritardando"
        }
    }
}

// MARK: - Equatable

extension GMNTempoChange.Direction: Equatable {
}

// MARK: - Sendable

extension GMNTempoChange.Direction: Sendable {
}
