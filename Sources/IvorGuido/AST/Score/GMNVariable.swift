// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A variable definition in a Guido Music Notation score.
public struct GMNVariable {

    // MARK: Public Initializers

    /// Creates a new variable definition with the provided name and value.
    ///
    /// - Parameter name:   The name of this variable.
    /// - Parameter value:  The value of this variable.
    public init(name: Name,
                value: Value) {
        self.init(name: name,
                  value: value,
                  symbols: nil)
    }

    // MARK: Public Instance Properties

    /// The name of this variable.
    public let name: Name

    /// The value of this variable.
    public let value: Value

    // MARK: Internal Initializers

    internal init(name: Name,
                  value: Value,
                  symbols: [GMNSymbol]?) {
        self.name = name
        self.symbols = symbols
        self.value = value
    }

    // MARK: Internal Instance Properties

    // A best-effort, declaration-time parse of this variable’s body into
    // symbols. guidolib re-lexes a variable’s raw text inline at each
    // reference point (`GuidoParser.cpp:345–361`), so this single
    // declaration-time approximation covers the common case — a string
    // variable used consistently in symbol position — leaving per-reference
    // splicing and inheritance to the resolver.
    //
    // Three states, and `[]` is not `nil`:
    //
    //   - `[]` — an empty body, which guidolib allows and which contributes
    //     nothing at each reference.
    //   - `nil` — this variable *cannot* supply symbols: its value is a
    //     number, or a string whose body does not lex as GMN. Legal as a tag
    //     parameter, where guidolib substitutes it by declared type; a
    //     symbol-position reference to one is rejected by `GMNParser`.
    //   - otherwise, the parsed fragment.
    //
    // A score built by hand can still carry `nil` here and reference it in
    // symbol position, which the parser would refuse; the resolver treats
    // that as contributing nothing.
    internal let symbols: [GMNSymbol]?
}

// MARK: - Equatable

extension GMNVariable: Equatable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether two variables are equal.
    ///
    /// Two variables are equal when their ``name`` and ``value`` match.
    ///
    /// - Parameter lhs:    The first variable to compare.
    /// - Parameter rhs:    The second variable to compare.
    ///
    /// - Returns:  `true` if the two variables are equal; otherwise, `false`.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        // `symbols` is deliberately excluded: it is a derived,
        // declaration-time parse of `value` rather than content in its own
        // right, so a parsed variable must compare equal to an identical one
        // built via `init(name:value:)`.

        lhs.name == rhs.name
        && lhs.value == rhs.value
    }
}

// MARK: - Sendable

extension GMNVariable: Sendable {
}
