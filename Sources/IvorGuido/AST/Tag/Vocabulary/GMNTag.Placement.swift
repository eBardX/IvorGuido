// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: the `S,position` parameter, read against `kAboveStr` and
    // `kBelowStr` (`TagParameterStrings.cpp:91,104`) and stored as
    // `ARArticulation`’s `enum { kDefaultPosition, kAbove, kBelow }`
    // (`ARArticulation.h:28`).
    //
    // A `nil` placement is guidolib's `kDefaultPosition`. `\symbol` also
    // declares `S,position` (`kARSymbolParams`) but over a different closed
    // vocabulary (`GRSymbol.cpp:185–190`). The per-tag reads are
    // `ARArticulation.cpp:33–39`, `ARFingering.cpp:48–53`,
    // `ARHarmony.cpp:36–40`, `ARTrill.cpp:169–174`, `ARFermata.cpp:57–58`, and
    // `ARTuplet.cpp:146–152`.

    /// Which side of the staff a Guido Music Notation tag is placed on.
    ///
    /// Modeled as an optional throughout: a `nil` placement means the author
    /// wrote nothing and the renderer chooses. It is not the same as an
    /// explicit `above`, even where `above` is the default.
    ///
    /// ## Not every `position` parameter is a placement
    ///
    /// `\symbol` also takes a `position`, but over a different vocabulary —
    /// `top`, `bottom`, `bot`, `over` — so it does *not* use this type.
    ///
    /// ## The parse is not uniform
    ///
    /// The tags that do share this vocabulary still disagree about what to do
    /// with a value outside it, which is a per-tag matter rather than a
    /// property of this type:
    ///
    /// - `\accent` and friends warn and fall back to the default, as do
    ///   `\fingering`, `\harmony`, and `\trill` and friends.
    /// - `\fermata` tests only for `below`.
    /// - `\tuplet` is fully open: `below` means below, and **anything else at
    ///   all** means above.
    public enum Placement {
        /// Above the staff (`position="above"`).
        case above

        /// Below the staff (`position="below"`).
        case below

        // MARK: Internal Initializers

        // Reads a written `position` value, or `nil` if it is outside the closed
        // vocabulary.
        //
        // The payloads whose classes parse `position` against `kAboveStr` and
        // `kBelowStr` and fall back to `kDefaultPosition` on anything else —
        // `ARArticulation`, `ARFingering`, `ARTrill` — decline to promote on a
        // `nil` here rather than reading it as absent. Both readings are
        // semantically faithful, since guidolib cannot tell an unrecognized value
        // from an absent one, but promoting would silently discard what was
        // written and the parser never discards. The tag stays reserved, the
        // value round-trips as written, and the validator reports it.
        //
        // `\tuplet` deliberately does not use this: its parse really is open —
        // `below` means below and anything else at all means above
        // (`ARTuplet.cpp:146–152`) — so there is no third state to preserve.
        internal init?(guidoValue: String) {
            switch guidoValue {
            case "above":
                self = .above

            case "below":
                self = .below

            default:
                return nil
            }
        }
    }
}

// MARK: -

extension GMNTag.Placement {

    // MARK: Internal Instance Properties

    // This placement as guidolib spells it.
    internal var guidoValue: String {
        switch self {
        case .above:
            "above"

        case .below:
            "below"
        }
    }
}

// MARK: - Equatable

extension GMNTag.Placement: Equatable {
}

// MARK: - Sendable

extension GMNTag.Placement: Sendable {
}
