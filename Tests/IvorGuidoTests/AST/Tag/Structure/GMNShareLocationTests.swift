// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNShareLocationTests {
}

// MARK: -

extension GMNShareLocationTests {
    @Test
    func canonicalNameIsShareLocation() {
        #expect(GMNShareLocation().name == makeTagName("shareLocation"))
    }

    @Test
    func equatable() {
        let a = GMNShareLocation()
        let b = GMNShareLocation()
        let c = GMNShareLocation(ident: makeTagIdent(1))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let shareLocation = GMNShareLocation()

        #expect(shareLocation.appearance.isEmpty)
        #expect(shareLocation.body.isEmpty)
        #expect(shareLocation.ident == nil)
    }

    @Test
    func itHasNoParametersOfItsOwn() {
        // `kARShareLocationParams` is empty: whatever a `\shareLocation`
        // carries beyond `kCommonParams` is somebody else's.
        #expect(GMNShareLocation().parameterValues.isEmpty)
    }

    @Test
    func promotes() throws {
        guard case let .shareLocation(shareLocation) = try normalizedTag("[\\shareLocation<dx=2hs>(c e)]")
        else {
            Issue.record("Expected shareLocation tag")
            return
        }

        #expect(shareLocation.appearance.dx == GMNLength(2, unit: .hs))
        #expect(shareLocation.body.count == 2)
    }
}
