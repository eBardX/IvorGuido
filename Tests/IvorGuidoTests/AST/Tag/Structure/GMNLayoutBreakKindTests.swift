// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNLayoutBreakKindTests {
}

// MARK: -

extension GMNLayoutBreakKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNLayoutBreak.Kind.newPage == .newPage)
        #expect(GMNLayoutBreak.Kind.newPage != .newSystem)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `layoutBreakKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(layoutBreakKindLabel(.newPage) == "newPage")
        #expect(layoutBreakKindLabel(.newSystem) == "newSystem")
    }
}
