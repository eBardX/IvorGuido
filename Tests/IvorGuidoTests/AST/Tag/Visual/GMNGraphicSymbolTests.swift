// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNGraphicSymbolTests {
}

// MARK: -

extension GMNGraphicSymbolTests {
    @Test
    func aBareSymbolTagIsRejected() {
        expectRejected("[\\symbol]",
                       .missingRequiredParameter(makeTagName("symbol"), "file"))
    }

    @Test
    func anIllTypedWidthIsDropped() throws {
        // FLIPPED IN PHASE 2. `w` was exempted from the inert-parameter
        // repair as one of four names guidolib was thought to read under two
        // C++ types. Per class it reads it under one: `ARSymbol::getFixedWidth`
        // takes a `TagParameterInt` and nothing else (`ARSymbol.cpp:36`), and
        // the two types the grep saw were `ARPageFormat`'s float and this
        // class's int. A string here is inert, so it goes, and the tag
        // promotes on what is left.
        guard case let .graphicSymbol(symbol) = try normalizedTag("[\\symbol<\"a.png\",w=\"wide\">]")
        else {
            Issue.record("Expected graphic symbol tag")
            return
        }

        #expect(symbol.file == "a.png")
        #expect(symbol.width == nil)
    }

    @Test(arguments: ["s", "symbol"])
    func bothSpellingsPromoteTheWholeTemplate(_ name: String) throws {
        guard case let .graphicSymbol(symbol) =
              try normalizedTag("[\\\(name)<\"a.png\",\"top\",20,30>(c)]")
        else {
            Issue.record("Expected graphic-symbol tag")
            return
        }

        #expect(symbol.file == "a.png")
        #expect(symbol.height == 30)
        #expect(symbol.position == "top")
        #expect(symbol.width == 20)
    }

    @Test
    func canonicalNameIsTheLongForm() {
        #expect(GMNGraphicSymbol(file: "a.png").name == makeTagName("symbol"))
    }

    @Test
    func equatable() {
        let a = GMNGraphicSymbol(file: "a.png", width: 20)
        let b = GMNGraphicSymbol(file: "a.png", width: 20)
        let c = GMNGraphicSymbol(file: "a.png")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let symbol = GMNGraphicSymbol(file: "a.png")

        #expect(symbol.appearance.isEmpty)
        #expect(symbol.body.isEmpty)
        #expect(symbol.file == "a.png")
        #expect(symbol.height == nil)
        #expect(symbol.ident == nil)
        #expect(symbol.position == nil)
        #expect(symbol.width == nil)
    }

    @Test
    func thePositionVocabularyIsOpen() throws {
        // A different vocabulary from the articulations' `above`/`below`:
        // `GRSymbol.cpp:185–189` reads `top`, `bot`, and `bottom` and treats
        // everything else as the middle, which is an open parse.
        guard case let .graphicSymbol(symbol) = try normalizedTag("[\\symbol<\"a.png\",\"bot\">]")
        else {
            Issue.record("Expected graphic-symbol tag")
            return
        }

        #expect(symbol.position == "bot")
    }
}
