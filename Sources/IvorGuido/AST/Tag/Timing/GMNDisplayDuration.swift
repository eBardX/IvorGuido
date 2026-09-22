// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARDisplayDuration`, `kARDisplayDurationParams`
// (`"I,n,,r;I,d,,r;I,ndots,0,o"`, `TagParameterStrings.cpp:48`). Range
// setting: `ONLY` — `\displayDuration` takes the notes it re-notates as its
// body.

/// A notated-duration override (`\dispDur`, `\displayDuration`).
///
/// Forces the *appearance* of the notes it covers to a given duration,
/// leaving their actual duration untouched.
///
/// `\displayDuration` takes the notes it re-notates as its body.
///
/// Both spellings mean exactly the same thing; the long form is what a tag is
/// written back as.
public struct GMNDisplayDuration {

    // MARK: Public Initializers

    /// Creates a new notated-duration override with the provided identifier,
    /// fraction, dot count, appearance, and body.
    ///
    /// Returns `nil` when `denominator` is `0`.
    ///
    /// - Parameter ident:       The numeric identifier written after this
    ///                          tag’s name. Defaults to `nil`.
    /// - Parameter numerator:   The numerator of the notated duration (`n`).
    /// - Parameter denominator: The denominator of the notated duration
    ///                          (`d`).
    /// - Parameter dotCount:    The number of augmentation dots (`ndots`), or
    ///                          `nil` if none was written. Defaults to `nil`.
    /// - Parameter appearance:  The common appearance parameters written for
    ///                          this tag. Defaults to none.
    /// - Parameter body:        The symbols scoped to this tag. Defaults to
    ///                          none.
    public init?(ident: GMNTag.Ident? = nil,
                 numerator: Int,
                 denominator: Int,
                 dotCount: Int? = nil,
                 appearance: GMNTag.Appearance = GMNTag.Appearance(),
                 body: [GMNSymbol] = []) {
        guard denominator != 0
        else { return nil }

        self.appearance = appearance
        self.body = body
        self.denominator = denominator
        self.dotCount = dotCount
        self.ident = ident
        self.numerator = numerator
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag, or empty if none were written.
    public let body: [GMNSymbol]

    /// The denominator of the notated duration (`d`).
    ///
    /// Required by the template, and read together with ``numerator`` — a
    /// tag missing either one never promotes to this payload.
    public let denominator: Int

    // **Non-omissible, provisionally.** `ARDisplayDuration::setTagParameters`
    // reads it with `usedefault=true` (`ARDisplayDuration.cpp:45–46`) and it
    // is not on the `TagIsSet()` blocklist — but treated as non-omissible
    // for now. The formatter takes the safe branch and never drops it.

    /// The number of augmentation dots written for this tag (`ndots`), or
    /// `nil` if none was written.
    public let dotCount: Int?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The numerator of the notated duration (`n`).
    public let numerator: Int

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let numerator = binding.integer(named: "n"),
              let denominator = binding.integer(named: "d")
        else { return nil }

        self.init(ident: ident,
                  numerator: numerator,
                  denominator: denominator,
                  dotCount: binding.integer(named: "ndots"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNDisplayDuration: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("displayDuration")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["d": .integer(denominator, nil),
                                                        "n": .integer(numerator, nil)]

        values["ndots"] = dotCount.map { .integer($0, nil) }

        return values
    }
}

// MARK: - Equatable

extension GMNDisplayDuration: Equatable {
}

// MARK: - Sendable

extension GMNDisplayDuration: Sendable {
}
