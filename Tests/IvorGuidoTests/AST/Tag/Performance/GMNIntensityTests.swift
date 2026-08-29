// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNIntensityTests {
}

// MARK: -

extension GMNIntensityTests {
    @Test
    func canonicalNameIsIntensity() {
        #expect(GMNIntensity(type: "pp").name == makeTagName("intensity"))
    }

    @Test
    func equatable() {
        let a = GMNIntensity(type: "pp")
        let b = GMNIntensity(type: "pp")
        let c = GMNIntensity(type: "ff")

        #expect(a == b)
        #expect(a != c)
    }

    @Test(arguments: ["i", "intens", "intensity"])
    func everyAliasPromotes(_ name: String) throws {
        guard case let .intensity(intensity) = try normalizedTag("[\\\(name)<\"pp\"> c]")
        else {
            Issue.record("Expected intensity tag")
            return
        }

        #expect(intensity.type == "pp")
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let intensity = GMNIntensity(type: "pp")

        #expect(intensity.after == nil)
        #expect(intensity.appearance.isEmpty)
        #expect(intensity.autopos == nil)
        #expect(intensity.before == nil)
        #expect(intensity.body.isEmpty)
        #expect(intensity.ident == nil)
        #expect(intensity.textStyle.isEmpty)
        #expect(intensity.type == "pp")
    }

    @Test
    func isRejectedWithoutTheRequiredType() {
        expectRejected("[\\intensity c]",
                       .missingRequiredParameter(makeTagName("intensity"), "type"))
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .intensity(intensity) =
              try normalizedTag("[\\intensity<\"pp\",\"molto\",\"sempre\",\"Arial\",12pt,\"b\",\"on\"> c]")
        else {
            Issue.record("Expected intensity tag")
            return
        }

        #expect(intensity.after == "sempre")
        #expect(intensity.autopos == "on")
        #expect(intensity.before == "molto")
        #expect(intensity.textStyle.font == "Arial")
        #expect(intensity.textStyle.fontAttributes == "b")
        #expect(intensity.textStyle.fontSize == GMNLength(12, unit: .pt))
    }

    @Test
    func textformatIsTheOneFontParameterWithNoSlot() throws {
        // `kARIntensParams` redeclares `font`, `fsize`, and `fattrib` but not
        // `textformat`, so that one is supported only through
        // `kARFontAbleParams` and is always written named.
        guard case let .intensity(intensity) = try normalizedTag("[\\intensity<\"pp\",textformat=\"cc\"> c]")
        else {
            Issue.record("Expected intensity tag")
            return
        }

        #expect(intensity.textStyle.textFormat == "cc")
    }
}
