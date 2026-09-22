// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARStaff`, `kARStaffParams` (`"I,id,,r"`,
// `TagParameterStrings.cpp:75`). Range setting: `NO` — `\staff` takes no body.

/// A staff assignment (`\staff`).
///
/// `\staff` takes no body.
public struct GMNStaff {

    // MARK: Public Initializers

    /// Creates a new staff assignment with the provided identifier, staff
    /// number, appearance, and body.
    ///
    /// - Parameter ident:      The numeric identifier written after this tag’s
    ///                         name. Defaults to `nil`.
    /// - Parameter id:         The staff to place the following music on.
    /// - Parameter appearance: The common appearance parameters written for
    ///                         this tag. Defaults to none.
    /// - Parameter body:       The symbols scoped to this tag. Defaults to
    ///                         none.
    public init(ident: GMNTag.Ident? = nil,
                id: GMNTag.NumberOrName,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.id = id
        self.ident = ident
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

    // **Non-omissible**, moot for a required parameter.
    //
    // `\staff` is one of the two tags whose class reads a parameter under two
    // C++ types, and the clearest case of it: `getStaffNumber()` reads `id` as
    // a `TagParameterInt` and `getStaffID()` as a `TagParameterString`
    // (`ARStaff.cpp:50–64`), the former returning the sentinel `-1` precisely
    // when the latter would answer.
    //
    // The template declares `I` and nothing else, so before this was
    // recorded a named staff bound to an apparently ill-typed slot and
    // stayed on the untyped lane, undiagnosed. See
    // `GMNTagTemplate.alternateParameterKinds`.

    /// The staff to place the following music on (`id`).
    ///
    /// Required, so a `\staff` without it stays reserved. It may be written
    /// either way: `\staff<2>` is a ``GMNTag/NumberOrName/number(_:)`` and
    /// `\staff<"upper">` a ``GMNTag/NumberOrName/name(_:)``.
    public let id: GMNTag.NumberOrName

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let id = binding.numberOrName(named: "id")
        else { return nil }

        self.init(ident: ident,
                  id: id,
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNStaff: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("staff")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        ["id": id.parameterValue]
    }
}

// MARK: - Equatable

extension GMNStaff: Equatable {
}

// MARK: - Sendable

extension GMNStaff: Sendable {
}
