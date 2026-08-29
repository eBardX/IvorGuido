// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib's `FRETTE` lexer rule (`guido.l`) accepts any text between colons,
// so there is no content constraint to enforce.

/// A tablature symbol in a Guido Music Notation voice.
///
/// ``fret`` is stored verbatim and left unvalidated: any text between the
/// colons is legal, including none at all — `s1::` is a valid, empty fret.
public struct GMNTablature {

    // MARK: Public Initializers

    /// Creates a new tablature symbol with the provided string, fret, and
    /// duration, or `nil` if `tabString` is out of range.
    ///
    /// - Parameter tabString:  The guitar string number (1-based). Must be in
    ///                         the range 1...6, which is all Guido Music
    ///                         Notation admits.
    /// - Parameter fret:       The fret identifier.
    /// - Parameter duration:   The duration of this tablature symbol, or
    ///                         `nil` if no duration was written in the
    ///                         source.
    public init?(tabString: UInt,
                 fret: String,
                 duration: GMNDuration?) {
        guard (1...6).contains(tabString)
        else { return nil }

        self.duration = duration
        self.fret = fret
        self.tabString = tabString
    }

    // MARK: Public Instance Properties

    /// The duration of this tablature symbol, or `nil` if no duration was
    /// written in the source (inherits the previous duration).
    public let duration: GMNDuration?

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
