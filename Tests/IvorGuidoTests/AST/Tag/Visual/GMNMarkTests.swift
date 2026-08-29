// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNMarkTests {
}

// MARK: -

extension GMNMarkTests {
    @Test
    func aBareMarkTagIsRejected() {
        expectRejected("[\\mark]",
                       .missingRequiredParameter(makeTagName("mark"), "text"))
    }

    @Test(arguments: [("bracket", GMNMark.Enclosure.bracket),
                      ("circle", .circle),
                      ("diamond", .diamond),
                      ("none", GMNMark.Enclosure.none),
                      ("oval", .oval),
                      ("rectangle", .rectangle),
                      ("square", .square),
                      ("triangle", .triangle)])
    func allEightEnclosuresRead(_ pair: (written: String, expected: GMNMark.Enclosure)) throws {
        guard case let .mark(mark) = try normalizedTag("[\\mark<\"A\",\"\(pair.written)\">]")
        else {
            Issue.record("Expected mark tag")
            return
        }

        #expect(mark.enclosure == pair.expected)
    }

    @Test
    func anUnreadableEnclosureIsRejected() {
        // FLIPPED IN PHASE 3. guidolib renders an unregistered enclosure as
        // none, so reading it that way would be semantically faithful — and
        // would still discard what was written. The tag used to stay generic
        // around it; discarding is what the score is now refused for.
        expectRejected("[\\mark<\"A\",\"hexagon\">]",
                       .unreadableParameterValue(makeTagName("mark")))
    }

    @Test
    func canonicalName() {
        #expect(GMNMark(text: "A").name == makeTagName("mark"))
    }

    @Test
    func equatable() {
        let a = GMNMark(text: "A", enclosure: .square)
        let b = GMNMark(text: "A", enclosure: .square)
        let c = GMNMark(text: "A")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let mark = GMNMark(text: "A")

        #expect(mark.appearance.isEmpty)
        #expect(mark.body.isEmpty)
        #expect(mark.enclosure == nil)
        #expect(mark.ident == nil)
        #expect(mark.text == "A")
        #expect(mark.textStyle.isEmpty)
    }

    @Test
    func theVerticalOffsetIsItsThirdSlot() throws {
        // `dy` is one of `\mark`'s own positional slots as well as a
        // `kCommonParams` name, so the third unnamed parameter binds to it.
        guard case let .mark(mark) = try normalizedTag("[\\mark<\"A\",\"square\",3hs>]")
        else {
            Issue.record("Expected mark tag")
            return
        }

        #expect(mark.appearance.dy == GMNLength(3, unit: .hs))
    }
}
