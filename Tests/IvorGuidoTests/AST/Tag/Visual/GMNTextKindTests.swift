// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTextKindTests {
}

// MARK: -

extension GMNTextKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNText.Kind.label == .label)
        #expect(GMNText.Kind.label != .text)
    }

    @Test
    func caseSetIsExactlyTwo() {
        // The switch in `textKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(textKindLabel(.label) == "label")
        #expect(textKindLabel(.text) == "text")
    }

    @Test
    func kind_aliasTagName() {
        // guidolib spells several of these more than one way; each
        // alias lands on the same case as its canonical name.
        #expect(GMNText.Kind.kind(forTagName: "t") == .text)
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNText.Kind.kind(forTagName: "label") == .label)
        #expect(GMNText.Kind.kind(forTagName: "text") == .text)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNText.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNText.Kind.label.tagName == "label")
        #expect(GMNText.Kind.text.tagName == "text")
    }
}
