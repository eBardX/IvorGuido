// © 2026 John Gary Pusey (see LICENSE.md)

// This is the model of guidolib's `U` parameter kind, the third of the four
// kinds a tag parameter template may declare (`S`, `I`, `F`, `U`). guidolib
// resolves a unitless value against the template's own declared default unit
// (`ARMusicalTag::checkUnitParameters`).
//
// The magnitude is a `Double` because guidolib's `TagParameterFloat` stores a
// `float`.

/// A length in a Guido Music Notation score — a signed magnitude with an
/// optional unit of measurement.
///
/// Negative values are legal and meaningful: a `U`-typed parameter is as often
/// a displacement along an axis as it is an extent, and `dx=-5hs` places a
/// symbol to the left of where it would otherwise sit.
///
/// Every parameter that measures something — `dx`, `dy`, `fsize`, `dx1`, `h`,
/// `thickness`, and the rest — is a `GMNLength` rather than a bare `Double`,
/// so the unit written in the source survives into the AST.
///
/// A `nil` ``unit`` means no unit was written (`dx=5`), which is distinct
/// from a unit that happens to be the default. Which unit a unitless value
/// takes is decided per tag when the score is rendered, and the AST
/// deliberately does not bake that in.
///
/// The magnitude does not record how it was written: `dx=5hs` and `dx=5.0hs`
/// are the same value.
public struct GMNLength {

    // MARK: Public Initializers

    /// Creates a new length with the provided magnitude and unit.
    ///
    /// - Parameter value: The signed magnitude of this length.
    /// - Parameter unit:  The unit of measurement written alongside the
    ///                    magnitude, or `nil` if none was written. Defaults to
    ///                    `nil`.
    public init(_ value: Double,
                unit: GMNTag.Parameter.Unit? = nil) {
        self.unit = unit
        self.value = value
    }

    // MARK: Public Instance Properties

    /// The unit of measurement of this length, or `nil` if none was written.
    public let unit: GMNTag.Parameter.Unit?

    /// The signed magnitude of this length.
    public let value: Double
}

// MARK: -

extension GMNLength {

    // MARK: Internal Instance Properties

    // This length as a written parameter value, for a typed payload's `U`
    // field.
    internal var parameterValue: GMNTag.Parameter.Value {
        .number(value,
                unit: unit)
    }
}

// MARK: - Equatable

extension GMNLength: Equatable {
}

// MARK: - Sendable

extension GMNLength: Sendable {
}
