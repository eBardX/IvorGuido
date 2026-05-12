// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNVariableTests {
}

// MARK: -

extension GMNVariableTests {
    @Test
    func equatable() {
        let var1 = GMNVariable(name: "$x", value: .integer(42))
        let var2 = GMNVariable(name: "$x", value: .integer(42))
        let var3 = GMNVariable(name: "$y", value: .integer(42))

        #expect(var1 == var2)
        #expect(var1 != var3)
    }

    @Test
    func equatable_value() {
        let int1a = GMNVariable.Value.integer(42)
        let int1b = GMNVariable.Value.integer(42)
        let int2 = GMNVariable.Value.integer(99)
        let flt1a = GMNVariable.Value.floating(3.14)
        let flt1b = GMNVariable.Value.floating(3.14)
        let str1a = GMNVariable.Value.string("hi")
        let str1b = GMNVariable.Value.string("hi")

        #expect(int1a == int1b)
        #expect(int1a != int2)
        #expect(flt1a == flt1b)
        #expect(str1a == str1b)
        #expect(int1a != flt1a)
    }

    @Test
    func init_floating() {
        let variable = GMNVariable(name: "$pi", value: .floating(3.14))

        #expect(variable.name == "$pi")

        guard case let .floating(value) = variable.value
        else {
            Issue.record("Expected floating value")
            return
        }

        #expect(value == 3.14)
    }

    @Test
    func init_integer() {
        let variable = GMNVariable(name: "$tempo", value: .integer(120))

        #expect(variable.name == "$tempo")

        guard case let .integer(value) = variable.value
        else {
            Issue.record("Expected integer value")
            return
        }

        #expect(value == 120)
    }

    @Test
    func init_string() {
        let variable = GMNVariable(name: "$title", value: .string("My Song"))

        #expect(variable.name == "$title")

        guard case let .string(value) = variable.value
        else {
            Issue.record("Expected string value")
            return
        }

        #expect(value == "My Song")
    }

    @Test
    func value_crossCaseInequality() {
        let intVal = GMNVariable.Value.integer(1)
        let fltVal = GMNVariable.Value.floating(1.0)
        let strVal = GMNVariable.Value.string("1")

        #expect(intVal != fltVal)
        #expect(intVal != strVal)
        #expect(fltVal != strVal)
    }
}
