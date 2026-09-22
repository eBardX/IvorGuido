// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagTemplateSlotKindTests {
}

// MARK: -

extension GMNTagTemplateSlotKindTests {
    @Test
    func accepts_float() {
        // `TagParameterInt` derives from `TagParameterFloat`, so an integer
        // satisfies an `F` slot as well as a float.
        #expect(GMNTagTemplate.Slot.Kind.float.accepts(.floating(1.5, nil)))
        #expect(GMNTagTemplate.Slot.Kind.float.accepts(.integer(1, nil)))
        #expect(!GMNTagTemplate.Slot.Kind.float.accepts(.string("1.5")))
    }

    @Test
    func accepts_integer() {
        // The asymmetry runs one way only: a float never satisfies an `I`
        // slot.
        #expect(GMNTagTemplate.Slot.Kind.integer.accepts(.integer(1, nil)))
        #expect(!GMNTagTemplate.Slot.Kind.integer.accepts(.floating(1.5, nil)))
        #expect(!GMNTagTemplate.Slot.Kind.integer.accepts(.string("1")))
    }

    @Test
    func accepts_length() {
        // A `U` slot is `TagParameterFloat(true)` under the hood, so it
        // follows `float`'s acceptance rule, not `integer`'s.
        #expect(GMNTagTemplate.Slot.Kind.length.accepts(.floating(1, .cm)))
        #expect(GMNTagTemplate.Slot.Kind.length.accepts(.integer(1, .cm)))
        #expect(!GMNTagTemplate.Slot.Kind.length.accepts(.string("1cm")))
    }

    @Test
    func accepts_string() {
        #expect(GMNTagTemplate.Slot.Kind.string.accepts(.string("black")))
        #expect(!GMNTagTemplate.Slot.Kind.string.accepts(.integer(1, nil)))
        #expect(!GMNTagTemplate.Slot.Kind.string.accepts(.floating(1.5, nil)))
    }
}
