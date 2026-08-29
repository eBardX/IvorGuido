// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNArticulationKindTests {
}

// MARK: -

extension GMNArticulationKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNArticulation.Kind.accent == .accent)
        #expect(GMNArticulation.Kind.accent != .bow)
    }

    @Test
    func caseSetIsExactlyEight() {
        // The switch in `articulationKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(articulationKindLabel(.accent) == "accent")
        #expect(articulationKindLabel(.bow) == "bow")
        #expect(articulationKindLabel(.fermata) == "fermata")
        #expect(articulationKindLabel(.harmonic) == "harmonic")
        #expect(articulationKindLabel(.marcato) == "marcato")
        #expect(articulationKindLabel(.pizzicato) == "pizzicato")
        #expect(articulationKindLabel(.staccato) == "staccato")
        #expect(articulationKindLabel(.tenuto) == "tenuto")
    }

    @Test
    func kind_aliasTagName() {
        // guidolib spells several of these more than one way; each
        // alias lands on the same case as its canonical name.
        #expect(GMNArticulation.Kind.kind(forTagName: "pizz") == .pizzicato)
        #expect(GMNArticulation.Kind.kind(forTagName: "stacc") == .staccato)
        #expect(GMNArticulation.Kind.kind(forTagName: "staccBegin") == .staccato)
        #expect(GMNArticulation.Kind.kind(forTagName: "staccEnd") == .staccato)
        #expect(GMNArticulation.Kind.kind(forTagName: "ten") == .tenuto)
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNArticulation.Kind.kind(forTagName: "accent") == .accent)
        #expect(GMNArticulation.Kind.kind(forTagName: "bow") == .bow)
        #expect(GMNArticulation.Kind.kind(forTagName: "fermata") == .fermata)
        #expect(GMNArticulation.Kind.kind(forTagName: "harmonic") == .harmonic)
        #expect(GMNArticulation.Kind.kind(forTagName: "marcato") == .marcato)
        #expect(GMNArticulation.Kind.kind(forTagName: "pizzicato") == .pizzicato)
        #expect(GMNArticulation.Kind.kind(forTagName: "staccato") == .staccato)
        #expect(GMNArticulation.Kind.kind(forTagName: "tenuto") == .tenuto)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNArticulation.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNArticulation.Kind.accent.tagName == "accent")
        #expect(GMNArticulation.Kind.bow.tagName == "bow")
        #expect(GMNArticulation.Kind.fermata.tagName == "fermata")
        #expect(GMNArticulation.Kind.harmonic.tagName == "harmonic")
        #expect(GMNArticulation.Kind.marcato.tagName == "marcato")
        #expect(GMNArticulation.Kind.pizzicato.tagName == "pizzicato")
        #expect(GMNArticulation.Kind.staccato.tagName == "staccato")
        #expect(GMNArticulation.Kind.tenuto.tagName == "tenuto")
    }
}
