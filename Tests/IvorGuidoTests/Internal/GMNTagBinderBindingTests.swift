// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// The three questions a binding answers *after* binding has happened: what
// bound, what bound to a slot it cannot be read as, and what cannot be read
// at all. The distinction matters because the normalizer treats them
// differently — an ill-typed value is repaired, an unrepresentable one is
// refused.
struct GMNTagBinderBindingTests {
}

// MARK: -

extension GMNTagBinderBindingTests {
    @Test
    func failure_isNilWhenEverythingBound() {
        #expect(makeBinding("clef", [makeTagParameter(.string("treble"))]).failure == nil)
    }

    @Test
    func failure_recordsAnUnboundPositional() {
        // `\clef` overrides `getParamsStr()`, so it has exactly one
        // positional slot and a second unnamed parameter has nowhere to go.
        let binding = makeBinding("clef",
                                  [makeTagParameter(.string("treble")),
                                   makeTagParameter(.string("red"))])

        #expect(binding.failure == .unboundPositionalParameter(index: 1))
    }

    @Test
    func illTypedParameterNames_areEmptyWhenEveryValueFits() {
        let binding = makeBinding("clef", [makeTagParameter("type", .string("treble"))])

        #expect(binding.illTypedParameterNames.isEmpty)
    }

    @Test
    func illTypedParameterNames_namesAValueTheSlotCannotRead() {
        // `type` is an `S` slot, so an integer written there bound fine but
        // reads as the wrong kind.
        let binding = makeBinding("clef", [makeTagParameter("type", .integer(1, nil))])

        #expect(binding.illTypedParameterNames == ["type"])
    }

    @Test
    func template_isTheOneTheNameDispatchesTo() {
        #expect(makeBinding("clef", []).template.supportedParameter(named: "type") != nil)
    }

    @Test
    func unrepresentableParameterNames_namesAUnitOnANonLengthSlot() {
        // `size` is an `F` slot, so it reads the number but has nowhere to
        // put the unit — keeping it would silently change the value.
        let binding = makeBinding("clef", [makeTagParameter("size", .integer(2, .hs))])

        #expect(binding.unrepresentableParameterNames == ["size"])
    }

    @Test
    func unrepresentableParameterNames_namesAVariableReference() {
        // A `$x` that survived to binding has no value yet, so no typed
        // field can hold it.
        let binding = makeBinding("clef",
                                  [makeTagParameter("type", .variable(GMNVariable.Name("x")))])

        #expect(binding.unrepresentableParameterNames == ["type"])
    }

    @Test
    func values_areKeyedByTheSlotTheyBoundTo() {
        let binding = makeBinding("clef", [makeTagParameter(.string("treble"))])

        #expect(binding.values["type"] == .string("treble"))
    }
}
