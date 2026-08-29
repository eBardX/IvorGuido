// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARCrescendo` and `ARDiminuendo`, both `ARDynamic`,
// `kARDynamicParams`
// (`"U,dx1,0,o;U,dx2,0,o;U,deltaY,3,o;U,thickness,0.16,o;S,autopos,off,o"`,
// `TagParameterStrings.cpp:49`). Range setting: `ONLY` — the notes the ramp
// covers are its body.
//
// ## Two endpoints, not four
//
// `kARDynamicParams` declares `dx1` and `dx2` and no `dy1`/`dy2`, so this
// payload keeps its own two fields rather than borrowing
// `GMNTag.ControlPoints` with holes in it — the grouping follows the
// parameter strings, exactly as that type's own discussion says.

/// A gradual dynamic change (`\crescendo`, `\diminuendo`).
///
/// The notes the ramp covers are written as its body. A hairpin has two
/// horizontal offsets, ``dx1`` and ``dx2``, and no vertical pair — its
/// vertical extent is ``deltaY`` instead.
public struct GMNDynamicRamp {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new dynamic ramp with the provided identifier, direction,
    /// offsets, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter direction:  Which way the dynamic ramps.
    /// - Parameter dx1:        The horizontal offset of the ramp’s left end,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter dx2:        The horizontal offset of the ramp’s right end,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter deltaY:     The vertical opening of the hairpin, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter thickness:  The hairpin’s line thickness, or `nil` if none
    ///                         was written. Defaults to `nil`.
    /// - Parameter autopos:    Whether the ramp is positioned automatically,
    ///                         as written, or `nil` if it was not written.
    ///                         Defaults to `nil`.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 direction: Direction,
                 dx1: GMNLength? = nil,
                 dx2: GMNLength? = nil,
                 deltaY: GMNLength? = nil,
                 thickness: GMNLength? = nil,
                 autopos: String? = nil,
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.autopos = autopos
        self.body = body
        self.deltaY = deltaY
        self.direction = direction
        self.dx1 = dx1
        self.dx2 = dx2
        self.ident = ident
        self.span = span
        self.thickness = thickness

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// Whether the ramp is positioned automatically (`autopos`), as written,
    /// or `nil` if it was not written.
    public let autopos: String?

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The vertical opening of the hairpin (`deltaY`), or `nil` if none was
    /// written.
    public let deltaY: GMNLength?

    /// Which way the dynamic ramps.
    public let direction: Direction

    // **Non-omissible, provisionally.** `ARDynamic::setTagParameters` reads
    // all five parameters with `usedefault=true` (`ARDynamic.cpp:57–63`), and
    // none is on the `TagIsSet()` blocklist — but treated as non-omissible
    // for now. The formatter takes the safe branch,
    // which costs nothing here: every field is `Optional` and absence is
    // preserved, so rule 5 never fires either way.

    /// The horizontal offset of the ramp’s left end (`dx1`), or `nil` if none
    /// was written.
    public let dx1: GMNLength?

    /// The horizontal offset of the ramp’s right end (`dx2`), or `nil` if
    /// none was written.
    public let dx2: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\crescBegin:1 …
    /// \crescEnd:1`.
    public let ident: GMNTag.Ident?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    /// The hairpin’s line thickness (`thickness`), or `nil` if none was
    /// written.
    public let thickness: GMNLength?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   direction: Direction,
                   span: GMNTag.Span,
                   body: [GMNSymbol]) {
        guard span != .end
        else {
            self.init(ident: ident,
                      direction: direction,
                      span: .end,
                      body: body)

            return
        }

        self.init(ident: ident,
                  direction: direction,
                  dx1: binding.length(named: "dx1"),
                  dx2: binding.length(named: "dx2"),
                  deltaY: binding.length(named: "deltaY"),
                  thickness: binding.length(named: "thickness"),
                  autopos: binding.string(named: "autopos"),
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNDynamicRamp: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(direction.tagName(for: span))
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["autopos"] = autopos.map { .string($0) }
        values["deltaY"] = deltaY?.parameterValue
        values["dx1"] = dx1?.parameterValue
        values["dx2"] = dx2?.parameterValue
        values["thickness"] = thickness?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNDynamicRamp: Equatable {
}

// MARK: - Sendable

extension GMNDynamicRamp: Sendable {
}
