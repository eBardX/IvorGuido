// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTablatureTests {
}

// MARK: -

extension GMNTablatureTests {
    @Test
    func equatable() {
        let tab1 = makeTablature(1, "5", makeDuration(1, 4))
        let tab2 = makeTablature(1, "5", makeDuration(1, 4))
        let tab3 = makeTablature(2, "5", makeDuration(1, 4))

        #expect(tab1 == tab2)
        #expect(tab1 != tab3)
    }

    @Test
    func init_mutedString() {
        let tab = makeTablature(6, "x", makeDuration(1, 4))

        #expect(tab.tabString == 6)
        #expect(tab.fret == "x")
    }

    @Test
    func init_openString() {
        let tab = makeTablature(1, "0", makeDuration(1, 4))

        #expect(tab.fret == "0")
    }

    @Test
    func init_success() throws {
        let expectedDuration = makeDuration(1, 8)
        let tab = try #require(GMNTablature(tabString: 3, fret: "7", duration: expectedDuration))

        #expect(tab.tabString == 3)
        #expect(tab.fret == "7")
        #expect(tab.duration == expectedDuration)
    }

    @Test
    func init_tabStringBoundary_success() throws {
        let low = try #require(GMNTablature(tabString: 1, fret: "5", duration: nil))
        let high = try #require(GMNTablature(tabString: 6, fret: "5", duration: nil))

        #expect(low.tabString == 1)
        #expect(high.tabString == 6)
    }

    @Test
    func init_tabStringOutOfRange_failure() {
        #expect(GMNTablature(tabString: 0, fret: "5", duration: nil) == nil)
        #expect(GMNTablature(tabString: 7, fret: "5", duration: nil) == nil)
    }
}
