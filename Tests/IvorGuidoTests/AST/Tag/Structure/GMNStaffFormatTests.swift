// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNStaffFormatTests {
}

// MARK: -

extension GMNStaffFormatTests {
    @Test
    func canonicalNameIsStaffFormat() {
        #expect(GMNStaffFormat().name == makeTagName("staffFormat"))
    }

    @Test
    func equatable() {
        let a = GMNStaffFormat(style: "5-line")
        let b = GMNStaffFormat(style: "5-line")
        let c = GMNStaffFormat(style: "1-line")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let staffFormat = GMNStaffFormat()

        #expect(staffFormat.appearance.isEmpty)
        #expect(staffFormat.body.isEmpty)
        #expect(staffFormat.distance == nil)
        #expect(staffFormat.ident == nil)
        #expect(staffFormat.lineThickness == nil)
        #expect(staffFormat.size == nil)
        #expect(staffFormat.style == nil)
    }

    @Test
    func promotes() throws {
        guard case let .staffFormat(staffFormat) =
              try normalizedTag("[\\staffFormat<\"5-line\",lineThickness=0.1,distance=8hs>]")
        else {
            Issue.record("Expected staffFormat tag")
            return
        }

        #expect(staffFormat.distance == GMNLength(8, unit: .hs))
        #expect(staffFormat.lineThickness == 0.1)
        #expect(staffFormat.style == "5-line")
    }

    @Test
    func sizeIsALengthHereAndNotAnAppearanceNumber() throws {
        // `kARStaffFormatParams` redeclares `size` as `U`, shadowing
        // `kCommonParams`' `F`. Reading it through `appearance` would drop
        // the unit, so this payload owns it.
        guard case let .staffFormat(staffFormat) = try normalizedTag("[\\staffFormat<size=4pt>]")
        else {
            Issue.record("Expected staffFormat tag")
            return
        }

        #expect(staffFormat.appearance.size == nil)
        #expect(staffFormat.size == GMNLength(4, unit: .pt))
    }

    @Test
    func takesNoParametersAtAll() throws {
        guard case .staffFormat = try normalizedTag("[\\staffFormat]")
        else {
            Issue.record("Expected staffFormat tag")
            return
        }
    }
}
