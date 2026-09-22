// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARKey`, `kARKeyParams`
// (`"S,key,,r;S,hideNaturals,false,o;S,free,,o"`,
// `TagParameterStrings.cpp:60`). Range setting: `NO` — `\key` takes no body.

/// A key signature (`\key`).
///
/// `\key` takes no body.
public struct GMNKey {

    // MARK: Public Initializers

    /// Creates a new key signature with the provided identifier, key,
    /// options, appearance, and body.
    ///
    /// - Parameter ident:        The numeric identifier written after this
    ///                           tag’s name. Defaults to `nil`.
    /// - Parameter key:          The key itself.
    /// - Parameter hideNaturals: Whether canceling naturals are suppressed,
    ///                           as written, or `nil` if it was not written.
    ///                           Defaults to `nil`.
    /// - Parameter free:         The free-key specification, or `nil` if none
    ///                           was written. Defaults to `nil`.
    /// - Parameter appearance:   The common appearance parameters written for
    ///                           this tag. Defaults to none.
    /// - Parameter body:         The symbols scoped to this tag. Defaults to
    ///                           none.
    public init(ident: GMNTag.Ident? = nil,
                key: GMNTag.NumberOrName,
                hideNaturals: String? = nil,
                free: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.free = free
        self.hideNaturals = hideNaturals
        self.ident = ident
        self.key = key
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so that a malformed score still round-trips what was written —
    /// reporting it is the validator’s job, not the parser’s.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Non-omissible, proven.** `ARKey::setTagParameters` reads it without
    // `usedefault` and sets `fIsFree = true` only when it is present
    // (`ARKey.cpp:102–106`), so absence is directly observable in the rendered
    // result.

    /// The free-key specification written for this tag (`free`), or `nil` if
    /// none was written.
    public let free: String?

    // **Non-omissible, proven.** Read without `usedefault`, and its presence
    // alone sets `fHideAutoNaturalsSet` (`ARKey.cpp:97–101`) — a flag whose
    // entire purpose is to distinguish “the author wrote this” from “the
    // author wrote nothing”, which is exactly the distinction omitting it
    // would erase.

    /// Whether canceling naturals are suppressed (`hideNaturals`), as
    /// written, or `nil` if it was not written.
    ///
    /// Not a `Bool`: a range of spellings is accepted, and re-spelling one as
    /// another would change what the score says.
    public let hideNaturals: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // A name goes to `ARKey::name2KeyNum`; a number is read through the
    // second, integer-typed lookup that fires only when the string one comes
    // back null (`ARKey.cpp:88–96`).
    //
    // The template declares `S` and nothing else, so before this was
    // recorded a `\key<2>` bound to an apparently ill-typed slot and stayed
    // on the untyped lane, undiagnosed. See
    // `GMNTagTemplate.alternateParameterKinds`.

    /// The key written for this tag (`key`).
    ///
    /// Required, so a `\key` without it stays reserved. It may be written
    /// either way: a ``GMNTag/NumberOrName/name(_:)`` is a note name whose
    /// case selects major or minor, optionally with a `free=…` prefix, and a
    /// ``GMNTag/NumberOrName/number(_:)`` is the count of accidentals.
    public let key: GMNTag.NumberOrName

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let key = binding.numberOrName(named: "key")
        else { return nil }

        self.init(ident: ident,
                  key: key,
                  hideNaturals: binding.string(named: "hideNaturals"),
                  free: binding.string(named: "free"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNKey: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("key")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["key": key.parameterValue]

        values["free"] = free.map { .string($0) }
        values["hideNaturals"] = hideNaturals.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNKey: Equatable {
}

// MARK: - Sendable

extension GMNKey: Sendable {
}
