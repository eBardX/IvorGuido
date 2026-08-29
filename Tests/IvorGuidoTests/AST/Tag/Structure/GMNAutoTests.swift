// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNAutoTests {
}

// MARK: -

extension GMNAutoTests {
    @Test
    func bindsPositionally() throws {
        guard case let .auto(auto) = try normalizedTag("[\\auto<\"off\",\"on\">]")
        else {
            Issue.record("Expected auto tag")
            return
        }

        #expect(auto.endBar == "off")
        #expect(auto.pageBreak == "on")
    }

    @Test
    func canonicalNameIsAuto() {
        #expect(GMNAuto().name == makeTagName("auto"))
    }

    @Test
    func equatable() {
        let a = GMNAuto(endBar: "off")
        let b = GMNAuto(endBar: "off")
        let c = GMNAuto(autoEndBar: "off")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let auto = GMNAuto()

        #expect(auto.appearance.isEmpty)
        #expect(auto.body.isEmpty)
        #expect(auto.endBar == nil)
        #expect(auto.fingeringSize == nil)
        #expect(auto.ident == nil)
        #expect(auto.resolveMultiVoiceCollisions == nil)
    }

    @Test
    func keepsBothSpellingsOfOneSetting() throws {
        // `ARAuto` reads the pair as `getParameter<T>(autoEndBar, endBar)`
        // (`ARAuto.cpp:47`), so both names are real and neither is folded onto
        // the other.
        guard case let .auto(auto) = try normalizedTag("[\\auto<endBar=\"off\",autoEndBar=\"on\">]")
        else {
            Issue.record("Expected auto tag")
            return
        }

        #expect(auto.endBar == "off")
        #expect(auto.autoEndBar == "on")
    }

    @Test
    func parameterValues_everySettingWritten() {
        // All twenty-three settings at once: each maps to its own key, and
        // `fingeringSize` is the lone `F` parameter, so it is the lone
        // `.number` among twenty-two `.string`s.
        let auto = GMNAuto(endBar: "off",
                           pageBreak: "on",
                           systemBreak: "off",
                           clefKeyMeterOrder: "on",
                           stretchLastLine: "off",
                           stretchFirstLine: "on",
                           lyricsAutoPos: "off",
                           instrAutoPos: "on",
                           intensAutoPos: "off",
                           autoEndBar: "on",
                           autoPageBreak: "off",
                           autoSystemBreak: "on",
                           autoClefKeyMeterOrder: "off",
                           autoStretchLastLine: "on",
                           autoStretchFirstLine: "off",
                           autoInstrPos: "on",
                           autoLyricsPos: "off",
                           autoIntensPos: "on",
                           fingeringPos: "above",
                           fingeringSize: 0.8,
                           harmonyPos: "below",
                           autoHideTiedAccidentals: "on",
                           resolveMultiVoiceCollisions: "off")
        let values = auto.parameterValues

        #expect(values.count == 23)
        #expect(values["autoClefKeyMeterOrder"] == .string("off"))
        #expect(values["autoEndBar"] == .string("on"))
        #expect(values["autoHideTiedAccidentals"] == .string("on"))
        #expect(values["autoInstrPos"] == .string("on"))
        #expect(values["autoIntensPos"] == .string("on"))
        #expect(values["autoLyricsPos"] == .string("off"))
        #expect(values["autoPageBreak"] == .string("off"))
        #expect(values["autoStretchFirstLine"] == .string("off"))
        #expect(values["autoStretchLastLine"] == .string("on"))
        #expect(values["autoSystemBreak"] == .string("on"))
        #expect(values["clefKeyMeterOrder"] == .string("on"))
        #expect(values["endBar"] == .string("off"))
        #expect(values["fingeringPos"] == .string("above"))
        #expect(values["fingeringSize"] == .number(0.8))
        #expect(values["harmonyPos"] == .string("below"))
        #expect(values["instrAutoPos"] == .string("on"))
        #expect(values["intensAutoPos"] == .string("off"))
        #expect(values["lyricsAutoPos"] == .string("off"))
        #expect(values["pageBreak"] == .string("on"))
        #expect(values["resolveMultiVoiceCollisions"] == .string("off"))
        #expect(values["stretchFirstLine"] == .string("on"))
        #expect(values["stretchLastLine"] == .string("off"))
        #expect(values["systemBreak"] == .string("off"))
    }

    @Test
    func parameterValues_nothingWritten() {
        #expect(GMNAuto().parameterValues.isEmpty)
    }

    @Test
    func promotes() throws {
        guard case let .auto(auto) = try normalizedTag("[\\auto<endBar=\"off\",fingeringSize=0.8>]")
        else {
            Issue.record("Expected auto tag")
            return
        }

        #expect(auto.endBar == "off")
        #expect(auto.fingeringSize == 0.8)
        #expect(auto.autoEndBar == nil)
    }

    @Test
    func promotesTheSetSpelling() throws {
        // `\set` builds a bare `ARAuto` exactly as `\auto` does
        // (`ARFactory.cpp:1322–1327`), so the two are the same tag.
        guard case let .auto(auto) = try normalizedTag("[\\set<pageBreak=\"off\">]")
        else {
            Issue.record("Expected auto tag")
            return
        }

        #expect(auto.name == makeTagName("auto"))
        #expect(auto.pageBreak == "off")
    }
}
