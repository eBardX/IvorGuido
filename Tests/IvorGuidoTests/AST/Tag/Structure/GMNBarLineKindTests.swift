// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNBarLineKindTests {
}

// MARK: -

extension GMNBarLineKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNBarLine.Kind.double == .double)
        #expect(GMNBarLine.Kind.double != .final)
    }

    @Test
    func caseSetIsExactlyThree() {
        // The switch in `barLineKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(barLineKindLabel(.double) == "double")
        #expect(barLineKindLabel(.final) == "final")
        #expect(barLineKindLabel(.single) == "single")
    }
}
