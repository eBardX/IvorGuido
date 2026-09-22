// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBreathMarkTests {
}

// MARK: -

extension GMNBreathMarkTests {
    @Test
    func canonicalNameIsBreathMark() {
        #expect(GMNBreathMark().name == makeTagName("breathMark"))
    }

    @Test
    func equatable() {
        let a = GMNBreathMark()
        let b = GMNBreathMark()
        let c = GMNBreathMark(appearance: GMNTag.Appearance(color: "red"))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let breathMark = GMNBreathMark()

        #expect(breathMark.appearance.isEmpty)
        #expect(breathMark.body.isEmpty)
        #expect(breathMark.ident == nil)
    }

    @Test
    func itHasNoParametersOfItsOwn() {
        // `ARBreathMark` overrides `getParamsStr()` to `""` and adds no map,
        // so `kCommonParams` is the whole of what it accepts.
        #expect(GMNBreathMark().parameterValues.isEmpty)
    }

    @Test
    func promotes() throws {
        guard case .breathMark = try normalizedTag("[\\breathMark]")
        else {
            Issue.record("Expected breathMark tag")
            return
        }
    }

    @Test
    func theCommonParametersAreStillAcceptedAndAlwaysNamed() throws {
        guard case let .breathMark(breathMark) = try normalizedTag("[\\breathMark<dx=2hs>]")
        else {
            Issue.record("Expected breathMark tag")
            return
        }

        #expect(breathMark.appearance.dx == GMNLength(2, unit: .hs))
    }
}
