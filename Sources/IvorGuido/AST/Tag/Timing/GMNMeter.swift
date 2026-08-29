// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARMeter`, `kARMeterParams`
// (`"S,type,4/4,r;S,autoBarlines,on,o;S,autoMeasuresNum,off,o;S,group,off,o;S,hidden,off,o"`,
// `TagParameterStrings.cpp:63`). Range setting: `NO` — `\meter` takes no body.

/// A time signature (`\meter`).
///
/// `\meter` takes no body.
///
/// Every one of the four options is written as a string rather than a
/// Boolean: three accept a range of on/off spellings and the fourth accepts
/// `on`, `page`, or `system`, and re-spelling one accepted form as another
/// would change what the score says.
public struct GMNMeter {

    // MARK: Public Initializers

    /// Creates a new time signature with the provided identifier, type,
    /// options, appearance, and body.
    ///
    /// - Parameter ident:           The numeric identifier written after this
    ///                              tag’s name. Defaults to `nil`.
    /// - Parameter type:            The meter itself.
    /// - Parameter autoBarlines:    Whether bar lines are generated
    ///                              automatically, as written, or `nil` if it
    ///                              was not written. Defaults to `nil`.
    /// - Parameter autoMeasuresNum: Where measure numbers are shown, as
    ///                              written, or `nil` if it was not written.
    ///                              Defaults to `nil`.
    /// - Parameter group:           Whether complex meters are grouped, as
    ///                              written, or `nil` if it was not written.
    ///                              Defaults to `nil`.
    /// - Parameter hidden:          Whether the meter is hidden, as written,
    ///                              or `nil` if it was not written. Defaults
    ///                              to `nil`.
    /// - Parameter appearance:      The common appearance parameters written
    ///                              for this tag. Defaults to none.
    /// - Parameter body:            The symbols scoped to this tag. Defaults
    ///                              to none.
    public init(ident: GMNTag.Ident? = nil,
                type: String,
                autoBarlines: String? = nil,
                autoMeasuresNum: String? = nil,
                group: String? = nil,
                hidden: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.autoBarlines = autoBarlines
        self.autoMeasuresNum = autoMeasuresNum
        self.body = body
        self.group = group
        self.hidden = hidden
        self.ident = ident
        self.type = type
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    // **Non-omissible, provisionally.** Read with `usedefault=true`
    // (`ARMeter.cpp:179`) and not on the `TagIsSet()` blocklist, which puts it
    // in the provisional bucket; the formatter takes the safe branch.

    /// Whether bar lines are generated automatically (`autoBarlines`), as
    /// written, or `nil` if it was not written.
    public let autoBarlines: String?

    // **Non-omissible, provisionally** — same verdict as `autoBarlines`
    // (`ARMeter.cpp:173–176`).

    /// Where measure numbers are shown (`autoMeasuresNum`), as written, or
    /// `nil` if it was not written.
    public let autoMeasuresNum: String?

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. Preserved
    /// so a malformed score still round-trips; reporting it is the validator’s
    /// job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Non-omissible, provisionally** — same verdict as `autoBarlines`
    // (`ARMeter.cpp:180`).

    /// Whether complex meters are grouped (`group`), as written, or `nil` if
    /// it was not written.
    public let group: String?

    // **Non-omissible, provisionally** — same verdict as `autoBarlines`
    // (`ARMeter.cpp:178`).

    /// Whether the meter is hidden (`hidden`), as written, or `nil` if it was
    /// not written.
    public let hidden: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// The meter written for this tag (`type`).
    ///
    /// Required, so a `\meter` without it stays reserved. The grammar admits
    /// `"4/4"`, additive forms such as `"2+3/8"`, and the words `C` and `C/`.
    public let type: String

    // MARK: Internal Initializers

    internal init?(ident: GMNTag.Ident?,
                   binding: GMNTagBinder.Binding,
                   body: [GMNSymbol]) {
        guard let type = binding.string(named: "type")
        else { return nil }

        self.init(ident: ident,
                  type: type,
                  autoBarlines: binding.string(named: "autoBarlines"),
                  autoMeasuresNum: binding.string(named: "autoMeasuresNum"),
                  group: binding.string(named: "group"),
                  hidden: binding.string(named: "hidden"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNMeter: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("meter")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = ["type": .string(type)]

        values["autoBarlines"] = autoBarlines.map { .string($0) }
        values["autoMeasuresNum"] = autoMeasuresNum.map { .string($0) }
        values["group"] = group.map { .string($0) }
        values["hidden"] = hidden.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNMeter: Equatable {
}

// MARK: - Sendable

extension GMNMeter: Sendable {
}
