// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A duration in a Guido Music Notation score, expressed as a fraction of
/// a whole note or as an absolute time in milliseconds.
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

    /// Creates a new duration expressed as a fractional note value.
    ///
    /// If either `numerator` or `denominator` is zero, this initializer
    /// returns `nil`.
    ///
    /// - Parameter numerator:      The numerator of the note fraction.
    /// - Parameter denominator:    The denominator of the note fraction.
    public init?(numerator: UInt,
                 denominator: UInt) {
        guard numerator > 0,
              denominator > 0
        else { return nil }

        self.value = .fraction(numerator, denominator)
    }

    /// Creates a new duration expressed as a dotted fractional note value.
    ///
    /// If either `numerator` or `denominator` is zero, or if `dots` is not
    /// in the range `1...3`, this initializer returns `nil`.
    ///
    /// - Parameter numerator:      The numerator of the note fraction.
    /// - Parameter denominator:    The denominator of the note fraction.
    /// - Parameter dots:           The number of augmentation dots (1–3).
    public init?(numerator: UInt,
                 denominator: UInt,
                 dots: UInt) {
        guard numerator > 0,
              denominator > 0,
              (1...3).contains(dots)
        else { return nil }

        self.value = .fractionDots(numerator, denominator, dots)
    }

    // MARK: Internal Initializers

    internal init(_ value: Value) {
        self.value = value
    }

    // MARK: Internal Instance Properties

    internal let value: Value
}

// MARK: -

extension GMNDuration {

    // MARK: Internal Type Methods

    internal static func fraction(_ numerator: UInt,
                                  _ denominator: UInt) -> GMNDuration {
        GMNDuration(.fraction(numerator, denominator))
    }

    internal static func fractionDots(_ numerator: UInt,
                                      _ denominator: UInt,
                                      _ dots: UInt) -> GMNDuration {
        GMNDuration(.fractionDots(numerator, denominator, dots))
    }

    internal static func milliseconds(_ value: UInt) -> GMNDuration {
        GMNDuration(.milliseconds(value))
    }
}

// MARK: - Equatable

extension GMNDuration: Equatable {
}

// MARK: - Sendable

extension GMNDuration: Sendable {
}
