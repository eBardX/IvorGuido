// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

struct GMNFormatterWriterTests {
}

// MARK: -

extension GMNFormatterWriterTests {
    @Test
    func writeScore_multipleVoices_bracedAndCommaSeparated() {
        let note1 = makeNote(makePitch(.c))
        let note2 = makeNote(makePitch(.d))
        let voice1 = makeVoice([.note(note1)])
        let voice2 = makeVoice([.note(note2)])
        let score = makeScore([], [voice1, voice2])
        var writer = GMNFormatter.Writer(score: score)

        #expect(String(data: writer.writeScore(), encoding: .utf8) == "{[c], [d]}")
    }

    @Test
    func writeScore_singleVoice_noBraces() {
        let note = makeNote(makePitch(.c))
        let voice = makeVoice([.note(note)])
        let score = makeScore([], [voice])
        var writer = GMNFormatter.Writer(score: score)

        #expect(String(data: writer.writeScore(), encoding: .utf8) == "[c]")
    }

    @Test
    func writeScore_variablesPrecedeVoicesOnOwnLines() {
        let variable = makeVariable("x", .integer(3))
        let note = makeNote(makePitch(.c))
        let voice = makeVoice([.note(note)])
        let score = makeScore([variable], [voice])
        var writer = GMNFormatter.Writer(score: score)

        #expect(String(data: writer.writeScore(), encoding: .utf8) == "$x = 3;\n[c]")
    }
}
