// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNText {

    // MARK: Public Nested Types

    // guidolib: `ARText` and `ARLabel`, two classes with identical parameters
    // — `ARLabel` explicitly returns `kARTextParams` and adds nothing
    // (`ARLabel.h:29`).
    //
    // `GRVoiceManager` dispatches on `typeid(ARLabel)` exactly
    // (`GRVoiceManager.cpp:1055,1471`), an equality test that an `ARText`
    // fails.

    /// Which of the two text tags a ``GMNText`` is.
    ///
    /// The two accept identical parameters but are **not** interchangeable:
    /// they are drawn by different code, so `\label` is never rewritten as
    /// `\text`.
    public enum Kind {
        /// A label (`\label`).
        case label

        /// A text string (`\text`, alias `\t`).
        case text
    }
}

// MARK: -

extension GMNText.Kind {

    // MARK: Internal Type Methods

    // The kind the given tag name selects, or `nil` if it names neither text
    // tag.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "label":
            .label

        case "t",
             "text":
            .text

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this kind.
    internal var tagName: String {
        switch self {
        case .label:
            "label"

        case .text:
            "text"
        }
    }
}

// MARK: - Equatable

extension GMNText.Kind: Equatable {
}

// MARK: - Sendable

extension GMNText.Kind: Sendable {
}
