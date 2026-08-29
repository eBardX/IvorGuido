// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNSpaceTests {
}

// MARK: -

extension GMNSpaceTests {
    @Test
    func canonicalNameIsSpace() {
        #expect(GMNSpace(distance: GMNLength(2, unit: .hs)).name == makeTagName("space"))
    }

    @Test
    func equatable() {
        let a = GMNSpace(distance: GMNLength(2, unit: .hs))
        let b = GMNSpace(distance: GMNLength(2, unit: .hs))
        let c = GMNSpace(distance: GMNLength(3, unit: .hs))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let space = GMNSpace(distance: GMNLength(2, unit: .hs))

        #expect(space.appearance.isEmpty)
        #expect(space.body.isEmpty)
        #expect(space.distance == GMNLength(2, unit: .hs))
        #expect(space.ident == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredDistance() {
        expectRejected("[\\space]",
                       .missingRequiredParameter(makeTagName("space"), "dd"))
    }

    @Test
    func promotes() throws {
        guard case let .space(space) = try normalizedTag("[\\space<3cm>]")
        else {
            Issue.record("Expected space tag")
            return
        }

        #expect(space.distance == GMNLength(3, unit: .cm))
    }
}
