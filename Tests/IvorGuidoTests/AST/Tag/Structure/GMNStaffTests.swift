// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNStaffTests {
}

// MARK: -

extension GMNStaffTests {
    @Test
    func canonicalNameIsStaff() {
        #expect(GMNStaff(id: .number(1)).name == makeTagName("staff"))
    }

    @Test
    func equatable() {
        let a = GMNStaff(id: .number(1))
        let b = GMNStaff(id: .number(1))
        let c = GMNStaff(id: .number(2))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let staff = GMNStaff(id: .number(1))

        #expect(staff.appearance.isEmpty)
        #expect(staff.body.isEmpty)
        #expect(staff.id == .number(1))
        #expect(staff.ident == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredId() {
        expectRejected("[\\staff]",
                       .missingRequiredParameter(makeTagName("staff"), "id"))
    }

    @Test
    func promotes() throws {
        guard case let .staff(staff) = try normalizedTag("[\\staff<2>]")
        else {
            Issue.record("Expected staff tag")
            return
        }

        #expect(staff.id == .number(2))
    }

    @Test
    func promotesWhenTheIdIsWrittenAsAString() throws {
        // FLIPPED IN PHASE 2. `ARStaff` reads `id` as an integer and then as
        // a string (`ARStaff.cpp:50–64`), so a string spelling is not inert
        // and declining to promote was the only way to keep it. It is now
        // carried in the payload instead.
        guard case let .staff(staff) = try normalizedTag("[\\staff<\"upper\">]")
        else {
            Issue.record("Expected staff tag")
            return
        }

        #expect(staff.id == .name("upper"))
    }

    @Test
    func theTwoSpellingsAreNotInterchangeable() {
        // `getStaffNumber()` returns the sentinel `-1` for a string id
        // precisely so that the two readings stay apart, so `\staff<2>` and
        // `\staff<"2">` must not collapse onto one another here either.
        #expect(GMNStaff(id: .number(2)) != GMNStaff(id: .name("2")))
    }
}
