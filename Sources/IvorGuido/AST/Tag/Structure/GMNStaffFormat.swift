// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// guidolib: `ARStaffFormat`, `kARStaffFormatParams`
// (`"S,style,standard,o;U,size,3pt,o;F,lineThickness,0.08,o;U,distance,0hs,o"`,
// `TagParameterStrings.cpp:74`). Range setting: `NO` — `\staffFormat` takes no
// body.
//
// `kARStaffFormatParams` redeclares `size` — a `kCommonParams` name — as its
// second positional slot, and changes its *kind* while doing so: `U` rather
// than `F`. Since `setupTagParameters` overwrites by name
// (`TagParameterMap.cpp:130–134`), the length declaration is the one that
// survives, and `ARStaffFormat::getSize` returns whichever of the two a
// consumer actually set (`ARStaffFormat.cpp:44–47`).

/// A staff-drawing setting (`\staffFormat`).
///
/// `\staffFormat` takes no body.
///
/// ## `size` here is a length, not a scaling factor
///
/// `size` is one of this tag’s own positional parameters, and it means
/// something different here than it does elsewhere: a length defaulting to
/// `3pt`, rather than the scaling factor the common `size` is. It is
/// therefore carried by ``size`` rather than by ``appearance`` — the one tag
/// whose ``GMNTag/Appearance`` is deliberately missing a field it would
/// otherwise hold. Reading it through ``appearance`` would silently drop the
/// unit.
public struct GMNStaffFormat {

    // MARK: Public Initializers

    /// Creates a new staff format with the provided identifier, style, size,
    /// line thickness, distance, appearance, and body.
    ///
    /// - Parameter ident:         The numeric identifier written after this
    ///                            tag’s name. Defaults to `nil`.
    /// - Parameter style:         How the staff is drawn, or `nil` if nothing
    ///                            was written. Defaults to `nil`.
    /// - Parameter size:          The staff size, or `nil` if none was
    ///                            written. Defaults to `nil`.
    /// - Parameter lineThickness: The staff line thickness, or `nil` if none
    ///                            was written. Defaults to `nil`.
    /// - Parameter distance:      The distance to the staff above, or `nil` if
    ///                            none was written. Defaults to `nil`.
    /// - Parameter appearance:    The common appearance parameters written for
    ///                            this tag, `size` excepted. Defaults to none.
    /// - Parameter body:          The symbols scoped to this tag. Defaults to
    ///                            none.
    public init(ident: GMNTag.Ident? = nil,
                style: String? = nil,
                size: GMNLength? = nil,
                lineThickness: Double? = nil,
                distance: GMNLength? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.body = body
        self.distance = distance
        self.ident = ident
        self.lineThickness = lineThickness
        self.size = size
        self.style = style
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    ///
    /// Its `size` is always `nil` — see the type’s discussion and ``size``.
    public let appearance: GMNTag.Appearance

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    // **Non-omissible.** `getStaffDistance` reads it without `usedefault`
    // (`ARStaffFormat.cpp:43`) and hands its consumers a null pointer when it
    // is absent, so absent and default-valued reach different code paths.

    /// The distance to the staff above (`distance`), or `nil` if none was
    /// written. Declared default: `0hs`.
    public let distance: GMNLength?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    // **Non-omissible, proven.** Read without `usedefault` and assigned only
    // when present (`ARStaffFormat.cpp:51–52`), so absence leaves the class’s
    // own `kLineThick`, which the declared default does not reproduce.

    /// The staff line thickness (`lineThickness`), or `nil` if none was
    /// written. Declared default: `0.08`.
    public let lineThickness: Double?

    // **Non-omissible, proven.** Read without `usedefault`, and setting it
    // calls `setBySet()` explicitly (`ARStaffFormat.cpp:53–66`) so that
    // `getSize` can tell a written size from an inherited one — condition 2 in
    // the class’s own hand.

    /// The staff size (`size`), or `nil` if none was written. Declared
    /// default: `3pt`.
    ///
    /// This is a length, not the scaling factor the common `size` is; see the
    /// type’s discussion.
    public let size: GMNLength?

    // **Non-omissible**: `ARStaffFormat.cpp:69` guards the whole reading on
    // `style->TagIsSet()`, so a written `style="standard"` sets the line
    // count and an omitted one does not.

    /// How the staff is drawn (`style`), or `nil` if nothing was written.
    /// Declared default: `standard`.
    ///
    /// An open grammar rather than a fixed set: `TAB`, or any number of
    /// lines written as `5-lines`.
    public let style: String?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        // Not `binding.appearance`: that reads `size` as a bare number, which
        // is right for every other tag and wrong for this one.
        let appearance = GMNTag.Appearance(color: binding.string(named: "color"),
                                           dx: binding.length(named: "dx"),
                                           dy: binding.length(named: "dy"))

        self.init(ident: ident,
                  style: binding.string(named: "style"),
                  size: binding.length(named: "size"),
                  lineThickness: binding.double(named: "lineThickness"),
                  distance: binding.length(named: "distance"),
                  appearance: appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNStaffFormat: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("staffFormat")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["distance"] = distance?.parameterValue
        values["lineThickness"] = lineThickness.map { .number($0) }
        values["size"] = size?.parameterValue
        values["style"] = style.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNStaffFormat: Equatable {
}

// MARK: - Sendable

extension GMNStaffFormat: Sendable {
}
