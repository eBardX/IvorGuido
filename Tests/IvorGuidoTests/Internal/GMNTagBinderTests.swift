// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagBinderTests {
}

// MARK: -

extension GMNTagBinderTests {
    @Test
    func bind_acceptsCommonParametersOnEveryTag() throws {
        let binding = try bind("staccato",
                               [value(.floating(2, .hs), named: "dx"),
                                value(.string("red"), named: "color")])

        #expect(binding.unsupportedParameterNames.isEmpty)
        #expect(binding.isMatched)
    }

    @Test
    func bind_bindsCommonParametersByPositionOnlyWhereGuidolibDoes() throws {
        // `\systemFormat` never overrides `getParamsStr()`, so its
        // positional slots really are `kCommonParams`.
        let inherited = try bind("systemFormat", [value(.string("red"))])

        #expect(inherited.values["color"] == .string("red"))

        // `\clef` does override it, so an unnamed second parameter has
        // nowhere to go — `color` is not a positional slot there.
        let overridden = try bind("clef",
                                  [value(.string("treble")),
                                   value(.string("red"))])

        #expect(overridden.failure == .unboundPositionalParameter(index: 1))
    }

    @Test
    func bind_bindsNothingForAnEmptyParameterList() throws {
        let binding = try bind("clef", [])

        #expect(binding.values.isEmpty)
        #expect(binding.missingRequiredParameterNames == ["type"])
    }

    @Test
    func bind_discardsEverythingForATagOutsideARMTParameter() throws {
        let binding = try bind("newPage", [value(.string("red"), named: "color")])

        #expect(binding.values.isEmpty)
        #expect(binding.failure == nil)
    }

    @Test
    func bind_keepsNamedParametersUnderTheirOwnNames() throws {
        let binding = try bind("tempo",
                               [value(.string("Allegro")),
                                value(.string("Arial"), named: "font")])

        #expect(binding.values["tempo"] == .string("Allegro"))
        #expect(binding.values["font"] == .string("Arial"))
        #expect(binding.values["bpm"] == nil)
        #expect(binding.isMatched)
    }

    @Test
    func bind_letsTheLastDuplicateWin() throws {
        let binding = try bind("clef",
                               [value(.string("treble"), named: "type"),
                                value(.string("bass"), named: "type")])

        #expect(binding.values["type"] == .string("bass"))
        #expect(binding.values.count == 1)
    }

    @Test
    func bind_namesUnnamedParametersByPosition() throws {
        let binding = try bind("tempo",
                               [value(.string("Allegro")),
                                value(.string("1/4=120"))])

        #expect(binding.failure == nil)
        #expect(binding.values["tempo"] == .string("Allegro"))
        #expect(binding.values["bpm"] == .string("1/4=120"))
        #expect(binding.isMatched)
    }

    @Test
    func bind_reportsUnsupportedParameterNames() throws {
        let binding = try bind("staccato", [value(.integer(1, nil), named: "bogus")])

        #expect(binding.unsupportedParameterNames == ["bogus"])
        #expect(!binding.isMatched)
    }

    @Test
    func bind_reproducesTheTempoCorruptionCase() throws {
        // The corruption case: the loop index is the *written* position,
        // so the unnamed `"Allegro"` at index 1 takes `keys[1]` — `bpm` —
        // overwriting the bpm the author named, and leaving the required
        // `tempo` unset. guidolib does exactly this, silently.
        let binding = try bind("tempo",
                               [value(.string("1/4=120"), named: "bpm"),
                                value(.string("Allegro"))])

        #expect(binding.values["bpm"] == .string("Allegro"))
        #expect(binding.values["tempo"] == nil)
        #expect(binding.missingRequiredParameterNames == ["tempo"])
        #expect(!binding.isMatched)
    }

    @Test
    func bind_skipsARawIdentifierWithoutConsumingASlot() throws {
        // guidolib's grammar nulls a bare identifier before `ARFactory` sees
        // it, so it never occupies a position. IvorGuido keeps it in the AST
        // for round-tripping; the binder must still not count it, or every
        // later positional binding drifts by one.
        let binding = try bind("tempo",
                               [value(.parameter("rawIdent")),
                                value(.string("Allegro")),
                                value(.string("1/4=120"))])

        #expect(binding.values["tempo"] == .string("Allegro"))
        #expect(binding.values["bpm"] == .string("1/4=120"))
        #expect(binding.failure == nil)
    }

    @Test
    func bind_stopsAtAnUnnamedParameterPastTheTemplate() throws {
        // `\clef` has exactly one slot. guidolib warns and `break`s: what
        // bound before the offender survives, what follows it does not.
        let binding = try bind("clef",
                               [value(.string("treble")),
                                value(.string("stray")),
                                value(.string("red"), named: "color")])

        #expect(binding.failure == .unboundPositionalParameter(index: 1))
        #expect(binding.values["type"] == .string("treble"))
        #expect(binding.values["color"] == nil)
        #expect(!binding.isMatched)
    }
}
