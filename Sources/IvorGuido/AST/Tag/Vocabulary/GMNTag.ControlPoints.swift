// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: the `dx1`/`dy1`/`dx2`/`dy2` prefix of `kARBowingParams`
    // (`TagParameterStrings.cpp:41`) and of `kARGlissandoParams` (`:54`).
    // Exactly three tag names carry the full quartet — `\slur` and `\tie`,
    // which share `kARBowingParams` verbatim as `ARBowing` subclasses, and
    // `\glissando`.
    //
    // ## All four are non-omissible
    //
    // `ARBowing::setTagParameters` reads each without a default —
    // `fDx1 = dx1 ? dx1->getValue() : 0` (`ARBowing.cpp:66–69`) — and then
    // records authorship outright in
    // `fParSet = (dx1 || dx2 || dy1 || dy2 || dx || dy)` (`:78`). The same four
    // names are on the `TagIsSet()` blocklist for `kARBeamParams`
    // (`GRBeam.cpp:492,506,517,528`; `ARBeam.cpp:74–76`).

    /// The two-endpoint control-point quartet shared by the curved Guido
    /// Music Notation tags.
    ///
    /// ## The grouping follows what each tag accepts, not a tidy abstraction
    ///
    /// Tags carrying only a subset keep their own individual fields rather
    /// than borrowing this type with holes in it: `\crescendo` and
    /// `\diminuendo` have `dx1`/`dx2` only, `\tuplet` has `dy1`/`dy2` only,
    /// and `\beam` has all eight and gets its own ``GMNBeam/ControlPoints``.
    ///
    /// ## All four are non-omissible
    ///
    /// Absence is observable independently of value, so an explicit `dx1=0`
    /// is a different score from no `dx1` at all and neither is ever dropped.
    ///
    /// Note also that the ``GMNTag/Appearance`` offsets are folded into these
    /// — `dx` is added to both `dx1` and `dx2` — so the two sets of offsets
    /// are not interchangeable and neither can be normalized into the other.
    public struct ControlPoints {

        // MARK: Public Initializers

        /// Creates a new control-point quartet with the provided offsets.
        ///
        /// - Parameter dx1:    The horizontal offset of the first endpoint,
        ///                     or `nil` if none was written. Defaults to
        ///                     `nil`.
        /// - Parameter dy1:    The vertical offset of the first endpoint, or
        ///                     `nil` if none was written. Defaults to `nil`.
        /// - Parameter dx2:    The horizontal offset of the second endpoint,
        ///                     or `nil` if none was written. Defaults to
        ///                     `nil`.
        /// - Parameter dy2:    The vertical offset of the second endpoint, or
        ///                     `nil` if none was written. Defaults to `nil`.
        public init(dx1: GMNLength? = nil,
                    dy1: GMNLength? = nil,
                    dx2: GMNLength? = nil,
                    dy2: GMNLength? = nil) {
            self.dx1 = dx1
            self.dx2 = dx2
            self.dy1 = dy1
            self.dy2 = dy2
        }

        // MARK: Public Instance Properties

        /// The horizontal offset of the first endpoint (`dx1`), or `nil` if
        /// none was written.
        public let dx1: GMNLength?

        /// The horizontal offset of the second endpoint (`dx2`), or `nil` if
        /// none was written.
        public let dx2: GMNLength?

        /// The vertical offset of the first endpoint (`dy1`), or `nil` if
        /// none was written.
        public let dy1: GMNLength?

        /// The vertical offset of the second endpoint (`dy2`), or `nil` if
        /// none was written.
        public let dy2: GMNLength?
    }
}

// MARK: -

extension GMNTag.ControlPoints {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether no control point at all was written
    /// for this tag.
    public var isEmpty: Bool {
        dx1 == nil && dx2 == nil && dy1 == nil && dy2 == nil
    }
}

// MARK: -

extension GMNTag.ControlPoints {

    // MARK: Internal Instance Properties

    // The four offsets, keyed by the template name each binds to.
    //
    // Folded into the owning payload's own `parameterValues`; the formatter
    // takes the order from the registry, since where the quartet sits differs
    // by tag — `kARBowingParams` opens with it while `kARGlissandoParams`
    // interleaves `fill` and `thickness` after it.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["dx1"] = dx1?.parameterValue
        values["dx2"] = dx2?.parameterValue
        values["dy1"] = dy1?.parameterValue
        values["dy2"] = dy2?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNTag.ControlPoints: Equatable {
}

// MARK: - Sendable

extension GMNTag.ControlPoints: Sendable {
}
