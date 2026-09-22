// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNLayoutBreakTests {
}

// MARK: -

extension GMNLayoutBreakTests {
    @Test
    func equatable() {
        let a = GMNLayoutBreak(kind: .newPage)
        let b = GMNLayoutBreak(kind: .newPage)
        let c = GMNLayoutBreak(kind: .newSystem)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let layoutBreak = GMNLayoutBreak(kind: .newSystem)

        #expect(layoutBreak.appearance.isEmpty)
        #expect(layoutBreak.body.isEmpty)
        #expect(layoutBreak.ident == nil)
        #expect(layoutBreak.name == makeTagName("newSystem"))
    }

    @Test
    func newPageWithAParameterHasItDropped() throws {
        // `ARNewPage` is not an `ARMTParameter`, so `ARFactory` discards what
        // was written before binding (`ARFactory.cpp:2012–2016`). The generic
        // lane used to keep it, on the grounds that promoting would lose it
        // silently; the normalizer now drops it and records
        // `droppedUnacceptedParameters`, so the loss is announced and the tag
        // is typed.
        //
        // `\newSystem` is the contrast, two tests up: `ARNewSystem` *is* an
        // `ARMTParameter`, so the pair of layout-break tags differ here
        // despite reading as siblings, and its `dx` reaches the payload.
        guard case let .layoutBreak(layoutBreak) = try normalizedTag("[\\newPage<dx=2hs>]")
        else {
            Issue.record("Expected layoutBreak tag")
            return
        }

        #expect(layoutBreak.appearance.dx == nil)
    }

    @Test
    func newSystemBindsCommonParametersPositionally() throws {
        // `ARNewSystem` never overrides `getParamsStr()`, so `kCommonParams`
        // is its whole schema and all four bind by position
        // (`ARMusicalTag.h:61`).
        guard case let .layoutBreak(layoutBreak) = try normalizedTag("[\\newSystem<\"red\",2hs>]")
        else {
            Issue.record("Expected layoutBreak tag")
            return
        }

        #expect(layoutBreak.appearance.color == "red")
        #expect(layoutBreak.appearance.dx == GMNLength(2, unit: .hs))
    }

    @Test(arguments: [("newSystem", "newSystem"), ("newLine", "newSystem"), ("newPage", "newPage")])
    func promotesEachName(_ pair: (written: String, canonical: String)) throws {
        guard case let .layoutBreak(layoutBreak) = try normalizedTag("[\\\(pair.written)]")
        else {
            Issue.record("Expected layoutBreak tag")
            return
        }

        #expect(layoutBreak.name == makeTagName(pair.canonical))
    }
}
