// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNTablatureTests {
}

// MARK: -

extension GMNTablatureTests {
    @Test
    func equatable() {
        let tab1 = GMNTablature(tabString: 1, fret: "5", duration: fdur(1, 4))
        let tab2 = GMNTablature(tabString: 1, fret: "5", duration: fdur(1, 4))
        let tab3 = GMNTablature(tabString: 2, fret: "5", duration: fdur(1, 4))

        #expect(tab1 == tab2)
        #expect(tab1 != tab3)
    }

    @Test
    func `init`() {
        let expectedDuration = fdur(1, 8)
        let tab = GMNTablature(tabString: 3, fret: "7", duration: expectedDuration)

        #expect(tab.tabString == 3)
        #expect(tab.fret == "7")
        #expect(tab.duration == expectedDuration)
    }

    @Test
    func init_mutedString() {
        let tab = GMNTablature(tabString: 6, fret: "x", duration: fdur(1, 4))

        #expect(tab.tabString == 6)
        #expect(tab.fret == "x")
    }

    @Test
    func init_openString() {
        let tab = GMNTablature(tabString: 1, fret: "0", duration: fdur(1, 4))

        #expect(tab.fret == "0")
    }
}
