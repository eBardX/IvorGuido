// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNVariableValueTests {
}

// MARK: -

extension GMNVariableValueTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNVariable.Value.integer(1) == .integer(1))
        #expect(GMNVariable.Value.integer(1) != .integer(2))
        #expect(GMNVariable.Value.integer(1) != .floating(1.0))
        #expect(GMNVariable.Value.integer(1) != .string("1"))
    }

    @Test
    func caseSetIsExactlyThree() {
        // The switch in `variableValueLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(variableValueLabel(.floating(1.5)) == "floating")
        #expect(variableValueLabel(.integer(2)) == "integer")
        #expect(variableValueLabel(.string("x")) == "string")
    }

    @Test
    func floating_carriesItsValue() {
        guard case let .floating(value) = GMNVariable.Value.floating(2.5)
        else {
            Issue.record("Expected a floating value")

            return
        }

        #expect(value == 2.5)
    }

    @Test
    func integer_carriesItsValue() {
        guard case let .integer(value) = GMNVariable.Value.integer(-3)
        else {
            Issue.record("Expected an integer value")

            return
        }

        #expect(value == -3)
    }

    @Test
    func string_carriesItsValue() {
        guard case let .string(value) = GMNVariable.Value.string("Allegro")
        else {
            Issue.record("Expected a string value")

            return
        }

        #expect(value == "Allegro")
    }
}
