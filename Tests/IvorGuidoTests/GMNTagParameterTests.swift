// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNTagParameterTests {
}

// MARK: -

extension GMNTagParameterTests {
    @Test
    func test_equatable() {
        let param1a = GMNTag.Parameter.integer("dx", 10, .hs)
        let param1b = GMNTag.Parameter.integer("dx", 10, .hs)
        let param2 = GMNTag.Parameter.integer("dy", 10, .hs)
        let param3 = GMNTag.Parameter.floating(nil, 1.0, nil)
        let param4 = GMNTag.Parameter.integer(nil, 1, nil)

        #expect(param1a == param1b)
        #expect(param1a != param2)
        #expect(param3 != param4)
    }

    @Test
    func test_floatingValue_floating() {
        let param = GMNTag.Parameter.floating("tempo", 120.0, nil)

        #expect(param.floatingValue == 120.0)
    }

    @Test
    func test_floatingValue_nonFloating() {
        let param = GMNTag.Parameter.integer(nil, 42, nil)

        #expect(param.floatingValue == nil)
    }

    @Test
    func test_hasNameOrNil_matchingName() {
        let param = GMNTag.Parameter.integer("dx", 10, .hs)

        #expect(param.hasNameOrNil("dx"))
    }

    @Test
    func test_hasNameOrNil_mismatchedName() {
        let param = GMNTag.Parameter.integer("dx", 10, .hs)

        #expect(!param.hasNameOrNil("dy"))
    }

    @Test
    func test_hasNameOrNil_nilName() {
        let param = GMNTag.Parameter.integer(nil, 10, nil)

        #expect(param.hasNameOrNil("anything"))
    }

    @Test
    func test_integerValue_integer() {
        let param = GMNTag.Parameter.integer(nil, 42, nil)

        #expect(param.integerValue == 42)
    }

    @Test
    func test_integerValue_nonInteger() {
        let param = GMNTag.Parameter.floating(nil, 3.14, nil)

        #expect(param.integerValue == nil)
    }

    @Test
    func test_name_allCases() {
        #expect(GMNTag.Parameter.floating("a", 1.0, nil).name == "a")
        #expect(GMNTag.Parameter.integer("b", 1, nil).name == "b")
        #expect(GMNTag.Parameter.parameter("c", "val").name == "c")
        #expect(GMNTag.Parameter.string("d", "val").name == "d")
        #expect(GMNTag.Parameter.variable("e", "$x").name == "e")
    }

    @Test
    func test_name_nil() {
        #expect(GMNTag.Parameter.floating(nil, 1.0, nil).name == nil)
        #expect(GMNTag.Parameter.integer(nil, 1, nil).name == nil)
        #expect(GMNTag.Parameter.parameter(nil, "val").name == nil)
        #expect(GMNTag.Parameter.string(nil, "val").name == nil)
        #expect(GMNTag.Parameter.variable(nil, "$x").name == nil)
    }

    @Test
    func test_stringValue_nonString() {
        let param = GMNTag.Parameter.integer(nil, 42, nil)

        #expect(param.stringValue == nil)
    }

    @Test
    func test_stringValue_string() {
        let param = GMNTag.Parameter.string(nil, "hello")

        #expect(param.stringValue == "hello")
    }

    @Test
    func test_unit_floating() {
        let param = GMNTag.Parameter.floating(nil, 2.5, .cm)

        #expect(param.unit == .cm)
    }

    @Test
    func test_unit_integer() {
        let param = GMNTag.Parameter.integer(nil, 10, .hs)

        #expect(param.unit == .hs)
    }

    @Test
    func test_unit_nonNumeric() {
        #expect(GMNTag.Parameter.parameter(nil, "val").unit == nil)
        #expect(GMNTag.Parameter.string(nil, "val").unit == nil)
        #expect(GMNTag.Parameter.variable(nil, "$x").unit == nil)
    }

    @Test
    func test_unit_rawValues() {
        #expect(GMNTag.Parameter.Unit(rawValue: "cm") == .cm)
        #expect(GMNTag.Parameter.Unit(rawValue: "hs") == .hs)
        #expect(GMNTag.Parameter.Unit(rawValue: "in") == .in)
        #expect(GMNTag.Parameter.Unit(rawValue: "m") == .m)
        #expect(GMNTag.Parameter.Unit(rawValue: "mm") == .mm)
        #expect(GMNTag.Parameter.Unit(rawValue: "pc") == .pc)
        #expect(GMNTag.Parameter.Unit(rawValue: "pt") == .pt)
        #expect(GMNTag.Parameter.Unit(rawValue: "rl") == .rl)
        #expect(GMNTag.Parameter.Unit(rawValue: "xx") == nil)
    }
}
