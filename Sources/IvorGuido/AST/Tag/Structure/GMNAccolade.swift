// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARAccolade`, `kARAccoladeParams`
// (`"I,id,,r;S,range,,r;S,type,standard,o"`, `TagParameterStrings.cpp:33`).
// Range setting: `NO` — `\accolade` takes no body.

/// A brace or bracket joining staves (`\accol`, `\accolade`).
///
/// `\accolade` takes no body.
public struct GMNAccolade {

    // MARK: Public Initializers

    /// Creates a new accolade with the provided identifier, own identifier,
    /// staff range, type, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter id:         The accolade’s own numeric identifier.
    /// - Parameter range:      The staves the accolade spans.
    /// - Parameter type:       The accolade’s shape, or `nil` if none was
    ///                         written. Defaults to `nil`.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                id: Int,
                range: String,
                type: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.id = id
        self.ident = ident
        self.range = range
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

    // **Non-omissible** (`GRAccolade.cpp:94`) — moot for a required
    // parameter, and recorded because the audit covered it.
    //
    // `ARAccolade` has no `setTagParameters` at all; it exposes three getters
    // that read the map directly (`ARAccolade.h:51–54`), and all three
    // inspect authorship with `TagIsSet()`.
    //
    // `ARAccolade` declares both `getIDString()` and `getIDInt()`
    // (`ARAccolade.h:57–58`), but only the latter has a caller
    // (`GRAccolade.cpp:92`), so the string accessor is dead and this is not a
    // name read twice. It was once exempted instead; see
    // `GMNTagTemplate.alternateParameterKinds`.

    /// The accolade’s own numeric identifier (`id`).
    ///
    /// Required, so an accolade without it stays reserved. It must be a
    /// number: `id="brace"` is inert, and the normalizer drops it, leaving the
    /// required parameter missing.
    public let id: Int

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible** (`GRAccolade.cpp:66`).

    /// The staves the accolade spans (`range`).
    ///
    /// Required, so an accolade without it stays reserved. Written as an
    /// open syntax of staff numbers, dashes, and commas, and left unparsed
    /// here.
    public let range: String

    // **Non-omissible**: `GRAccolade.cpp:37` inspects it for authorship, so
    // absence is a state the declared default cannot stand in for.

    /// The accolade’s shape (`type`), or `nil` if none was written. Declared
    /// default: `standard`.
    public let type: String?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let id = binding.integer(named: "id"),
              let range = binding.string(named: "range")
        else { return nil }

        self.init(ident: ident,
                  id: id,
                  range: range,
                  type: binding.string(named: "type"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNAccolade: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("accolade")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["id": .integer(id, nil),
                                                        "range": .string(range)]

        values["type"] = type.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNAccolade: Equatable {
}

// MARK: - Sendable

extension GMNAccolade: Sendable {
}
