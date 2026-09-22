// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTag {

    // MARK: Public Nested Types

    // guidolib: `ARMusicalTag::RANGE { NO, ONLY, RANGEDC }`
    // (`ARMusicalTag.h:44`), a per-class property each tag’s constructor
    // declares by assigning `rangesetting`. The base initializer defaults it
    // to `NO` (`ARMusicalTag.cpp:35`), so a class that says nothing takes no
    // body.

    /// Whether a Guido Music Notation tag may carry a body.
    ///
    /// This is a property of the tag *name*, supplied by the template
    /// registry, and is what lets the validator reject `\tempo(c d)` and
    /// `\accent` standing alone. It is not itself written in the source.
    public enum RangeSetting {
        /// The tag may appear either with or without a body.
        case either

        /// The tag must not have a body. This is the default for any tag
        /// that does not say otherwise.
        case no

        /// The tag must have a body. `\accent` is one.
        case only
    }
}

// MARK: - Equatable

extension GMNTag.RangeSetting: Equatable {
}

// MARK: - Sendable

extension GMNTag.RangeSetting: Sendable {
}
