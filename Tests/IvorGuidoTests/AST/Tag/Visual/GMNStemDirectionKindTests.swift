// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNStemDirectionKindTests {
}

// MARK: -

extension GMNStemDirectionKindTests {
    @Test
    func casesAreDistinct() {
        #expect(GMNStemDirection.Kind.auto == .auto)
        #expect(GMNStemDirection.Kind.auto != .down)
    }

    @Test
    func caseSetIsExactlyFour() {
        // The switch in `stemDirectionKindLabel(_:)` is exhaustive by compilation, so
        // adding or removing a case breaks this test rather than passing
        // silently.
        #expect(stemDirectionKindLabel(.auto) == "auto")
        #expect(stemDirectionKindLabel(.down) == "down")
        #expect(stemDirectionKindLabel(.off) == "off")
        #expect(stemDirectionKindLabel(.up) == "up")
    }

    @Test
    func kind_canonicalTagName() {
        // Every canonical spelling round-trips.
        #expect(GMNStemDirection.Kind.kind(forTagName: "stemsAuto") == .auto)
        #expect(GMNStemDirection.Kind.kind(forTagName: "stemsDown") == .down)
        #expect(GMNStemDirection.Kind.kind(forTagName: "stemsOff") == .off)
        #expect(GMNStemDirection.Kind.kind(forTagName: "stemsUp") == .up)
    }

    @Test
    func kind_unknownTagName() {
        #expect(GMNStemDirection.Kind.kind(forTagName: "bembel") == nil)
    }

    @Test
    func tagName() {
        #expect(GMNStemDirection.Kind.auto.tagName == "stemsAuto")
        #expect(GMNStemDirection.Kind.down.tagName == "stemsDown")
        #expect(GMNStemDirection.Kind.off.tagName == "stemsOff")
        #expect(GMNStemDirection.Kind.up.tagName == "stemsUp")
    }
}
