// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNClefTests {
}

// MARK: -

extension GMNClefTests {
    @Test
    func canonicalNameIsClef() {
        #expect(GMNClef(type: "treble").name == makeTagName("clef"))
    }

    @Test
    func equatable() {
        let a = GMNClef(type: "treble")
        let b = GMNClef(type: "treble")
        let c = GMNClef(type: "bass")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsOptionalsToNil() {
        let clef = GMNClef(type: "alto")

        #expect(clef.appearance.isEmpty)
        #expect(clef.body.isEmpty)
        #expect(clef.ident == nil)
        #expect(clef.type == "alto")
    }

    @Test
    func isRejectedWithoutTheRequiredType() {
        expectRejected("[\\clef]",
                       .missingRequiredParameter(makeTagName("clef"), "type"))
    }

    @Test
    func promotes() throws {
        guard case let .clef(clef) = try normalizedTag("[\\clef<\"bass\">]")
        else {
            Issue.record("Expected clef tag")
            return
        }

        #expect(clef.type == "bass")
    }

    @Test
    func promotesAnOctaveTransposedClef() throws {
        // `ARClef::decodeOctava` strips the suffix rather than rejecting it
        // (`ARClef.cpp:100–118`), so the value stays an open `String`.
        guard case let .clef(clef) = try normalizedTag("[\\clef<\"treble-8\">]")
        else {
            Issue.record("Expected clef tag")
            return
        }

        #expect(clef.type == "treble-8")
    }
}
