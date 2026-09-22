// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

// The specification strings are guidolib's own `ARMTParameter` tables copied
// verbatim, so what is worth stating about them is that they still parse into
// the slots they name — a stray separator or a bad kind letter would
// otherwise drop a slot silently and only show up as a tag that stops
// binding.
struct GMNTagTemplateSpecificationTests {
}

// MARK: -

extension GMNTagTemplateSpecificationTests {
    @Test
    func aMultiLineSpecificationParsesAsOneList() {
        // `arAuto` is written as several concatenated string literals; the
        // concatenation must not introduce or lose a separator.
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.arAuto)

        #expect(slots.count == 23)
        #expect(slots.allSatisfy { !$0.name.isEmpty })
    }

    @Test
    func common_isTheFourParametersEveryTagAccepts() {
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.common)

        #expect(slots.map(\.name) == ["color", "dx", "dy", "size"])
        #expect(slots.allSatisfy { !$0.isRequired })
    }

    @Test
    func common_slotKindsAreAsWritten() {
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.common)
        let kinds = Dictionary(uniqueKeysWithValues: slots.map { ($0.name, $0.kind) })

        #expect(kinds["color"] == .string)
        #expect(kinds["dx"] == .length)
        #expect(kinds["dy"] == .length)
        #expect(kinds["size"] == .float)
    }

    @Test
    func defaultValue_isReadFromTheMiddleField() {
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.common)
        let defaults = Dictionary(uniqueKeysWithValues: slots.map { ($0.name, $0.defaultValue) })

        #expect(defaults["color"] == "black")
        #expect(defaults["size"] == "1.0")
    }

    @Test
    func fontAble_isTheFourFontParameters() {
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.fontAble)

        #expect(slots.map(\.name).sorted() == ["fattrib", "font", "fsize", "textformat"])
    }

    @Test
    func requiredness_isReadFromTheTrailingFlag() {
        // `r` is required and `o` is optional; `\clef` has exactly one
        // required slot.
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.arClef)

        #expect(slots.map(\.name) == ["type"])
        #expect(slots[0].isRequired)
    }
}
