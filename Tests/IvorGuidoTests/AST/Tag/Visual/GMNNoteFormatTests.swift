// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNNoteFormatTests {
}

// MARK: -

extension GMNNoteFormatTests {
    @Test
    func canonicalName() {
        #expect(GMNNoteFormat().name == makeTagName("noteFormat"))
    }

    @Test
    func equatable() {
        let a = GMNNoteFormat(style: "diamond")
        let b = GMNNoteFormat(style: "diamond")
        let c = GMNNoteFormat(style: "cross")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let format = GMNNoteFormat()

        #expect(format.appearance.isEmpty)
        #expect(format.body.isEmpty)
        #expect(format.ident == nil)
        #expect(format.style == nil)
    }

    @Test
    func theStyleBindsPositionally() throws {
        guard case let .noteFormat(format) = try normalizedTag("[\\noteFormat<\"diamond\">(c d)]")
        else {
            Issue.record("Expected note-format tag")
            return
        }

        #expect(format.style == "diamond")
        #expect(format.body.count == 2)
    }

    @Test
    func theStyleVocabularyIsOpen() throws {
        // guidolib assigns it straight through to `mStyle` and resolves it
        // against a glyph table only at rendering time, so an unrecognized
        // style is preserved rather than refused.
        guard case let .noteFormat(format) = try normalizedTag("[\\noteFormat<\"banana\">]")
        else {
            Issue.record("Expected note-format tag")
            return
        }

        #expect(format.style == "banana")
    }
}
