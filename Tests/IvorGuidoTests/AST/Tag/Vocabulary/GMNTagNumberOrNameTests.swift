// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagNumberOrNameTests {
}

// MARK: -

extension GMNTagNumberOrNameTests {
    @Test
    func equatable() {
        #expect(GMNTag.NumberOrName.number(2) == .number(2))
        #expect(GMNTag.NumberOrName.name("D") == .name("D"))
        #expect(GMNTag.NumberOrName.number(2) != .name("2"))
    }

    @Test
    func init_declinesAFloat() {
        // `TagParameterInt` derives from `TagParameterFloat` and not the
        // other way round, so `getParameter<TagParameterInt>` casts a written
        // float away. Neither read answers, and the value is inert.
        #expect(GMNTag.NumberOrName(.floating(2.0, nil)) == nil)
    }

    @Test
    func init_declinesAnAbsentValue() {
        #expect(GMNTag.NumberOrName(nil) == nil)
    }

    @Test
    func init_declinesAVariableReference() {
        #expect(GMNTag.NumberOrName(.variable("x")) == nil)
    }

    @Test
    func init_dropsAUnitWrittenOnANumber() {
        // Both reads are of a bare C++ scalar, and neither slot is a `U`, so
        // there is nowhere for a unit to go. Dropping it here would be silent
        // loss, so `unrepresentableParameterNames` holds such a parameter back
        // from promotion and this is never reached with one — the arm exists
        // because the value type carries an optional unit regardless.
        #expect(GMNTag.NumberOrName(.integer(2, .hs)) == .number(2))
    }

    @Test
    func init_readsAQuotedString() {
        #expect(GMNTag.NumberOrName(.string("D")) == .name("D"))
    }

    @Test
    func init_readsAWholeNumber() {
        #expect(GMNTag.NumberOrName(.integer(2, nil)) == .number(2))
    }

    @Test
    func parameterValue_formatsBackAsWritten() {
        #expect(GMNTag.NumberOrName.number(2).parameterValue == .integer(2, nil))
        #expect(GMNTag.NumberOrName.name("D").parameterValue == .string("D"))
    }

    @Test
    func parameterValue_roundTripsThroughInit() {
        for value: GMNTag.NumberOrName in [.number(-3), .name("free=1&,2&")] {
            #expect(GMNTag.NumberOrName(value.parameterValue) == value)
        }
    }
}
