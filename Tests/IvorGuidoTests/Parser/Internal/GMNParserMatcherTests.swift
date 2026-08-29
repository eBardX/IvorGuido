// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// The matcher is the parser's whole grammar; `GMNParser` only feeds it bytes
// and hands back what it produced. These cases drive it directly, so a
// failure names the grammar rather than the entry point.
struct GMNParserMatcherTests {
}

// MARK: -

extension GMNParserMatcherTests {
    @Test
    func diagnostics_startEmpty() throws {
        let matcher = try matcher("[c]")

        #expect(matcher.diagnostics.isEmpty)
    }

    @Test
    func matchScore_collectsVariablesAndVoices() throws {
        var matcher = try matcher("$x = 1; [c d]")
        let (score, _) = try matcher.matchScore()

        #expect(score.variables.count == 1)
        #expect(score.voices.count == 1)
    }

    @Test
    func matchScore_multipleVoices() throws {
        var matcher = try matcher("{[c d], [e f]}")
        let (score, _) = try matcher.matchScore()

        #expect(score.voices.count == 2)
    }

    @Test
    func matchScore_trailingGarbageThrows() throws {
        var matcher = try matcher("[c d] )")

        #expect(throws: GMNParser.Error.trailingGarbage) {
            _ = try matcher.matchScore()
        }
    }

    @Test
    func matchSymbolsExhaustively_readsABareSymbolRun() throws {
        var matcher = try matcher("c d e")
        let symbols = try matcher.matchSymbolsExhaustively()

        #expect(symbols.count == 3)
    }

    @Test
    func matchSymbolsExhaustively_trailingGarbageThrows() throws {
        var matcher = try matcher("c d ]")

        #expect(throws: GMNParser.Error.trailingGarbage) {
            _ = try matcher.matchSymbolsExhaustively()
        }
    }
}
