// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

// The two untyped lanes and the rule that picks between them: a name
// guidolib dispatches is `.reserved`, and one it does not is `.custom`.
// Which lane a tag lands in is a fact about the *name* alone, so the factory
// can decide it without seeing the score.
struct GMNUntypedTagTests {
}

// MARK: -

extension GMNUntypedTagTests {
    @Test
    func untyped_dispatchedNameLandsOnTheReservedLane() {
        // `\accidental` is in the registry, so it is a name guidolib knows
        // even though no payload claims it.
        guard case .reserved = GMNTag.untyped(ident: nil,
                                              name: makeTagName("accidental"),
                                              parameters: [],
                                              body: [])
        else {
            Issue.record("Expected a reserved tag")

            return
        }
    }

    @Test
    func untyped_keepsWhatWasWritten() {
        let parameters = [makeTagParameter(.integer(2, .hs))]
        let tag = GMNTag.untyped(ident: makeTagIdent(1),
                                 name: makeTagName("bembel"),
                                 parameters: parameters,
                                 body: [])

        #expect(tag.untypedPayload?.parameters == parameters)
        #expect(tag.untypedPayload?.ident == makeTagIdent(1))
    }

    @Test
    func untyped_undispatchedNameLandsOnTheCustomLane() {
        guard case .custom = GMNTag.untyped(ident: nil,
                                            name: makeTagName("bembel"),
                                            parameters: [],
                                            body: [])
        else {
            Issue.record("Expected a custom tag")

            return
        }
    }

    @Test
    func untypedPayload_isNilForATypedTag() {
        // A promoted tag has a payload of its own, and reaching it through
        // the untyped lane would mean promotion had not happened.
        let tag = makePromotedTag("slur")

        #expect(tag.untypedPayload == nil)
    }

    @Test
    func untypedPayload_reachesBothLanes() {
        let custom = GMNTag.untyped(ident: nil,
                                    name: makeTagName("bembel"),
                                    parameters: [],
                                    body: [])
        let reserved = GMNTag.untyped(ident: nil,
                                      name: makeTagName("accidental"),
                                      parameters: [],
                                      body: [])

        #expect(custom.untypedPayload != nil)
        #expect(reserved.untypedPayload != nil)
    }
}
