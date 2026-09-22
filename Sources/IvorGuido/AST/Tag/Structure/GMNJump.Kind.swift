// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNJump {

    // MARK: Public Nested Types

    // The eight names back onto eight classes that derive from `ARJump` and
    // add nothing but a label — one payload with a `kind`. Groupings come
    // from dispatched names; the class hierarchy only reveals which names
    // share a shape.

    /// Which navigation mark a ``GMNJump`` is.
    ///
    /// All eight accept the same parameters and differ only in the label they
    /// draw.
    public enum Kind {
        /// A coda sign (`\coda`).
        case coda

        /// A *da capo* instruction (`\daCapo`).
        case daCapo

        /// A *da capo al fine* instruction (`\daCapoAlFine`).
        case daCapoAlFine

        /// A *da coda* instruction (`\daCoda`).
        case daCoda

        /// A *dal segno* instruction (`\dalSegno`).
        case dalSegno

        /// A *dal segno al fine* instruction (`\dalSegnoAlFine`).
        case dalSegnoAlFine

        /// A *fine* marking (`\fine`).
        case fine

        /// A segno sign (`\segno`).
        ///
        /// The one kind with no positional parameters: `\segno`’s must
        /// always be written named.
        case segno
    }
}

// MARK: -

extension GMNJump.Kind {

    // MARK: Internal Type Methods

    // The kind written as `tagName`, or `nil` if that is not a jump name.
    internal static func kind(forTagName tagName: String) -> Self? {
        allKinds.first { $0.tagName == tagName }
    }

    // MARK: Internal Instance Properties

    // The tag name this kind is written as. Each is already the canonical long
    // form — no navigation mark has an alias.
    internal var tagName: String {
        switch self {
        case .coda:
            "coda"

        case .daCapo:
            "daCapo"

        case .daCapoAlFine:
            "daCapoAlFine"

        case .daCoda:
            "daCoda"

        case .dalSegno:
            "dalSegno"

        case .dalSegnoAlFine:
            "dalSegnoAlFine"

        case .fine:
            "fine"

        case .segno:
            "segno"
        }
    }

    // MARK: Private Type Properties

    private static let allKinds: [Self] = [.coda,
                                           .daCapo,
                                           .daCapoAlFine,
                                           .daCoda,
                                           .dalSegno,
                                           .dalSegnoAlFine,
                                           .fine,
                                           .segno]
}

// MARK: - Equatable

extension GMNJump.Kind: Equatable {
}

// MARK: - Sendable

extension GMNJump.Kind: Sendable {
}
