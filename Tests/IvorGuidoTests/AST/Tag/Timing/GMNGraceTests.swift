// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNGraceTests {
}

// MARK: -

extension GMNGraceTests {
    @Test
    func canonicalNameIsGrace() {
        #expect(GMNGrace().name == makeTagName("grace"))
    }

    @Test
    func equatable() {
        let a = GMNGrace(index: 1)
        let b = GMNGrace(index: 1)
        let c = GMNGrace()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let grace = GMNGrace()

        #expect(grace.appearance.isEmpty)
        #expect(grace.body.isEmpty)
        #expect(grace.ident == nil)
        #expect(grace.index == nil)
    }

    @Test
    func promotes() throws {
        guard case let .grace(grace) = try normalizedTag("[\\grace(c/16 d/16)]")
        else {
            Issue.record("Expected grace tag")
            return
        }

        #expect(grace.body.count == 2)
        #expect(grace.index == nil)
    }

    @Test
    func promotesWithAnIndex() throws {
        guard case let .grace(grace) = try normalizedTag("[\\grace<2>(c/16)]")
        else {
            Issue.record("Expected grace tag")
            return
        }

        #expect(grace.index == 2)
    }
}
