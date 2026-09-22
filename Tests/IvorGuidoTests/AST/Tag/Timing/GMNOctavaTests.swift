// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNOctavaTests {
}

// MARK: -

extension GMNOctavaTests {
    @Test
    func absentHiddenDiffersFromWrittenDefault() {
        // Proven non-omissible: `AROctava::setTagParameters` assigns
        // `fHidden` only when `hidden` is present.
        #expect(GMNOctava(offset: 1) != GMNOctava(offset: 1, hidden: "off"))
    }

    @Test
    func canonicalNameIsTheLongForm() {
        #expect(GMNOctava(offset: 1).name == makeTagName("octava"))
    }

    @Test
    func equatable() {
        let a = GMNOctava(offset: 1)
        let b = GMNOctava(offset: 1)
        let c = GMNOctava(offset: -1)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let octava = GMNOctava(offset: -2)

        #expect(octava.appearance.isEmpty)
        #expect(octava.body.isEmpty)
        #expect(octava.hidden == nil)
        #expect(octava.ident == nil)
        #expect(octava.offset == -2)
    }

    @Test(arguments: ["oct", "octava"])
    func promotesFromEitherName(_ name: String) throws {
        guard case let .octava(octava) = try normalizedTag("[\\\(name)<1>(c d)]")
        else {
            Issue.record("Expected octava tag")
            return
        }

        #expect(octava.body.count == 2)
        #expect(octava.offset == 1)
    }

    @Test
    func promotesWithNoBody() throws {
        // `AROctava`'s range setting is `RANGEDC`.
        guard case let .octava(octava) = try normalizedTag("[\\octava<-1,hidden=\"on\"> c]")
        else {
            Issue.record("Expected octava tag")
            return
        }

        #expect(octava.body.isEmpty)
        #expect(octava.hidden == "on")
        #expect(octava.offset == -1)
    }
}
