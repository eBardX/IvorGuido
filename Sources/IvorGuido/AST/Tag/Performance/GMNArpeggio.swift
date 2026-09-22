// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARArpeggio`, `kARArpeggioParams` (`"S,direction,,o"`,
// `TagParameterStrings.cpp:35`). Range setting: `ONLY` — the notes the
// arpeggio covers are its body.
//
// ## `\arpeggioEnd` is not a tag
//
// `ARArpeggio::MatchEndTag` accepts the string `\arpeggioEnd`
// (`ARArpeggio.cpp:33–39`), which reads like the closing half of an open
// span — but `ARFactory::createTag` dispatches no such name, so nothing ever
// builds one and writing it reaches the unknown-name fallback instead. This
// payload therefore carries no `GMNTag.Span`.

/// An arpeggiated chord (`\arpeggio`).
///
/// The notes the arpeggio covers are written as its body. `\arpeggio` has the
/// range form only — there is no `\arpeggioEnd` counterpart, so this tag never
/// spans an open pair.
public struct GMNArpeggio {

    // MARK: Public Initializers

    /// Creates a new arpeggio with the provided identifier, direction,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter direction:  Which way the arpeggio is rolled, or `nil` if
    ///                         none was written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                direction: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.direction = direction
        self.ident = ident
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARArpeggio.cpp:42–48`), so absence leaves the class's own
    // `kUnknown` rather than applying the declared default — which is empty
    // here in any case.
    //
    // Left a `String` rather than a two-case enum: closed Swift enums here
    // are confined to the enumerated list of C++ enumerations the model
    // commits to, and this is not one of them.

    /// Which way the arpeggio is rolled (`direction`), or `nil` if none was
    /// written.
    ///
    /// The recognized values are `up` and `down`; anything else is ignored
    /// when the score is rendered.
    public let direction: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  direction: binding.string(named: "direction"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNArpeggio: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("arpeggio")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["direction"] = direction.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNArpeggio: Equatable {
}

// MARK: - Sendable

extension GMNArpeggio: Sendable {
}
