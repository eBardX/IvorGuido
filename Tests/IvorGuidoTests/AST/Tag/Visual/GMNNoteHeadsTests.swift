// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNNoteHeadsTests {
}

// MARK: -

extension GMNNoteHeadsTests {
    @Test(arguments: [("headsCenter", GMNNoteHeads.Kind.center),
                      ("headsLeft", .left),
                      ("headsNormal", .normal),
                      ("headsReverse", .reverse),
                      ("headsRight", .right)])
    func allFiveNamesPromote(_ pair: (name: String, expected: GMNNoteHeads.Kind)) throws {
        guard case let .noteHeads(heads) = try normalizedTag("[\\\(pair.name)]")
        else {
            Issue.record("Expected note-heads tag")
            return
        }

        #expect(heads.kind == pair.expected)
    }

    @Test(arguments: [(GMNNoteHeads.Kind.center, "headsCenter"),
                      (GMNNoteHeads.Kind.left, "headsLeft"),
                      (GMNNoteHeads.Kind.normal, "headsNormal"),
                      (GMNNoteHeads.Kind.reverse, "headsReverse"),
                      (GMNNoteHeads.Kind.right, "headsRight")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNNoteHeads.Kind, expected: String)) {
        #expect(GMNNoteHeads(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNNoteHeads(kind: .left)
        let b = GMNNoteHeads(kind: .left)
        let c = GMNNoteHeads(kind: .right)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let heads = GMNNoteHeads(kind: .normal)

        #expect(heads.appearance.isEmpty)
        #expect(heads.body.isEmpty)
        #expect(heads.ident == nil)
        #expect(heads.kind == .normal)
    }

    @Test
    func theCommonParametersAreItsOwnPositionalSlots() throws {
        // `ARTHead` never overrides `getParamsStr()`, so `kCommonParams` is
        // its positional template and the unnamed string binds `color`.
        guard case let .noteHeads(heads) = try normalizedTag("[\\headsLeft<\"red\">(c)]")
        else {
            Issue.record("Expected note-heads tag")
            return
        }

        #expect(heads.appearance.color == "red")
        #expect(heads.body.count == 1)
    }
}
