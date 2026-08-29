// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARTie : ARBowing`, `kARBowingParams`
// (`"S,curve,down,o;U,dx1,2hs,o;U,dy1,1hs,o;U,dx2,-2hs,o;U,dy2,1hs,o;F,r3,0.5,o;U,h,2hs,o"`,
// `TagParameterStrings.cpp:41`). Range setting: `ONLY` — the notes the tie
// joins are its body.
//
// A tie is a bowing, not a timing tag: `ARTie` is an `ARBowing` subclass
// adding neither a template nor a read, so it has `GMNSlur`'s shape
// verbatim — a transcription trap, and the reason a payload built by
// grouping tags on what they *mean* rather than on what they *accept* would
// have got this one wrong. Every field's audit is `ARBowing`'s;
// see `GMNSlur` for it.

/// A tie (`\tie`).
///
/// The notes the tie joins are its body.
///
/// A tie accepts exactly the parameters a ``GMNSlur`` does — the shape of the
/// curve, not the notes it joins.
public struct GMNTie {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new tie with the provided identifier, curve, control points,
    /// control ratio, height, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter curve:         Which way the tie bends, or `nil` if none
    ///                            was written. Defaults to `nil`.
    /// - Parameter controlPoints: The `dx1`/`dy1`/`dx2`/`dy2` offsets written
    ///                            for this tag. Defaults to none.
    /// - Parameter r3:            The relative position of the curve’s apex,
    ///                            or `nil` if none was written. Defaults to
    ///                            `nil`.
    /// - Parameter h:             The height of the curve’s apex, or `nil` if
    ///                            none was written. Defaults to `nil`.
    /// - Parameter span:          Which part of a spanning construct this tag
    ///                            is. Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance:    The common appearance parameters written for
    ///                            this tag. Defaults to none.
    /// - Parameter body:          The symbols scoped to this tag. Defaults to
    ///                            none.
    public init?(ident: GMNTag.Ident? = nil,
                 curve: GMNTag.Curve? = nil,
                 controlPoints: GMNTag.ControlPoints = GMNTag.ControlPoints(),
                 r3: Double? = nil,
                 h: GMNLength? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.controlPoints = controlPoints
        self.curve = curve
        self.h = h
        self.ident = ident
        self.r3 = r3
        self.span = span

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// Its `dx` and `dy` are folded into the control points rather than
    /// replacing them — see ``GMNSlur``.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **All four non-omissible, proven** — see `GMNSlur.controlPoints`.

    /// The `dx1`/`dy1`/`dx2`/`dy2` offsets written for this tag.
    public let controlPoints: GMNTag.ControlPoints

    // **Non-omissible, proven** — see `GMNSlur.curve`.

    /// Which way the tie bends (`curve`), or `nil` if none was written.
    public let curve: GMNTag.Curve?

    // **Non-omissible, proven** — see `GMNSlur.h`, including why an `h`
    // written as something other than a length keeps the tag reserved.

    /// The height of the curve’s apex (`h`), or `nil` if none was written.
    public let h: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\tieBegin:1 …
    /// \tieEnd:1`.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven** — see `GMNSlur.r3`.

    /// The relative position of the curve’s apex (`r3`), or `nil` if none was
    /// written.
    public let r3: Double?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

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
                  curve: binding.curve(named: "curve"),
                  controlPoints: binding.controlPoints,
                  r3: binding.double(named: "r3"),
                  h: binding.length(named: "h"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTie: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("tieBegin")

        case .end:
            GMNTag.Name("tieEnd")

        case .whole:
            GMNTag.Name("tie")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = controlPoints.parameterValues

        values["curve"] = curve.map { .string($0.guidoValue) }
        values["h"] = h?.parameterValue
        values["r3"] = r3.map { .number($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNTie: Equatable {
}

// MARK: - Sendable

extension GMNTie: Sendable {
}
