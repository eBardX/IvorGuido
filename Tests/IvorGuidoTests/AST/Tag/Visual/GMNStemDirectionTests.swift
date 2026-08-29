// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNStemDirectionTests {
}

// MARK: -

extension GMNStemDirectionTests {
    @Test(arguments: [("stemsAuto", GMNStemDirection.Kind.auto),
                      ("stemsDown", .down),
                      ("stemsOff", .off),
                      ("stemsUp", .up)])
    func allFourNamesPromote(_ pair: (name: String, expected: GMNStemDirection.Kind)) throws {
        guard case let .stemDirection(stems) = try normalizedTag("[\\\(pair.name)]")
        else {
            Issue.record("Expected stem-direction tag")
            return
        }

        #expect(stems.kind == pair.expected)
    }

    @Test(arguments: [(GMNStemDirection.Kind.auto, "stemsAuto"),
                      (GMNStemDirection.Kind.down, "stemsDown"),
                      (GMNStemDirection.Kind.off, "stemsOff"),
                      (GMNStemDirection.Kind.up, "stemsUp")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNStemDirection.Kind, expected: String)) {
        #expect(GMNStemDirection(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNStemDirection(kind: .up, length: GMNLength(7))
        let b = GMNStemDirection(kind: .up, length: GMNLength(7))
        let c = GMNStemDirection(kind: .up)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let stems = GMNStemDirection(kind: .off)

        #expect(stems.appearance.isEmpty)
        #expect(stems.body.isEmpty)
        #expect(stems.ident == nil)
        #expect(stems.kind == .off)
        #expect(stems.length == nil)
    }

    @Test
    func theLengthBindsPositionally() throws {
        guard case let .stemDirection(stems) = try normalizedTag("[\\stemsUp<5hs>(c d)]")
        else {
            Issue.record("Expected stem-direction tag")
            return
        }

        #expect(stems.length == GMNLength(5, unit: .hs))
        #expect(stems.body.count == 2)
    }
}
