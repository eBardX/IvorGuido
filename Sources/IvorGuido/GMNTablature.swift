// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A tablature symbol in a Guido Music Notation voice.
public struct GMNTablature {

    // MARK: Public Initializers

    /// Creates a new tablature symbol with the provided string, fret, and
    /// duration.
    ///
    /// - Parameter tabString:  The guitar string number (1-based).
    /// - Parameter fret:       The fret identifier.
    /// - Parameter duration:   The duration of this tablature symbol.
    public init(tabString: UInt,
                fret: String,
                duration: GMNDuration) {
        self.duration = duration
        self.fret = fret
        self.tabString = tabString
    }

    // MARK: Public Instance Properties

    /// The duration of this tablature symbol.
    public let duration: GMNDuration

    /// The fret identifier.
    public let fret: String

    /// The guitar string number (1-based).
    public let tabString: UInt
}

// MARK: - Equatable

extension GMNTablature: Equatable {
}

// MARK: - Sendable

extension GMNTablature: Sendable {
}
