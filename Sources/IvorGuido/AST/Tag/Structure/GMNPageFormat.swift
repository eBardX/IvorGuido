// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARPageFormat`, `kARPageFormatParams`
// (`"S,type,,r;U,w,,r;U,h,,r;U,lm,2cm,o;U,tm,5cm,o;U,rm,2cm,o;U,bm,3cm,o;S,color,black,o"`,
// `TagParameterStrings.cpp:67`). Range setting: `NO` — `\pageFormat` takes no
// body.
//
// `ARPageFormat` is the one class in the catalog that overrides
// `checkTagParameters` (`ARPageFormat.cpp:136–149`). It builds its positional
// template on the spot from the two alternatives and then removes the losing
// one from the supported set entirely.

/// A page size and margin setting (`\pageFormat`).
///
/// `\pageFormat` takes no body.
///
/// ## The page is either named or measured, never both
///
/// A page is written either as `type` followed by the four margins, or as `w`
/// and `h` followed by the four margins. Whichever alternative is used, the
/// other is not accepted: `\pageFormat<"A4">` takes no `w`, and
/// `\pageFormat<21cm,29.7cm>` takes no `type`.
///
/// Both readings are modeled here as optional fields, and a payload built
/// from a written tag always carries one alternative or the other. The
/// consequence worth knowing is positional: in `\pageFormat<"A4",1cm>` the
/// `1cm` is the **left margin**, not the width.
///
/// `color` has no positional slot under either alternative, so it is carried
/// in ``appearance`` like every other common parameter and always written
/// named.
public struct GMNPageFormat {

    // MARK: Public Initializers

    /// Creates a new page format with the provided identifier, page type,
    /// dimensions, margins, appearance, and body.
    ///
    /// Returns `nil` unless the page is either named or measured — `type`, or
    /// both `width` and `height`. A page that is neither is a tag
    /// ``GMNValidator/validate(_:)`` refuses. Supplying both alternatives is
    /// admissible: `type` wins and the dimensions are ignored.
    ///
    /// - Parameter ident:        The numeric identifier written after this
    ///                           tag’s name. Defaults to `nil`.
    /// - Parameter type:         The named page size, or `nil` if the page is
    ///                           measured instead. Defaults to `nil`.
    /// - Parameter width:        The page width, or `nil` if the page is named
    ///                           instead. Defaults to `nil`.
    /// - Parameter height:       The page height, or `nil` if the page is
    ///                           named instead. Defaults to `nil`.
    /// - Parameter leftMargin:   The left margin, or `nil` if none was
    ///                           written. Defaults to `nil`.
    /// - Parameter topMargin:    The top margin, or `nil` if none was written.
    ///                           Defaults to `nil`.
    /// - Parameter rightMargin:  The right margin, or `nil` if none was
    ///                           written. Defaults to `nil`.
    /// - Parameter bottomMargin: The bottom margin, or `nil` if none was
    ///                           written. Defaults to `nil`.
    /// - Parameter appearance:   The common appearance parameters written for
    ///                           this tag. Defaults to none.
    /// - Parameter body:         The symbols scoped to this tag. Defaults to
    ///                           none.
    public init?(ident: GMNTag.Ident? = nil,
                 type: String? = nil,
                 width: GMNLength? = nil,
                 height: GMNLength? = nil,
                 leftMargin: GMNLength? = nil,
                 topMargin: GMNLength? = nil,
                 rightMargin: GMNLength? = nil,
                 bottomMargin: GMNLength? = nil,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.bottomMargin = bottomMargin
        self.height = height
        self.ident = ident
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.topMargin = topMargin
        self.type = type
        self.width = width

        guard type != nil || (height != nil && width != nil)
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// `color` is one of this tag’s own parameters as well as a common one,
    /// with the same meaning either way — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Omissible, provisionally.** Read with `usedefault=true`
    // (`ARPageFormat.cpp:132`) and absent from the `TagIsSet()` blocklist —
    // but treated as non-omissible for now, so nothing is omitted. Absence
    // is preserved instead.

    /// The bottom margin (`bm`), or `nil` if none was written. Declared
    /// default: `3cm`.
    public let bottomMargin: GMNLength?

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARPageFormat.cpp:176–177`); absent leaves the class’s own
    // 29.7cm default, which the template’s empty declared default cannot stand
    // in for.

    /// The page height (`h`), or `nil` if the page is named by ``type``
    /// instead.
    ///
    /// It must be a length: `\pageFormat<h="tall">` is inert, and the
    /// normalizer drops it.
    public let height: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Omissible, provisionally** — same reading as `bottomMargin`
    // (`ARPageFormat.cpp:129`).

    /// The left margin (`lm`), or `nil` if none was written. Declared default:
    /// `2cm`.
    public let leftMargin: GMNLength?

    // **Omissible, provisionally** — same reading as `bottomMargin`
    // (`ARPageFormat.cpp:131`).

    /// The right margin (`rm`), or `nil` if none was written. Declared
    /// default: `2cm`.
    public let rightMargin: GMNLength?

    // **Omissible, provisionally** — same reading as `bottomMargin`
    // (`ARPageFormat.cpp:130`).

    /// The top margin (`tm`), or `nil` if none was written. Declared default:
    /// `5cm`.
    public let topMargin: GMNLength?

    // **Non-omissible, proven.** Read without `usedefault`, and its presence
    // is what selects the whole reading (`ARPageFormat.cpp:154–155`) — the one
    // parameter in the catalog whose absence changes which other parameters
    // the tag has.

    /// The named page size (`type`), or `nil` if the page is measured by
    /// ``width`` and ``height`` instead.
    ///
    /// The recognized values are `A4`, `A3`, and `letter`; anything else
    /// silently leaves the default page size in place.
    public let type: String?

    // **Non-omissible, proven** — same reading as `height`
    // (`ARPageFormat.cpp:174–175`), and likewise one of the four ambiguously-
    // typed names.

    /// The page width (`w`), or `nil` if the page is named by ``type``
    /// instead.
    public let width: GMNLength?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        // The named-or-measured rule now lives on the public initializer, and
        // failure propagates through this delegation. The binding's own
        // `checkRequired` guarantees it anyway, since exactly one alternative
        // is required under each of the two templates.
        self.init(ident: ident,
                  type: binding.string(named: "type"),
                  width: binding.length(named: "w"),
                  height: binding.length(named: "h"),
                  leftMargin: binding.length(named: "lm"),
                  topMargin: binding.length(named: "tm"),
                  rightMargin: binding.length(named: "rm"),
                  bottomMargin: binding.length(named: "bm"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNPageFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("pageFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["bm"] = bottomMargin?.parameterValue
        values["h"] = height?.parameterValue
        values["lm"] = leftMargin?.parameterValue
        values["rm"] = rightMargin?.parameterValue
        values["tm"] = topMargin?.parameterValue
        values["type"] = type.map { .string($0) }
        values["w"] = width?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNPageFormat: Equatable {
}

// MARK: - Sendable

extension GMNPageFormat: Sendable {
}
