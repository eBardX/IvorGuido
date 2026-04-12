// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNTablatureTests {
}

// MARK: -

extension GMNTablatureTests {
    @Test
    func test_equatable() {
        let tab1 = GMNTablature(tabString: 1, fret: "5", duration: .fraction(1, 4))
        let tab2 = GMNTablature(tabString: 1, fret: "5", duration: .fraction(1, 4))
        let tab3 = GMNTablature(tabString: 2, fret: "5", duration: .fraction(1, 4))

        #expect(tab1 == tab2)
        #expect(tab1 != tab3)
    }

    @Test
    func test_init() {
        let tab = GMNTablature(tabString: 3, fret: "7", duration: .fraction(1, 8))

        #expect(tab.tabString == 3)
        #expect(tab.fret == "7")
        #expect(tab.duration == .fraction(1, 8))
    }

    @Test
    func test_init_openString() {
        let tab = GMNTablature(tabString: 1, fret: "0", duration: .fraction(1, 4))

        #expect(tab.fret == "0")
    }

    @Test
    func test_init_mutedString() {
        let tab = GMNTablature(tabString: 6, fret: "x", duration: .fraction(1, 4))

        #expect(tab.tabString == 6)
        #expect(tab.fret == "x")
    }
}
