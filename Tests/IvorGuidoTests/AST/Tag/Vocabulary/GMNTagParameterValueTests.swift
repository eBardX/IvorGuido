// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagParameterValueTests {
}

// MARK: -

extension GMNTagParameterValueTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.Parameter.Value.integer(1, nil) == .integer(1, nil))
        #expect(GMNTag.Parameter.Value.integer(1, nil) != .integer(2, nil))
        #expect(GMNTag.Parameter.Value.integer(1, nil) != .floating(1.0, nil))
        #expect(GMNTag.Parameter.Value.integer(1, nil) != .string("1"))
    }

    @Test
    func caseSetIsExactlyFive() {
        // The switch in `tagParameterValueLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(tagParameterValueLabel(.floating(1.5, nil)) == "floating")
        #expect(tagParameterValueLabel(.integer(1, nil)) == "integer")
        #expect(tagParameterValueLabel(.parameter("dx")) == "parameter")
        #expect(tagParameterValueLabel(.string("x")) == "string")
        #expect(tagParameterValueLabel(.variable(GMNVariable.Name("x"))) == "variable")
    }

    @Test
    func equatable_unitIsPartOfTheValue() {
        // A length is its number *and* its unit; `2hs` and `2pt` are not the
        // same value.
        #expect(GMNTag.Parameter.Value.integer(2, .hs) == .integer(2, .hs))
        #expect(GMNTag.Parameter.Value.integer(2, .hs) != .integer(2, .pt))
        #expect(GMNTag.Parameter.Value.integer(2, .hs) != .integer(2, nil))
    }

    @Test
    func number_carriesTheUnitThrough() {
        #expect(GMNTag.Parameter.Value.number(2.0, unit: .hs) == .integer(2, .hs))
        #expect(GMNTag.Parameter.Value.number(2.5, unit: .hs) == .floating(2.5, .hs))
    }

    @Test
    func number_integralValueBecomesAnInteger() {
        // A written `1.0` is the integer 1: guidolib reads the slot by kind,
        // and keeping the float would spell it back out with a stray `.0`.
        #expect(GMNTag.Parameter.Value.number(1.0) == .integer(1, nil))
        #expect(GMNTag.Parameter.Value.number(-3.0) == .integer(-3, nil))
        #expect(GMNTag.Parameter.Value.number(0.0) == .integer(0, nil))
    }

    @Test
    func number_nonIntegralValueStaysFloating() {
        #expect(GMNTag.Parameter.Value.number(1.5) == .floating(1.5, nil))
    }

    @Test
    func number_valueTooLargeForAnIntStaysFloating() {
        // `Int(exactly:)` declines, and the guard falls through rather than
        // trapping.
        #expect(GMNTag.Parameter.Value.number(1e30) == .floating(1e30, nil))
    }
}
