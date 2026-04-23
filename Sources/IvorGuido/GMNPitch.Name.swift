// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension GMNPitch {

    // MARK: Public Nested Types

    /// The name of a pitch.
    public enum Name {
        /// The pitch name A.
        case a

        /// The pitch name A-sharp (German notation).
        case ais

        /// The pitch name B.
        case b

        /// The pitch name C.
        case c

        /// The pitch name C-sharp (German notation).
        case cis

        /// The pitch name D.
        case d

        /// The pitch name D-sharp (German notation).
        case dis

        /// The solfège pitch name Do (equivalent to C in Fixed Do).
        case `do`

        /// The pitch name E.
        case e

        /// An empty pitch (no name).
        case empty

        /// The pitch name F.
        case f

        /// The solfège pitch name Fa (equivalent to F in Fixed Do).
        case fa

        /// The pitch name F-sharp (German notation).
        case fis

        /// The pitch name G.
        case g

        /// The pitch name G-sharp (German notation).
        case gis

        /// The pitch name B-natural (German notation).
        case h

        /// The solfège pitch name La (equivalent to A in Fixed Do).
        case la

        /// The solfège pitch name Mi (equivalent to E in Fixed Do).
        case mi

        /// The solfège pitch name Re (equivalent to D in Fixed Do).
        case re

        /// The solfège pitch name Si (equivalent to B in Fixed Do).
        case si

        /// The solfège pitch name Sol (equivalent to G in Fixed Do).
        case sol

        /// The solfège pitch name Ti (equivalent to B in Fixed Do).
        case ti
    }
}

// MARK: - Equatable

extension GMNPitch.Name: Equatable {
}

// MARK: - Sendable

extension GMNPitch.Name: Sendable {
}
