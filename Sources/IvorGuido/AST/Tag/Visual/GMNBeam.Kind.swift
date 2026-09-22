// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNBeam {

    // MARK: Public Nested Types

    // guidolib: `ARBeam` and `ARFeatheredBeam : ARBeam`. The subclass adds
    // `kARFeatheredBeamParams` on top of `kARBeamParams` and makes those two
    // its *only* positional slots, so the two names have the same supported
    // set but different slot orders — which is why the kind selects the
    // template the formatter emits against.

    /// Which of the two beam tags a ``GMNBeam`` is.
    public enum Kind {
        /// A feathered beam (`\fBeam`).
        case feathered

        /// An ordinary beam (`\beam`, aliases `\b` and `\bm`).
        case normal
    }
}

// MARK: -

extension GMNBeam.Kind {

    // MARK: Internal Type Methods

    // The kind the given tag name selects, or `nil` if it names no beam.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "b",
             "beam",
             "beamBegin",
             "beamEnd",
             "bm":
            .normal

        case "fBeam",
             "fBeamBegin",
             "fBeamEnd":
            .feathered

        default:
            nil
        }
    }

    // MARK: Internal Instance Methods

    // The canonical tag name for this kind and span.
    //
    // Both families are symmetric — guidolib dispatches `\beamBegin` and
    // `\beamEnd` (`ARFactory.cpp:693,702`) and `\fBeamBegin` and `\fBeamEnd`
    // — so unlike the articulations and the dynamic ramps there is no short
    // spelling to preserve here.
    internal func tagName(for span: GMNTag.Span) -> String {
        let base = self == .feathered ? "fBeam" : "beam"

        switch span {
        case .begin:
            return base + "Begin"

        case .end:
            return base + "End"

        case .whole:
            return base
        }
    }
}

// MARK: - Equatable

extension GMNBeam.Kind: Equatable {
}

// MARK: - Sendable

extension GMNBeam.Kind: Sendable {
}
