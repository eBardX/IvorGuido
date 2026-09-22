// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// Bucket C is the decoration lane: tags that attach to an event rather than
// change the staff's state. Promotion is keyed on the written name, so each
// alias has to land on the same payload as its canonical spelling.
struct GMNTagPromoterBucketCTests {
}

// MARK: -

extension GMNTagPromoterBucketCTests {
    @Test
    func promoteBucketC_arpeggio() {
        guard case .arpeggio = promoteBucketC("arpeggio")
        else {
            Issue.record("Expected an arpeggio tag")

            return
        }
    }

    @Test
    func promoteBucketC_breathMark() {
        guard case .breathMark = promoteBucketC("breathMark")
        else {
            Issue.record("Expected a breath-mark tag")

            return
        }
    }

    @Test
    func promoteBucketC_declinesANameFromAnotherBucket() {
        // `\color` is bucket D, and bucket C must not claim it.
        #expect(promoteBucketC("color") == nil)
    }

    @Test
    func promoteBucketC_pedalCarriesItsKindInTheName() {
        // `pedalOn` and `pedalOff` are one payload with two names, so the
        // kind has to come from the name rather than a parameter.
        guard case let .pedal(on) = promoteBucketC("pedalOn"),
              case let .pedal(off) = promoteBucketC("pedalOff")
        else {
            Issue.record("Expected pedal tags")

            return
        }

        #expect(on.kind == .on)
        #expect(off.kind == .off)
    }

    @Test
    func promoteBucketC_slurAliasesLandOnOnePayload() {
        for name in ["sl", "slur"] {
            guard case .slur = promoteBucketC(name)
            else {
                Issue.record("Expected a slur tag for \(name)")

                return
            }
        }
    }

    @Test
    func promoteBucketC_tie() {
        guard case .tie = promoteBucketC("tie")
        else {
            Issue.record("Expected a tie tag")

            return
        }
    }
}
