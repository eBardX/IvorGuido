// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagPromoterTests {
}

// MARK: -

extension GMNTagPromoterTests {
    @Test
    func promote_acceptsSuchATagWhenNothingWasWritten() {
        guard case .merge = GMNTagPromoter.promote(ident: nil,
                                                   name: makeTagName("merge"),
                                                   parameters: [],
                                                   body: [])
        else {
            Issue.record("Expected merge tag")
            return
        }
    }

    @Test
    func promote_declinesAnUnmatchedBinding() {
        // An unsupported parameter name is guidolib's own `checkExist`
        // failure and keeps the tag reserved.
        guard case .reserved = GMNTagPromoter.promote(ident: nil,
                                                      name: makeTagName("meter"),
                                                      parameters: [makeTagParameter(.string("4/4")),
                                                                   makeTagParameter("bogus", .string("x"))],
                                                      body: [])
        else {
            Issue.record("Expected reserved tag")
            return
        }
    }

    @Test
    func promote_declinesARawIdentifier() {
        // guidolib discards a raw identifier before binding
        // (`GuidoParser.cpp:291`); IvorGuido keeps it, which no typed field
        // can hold.
        guard case .reserved = GMNTagPromoter.promote(ident: nil,
                                                      name: makeTagName("accidental"),
                                                      parameters: [makeTagParameter(.parameter("rawIdent"))],
                                                      body: [])
        else {
            Issue.record("Expected reserved tag")
            return
        }
    }

    @Test(arguments: ["beamsAuto", "merge", "newPage", "port"])
    func promote_declinesATagThatKeepsNoParameters(_ name: String) {
        // These six names are not `ARMTParameter`s, so
        // `ARFactory::addTagParameter` throws away what was written before
        // binding (`ARFactory.cpp:2012–2016`). Binding yields an empty map, so
        // a payload built from it would carry nothing — the tag stays
        // reserved instead, where the value survives for the validator to
        // report.
        guard case let .reserved(tag) = GMNTagPromoter.promote(ident: nil,
                                                               name: makeTagName(name),
                                                               parameters: [makeTagParameter("dx", .integer(2, .hs))],
                                                               body: [])
        else {
            Issue.record("Expected reserved tag")
            return
        }

        #expect(tag.parameters.count == 1)
    }

    @Test
    func promote_declinesAUnitOnARatio() {
        // `size` is `F` — a bare ratio — so a unit written on it has nowhere
        // to go in a `Double` field.
        guard case .reserved = GMNTagPromoter.promote(ident: nil,
                                                      name: makeTagName("cluster"),
                                                      parameters: [makeTagParameter("size", .integer(2, .hs))],
                                                      body: [])
        else {
            Issue.record("Expected reserved tag")
            return
        }
    }

    @Test
    func promote_isIdempotent() {
        // The catalog is closed, so "still untyped, but not for want of a
        // template" now means one of the three names kept reserved on
        // purpose. `\\DrRenz` is a real class with a real
        // parameter (`"I,inverse,0,o"`, `ARFactory.cpp:1619`) that simply
        // falls outside the catalog, so it binds cleanly and still has
        // nowhere to go.
        let once = GMNTagPromoter.promote(ident: nil,
                                          name: makeTagName("DrRenz"),
                                          parameters: [makeTagParameter(.integer(1, nil))],
                                          body: [])

        guard case let .reserved(tag) = once
        else {
            Issue.record("Expected reserved tag")
            return
        }

        let twice = GMNTagPromoter.promote(ident: tag.ident,
                                           name: tag.name,
                                           parameters: tag.parameters,
                                           body: tag.body)

        #expect(once == twice)
    }

    @Test
    func promote_isIdempotentOverATypedPayload() {
        let once = GMNTagPromoter.promote(ident: nil,
                                          name: makeTagName("acc"),
                                          parameters: [makeTagParameter(.string("cautionary"))],
                                          body: [])

        let twice = GMNTagPromoter.promote(ident: once.ident,
                                           name: once.name,
                                           parameters: once.payload.namedParameters,
                                           body: once.body)

        #expect(once == twice)
    }

    @Test
    func promote_isIdempotentOverBucketB() {
        // Promotion runs in the parser and again in the normalizer, so a
        // payload rebuilt from its own parameters must come back identical.
        let promoted = GMNTagPromoter.promote(ident: nil,
                                              name: makeTagName("instrument"),
                                              parameters: [makeTagParameter(.string("Horn")),
                                                           makeTagParameter("MIDI", .integer(61, nil))],
                                              body: [])
        let repromoted = GMNTagPromoter.promote(ident: promoted.ident,
                                                name: promoted.name,
                                                parameters: promoted.payload.namedParameters,
                                                body: promoted.body)

        #expect(promoted == repromoted)
    }

    @Test
    func promote_isTotal() {
        // Every name promotes to *something*, whether or not guidolib
        // dispatches it and whether or not what was written makes sense.
        for name in ["slur", "tempo", "bembel", "|"] {
            let tag = GMNTagPromoter.promote(ident: nil,
                                             name: makeTagName(name),
                                             parameters: [makeTagParameter("bogus", .integer(1, nil))],
                                             body: [])

            #expect(tag.name == makeTagName(name))
        }
    }

    @Test
    func promote_preservesEverythingWritten() {
        let parameters = [makeTagParameter(.integer(1, nil)),
                          makeTagParameter("dx", .integer(5, .hs))]
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))

        // As in `promote_isIdempotent`, a dispatched name with no payload.
        guard case let .reserved(tag) = GMNTagPromoter.promote(ident: makeTagIdent(2),
                                                               name: makeTagName("DrRenz"),
                                                               parameters: parameters,
                                                               body: [.note(note)])
        else {
            Issue.record("Expected reserved tag")
            return
        }

        #expect(tag.name == makeTagName("DrRenz"))
        #expect(tag.ident == makeTagIdent(2))
        #expect(tag.parameters == parameters)
        #expect(tag.body.count == 1)
    }
}
