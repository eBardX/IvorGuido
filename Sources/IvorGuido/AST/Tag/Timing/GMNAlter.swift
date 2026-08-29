// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARAlter`, `kARAlterParams` (`"F,detune,0.0,r;S,text,,o"`,
// `TagParameterStrings.cpp:34`). Range setting: `RANGEDC` — `\alter` may be
// written with a body or without one.

/// A microtonal detuning (`\alter`).
///
/// `\alter` may be written with a body or without one.
public struct GMNAlter {

    // MARK: Public Initializers

    /// Creates a new detuning with the provided identifier, amount, text,
    /// appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter detune:     The detuning amount, in semitones.
    /// - Parameter text:       The text displayed in place of the amount, or
    ///                         `nil` if none was written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                detune: Double,
                text: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.detune = detune
        self.ident = ident
        self.text = text
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The detuning amount written for this tag (`detune`), in semitones.
    ///
    /// Required by the template, so a `\alter` without it never promotes to
    /// this payload at all and stays reserved.
    public let detune: Double

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible.** `ARAlter::getAlterText` reads it without `usedefault`
    // and, when it is absent, synthesizes the string from `detune` instead
    // (`ARAlter.cpp:41–49`) — so absence selects a different code path rather
    // than a default value.

    /// The text displayed in place of the detuning amount (`text`), or `nil`
    /// if none was written.
    public let text: String?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let detune = binding.double(named: "detune")
        else { return nil }

        self.init(ident: ident,
                  detune: detune,
                  text: binding.string(named: "text"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNAlter: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("alter")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["detune": .number(detune)]

        values["text"] = text.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNAlter: Equatable {
}

// MARK: - Sendable

extension GMNAlter: Sendable {
}
