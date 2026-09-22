// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// **Every parameter here is non-omissible** — none is inspected for
// authorship with `TagIsSet()`; they fail the usedefault half of the test
// instead. `ARBar::setTagParameters` reads all five without `usedefault`
// (`ARBar.cpp:48–68`), so absence never routes
// through the declared default. `displayMeasNum` is the strongest case: its
// mere presence sets `fMeasureNumberDisplayedIsSet` (`ARBar.cpp:57`), a flag
// that exists purely to distinguish “written” from “not written”.
//
// guidolib: `ARBar`, `ARDoubleBar`, `ARFinishBar`, all sharing `kARBarParams`
// (`"S,displayMeasNum,false,o;I,measNum,,o;S,hidden,false,o;U,numDx,0,o;U,numDy,0,o"`,
// `TagParameterStrings.cpp:38`). Range setting: `NO` — a barline takes no
// body.

/// A barline (`|`, `\bar`, `\doubleBar`, `\endBar`).
///
/// A barline takes no body.
///
/// ## The `|` shorthand
///
/// A bare `|` is the same tag as a `\bar` with no parameters and no
/// identifier, so the two are interchangeable. A single barline carrying
/// nothing at all is written back as `|`; one carrying anything is written
/// back as `\bar<…>`.
public struct GMNBarLine {

    // MARK: Public Initializers

    /// Creates a new barline with the provided identifier, kind, measure-
    /// numbering options, appearance, and body.
    ///
    /// - Parameter ident:           The numeric identifier written after this
    ///                              tag’s name. Defaults to `nil`.
    /// - Parameter kind:            Which of the three barlines this is.
    ///                              Defaults to ``Kind/single``.
    /// - Parameter displayMeasNum:  How the measure number is displayed, as
    ///                              written, or `nil` if it was not written.
    ///                              Defaults to `nil`.
    /// - Parameter measNum:         The measure number to display, or `nil` if
    ///                              none was written. Defaults to `nil`.
    /// - Parameter hidden:          Whether the barline is suppressed, as
    ///                              written, or `nil` if it was not written.
    ///                              Defaults to `nil`.
    /// - Parameter numDx:           The horizontal offset of the measure
    ///                              number, or `nil` if none was written.
    ///                              Defaults to `nil`.
    /// - Parameter numDy:           The vertical offset of the measure number,
    ///                              or `nil` if none was written. Defaults to
    ///                              `nil`.
    /// - Parameter appearance:      The common appearance parameters written
    ///                              for this tag. Defaults to none.
    /// - Parameter body:            The symbols scoped to this tag. Defaults
    ///                              to none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind = .single,
                displayMeasNum: String? = nil,
                measNum: Int? = nil,
                hidden: String? = nil,
                numDx: GMNLength? = nil,
                numDy: GMNLength? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.displayMeasNum = displayMeasNum
        self.hidden = hidden
        self.ident = ident
        self.kind = kind
        self.measNum = measNum
        self.numDx = numDx
        self.numDy = numDy
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Non-omissible, proven** — its presence alone sets
    // `fMeasureNumberDisplayedIsSet` (`ARBar.cpp:51–58`).

    /// How the measure number is displayed (`displayMeasNum`), as written, or
    /// `nil` if it was not written. Declared default: `false`.
    ///
    /// Not a `Bool`: beyond the boolean spellings, the literal `skipped` is
    /// also recognized.
    public let displayMeasNum: String?

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARBar.cpp:59–60`), so absence leaves the class’s own
    // initial state.

    /// Whether the barline is suppressed (`hidden`), as written, or `nil` if
    /// it was not written. Declared default: `false`.
    public let hidden: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which of the three barlines this is.
    public let kind: Kind

    // **Non-omissible, proven.** The template declares no default at all, and
    // the absent branch substitutes `0` (`ARBar.cpp:61–62`) — there is no
    // declared default for an omission to stand in for.

    /// The measure number to display (`measNum`), or `nil` if none was
    /// written.
    public let measNum: Int?

    // **Non-omissible.** Read without `usedefault` (`ARBar.cpp:64–65`), so
    // absent and default-valued reach different code paths.

    /// The horizontal offset of the measure number (`numDx`), or `nil` if none
    /// was written. Declared default: `0`.
    public let numDx: GMNLength?

    // **Non-omissible** — same reason as `numDx` (`ARBar.cpp:66–67`).

    /// The vertical offset of the measure number (`numDy`), or `nil` if none
    /// was written. Declared default: `0`.
    public let numDy: GMNLength?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  kind: Kind,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  kind: kind,
                  displayMeasNum: binding.string(named: "displayMeasNum"),
                  measNum: binding.integer(named: "measNum"),
                  hidden: binding.string(named: "hidden"),
                  numDx: binding.length(named: "numDx"),
                  numDy: binding.length(named: "numDy"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: -

extension GMNBarLine {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this barline carries nothing at all
    /// — no parameters, no identifier, no body.
    ///
    /// A single barline in that state is written `|`.
    public var isBare: Bool {
        appearance.isEmpty
            && body.isEmpty
            && displayMeasNum == nil
            && hidden == nil
            && ident == nil
            && measNum == nil
            && numDx == nil
            && numDy == nil
    }
}

// MARK: - GMNTagPayload

extension GMNBarLine: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch kind {
        case .double:
            GMNTag.Name("doubleBar")

        case .final:
            GMNTag.Name("endBar")

        case .single:
            GMNTag.Name(isBare ? "|" : "bar")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["displayMeasNum"] = displayMeasNum.map { .string($0) }
        values["hidden"] = hidden.map { .string($0) }
        values["measNum"] = measNum.map { .integer($0, nil) }
        values["numDx"] = numDx?.parameterValue
        values["numDy"] = numDy?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNBarLine: Equatable {
}

// MARK: - Sendable

extension GMNBarLine: Sendable {
}
