// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNValidator {

    // MARK: Public Nested Types

    /// An issue found when validating a ``GMNScore``.
    ///
    /// ## What is judged here
    ///
    /// Everything a repair cannot reach. ``GMNParser`` rejects what could never
    /// be repaired and ``GMNNormalizer`` repairs what it can, but neither
    /// judges: normalization is total, so a defect it could not repair arrives
    /// here intact.
    ///
    /// Two of the five are about a tag’s *body*, and whether a tag scopes
    /// something is a fact about the score around it, which no repair could
    /// guess at. The other three are about its *parameters*, and each is a
    /// value that was written and then thrown away unread.
    ///
    /// ## Why the parameter issues are judged after normalization
    ///
    /// A defect is only definite once every repair has been tried. `\volta`
    /// requires `mark`, and `\volta<m="1.">` supplies it under a name since
    /// renamed — so the tag is missing a required parameter as written and
    /// complete after ``GMNNormalizer/normalize(_:)`` renames it.
    /// The same holds for a `$variable` that expands into a closed vocabulary,
    /// and for a span end whose written parameters are dropped before they can
    /// overrun its template. This is why ``GMNValidator/validate(_:)`` throws
    /// ``Error/notNormalized`` rather than judging an unnormalized score.
    ///
    /// ## Every issue is fatal
    ///
    /// There is no grading, and no issue is advisory. Any of the five leaves
    /// ``GMNValidator/validate(_:)`` returning the score unvalidated, because
    /// a set this small holds nothing worth tolerating: a `\slur` scoping
    /// nothing, a `\title` scoping something, and a `\clef` with no type are
    /// all defects the writer meant otherwise.
    ///
    /// A Guido renderer warns on every one of the five and draws the score
    /// anyway. That is a divergence, and a deliberate one — a renderer answers
    /// “can something be drawn?”, and this is a library answering “is this
    /// score well formed?”. In each case a value that was written is thrown
    /// away without being read, and the rendered score says nothing about the
    /// loss. What each field *means* is Guido’s to say; what to do about a
    /// violation is not.
    public enum Issue {
        // `checkRequired` (`TagParameterMap.cpp:96–107`).

        /// A required parameter was not written, and no repair supplied it.
        ///
        /// The associated values are the tag’s canonical name and the missing
        /// parameter’s name; where more than one is missing, the
        /// alphabetically first is reported.
        ///
        /// `\clef` with no `type` is the plain case. The trap is
        /// `\tempo<bpm="1/4=120","Allegro">`, where the positional
        /// `"Allegro"` binds to slot 1 — `bpm` — overwriting the bpm that
        /// was written and leaving required `tempo` with nothing.
        case missingRequiredParameter(GMNTag.Name, GMNTag.Parameter.Name)

        /// A tag that must have a body — ``GMNTag/RangeSetting/only`` — was
        /// written without one.
        ///
        /// `\slur`, `\beam`, `\tuplet`, `\grace`, `\cluster`, `\volta`,
        /// `\lyrics`, and `\trill` are among the tags that must scope
        /// something. Only the ``GMNTag/Span/whole`` form is checked: an open
        /// span writes its halves as `\slurBegin … \slurEnd`, and neither
        /// half carries a body by construction.
        case missingTagBody(GMNTag.Name)

        // guidolib warns and `break`s (`ARMusicalTag.cpp:101–104`).

        /// An unnamed parameter was written at a position past the end of the
        /// tag’s template, so there is no name to bind it to.
        ///
        /// Everything bound before this parameter is kept; this one and
        /// everything after it is discarded. In
        /// `\meter<"4/4",1,2,3,4,5,6,7,8>` that is eight of the nine
        /// parameters written. The associated values are the tag’s canonical
        /// name and the written position binding stopped at.
        case unboundPositionalParameter(GMNTag.Name, index: Int)

        /// A tag that must not have a body — ``GMNTag/RangeSetting/no`` — was
        /// written with one.
        ///
        /// `\composer`, `\title`, `\footer`, `\mark`, and `\endBar` are among
        /// the tags that scope nothing.
        case unexpectedTagBody(GMNTag.Name)

        /// Every parameter bound and none was ill-typed, and the tag still
        /// could not read one of the values.
        ///
        /// Three shapes reach this: a `position` outside `above`/`below`
        /// (``GMNTag/Placement``), a `curve` that would only be recognized by
        /// re-spelling it (``GMNTag/Curve``), and a `bpm` that
        /// ``GMNTempo/Metronome`` rejects. A renderer substitutes its own
        /// default for each, silently discarding what was written.
        ///
        /// The associated value is the tag’s name, not the parameter’s.
        /// Naming the parameter would mean a table of which value each tag
        /// reads against a closed vocabulary, maintained separately from the
        /// builders that actually do the reading — the kind of parallel table
        /// the typed tag model exists to remove.
        case unreadableParameterValue(GMNTag.Name)
    }
}

// MARK: -

extension GMNValidator.Issue {

    // MARK: Public Instance Properties

    /// A human-readable description of this issue.
    public var message: String {
        switch self {
        case let .missingRequiredParameter(name, parameter):
            "Missing required parameter ‘\(parameter.stringValue)’ on tag ‘\\\(name.stringValue)’"

        case let .missingTagBody(name):
            "Tag ‘\\\(name.stringValue)’ requires a body"

        case let .unboundPositionalParameter(name, index):
            "Parameter \(index + 1) of tag ‘\\\(name.stringValue)’ binds to no template slot"

        case let .unexpectedTagBody(name):
            "Tag ‘\\\(name.stringValue)’ takes no body"

        case let .unreadableParameterValue(name):
            "Unreadable parameter value on tag ‘\\\(name.stringValue)’"
        }
    }
}

// MARK: - Equatable

extension GMNValidator.Issue: Equatable {
}

// MARK: - Sendable

extension GMNValidator.Issue: Sendable {
}
