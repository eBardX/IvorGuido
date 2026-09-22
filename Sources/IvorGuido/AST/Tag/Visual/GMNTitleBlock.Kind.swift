// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTitleBlock {

    // MARK: Public Nested Types

    // guidolib: `ARTitle`, `ARComposer`, and `ARFooter` — three `ARText`
    // subclasses, each with a template of its own that differs only in
    // defaults and in what the required first slot is called.

    /// Which page-level text block a ``GMNTitleBlock`` is.
    public enum Kind {
        /// The composer credit (`\composer`).
        case composer

        /// The page footer (`\footer`).
        case footer

        /// The score title (`\title`).
        case title
    }
}

// MARK: -

extension GMNTitleBlock.Kind {

    // MARK: Internal Type Methods

    // The block the given tag name selects, or `nil` if it names no text
    // block.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "composer":
            .composer

        case "footer":
            .footer

        case "title":
            .title

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this block.
    internal var tagName: String {
        switch self {
        case .composer:
            "composer"

        case .footer:
            "footer"

        case .title:
            "title"
        }
    }

    // Which template slot this block's text occupies.
    //
    // `kARTitleParams` and `kARComposerParams` open with `S,name,,r` while
    // `kARFooterParams` opens with `S,text,,r`, so one payload field lands on
    // two different names. The difference is not cosmetic: `\title` and
    // `\composer` also *remove* the `text` they inherit from `ARText`
    // (`ARTitle.cpp:31`, `ARComposer.cpp:30`), so writing `text=` on either is
    // an unsupported parameter rather than a second spelling of `name`.
    internal var textParameterName: String {
        self == .footer ? "text" : "name"
    }
}

// MARK: - Equatable

extension GMNTitleBlock.Kind: Equatable {
}

// MARK: - Sendable

extension GMNTitleBlock.Kind: Sendable {
}
