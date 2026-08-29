// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNUnitsTests {
}

// MARK: -

extension GMNUnitsTests {
    @Test
    func canonicalNameIsUnits() {
        #expect(GMNUnits(type: "cm").name == makeTagName("units"))
    }

    @Test
    func equatable() {
        let a = GMNUnits(type: "cm")
        let b = GMNUnits(type: "cm")
        let c = GMNUnits(type: "in")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let units = GMNUnits(type: "cm")

        #expect(units.appearance.isEmpty)
        #expect(units.body.isEmpty)
        #expect(units.ident == nil)
        #expect(units.type == "cm")
    }

    @Test
    func isRejectedWithoutTheRequiredType() {
        expectRejected("[\\units]",
                       .missingRequiredParameter(makeTagName("units"), "type"))
    }

    @Test
    func promotes() throws {
        guard case let .units(units) = try normalizedTag("[\\units<\"cm\">]")
        else {
            Issue.record("Expected units tag")
            return
        }

        #expect(units.type == "cm")
    }
}
