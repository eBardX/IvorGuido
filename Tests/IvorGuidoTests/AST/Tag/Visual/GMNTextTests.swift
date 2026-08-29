// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTextTests {
}

// MARK: -

extension GMNTextTests {
    @Test
    func aBareTextTagIsRejected() {
        expectRejected("[\\text]",
                       .missingRequiredParameter(makeTagName("text"), "text"))
    }

    @Test
    func aLabelIsNeverRespelledAsText() throws {
        // `GRVoiceManager` dispatches on `typeid(ARLabel)` exactly, an
        // equality test an `ARText` fails — so canonicalizing `\label` to
        // `\text` would change which branch a consumer takes.
        guard case let .text(label) = try normalizedTag("[\\label<\"hi\">]")
        else {
            Issue.record("Expected text tag")
            return
        }

        #expect(label.name == makeTagName("label"))
    }

    @Test(arguments: [("label", GMNText.Kind.label),
                      ("t", .text),
                      ("text", .text)])
    func allThreeNamesPromote(_ pair: (name: String, expected: GMNText.Kind)) throws {
        guard case let .text(text) = try normalizedTag("[\\\(pair.name)<\"hi\">]")
        else {
            Issue.record("Expected text tag")
            return
        }

        #expect(text.kind == pair.expected)
    }

    @Test(arguments: [(GMNText.Kind.label, "label"),
                      (GMNText.Kind.text, "text")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNText.Kind, expected: String)) {
        #expect(GMNText(kind: pair.kind, text: "hi").name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNText(kind: .text, text: "hi")
        let b = GMNText(kind: .text, text: "hi")
        let c = GMNText(kind: .label, text: "hi")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let text = GMNText(kind: .text, text: "hi")

        #expect(text.appearance.isEmpty)
        #expect(text.body.isEmpty)
        #expect(text.ident == nil)
        #expect(text.kind == .text)
        #expect(text.text == "hi")
        #expect(text.textStyle.isEmpty)
    }

    @Test
    func promotesTheWholeTemplate() throws {
        guard case let .text(text) = try normalizedTag("[\\text<\"hi\",-2hs,\"cb\",14pt>(c)]")
        else {
            Issue.record("Expected text tag")
            return
        }

        #expect(text.appearance.dy == GMNLength(-2, unit: .hs))
        #expect(text.body.count == 1)
        #expect(text.text == "hi")
        #expect(text.textStyle.fontSize == GMNLength(14, unit: .pt))
        #expect(text.textStyle.textFormat == "cb")
    }
}
