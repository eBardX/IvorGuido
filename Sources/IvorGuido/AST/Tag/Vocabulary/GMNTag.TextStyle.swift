// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: `kARFontAbleParams`
    // (`"S,textformat,rc,o;S,font,Times,o;U,fsize,9pt,o;S,fattrib,,o"`,
    // `TagParameterStrings.cpp:21`), contributed by `ARFontAble`
    // (`ARFontAble.h:28`) to the nine tag names that derive from it.
    //
    // `ARFontAble::getParamsStr()` returns `kARFontAbleParams` outright, and a
    // subclass that adds its own parameters concatenates them.
    //
    // ## Omissibility
    //
    // `ARFontAble::setTagParameters` reads all four with `usedefault=true`
    // (`ARFontAble.cpp:30–33`), so each satisfies condition 1 of the
    // omissibility criterion, and none appears on the `TagIsSet()` blocklist.
    // That makes them *provisionally* omissible, pending the per-payload
    // spot-check that no consumer reads them by a route other than the getter.
    // Until that check lands, the formatter takes the safe branch and emits
    // what was written.

    /// The four font parameters shared by every text-bearing Guido Music
    /// Notation tag.
    ///
    /// Unlike ``GMNTag/Appearance``, these four **do** occupy positional
    /// slots, so a text style is bound and emitted like any other parameter
    /// of the owning tag.
    ///
    /// A tag may declare its own `fsize` with a default of its own —
    /// `\fingering` does, `10pt` rather than `9pt` — which changes nothing
    /// about how the value is modeled here.
    public struct TextStyle {

        // MARK: Public Initializers

        /// Creates a new text style with the provided parameters.
        ///
        /// - Parameter textFormat:     The text alignment, or `nil` if none
        ///                             was written. Defaults to `nil`.
        /// - Parameter font:           The font name, or `nil` if none was
        ///                             written. Defaults to `nil`.
        /// - Parameter fontSize:       The font size, or `nil` if none was
        ///                             written. Defaults to `nil`.
        /// - Parameter fontAttributes: The font attributes, or `nil` if none
        ///                             were written. Defaults to `nil`.
        public init(textFormat: String? = nil,
                    font: String? = nil,
                    fontSize: GMNLength? = nil,
                    fontAttributes: String? = nil) {
            self.font = font
            self.fontAttributes = fontAttributes
            self.fontSize = fontSize
            self.textFormat = textFormat
        }

        // MARK: Public Instance Properties

        /// The font name written for this tag (`font`), or `nil` if none was
        /// written. Declared default: `Times`.
        public let font: String?

        /// The font attributes written for this tag (`fattrib`), or `nil` if
        /// none were written. Declared default: the empty string.
        ///
        /// An open grammar: the string is passed straight through to the
        /// device driver.
        public let fontAttributes: String?

        /// The font size written for this tag (`fsize`), or `nil` if none was
        /// written. Declared default: `9pt`.
        ///
        /// A `U` parameter, hence ``GMNLength`` rather than `Double`.
        public let fontSize: GMNLength?

        /// The text alignment written for this tag (`textformat`), or `nil`
        /// if none was written. Declared default: `rc`.
        ///
        /// Two characters, horizontal then vertical, drawn from `l`/`c`/`r`
        /// and `t`/`c`/`b`. Not validated as a closed set, since Guido does
        /// not validate it either.
        public let textFormat: String?
    }
}

// MARK: -

extension GMNTag.TextStyle {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether no font parameter at all was written
    /// for this tag.
    public var isEmpty: Bool {
        font == nil && fontAttributes == nil && fontSize == nil && textFormat == nil
    }
}

// MARK: -

extension GMNTag.TextStyle {

    // MARK: Internal Instance Properties

    // The four font parameters, keyed by the template name each binds to.
    //
    // The counterpart of ``GMNTag/Appearance``'s: a font-able payload merges
    // this into its own `parameterValues` and the formatter takes the order
    // from the registry, since where these four sit differs by tag —
    // `\harmony` declares three of them among its own positional slots while
    // `\instrument` declares none.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["fattrib"] = fontAttributes.map { .string($0) }
        values["font"] = font.map { .string($0) }
        values["fsize"] = fontSize?.parameterValue
        values["textformat"] = textFormat.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNTag.TextStyle: Equatable {
}

// MARK: - Sendable

extension GMNTag.TextStyle: Sendable {
}
