// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNStaffVisibilityKindTests {
}

// MARK: -

extension GMNStaffVisibilityKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNStaffVisibility.Kind.off == .off)
        #expect(GMNStaffVisibility.Kind.off != .on)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `staffVisibilityKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(staffVisibilityKindLabel(.off) == "off")
        #expect(staffVisibilityKindLabel(.on) == "on")
    }

    @Test
    func tagName() {
        #expect(GMNStaffVisibility.Kind.off.tagName == "staffOff")
        #expect(GMNStaffVisibility.Kind.on.tagName == "staffOn")
    }
}
