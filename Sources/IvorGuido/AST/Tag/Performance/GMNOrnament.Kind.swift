// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNOrnament {

    // MARK: Public Nested Types

    // All three names build the *same* class, `ARTrill`, which selects
    // between them by constructor argument rather than by subclass
    // (`ARFactory.cpp:1490–1520`). That is why one payload covers three tags
    // that a hierarchy walk would have split.

    /// Which ornament a ``GMNOrnament`` is.
    ///
    /// The kind is not a parameter — it is which tag name was written. All
    /// three kinds accept the same parameters.
    public enum Kind {
        /// A mordent (`\mordent`, alias `\mord`).
        case mordent

        /// A trill (`\trill`).
        case trill

        /// A turn (`\turn`).
        case turn
    }
}

// MARK: -

extension GMNOrnament.Kind {

    // MARK: Internal Type Methods

    // The kind the given tag name selects, or `nil` if it names no ornament.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "mord",
             "mordent":
            .mordent

        case "trill",
             "trillBegin",
             "trillEnd":
            .trill

        case "turn":
            .turn

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this kind's range form.
    internal var tagName: String {
        switch self {
        case .mordent:
            "mordent"

        case .trill:
            "trill"

        case .turn:
            "turn"
        }
    }
}

// MARK: - Equatable

extension GMNOrnament.Kind: Equatable {
}

// MARK: - Sendable

extension GMNOrnament.Kind: Sendable {
}
