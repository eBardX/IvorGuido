// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagTemplateTests {
}

// MARK: -

extension GMNTagTemplateTests {
    @Test
    func alternateParameterKinds_isEmptyForEveryOtherName() throws {
        // Two entries in the whole registry. Asserting the *count* rather than
        // the two names is what makes a third one — added without re-running
        // the per-class grep — visible here.
        var alternates: Set<String> = []

        for name in GMNTagTemplate.Registry.names.sorted() {
            let tagName = try #require(GMNTag.Name(stringValue: name))
            let template = try #require(GMNTagTemplate.Registry.template(for: tagName))

            alternates.formUnion(template.alternateParameterKinds.keys)
        }

        #expect(alternates == ["id", "key"])
    }

    @Test
    func commonSlots_matchKCommonParams() {
        #expect(GMNTagTemplate.commonSlots.map { $0.name } == ["color", "dx", "dy", "size"])
    }

    @Test
    func hasNoPositionalSlots_reflectsAnEmptyTemplateString() throws {
        let segno = try template("segno")
        let coda = try template("coda")

        // Both are `ARJump` subclasses supporting `m` and `id`, but only
        // `\segno` overrides `getParamsStr()` to `""` — a transcription trap.
        #expect(segno.hasNoPositionalSlots)
        #expect(!coda.hasNoPositionalSlots)
        #expect(segno.supportedParameter(named: "m") != nil)
        #expect(coda.slots.map { $0.name } == ["m", "id"])
    }

    @Test
    func init_derivesIsFontAbleFromTheConstructionChain() throws {
        let tempo = try template("tempo")
        let clef = try template("clef")

        #expect(tempo.isFontAble)
        #expect(!clef.isFontAble)
        #expect(tempo.supportedParameter(named: "fattrib") != nil)
        #expect(clef.supportedParameter(named: "fattrib") == nil)
    }

    @Test
    func init_letsALaterSpecificationOverwriteAnEarlierOne() throws {
        // `ARMusicalTag::init` adds `kCommonParams` first, then each
        // `setupTagParameters` call overwrites by name. `\harmony`
        // redeclares `dy` with a default of `-1`, shadowing the common `0`,
        // and keeps its original position in the accumulated set.
        let template = try template("harmony")
        let slot = try #require(template.supportedParameter(named: "dy"))

        #expect(slot.defaultValue == "-1")
        #expect(template.supportedParameters.filter { $0.name == "dy" }.count == 1)
    }

    @Test
    func init_prependsCommonParametersToTheSupportedSet() {
        let template = GMNTagTemplate(slotSpecification: GMNTagTemplate.Specification.arClef,
                                      parameterSpecifications: [GMNTagTemplate.Specification.arClef],
                                      rangeSetting: .no)

        #expect(template.slots.map { $0.name } == ["type"])
        #expect(template.supportedParameters.map { $0.name } == ["color", "dx", "dy", "size", "type"])
    }

    @Test
    func reads_acceptsEitherTypeWhereTheClassReadsTheNameTwice() throws {
        // The two pairs `alternateParameterKinds` records. `\key` declares `S`
        // and reads an int second (`ARKey.cpp:88–96`); `\staff` declares `I`
        // and reads a string second (`ARStaff.cpp:50–64`).
        let key = try template("key")
        let staff = try template("staff")

        #expect(key.reads(.string("D"), as: "key"))
        #expect(key.reads(.integer(2, nil), as: "key"))
        #expect(staff.reads(.integer(2, nil), as: "id"))
        #expect(staff.reads(.string("upper"), as: "id"))
    }

    @Test
    func reads_acceptsOnlyTheDeclaredTypeEverywhereElse() throws {
        // The second read is a property of a class, not of a name. `id` on
        // `\coda` and `h` on `\symbol` are the
        // same two names, read once each.
        let coda = try template("coda")
        let symbol = try template("symbol")

        #expect(coda.reads(.integer(1, nil), as: "id"))
        #expect(!coda.reads(.string("fine"), as: "id"))
        #expect(symbol.reads(.integer(2, nil), as: "h"))
        #expect(!symbol.reads(.string("tall"), as: "h"))
    }

    @Test
    func reads_declinesANameTheTagDoesNotSupport() throws {
        // No slot to measure against; `checkExist` has already accounted for
        // it, and answering `true` here would let an unsupported name pass as
        // live.
        let key = try template("key")

        #expect(!key.reads(.string("D"), as: "bogus"))
    }

    @Test
    func slots_areEmptyForAnEmptySpecification() {
        #expect(GMNTagTemplate.slots(from: "").isEmpty)
    }

    @Test
    func slots_dropGuidolibsStrayTrailingSeparator() {
        // `kARFingeringParams` ends with a `;`, which `split` turns into an
        // empty final element and `str2tagParam` refuses.
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.arFingering)

        #expect(slots.map { $0.name } == ["position", "fsize"])
    }

    @Test
    func slots_preserveDeclarationOrder() {
        // Declaration order is what `checkTagParameters` binds against, so
        // it must survive verbatim — `TagParameterMap`'s own no-argument
        // `getKeys()` sorts alphabetically and is *not* what is used here.
        let slots = GMNTagTemplate.slots(from: GMNTagTemplate.Specification.arTempo)

        #expect(slots.map { $0.name } == ["tempo", "bpm", "font", "textformat", "fsize"])
    }
}
