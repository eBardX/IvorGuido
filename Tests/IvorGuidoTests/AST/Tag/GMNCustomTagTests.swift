// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// Every name used here is one `ARFactory::createTag` has no branch for —
// `\bembel` and `\splitChord` are declared in `Tags.cpp` and never
// dispatched, `\wibble` is invented. That is the whole admission rule for
// this type, and `init_refusesADispatchedName` is the other half of it.
struct GMNCustomTagTests {
}

// MARK: -

extension GMNCustomTagTests {
    @Test
    func `init`() {
        let tag = makeCustomTag(makeTagName("bembel"))

        #expect(tag.name == makeTagName("bembel"))
        #expect(tag.ident == nil)
        #expect(tag.parameters.isEmpty)
        #expect(tag.body.isEmpty)
    }

    @Test
    func appearanceAndParameterValuesAreAlwaysEmpty() {
        // Not an omission — there is nothing to read them from. guidolib has
        // no template for the name, so `kCommonParams` never binds, and its
        // own `ARTDummy` is handed no parameter either. The written list
        // survives on `parameters`, which is what round-tripping needs.
        let tag = makeCustomTag(makeTagName("bembel"),
                                ident: nil,
                                parameters: [makeTagParameter("color", .string("red"))])

        #expect(tag.appearance == GMNTag.Appearance())
        #expect(tag.parameterValues.isEmpty)
        #expect(tag.parameters.count == 1)
    }

    @Test
    func equatable() {
        let tag1 = makeCustomTag(makeTagName("bembel"))
        let tag2 = makeCustomTag(makeTagName("bembel"))
        let tag3 = makeCustomTag(makeTagName("splitChord"))

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func equatable_ident() {
        let tag1 = makeCustomTag(makeTagName("bembel"), ident: makeTagIdent(1))
        let tag2 = makeCustomTag(makeTagName("bembel"), ident: makeTagIdent(2))

        #expect(tag1 != tag2)
    }

    @Test
    func init_refusesADispatchedName() throws {
        // The invariant this type exists to hold, at its only entry point: a
        // known name belongs to `GMNReservedTag`, whether or not a payload
        // claims it. `\slur` has one, `\port` does not, and neither can be
        // spelled as a custom tag.
        for name in ["slur", "port", "DrHoos", "bm"] {
            let tagName = try #require(GMNTag.Name(stringValue: name))

            #expect(GMNCustomTag(ident: nil,
                                 name: tagName,
                                 parameters: [],
                                 body: []) == nil,
                    Comment(rawValue: name))
        }
    }

    @Test
    func init_withBody() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))
        let tag = makeCustomTag(makeTagName("bembel"), ident: nil, parameters: [], body: [.note(note)])

        #expect(tag.body.count == 1)
    }

    @Test
    func init_withIdent() {
        let tag = makeCustomTag(makeTagName("wibble"), ident: makeTagIdent(1))

        #expect(tag.name == makeTagName("wibble"))
        #expect(tag.ident == makeTagIdent(1))
    }

    @Test
    func init_withParameters() {
        let param = makeTagParameter("dx", .integer(5, .hs))
        let tag = makeCustomTag(makeTagName("bembel"), ident: nil, parameters: [param])

        #expect(tag.parameters.count == 1)
        #expect(tag.parameters.first == param)
    }
}
