// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagAppearanceTests {
}

// MARK: -

extension GMNTagAppearanceTests {
    @Test
    func absentDiffersFromDefaultValued() {
        // All four parameters are non-omissible, so an explicitly written
        // default must not compare equal to nothing written at all —
        // `\bar` and `\bar<dx=0>` are observably different scores.
        #expect(GMNTag.Appearance() != GMNTag.Appearance(dx: GMNLength(0)))
        #expect(GMNTag.Appearance() != GMNTag.Appearance(color: "black"))
        #expect(GMNTag.Appearance() != GMNTag.Appearance(size: 1.0))
    }

    @Test
    func equatable() {
        let a = GMNTag.Appearance(color: "red",
                                  dx: GMNLength(2, unit: .hs))
        let b = GMNTag.Appearance(color: "red",
                                  dx: GMNLength(2, unit: .hs))
        let c = GMNTag.Appearance(color: "red",
                                  dx: GMNLength(2, unit: .pt))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let appearance = GMNTag.Appearance()

        #expect(appearance.color == nil)
        #expect(appearance.dx == nil)
        #expect(appearance.dy == nil)
        #expect(appearance.size == nil)
    }

    @Test
    func init_storesAllParameters() {
        let appearance = GMNTag.Appearance(color: "blue",
                                           dx: GMNLength(5, unit: .hs),
                                           dy: GMNLength(-2.5, unit: .pt),
                                           size: 1.5)

        #expect(appearance.color == "blue")
        #expect(appearance.dx == GMNLength(5, unit: .hs))
        #expect(appearance.dy == GMNLength(-2.5, unit: .pt))
        #expect(appearance.size == 1.5)
    }

    @Test
    func isEmpty() {
        #expect(GMNTag.Appearance().isEmpty)

        #expect(!GMNTag.Appearance(color: "red").isEmpty)
        #expect(!GMNTag.Appearance(dx: GMNLength(0)).isEmpty)
        #expect(!GMNTag.Appearance(dy: GMNLength(0)).isEmpty)
        #expect(!GMNTag.Appearance(size: 1.0).isEmpty)
    }
}
