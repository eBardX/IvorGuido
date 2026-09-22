// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagTemplateSlotTests {
}

// MARK: -

extension GMNTagTemplateSlotTests {
    @Test
    func init_decodesEveryField() throws {
        let slot = try #require(GMNTagTemplate.Slot(specification: "S,color,black,o"))

        #expect(slot.defaultValue == "black")
        #expect(!slot.isRequired)
        #expect(slot.kind == .string)
        #expect(slot.name == "color")
    }

    @Test
    func init_decodesEveryKindLetter() throws {
        #expect(try #require(GMNTagTemplate.Slot(specification: "F,size,1.0,o")).kind == .float)
        #expect(try #require(GMNTagTemplate.Slot(specification: "I,id,0,o")).kind == .integer)
        #expect(try #require(GMNTagTemplate.Slot(specification: "U,dx,0,o")).kind == .length)
        #expect(try #require(GMNTagTemplate.Slot(specification: "S,type,treble,r")).kind == .string)
    }

    @Test
    func init_decodesRequiredFlag() throws {
        let required = try #require(GMNTagTemplate.Slot(specification: "S,type,treble,r"))
        let optional = try #require(GMNTagTemplate.Slot(specification: "S,type,treble,o"))

        // Anything other than the literal `"r"` is optional — guidolib
        // writes `setRequired(parts[3] == "r")` and never inspects it again.
        let other = try #require(GMNTagTemplate.Slot(specification: "S,type,treble,x"))

        #expect(required.isRequired)
        #expect(!optional.isRequired)
        #expect(!other.isRequired)
    }

    @Test
    func init_mapsEmptyDefaultToNil() throws {
        let slot = try #require(GMNTagTemplate.Slot(specification: "S,tempo,,r"))

        #expect(slot.defaultValue == nil)
        #expect(slot.name == "tempo")
    }

    @Test
    func init_rejectsWhatGuidolibDiscards() {
        // `str2tagParam` requires exactly four comma-separated parts and a
        // recognized type letter; anything else is dropped with a warning.
        #expect(GMNTagTemplate.Slot(specification: "") == nil)
        #expect(GMNTagTemplate.Slot(specification: "S,color,black") == nil)
        #expect(GMNTagTemplate.Slot(specification: "S,color,black,o,extra") == nil)
        #expect(GMNTagTemplate.Slot(specification: "X,color,black,o") == nil)
        #expect(GMNTagTemplate.Slot(specification: "s,color,black,o") == nil)
    }
}
