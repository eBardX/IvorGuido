// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// Every name built here is one `ARFactory::createTag` dispatches. That is the
// whole admission rule for this lane — *not* "no payload claims it", which is
// a property of the normalized score rather than of the value, and which
// `GMNTagCatalogueClosureTests` states over all 161 names.
//
// The rule is no longer stated by an initializer of this type, which has no
// public one: it is stated by `GMNTag.untyped(ident:name:parameters:body:)`,
// which chooses the lane. The two `lane_` tests below are what pins it, and
// they are the only ones here naming an undispatched tag.
struct GMNReservedTagTests {
}

// MARK: -

extension GMNReservedTagTests {
    @Test
    func `init`() {
        let tag = makeReservedTag(makeTagName("slur"))

        #expect(tag.name == makeTagName("slur"))
        #expect(tag.ident == nil)
        #expect(tag.parameters.isEmpty)
        #expect(tag.body.isEmpty)
    }

    @Test
    func bindsAgainstItsOwnTemplate() {
        // The other half of the difference from `GMNCustomTag`: a dispatched
        // name has a template, so `kCommonParams` and the tag's own slots
        // both bind even though nothing promoted.
        let tag = makeReservedTag(makeTagName("tempo"),
                                  ident: nil,
                                  parameters: [makeTagParameter(.string("Allegro"))])

        #expect(tag.template != nil)
        #expect(tag.binding?.values["tempo"] == .string("Allegro"))
    }

    @Test
    func equatable() {
        let tag1 = makeReservedTag(makeTagName("slur"))
        let tag2 = makeReservedTag(makeTagName("slur"))
        let tag3 = makeReservedTag(makeTagName("tie"))

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func equatable_ident() {
        let tag1 = makeReservedTag(makeTagName("slur"), ident: makeTagIdent(1))
        let tag2 = makeReservedTag(makeTagName("slur"), ident: makeTagIdent(2))

        #expect(tag1 != tag2)
    }

    @Test
    func init_hasNoPublicEntryPoint() throws {
        // The lane is readable but not constructible outside the package, so
        // none of the three parameter `GMNValidator.Issue` cases can be reached by
        // hand through it. Stated where it can still be seen: this suite
        // builds its values through the internal initializer, which nothing
        // outside `IvorGuido` can name.
        //
        // `GMNCustomTag` deliberately keeps its public initializer — an
        // undispatched name has no template, so there is nothing to judge it
        // against and nothing to refuse.
        #expect(try GMNCustomTag(ident: nil,
                                 name: #require(GMNTag.Name(stringValue: "wibble")),
                                 parameters: [],
                                 body: []) != nil)
    }

    @Test
    func init_withBody() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let tag = makeReservedTag(makeTagName("slur"), ident: nil, parameters: [], body: [.note(note)])

        #expect(tag.body.count == 1)
    }

    @Test
    func init_withIdent() {
        let tag = makeReservedTag(makeTagName("tieBegin"), ident: makeTagIdent(1))

        #expect(tag.name == makeTagName("tieBegin"))
        #expect(tag.ident == makeTagIdent(1))
    }

    @Test
    func init_withParameters() {
        let param = makeTagParameter("dx", .integer(5, .hs))
        let tag = makeReservedTag(makeTagName("staffFormat"), ident: nil, parameters: [param])

        #expect(tag.parameters.count == 1)
        #expect(tag.parameters.first == param)
    }

    @Test
    func lane_admitsADispatchedNameNoPayloadClaimsAndOneEveryPayloadDoes() throws {
        // Decision B′ in one assertion, now stated where the rule lives.
        // The three permanent residents and an alias of a fully modelled tag
        // are equally admissible here, because the test is dispatch: a
        // lossless parser has to be able to carry `\bm<bogus=1>` before the
        // normalizer repairs it.
        for name in ["port", "DrHoos", "DrRenz", "bm", "slur"] {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            guard case .reserved = GMNTag.untyped(ident: nil,
                                                  name: tagName,
                                                  parameters: [],
                                                  body: [])
            else {
                Issue.record("Expected \(name) on the reserved lane")
                continue
            }
        }
    }

    @Test
    func lane_sendsAnUndispatchedNameToCustomInstead() throws {
        // The invariant this type exists to hold. `\bembel` and `\splitChord`
        // are declared in `Tags.cpp` and never dispatched; `\wibble` is
        // nobody's.
        for name in ["bembel", "splitChord", "wibble"] {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            guard case .custom = GMNTag.untyped(ident: nil,
                                                name: tagName,
                                                parameters: [],
                                                body: [])
            else {
                Issue.record("Expected \(name) on the custom lane")
                continue
            }
        }
    }
}
