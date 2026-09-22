// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBeamStateTests {
}

// MARK: -

extension GMNBeamStateTests {
    @Test(arguments: [("beamsAuto", GMNBeamState.Kind.auto),
                      ("beamsFull", .full),
                      ("beamsOff", .off)])
    func allThreeNamesPromote(_ pair: (name: String, expected: GMNBeamState.Kind)) throws {
        guard case let .beamState(state) = try normalizedTag("[\\\(pair.name)]")
        else {
            Issue.record("Expected beam-state tag")
            return
        }

        #expect(state.kind == pair.expected)
    }

    @Test
    func aWrittenParameterIsDropped() throws {
        // `ARBeamState` is not an `ARMTParameter`, so guidolib discards
        // anything written to it before binding. The tag used to stay generic
        // so that the parameter survived for the validator to see; the
        // normalizer now drops it and records `droppedUnacceptedParameters`,
        // which says the same thing at the stage that can act on it.
        guard case .beamState = try normalizedTag("[\\beamsOff<dx=2hs>]")
        else {
            Issue.record("Expected beam-state tag")
            return
        }
    }

    @Test(arguments: [(GMNBeamState.Kind.auto, "beamsAuto"),
                      (GMNBeamState.Kind.full, "beamsFull"),
                      (GMNBeamState.Kind.off, "beamsOff")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNBeamState.Kind, expected: String)) {
        #expect(GMNBeamState(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNBeamState(kind: .auto)
        let b = GMNBeamState(kind: .auto)
        let c = GMNBeamState(kind: .off)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let state = GMNBeamState(kind: .full)

        #expect(state.body.isEmpty)
        #expect(state.ident == nil)
        #expect(state.kind == .full)
    }
}
