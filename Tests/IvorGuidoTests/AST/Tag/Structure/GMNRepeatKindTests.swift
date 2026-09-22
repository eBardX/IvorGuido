// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNRepeatKindTests {
}

// MARK: -

extension GMNRepeatKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNRepeat.Kind.begin == .begin)
        #expect(GMNRepeat.Kind.begin != .end)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `repeatKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(repeatKindLabel(.begin) == "begin")
        #expect(repeatKindLabel(.end) == "end")
    }

    @Test
    func tagName() {
        #expect(GMNRepeat.Kind.begin.tagName == "repeatBegin")
        #expect(GMNRepeat.Kind.end.tagName == "repeatEnd")
    }
}
