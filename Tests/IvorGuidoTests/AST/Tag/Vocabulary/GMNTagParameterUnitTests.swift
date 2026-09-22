// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagParameterUnitTests {
}

// MARK: -

extension GMNTagParameterUnitTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTag.Parameter.Unit.hs == .hs)
        #expect(GMNTag.Parameter.Unit.hs != .pt)
    }

    @Test
    func caseSetIsExactlyEight() {
        // The switch in `tagParameterUnitLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(tagParameterUnitLabel(.cm) == "cm")
        #expect(tagParameterUnitLabel(.hs) == "hs")
        #expect(tagParameterUnitLabel(.in) == "in")
        #expect(tagParameterUnitLabel(.m) == "m")
        #expect(tagParameterUnitLabel(.mm) == "mm")
        #expect(tagParameterUnitLabel(.pc) == "pc")
        #expect(tagParameterUnitLabel(.pt) == "pt")
        #expect(tagParameterUnitLabel(.rl) == "rl")
    }

    @Test
    func init_rawValueRoundTrips() {
        #expect(GMNTag.Parameter.Unit(rawValue: "cm") == .cm)
        #expect(GMNTag.Parameter.Unit(rawValue: "hs") == .hs)
        #expect(GMNTag.Parameter.Unit(rawValue: "in") == .in)
        #expect(GMNTag.Parameter.Unit(rawValue: "m") == .m)
        #expect(GMNTag.Parameter.Unit(rawValue: "mm") == .mm)
        #expect(GMNTag.Parameter.Unit(rawValue: "pc") == .pc)
        #expect(GMNTag.Parameter.Unit(rawValue: "pt") == .pt)
        #expect(GMNTag.Parameter.Unit(rawValue: "rl") == .rl)
    }

    @Test
    func init_unknownRawValue() {
        #expect(GMNTag.Parameter.Unit(rawValue: "bembel") == nil)
    }

    @Test
    func rawValue() {
        // `in` is spelled with a backtick in Swift but is plain "in" in GMN.
        #expect(GMNTag.Parameter.Unit.cm.rawValue == "cm")
        #expect(GMNTag.Parameter.Unit.hs.rawValue == "hs")
        #expect(GMNTag.Parameter.Unit.in.rawValue == "in")
        #expect(GMNTag.Parameter.Unit.m.rawValue == "m")
        #expect(GMNTag.Parameter.Unit.mm.rawValue == "mm")
        #expect(GMNTag.Parameter.Unit.pc.rawValue == "pc")
        #expect(GMNTag.Parameter.Unit.pt.rawValue == "pt")
        #expect(GMNTag.Parameter.Unit.rl.rawValue == "rl")
    }
}
