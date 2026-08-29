// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNAlterTests {
}

// MARK: -

extension GMNAlterTests {
    @Test
    func canonicalNameIsAlter() {
        #expect(GMNAlter(detune: 0).name == makeTagName("alter"))
    }

    @Test
    func equatable() {
        let a = GMNAlter(detune: 0.5)
        let b = GMNAlter(detune: 0.5)
        let c = GMNAlter(detune: 0.5,
                         text: "+")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let alter = GMNAlter(detune: -0.25)

        #expect(alter.appearance.isEmpty)
        #expect(alter.body.isEmpty)
        #expect(alter.detune == -0.25)
        #expect(alter.ident == nil)
        #expect(alter.text == nil)
    }

    @Test
    func init_fromBindingRequiresDetune() {
        #expect(GMNAlter(ident: nil,
                         binding: makeBinding("alter"),
                         body: []) == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredDetune() {
        expectRejected("[\\alter(c)]",
                       .missingRequiredParameter(makeTagName("alter"), "detune"))
    }

    @Test
    func promotes() throws {
        guard case let .alter(alter) = try normalizedTag("[\\alter<0.5,\"+q\">(c)]")
        else {
            Issue.record("Expected alter tag")
            return
        }

        #expect(alter.body.count == 1)
        #expect(alter.detune == 0.5)
        #expect(alter.text == "+q")
    }

    @Test
    func promotesWithNoBody() throws {
        // `ARAlter`'s range setting is `RANGEDC`, so both forms are legal.
        guard case let .alter(alter) = try normalizedTag("[\\alter<0.5> c]")
        else {
            Issue.record("Expected alter tag")
            return
        }

        #expect(alter.body.isEmpty)
    }
}
