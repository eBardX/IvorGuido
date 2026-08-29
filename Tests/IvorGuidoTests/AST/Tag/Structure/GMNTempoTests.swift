// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTempoTests {
}

// MARK: -

extension GMNTempoTests {
    @Test
    func canonicalNameIsTempo() {
        #expect(GMNTempo(tempo: "Allegro").name == makeTagName("tempo"))
    }

    @Test
    func equatable() {
        let a = GMNTempo(tempo: "Allegro")
        let b = GMNTempo(tempo: "Allegro")
        let c = GMNTempo(tempo: "Adagio")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let tempo = GMNTempo(tempo: "Allegro")

        #expect(tempo.appearance.isEmpty)
        #expect(tempo.metronome == nil)
        #expect(tempo.body.isEmpty)
        #expect(tempo.ident == nil)
        #expect(tempo.tempo == "Allegro")
        #expect(tempo.textStyle.isEmpty)
    }

    @Test
    func isRejectedWhenTheBpmCannotBeRead() {
        // FLIPPED IN PHASE 3. A `bpm` that will not parse is still a
        // well-typed string, so the normalizer cannot drop it and declining
        // to promote was all that kept it. guidolib's own answer is to warn
        // and render a tempo with no rate in it (`ARTempo::ParseBpm`), which
        // is the loss this now refuses instead.
        expectRejected("[\\tempo<\"Allegro\",\"quickish\">]",
                       .unreadableParameterValue(makeTagName("tempo")))
    }

    @Test
    func isRejectedWithoutTheRequiredText() {
        expectRejected("[\\tempo]",
                       .missingRequiredParameter(makeTagName("tempo"), "tempo"))
    }

    @Test
    func promotes() throws {
        guard case let .tempo(tempo) = try normalizedTag("[\\tempo<\"Allegro\",\"1/4=120\",fsize=13pt>]")
        else {
            Issue.record("Expected tempo tag")
            return
        }

        #expect(tempo.metronome == .rate(unit: GMNTempo.Metronome.BeatUnit(1, 4).require(),
                                         beats: 120))
        #expect(tempo.tempo == "Allegro")
        #expect(tempo.textStyle.fontSize == GMNLength(13, unit: .pt))
    }
}
