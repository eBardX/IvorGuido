// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A duration in a Guido Music Notation score, expressed as a fraction of a
/// whole note or as an absolute time in milliseconds, optionally augmented by
/// dots.
///
/// A note/rest/tablature symbol with no duration written at all (e.g. bare
/// `c`) has a `nil` `GMNDuration` — there is no such thing as a `GMNDuration`
/// with neither a base nor any dots. `dots` written without a base (e.g.
/// `c.`) still augments whatever duration is inherited from a prior symbol.
public struct GMNDuration {

    // MARK: Public Initializers

    /// Creates a new duration with no explicit base, representing dots
    /// written without a base in the source text (e.g. `c.`).
    ///
    /// - Parameter dots:   The number of augmentation dots written without an
    ///                     explicit base.
    public init(dots: DotCount) {
        self.base = nil
        self.dots = dots
    }

    /// Creates a new duration expressed in milliseconds, possibly augmented
    /// by dots.
    ///
    /// If `milliseconds` is zero, this initializer returns `nil`.
    ///
    /// - Parameter milliseconds:   The duration in milliseconds.
    /// - Parameter dots:           The number of augmentation dots written
    ///                             alongside this base, or `nil` if none were
    ///                             written.
    public init?(milliseconds: UInt,
                 dots: DotCount? = nil) {
        guard milliseconds > 0
        else { return nil }

        self.base = .milliseconds(milliseconds)
        self.dots = dots
    }

    /// Creates a new duration expressed as a fractional note value, possibly
    /// augmented by dots.
    ///
    /// The fraction is reduced to lowest terms before being stored.
    ///
    /// If either `numerator` or `denominator` is zero, this initializer
    /// returns `nil`.
    ///
    /// - Parameter numerator:      The numerator of the note fraction.
    /// - Parameter denominator:    The denominator of the note fraction.
    /// - Parameter dots:           The number of augmentation dots written
    ///                             alongside this base, or `nil` if none were
    ///                             written.
    public init?(numerator: UInt,
                 denominator: UInt,
                 dots: DotCount? = nil) {
        guard numerator > 0,
              denominator > 0
        else { return nil }

        var num = numerator
        var den = denominator

        if den != 1 {
            let tmp = UInt.gcd(num, den)

            if tmp != 1 {
                num /= tmp
                den /= tmp
            }
        }

        self.base = .fraction(num, den)
        self.dots = dots
    }

    // MARK: Public Instance Properties

    /// The number of augmentation dots written directly on this duration, or
    /// `nil` if none were written.
    public let dots: DotCount?

    // MARK: Internal Instance Properties

    internal let base: Base?
}

// MARK: -

extension GMNDuration {

    // MARK: Public Instance Properties

    /// The denominator of the note fraction, or `nil` if this duration is
    /// expressed in milliseconds or its base was omitted from the source.
    public var denominator: UInt? {
        switch base {
        case let .fraction(_, den)?:
            den

        default:
            nil
        }
    }

    /// The duration in milliseconds, or `nil` if this duration is expressed as
    /// a fractional note value or its base was omitted from the source.
    public var milliseconds: UInt? {
        switch base {
        case let .milliseconds(ms)?:
            ms

        default:
            nil
        }
    }

    /// The numerator of the note fraction, or `nil` if this duration is
    /// expressed in milliseconds or its base was omitted from the source.
    public var numerator: UInt? {
        switch base {
        case let .fraction(num, _)?:
            num

        default:
            nil
        }
    }
}

// MARK: - Equatable

extension GMNDuration: Equatable {
}

// MARK: - Sendable

extension GMNDuration: Sendable {
}
