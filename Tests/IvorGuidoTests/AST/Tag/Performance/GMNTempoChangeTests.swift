// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTempoChangeTests {
}

// MARK: -

extension GMNTempoChangeTests {
    @Test(arguments: [(GMNTempoChange.Direction.accelerando, GMNTag.Span.whole, "accelerando"),
                      (.accelerando, .begin, "accelBegin"),
                      (.accelerando, .end, "accelEnd"),
                      (.ritardando, .whole, "ritardando"),
                      (.ritardando, .begin, "ritBegin"),
                      (.ritardando, .end, "ritEnd")])
    func canonicalNameFollowsTheDirectionAndSpan(_ triple: (direction: GMNTempoChange.Direction,
                                                            span: GMNTag.Span,
                                                            expected: String)) {
        // Both directions are asymmetric: guidolib dispatches only the short
        // spelling for the open halves. The normalizer's alias table used to
        // rewrite these to `\accelerandoBegin` and friends, which name
        // nothing at all — since corrected.
        #expect(GMNTempoChange(direction: triple.direction,
                               span: triple.span).require().name == makeTagName(triple.expected))
    }

    @Test
    func equatable() {
        let a = GMNTempoChange(direction: .accelerando, before: "accel.").require()
        let b = GMNTempoChange(direction: .accelerando, before: "accel.").require()
        let c = GMNTempoChange(direction: .ritardando, before: "accel.").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test(arguments: [("accel", GMNTempoChange.Direction.accelerando),
                      ("accelerando", .accelerando),
                      ("rit", .ritardando),
                      ("ritardando", .ritardando)])
    func everyAliasPromotesToItsDirection(_ pair: (name: String, direction: GMNTempoChange.Direction)) throws {
        guard case let .tempoChange(change) = try normalizedTag("[\\\(pair.name)(c d)]")
        else {
            Issue.record("Expected tempo change tag")
            return
        }

        #expect(change.direction == pair.direction)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let change = GMNTempoChange(direction: .ritardando).require()

        #expect(change.after == nil)
        #expect(change.appearance.isEmpty)
        #expect(change.before == nil)
        #expect(change.body.isEmpty)
        #expect(change.direction == .ritardando)
        #expect(change.dx2 == nil)
        #expect(change.ident == nil)
        #expect(change.span == .whole)
        #expect(change.textStyle.isEmpty)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .tempoChange(change) =
              try normalizedTag("[\\ritardando<\"rit.\",\"a tempo\",2hs,\"Arial\",12pt,\"cc\">(c d)]")
        else {
            Issue.record("Expected tempo change tag")
            return
        }

        #expect(change.after == "a tempo")
        #expect(change.before == "rit.")
        #expect(change.dx2 == GMNLength(2, unit: .hs))
        #expect(change.textStyle.font == "Arial")
        #expect(change.textStyle.fontSize == GMNLength(12, unit: .pt))
        #expect(change.textStyle.textFormat == "cc")
    }

    @Test
    func theFontParametersAreItsOwnSlots() throws {
        // `font`, `fsize`, and `textformat` are `kARFontAbleParams` names
        // this tag redeclares positionally, so they bind by position here
        // where on most font-able tags they would have to be named.
        guard case let .tempoChange(change) = try normalizedTag("[\\accelerando<\"accel.\",\"\",0hs,\"Arial\">(c d)]")
        else {
            Issue.record("Expected tempo change tag")
            return
        }

        #expect(change.textStyle.font == "Arial")
    }
}
