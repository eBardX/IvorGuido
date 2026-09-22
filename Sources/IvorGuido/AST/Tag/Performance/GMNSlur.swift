// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARSlur : ARBowing`, `kARBowingParams`
// (`"S,curve,down,o;U,dx1,2hs,o;U,dy1,1hs,o;U,dx2,-2hs,o;U,dy2,1hs,o;F,r3,0.5,o;U,h,2hs,o"`,
// `TagParameterStrings.cpp:41`). Range setting: `ONLY` — the notes the slur
// covers are its body.

/// A slur (`\slur`, alias `\sl`).
///
/// The notes the slur covers are its body.
///
/// ``GMNTie`` accepts exactly the same parameters. The two are separate
/// payloads because they are separate tags, not because they differ.
///
/// The common offsets are folded in, not replaced: `dx` is added to both
/// `dx1` and `dx2`, and `dy` to both `dy1` and `dy2`. So ``appearance`` and
/// ``controlPoints`` are not alternative spellings of one thing —
/// `\slur<dx=2hs>` and `\slur<dx1=2hs>` are different scores.
public struct GMNSlur {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new slur with the provided identifier, curve, control points,
    /// control ratio, height, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter curve:         Which way the slur bends, or `nil` if none
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
    /// replacing them — see the type’s discussion.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **All four non-omissible, proven.** `ARBowing` reads each without a
    // default and then records authorship outright in `fParSet = (dx1 || dx2
    // || dy1 || dy2 || dx || dy)` (`ARBowing.cpp:66–78`) — the class
    // inspecting its own parameters for authorship, in its own hand.

    /// The `dx1`/`dy1`/`dx2`/`dy2` offsets written for this tag.
    public let controlPoints: GMNTag.ControlPoints

    // **Non-omissible, proven.** Absence is `kUndefined`, a third state the
    // declared default `down` never reaches — see `GMNTag.Curve` for the open
    // parse that makes `curve="banana"` re-emit as `curve="up"`.

    /// Which way the slur bends (`curve`), or `nil` if none was written.
    public let curve: GMNTag.Curve?

    // **Non-omissible, proven.** Read without a default, yielding
    // `ARBowing::undefined()` — the sentinel `9999.f` — when absent, and
    // folded into `fParSet` alongside `r3` (`ARBowing.cpp:88–92`).
    //
    // `ARBowing` reads `h` as a `TagParameterFloat` and as nothing else
    // (`ARBowing.cpp:96`), matching the template's `U`. It was once exempted
    // instead, on a by-name reading of the ambiguity grep that conflated
    // this class with `ARSymbol` — see
    // `GMNTagTemplate.alternateParameterKinds`.

    /// The height of the curve’s apex (`h`), or `nil` if none was written.
    ///
    /// An `h` written as anything but a length is inert, and the normalizer
    /// drops it.
    public let h: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\slurBegin:1 …
    /// \slurEnd:1`.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven** — same read and same `fParSet` as `h`.

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

extension GMNSlur: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("slurBegin")

        case .end:
            GMNTag.Name("slurEnd")

        case .whole:
            GMNTag.Name("slur")
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

extension GMNSlur: Equatable {
}

// MARK: - Sendable

extension GMNSlur: Sendable {
}
