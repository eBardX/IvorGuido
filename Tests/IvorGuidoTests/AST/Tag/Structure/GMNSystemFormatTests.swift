// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNSystemFormatTests {
}

// MARK: -

extension GMNSystemFormatTests {
    @Test
    func canonicalNameIsSystemFormat() {
        #expect(GMNSystemFormat().name == makeTagName("systemFormat"))
    }

    @Test
    func equatable() {
        let a = GMNSystemFormat()
        let b = GMNSystemFormat()
        let c = GMNSystemFormat(ident: makeTagIdent(1))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let systemFormat = GMNSystemFormat()

        #expect(systemFormat.appearance.isEmpty)
        #expect(systemFormat.body.isEmpty)
        #expect(systemFormat.ident == nil)
    }

    @Test
    func promotes() throws {
        guard case let .systemFormat(systemFormat) = try normalizedTag("[\\systemFormat<dx=3cm>]")
        else {
            Issue.record("Expected systemFormat tag")
            return
        }

        #expect(systemFormat.appearance.dx == GMNLength(3, unit: .cm))
    }

    @Test
    func theCommonParametersAreItsOwnPositionalSlots() throws {
        // `ARSystemFormat` inherits `kCommonParams` as its whole template, so
        // an unnamed first parameter binds to `color` — the one place where
        // an appearance parameter has a position.
        guard case let .systemFormat(systemFormat) = try normalizedTag("[\\systemFormat<\"red\">]")
        else {
            Issue.record("Expected systemFormat tag")
            return
        }

        #expect(systemFormat.appearance.color == "red")
    }
}
