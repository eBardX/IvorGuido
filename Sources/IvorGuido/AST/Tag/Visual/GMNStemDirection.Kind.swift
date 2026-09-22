// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNStemDirection {

    // MARK: Public Nested Types

    // guidolib: `ARTStem::STEMSTATE` — a genuine C++ enumeration
    // (`ARTStem.h:83`), which is what licenses a closed Swift enum here. All four states are dispatched names, unlike
    // `GMNNoteHeads.Kind`’s.

    /// Which way a ``GMNStemDirection`` points the stems.
    public enum Kind {
        /// The stem direction is chosen automatically (`\stemsAuto`).
        case auto

        /// The stems point down (`\stemsDown`).
        case down

        /// No stems are drawn (`\stemsOff`).
        case off

        /// The stems point up (`\stemsUp`).
        case up
    }
}

// MARK: -

extension GMNStemDirection.Kind {

    // MARK: Internal Type Methods

    // The direction the given tag name selects, or `nil` if it names no stem
    // setting.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "stemsAuto":
            .auto

        case "stemsDown":
            .down

        case "stemsOff":
            .off

        case "stemsUp":
            .up

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this direction — the spelling
    // `ARTStem::getGMNName` builds (`ARTStem.cpp:52–61`).
    internal var tagName: String {
        switch self {
        case .auto:
            "stemsAuto"

        case .down:
            "stemsDown"

        case .off:
            "stemsOff"

        case .up:
            "stemsUp"
        }
    }
}

// MARK: - Equatable

extension GMNStemDirection.Kind: Equatable {
}

// MARK: - Sendable

extension GMNStemDirection.Kind: Sendable {
}
