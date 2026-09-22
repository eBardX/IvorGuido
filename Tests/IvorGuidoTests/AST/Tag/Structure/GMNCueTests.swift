// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNCueTests {
}

// MARK: -

extension GMNCueTests {
    @Test
    func canonicalNameIsCue() {
        #expect(GMNCue().name == makeTagName("cue"))
    }

    @Test
    func carriesItsFontParametersInTheTextStyle() throws {
        // `\cue` redeclares `fsize` among its own slots, so it binds
        // positionally while the other three font parameters are named.
        guard case let .cue(cue) = try normalizedTag("[\\cue<\"flute\",12pt,font=\"Arial\">(c)]")
        else {
            Issue.record("Expected cue tag")
            return
        }

        #expect(cue.textStyle.fontSize == GMNLength(12, unit: .pt))
        #expect(cue.textStyle.font == "Arial")
    }

    @Test
    func equatable() {
        let a = GMNCue(name: "solo")
        let b = GMNCue(name: "solo")
        let c = GMNCue(name: "tutti")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToEmpty() {
        let cue = GMNCue()

        #expect(cue.appearance.isEmpty)
        #expect(cue.body.isEmpty)
        #expect(cue.cueName == nil)
        #expect(cue.ident == nil)
        #expect(cue.textStyle.isEmpty)
    }

    @Test
    func promotes() throws {
        guard case let .cue(cue) = try normalizedTag("[\\cue<\"flute\">(c/8 d/8)]")
        else {
            Issue.record("Expected cue tag")
            return
        }

        #expect(cue.cueName == "flute")
        #expect(cue.body.count == 2)
    }
}
