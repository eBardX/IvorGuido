// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagTests {
}

// MARK: -

extension GMNTagTests {
    @Test
    func equatable() {
        let tag1 = GMNTag(name: "\\slur", ident: nil, parameters: [], symbols: [])
        let tag2 = GMNTag(name: "\\slur", ident: nil, parameters: [], symbols: [])
        let tag3 = GMNTag(name: "\\tie", ident: nil, parameters: [], symbols: [])

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func equatable_ident() {
        let tag1 = GMNTag(name: "\\slur", ident: 1, parameters: [], symbols: [])
        let tag2 = GMNTag(name: "\\slur", ident: 2, parameters: [], symbols: [])

        #expect(tag1 != tag2)
    }

    @Test
    func `init`() {
        let tag = GMNTag(name: "\\slur", ident: nil, parameters: [], symbols: [])

        #expect(tag.name == "\\slur")
        #expect(tag.ident == nil)
        #expect(tag.parameters.isEmpty)
        #expect(tag.symbols.isEmpty)
    }

    @Test
    func init_withIdent() {
        let tag = GMNTag(name: "\\tieBegin", ident: 1, parameters: [], symbols: [])

        #expect(tag.name == "\\tieBegin")
        #expect(tag.ident == 1)
    }

    @Test
    func init_withParameters() {
        let param = GMNTag.Parameter.integer("dx", 5, .hs)
        let tag = GMNTag(name: "\\staffFormat", ident: nil, parameters: [param], symbols: [])

        #expect(tag.parameters.count == 1)
        #expect(tag.parameters.first == param)
    }

    @Test
    func init_withSymbols() {
        let note = GMNNote(pitch: GMNPitch(letter: .c, accidental: .natural, octave: 4),
                           duration: fdur(1, 4))
        let tag = GMNTag(name: "\\slur", ident: nil, parameters: [], symbols: [.note(note)])

        #expect(tag.symbols.count == 1)
    }
}
