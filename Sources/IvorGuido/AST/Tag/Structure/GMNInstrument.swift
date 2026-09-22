// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARInstrument : ARFontAble`, `kARInstrumentParams`
// (`"S,name,,r;S,transp,,o;S,autopos,off,o;S,repeat,off,o;I,MIDI,-1,o"`,
// `TagParameterStrings.cpp:57`) on top of `kARFontAbleParams`. Range setting:
// `NO` — `\instrument` takes no body.

/// An instrument name (`\instr`, `\instrument`).
///
/// `\instrument` takes no body.
public struct GMNInstrument {

    // MARK: Public Initializers

    /// Creates a new instrument name with the provided identifier, values,
    /// text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter name:       The instrument’s name.
    /// - Parameter transp:     The transposition, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter autopos:    Whether the name is positioned automatically,
    ///                         as written, or `nil` if it was not written.
    ///                         Defaults to `nil`.
    /// - Parameter repeats:    Whether the name is repeated on every system,
    ///                         as written, or `nil` if it was not written.
    ///                         Defaults to `nil`.
    /// - Parameter midi:       The MIDI program number, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                name: String,
                transp: String? = nil,
                autopos: String? = nil,
                repeats: String? = nil,
                midi: Int? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.autopos = autopos
        self.body = body
        self.ident = ident
        self.instrumentName = name
        self.midi = midi
        self.repeats = repeats
        self.textStyle = textStyle
        self.transp = transp
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    // **Non-omissible, proven.** Unlike its neighbours this one is read twice
    // — first without a default to test for presence, and only then with one
    // (`ARInstrument.cpp:37–39`) — so absence leaves `fAutoPos` at the class’s
    // own initial value and is directly observable.

    /// Whether the name is positioned automatically (`autopos`), as written,
    /// or `nil` if it was not written. Declared default: `off`.
    public let autopos: String?

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The instrument’s name (`name`).
    ///
    /// Required by the template, so an `\instrument` without it never promotes
    /// to this payload and stays reserved.
    ///
    /// Spelled `instrumentName` rather than `name` because `GMNTagPayload`
    /// already claims `name` for the tag’s own canonical name.
    public let instrumentName: String

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARInstrument.cpp:41`) and not on the `TagIsSet()` blocklist, which
    // puts it in the provisional bucket; the formatter takes the safe
    // branch.

    /// The MIDI program number (`MIDI`), or `nil` if none was written.
    /// Declared default: `-1`.
    public let midi: Int?

    // **Non-omissible, provisionally** — read with `usedefault=true`
    // (`ARInstrument.cpp:40`), as `midi` is.

    /// Whether the name is repeated on every system (`repeat`), as written, or
    /// `nil` if it was not written. Declared default: `off`.
    ///
    /// Spelled `repeats` because `repeat` is a Swift keyword.
    public let repeats: String?

    /// The font parameters written for this tag.
    public let textStyle: GMNTag.TextStyle

    // **Non-omissible, provisionally** — read with `usedefault=true`
    // (`ARInstrument.cpp:36`), as `midi` is.

    /// The transposition (`transp`), or `nil` if none was written.
    public let transp: String?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let name = binding.string(named: "name")
        else { return nil }

        self.init(ident: ident,
                  name: name,
                  transp: binding.string(named: "transp"),
                  autopos: binding.string(named: "autopos"),
                  repeats: binding.string(named: "repeat"),
                  midi: binding.integer(named: "MIDI"),
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNInstrument: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("instrument")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["autopos"] = autopos.map { .string($0) }
        values["MIDI"] = midi.map { .integer($0, nil) }
        values["name"] = .string(instrumentName)
        values["repeat"] = repeats.map { .string($0) }
        values["transp"] = transp.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNInstrument: Equatable {
}

// MARK: - Sendable

extension GMNInstrument: Sendable {
}
