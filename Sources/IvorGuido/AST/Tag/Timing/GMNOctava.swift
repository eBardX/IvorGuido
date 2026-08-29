// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `AROctava`, `kAROctavaParams` (`"I,i,,r;S,hidden,off,o"`,
// `TagParameterStrings.cpp:66`). Range setting: `RANGEDC` — `\octava` may be
// written with a body or without one.

/// An octave transposition (`\oct`, `\octava`).
///
/// `\octava` may be written with a body or without one.
public struct GMNOctava {

    // MARK: Public Initializers

    /// Creates a new octave transposition with the provided identifier,
    /// offset, hidden setting, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter offset:     The transposition in octaves (`i`).
    /// - Parameter hidden:     Whether the octave bracket is hidden, as
    ///                         written, or `nil` if it was not written.
    ///                         Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                offset: Int,
                hidden: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.hidden = hidden
        self.ident = ident
        self.offset = offset
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    // **Non-omissible, proven.** `AROctava::setTagParameters` reads it
    // *without* `usedefault` and assigns `fHidden` only when it is present
    // (`AROctava.cpp:41–43`), so an absent `hidden` never applies the declared
    // default `off` — it leaves the class’s own initial value in place.
    // Absence and `hidden="off"` are two different paths.

    /// Whether the octave bracket is hidden (`hidden`), as written, or `nil`
    /// if it was not written.
    public let hidden: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The transposition in octaves written for this tag (`i`).
    ///
    /// Required by the template, so an `\octava` without it never promotes to
    /// this payload and stays reserved.
    public let offset: Int

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let offset = binding.integer(named: "i")
        else { return nil }

        self.init(ident: ident,
                  offset: offset,
                  hidden: binding.string(named: "hidden"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNOctava: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("octava")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["i": .integer(offset, nil)]

        values["hidden"] = hidden.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNOctava: Equatable {
}

// MARK: - Sendable

extension GMNOctava: Sendable {
}
