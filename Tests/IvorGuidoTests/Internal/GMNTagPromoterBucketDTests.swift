// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// Bucket D is the appearance lane: tags that change how something is drawn
// without adding an event or a decoration.
struct GMNTagPromoterBucketDTests {
}

// MARK: -

extension GMNTagPromoterBucketDTests {
    @Test
    func promoteBucketD_color() {
        guard case .color = promoteBucketD("color", [makeTagParameter(.string("red"))])
        else {
            Issue.record("Expected a color tag")

            return
        }
    }

    @Test
    func promoteBucketD_declinesANameFromAnotherBucket() {
        // `\arpeggio` is bucket C, and bucket D must not claim it.
        #expect(promoteBucketD("arpeggio") == nil)
    }

    @Test
    func promoteBucketD_dotFormat() {
        guard case .dotFormat = promoteBucketD("dotFormat")
        else {
            Issue.record("Expected a dot-format tag")

            return
        }
    }

    @Test
    func promoteBucketD_lyrics() {
        guard case .lyrics = promoteBucketD("lyrics", [makeTagParameter("text", .string("la"))])
        else {
            Issue.record("Expected a lyrics tag")

            return
        }
    }

    @Test
    func promoteBucketD_mark() {
        guard case .mark = promoteBucketD("mark", [makeTagParameter("text", .string("A"))])
        else {
            Issue.record("Expected a mark tag")

            return
        }
    }

    @Test
    func promoteBucketD_noteFormat() {
        guard case .noteFormat = promoteBucketD("noteFormat")
        else {
            Issue.record("Expected a note-format tag")

            return
        }
    }

    @Test
    func promoteBucketD_restFormat() {
        guard case .restFormat = promoteBucketD("restFormat")
        else {
            Issue.record("Expected a rest-format tag")

            return
        }
    }

    @Test
    func promoteBucketD_special() {
        guard case .special = promoteBucketD("special", [makeTagParameter("char", .string("x"))])
        else {
            Issue.record("Expected a special tag")

            return
        }
    }

    @Test
    func promoteBucketD_symbolAliasesLandOnOnePayload() {
        // `\\s` abbreviates `\\symbol`, not `\\special` — the two are
        // different payloads and the one-letter name belongs to the former.
        for name in ["s", "symbol"] {
            guard case .graphicSymbol = promoteBucketD(name, [makeTagParameter("file", .string("x.png"))])
            else {
                Issue.record("Expected a graphic-symbol tag for \\(name)")

                return
            }
        }
    }
}
