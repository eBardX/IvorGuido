// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single symbol in a Guido Music Notation voice.
public enum GMNSymbol {
    /// A chord symbol.
    case chord(GMNChord)

    /// A note symbol.
    case note(GMNNote)

    /// A rest symbol.
    case rest(GMNRest)

    /// A tablature symbol.
    case tablature(GMNTablature)

    /// A tag symbol.
    case tag(GMNTag)

    /// A variable reference, identified by name.
    case variable(GMNVariable.Name)
}

// MARK: -

extension GMNSymbol {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this symbol represents musical
    /// content (a note, rest, chord, tablature, or a tag that contains
    /// musical content).
    public var isMusic: Bool {
        switch self {
        case .chord,
             .note,
             .rest,
             .tablature:
            true

        case let .tag(tag):
            tag.body.contains { $0.isMusic }

        default:
            false
        }
    }
}

// MARK: - Equatable

extension GMNSymbol: Equatable {
}

// MARK: - Sendable

extension GMNSymbol: Sendable {
}
