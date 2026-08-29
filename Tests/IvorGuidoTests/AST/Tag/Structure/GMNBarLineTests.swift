// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNBarLineTests {
}

// MARK: -

extension GMNBarLineTests {
    @Test
    func bareSingleBarLineIsNamedForTheShorthand() {
        // The bare bar-line shorthand, expressed as the payload's own
        // canonical name so the formatter needs no special case.
        #expect(GMNBarLine().name == makeTagName("|"))
    }

    @Test
    func equatable() {
        let a = GMNBarLine(kind: .double)
        let b = GMNBarLine(kind: .double)
        let c = GMNBarLine(kind: .final)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingToNil() {
        let bar = GMNBarLine()

        #expect(bar.appearance.isEmpty)
        #expect(bar.body.isEmpty)
        #expect(bar.displayMeasNum == nil)
        #expect(bar.hidden == nil)
        #expect(bar.ident == nil)
        #expect(bar.kind == .single)
        #expect(bar.measNum == nil)
        #expect(bar.numDx == nil)
        #expect(bar.numDy == nil)
        #expect(bar.isBare)
    }

    @Test
    func parameterizedSingleBarLineIsNamedBar() {
        #expect(GMNBarLine(measNum: 4).name == makeTagName("bar"))
        #expect(GMNBarLine(ident: makeTagIdent(1)).name == makeTagName("bar"))
        #expect(GMNBarLine(appearance: GMNTag.Appearance(color: "red")).name == makeTagName("bar"))
    }

    @Test(arguments: [("bar", GMNBarLine.Kind.single),
                      ("doubleBar", .double),
                      ("endBar", .final)])
    func promotesEachKind(_ pair: (name: String, kind: GMNBarLine.Kind)) throws {
        guard case let .barLine(bar) = try normalizedTag("[\\\(pair.name)]")
        else {
            Issue.record("Expected barLine tag")
            return
        }

        #expect(bar.kind == pair.kind)
    }

    @Test
    func promotesTheShorthand() throws {
        guard case let .barLine(bar) = try normalizedTag("[|]")
        else {
            Issue.record("Expected barLine tag")
            return
        }

        #expect(bar.kind == .single)
        #expect(bar.isBare)
    }

    @Test
    func promotesWithParameters() throws {
        guard case let .barLine(bar) = try normalizedTag("[\\bar<\"true\",4,numDy=2hs>]")
        else {
            Issue.record("Expected barLine tag")
            return
        }

        #expect(bar.displayMeasNum == "true")
        #expect(bar.measNum == 4)
        #expect(bar.numDy == GMNLength(2, unit: .hs))
        #expect(!bar.isBare)
    }
}
