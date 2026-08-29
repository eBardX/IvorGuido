// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNDisplayDurationTests {
}

// MARK: -

extension GMNDisplayDurationTests {
    @Test
    func canonicalNameIsTheLongForm() {
        #expect(GMNDisplayDuration(numerator: 1,
                                   denominator: 4).require().name == makeTagName("displayDuration"))
    }

    @Test
    func equatable() {
        let a = GMNDisplayDuration(numerator: 1,
                                   denominator: 4).require()
        let b = GMNDisplayDuration(numerator: 1,
                                   denominator: 4).require()
        let c = GMNDisplayDuration(numerator: 1,
                                   denominator: 8).require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_admitsANegativeOrZeroNumerator() {
        // Only the denominator is constrained, and only against zero. A
        // negative or zero *numerator* is not something guidolib refuses, and
        // this phase does not invent a domain it does not state.
        #expect(GMNDisplayDuration(numerator: 0,
                                   denominator: 4) != nil)
        #expect(GMNDisplayDuration(numerator: -1,
                                   denominator: -4) != nil)
    }

    @Test
    func init_defaultsDotCountToNil() {
        let duration = GMNDisplayDuration(numerator: 3,
                                          denominator: 8).require()

        #expect(duration.denominator == 8)
        #expect(duration.dotCount == nil)
        #expect(duration.numerator == 3)
    }

    @Test
    func init_fromBindingRequiresBothHalves() {
        #expect(GMNDisplayDuration(ident: nil,
                                   binding: makeBinding("displayDuration",
                                                        [makeTagParameter("n", .integer(1, nil))]),
                                   body: []) == nil)
    }

    @Test
    func init_nonZeroDenominatorStillPromotes() throws {
        guard case let .displayDuration(payload) = try normalizedTag("[\\dispDur<1,4>(c)]")
        else {
            Issue.record("Expected a display-duration tag")

            return
        }

        #expect(payload.denominator == 4)
    }

    @Test
    func init_zeroDenominator() {
        // `ARDisplayDuration::setTagParameters` calls `fDuration.set(n, d)`,
        // which lands on `Fraction::set`; that asserts `denom != 0`
        // (`Fraction.cpp:88`).
        #expect(GMNDisplayDuration(numerator: 1,
                                   denominator: 0) == nil)
    }

    @Test
    func init_zeroDenominatorIsRejectedByThePipeline() {
        // The consequence of the initializer, seen from the outside. A
        // payload that declines leaves the tag reserved, and the validator's
        // residual check is exactly "bound cleanly and still did not promote"
        // — so the new invariant reaches the pipeline through machinery that
        // already existed, with no new issue case.
        //
        // This is a divergence from guidolib's *behaviour* and not from its
        // meaning: a release build of guidolib computes `1 / 0` and renders
        // something. The assertion is where it says what it meant.
        //
        // Reported under the name as written: both spellings are registry
        // names sharing one template, so neither is rewritten to the other.
        expectRejected("[\\dispDur<1,0>(c)]",
                       .unreadableParameterValue(makeTagName("dispDur")))
    }

    @Test
    func isRejectedWhenAnIntegerSlotIsWrittenAsAFloat() {
        // `n` is `I`, so `1.5` is a `TagParameterFloat` where a
        // `TagParameterInt` is read — inert, dropped by the normalizer, and
        // then the required `n` is missing.
        expectRejected("[\\displayDuration<1.5,4>(c)]",
                       .missingRequiredParameter(makeTagName("displayDuration"), "n"))
    }

    @Test(arguments: ["dispDur", "displayDuration"])
    func promotesFromEitherName(_ name: String) throws {
        guard case let .displayDuration(duration) = try normalizedTag("[\\\(name)<1,4,1>(c)]")
        else {
            Issue.record("Expected display-duration tag")
            return
        }

        #expect(duration.denominator == 4)
        #expect(duration.dotCount == 1)
        #expect(duration.numerator == 1)
    }
}
