// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNRepeat {

    // MARK: Public Nested Types

    // Deliberately *not* a `GMNTag.Span`. A span's two halves are one guidolib
    // class dispatched twice, paired by ident and closed by an
    // `ARDummyRangeEnd`; these are two unrelated classes, neither of which is
    // a range end. `ARFactory` even ignores the ident on `\repeatBegin`
    // outright (`ARFactory.cpp:1265–1267`), which is why
    // `GMNTagTemplate.Registry.span(of:)` reports `.whole` for both names.

    /// Which half of a repeated passage a ``GMNRepeat`` is.
    ///
    /// This is *not* a ``GMNTag/Span``: the two halves take different
    /// parameters and are not paired by an identifier.
    public enum Kind {
        /// The opening half (`\repeatBegin`).
        ///
        /// Its positional parameters are the common appearance ones, so
        /// `hidden` must be written named.
        case begin

        /// The closing half (`\repeatEnd`).
        ///
        /// It takes the measure-numbering parameters a barline does, binds
        /// them positionally as a barline would, and — unlike its opening
        /// half — may take a body.
        case end
    }
}

// MARK: -

extension GMNRepeat.Kind {

    // MARK: Internal Instance Properties

    // The tag name this kind is written as. Neither has an alias.
    internal var tagName: String {
        switch self {
        case .begin:
            "repeatBegin"

        case .end:
            "repeatEnd"
        }
    }
}

// MARK: - Equatable

extension GMNRepeat.Kind: Equatable {
}

// MARK: - Sendable

extension GMNRepeat.Kind: Sendable {
}
