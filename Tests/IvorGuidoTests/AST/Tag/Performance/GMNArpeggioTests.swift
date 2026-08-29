// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNArpeggioTests {
}

// MARK: -

extension GMNArpeggioTests {
    @Test
    func arpeggioEndStaysCustom() throws {
        // `ARArpeggio::MatchEndTag` names `\arpeggioEnd`, but
        // `ARFactory::createTag` dispatches no such name, so it has no
        // template and cannot promote.
        guard case .custom = try normalizedTag("[\\arpeggioEnd]")
        else {
            Issue.record("Expected custom tag")
            return
        }
    }

    @Test
    func canonicalNameIsArpeggio() {
        #expect(GMNArpeggio().name == makeTagName("arpeggio"))
    }

    @Test
    func equatable() {
        let a = GMNArpeggio(direction: "up")
        let b = GMNArpeggio(direction: "up")
        let c = GMNArpeggio(direction: "down")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let arpeggio = GMNArpeggio()

        #expect(arpeggio.appearance.isEmpty)
        #expect(arpeggio.body.isEmpty)
        #expect(arpeggio.direction == nil)
        #expect(arpeggio.ident == nil)
    }

    @Test
    func promotes() throws {
        guard case let .arpeggio(arpeggio) = try normalizedTag("[\\arpeggio<\"up\">({c,e,g})]")
        else {
            Issue.record("Expected arpeggio tag")
            return
        }

        #expect(arpeggio.body.count == 1)
        #expect(arpeggio.direction == "up")
    }

    @Test
    func promotesADirectionGuidolibIgnores() throws {
        // `ARArpeggio` recognizes `up` and `down` and silently leaves
        // `kUnknown` for anything else (`ARArpeggio.cpp:42–48`). The field is
        // a `String`, so the written value survives rather than being
        // re-spelled or dropped.
        guard case let .arpeggio(arpeggio) = try normalizedTag("[\\arpeggio<\"sideways\">(c)]")
        else {
            Issue.record("Expected arpeggio tag")
            return
        }

        #expect(arpeggio.direction == "sideways")
    }
}
