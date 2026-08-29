// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: `kCommonParams`
    // (`"S,color,black,o;U,dx,0,o;U,dy,0,o;F,size,1.0,o"`,
    // `TagParameterStrings.cpp:20`), merged into every tag’s parameter
    // template by `ARMusicalTag::init` (`ARMusicalTag.cpp:50–54`).
    //
    // `checkTagParameters` binds unnamed parameters against the tag's *own*
    // `getParamsStr()` only, and `kCommonParams` is merged in separately. A
    // class that never overrides `getParamsStr()` inherits `ARMusicalTag`'s
    // base implementation, which returns `kCommonParams` itself
    // (`ARMusicalTag.h:61`). Both exceptions are recorded by the tag
    // template registry, which the formatter must consult rather than assume.
    //
    // Each field fails the omissibility criterion for its own reason; see the
    // individual field comments.

    /// The four appearance parameters every Guido Music Notation tag accepts.
    ///
    /// These four usually have **no positional slot**: for most tags `color`,
    /// `dx`, `dy`, and `size` are written named and sort after the tag’s own
    /// parameters. There are two exceptions:
    ///
    /// - For `\newPage`, `\systemFormat`, `\pedalOn`, the `\heads…` family,
    ///   and every `…End`, these four *are* the positional parameters.
    /// - A tag may declare one of the four among its own. `\beam`’s first
    ///   positional parameter is `dy`, so `\beam<2hs>` binds it; `\color`
    ///   takes nothing but `color`; `\pageFormat` ends with it; `\text` and
    ///   its relatives take `dy`.
    ///
    /// ## All four are non-omissible
    ///
    /// No field of this type is ever dropped from formatted output, even when
    /// its value equals the default. `\bar` and `\bar<dx=0>` are observably
    /// different scores.
    public struct Appearance {

        // MARK: Public Initializers

        /// Creates a new appearance with the provided parameters.
        ///
        /// - Parameter color:  The color, or `nil` if none was written.
        ///                     Defaults to `nil`.
        /// - Parameter dx:     The horizontal offset, or `nil` if none was
        ///                     written. Defaults to `nil`.
        /// - Parameter dy:     The vertical offset, or `nil` if none was
        ///                     written. Defaults to `nil`.
        /// - Parameter size:   The size scaling factor, or `nil` if none was
        ///                     written. Defaults to `nil`.
        public init(color: String? = nil,
                    dx: GMNLength? = nil,
                    dy: GMNLength? = nil,
                    size: Double? = nil) {
            self.color = color
            self.dx = dx
            self.dy = dy
            self.size = size
        }

        // MARK: Public Instance Properties

        // **Non-omissible.** Absence is observable: `GRSingleNote.cpp:1066`
        // guards on `if (frmt->getColor())`, so an absent `color` inherits the
        // enclosing colour while an explicit `color="black"` forces black. The
        // declared default is `black`, but the two are not the same score.

        /// The color written for this tag (`color`), or `nil` if none was
        /// written.
        ///
        /// The grammar is open: a color name, or an `r,g,b,a` tuple.
        public let color: String?

        // **Non-omissible.** Read with `usedefault=true`, so absence and an
        // explicit `0` yield the same magnitude — but consumers inspect
        // authorship directly with the `TagIsSet()` family, at
        // `GRSingleNote.cpp:1197,1202`, `GRAccolade.cpp:54`, `GRBar.cpp:129`,
        // `GREvent.cpp:185`, and `GRStaff.cpp:266` among others.

        /// The horizontal offset written for this tag (`dx`), or `nil` if
        /// none was written.
        public let dx: GMNLength?

        // **Non-omissible**, for the same reason as `dx`:
        // `GRSingleNote.cpp:1210,1218`, `GRAccolade.cpp:57`, `GRBar.cpp:130`,
        // `GRSystem.cpp:1097`, `GRStaff.cpp:1873`.

        /// The vertical offset written for this tag (`dy`), or `nil` if none
        /// was written.
        public let dy: GMNLength?

        // **Non-omissible**, and the most awkward of the four: consumers
        // disagree about what absence means. `GRClef.cpp:311` reads `p ?
        // p->getValue() : 1` (absent takes the declared default), while
        // `GRSingleNote.cpp:1097` reads `if (tpf) mSize = tpf->getValue();`
        // (absent inherits), with the default-applying form commented out
        // directly above it. The AST cannot know which consumer will read the
        // tag, so it preserves what was written.

        /// The size scaling factor written for this tag (`size`), or `nil` if
        /// none was written.
        ///
        /// A bare `F` parameter, not a `U` — `size` is a ratio and takes no
        /// unit — hence `Double` rather than ``GMNLength``.
        public let size: Double?
    }
}

// MARK: -

extension GMNTag.Appearance {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether no appearance parameter at all was
    /// written for this tag.
    public var isEmpty: Bool {
        color == nil && dx == nil && dy == nil && size == nil
    }

    // MARK: Internal Instance Properties

    // These four parameters keyed by their `kCommonParams` names, omitting
    // any that was not written — the shape `formatTypedTag(_:)` emits from.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["color"] = color.map { .string($0) }
        values["dx"] = dx?.parameterValue
        values["dy"] = dy?.parameterValue
        values["size"] = size.map { .number($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNTag.Appearance: Equatable {
}

// MARK: - Sendable

extension GMNTag.Appearance: Sendable {
}
