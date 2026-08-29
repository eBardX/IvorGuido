// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTitle`, `ARComposer`, and `ARFooter`, three `ARText` subclasses
// on `kARTitleParams` (`TagParameterStrings.cpp:79`), `kARComposerParams`
// (`:46`), and `kARFooterParams` (`:53`). Range setting: `NO` for all three —
// none takes a body.

/// A page-level text block (`\title`, `\composer`, `\footer`).
///
/// None takes a body.
///
/// ## One shape, three templates
///
/// The three differ in defaults, in which font parameters they declare as
/// slots, and in what the required first slot is called — `name` for `\title`
/// and `\composer`, `text` for `\footer`. ``kind`` selects the template the
/// formatter emits against, so `\title<"Sonata">` and `\footer<"page 1">`
/// both write their text positionally without either payload knowing how.
public struct GMNTitleBlock {

    // MARK: Public Initializers

    /// Creates a new page-level text block with the provided identifier, kind,
    /// text, page format, text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which text block this is.
    /// - Parameter text:       The text to draw.
    /// - Parameter pageFormat: Where on the page the block sits, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                text: String,
                pageFormat: String? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.kind = kind
        self.pageFormat = pageFormat
        self.text = text
        self.textStyle = textStyle
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// `\title` declares `dy` among its own slots as well; the other two do
    /// not, so they write it named.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which text block this is.
    public let kind: Kind

    // **Non-omissible, provisionally.** All three classes read it with
    // `usedefault=true` (`ARTitle.cpp:40`, `ARComposer.cpp:37`,
    // `ARFooter.cpp:38`) and none is on the `TagIsSet()` blocklist, which puts
    // it in the explicitly provisional bucket — and the three declare three
    // *different* defaults (`c2`, `53`, `c6`), so nothing about it can be
    // reasoned about once separated from its kind.

    /// Where on the page the block sits (`pageformat`), as in `"c2"`, or `nil`
    /// if none was written.
    ///
    /// The grammar mixes a two-character row/column code with bare digits, and
    /// is resolved only when the page is laid out.
    public let pageFormat: String?

    /// The text to draw — `name` for `\title` and `\composer`, `text` for
    /// `\footer`.
    ///
    /// Required by all three templates, so a block without it never promotes
    /// to this payload and stays reserved.
    public let text: String

    /// The font parameters written for this tag.
    ///
    /// Which of the four are also positional slots differs by kind: `\title`
    /// and `\footer` declare `font`, `fsize`, and `textformat`; `\composer`
    /// declares only `fsize` and `textformat`.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   kind: Kind,
                   body: [GMNSymbol]) {
        guard let text = binding.string(named: kind.textParameterName)
        else { return nil }

        self.init(ident: ident,
                  kind: kind,
                  text: text,
                  pageFormat: binding.string(named: "pageformat"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTitleBlock: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["pageformat"] = pageFormat.map { .string($0) }
        values[kind.textParameterName] = .string(text)

        return values
    }
}

// MARK: - Equatable

extension GMNTitleBlock: Equatable {
}

// MARK: - Sendable

extension GMNTitleBlock: Sendable {
}
