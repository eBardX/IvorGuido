// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNPedalTests {
}

// MARK: -

extension GMNPedalTests {
    @Test
    func bothHalvesPromote() throws {
        guard case let .pedal(on) = try normalizedTag("[\\pedalOn]"),
              case let .pedal(off) = try normalizedTag("[\\pedalOff]")
        else {
            Issue.record("Expected pedal tags")
            return
        }

        #expect(on.kind == .on)
        #expect(off.kind == .off)
    }

    @Test(arguments: [(GMNPedal.Kind.off, "pedalOff"),
                      (GMNPedal.Kind.on, "pedalOn")])
    func canonicalNameFollowsTheKind(_ pair: (kind: GMNPedal.Kind, expected: String)) {
        #expect(GMNPedal(kind: pair.kind).name == makeTagName(pair.expected))
    }

    @Test
    func equatable() {
        let a = GMNPedal(kind: .on)
        let b = GMNPedal(kind: .on)
        let c = GMNPedal(kind: .off)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let pedal = GMNPedal(kind: .on)

        #expect(pedal.appearance.isEmpty)
        #expect(pedal.body.isEmpty)
        #expect(pedal.ident == nil)
        #expect(pedal.kind == .on)
    }

    @Test
    func theCommonParametersAreItsOwnPositionalSlots() throws {
        // `ARNotations` never overrides `getParamsStr()`, so `kCommonParams`
        // really is its positional template: the unnamed string binds `color`.
        guard case let .pedal(pedal) = try normalizedTag("[\\pedalOn<\"red\">]")
        else {
            Issue.record("Expected pedal tag")
            return
        }

        #expect(pedal.appearance.color == "red")
    }

    @Test
    func theKindIsNotASpan() throws {
        // `ARNotations` spells its two cases `kPedalBegin`/`kPedalEnd`, but
        // neither name is an `ARDummyRangeEnd` and neither pairs with the
        // other by identifier, so `span(of:)` answers `.whole` for both.
        guard case let .pedal(pedal) = try normalizedTag("[\\pedalOff]")
        else {
            Issue.record("Expected pedal tag")
            return
        }

        #expect(GMNTag.pedal(pedal).span == .whole)
    }
}
