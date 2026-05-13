// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A duration in a Guido Music Notation score, expressed as a fraction of a
/// whole note (possibly augmented by dots) or as an absolute time in
/// milliseconds.
public struct GMNDuration {

    // MARK: Public Initializers

    /// Creates a new duration expressed in milliseconds.
    ///
    /// If `milliseconds` is zero, this initializer returns `nil`.
    ///
    /// - Parameter milliseconds:   The duration in milliseconds.
    public init?(milliseconds: UInt) {
        guard milliseconds > 0
        else { return nil }

        self.value = .milliseconds(milliseconds)
    }

    /// Creates a new duration expressed as a fractional note value, possibly
    /// augmented by dots.
    ///
    /// The fraction is reduced to lowest terms before being stored.
    ///
    /// If either `numerator` or `denominator` is zero, or if `dots` is not in
    /// the range `0...3`, this initializer returns `nil`.
    ///
    /// - Parameter numerator:      The numerator of the note fraction.
    /// - Parameter denominator:    The denominator of the note fraction.
    /// - Parameter dots:           The number of augmentation dots (0–3).
    ///                             Defaults to zero.
    public init?(numerator: UInt,
                 denominator: UInt,
                 dots: UInt = 0) {
        guard numerator > 0,
              denominator > 0,
              (0...3).contains(dots)
        else { return nil }

        var num = numerator
        var den = denominator

        if den != 1 {
            if num != 0 {
                let tmp = UInt.gcd(num, den)

                if tmp != 1 {
                    num /= tmp
                    den /= tmp
                }
            } else {
                den = 1
            }
        }

        self.value = .fractionDots(num, den, dots)
    }

    // MARK: Internal Instance Properties

    internal let value: Value
}

// MARK: -

extension GMNDuration {

    // MARK: Public Instance Properties

    /// The denominator of the note fraction, or `nil` if this duration is
    /// expressed in milliseconds.
    public var denominator: UInt? {
        switch value {
        case let .fractionDots(_, den, _):
            den

        default:
            nil
        }
    }

    /// The number of augmentation dots (0–3), or `nil` if this duration is
    /// expressed in milliseconds.
    public var dots: UInt? {
        switch value {
        case let .fractionDots(_, _, dots):
            dots

        default:
            nil
        }
    }

    /// The duration in milliseconds, or `nil` if this duration is expressed as
    /// a fractional note value.
    public var milliseconds: UInt? {
        switch value {
        case let .milliseconds(ms):
            ms

        default:
            nil
        }
    }

    /// The numerator of the note fraction, or `nil` if this duration is
    /// expressed in milliseconds.
    public var numerator: UInt? {
        switch value {
        case let .fractionDots(num, _, _):
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
