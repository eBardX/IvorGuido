// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNClusterTests {
}

// MARK: -

extension GMNClusterTests {
    @Test
    func absentOffsetDiffersFromWrittenZero() {
        #expect(GMNCluster() != GMNCluster(hdx: GMNLength(0)))
    }

    @Test
    func canonicalNameIsCluster() {
        #expect(GMNCluster().name == makeTagName("cluster"))
    }

    @Test
    func equatable() {
        let a = GMNCluster(hdx: GMNLength(2, unit: .hs))
        let b = GMNCluster(hdx: GMNLength(2, unit: .hs))
        let c = GMNCluster(hdx: GMNLength(2, unit: .pt))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let cluster = GMNCluster()

        #expect(cluster.appearance.isEmpty)
        #expect(cluster.body.isEmpty)
        #expect(cluster.hdx == nil)
        #expect(cluster.hdy == nil)
        #expect(cluster.ident == nil)
    }

    @Test
    func promotes() throws {
        guard case let .cluster(cluster) = try normalizedTag("[\\cluster<2hs,-1.5pt>(c e)]")
        else {
            Issue.record("Expected cluster tag")
            return
        }

        #expect(cluster.body.count == 2)
        #expect(cluster.hdx == GMNLength(2, unit: .hs))
        #expect(cluster.hdy == GMNLength(-1.5, unit: .pt))
    }

    @Test
    func promotesWithNoParameters() throws {
        guard case let .cluster(cluster) = try normalizedTag("[\\cluster(c e)]")
        else {
            Issue.record("Expected cluster tag")
            return
        }

        #expect(cluster.hdx == nil)
        #expect(cluster.hdy == nil)
    }
}
