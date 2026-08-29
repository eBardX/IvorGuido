// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARRepeatBegin` and `ARRepeatEnd`, both carrying `kARRepeatParams`
// (`"S,hidden,false,o"`, `TagParameterStrings.cpp:69`). Range settings differ
// — `NO` for the opening half, `RANGEDC` for the closing one
// (`ARRepeatEnd.h:44`).

/// A repeat mark (`\repeatBegin`, `\repeatEnd`).
///
/// ## Two halves, two shapes
///
/// The halves are not symmetrical, and ``kind`` is the only thing that says
/// which shape a value has:
///
/// - `\repeatBegin` adds nothing but `hidden`, and its positional parameters
///   are the common appearance ones — so `hidden` can only be written named.
/// - `\repeatEnd` takes the whole measure-numbering vocabulary a barline
///   does, so `\repeatEnd<"true",4>` reads exactly as the same parameters on
///   a `\bar` would.
///
/// A ``displayMeasNum``, ``measNum``, ``numDx``, or ``numDy`` written on a
/// `\repeatBegin` is therefore unsupported, and such a tag never promotes to
/// this payload at all.
public struct GMNRepeat {

    // MARK: Public Initializers

    /// Creates a new repeat mark with the provided identifier, kind, measure-
    /// numbering parameters, appearance, and body.
    ///
    /// - Parameter ident:          The numeric identifier written after this
    ///                             tag’s name. Defaults to `nil`.
    /// - Parameter kind:           Which half of a repeated passage this is.
    /// - Parameter hidden:         Whether the mark is suppressed. Defaults to
    ///                             `nil`.
    /// - Parameter displayMeasNum: How the measure number is displayed.
    ///                             Defaults to `nil`.
    /// - Parameter measNum:        The measure number to display. Defaults to
    ///                             `nil`.
    /// - Parameter numDx:          The horizontal offset of the measure
    ///                             number. Defaults to `nil`.
    /// - Parameter numDy:          The vertical offset of the measure number.
    ///                             Defaults to `nil`.
    /// - Parameter appearance:     The common appearance parameters written
    ///                             for this tag. Defaults to none.
    /// - Parameter body:           The symbols scoped to this tag. Defaults to
    ///                             none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                hidden: String? = nil,
                displayMeasNum: String? = nil,
                measNum: Int? = nil,
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
    ///
    /// On a `\repeatBegin` these four are also the tag’s positional slots —
    /// see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    ///
    /// Only a `\repeatEnd` may carry one: its range setting is `RANGEDC`,
    /// while a `\repeatBegin` is `NO`. The field exists on both so a malformed
    /// score still round-trips what was written; reporting it is the
    /// validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Non-omissible, proven** — its presence alone sets
    // `fMeasureNumberDisplayedIsSet` (`ARBar.cpp:51–58`).

    /// How the measure number is displayed (`displayMeasNum`), as written, or
    /// `nil` if it was not written. Declared default: `false`. Supported on a
    /// `\repeatEnd` only.
    ///
    /// Not a `Bool`: beyond the boolean spellings, the literal `skipped` is
    /// also recognized.
    public let displayMeasNum: String?

    // **Omissible, provisionally.** Both halves read it with `usedefault=true`
    // (`ARRepeatBegin.cpp:38–41`, `ARRepeatEnd.h:51`) and neither is on the
    // `TagIsSet()` blocklist — but treated as non-omissible for now, so
    // nothing is omitted. Absence is preserved instead.

    /// Whether the repeat mark is suppressed (`hidden`), as written, or `nil`
    /// if it was not written. Declared default: `false`.
    ///
    /// Left a `String`: a range of spellings is accepted, an open spelling
    /// rather than an enumeration.
    public let hidden: String?

    // `ARFactory` discards it on a `\repeatBegin` (`ARFactory.cpp:1265–1267`,
    // whose comment reads "right now, IDs are ignored for this").

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// It has no effect on a `\repeatBegin`, but is kept here so the tag
    /// round-trips as written.
    public let ident: GMNTag.Ident?

    /// Which half of a repeated passage this is.
    public let kind: Kind

    // **Non-omissible, proven.** The template declares no default at all, and
    // the absent branch substitutes `0` (`ARBar.cpp:61–62`) — there is no
    // declared default for an omission to stand in for.

    /// The measure number to display (`measNum`), or `nil` if none was
    /// written. Supported on a `\repeatEnd` only.
    public let measNum: Int?

    // **Non-omissible.** Read without `usedefault` (`ARBar.cpp:64–65`), so
    // absent and default-valued reach different code paths.

    /// The horizontal offset of the measure number (`numDx`), or `nil` if none
    /// was written. Declared default: `0`. Supported on a `\repeatEnd` only.
    public let numDx: GMNLength?

    // **Non-omissible** — same reason as `numDx` (`ARBar.cpp:66–67`).

    /// The vertical offset of the measure number (`numDy`), or `nil` if none
    /// was written. Declared default: `0`. Supported on a `\repeatEnd` only.
    public let numDy: GMNLength?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  kind: Kind,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  kind: kind,
                  hidden: binding.string(named: "hidden"),
                  displayMeasNum: binding.string(named: "displayMeasNum"),
                  measNum: binding.integer(named: "measNum"),
                  numDx: binding.length(named: "numDx"),
                  numDy: binding.length(named: "numDy"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNRepeat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
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

extension GMNRepeat: Equatable {
}

// MARK: - Sendable

extension GMNRepeat: Sendable {
}
