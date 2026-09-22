// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARClef`, `kARClefParams` (`"S,type,treble,r"`,
// `TagParameterStrings.cpp:42`). Range setting: `NO` — `\clef` takes no body.

/// A clef (`\clef`).
///
/// `\clef` takes no body.
public struct GMNClef {

    // MARK: Public Initializers

    /// Creates a new clef with the provided identifier, type, appearance, and
    /// body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter type:       The clef itself.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                type: String,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.ident = ident
        self.type = type
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

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // Required by the template, so omissibility does not arise even though
    // `ARClef` does read it with `usedefault=true` (`ARClef.cpp:96`).
    //
    // Left a `String`: `ARClef::decodeOctava` strips the octave suffix
    // (`ARClef.cpp:100–118`) before a map lookup, and an unknown name is
    // accepted (`ARClef.cpp:129–132`) rather than rejected.

    /// The clef written for this tag (`type`).
    ///
    /// Required, so a `\clef` without it stays reserved. The grammar is
    /// open: a clef name may carry a trailing `+8` or `-15` octave suffix,
    /// and an unrecognized name turns the clef off rather than being
    /// rejected.
    public let type: String

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let type = binding.string(named: "type")
        else { return nil }

        self.init(ident: ident,
                  type: type,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNClef: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("clef")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["type": .string(type)]
    }
}

// MARK: - Equatable

extension GMNClef: Equatable {
}

// MARK: - Sendable

extension GMNClef: Sendable {
}
