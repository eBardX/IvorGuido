// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNInstrumentTests {
}

// MARK: -

extension GMNInstrumentTests {
    @Test
    func canonicalNameIsInstrument() {
        #expect(GMNInstrument(name: "Flute").name == makeTagName("instrument"))
    }

    @Test
    func equatable() {
        let a = GMNInstrument(name: "Flute")
        let b = GMNInstrument(name: "Flute")
        let c = GMNInstrument(name: "Oboe")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsOptionalsToEmpty() {
        let instrument = GMNInstrument(name: "Flute")

        #expect(instrument.appearance.isEmpty)
        #expect(instrument.autopos == nil)
        #expect(instrument.body.isEmpty)
        #expect(instrument.ident == nil)
        #expect(instrument.instrumentName == "Flute")
        #expect(instrument.midi == nil)
        #expect(instrument.repeats == nil)
        #expect(instrument.textStyle.isEmpty)
        #expect(instrument.transp == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredName() {
        expectRejected("[\\instrument]",
                       .missingRequiredParameter(makeTagName("instrument"), "name"))
    }

    @Test
    func promotes() throws {
        guard case let .instrument(instrument) = try normalizedTag("[\\instrument<\"Clarinet\",\"-2\",MIDI=71>]")
        else {
            Issue.record("Expected instrument tag")
            return
        }

        #expect(instrument.instrumentName == "Clarinet")
        #expect(instrument.transp == "-2")
        #expect(instrument.midi == 71)
    }

    @Test
    func promotesFromTheAlias() throws {
        guard case let .instrument(instrument) = try normalizedTag("[\\instr<\"Horn\">]")
        else {
            Issue.record("Expected instrument tag")
            return
        }

        #expect(instrument.name == makeTagName("instrument"))
        #expect(instrument.instrumentName == "Horn")
    }

    @Test
    func readsTheRepeatParameterDespiteTheKeyword() throws {
        guard case let .instrument(instrument) = try normalizedTag("[\\instrument<\"Horn\",repeat=\"on\">]")
        else {
            Issue.record("Expected instrument tag")
            return
        }

        #expect(instrument.repeats == "on")
    }
}
