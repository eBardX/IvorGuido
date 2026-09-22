// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagTextStyleTests {
}

// MARK: -

extension GMNTagTextStyleTests {
    @Test
    func absentDiffersFromDefaultValued() {
        // The four are only *provisionally* omissible, so the model keeps
        // absence distinct from an explicitly written declared default.
        #expect(GMNTag.TextStyle() != GMNTag.TextStyle(font: "Times"))
        #expect(GMNTag.TextStyle() != GMNTag.TextStyle(fontAttributes: ""))
    }

    @Test
    func equatable() {
        let a = GMNTag.TextStyle(font: "Times",
                                 fontSize: GMNLength(9, unit: .pt))
        let b = GMNTag.TextStyle(font: "Times",
                                 fontSize: GMNLength(9, unit: .pt))
        let c = GMNTag.TextStyle(font: "Times",
                                 fontSize: GMNLength(10, unit: .pt))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let style = GMNTag.TextStyle()

        #expect(style.font == nil)
        #expect(style.fontAttributes == nil)
        #expect(style.fontSize == nil)
        #expect(style.textFormat == nil)
    }

    @Test
    func init_storesAllParameters() {
        let style = GMNTag.TextStyle(textFormat: "lc",
                                     font: "Times New Roman",
                                     fontSize: GMNLength(11, unit: .pt),
                                     fontAttributes: "b")

        #expect(style.font == "Times New Roman")
        #expect(style.fontAttributes == "b")
        #expect(style.fontSize == GMNLength(11, unit: .pt))
        #expect(style.textFormat == "lc")
    }

    @Test
    func isEmpty() {
        #expect(GMNTag.TextStyle().isEmpty)

        #expect(!GMNTag.TextStyle(textFormat: "lc").isEmpty)
        #expect(!GMNTag.TextStyle(font: "Times").isEmpty)
        #expect(!GMNTag.TextStyle(fontSize: GMNLength(9, unit: .pt)).isEmpty)
        #expect(!GMNTag.TextStyle(fontAttributes: "b").isEmpty)
    }
}
