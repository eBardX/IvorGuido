// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// The catalog-closure test: with bucket D landed, the catalog is
// complete, and this pins that against regression rather than establishing
// it. The attribution itself was verified by hand during design, so a
// failure here means a payload or a registry entry drifted, not that
// something new was discovered.
//
// Every assertion is stated against `GMNTagTemplate.Registry`, so a name added
// there without a payload fails, and a payload that stops claiming a name
// fails too.
//
// Decision B′, stated over all 161 registry names rather than in a comment.
// The two invariants hold at different scopes on purpose, and the difference
// is the whole of the decision: dispatch is checkable by a value alone, so it
// is an initializer's rule and holds everywhere; "no payload claims it" is a
// fact about how far a score has been through the pipeline, so it is a
// normalized-stage rule and holds only there.
struct GMNTagTemplateRegistryTests {
}

// MARK: -

extension GMNTagTemplateRegistryTests {
    @Test
    func anUndispatchedNameIsCustomAtEveryStage() throws {
        // The other lane end to end. `\bembel` is declared in `Tags.cpp` and
        // never dispatched, so guidolib builds an `ARTDummy` for it and
        // IvorGuido has nothing to model — at the parser, after the
        // normalizer, and in the formatted text, which round-trips.
        let input = "[\\bembel<color=\"red\"> c]"
        let (parsed, _) = try GMNParser().parse(Data(input.utf8))

        #expect(isCustom(parsed))

        let normalized = try normalizeScore(input)

        #expect(isCustom(normalized))
        #expect(try formatScore(normalized) == input)
    }

    @Test
    func classesOutsideARMTParameterAcceptNoParameters() throws {
        for name in ["beamsAuto", "beamsFull", "beamsOff", "merge", "newPage", "port"] {
            #expect(try !template(name).acceptsParameters, "\(name)")
        }

        // The near-miss: `\newSystem` and `\newLine` share `\newPage`'s
        // schema but *are* `ARMTParameter`s.
        #expect(try template("newLine").acceptsParameters)
        #expect(try template("newSystem").acceptsParameters)
    }

