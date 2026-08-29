// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagParameterTests {
}

// MARK: -

extension GMNTagParameterTests {
    @Test
    func equatable() {
        let param1a = GMNTag.Parameter(name: "dx", value: .integer(10, .hs))
        let param1b = GMNTag.Parameter(name: "dx", value: .integer(10, .hs))
        let param2 = GMNTag.Parameter(name: "dy", value: .integer(10, .hs))
        let param3 = GMNTag.Parameter(value: .floating(1.0, nil))
        let param4 = GMNTag.Parameter(value: .integer(1, nil))

        #expect(param1a == param1b)
        #expect(param1a != param2)
        #expect(param3 != param4)
    }

    @Test
    func floatingValue_floating() {
        let param = GMNTag.Parameter(name: "tempo", value: .floating(120.0, nil))

        #expect(param.floatingValue == 120.0)
    }

    @Test
    func floatingValue_nonFloating() {
        let param = GMNTag.Parameter(value: .integer(42, nil))

        #expect(param.floatingValue == nil)
    }

    @Test
    func integerValue_integer() {
        let param = GMNTag.Parameter(value: .integer(42, nil))

        #expect(param.integerValue == 42)
    }

    @Test
    func integerValue_nonInteger() {
        let param = GMNTag.Parameter(value: .floating(3.14, nil))

        #expect(param.integerValue == nil)
    }

    @Test
    func name_allCases() {
        #expect(GMNTag.Parameter(name: "a", value: .floating(1.0, nil)).name == "a")
        #expect(GMNTag.Parameter(name: "b", value: .integer(1, nil)).name == "b")
        #expect(GMNTag.Parameter(name: "c", value: .parameter("val")).name == "c")
        #expect(GMNTag.Parameter(name: "d", value: .string("val")).name == "d")
        #expect(GMNTag.Parameter(name: "e", value: .variable("x")).name == "e")
    }

    @Test
    func name_nil() {
        #expect(GMNTag.Parameter(value: .floating(1.0, nil)).name == nil)
        #expect(GMNTag.Parameter(value: .integer(1, nil)).name == nil)
        #expect(GMNTag.Parameter(value: .parameter("val")).name == nil)
        #expect(GMNTag.Parameter(value: .string("val")).name == nil)
        #expect(GMNTag.Parameter(value: .variable("x")).name == nil)
    }

    @Test
    func stringValue_nonString() {
        let param = GMNTag.Parameter(value: .integer(42, nil))

        #expect(param.stringValue == nil)
    }

    @Test
    func stringValue_string() {
        let param = GMNTag.Parameter(value: .string("hello"))

        #expect(param.stringValue == "hello")
    }

    @Test
    func unit_floating() {
        let param = GMNTag.Parameter(value: .floating(2.5, .cm))

        #expect(param.unit == .cm)
    }

    @Test
    func unit_integer() {
        let param = GMNTag.Parameter(value: .integer(10, .hs))

        #expect(param.unit == .hs)
    }

    @Test
    func unit_nonNumeric() {
        #expect(GMNTag.Parameter(value: .parameter("val")).unit == nil)
        #expect(GMNTag.Parameter(value: .string("val")).unit == nil)
        #expect(GMNTag.Parameter(value: .variable("x")).unit == nil)
    }

    @Test
    func unit_rawValues() {
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
