// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNBeamState {

    // MARK: Public Nested Types

    // guidolib: `ARBeamState::beamstate` — a genuine C++ enumeration
    // (`ARBeamState.h:56`), which is what licenses a closed Swift enum here.
    // One dispatched name per case, chosen by `ARFactory::createTag`
    // (`ARFactory.cpp:710–730`).

    /// Which automatic-beaming setting a ``GMNBeamState`` selects.
    public enum Kind {
        /// Automatic beaming is on (`\beamsAuto`).
        case auto

        /// Automatic beaming is on and a rest no longer breaks a beam
        /// (`\beamsFull`).
        case full

        /// Automatic beaming is off (`\beamsOff`).
        case off
    }
}

// MARK: -

extension GMNBeamState.Kind {

    // MARK: Internal Type Methods

    // The setting the given tag name selects, or `nil` if it names no beam
    // state.
    internal static func kind(forTagName name: String) -> Self? {
        switch name {
        case "beamsAuto":
            .auto

        case "beamsFull":
            .full

        case "beamsOff":
            .off

        default:
            nil
        }
    }

    // MARK: Internal Instance Properties

    // The canonical tag name for this setting.
    internal var tagName: String {
        switch self {
        case .auto:
            "beamsAuto"

        case .full:
            "beamsFull"

        case .off:
            "beamsOff"
        }
    }
}

// MARK: - Equatable

extension GMNBeamState.Kind: Equatable {
}

// MARK: - Sendable

extension GMNBeamState.Kind: Sendable {
}
