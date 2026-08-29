// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNLyricsTests {
}

// MARK: -

extension GMNLyricsTests {
    @Test
    func aBareLyricsTagIsRejected() {
        expectRejected("[\\lyrics(c)]",
                       .missingRequiredParameter(makeTagName("lyrics"), "text"))
    }

    @Test
    func canonicalName() {
        #expect(GMNLyrics(text: "la").name == makeTagName("lyrics"))
    }

    @Test
    func equatable() {
        let a = GMNLyrics(text: "la")
        let b = GMNLyrics(text: "la")
        let c = GMNLyrics(text: "la", autopos: "on")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let lyrics = GMNLyrics(text: "la")

        #expect(lyrics.appearance.isEmpty)
        #expect(lyrics.autopos == nil)
        #expect(lyrics.body.isEmpty)
        #expect(lyrics.ident == nil)
        #expect(lyrics.text == "la")
        #expect(lyrics.textStyle.isEmpty)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        // The five slots are `text`, `dy`, `textformat`, `fsize`, `autopos` —
        // and `dy` lands in the appearance while `textformat` and `fsize` land
        // in the text style, because that is where those names live for every
        // other tag too.
        guard case let .lyrics(lyrics) =
              try normalizedTag("[\\lyrics<\"la-la\",-4hs,\"cb\",10pt,\"on\">(c d)]")
        else {
            Issue.record("Expected lyrics tag")
            return
        }

        #expect(lyrics.appearance.dy == GMNLength(-4, unit: .hs))
        #expect(lyrics.autopos == "on")
        #expect(lyrics.body.count == 2)
        #expect(lyrics.text == "la-la")
        #expect(lyrics.textStyle.fontSize == GMNLength(10, unit: .pt))
        #expect(lyrics.textStyle.textFormat == "cb")
    }
}
