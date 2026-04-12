// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNRestTests {
}

// MARK: -

extension GMNRestTests {
    @Test
    func test_equatable() {
        let rest1 = GMNRest(duration: .fraction(1, 4))
        let rest2 = GMNRest(duration: .fraction(1, 4))
        let rest3 = GMNRest(duration: .fraction(1, 8))

        #expect(rest1 == rest2)
        #expect(rest1 != rest3)
    }

    @Test
    func test_init() {
        let rest = GMNRest(duration: .fraction(1, 2))

        #expect(rest.duration == .fraction(1, 2))
    }

    @Test
    func test_init_milliseconds() {
        let rest = GMNRest(duration: .milliseconds(750))

        #expect(rest.duration == .milliseconds(750))
    }
}
