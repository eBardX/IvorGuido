// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNJumpTests {
}

// MARK: -

extension GMNJumpTests {
    @Test
    func equatable() {
        let a = GMNJump(kind: .coda)
        let b = GMNJump(kind: .coda)
        let c = GMNJump(kind: .segno)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsOptionalsToNil() {
        let jump = GMNJump(kind: .fine)

        #expect(jump.appearance.isEmpty)
        #expect(jump.body.isEmpty)
        #expect(jump.id == nil)
        #expect(jump.ident == nil)
        #expect(jump.kind == .fine)
        #expect(jump.mark == nil)
    }

    @Test(arguments: [("coda", GMNJump.Kind.coda),
                      ("daCapo", .daCapo),
                      ("daCapoAlFine", .daCapoAlFine),
                      ("daCoda", .daCoda),
                      ("dalSegno", .dalSegno),
                      ("dalSegnoAlFine", .dalSegnoAlFine),
                      ("fine", .fine),
                      ("segno", .segno)])
    func promotesEachKind(_ pair: (name: String, kind: GMNJump.Kind)) throws {
        guard case let .jump(jump) = try normalizedTag("[\\\(pair.name)]")
        else {
            Issue.record("Expected jump tag")
            return
        }

        #expect(jump.kind == pair.kind)
        #expect(jump.name == makeTagName(pair.name))
    }

    @Test
    func promotesWithAMark() throws {
        guard case let .jump(jump) = try normalizedTag("[\\daCapo<\"D.C. al Fine\">]")
        else {
            Issue.record("Expected jump tag")
            return
        }

        #expect(jump.mark == "D.C. al Fine")
    }

    @Test
    func segnoBindsOnlyNamedParameters() throws {
        // `ARSegno` overrides `getParamsStr()` to `""` (`ARSegno.h:42`) while
        // still supporting `kARJumpParams`, so the named spelling promotes …
        guard case let .jump(jump) = try normalizedTag("[\\segno<id=3>]")
        else {
            Issue.record("Expected jump tag")
            return
        }

        #expect(jump.id == 3)
    }

    @Test
    func segnoRejectsAPositionalParameter() {
        // … and the positional one has no slot to bind to at all.
        expectRejected("[\\segno<3>]",
                       .unboundPositionalParameter(makeTagName("segno"), index: 0))
    }

    @Test
    func theMarkParameterCannotBeWrittenByName() {
        // `guido.l:143` lexes a bare `m` as a UNIT token unconditionally, in
        // guidolib exactly as here, so `m=…` never reaches a parser at all —
        // the parameter is reachable only positionally. (This is very likely
        // why `\volta`'s `m` was renamed to `mark` in guidolib 1.5.5.) The
        // binder itself has no such restriction.
        let binding = makeBinding("daCapo", [makeTagParameter("m", .string("D.C."))])
        let jump = GMNJump(ident: nil, binding: binding, kind: .daCapo, body: [])

        #expect(jump.mark == "D.C.")
    }
}