    @Test
    func commonParametersAreSlotsOnlyWhereGuidolibPutsThem() throws {
        // The plan's invariant was "`kCommonParams` never appears in any
        // `slots`". guidolib does not honor it, in two separate ways, and
        // both are pinned here because both change what the formatter may
        // emit unnamed.
        //
        //   - **Inherited**: `ARMusicalTag::getParamsStr()` returns
        //     `kCommonParams` itself (`ARMusicalTag.h:61`), so a class that
        //     never overrides it binds `color`/`dx`/`dy`/`size` by position.
        //   - **Redeclared**: a class's own template may name one of the
        //     four — `kARBeamParams` opens with `U,dy,0,o`, so `\beam<2hs>`
        //     binds `dy`, and `kARColorParams` is nothing but `color`.
        //
        // What remains true, and is what the rule actually depends on, is
        // that `kCommonParams` is never *appended* to a tag's own template:
        // `slots` is always exactly what `getParamsStr()` returns.
        let commonNames = Set(GMNTagTemplate.commonSlots.map { $0.name })
        let orderedCommonNames = GMNTagTemplate.commonSlots.map { $0.name }

        var inheriting: Set<String> = []
        var redeclaring: Set<String> = []

        for name in GMNTagTemplate.Registry.names {
            let slots = try template(name).slots.map { $0.name }

            if slots == orderedCommonNames {
                inheriting.insert(name)
            } else if !Set(slots).isDisjoint(with: commonNames) {
                redeclaring.insert(name)
            }
        }

        #expect(inheriting == ["accelEnd",
                               "beamEnd",
                               "crescEnd",
                               "decrescEnd",
                               "dimEnd",
                               "diminuendoEnd",
                               "fBeamEnd",
                               "glissandoEnd",
                               "ritEnd",
                               "slurEnd",
                               "staccEnd",
                               "tieEnd",
                               "tremEnd",
                               "tremoloEnd",
                               "trillEnd",
                               "tupletEnd",
                               "voltaEnd",
                               "headsCenter",
                               "headsLeft",
                               "headsNormal",
                               "headsReverse",
                               "headsRight",
                               "newLine",
                               "newPage",
                               "newSystem",
                               "pedalOff",
                               "pedalOn",
                               "port",
                               "repeatBegin",
                               "systemFormat"])

        #expect(redeclaring == ["b",
                                "beam",
                                "beamBegin",
                                "bm",
                                "color",
                                "colour",
                                "fing",
                                "fingering",
                                "harmony",
                                "label",
                                "lyrics",
                                "mark",
                                "staffFormat",
                                "t",
                                "text",
                                "title"])
    }

    @Test
    func everyDispatchedNamePromotes() throws {
        // Each name is written with exactly the parameters its own template
        // requires, synthesized from the declared kind of each required slot
        // — the point being that requiredness, not typing, is the only thing
        // standing between a bare name and its payload.
        for name in GMNTagTemplate.Registry.names.sorted()
        where !Fixtures.namesThatStayReserved.contains(name) {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            #expect(!isReserved(tagName),
                    "\(name) did not promote to a typed payload")
        }
    }

    @Test
    func everyPayloadReportsANameTheRegistryKnows() throws {
        // Rule 1 stated as a closed loop: a payload's canonical name must
        // itself be dispatched, or formatting it would produce a score that
        // no longer parses back to the same case.
        for name in GMNTagTemplate.Registry.names.sorted()
        where !Fixtures.namesThatStayReserved.contains(name) {
            let tagName = try #require(GMNTag.Name(stringValue: name))
            let promoted = promote(tagName)

            #expect(GMNTagTemplate.Registry.names.contains(promoted.name.stringValue),
                    "\(name) reports the undispatched canonical name \(promoted.name.stringValue)")
        }
    }

    @Test
    func everyStage_noCustomTagHasADispatchedName() throws {
        // Enforced by the initializer, so there is no stage at which it could
        // fail to hold — which is what makes it testable this way, against
        // the type rather than against a pipeline run.
        for name in GMNTagTemplate.Registry.names.sorted() {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            #expect(GMNCustomTag(ident: nil,
                                 name: tagName,
                                 parameters: [],
                                 body: []) == nil,
                    "\(name) is dispatched and must not be spellable as a custom tag")
        }
    }

    @Test
    func everyStage_promotionNeverProducesACustomTagForADispatchedName() throws {
        // The same invariant seen from the only code path that builds an
        // untyped tag without going through a public initializer.
        for name in GMNTagTemplate.Registry.names.sorted() {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            if case .custom = promote(tagName) {
                Issue.record("\(name) promoted to a custom tag")
            }
        }
    }

    @Test
    func exactlyThreeDispatchedNamesStayReserved() throws {
        // `\port` builds an `ARTDummy` and means nothing; `\DrHoos` and
        // `\DrRenz` are real classes with a real parameter that
        // simply fall outside the catalog. All three are in the registry —
        // they bind, they just have nowhere to go.
        for name in Fixtures.namesThatStayReserved {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            #expect(isReserved(tagName),
                    "\(name) should have stayed reserved")
        }
    }

    @Test
    func fingeringBindsPositionsAgainstItsBaseClassTemplate() throws {
        // `ARFingering : ARText` never overrides `getParamsStr()`, so its
        // positional slots come from `kARTextParams` while its supported set
        // adds `kARFingeringParams` on top.
        let template = try template("fingering")

        #expect(template.slots.map { $0.name } == ["text", "dy", "textformat", "fsize"])
        #expect(template.supportedParameter(named: "position") != nil)
    }

    @Test
    func normalizedStage_theOnlyReservedNamesAreTheThree() throws {
        // One hand-built score carrying every dispatched name, written with
        // exactly the parameters its own template requires, run through the
        // normalizer. What comes back untyped is the answer — no name is
        // exempted, and the set is compared whole rather than sampled.
        let tags = try GMNTagTemplate.Registry.names.sorted().map { name -> GMNSymbol in
            let tagName = try #require(GMNTag.Name(stringValue: name))

            return .tag(GMNTag.untyped(ident: nil,
                                       name: tagName,
                                       parameters: requiredParameters(tagName),
                                       body: []))
        }

        let (normalized, _) = GMNNormalizer().normalize(GMNScore(variables: [],
                                                                 voices: [GMNVoice(symbols: tags)]))

        var reserved: Set<String> = []

        for symbol in normalized.voices[0].symbols {
            guard case let .tag(tag) = symbol,
                  case let .reserved(payload) = tag
            else { continue }

            reserved.insert(payload.name.stringValue)
        }

        #expect(reserved == GMNTagPromoter.namesWithoutPayload)
    }

    @Test
    func pageFormatColorIsSupportedButHasNoSlot() throws {
        // Neither hand-built template declares `color`; `kCommonParams` still
        // supplies it, as it does for every tag.
        let template = try template("pageFormat")

        #expect(!template.slots.contains { $0.name == "color" })
        #expect(template.supportedParameter(named: "color") != nil)
    }

    @Test
    func pageFormatPicksItsTemplatePerTag() throws {
        // `ARPageFormat::checkTagParameters` (`ARPageFormat.cpp:136–149`) is
        // the catalogue's only override: it builds the positional template on
        // the spot, choosing a page named by `type` or one sized by `w` and
        // `h`, and removes the loser from the supported set outright.
        let name = try #require(GMNTag.Name(stringValue: "pageFormat"))
        let margins = ["lm", "tm", "rm", "bm"]

        let byType = try #require(GMNTagTemplate.Registry.template(for: name,
                                                                   parameters: [makeTagParameter(.string("a4"))]))
        let bySize = try #require(GMNTagTemplate.Registry.template(for: name,
                                                                   parameters: [makeTagParameter(.integer(21, .cm))]))

        #expect(byType.slots.map { $0.name } == ["type"] + margins)
        #expect(bySize.slots.map { $0.name } == ["w", "h"] + margins)

        // An empty list takes `checkTagParameters`' `else` branch.
        #expect(GMNTagTemplate.Registry.template(for: name)?.slots.map { $0.name } == ["w", "h"] + margins)
    }

    @Test
    func rangeSettingsMatchTheReferencePoints() throws {
        for name in ["slur", "beam", "tuplet", "grace", "cluster", "volta", "lyrics", "trill"] {
            #expect(try template(name).rangeSetting == .only, "\(name)")
        }

        for name in ["composer", "title", "footer", "mark", "endBar"] {
            #expect(try template(name).rangeSetting == .no, "\(name)")
        }

        for name in ["text", "fermata", "octava", "alter", "noteFormat", "symbol", "harmony"] {
            #expect(try template(name).rangeSetting == .either, "\(name)")
        }
    }

    @Test
    func registry_coversExactlyTheDispatchedNames() {
        // 158 of `Tags.cpp`'s 162 constants (four are declared but never
        // dispatched — see `undispatchedNamesHaveNoTemplate`), plus the two
        // bare-literal names `DrHoos` and `DrRenz` (`ARFactory.cpp:1613`,
        // `:1619`), plus the bar-line shorthand `"|"` that `guido.y:180`
        // rewrites to `\bar`.
        #expect(GMNTagTemplate.Registry.names.count == 161)
    }

    @Test
    func registry_hasNoNameDeclaredTwice() {
        // The transcription hazard this guards is a name landing in two
        // entries with different templates; the dictionary would silently
        // keep whichever came last.
        let declared = GMNTagTemplate.Registry.entries.flatMap { $0.names }

        #expect(declared.count == GMNTagTemplate.Registry.names.count)
    }

    @Test
    func registry_resolvesEveryNameItClaims() throws {
        for name in GMNTagTemplate.Registry.names {
            let tagName = try #require(GMNTag.Name(stringValue: name),
                                       "\(name) is not a representable tag name")

            #expect(GMNTagTemplate.Registry.template(for: tagName) != nil,
                    "\(name) has no template")
        }
    }

    @Test
    func theCatalogueIsFiftyNinePayloads() throws {
        // 10 (bucket A) + 22 (bucket B) + 13 (bucket C) + 14 (bucket D). One
        // case per payload, and neither untyped lane is one of them.
        var cases: Set<String> = []

        for name in GMNTagTemplate.Registry.names
        where !Fixtures.namesThatStayReserved.contains(name) {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            try cases.insert(#require(caseName(tagName)))
        }

        #expect(cases.count == 59)
        #expect(!cases.contains("custom"))
        #expect(!cases.contains("reserved"))
    }

    @Test
    func theParserEmitsReservedForADispatchedNameItCouldNotPromote() throws {
        // The third checkbox of the phase, and the reason the initializer
        // constrains on dispatch rather than on the three names: each of
        // these is a *dispatched* name the parser must carry untyped, because
        // repairing it is the normalizer's job and the parser is lossless.
        for input in ["[\\bm<bogus=1> c]",
                      "[\\beam<foo> c]",
                      "[\\staccato<0.5> c]",
                      "[\\slurEnd<dx=2hs> c]"] {
            let (parsed, _) = try GMNParser().parse(Data(input.utf8))

            guard case let .tag(tag) = parsed.voices[0].symbols[0],
                  case .reserved = tag
            else {
                Issue.record(Comment(rawValue: "\(input) did not parse to a reserved tag"))

                continue
            }
        }
    }

    @Test
    func tieAndSlurShareOneShape() throws {
        // `ARTie : ARBowing`, verbatim the same template as `ARSlur` — a
        // transcription trap.
        #expect(try template("tie") == template("slur"))
    }

    @Test
    func undispatchedNamesHaveNoTemplate() throws {
        // Declared in `Tags.cpp` but matched by no branch of
        // `ARFactory::createTag`, so each falls to the unknown-name
        // `ARTDummy` at `:1636–1640`. A `nil` template is what keeps them
        // `.generic`.
        for name in ["bembel", "chord", "shortFermata", "splitChord"] {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            #expect(GMNTagTemplate.Registry.template(for: tagName) == nil,
                    "\(name) should not be in the registry")
        }
    }

    @Test
    func zeroSlotClassesHaveNoPositionalSlots() throws {
        // Eleven dispatched names covering the nine zero-slot classes that
        // are reachable by tag name — those overriding `getParamsStr()` to
        // `""`. The other nine such classes — `ARChordComma`,
        // `ARChordTag`, `ARNaturalKey`, `ARNote`, `ARPossibleBreak`,
        // `ARRepeatEndRangeEnd`, `ARRest`, `ARSecondGlue`, `ARShareStem` —
        // are not reachable by tag name at all.
        for name in ["beamsAuto",
                     "beamsFull",
                     "beamsOff",
                     "breathMark",
                     "dotFormat",
                     "merge",
                     "restFormat",
                     "segno",
                     "shareLocation",
                     "staffOff",
                     "staffOn"] {
            #expect(try template(name).hasNoPositionalSlots,
                    "\(name) should have no positional slots")
        }
    }
}
