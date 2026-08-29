// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARBeam`, `kARBeamParams`
// (`"U,dy,0,o;U,dx1,0hs,o;U,dy1,0hs,o;U,dx2,0hs,o;U,dy2,1hs,o;U,dx3,0hs,o;U,dy3,0hs,o;U,dx4,0hs,o;U,dy4,1hs,o"`,
// `TagParameterStrings.cpp:39`), and `ARFeatheredBeam : ARBeam`,
// `kARFeatheredBeamParams` (`"S,durations,,o;S,drawDuration,false,o"`, `:50`).
// Range setting: `ONLY` for both (`ARBeam.cpp:23`, `ARFeatheredBeam.cpp:31`) —
// the notes the beam covers are its body.

/// A beam (`\beam`, aliases `\b` and `\bm`) or a feathered beam (`\fBeam`).
///
/// The notes the beam covers are its body.
///
/// `\beam`’s first positional parameter is `dy`, which is also a common
/// appearance parameter — so `\beam<2hs>` binds `dy`, and this payload keeps
/// it in ``appearance`` where every other tag’s `dy` lives.
///
/// ## Two names, two slot orders
///
/// A feathered beam accepts everything an ordinary one does, but its *only*
/// positional parameters are `durations` and `drawDuration`. So `\beam<2hs>`
/// sets `dy` while `\fBeam<"1/16,1/4">` sets `durations`, and ``kind`` is
/// what says which of the two orders applies.
public struct GMNBeam {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new beam with the provided identifier, kind, control points,
    /// durations, duration drawing, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter kind:          Which of the two beam tags this is.
    /// - Parameter controlPoints: The four corners of the beam. Defaults to
    ///                            none.
    /// - Parameter durations:     The first and last durations a feathered
    ///                            beam interpolates between, or `nil` if none
    ///                            was written. Defaults to `nil`.
    /// - Parameter drawDuration:  Whether a feathered beam draws its
    ///                            durations, as written, or `nil` if it was
    ///                            not written. Defaults to `nil`.
    /// - Parameter span:          Which part of a spanning construct this tag
    ///                            is. Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance:    The common appearance parameters written for
    ///                            this tag. Defaults to none.
    /// - Parameter body:          The symbols scoped to this tag. Defaults to
    ///                            none.
    public init?(ident: GMNTag.Ident? = nil,
                 kind: Kind,
                 controlPoints: ControlPoints = ControlPoints(),
                 durations: String? = nil,
                 drawDuration: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.controlPoints = controlPoints
        self.drawDuration = drawDuration
        self.durations = durations
        self.ident = ident
        self.kind = kind
        self.span = span

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag, `dy` among them
    /// — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag — the notes the beam covers.
    public let body: [GMNSymbol]

    /// The four corners of the beam.
    public let controlPoints: ControlPoints

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARFeatheredBeam.cpp:47–48`) and not on the `TagIsSet()` blocklist,
    // which puts it in the explicitly provisional bucket.

    /// Whether a feathered beam draws its durations (`drawDuration`), as
    /// written, or `nil` if it was not written.
    ///
    /// Left a `String` rather than a `Bool`: a range of spellings is
    /// accepted, so preserving the one written is what makes the round trip
    /// exact.
    public let drawDuration: String?

    // **Non-omissible, provisionally** — same read as `drawDuration`
    // (`ARFeatheredBeam.cpp:45–46`).

    /// The first and last durations a feathered beam interpolates between
    /// (`durations`), as in `"1/16,1/4"`, or `nil` if none was written.
    ///
    /// Written as two durations separated by a comma, and left unparsed here:
    /// anything unrecognized, including a missing comma, is silently ignored
    /// when the score is rendered.
    public let durations: String?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\beamBegin:1 …
    /// \beamEnd:1`.
    public let ident: GMNTag.Ident?

    /// Which of the two beam tags this is.
    public let kind: Kind

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   kind: Kind,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      kind: kind,
                      span: .end,
                      body: body)

            return
        }

        self.init(ident: ident,
                  kind: kind,
                  controlPoints: ControlPoints(binding: binding),
                  durations: binding.string(named: "durations"),
                  drawDuration: binding.string(named: "drawDuration"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNBeam: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName(for: span))
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = controlPoints.parameterValues

        values["drawDuration"] = drawDuration.map { .string($0) }
        values["durations"] = durations.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNBeam: Equatable {
}

// MARK: - Sendable

extension GMNBeam: Sendable {
}
