// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag.Parameter {

    // MARK: Public Nested Types

    /// The value of a Guido Music Notation tag parameter.
    public enum Value {
        /// A floating-point value, with an optional unit.
        case floating(Double, Unit?)

        /// An integer value, with an optional unit.
        case integer(Int, Unit?)

        // guidolib's bare `id` alternative of the `tagarg` production
        // (`guido.y` lines 183–193), which sits in the *value* position of a
        // `tagparam` — not the name position. guidolib discards it immediately
        // (`tagarg: id { $$ = 0; delete $1; }`, `GuidoParser.cpp:291`), even
        // when it is given a name via `name=rawIdent`, since the name is only
        // ever attached to a non-null parameter.

        /// A raw (unquoted) string value.
        ///
        /// Such a value is always in the *value* position, never the name
        /// position, and nothing reads it. ``GMNParser`` preserves the raw
        /// text rather than discarding it, so that a parsed score still
        /// round-trips byte for byte; ``GMNNormalizer`` then drops it and
        /// records
        /// ``GMNNormalizer/Change/droppedRawIdentifierParameter(_:_:)``,
        /// because it is otherwise the one token that keeps an entire tag
        /// untyped over a value nothing reads. So this case is reachable on a
        /// parsed score and never on a normalized one.
        case parameter(String)

        /// A quoted string value.
        case string(String)

        /// A variable-reference value.
        case variable(GMNVariable.Name)
    }
}

// MARK: -

extension GMNTag.Parameter.Value {

    // MARK: Internal Type Methods

    // Returns the value a typed payload's numeric field is written back as.
    //
    // A magnitude that is a whole number is spelled without a fractional
    // part, so a payload built from `hdx=2hs` re-emits `2hs` rather than
    // `2.0hs`. This is safe in exactly the direction it is used. `guido.y`
    // builds a `TagParameterInt` for `2` and a `TagParameterFloat` for
    // `2.0`, and `TagParameterInt` *derives from* `TagParameterFloat`
    // (`TagParameterInt.h:24`) — so the integer spelling satisfies every
    // reader the float spelling would, and `F` and `U` fields may use it
    // freely. The reverse would not hold, but never arises: an `I` slot
    // written with a float is ill-typed and is dropped before any payload
    // can hold it.
    internal static func number(_ value: Double,
                                unit: GMNTag.Parameter.Unit? = nil) -> Self {
        guard value == value.rounded(),
              let integerValue = Int(exactly: value.rounded())
        else { return .floating(value,
                                unit) }

        return .integer(integerValue,
                        unit)
    }
}

// MARK: - Equatable

extension GMNTag.Parameter.Value: Equatable {
}

// MARK: - Sendable

extension GMNTag.Parameter.Value: Sendable {
}
