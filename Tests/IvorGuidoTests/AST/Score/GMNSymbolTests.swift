// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNSymbolTests {
}

// MARK: -

extension GMNSymbolTests {
    @Test
    func equatable() {
        let note1 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let note2 = makeNote(makePitch(.c, 4),
                             makeDuration(1, 4))
        let var1: GMNVariable.Name = "x"
        let var2: GMNVariable.Name = "x"

        #expect(GMNSymbol.note(note1) == GMNSymbol.note(note2))
        #expect(GMNSymbol.variable(var1) == GMNSymbol.variable(var2))
        #expect(GMNSymbol.note(note1) != GMNSymbol.variable(var1))
    }

    @Test
    func isMusic_chord() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let segment = makeChordSegment([.note(note)])
        let chord = makeChord([segment])
        let symbol = GMNSymbol.chord(chord)

        #expect(symbol.isMusic)
    }

    @Test
    func isMusic_note() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))

        #expect(GMNSymbol.note(note).isMusic)
    }

    @Test
    func isMusic_rest() {
        let rest = makeRest(makeDuration(1, 4))

        #expect(GMNSymbol.rest(rest).isMusic)
    }

    @Test
    func isMusic_tablature() {
        let tab = makeTablature(1, "5", makeDuration(1, 4))

        #expect(GMNSymbol.tablature(tab).isMusic)
    }

    @Test
    func isMusic_tagWithMusic() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let tag = makeTag(makeTagName("slur"), body: [.note(note)])

        #expect(GMNSymbol.tag(tag).isMusic)
    }

    @Test
    func isMusic_tagWithoutMusic() {
        let tag = makeTag(makeTagName("tempo"))

        #expect(!GMNSymbol.tag(tag).isMusic)
    }

    @Test
    func isMusic_variable() {
        #expect(!GMNSymbol.variable("x").isMusic)
    }
}
