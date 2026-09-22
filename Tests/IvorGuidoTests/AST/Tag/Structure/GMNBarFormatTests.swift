// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBarFormatTests {
}

// MARK: -

extension GMNBarFormatTests {
    @Test
    func canonicalNameIsBarFormat() {
        #expect(GMNBarFormat().name == makeTagName("barFormat"))
    }

    @Test
    func equatable() {
        let a = GMNBarFormat(style: "system")
        let b = GMNBarFormat(style: "system")
        let c = GMNBarFormat(style: "staff")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let format = GMNBarFormat()

        #expect(format.appearance.isEmpty)
        #expect(format.body.isEmpty)
        #expect(format.ident == nil)
        #expect(format.range == nil)
        #expect(format.style == nil)
    }

    @Test
    func promotes() throws {
        guard case let .barFormat(format) = try normalizedTag("[\\barFormat<\"system\",\"1-2\">]")
        else {
            Issue.record("Expected barFormat tag")
            return
        }

        #expect(format.style == "system")
        #expect(format.range == "1-2")
    }

    @Test
    func promotesAnUnrecognizedStyle() throws {
        // `ARBarFormat` diagnoses an unknown style and carries on
        // (`ARBarFormat.cpp:81`), so the vocabulary is open and the value stays
        // a `String`.
        guard case let .barFormat(format) = try normalizedTag("[\\barFormat<\"banana\">]")
        else {
            Issue.record("Expected barFormat tag")
            return
        }

        #expect(format.style == "banana")
    }

    @Test
    func promotesWithNoParametersAtAll() throws {
        guard case let .barFormat(format) = try normalizedTag("[\\barFormat]")
        else {
            Issue.record("Expected barFormat tag")
            return
        }

        #expect(format.style == nil)
    }
}
