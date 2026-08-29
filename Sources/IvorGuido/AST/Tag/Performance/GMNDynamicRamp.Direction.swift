// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNDynamicRamp {

    // MARK: Public Nested Types

    // guidolib: `ARCrescendo` and `ARDiminuendo`, two subclasses of
    // `ARDynamic` that add neither a template nor a parameter map — the class
    // is the direction and nothing else (`ARFactory.cpp:840–930`).

    /// Which way a ``GMNDynamicRamp`` ramps.
    ///
    /// The direction is not a parameter — it is which tag name was written.
    /// Both directions accept exactly the same parameters.
    public enum Direction {
        /// The dynamic rises (`\crescendo`, alias `\cresc`).
        case crescendo

        /// The dynamic falls (`\diminuendo`, aliases `\dim`, `\decresc`,
        /// `\decrescendo`).
        case diminuendo
    }
}

// MARK: -

extension GMNDynamicRamp.Direction {

    // MARK: Internal Type Methods

    // The direction the given tag name selects, or `nil` if it names no
    // dynamic ramp.
    internal static func direction(forTagName name: String) -> Self? {
        switch name {
        case "cresc",
             "crescBegin",
             "crescEnd",
             "crescendo":
            .crescendo

        case "decresc",
             "decrescBegin",
             "decrescEnd",
             "decrescendo",
             "dim",
             "dimBegin",
             "dimEnd",
             "diminuendo",
             "diminuendoBegin",
             "diminuendoEnd":
            .diminuendo

        default:
            nil
        }
    }

    // MARK: Internal Instance Methods

    // The canonical tag name for this direction and span.
    //
    // `\crescendo` is the asymmetric one: guidolib dispatches no
    // `\crescendoBegin` or `\crescendoEnd`, only the short `\crescBegin` and
    // `\crescEnd`, so those are the canonical spellings of its open halves
    // even though its range form has a long one. `\diminuendo` has the long
    // spelling throughout.
    internal func tagName(for span: GMNTag.Span) -> String {
        switch (self, span) {
        case (.crescendo, .begin):
            "crescBegin"

        case (.crescendo, .end):
            "crescEnd"

        case (.crescendo, .whole):
            "crescendo"

        case (.diminuendo, .begin):
            "diminuendoBegin"

        case (.diminuendo, .end):
            "diminuendoEnd"

        case (.diminuendo, .whole):
            "diminuendo"
        }
    }
}

// MARK: - Equatable

extension GMNDynamicRamp.Direction: Equatable {
}

// MARK: - Sendable

extension GMNDynamicRamp.Direction: Sendable {
}
