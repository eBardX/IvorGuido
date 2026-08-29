// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: `ARBowing::CurveDirection` (`enum { kUndefined, kUp, kDown,
    // kPUndefined=9999 }`, `ARBowing.h:26`), set from the `S,curve` parameter
    // of `kARBowingParams`.
    //
    // `ARBowing::setTagParameters` (`ARBowing.cpp:80–92`) tests only for the
    // exact string `down`, case-sensitively: absent → `kUndefined`, `"down"`
    // → `kDown`, anything else at all (including `"Down"` or `"UP"`) →
    // `kUp` (`// assume an upward curve`). This type deliberately does not
    // mirror that literally — see the discussion below.

    /// The direction a bowing curve bends (`\slur`, `\tie`).
    ///
    /// Always used as `Curve?`, where `nil` means either no `curve` was
    /// written at all (the renderer decides) or a value outside the closed
    /// `up`/`down` vocabulary was written. Both are reported the same way a
    /// closed-vocabulary `position` is — see
    /// ``GMNValidator/Issue/unreadableParameterValue(_:)`` and
    /// `GMNTagBinder.Binding.hasUnreadableCurve(named:)`.
    ///
    /// ## The parse is closed, and case-insensitive
    ///
    /// Unlike guidolib's own total parse (above), this type does not treat
    /// every unrecognized spelling as `up` — `\slur<curve="banana">` and
    /// `\slur<curve="up">` are not read as the same score, so `"banana"`
    /// stays reserved rather than silently promoting to `up`.
    ///
    /// Case is the one place this reads more leniently than guidolib's own
    /// exact-string comparison: `\slur<curve="Up">`, `\slur<curve="UP">`,
    /// and `\slur<curve="up">` are all read as `up`. Requiring guidolib's
    /// own byte-for-byte casing would make this parser stricter than the
    /// vocabulary itself — `up`/`down` are the words being spelled, not a
    /// fixed-case token — while a value outside those two words entirely is
    /// still refused exactly as before.
    public enum Curve {
        /// The curve bends downward (`curve="down"`).
        case down

        /// The curve bends upward (`curve="up"`).
        case up

        // MARK: Internal Initializers

        // Reads a written `curve` value case-insensitively against `up`/
        // `down`, or `nil` if it is outside that closed vocabulary.
        internal init?(guidoValue: String) {
            switch guidoValue.lowercased() {
            case "down":
                self = .down

            case "up":
                self = .up

            default:
                return nil
            }
        }
    }
}

// MARK: -

extension GMNTag.Curve {

    // MARK: Internal Instance Properties

    // This direction as guidolib spells it — always the canonical lowercase
    // form, regardless of how it was originally written, so a formatter
    // that reads this case never re-emits a written `"Up"` verbatim.
    internal var guidoValue: String {
        switch self {
        case .down:
            "down"

        case .up:
            "up"
        }
    }
}

// MARK: - Equatable

extension GMNTag.Curve: Equatable {
}

// MARK: - Sendable

extension GMNTag.Curve: Sendable {
}
