// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNBarLine {

    // MARK: Public Nested Types

    // The three names back onto three classes — `ARBar`, `ARDoubleBar`, and
    // `ARFinishBar` — that share `kARBarParams` verbatim and differ only in
    // how they are drawn (`ARFinishBar.h:44`), which is exactly a payload with
    // a `kind` rather than three payloads.

    /// Which of the three barlines a ``GMNBarLine`` is.
    ///
    /// All three accept the same parameters and differ only in how they are
    /// drawn.
    public enum Kind {
        /// A double barline (`\doubleBar`).
        case double

        /// A final barline (`\endBar`).
        case final

        /// An ordinary barline (`|`, `\bar`).
        case single
    }
}

// MARK: - Equatable

extension GMNBarLine.Kind: Equatable {
}

// MARK: - Sendable

extension GMNBarLine.Kind: Sendable {
}
