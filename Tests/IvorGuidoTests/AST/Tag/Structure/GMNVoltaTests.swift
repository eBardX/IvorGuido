// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNVoltaTests {
}

// MARK: -

extension GMNVoltaTests {
    @Test(arguments: [(GMNTag.Span.begin, "voltaBegin"),
                      (GMNTag.Span.end, "voltaEnd"),
                      (GMNTag.Span.whole, "volta")])
    func canonicalNameFollowsTheSpan(_ pair: (span: GMNTag.Span, expected: String)) {
        // A closing half is the one span that cannot carry the mark, so the
        // argument varies with the case rather than being held constant —
        // see `init_refusesAMarkOnASpanEnd`.
        #expect(GMNVolta(mark: pair.span == .end ? "" : "1",
                         span: pair.span).require().name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNVolta(mark: "1").require()
        let b = GMNVolta(mark: "1").require()
        let c = GMNVolta(mark: "2").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let volta = GMNVolta(mark: "1").require()

        #expect(volta.appearance.isEmpty)
        #expect(volta.body.isEmpty)
        #expect(volta.format == nil)
        #expect(volta.ident == nil)
        #expect(volta.mark == "1")
        #expect(volta.span == .whole)
    }

    @Test
    func init_fromBindingRequiresMarkExceptAtASpanEnd() {
        #expect(GMNVolta(ident: nil,
                         binding: makeBinding("volta"),
                         span: .whole,
                         body: []) == nil)

        #expect(GMNVolta(ident: nil,
                         binding: makeBinding("voltaEnd"),
                         span: .end,
                         body: []) != nil)
    }

    @Test
    func init_refusesAMarkOnASpanEnd() {
        // What used to be pinned here is that a mark on a closing half was
        // silently dropped at emission. It is refused at construction now:
        // An `ARDummyRangeEnd` has nowhere to put it, and dropping it at the
        // formatter meant the value was accepted and then lost.
        #expect(GMNVolta(mark: "1",
                         span: .end) == nil)
        #expect(GMNVolta(mark: "",
                         format: "|-",
                         span: .end) == nil)
        #expect(GMNVolta(mark: "",
                         span: .end,
                         appearance: GMNTag.Appearance(color: "red")) == nil)
    }

    @Test
    func isRepairedWhenASpanEndCarriesParameters() throws {
        // `\voltaEnd` is an `ARDummyRangeEnd` and takes nothing, so the
        // normalizer drops what was written rather than
        // carrying it to a reader that does not exist.
        guard case let .volta(volta) = try normalizedTag("[\\voltaEnd<\"1.\">]")
        else {
            Issue.record("Expected volta tag")
            return
        }

        #expect(volta.parameterValues.isEmpty)
        #expect(volta.span == .end)
    }

    @Test
    func promotes() throws {
        guard case let .volta(volta) = try normalizedTag("[\\volta<\"1.\",\"|-\">(c d)]")
        else {
            Issue.record("Expected volta tag")
            return
        }

        #expect(volta.body.count == 2)
        #expect(volta.format == "|-")
        #expect(volta.mark == "1.")
        #expect(volta.span == .whole)
    }

    @Test
    func promotesBothHalvesOfTheSpan() throws {
        guard case let .volta(begin) = try normalizedTag("[\\voltaBegin:1<\"1.\">]"),
              case let .volta(end) = try normalizedTag("[\\voltaEnd:1]")
        else {
            Issue.record("Expected volta tags")
            return
        }

        #expect(begin.ident == makeTagIdent(1))
        #expect(begin.span == .begin)
        #expect(end.span == .end)
    }

    @Test
    func spanEndEmitsNoParameters() {
        #expect(GMNVolta(mark: "",
                         span: .end).require().parameterValues.isEmpty)
    }
}
