// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTremoloTests {
}

// MARK: -

extension GMNTremoloTests {
    @Test
    func bothShortAndLongSpanNamesPromote() throws {
        guard case let .tremolo(shortBegin) = try normalizedTag("[\\tremBegin c]"),
              case let .tremolo(longEnd) = try normalizedTag("[\\tremoloEnd]")
        else {
            Issue.record("Expected tremolo tags")
            return
        }

        #expect(shortBegin.span == .begin)
        #expect(longEnd.span == .end)
    }

    @Test(arguments: [(GMNTag.Span.whole, "tremolo"),
                      (.begin, "tremoloBegin"),
                      (.end, "tremoloEnd")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        // Unlike `\crescendo` and `\accelerando`, `\tremolo` has the long
        // spelling for all three forms — `Tags.cpp` declares `tremoloBegin`
        // and `tremoloEnd` alongside the short `tremBegin`/`tremEnd`.
        #expect(GMNTremolo(span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNTremolo(style: "//").require()
        let b = GMNTremolo(style: "//").require()
        let c = GMNTremolo(style: "///").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let tremolo = GMNTremolo().require()

        #expect(tremolo.appearance.isEmpty)
        #expect(tremolo.body.isEmpty)
        #expect(tremolo.ident == nil)
        #expect(tremolo.pitch == nil)
        #expect(tremolo.span == .whole)
        #expect(tremolo.speed == nil)
        #expect(tremolo.style == nil)
        #expect(tremolo.text == nil)
        #expect(tremolo.thickness == nil)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .tremolo(tremolo) =
              try normalizedTag("[\\tremolo<\"//\",16,\"e\",0.5,\"trem.\">(c)]")
        else {
            Issue.record("Expected tremolo tag")
            return
        }

        #expect(tremolo.pitch == "e")
        #expect(tremolo.speed == 16)
        #expect(tremolo.style == "//")
        #expect(tremolo.text == "trem.")
        #expect(tremolo.thickness == GMNLength(0.5))
    }

    @Test
    func speedIsAnIntegerAndNotAFloat() throws {
        // `kARTremoloParams` declares `I,speed`, and
        // `getParameter<TagParameterInt>` casts a written float away — so the
        // value is inert, the normalizer drops it, and what promotes is a
        // `\tremolo` with no speed at all.
        guard case let .tremolo(tremolo) = try normalizedTag("[\\tremolo<speed=16.5>(c)]")
        else {
            Issue.record("Expected tremolo tag")
            return
        }

        #expect(tremolo.speed == nil)
    }

    @Test
    func theSecondPitchStaysAString() throws {
        // `ARTremolo` keeps it as text and validates it only loosely,
        // accepting a `{…}` wrapper its own scanner never fully parses.
        guard case let .tremolo(tremolo) = try normalizedTag("[\\tremolo<pitch=\"{e&2}\">(c)]")
        else {
            Issue.record("Expected tremolo tag")
            return
        }

        #expect(tremolo.pitch == "{e&2}")
    }
}
