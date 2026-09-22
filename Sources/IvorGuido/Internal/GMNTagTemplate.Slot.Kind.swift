// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagTemplate.Slot {

    // MARK: Internal Nested Types

    // The value type of a slot, from the leading type letter.
    internal enum Kind: String {

        // A float parameter (`F`) — `TagParameterFloat(false)`.
        case float = "F"

        // An integer parameter (`I`) — `TagParameterInt`.
        case integer = "I"

        // A length parameter (`U`) — `TagParameterFloat(true)`: a
        // magnitude carrying an optional unit, or else the default unit
        // set by `\units`. This is what `GMNLength` models.
        case length = "U"

        // A string parameter (`S`) — `TagParameterString`.
        case string = "S"
    }
}

// MARK: -

extension GMNTagTemplate.Slot.Kind {

    // MARK: Internal Instance Methods

    // Returns whether a written value of this kind survives the
    // `dynamic_cast` a reader performs on it.
    //
    // `TagParameterMap::get<T>` is a `dynamic_cast`
    // (`TagParameterMap.h:54–57`), so what matters is the C++ class
    // the grammar built, not what the template asked for. `guido.y`
    // builds exactly three: `TagParameterInt` for a signed number,
    // `TagParameterFloat` for a float, and `TagParameterString` for a
    // quoted string (`guido.y:183–187`, `GuidoParser.cpp:292–294`).
    //
    // The one asymmetry worth stating: `TagParameterInt` *derives
    // from* `TagParameterFloat` (`TagParameterInt.h:24`), so an
    // integer satisfies an `F` or `U` slot, while a float never
    // satisfies an `I` slot. A unit is a field on the value, not a
    // separate class, so it never affects the cast — `checkUnit`
    // warns about a misplaced one but binding is unaffected.
    internal func accepts(_ value: GMNTag.Parameter.Value) -> Bool {
        switch self {
        case .float,
             .length:
            switch value {
            case .floating,
                 .integer:
                true

            default:
                false
            }

        case .integer:
            if case .integer = value {
                true
            } else {
                false
            }

        case .string:
            if case .string = value {
                true
            } else {
                false
            }
        }
    }
}

// MARK: - Equatable

extension GMNTagTemplate.Slot.Kind: Equatable {
}

// MARK: - Sendable

extension GMNTagTemplate.Slot.Kind: Sendable {
}
