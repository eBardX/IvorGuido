// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagTemplate {

    // MARK: Internal Nested Types

    // One parameter declaration taken from a guidolib parameter template
    // string.
    //
    // guidolib writes a template as `;`-separated elements, each of the form
    // `"TYPE,NAME,DEFVALUE,REQUIRED"` — the format is documented at
    // `TagParameterMap.cpp:28–47` and decoded by
    // `TagParameterMap::str2tagParam` (`TagParameterMap.cpp:151–173`).
    //
    // `str2tagParam` discards, with a warning, any element that does not
    // split into exactly four comma-separated parts or whose type letter is
    // unrecognized; `init?(specification:)` mirrors that by returning `nil`.
    // This is not hypothetical — `kARFingeringParams` ends with a stray `;`,
    // which yields a trailing empty element that guidolib drops on the floor.
    internal struct Slot {

        // MARK: Internal Initializers

        // Creates a slot from one element of a template string, or `nil` if
        // guidolib would discard that element.
        //
        // - Parameter specification: One `;`-delimited element, without its
        //                            delimiter.
        internal init?(specification: String) {
            let parts = specification.split(separator: ",",
                                            omittingEmptySubsequences: false)

            guard parts.count == 4,
                  let kind = Kind(rawValue: String(parts[0]))
            else { return nil }

            let defaultValue = String(parts[2])

            self.defaultValue = defaultValue.isEmpty ? nil : defaultValue
            self.isRequired = parts[3] == "r"
            self.kind = kind
            self.name = String(parts[1])
        }

        // MARK: Internal Instance Properties

        // The declared default value, verbatim, or `nil` where guidolib
        // declares it empty.
        //
        // guidolib always stores a string here, so an empty field becomes
        // `setValue("")` rather than an absent default. The distinction is
        // not observable for the formatter's purposes: an empty default is
        // never a value a written parameter could redundantly restate, so
        // the default-omission rule never fires against it either way.
        internal let defaultValue: String?

        // Whether guidolib flags this parameter `r` (required) rather than
        // `o` (optional).
        //
        // Requiredness is enforced by `TagParameterMap::checkRequired`
        // (`TagParameterMap.cpp:96–107`), which only warns — a score with a
        // missing required parameter still parses.
        internal let isRequired: Bool

        // The value type declared by the leading type letter.
        internal let kind: Kind

        // The parameter's name, as written in the template.
        internal let name: String
    }
}

// MARK: - Equatable

extension GMNTagTemplate.Slot: Equatable {
}

// MARK: - Sendable

extension GMNTagTemplate.Slot: Sendable {
}
