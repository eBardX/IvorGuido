// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNMark {

    // MARK: Public Nested Types

    // guidolib: the anonymous C++ enumeration at `ARMark.h:54`, whose eight
    // constants are keyed by the eight strings `ARMark`’s constructor
    // registers in `fEnclosureShapes` (`ARMark.cpp:31–40`) — a closed set,
    // which is what licenses a closed Swift enum here.

    /// The shape drawn around a ``GMNMark``.
    public enum Enclosure {
        /// A square bracket on each side (`"bracket"`).
        case bracket

        /// A circle (`"circle"`).
        case circle

        /// A diamond (`"diamond"`).
        case diamond

        /// No enclosure at all (`"none"`) — the declared default, written
        /// explicitly.
        case none

        /// An oval (`"oval"`).
        case oval

        /// A rectangle (`"rectangle"`).
        case rectangle

        /// A square (`"square"`).
        case square

        /// A triangle (`"triangle"`).
        case triangle

        // MARK: Internal Initializers

        // Reads one of the eight registered spellings, or `nil` for anything
        // else.
        //
        // guidolib itself is not this strict — `fEnclosureShapes[value]` on
        // an unregistered string default-constructs `0`, which is
        // `kNoEnclosure`, so an unrecognized enclosure renders as none.
        // Reading it as ``none`` here would be semantically faithful but
        // would still *discard* what was written, so `GMNMark` declines to
        // promote instead and the value survives on the `.reserved` lane.
        // This is the same choice the articulations make for an unreadable
        // `position`.
        internal init?(guidoValue: String) {
            switch guidoValue {
            case "bracket":
                self = .bracket

            case "circle":
                self = .circle

            case "diamond":
                self = .diamond

            case "none":
                self = .none

            case "oval":
                self = .oval

            case "rectangle":
                self = .rectangle

            case "square":
                self = .square

            case "triangle":
                self = .triangle

            default:
                return nil
            }
        }
    }
}

// MARK: -

extension GMNMark.Enclosure {

    // MARK: Internal Instance Properties

    // The spelling `ARMark` registers for this shape.
    internal var guidoValue: String {
        switch self {
        case .bracket:
            "bracket"

        case .circle:
            "circle"

        case .diamond:
            "diamond"

        case .none:
            "none"

        case .oval:
            "oval"

        case .rectangle:
            "rectangle"

        case .square:
            "square"

        case .triangle:
            "triangle"
        }
    }
}

// MARK: - Equatable

extension GMNMark.Enclosure: Equatable {
}

// MARK: - Sendable

extension GMNMark.Enclosure: Sendable {
}
