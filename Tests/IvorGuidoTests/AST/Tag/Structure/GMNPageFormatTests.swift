// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNPageFormatTests {
}

// MARK: -

extension GMNPageFormatTests {
    @Test
    func canonicalNameIsPageFormat() {
        #expect(GMNPageFormat(type: "a4").require().name == makeTagName("pageFormat"))
    }

    @Test
    func equatable() {
        let a = GMNPageFormat(type: "a4").require()
        let b = GMNPageFormat(type: "a4").require()
        let c = GMNPageFormat(type: "letter").require()

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsEverythingElseToEmpty() {
        let pageFormat = GMNPageFormat(type: "a4").require()

        #expect(pageFormat.appearance.isEmpty)
        #expect(pageFormat.body.isEmpty)
        #expect(pageFormat.bottomMargin == nil)
        #expect(pageFormat.height == nil)
        #expect(pageFormat.ident == nil)
        #expect(pageFormat.leftMargin == nil)
        #expect(pageFormat.rightMargin == nil)
        #expect(pageFormat.topMargin == nil)
        #expect(pageFormat.type == "a4")
        #expect(pageFormat.width == nil)
    }

    @Test
    func init_fromBindingRequiresANamedOrMeasuredPage() {
        // The by-size template is what an empty list binds against, and both
        // of its slots are required, so nothing survives `checkRequired`.
        #expect(GMNPageFormat(ident: nil,
                              binding: makeBinding("pageFormat"),
                              body: []) == nil)
    }

    @Test
    func init_requiresANamedOrMeasuredPage() {
        // `kARPageFormatParams` flags `type`, `w`, and `h` all required, and
        // `ARPageFormat::checkTagParameters` removes whichever alternative
        // was not written. A page that is neither named nor measured is a
        // `\pageFormat` the validator refuses, and half a measured one is
        // too.
        #expect(GMNPageFormat() == nil)
        #expect(GMNPageFormat(width: GMNLength(21, unit: .cm)) == nil)
        #expect(GMNPageFormat(height: GMNLength(29.7, unit: .cm)) == nil)
        #expect(GMNPageFormat(leftMargin: GMNLength(1, unit: .cm)) == nil)

        #expect(GMNPageFormat(type: "a4") != nil)
        #expect(GMNPageFormat(width: GMNLength(21, unit: .cm),
                              height: GMNLength(29.7, unit: .cm)) != nil)
    }

    @Test
    func isRejectedWithHalfAMeasuredPage() {
        expectRejected("[\\pageFormat<w=21cm>]",
                       .missingRequiredParameter(makeTagName("pageFormat"), "h"))
    }

    @Test
    func promotesAMeasuredPage() throws {
        guard case let .pageFormat(pageFormat) = try normalizedTag("[\\pageFormat<21cm,29.7cm>]")
        else {
            Issue.record("Expected pageFormat tag")
            return
        }

        #expect(pageFormat.height == GMNLength(29.7, unit: .cm))
        #expect(pageFormat.type == nil)
        #expect(pageFormat.width == GMNLength(21, unit: .cm))
    }

    @Test
    func promotesANamedPage() throws {
        guard case let .pageFormat(pageFormat) = try normalizedTag("[\\pageFormat<\"a4\",lm=1cm>]")
        else {
            Issue.record("Expected pageFormat tag")
            return
        }

        #expect(pageFormat.type == "a4")
        #expect(pageFormat.leftMargin == GMNLength(1, unit: .cm))
        #expect(pageFormat.width == nil)
    }

    @Test
    func theMarginsFollowTheNameInBothTemplates() throws {
        // `\pageFormat<"a4",1cm>` binds its `1cm` to `lm`, not to `w`: the
        // by-type template's slot 1 is the left margin. Getting this wrong is
        // silent corruption, so it is pinned from both directions.
        guard case let .pageFormat(named) = try normalizedTag("[\\pageFormat<\"a4\",1cm,2cm,3cm,4cm>]"),
              case let .pageFormat(measured) = try normalizedTag("[\\pageFormat<21cm,29.7cm,1cm,2cm,3cm,4cm>]")
        else {
            Issue.record("Expected pageFormat tags")
            return
        }

        #expect(named.leftMargin == GMNLength(1, unit: .cm))
        #expect(named.topMargin == GMNLength(2, unit: .cm))
        #expect(named.rightMargin == GMNLength(3, unit: .cm))
        #expect(named.bottomMargin == GMNLength(4, unit: .cm))

        #expect(measured.leftMargin == named.leftMargin)
        #expect(measured.topMargin == named.topMargin)
        #expect(measured.rightMargin == named.rightMargin)
        #expect(measured.bottomMargin == named.bottomMargin)
    }
}
