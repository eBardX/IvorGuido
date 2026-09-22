// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNBeam {

    // MARK: Public Nested Types

    // guidolib: the `dx1`…`dy4` tail of `kARBeamParams`
    // (`TagParameterStrings.cpp:39`). A beam is a quadrilateral rather than a
    // curve, so it takes four corners where `GMNTag.ControlPoints` takes two
    // endpoints — which is why this is a type of its own rather than that one
    // with fields left over.
    //
    // ## Six of the eight are non-omissible outright
    //
    // `dx1`, `dy1`, `dx2`, `dy2`, `dy3`, and `dy4`:
    // `GRBeam.cpp:492,506,517,528,574,578,595,1348` and
    // `ARBeam.cpp:74–76` inspect authorship with `TagIsSet()`. The remaining
    // two, `dx3` and `dx4`, are read with `usedefault=true` and are treated
    // the same way — nothing is ever dropped, leaving the whole group
    // non-omissible rather than split it.
    //
    // `ARBeam::setTagParameters` (`ARBeam.cpp:44–70`) also branches on *how
    // many* parameters were written, reading `dy` alone or `dy1`/`dy2` alone as
    // an abbreviated two-point form. That is a reading of the same parameters,
    // not a different set of them, so it does not change what this type stores.

    /// The four-corner control points of a beam.
    ///
    /// Writing `dy` alone, or `dy1` and `dy2` alone, selects an abbreviated
    /// two-point form of the same parameters.
    public struct ControlPoints {

        // MARK: Public Initializers

        /// Creates a new set of beam control points with the provided
        /// offsets.
        ///
        /// - Parameter dx1: The horizontal offset of the first corner, or
        ///                  `nil` if none was written. Defaults to `nil`.
        /// - Parameter dy1: The vertical offset of the first corner, or `nil`
        ///                  if none was written. Defaults to `nil`.
        /// - Parameter dx2: The horizontal offset of the second corner, or
        ///                  `nil` if none was written. Defaults to `nil`.
        /// - Parameter dy2: The vertical offset of the second corner, or `nil`
        ///                  if none was written. Defaults to `nil`.
        /// - Parameter dx3: The horizontal offset of the third corner, or
        ///                  `nil` if none was written. Defaults to `nil`.
        /// - Parameter dy3: The vertical offset of the third corner, or `nil`
        ///                  if none was written. Defaults to `nil`.
        /// - Parameter dx4: The horizontal offset of the fourth corner, or
        ///                  `nil` if none was written. Defaults to `nil`.
        /// - Parameter dy4: The vertical offset of the fourth corner, or `nil`
        ///                  if none was written. Defaults to `nil`.
        public init(dx1: GMNLength? = nil,
                    dy1: GMNLength? = nil,
                    dx2: GMNLength? = nil,
                    dy2: GMNLength? = nil,
                    dx3: GMNLength? = nil,
                    dy3: GMNLength? = nil,
                    dx4: GMNLength? = nil,
                    dy4: GMNLength? = nil) {
            self.dx1 = dx1
            self.dx2 = dx2
            self.dx3 = dx3
            self.dx4 = dx4
            self.dy1 = dy1
            self.dy2 = dy2
            self.dy3 = dy3
            self.dy4 = dy4
        }

        // MARK: Public Instance Properties

        /// The horizontal offset of the first corner (`dx1`), or `nil` if none
        /// was written.
        public let dx1: GMNLength?

        /// The horizontal offset of the second corner (`dx2`), or `nil` if
        /// none was written.
        public let dx2: GMNLength?

        /// The horizontal offset of the third corner (`dx3`), or `nil` if none
        /// was written.
        public let dx3: GMNLength?

        /// The horizontal offset of the fourth corner (`dx4`), or `nil` if
        /// none was written.
        public let dx4: GMNLength?

        /// The vertical offset of the first corner (`dy1`), or `nil` if none
        /// was written.
        public let dy1: GMNLength?

        /// The vertical offset of the second corner (`dy2`), or `nil` if none
        /// was written.
        public let dy2: GMNLength?

        /// The vertical offset of the third corner (`dy3`), or `nil` if none
        /// was written.
        public let dy3: GMNLength?

        /// The vertical offset of the fourth corner (`dy4`), or `nil` if none
        /// was written.
        public let dy4: GMNLength?

        // MARK: Internal Initializers

        internal init(binding: GMNTagBinder.Binding) {
            self.init(dx1: binding.length(named: "dx1"),
                      dy1: binding.length(named: "dy1"),
                      dx2: binding.length(named: "dx2"),
                      dy2: binding.length(named: "dy2"),
                      dx3: binding.length(named: "dx3"),
                      dy3: binding.length(named: "dy3"),
                      dx4: binding.length(named: "dx4"),
                      dy4: binding.length(named: "dy4"))
        }
    }
}

// MARK: -

extension GMNBeam.ControlPoints {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether no control point at all was written
    /// for this tag.
    public var isEmpty: Bool {
        dx1 == nil && dx2 == nil && dx3 == nil && dx4 == nil
            && dy1 == nil && dy2 == nil && dy3 == nil && dy4 == nil
    }
}

// MARK: -

extension GMNBeam.ControlPoints {

    // MARK: Internal Instance Properties

    // The eight offsets, keyed by the template name each binds to.
    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["dx1"] = dx1?.parameterValue
        values["dx2"] = dx2?.parameterValue
        values["dx3"] = dx3?.parameterValue
        values["dx4"] = dx4?.parameterValue
        values["dy1"] = dy1?.parameterValue
        values["dy2"] = dy2?.parameterValue
        values["dy3"] = dy3?.parameterValue
        values["dy4"] = dy4?.parameterValue

        return values
    }
}

// MARK: - Equatable

extension GMNBeam.ControlPoints: Equatable {
}

// MARK: - Sendable

extension GMNBeam.ControlPoints: Sendable {
}
