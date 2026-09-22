// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNMergeTests {
}

// MARK: -

extension GMNMergeTests {
    @Test
    func canonicalNameIsMerge() {
        #expect(GMNMerge().name == makeTagName("merge"))
    }

    @Test
    func equatable() {
        let a = GMNMerge(ident: makeTagIdent(1))
        let b = GMNMerge(ident: makeTagIdent(1))
        let c = GMNMerge()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let merge = GMNMerge()

        #expect(merge.appearance.isEmpty)
        #expect(merge.body.isEmpty)
        #expect(merge.ident == nil)
    }

    @Test
    func promotes() throws {
        guard case let .merge(merge) = try normalizedTag("[\\merge(c e)]")
        else {
            Issue.record("Expected merge tag")
            return
        }

        #expect(merge.body.count == 2)
    }

    @Test
    func withAParameterHasItDroppedAndPromotes() throws {
        // `ARMerge` is not an `ARMTParameter`, so guidolib discards what was
        // written before binding. It used to keep the tag generic, on the
        // grounds that promoting would lose the parameter silently; the
        // normalizer now drops it and records
        // `droppedUnacceptedParameters`, so nothing is lost silently and the
        // tag promotes on the second pass.
        guard case .merge = try normalizedTag("[\\merge<dx=2hs>(c e)]")
        else {
            Issue.record("Expected merge tag")
            return
        }
    }
}
