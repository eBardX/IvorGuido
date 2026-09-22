// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARAccelerando` and `ARRitardando`, both `TempoChange :
// ARFontAble`, `kARAccelerandoParams` and `kARRitardandoParams`
// (`"S,before,,o;S,after,,o;U,dx2,0hs,o;S,font,Times New
// Roman,o;U,fsize,10pt,o;S,textformat,lc,o"`, `TagParameterStrings.cpp:31,70`
// — the two strings are identical). Range setting: `ONLY` — the notes the
// change covers are its body.

/// A gradual tempo change (`\accelerando`, `\ritardando`).
///
/// The notes the change covers are its body.
///
/// Its positional parameters are `before`, `after`, `dx2`, `font`, `fsize`,
/// and `textformat`, in that order. The last three live in ``textStyle`` like
/// every other font parameter; only where they are emitted differs.
public struct GMNTempoChange {

    // MARK: Public Initializers

    // A closing half is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. The
    // parser can never build one — the normalizer drops what was written and
    // promotes the emptied tag — so the `span == .end` guard is what keeps a
    // hand-built score out of a shape the pipeline refuses.

    /// Creates a new tempo change with the provided identifier, direction,
    /// texts, offset, text style, span, appearance, and body.
    ///
    /// Returns `nil` when `span` is ``GMNTag/Span/end`` and anything was
    /// supplied alongside it: a closing half carries no parameters and no
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter direction:  Which way the tempo changes.
    /// - Parameter before:     The text drawn before the dashed line, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter after:      The text drawn after the dashed line, or `nil`
    ///                         if none was written. Defaults to `nil`.
    /// - Parameter dx2:        The horizontal offset of the line’s right end,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter textStyle:  The font parameters written for this tag.
    ///                         Defaults to none.
    /// - Parameter span:       Which part of a spanning construct this tag is.
    ///                         Defaults to ``GMNTag/Span/whole``.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init?(ident: GMNTag.Ident? = nil,
                 direction: Direction,
                 before: String? = nil,
                 after: String? = nil,
                 dx2: GMNLength? = nil,
                 textStyle: GMNTag.TextStyle = GMNTag.TextStyle(),
                 span: GMNTag.Span = .whole,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        self.after = after
        self.appearance = appearance
        self.before = before
        self.body = body
        self.direction = direction
        self.dx2 = dx2
        self.ident = ident
        self.span = span
        self.textStyle = textStyle

        guard span != .end || carriesNoParameters
        else { return nil }
    }

    // MARK: Public Instance Properties

    /// The text drawn after the dashed line (`after`), or `nil` if none was
    /// written.
    public let after: String?

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    // **Non-omissible, provisionally.** `TempoChange::setTagParameters` reads
    // `before`, `after`, and `dx2` with `usedefault=true`
    // (`TempoChange.cpp:24–29`), and none is on the `TagIsSet()` blocklist,
    // which puts all three in the explicitly provisional bucket.
    //
    // Left a `String` although guidolib runs it through `FormatStringParser`:
    // that parser splits the text into styled runs for rendering, it does not
    // narrow the vocabulary, so there is nothing closed to model (`\tempo`'s
    // own text makes the same call).

    /// The text drawn before the dashed line (`before`), or `nil` if none was
    /// written.
    public let before: String?

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// Which way the tempo changes.
    public let direction: Direction

    /// The horizontal offset of the dashed line’s right end (`dx2`), or `nil`
    /// if none was written.
    public let dx2: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    ///
    /// This is what pairs the halves of an open span: `\accelBegin:1 …
    /// \accelEnd:1`.
    public let ident: GMNTag.Ident?

    /// Which part of a spanning construct this tag is.
    public let span: GMNTag.Span

    /// The font parameters written for this tag.
    ///
    /// Three of the four are also this tag’s own positional slots — see the
    /// type’s discussion.
    public let textStyle: GMNTag.TextStyle

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
                  before: binding.string(named: "before"),
                  after: binding.string(named: "after"),
                  dx2: binding.length(named: "dx2"),
                  textStyle: binding.textStyle,
                  span: span,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNTempoChange: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(direction.tagName(for: span))
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values = textStyle.parameterValues

        values["after"] = after.map { .string($0) }
        values["before"] = before.map { .string($0) }
        values["dx2"] = dx2?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNTempoChange: Equatable {
}

// MARK: - Sendable

extension GMNTempoChange: Sendable {
}
