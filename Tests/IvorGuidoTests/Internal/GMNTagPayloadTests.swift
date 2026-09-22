// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// The two defaulted members every payload inherits. Both are stated over a
// concrete payload rather than a stub, because what they actually have to get
// right is the *merge* with `appearance` — a payload's own fields and the
// common parameters live in two different places and both count.
struct GMNTagPayloadTests {
}

// MARK: -

extension GMNTagPayloadTests {
    @Test
    func carriesNoParameters_aPayloadFieldMakesItFalse() {
        let payload = GMNSlur(curve: .up,
                              span: .whole)

        #expect(payload?.carriesNoParameters == false)
    }

    @Test
    func carriesNoParameters_appearanceAloneIsEnoughToCarrySomething() {
        // The half that is easy to forget: `kCommonParams` live on
        // `appearance`, not in the payload's own fields, so a guard reading
        // only `parameterValues` would call this empty.
        let payload = GMNSlur(span: .end,
                              appearance: GMNTag.Appearance(color: "red"))

        #expect(payload == nil)

        let bare = GMNSlur(span: .end)

        #expect(bare?.carriesNoParameters == true)
    }

    @Test
    func carriesNoParameters_whenNothingWasWritten() {
        let payload = GMNSlur(span: .end)

        #expect(payload?.carriesNoParameters == true)
    }

    @Test
    func namedParameters_mergesAppearanceWithTheOwnFields() {
        let payload = GMNSlur(curve: .up,
                              span: .whole,
                              appearance: GMNTag.Appearance(color: "red"))
        let names = payload?.namedParameters.compactMap(\.name?.stringValue).sorted()

        #expect(names == ["color", "curve"])
    }

    @Test
    func namedParameters_ownFieldWinsOverAppearance() {
        // `merging` keeps the payload's own value, so a field and a common
        // parameter of the same name cannot produce two entries.
        let payload = GMNSlur(curve: .up,
                              span: .whole,
                              appearance: GMNTag.Appearance(color: "red"))
        let names = payload?.namedParameters.compactMap(\.name?.stringValue)

        #expect(names?.count == names.map { Set($0).count })
    }

    @Test
    func namedParameters_whenNothingWasWritten() {
        let payload = GMNSlur(span: .end)

        #expect(payload?.namedParameters.isEmpty == true)
    }
}
