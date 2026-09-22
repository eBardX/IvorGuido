// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARGlissando`, `kARGlissandoParams`
// (`"U,dx1,0,o;U,dy1,0,o;U,dx2,0,o;U,dy2,0,o;S,fill,false,o;U,thickness,0.3,o"`,
// `TagParameterStrings.cpp:54`). Range setting: `ONLY` — the notes the
// glissando joins are its body.
//
// One of the three tags carrying the full control-point quartet, and the one
// that is not an `ARBowing` — see `GMNTag.ControlPoints`.

/// A glissando (`\glissando`).
///
/// The notes the glissando joins are written as its body. It carries the full
/// ``GMNTag/ControlPoints`` quartet.
public struct GMNGlissando {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new glissando with the provided identifier, control points,
    /// fill, thickness, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter controlPoints: The `dx1`/`dy1`/`dx2`/`dy2` offsets written
    ///                            for this tag. Defaults to none.
    /// - Parameter fill:          Whether the glissando is drawn filled, as
    ///                            written, or `nil` if it was not written.
    ///                            Defaults to `nil`.
    /// - Parameter thickness:     The glissando’s line thickness, or `nil` if
    ///                            none was written. Defaults to `nil`.
    /// - Parameter span:          Which part of a spanning construct this tag
    ///                            is. Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance:    The common appearance parameters written for
    ///                            this tag. Defaults to none.
    /// - Parameter body:          The symbols scoped to this tag. Defaults to
    ///                            none.
    public init?(ident: GMNTag.Ident? = nil,
                 controlPoints: GMNTag.ControlPoints = GMNTag.ControlPoints(),
                 fill: String? = nil,
                 thickness: GMNLength? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.controlPoints = controlPoints
        self.fill = fill
        self.ident = ident
        self.span = span
        self.thickness = thickness

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **All four non-omissible, provisionally.**
    // `ARGlissando::setTagParameters` reads each with `usedefault=true`
    // (`ARGlissando.cpp:60–67`), which is the provisional bucket. Note that
    // this is a weaker guarantee than `GMNSlur`'s: `ARBowing` records
    // authorship outright in `fParSet`, whereas `ARGlissando` keeps no such
    // flag.

    /// The `dx1`/`dy1`/`dx2`/`dy2` offsets written for this tag.
    public let controlPoints: GMNTag.ControlPoints

    /// Whether the glissando is drawn filled (`fill`), as written, or `nil`
    /// if it was not written.
    public let fill: String?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\glissandoBegin:1 …
    /// \glissandoEnd:1`.
    public let ident: GMNTag.Ident?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    /// The glissando’s line thickness (`thickness`), or `nil` if none was
    /// written.
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
                  controlPoints: binding.controlPoints,
                  fill: binding.string(named: "fill"),
                  thickness: binding.length(named: "thickness"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNGlissando: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        switch span {
        case .begin:
            GMNTag.Name("glissandoBegin")

        case .end:
            GMNTag.Name("glissandoEnd")

        case .whole:
            GMNTag.Name("glissando")
        }
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = controlPoints.parameterValues

        values["fill"] = fill.map { .string($0) }
        values["thickness"] = thickness?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNGlissando: Equatable {
}

// MARK: - Sendable

extension GMNGlissando: Sendable {
}
