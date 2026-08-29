// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTitleBlockTests {
}

// MARK: -

extension GMNTitleBlockTests {
    @Test
    func aBareTitleTagIsRejected() {
        expectRejected("[\\title]",
                       .missingRequiredParameter(makeTagName("title"), "name"))
    }

    @Test(arguments: [("composer", GMNTitleBlock.Kind.composer),
                      ("footer", .footer),
                      ("title", .title)])
    func allThreeNamesPromote(_ pair: (name: String, expected: GMNTitleBlock.Kind)) throws {
        guard case let .titleBlock(block) = try normalizedTag("[\\\(pair.name)<\"x\">]")
        else {
            Issue.record("Expected title-block tag")
            return
        }

        #expect(block.kind == pair.expected)
        #expect(block.text == "x")
    }

    @Test(arguments: [(GMNTitleBlock.Kind.composer, "composer"),
                      (GMNTitleBlock.Kind.footer, "footer"),
                      (GMNTitleBlock.Kind.title, "title")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNTitleBlock.Kind, expected: String)) {
        #expect(GMNTitleBlock(kind: pair.kind, text: "x").name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNTitleBlock(kind: .title, text: "Sonata")
        let b = GMNTitleBlock(kind: .title, text: "Sonata")
        let c = GMNTitleBlock(kind: .composer, text: "Sonata")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let block = GMNTitleBlock(kind: .title, text: "Sonata")

        #expect(block.appearance.isEmpty)
        #expect(block.body.isEmpty)
        #expect(block.ident == nil)
        #expect(block.kind == .title)
        #expect(block.pageFormat == nil)
        #expect(block.text == "Sonata")
        #expect(block.textStyle.isEmpty)
    }

    @Test
    func promotesTheWholeTitleTemplate() throws {
        guard case let .titleBlock(title) =
              try normalizedTag("[\\title<\"Sonata\",\"c1\",2hs,\"Arial\",20pt,\"lt\">]")
        else {
            Issue.record("Expected title-block tag")
            return
        }

        #expect(title.appearance.dy == GMNLength(2, unit: .hs))
        #expect(title.pageFormat == "c1")
        #expect(title.text == "Sonata")
        #expect(title.textStyle.font == "Arial")
        #expect(title.textStyle.fontSize == GMNLength(20, unit: .pt))
        #expect(title.textStyle.textFormat == "lt")
    }

    @Test(arguments: ["composer", "title"])
    func theInheritedTextParameterIsRemoved(_ name: String) throws {
        // Both call `clearTagDefaultParameter(kTextStr)`, so `text` is not
        // merely un-required on them — it is unsupported, and the normalizer
        // drops it. `name` is what these tags actually read, so it is what
        // survives into the payload's text.
        guard case let .titleBlock(titleBlock) = try normalizedTag("[\\\(name)<name=\"x\",text=\"y\">]")
        else {
            Issue.record("Expected title-block tag")
            return
        }

        #expect(titleBlock.text == "x")
    }

    @Test
    func theRequiredSlotIsNamedForTheKind() throws {
        // `kARTitleParams` and `kARComposerParams` open with `name` while
        // `kARFooterParams` opens with `text`, so one payload field lands on
        // two different template names.
        guard case let .titleBlock(title) = try normalizedTag("[\\title<name=\"Sonata\">]"),
              case let .titleBlock(footer) = try normalizedTag("[\\footer<text=\"page 1\">]")
        else {
            Issue.record("Expected title-block tags")
            return
        }

        #expect(title.text == "Sonata")
        #expect(footer.text == "page 1")
    }
}
