// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNRepeatTests {
}

// MARK: -

extension GMNRepeatTests {
    @Test(arguments: [(GMNRepeat.Kind.begin, "repeatBegin"),
                      (GMNRepeat.Kind.end, "repeatEnd")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNRepeat.Kind, expected: String)) {
        #expect(GMNRepeat(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNRepeat(kind: .begin)
        let b = GMNRepeat(kind: .begin)
        let c = GMNRepeat(kind: .end)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let repeatMark = GMNRepeat(kind: .begin)

        #expect(repeatMark.appearance.isEmpty)
        #expect(repeatMark.body.isEmpty)
        #expect(repeatMark.displayMeasNum == nil)
        #expect(repeatMark.hidden == nil)
        #expect(repeatMark.ident == nil)
        #expect(repeatMark.kind == .begin)
        #expect(repeatMark.measNum == nil)
        #expect(repeatMark.numDx == nil)
        #expect(repeatMark.numDy == nil)
    }

    @Test
    func neitherHalfRequiresAnything() throws {
        guard case let .repeatMark(begin) = try normalizedTag("[\\repeatBegin]"),
              case let .repeatMark(end) = try normalizedTag("[\\repeatEnd]")
        else {
            Issue.record("Expected repeat tags")
            return
        }

        #expect(begin.kind == .begin)
        #expect(end.kind == .end)
    }

    @Test
    func promotesTheBarParametersOfARepeatEnd() throws {
        guard case let .repeatMark(repeatMark) =
              try normalizedTag("[\\repeatEnd<measNum=5,numDx=1hs,hidden=\"true\">]")
        else {
            Issue.record("Expected repeat tag")
            return
        }

        #expect(repeatMark.hidden == "true")
        #expect(repeatMark.measNum == 5)
        #expect(repeatMark.numDx == GMNLength(1, unit: .hs))
    }

    @Test
    func theKindIsNotASpan() throws {
        // `\repeatBegin` and `\repeatEnd` are two independent marks, not the
        // halves of one construct: `span(of:)` answers `.whole` for both.
        guard case let .repeatMark(repeatMark) = try normalizedTag("[\\repeatEnd]")
        else {
            Issue.record("Expected repeat tag")
            return
        }

        #expect(GMNTag.repeatMark(repeatMark).span == .whole)
    }
}
