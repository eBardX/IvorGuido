// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTremolo`, `kARTremoloParams`
// (`"S,style,///,o;I,speed,32,o;S,pitch,,o;U,thickness,0.75,o;S,text,,o"`,
// `TagParameterStrings.cpp:80`). Range setting: `ONLY` — the notes the tremolo
// covers are its body.

/// A tremolo (`\tremolo`, alias `\trem`).
///
/// The notes the tremolo covers are its body.
public struct GMNTremolo {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new tremolo with the provided identifier, style, speed,
    /// pitch, thickness, text, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter style:      The stroke style, or `nil` if none was written.
    ///                         Defaults to `nil`.
    /// - Parameter speed:      The tremolo’s subdivision, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter pitch:      The second pitch of a two-pitch tremolo, or
    ///                         `nil` if none was written. Defaults to `nil`.
    /// - Parameter thickness:  The stroke thickness, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter text:       The text drawn alongside the tremolo, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 style: String? = nil,
                 speed: Int? = nil,
                 pitch: String? = nil,
                 thickness: GMNLength? = nil,
                 text: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.pitch = pitch
        self.span = span
        self.speed = speed
        self.style = style
        self.text = text
        self.thickness = thickness

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\tremBegin:1 …
    /// \tremEnd:1`.
    public let ident: GMNTag.Ident?

    // Left a `String` rather than a `GMNPitch`. `ARTremolo` keeps it as text
    // and validates it only loosely, accepting a `{…}` wrapper and a
    // chord-like tail its own scanner never fully parses
    // (`ARTremolo::isSecondPitchCorrect`, `ARTremolo.cpp:75–110`); reading it
    // as a pitch would commit this AST to a grammar guidolib does not itself
    // enforce.

    /// The second pitch of a two-pitch tremolo (`pitch`), or `nil` if none
    /// was written.
    ///
    /// Written as text — a pitch name, optionally wrapped in `{…}` — and left
    /// unparsed here.
    public let pitch: String?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    // **Non-omissible, provisionally.** `ARTremolo::setTagParameters` reads
    // all five parameters with `usedefault=true` (`ARTremolo.cpp:65–71`), and
    // none is on the `TagIsSet()` blocklist — but treated as non-omissible
    // for now.

    /// The tremolo’s subdivision (`speed`), or `nil` if none was written.
    public let speed: Int?

    // Left a `String`: `ARTremolo::getNumberOfStrokes`
    // (`ARTremolo.cpp:113–127`) is an open parse rather than a closed
    // vocabulary.

    /// The stroke style (`style`), as in `"//"`, or `nil` if none was
    /// written.
    ///
    /// One to four slashes select that many strokes; anything else is drawn
    /// with three.
    public let style: String?

    /// The text drawn alongside the tremolo (`text`), or `nil` if none was
    /// written.
    public let text: String?

    /// The stroke thickness (`thickness`), or `nil` if none was written.
    public let thickness: GMNLength?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      span: .end,
                      body: body)

            return
        }

        self.init(ident: ident,
                  style: binding.string(named: "style"),
                  speed: binding.integer(named: "speed"),
                  pitch: binding.string(named: "pitch"),
                  thickness: binding.length(named: "thickness"),
                  text: binding.string(named: "text"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTremolo: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("tremoloBegin")

        case .end:
            GMNTag.Name("tremoloEnd")

        case .whole:
            GMNTag.Name("tremolo")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["pitch"] = pitch.map { .string($0) }
        values["speed"] = speed.map { .integer($0, nil) }
        values["style"] = style.map { .string($0) }
        values["text"] = text.map { .string($0) }
        values["thickness"] = thickness?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNTremolo: Equatable {
}

// MARK: - Sendable

extension GMNTremolo: Sendable {
}
