// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    /// Which part of a spanning construct a Guido Music Notation tag is.
    ///
    /// Roughly forty tag names are the `…Begin`/`…End`
    /// halves of about fifteen base tags — `\slurBegin`/`\slurEnd`,
    /// `\crescBegin`/`\crescEnd`, `\tieBegin`/`\tieEnd`, and so on. Rather
    /// than give each half its own payload, one payload carries a `Span`.
    ///
    /// - ``whole``: the range form, `\slur(c d e)` — the tag owns a body.
    /// - ``begin`` / ``end``: the open form, `\slurBegin c d \slurEnd`,
    ///   optionally paired by a ``GMNTag/Ident`` suffix.
    ///
    /// ## The two forms are never interchanged
    ///
    /// A `Begin`/`End` pair is not rewritten into a range, nor a range into a
    /// pair, on grounds of totality: open spans may overlap or go
    /// unterminated, and a range is a tree that can express neither.
    /// A real score may contain
    /// `\slurBegin:1 \beam( b/16 \crescBegin c3 d e&) \slurEnd:1 \crescEnd`,
    /// which interleaves three spans across the beam’s range. Restricting the
    /// rewrite to the safe subset would be worse than not doing it: identical
    /// fragments would format differently depending on distant context.
    ///
    /// ## An `end` carries no parameters
    ///
    /// Every `…End` name takes no parameters at all. A payload whose span is
    /// ``end`` therefore refuses typed parameters, and none is ever emitted.
    /// Parameters written on an `…End` tag keep it reserved
    /// through the parser, and ``GMNNormalizer`` drops them —
    /// ``GMNNormalizer/Change/droppedSpanEndParameters(_:)`` — so the tag
    /// promotes on the second pass.
    public enum Span {
        /// The opening half of an open span (`\slurBegin`).
        case begin

        /// The closing half of an open span (`\slurEnd`). Carries no
        /// parameters.
        case end

        /// The range form, which owns its body (`\slur(c d e)`).
        case whole
    }
}

// MARK: - Equatable

extension GMNTag.Span: Equatable {
}

// MARK: - Sendable

extension GMNTag.Span: Sendable {
}
