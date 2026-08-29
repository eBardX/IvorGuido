// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagTests {
}

// MARK: -

extension GMNTagTests {
    @Test
    func appearance() {
        let tag = makeTag(makeTagName("slur"),
                          parameters: [makeTagParameter("dx", .integer(5, .hs)),
                                       makeTagParameter("color", .string("red"))])

        #expect(tag.appearance == GMNTag.Appearance(color: "red",
                                                    dx: GMNLength(5, unit: .hs)))
    }

    @Test
    func appearance_absentIsEmpty() {
        #expect(makeTag(makeTagName("slur")).appearance.isEmpty)
    }

    @Test
    func appearance_unknownNameIsEmpty() {
        // No template, so nothing to bind against — not a crash, and not a
        // guess either.
        let tag = makeTag(makeTagName("bembel"),
                          parameters: [makeTagParameter("dx", .integer(5, .hs))])

        #expect(tag.appearance.isEmpty)
    }

    @Test
    func body() {
        let note = makeNote(makePitch(.c, 4),
                            makeDuration(1, 4))

        #expect(makeTag(makeTagName("slur"), body: [.note(note)]).body.count == 1)
        #expect(makeTag(makeTagName("slur")).body.isEmpty)
    }

    @Test
    func custom_carriesItsPayload() {
        let payload = makeCustomTag(makeTagName("bembel"), ident: makeTagIdent(1))

        guard case let .custom(tag) = GMNTag.custom(payload)
        else {
            Issue.record("Expected custom tag")
            return
        }

        #expect(tag == payload)
    }

    @Test
    func equatable() {
        let tag1 = makeTag(makeTagName("slur"))
        let tag2 = makeTag(makeTagName("slur"))
        let tag3 = makeTag(makeTagName("tie"))

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func ident() {
        #expect(makeTag(makeTagName("slurBegin"), ident: makeTagIdent(3)).ident == makeTagIdent(3))
        #expect(makeTag(makeTagName("slurBegin")).ident == nil)
    }

    @Test
    func name() {
        #expect(makeTag(makeTagName("bm")).name == makeTagName("bm"))
    }

    @Test
    func rangeSetting() {
        #expect(makeTag(makeTagName("slur")).rangeSetting == .only)
        #expect(makeTag(makeTagName("text")).rangeSetting == .either)
        #expect(makeTag(makeTagName("mark")).rangeSetting == .no)
    }

    @Test
    func rangeSetting_unknownNameIsNo() {
        // guidolib's own default for a class that never assigns one
        // (`ARMusicalTag.cpp:35`).
        #expect(makeTag(makeTagName("bembel")).rangeSetting == .no)
    }

    @Test
    func reserved_carriesItsPayload() {
        let payload = makeReservedTag(makeTagName("slur"), ident: makeTagIdent(1))

        guard case let .reserved(tag) = GMNTag.reserved(payload)
        else {
            Issue.record("Expected reserved tag")
            return
        }

        #expect(tag == payload)
    }

    @Test
    func span() {
        #expect(makeTag(makeTagName("slur")).span == .whole)
        #expect(makeTag(makeTagName("slurBegin")).span == .begin)
        #expect(makeTag(makeTagName("slurEnd")).span == .end)
    }

    @Test
    func span_repeatIsNotASpan() {
        // `\repeatBegin` reads like an opening half but is not one:
        // `\repeatEnd` is an `ARRepeatEnd` with its own parameters, not an
        // `ARDummyRangeEnd`.
        #expect(makeTag(makeTagName("repeatBegin")).span == .whole)
        #expect(makeTag(makeTagName("repeatEnd")).span == .whole)
    }

    @Test
    func span_unknownNameIsWhole() {
        #expect(makeTag(makeTagName("bembel")).span == .whole)
        #expect(makeTag(makeTagName("fooBegin")).span == .whole)
    }

    @Test
    func untyped_choosesTheLaneByDispatch() {
        // The one place the two lanes are chosen between, seen from outside:
        // `\slur` is dispatched and `\bembel` is not, and nothing else about
        // the two tags differs.
        #expect(GMNTag.untyped(ident: nil,
                               name: makeTagName("slur"),
                               parameters: [],
                               body: []) == .reserved(makeReservedTag(makeTagName("slur"))))
        #expect(GMNTag.untyped(ident: nil,
                               name: makeTagName("bembel"),
                               parameters: [],
                               body: []) == .custom(makeCustomTag(makeTagName("bembel"))))
    }
}
