// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNStaffVisibilityTests {
}

// MARK: -

extension GMNStaffVisibilityTests {
    @Test(arguments: [(GMNStaffVisibility.Kind.off, "staffOff"),
                      (GMNStaffVisibility.Kind.on, "staffOn")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNStaffVisibility.Kind, expected: String)) {
        #expect(GMNStaffVisibility(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNStaffVisibility(kind: .on)
        let b = GMNStaffVisibility(kind: .on)
        let c = GMNStaffVisibility(kind: .off)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let staffVisibility = GMNStaffVisibility(kind: .on)

        #expect(staffVisibility.appearance.isEmpty)
        #expect(staffVisibility.body.isEmpty)
        #expect(staffVisibility.ident == nil)
        #expect(staffVisibility.kind == .on)
    }

    @Test
    func itHasNoParametersOfItsOwn() {
        #expect(GMNStaffVisibility(kind: .on).parameterValues.isEmpty)
    }

    @Test
    func promotesBothHalves() throws {
        guard case let .staffVisibility(off) = try normalizedTag("[\\staffOff]"),
              case let .staffVisibility(on) = try normalizedTag("[\\staffOn]")
        else {
            Issue.record("Expected staff visibility tags")
            return
        }

        #expect(off.kind == .off)
        #expect(on.kind == .on)
    }
}
