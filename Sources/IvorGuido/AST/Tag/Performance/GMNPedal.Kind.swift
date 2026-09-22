// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNPedal {

    // MARK: Public Nested Types

    // guidolib: `ARNotations`’ own `enum { kPedalBegin, kPedalEnd }`
    // (`ARNotations.h:52`), which `ARFactory::createTag` selects between by
    // name (`ARFactory.cpp:1200–1211`).
    //
    // Despite guidolib's spelling of the two cases, this is **not** a
    // `GMNTag.Span`: neither is an `ARDummyRangeEnd`.

    /// Which way a ``GMNPedal`` moves the pedal.
    ///
    /// This is **not** a ``GMNTag/Span``: `\pedalOn` and `\pedalOff` are two
    /// independent marks, and neither carries an identifier pairing it with
    /// the other.
    public enum Kind {
        /// The pedal is released from here on (`\pedalOff`).
        case off

        /// The pedal is depressed from here on (`\pedalOn`).
        case on
    }
}

// MARK: -

extension GMNPedal.Kind {

    // MARK: Internal Instance Properties

    // The tag name this kind is written as. Neither has an alias.
    internal var tagName: String {
        switch self {
        case .off:
            "pedalOff"

        case .on:
            "pedalOn"
        }
    }
}

// MARK: - Equatable

extension GMNPedal.Kind: Equatable {
}

// MARK: - Sendable

extension GMNPedal.Kind: Sendable {
}
