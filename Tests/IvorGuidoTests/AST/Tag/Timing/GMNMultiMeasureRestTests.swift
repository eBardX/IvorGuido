// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNMultiMeasureRestTests {
}

// MARK: -

extension GMNMultiMeasureRestTests {
    @Test
    func canonicalNameIsMrest() {
        #expect(GMNMultiMeasureRest(count: 4).name == makeTagName("mrest"))
    }

    @Test
    func equatable() {
        let a = GMNMultiMeasureRest(count: 4)
        let b = GMNMultiMeasureRest(count: 4)
        let c = GMNMultiMeasureRest(count: 8)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let rest = GMNMultiMeasureRest(count: 12)

        #expect(rest.appearance.isEmpty)
        #expect(rest.body.isEmpty)
        #expect(rest.count == 12)
        #expect(rest.ident == nil)
    }

    @Test
    func init_fromBindingRequiresCount() {
        #expect(GMNMultiMeasureRest(ident: nil,
                                    binding: makeBinding("mrest"),
                                    body: []) == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredCount() {
        expectRejected("[\\mrest(_)]",
                       .missingRequiredParameter(makeTagName("mrest"), "count"))
    }

    @Test
    func promotes() throws {
        guard case let .multiMeasureRest(rest) = try normalizedTag("[\\mrest<7>(_)]")
        else {
            Issue.record("Expected multiple-measure rest tag")
            return
        }

        #expect(rest.body.count == 1)
        #expect(rest.count == 7)
    }
}
