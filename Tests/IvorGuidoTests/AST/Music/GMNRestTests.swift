// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNRestTests {
}

// MARK: -

extension GMNRestTests {
    @Test
    func `init`() {
        let expectedDuration = makeDuration(1, 2)
        let rest = GMNRest(duration: expectedDuration)

        #expect(rest.duration == expectedDuration)
    }

    @Test
    func equatable() {
        let rest1 = GMNRest(duration: makeDuration(1, 4))
        let rest2 = GMNRest(duration: makeDuration(1, 4))
        let rest3 = GMNRest(duration: makeDuration(1, 8))

        #expect(rest1 == rest2)
        #expect(rest1 != rest3)
    }

    @Test
    func init_milliseconds() {
        let expectedDuration = makeDuration(750)
        let rest = GMNRest(duration: expectedDuration)

        #expect(rest.duration == expectedDuration)
    }
}
