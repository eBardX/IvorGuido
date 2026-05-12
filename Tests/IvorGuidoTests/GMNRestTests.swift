// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNRestTests {
}

// MARK: -

extension GMNRestTests {
    @Test
    func equatable() {
        let rest1 = GMNRest(duration: fdur(1, 4))
        let rest2 = GMNRest(duration: fdur(1, 4))
        let rest3 = GMNRest(duration: fdur(1, 8))

        #expect(rest1 == rest2)
        #expect(rest1 != rest3)
    }

    @Test
    func `init`() {
        let expectedDuration = fdur(1, 2)
        let rest = GMNRest(duration: expectedDuration)

        #expect(rest.duration == expectedDuration)
    }

    @Test
    func init_milliseconds() {
        let expectedDuration = mdur(750)
        let rest = GMNRest(duration: expectedDuration)

        #expect(rest.duration == expectedDuration)
    }
}
