// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARJump` and its seven pure subclasses, `kARJumpParams`
// (`"S,m,,o;I,id,0,o"`, `TagParameterStrings.cpp:59`). Range setting: `NO` — a
// jump takes no body.
//
// `ARSegno : ARJump` overrides `getParamsStr()` to `""` (`ARSegno.h:42`)
// while still *supporting* `kARJumpParams`. Nothing in this payload encodes
// that; the registry holds a separate template for `segno` and the formatter
// reads the ordering from there, which is exactly why the registry
// transcribes per class rather than per hierarchy.

/// A navigation mark (`\coda`, `\daCapo`, `\daCapoAlFine`, `\daCoda`,
/// `\dalSegno`, `\dalSegnoAlFine`, `\fine`, `\segno`).
///
/// A jump takes no body.
///
/// ``Kind/segno`` is the exception to watch: `\segno` has no positional
/// parameters, so `\segno<"D.S.">` binds nothing and its `id` and `m` must
/// always be written named. Every other kind takes them positionally.
public struct GMNJump {

    // MARK: Public Initializers

    /// Creates a new navigation mark with the provided identifier, kind, mark
    /// text, own identifier, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter kind:       Which navigation mark this is.
    /// - Parameter mark:       The text drawn in place of the default label,
    ///                         or `nil` if none was written. Defaults to
    ///                         `nil`.
    /// - Parameter id:         The mark’s own numeric identifier, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                kind: Kind,
                mark: String? = nil,
                id: Int? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.id = id
        self.ident = ident
        self.kind = kind
        self.mark = mark
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

    // **Non-omissible, proven — for an unusual reason.** `ARJump` does not
    // read this parameter at all: both the read and the field it fed are
    // commented out (`ARJump.cpp:40`, `ARJump.h:38,43`). A parameter no
    // consumer reads cannot satisfy condition 1, which asks what the *reader*
    // does with `usedefault`, so it stays as written. The template still
    // declares it, so writing it is legal and it must survive the round trip.

    /// The mark’s own numeric identifier (`id`), or `nil` if none was written.
    /// Declared default: `0`.
    ///
    /// It must be a number: `id="fine"` is inert, and the normalizer drops
    /// it.
    public let id: Int?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Which navigation mark this is.
    public let kind: Kind

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARJump.cpp:34`) and not on the `TagIsSet()` blocklist, which puts it
    // in the provisional bucket; the formatter takes the safe branch.

    /// The text drawn in place of the default label (`m`), or `nil` if none
    /// was written.
    ///
    /// Arbitrary text, with embedded substitutions permitted.
    public let mark: String?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  kind: Kind,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  kind: kind,
                  mark: binding.string(named: "m"),
                  id: binding.integer(named: "id"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNJump: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name(kind.tagName)
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["id"] = id.map { .integer($0, nil) }
        values["m"] = mark.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNJump: Equatable {
}

// MARK: - Sendable

extension GMNJump: Sendable {
}
