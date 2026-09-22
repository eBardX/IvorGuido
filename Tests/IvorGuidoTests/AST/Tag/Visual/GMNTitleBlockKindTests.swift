// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTitleBlockKindTests {
}

// MARK: -

extension GMNTitleBlockKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNTitleBlock.Kind.composer == .composer)
        #expect(GMNTitleBlock.Kind.composer != .footer)
    }

    @Test
    func caseSetIsExactlyThree() {
        // The switch in `titleBlockKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(titleBlockKindLabel(.composer) == "composer")
        #expect(titleBlockKindLabel(.footer) == "footer")
        #expect(titleBlockKindLabel(.title) == "title")
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNTitleBlock.Kind.kind(forTagName: "composer") == .composer)
        #expect(GMNTitleBlock.Kind.kind(forTagName: "footer") == .footer)
        #expect(GMNTitleBlock.Kind.kind(forTagName: "title") == .title)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNTitleBlock.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNTitleBlock.Kind.composer.tagName == "composer")
        #expect(GMNTitleBlock.Kind.footer.tagName == "footer")
        #expect(GMNTitleBlock.Kind.title.tagName == "title")
    }
}
