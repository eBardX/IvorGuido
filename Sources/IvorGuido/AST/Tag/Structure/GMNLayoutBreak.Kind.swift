// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNLayoutBreak {

    // MARK: Public Nested Types

    /// Which layout break a ``GMNLayoutBreak`` is.
    public enum Kind {
        /// A forced page break (`\newPage`).
        case newPage

        /// A forced system break (`\newLine`, `\newSystem`).
        ///
        /// `\newLine` is an alias, so a break written that way is written
        /// back as `\newSystem`.
        case newSystem
    }
}

// MARK: - Equatable

extension GMNLayoutBreak.Kind: Equatable {
}

// MARK: - Sendable

extension GMNLayoutBreak.Kind: Sendable {
}
