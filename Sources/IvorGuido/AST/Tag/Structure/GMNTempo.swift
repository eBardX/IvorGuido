// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTempo : ARFontAble`, `kARTempoParams`
// (`"S,tempo,,r;S,bpm,,o;S,font,Times New
// Roman,o;S,textformat,lc,o;U,fsize,11pt,o"`, `TagParameterStrings.cpp:77`) on
// top of `kARFontAbleParams`. Range setting: `NO` — `\tempo` takes no body.
//
// The template declares `bpm` as `S`, so a numeric `bpm` is read by a
// `dynamic_cast` to `TagParameterString` (`ARTempo.cpp:85`) that fails. That
// is guidolib's inert-parameter case.

/// A tempo marking (`\tempo`).
///
/// `\tempo` takes no body.
///
/// ## `bpm` must be written as a string
///
/// `\tempo<"Allegro",120>` writes a number where a string is expected; the
/// `120` is inert, and the normalizer drops it, so the tag arrives here as a
/// bare `\tempo<"Allegro">`. Write `\tempo<"Allegro","1/4=120">` instead.
///
/// A `bpm` that *is* a string but that ``GMNTempo/Metronome`` cannot read is
/// a different matter: such a tag stays reserved rather than losing the
/// text.
public struct GMNTempo {

    // MARK: Public Initializers

    /// Creates a new tempo marking with the provided identifier, text,
    /// metronome specification, text style, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter tempo:      The tempo text.
    /// - Parameter metronome:  The metronome specification, or `nil` if none
    ///                         was written. Defaults to `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                tempo: String,
                metronome: Metronome? = nil,
                textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.metronome = metronome
        self.tempo = tempo
        self.textStyle = textStyle
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

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible**: `ARTempo.cpp:86` guards the whole reading on
    // `bpm->TagIsSet()`, so absence and a written value are distinguishable
    // however the default is declared.

    /// The metronome specification (`bpm`), or `nil` if none was written.
    public let metronome: Metronome?

    // **Non-omissible**, moot for a required parameter.

    /// The tempo text (`tempo`).
    ///
    /// Required, so a `\tempo` without it stays reserved. It is an open
    /// markup syntax rather than a fixed set of tempo words — `\note{…}`
    /// embeds a note glyph, for instance.
    public let tempo: String

    /// The font parameters written for this tag.
    ///
    /// Three of the four — `font`, `textformat`, `fsize` — are also this tag’s
    /// own positional slots, with defaults of its own. That changes where they
    /// are emitted, not how they are modeled.
    public let textStyle: GMNTag.TextStyle

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let tempo = binding.string(named: "tempo")
        else { return nil }

        var metronome: Metronome?

        if let specification = binding.string(named: "bpm") {
            guard let parsed = Metronome(specification)
            else { return nil }

            metronome = parsed
        }

        self.init(ident: ident,
                  tempo: tempo,
                  metronome: metronome,
                  textStyle: binding.textStyle,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTempo: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("tempo")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["bpm"] = metronome.map { .string($0.stringValue) }
        values["tempo"] = .string(tempo)

        return values
    }
}

// MARK: - Equatable

extension GMNTempo: Equatable {
}

// MARK: - Sendable

extension GMNTempo: Sendable {
}
