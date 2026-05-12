// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNVoiceTests {
}

// MARK: -

extension GMNVoiceTests {
    @Test
    func equatable() {
        let note1 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let note2 = GMNNote(pitch: GMNPitch(name: .c, accidental: .natural, octave: 4),
                            duration: fdur(1, 4))
        let voice1 = GMNVoice(symbols: [.note(note1)])
        let voice2 = GMNVoice(symbols: [.note(note2)])
        let voice3 = GMNVoice(symbols: [])

        #expect(voice1 == voice2)
        #expect(voice1 != voice3)
    }

    @Test
    func findAllTags_matchingName() {
        let tag1 = GMNTag(name: "\\slur",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\accent",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag3 = GMNTag(name: "\\slur",
                          ident: 1,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2), .tag(tag3)])

        let result = voice.findAllTags(matching: "\\slur")

        #expect(result.count == 2)
        #expect(result[0].name == "\\slur")
        #expect(result[1].name == "\\slur")
    }

    @Test
    func findAllTags_matchingNames() {
        let tag1 = GMNTag(name: "\\slur",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\accent",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag3 = GMNTag(name: "\\tie",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2), .tag(tag3)])

        let result = voice.findAllTags(matching: ["\\slur", "\\tie"])

        #expect(result.count == 2)
        #expect(result[0].name == "\\slur")
        #expect(result[1].name == "\\tie")
    }

    @Test
    func findAllTags_nested() {
        let innerTag = GMNTag(name: "\\accent",
                              ident: nil,
                              parameters: [],
                              symbols: [])
        let outerTag = GMNTag(name: "\\slur",
                              ident: nil,
                              parameters: [],
                              symbols: [.tag(innerTag)])
        let voice = GMNVoice(symbols: [.tag(outerTag)])

        let result = voice.findAllTags(matching: "\\accent")

        #expect(result.count == 1)
        #expect(result[0].name == "\\accent")
    }

    @Test
    func findAllTags_noMatch() {
        let tag = GMNTag(name: "\\slur",
                         ident: nil,
                         parameters: [],
                         symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag)])

        let result = voice.findAllTags(matching: "\\accent")

        #expect(result.isEmpty)
    }

    @Test
    func findAllTags_wherePredicate() {
        let tag1 = GMNTag(name: "\\slur",
                          ident: 1,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\slur",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2)])

        let result = voice.findAllTags { $0.ident != nil }

        #expect(result.count == 1)
        #expect(result[0].ident == 1)
    }

    @Test
    func findFirstTag_matchingName() {
        let tag1 = GMNTag(name: "\\slur",
                          ident: 1,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\slur",
                          ident: 2,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2)])

        let result = voice.findFirstTag(matching: "\\slur")

        #expect(result != nil)
        #expect(result?.ident == 1)
    }

    @Test
    func findFirstTag_matchingNames() {
        let tag1 = GMNTag(name: "\\accent",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\slur",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2)])

        let result = voice.findFirstTag(matching: ["\\slur", "\\tie"])

        #expect(result != nil)
        #expect(result?.name == "\\slur")
    }

    @Test
    func findFirstTag_nested() {
        let innerTag = GMNTag(name: "\\accent",
                              ident: nil,
                              parameters: [],
                              symbols: [])
        let outerTag = GMNTag(name: "\\slur",
                              ident: nil,
                              parameters: [],
                              symbols: [.tag(innerTag)])
        let voice = GMNVoice(symbols: [.tag(outerTag)])

        let result = voice.findFirstTag(matching: "\\accent")

        #expect(result != nil)
        #expect(result?.name == "\\accent")
    }

    @Test
    func findFirstTag_noMatch() {
        let tag = GMNTag(name: "\\slur",
                         ident: nil,
                         parameters: [],
                         symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag)])

        let result = voice.findFirstTag(matching: "\\accent")

        #expect(result == nil)
    }

    @Test
    func findFirstTag_wherePredicate() {
        let tag1 = GMNTag(name: "\\slur",
                          ident: nil,
                          parameters: [],
                          symbols: [])
        let tag2 = GMNTag(name: "\\accent",
                          ident: 5,
                          parameters: [],
                          symbols: [])
        let voice = GMNVoice(symbols: [.tag(tag1), .tag(tag2)])

        let result = voice.findFirstTag { $0.ident != nil }

        #expect(result != nil)
        #expect(result?.name == "\\accent")
    }

    @Test
    func `init`() {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let voice = GMNVoice(symbols: [.note(note)])

        #expect(voice.symbols.count == 1)
    }

    @Test
    func init_empty() {
        let voice = GMNVoice(symbols: [])

        #expect(voice.symbols.isEmpty)
    }

    @Test
    func noTags() {
        let note = GMNNote(pitch: GMNPitch(name: .c,
                                           accidental: .natural,
                                           octave: 4),
                           duration: fdur(1, 4))
        let voice = GMNVoice(symbols: [.note(note), .variable("$x")])

        #expect(voice.findAllTags(matching: "\\slur").isEmpty)
        #expect(voice.findFirstTag(matching: "\\slur") == nil)
    }
}
