// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing

struct GMNParserDiagnosticTests {
}

// MARK: -

extension GMNParserDiagnosticTests {
    @Test
    func equatable() {
        let a = GMNParser.Diagnostic.vestigialCount("c<3>")
        let b = GMNParser.Diagnostic.vestigialCount("c<3>")
        let c = GMNParser.Diagnostic.vestigialCount("_<4>")

        #expect(a == b)
        #expect(a != c)
        #expect(a != GMNParser.Diagnostic.unrecognizedEscape("\\t"))
    }

    @Test
    func message_unrecognizedEscape() {
        #expect(GMNParser.Diagnostic.unrecognizedEscape("\\t").message.contains("\\t"))
    }

    @Test
    func message_vestigialCount() {
        #expect(GMNParser.Diagnostic.vestigialCount("c<3>").message.contains("c<3>"))
    }

    @Test
    func parse_emptyWhenNoneApply() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("[ c d e ]".utf8))

        #expect(diagnostics.isEmpty)
    }

    @Test
    func parse_unrecognizedEscapeInTablatureFret() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("[ s1:a\\:b: ]".utf8))

        #expect(diagnostics == [.unrecognizedEscape("\\:")])
    }

    @Test
    func parse_unrecognizedEscapeInTagParameterString() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("[ \\mark<\"a\\tb\"> c ]".utf8))

        #expect(diagnostics == [.unrecognizedEscape("\\t")])
    }

    @Test
    func parse_unrecognizedEscapeInVariableString() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("$title = \"a\\tb\"; [ c ]".utf8))

        #expect(diagnostics == [.unrecognizedEscape("\\t")])
    }

    @Test
    func parse_vestigialCountOnNote() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("[ c<3> ]".utf8))

        #expect(diagnostics == [.vestigialCount("c<3>")])
    }

    @Test
    func parse_vestigialCountOnRest() throws {
        let (_, diagnostics) = try GMNParser().parse(Data("[ _<4> ]".utf8))

        #expect(diagnostics == [.vestigialCount("_<4>")])
    }
}
