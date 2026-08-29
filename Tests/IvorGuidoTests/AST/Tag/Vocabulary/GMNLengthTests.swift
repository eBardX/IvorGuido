// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNLengthTests {
}

// MARK: -

extension GMNLengthTests {
    @Test
    func equatable() {
        let a = GMNLength(2, unit: .hs)
        let b = GMNLength(2, unit: .hs)
        let c = GMNLength(2, unit: .pt)
        let d = GMNLength(3, unit: .hs)

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test
    func init_defaultsUnitToNil() {
        let length = GMNLength(5)

        #expect(length.value == 5)
        #expect(length.unit == nil)
    }

    @Test
    func init_storesValueAndUnit() {
        let length = GMNLength(-2.5,
                               unit: .pt)

        #expect(length.value == -2.5)
        #expect(length.unit == .pt)
    }

    @Test
    func unitlessDiffersFromUnitBearing() {
        // A `nil` unit means none was written, which guidolib resolves
        // against the template's own declared default unit. It is not the
        // same as writing that unit out.
        #expect(GMNLength(0) != GMNLength(0, unit: .hs))
    }
}
