// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNArticulation {

    // MARK: Public Nested Types

    // Eight names, eight guidolib classes, one shared base: `ARArticulation`
    // (`ARArticulation.h`), whose whole template is `S,position`. Four of the
    // eight — `accent`, `harmonic`, `marcato`, `tenuto` — add nothing to it at
    // all; the other four each add a `type` over a vocabulary of their own.
    //
    // The kind selects the template the formatter emits against.

    /// Which articulation a ``GMNArticulation`` is.
    ///
    /// The kind is not a parameter — it is which tag name was written, which
    /// is why it is not `Optional`. Every kind accepts a `position`; only
    /// ``bow``, ``fermata``, ``pizzicato``, and ``staccato`` also accept a
    /// `type`.
    public enum Kind {
        /// A stress accent (`\accent`).
        case accent

        /// A bowing direction (`\bow`).
        case bow

        /// A held note (`\fermata`).
        case fermata

        /// A harmonic (`\harmonic`).
        case harmonic

        /// A strong stress accent (`\marcato`).
        case marcato

        /// A plucked note (`\pizzicato`, alias `\pizz`).
        case pizzicato

        /// A detached note (`\staccato`, alias `\stacc`).
        case staccato

        /// A sustained note (`\tenuto`, alias `\ten`).
        case tenuto
    }
}

// MARK: -

extension GMNArticulation.Kind {

    // MARK: Internal Type Methods

    // The kind the given tag name selects, or `nil` if it names no
    // articulation.
    //
    // `staccBegin` and `staccEnd` are absent deliberately: the span, not the
    // kind, is what those two names carry beyond `\stacc` itself, and
    // `GMNArticulation`'s builder reads it from the registry.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "accent":
            .accent

        case "bow":
            .bow

        case "fermata":
            .fermata

        case "harmonic":
            .harmonic

        case "marcato":
            .marcato

        case "pizz",
             "pizzicato":
            .pizzicato

        case "stacc",
             "staccato",
             "staccBegin",
             "staccEnd":
            .staccato

        case "ten",
             "tenuto":
            .tenuto

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this kind's range form — the long spelling
    // wherever guidolib dispatches one.
    internal var tagName: String {
        switch self {
        case .accent:
            "accent"

        case .bow:
            "bow"

        case .fermata:
            "fermata"

        case .harmonic:
            "harmonic"

        case .marcato:
            "marcato"

        case .pizzicato:
            "pizzicato"

        case .staccato:
            "staccato"

        case .tenuto:
            "tenuto"
        }
    }
}

// MARK: - Equatable

extension GMNArticulation.Kind: Equatable {
}

// MARK: - Sendable

extension GMNArticulation.Kind: Sendable {
}
