// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNMeterTests {
}

// MARK: -

extension GMNMeterTests {
    @Test
    func absentOptionDiffersFromWrittenDefault() {
        #expect(GMNMeter(type: "4/4") != GMNMeter(type: "4/4", autoBarlines: "on"))
    }

    @Test
    func canonicalNameIsMeter() {
        #expect(GMNMeter(type: "4/4").name == makeTagName("meter"))
    }

    @Test
    func equatable() {
        let a = GMNMeter(type: "4/4")
        let b = GMNMeter(type: "4/4")
        let c = GMNMeter(type: "3/4")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEveryOptionToNil() {
        let meter = GMNMeter(type: "6/8")

        #expect(meter.appearance.isEmpty)
        #expect(meter.autoBarlines == nil)
        #expect(meter.autoMeasuresNum == nil)
        #expect(meter.body.isEmpty)
        #expect(meter.group == nil)
        #expect(meter.hidden == nil)
        #expect(meter.type == "6/8")
    }

    @Test
    func init_fromBindingRequiresType() {
        #expect(GMNMeter(ident: nil,
                         binding: makeBinding("meter"),
                         body: []) == nil)
    }

    @Test
    func promotes() throws {
        guard case let .meter(meter) = try normalizedTag("[\\meter<\"2+3/8\",autoBarlines=\"off\"> c]")
        else {
            Issue.record("Expected meter tag")
            return
        }

        #expect(meter.autoBarlines == "off")
        #expect(meter.type == "2+3/8")
    }

    @Test
    func promotionIsOrderIndependent() throws {
        // Once bound, the order the parameters were written in carries
        // nothing, so both spellings give the same payload.
        #expect(try normalizedTag("[\\meter<autoBarlines=\"off\",type=\"4/4\"> c]")
            == normalizedTag("[\\meter<\"4/4\",autoBarlines=\"off\"> c]"))
    }
}
