// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // A guidolib template declares one C++ type per parameter, and
    // `TagParameterMap::get<T>` is a `dynamic_cast` (`TagParameterMap.h:54–57`),
    // so a value of any other type normally reads back as null and the
    // parameter is inert. `ARKey` reads `key` as a `TagParameterString` and,
    // failing that, as a `TagParameterInt` (`ARKey.cpp:88–96`); `ARStaff` reads
    // `id` as a `TagParameterInt` in `getStaffNumber()` and as a
    // `TagParameterString` in `getStaffID()`, the former returning the sentinel
    // `-1` precisely when the latter would answer (`ARStaff.cpp:50–64`).
    //
    // See `GMNTagTemplate`'s alternate-kind table for the derivation of the two
    // cases, and for the four names an earlier, name-global reading of the same
    // evidence wrongly produced.

    /// A parameter written either as a whole number or as a quoted string,
    /// where the tag’s own class reads both.
    ///
    /// Most parameters accept one spelling and treat the other as inert. Two
    /// accept both:
    ///
    /// - `\key<"D">` names a key and `\key<2>` counts its accidentals.
    /// - `\staff<2>` numbers a staff and `\staff<"upper">` names one.
    ///
    /// This type is what lets a payload carry either spelling without
    /// re-spelling it, so `\key<2>` and `\staff<"upper">` are typed rather
    /// than left on the untyped lane. The distinction is preserved rather
    /// than collapsed: ``number(_:)`` and ``name(_:)`` format back as they
    /// were written, and a `2` is never turned into a `"2"`.
    public enum NumberOrName {
        /// Written as a quoted string.
        case name(String)

        /// Written as a whole number.
        case number(Int)

        // MARK: Internal Initializers

        // Reads a written value, or `nil` if it is neither a quoted string nor a
        // whole number.
        //
        // A float never qualifies, under either reading: `TagParameterInt`
        // derives from `TagParameterFloat` and not the other way round, so
        // `getParameter<TagParameterInt>` casts a written float away.
        internal init?(_ value: GMNTag.Parameter.Value?) {
            switch value {
            case let .integer(magnitude, _):
                self = .number(magnitude)

            case let .string(text):
                self = .name(text)

            default:
                return nil
            }
        }
    }
}

// MARK: -

extension GMNTag.NumberOrName {

    // MARK: Internal Instance Properties

    // This value as a written parameter value.
    internal var parameterValue: GMNTag.Parameter.Value {
        switch self {
        case let .name(text):
            .string(text)

        case let .number(magnitude):
            .integer(magnitude, nil)
        }
    }
}

// MARK: - Equatable

extension GMNTag.NumberOrName: Equatable {
}

// MARK: - Sendable

extension GMNTag.NumberOrName: Sendable {
}
