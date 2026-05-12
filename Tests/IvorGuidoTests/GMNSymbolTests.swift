// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNSymbolTests {
}

// MARK: -

extension GMNSymbolTests {
    @Test
    func equatable() {
        let note1 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let var1 = "$x"
        let var2 = "$x"

        #expect(GMNSymbol.note(note1) == GMNSymbol.note(note2))
        #expect(GMNSymbol.variable(var1) == GMNSymbol.variable(var2))
        #expect(GMNSymbol.note(note1) != GMNSymbol.variable(var1))
    }

    @Test
    func isMusic_chord() throws {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let segment = try #require(GMNChord.Segment(symbols: [.note(note)]))
        let symbol = GMNSymbol.chord(GMNChord(segments: [segment]))

        #expect(symbol.isMusic)
    }

    @Test
    func isMusic_note() {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))

        #expect(GMNSymbol.note(note).isMusic)
    }

    @Test
    func isMusic_rest() {
        let rest = GMNRest(duration: fdur(1, 4))

        #expect(GMNSymbol.rest(rest).isMusic)
    }

    @Test
    func isMusic_tablature() {
        let tab = GMNTablature(tabString: 1,
                               fret: "5",
                               duration: fdur(1, 4))

        #expect(GMNSymbol.tablature(tab).isMusic)
    }

    @Test
    func isMusic_tagWithMusic() {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let tag = GMNTag(name: "\\slur",
                         ident: nil,
                         parameters: [],
                         symbols: [.note(note)])

        #expect(GMNSymbol.tag(tag).isMusic)
    }

    @Test
    func isMusic_tagWithoutMusic() {
        let tag = GMNTag(name: "\\tempo",
                         ident: nil,
                         parameters: [],
                         symbols: [])

        #expect(!GMNSymbol.tag(tag).isMusic)
    }

    @Test
    func isMusic_variable() {
        #expect(!GMNSymbol.variable("$x").isMusic)
    }

    @Test
    func tagValue_nonTag() {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))

        #expect(GMNSymbol.note(note).tagValue == nil)
        #expect(GMNSymbol.rest(GMNRest(duration: fdur(1, 4))).tagValue == nil)
        #expect(GMNSymbol.variable("$x").tagValue == nil)
    }

    @Test
    func tagValue_tag() {
        let tag = GMNTag(name: "\\tempo",
                         ident: nil,
                         parameters: [],
                         symbols: [])

        let result = GMNSymbol.tag(tag).tagValue

        #expect(result != nil)
        #expect(result?.name == "\\tempo")
    }
}
