// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNNoteHeads {

    // MARK: Public Nested Types

    // guidolib: `ARTHead::HEADSTATE` — a genuine C++ enumeration
    // (`ARTHead.h:76`), which is what licenses a closed Swift enum here. Its sixth state, `NOTSET`, is absent deliberately: no name
    // is dispatched for it, and it is what `getEndTag()` builds to restore the
    // state a range form saved (`ARTHead.h:88`).

    /// Where a ``GMNNoteHeads`` puts the notehead.
    public enum Kind {
        /// The notehead is centered on the stem (`\headsCenter`).
        case center

        /// The notehead is forced to the left of the stem (`\headsLeft`).
        case left

        /// A previous notehead setting is canceled (`\headsNormal`).
        case normal

        /// The notehead moves to the opposite side of its normal position
        /// (`\headsReverse`).
        case reverse

        /// The notehead is forced to the right of the stem (`\headsRight`).
        case right
    }
}

// MARK: -

extension GMNNoteHeads.Kind {

    // MARK: Internal Type Methods

    // The placement the given tag name selects, or `nil` if it names no
    // notehead setting.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "headsCenter":
            .center

        case "headsLeft":
            .left

        case "headsNormal":
            .normal

        case "headsReverse":
            .reverse

        case "headsRight":
            .right

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this placement — the spelling
    // `ARTHead::getGMNName` builds (`ARTHead.cpp:39–56`).
    internal var tagName: String {
        switch self {
        case .center:
            "headsCenter"

        case .left:
            "headsLeft"

        case .normal:
            "headsNormal"

        case .reverse:
            "headsReverse"

        case .right:
            "headsRight"
        }
    }
}

// MARK: - Equatable

extension GMNNoteHeads.Kind: Equatable {
}

// MARK: - Sendable

extension GMNNoteHeads.Kind: Sendable {
}
