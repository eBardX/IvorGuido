// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNNormalizer {

    // MARK: Public Nested Types

    /// A change applied when normalizing a ``GMNScore`` to canonical form.
    ///
    /// ## Two of these fire far less often than they used to
    ///
    /// Before the typed tag model, normalization was where a tag’s name and
    /// its parameter names were put right, so
    /// ``canonicalizedTagName(_:_:)`` and ``renamedParameter(_:_:_:)``
    /// were reported for *every* tag written with an alias or a deprecated
    /// parameter name. They are now reported only for a tag that failed to
    /// promote to a typed payload.
    ///
    /// The canonicalization still happens either way — it just usually
    /// happens in the parser, where promotion selects the payload and the
    /// payload *is* the canonical identity. A `\bm` becomes a ``GMNBeam``,
    /// and ``GMNBeam`` reports the name `beam`; there was never an alias
    /// stored to rewrite. Only a tag promotion rejected — an unknown
    /// parameter, a value no field can carry — keeps its written name far
    /// enough downstream for the normalizer’s fallback table to be the thing
    /// that fixes it.
    ///
    /// So a caller that counted these changes to detect “this score used
    /// short-form tag names” will now see nothing for a score it previously
    /// reported on. **The formatted output is unchanged**: a `\bm` still
    /// comes out `\beam`. What changed is which stage says so, and therefore
    /// whether it is announced at all.
    public enum Change {
        // The `ARFactory` alias table (`ARFactory.cpp` `createTag`) is the
        // source catalog.

        /// A tag-name alias was collapsed to its canonical long form. The
        /// first associated value is the alias as written; the second is the
        /// canonical replacement.
        ///
        /// Reported only for a tag that did not promote to a typed payload —
        /// see the note on ``GMNNormalizer/Change`` itself.
        case canonicalizedTagName(GMNTag.Name, GMNTag.Name)

        // `TagParameterMap::get<T>` is a `dynamic_cast`
        // (`TagParameterMap.h:54–57`), so a value of the wrong type reads back
        // as null.
        //
        // Unlike its two neighbours this one has no parser-stage equivalent,
        // and it is the reason the other two got quieter: a parameter can only
        // be recognized as inert by binding it against a template, which is
        // work the normalizer does and the parser does not.

        /// A parameter Guido itself would read as inert was dropped. The
        /// associated values are the tag name the parameter appeared on and
        /// the parameter name it bound to.
        ///
        /// A value of the wrong type is never read, so the tag behaves as
        /// though it were never written — `\staccato<0.5>` means the same as
        /// a bare `\staccato`. Dropping it changes nothing about the score
        /// and is what lets the tag promote to a typed payload.
        ///
        /// Every parameter that bound to the reported name is dropped, not
        /// just the last one: keeping an earlier write would resurrect a
        /// value the later one had already overwritten.
        case droppedInertParameter(GMNTag.Name, String)

        // A unit is a field on the value rather than a separate class, so the
        // `dynamic_cast` still succeeds and `checkUnit` merely warns; the class
        // then reads the magnitude and ignores the unit entirely.

        /// A unit written on a parameter that measures no length was dropped,
        /// keeping the magnitude. The associated values are the tag name the
        /// parameter appeared on and the parameter name it bound to.
        ///
        /// Such a parameter is a bare number — `size` is a ratio, not a
        /// length — so the unit was never going to survive into a typed
        /// payload. Dropping it here makes that loss explicit and recorded
        /// rather than silent and untyped.
        ///
        /// Contrast ``GMNLength``, which carries its unit and all. Which of
        /// the two a parameter is depends on the parameter, not on how the
        /// value was written.
        case droppedParameterUnit(GMNTag.Name, String)

        // guidolib never receives one: the grammar reduces it to a null
        // parameter (`guido.y:188`, `tagarg: id { $$ = 0; delete $1; }`) and
        // `GuidoParser::tagParameter` drops nulls before `ARFactory` is called
        // (`GuidoParser.cpp:291`).

        /// A raw (unquoted) identifier parameter was dropped. The associated
        /// values are the tag name it appeared on and the identifier as
        /// written.
        ///
        /// Nothing ever reads one. It binds to nothing, so there is no
        /// parameter to measure it against and no name to report it under —
        /// which is why the identifier itself is reported instead.
        ///
        /// ``GMNParser`` keeps it, so a parsed score still round-trips byte
        /// for byte; the normalizer is where it goes, because it is the one
        /// token that would otherwise keep an entire tag untyped over a value
        /// nothing reads.
        case droppedRawIdentifierParameter(GMNTag.Name, String)

        // `ARFactory` builds an `ARDummyRangeEnd` for every closing half, and
        // it supports no parameters at all. This is the same
        // argument that licenses `droppedInertParameter(_:_:)`, in its
        // strongest form: that one has to bind a parameter and reason about a
        // `dynamic_cast` to prove the value is unread, while here the tag's
        // whole schema is that it has none.

        /// Every parameter written on an `…End` tag was dropped. The
        /// associated value is the tag name they appeared on.
        ///
        /// A closing half accepts no parameters at all, so
        /// `\slurEnd<dx=2hs>` writes an offset nothing will ever read.
        ///
        /// Reported once for the tag rather than once per parameter. Every
        /// one of them goes for the same single reason, and unlike an inert
        /// parameter there is no surviving list whose positional spelling
        /// could shift as a result.
        ///
        /// **A parameter still holding an unresolved `$variable` reference
        /// survives**, for the reason given on
        /// ``droppedUnsupportedParameter(_:_:)``: an undeclared name is a
        /// parse failure whatever tag it was written on.
        case droppedSpanEndParameters(GMNTag.Name)

        // `ARFactory::addTagParameter` records a parameter only when the tag
        // just built is an `ARMTParameter` (`ARFactory.cpp:2012–2016`). This is
        // `droppedSpanEndParameters(_:)`'s argument reached by a different
        // route, and it is stronger than `droppedInertParameter(_:_:)`'s:
        // there, a value has to be bound and reasoned about through a
        // `dynamic_cast` before it can be shown unread; here nothing is bound
        // at all.

        /// Every parameter written on a tag whose class keeps none was
        /// dropped. The associated value is the tag name they appeared on.
        ///
        /// Six names keep no parameters at all: `\beamsAuto`, `\beamsFull`,
        /// `\beamsOff`, `\newPage`, `\merge`, and `\port`. A parameter
        /// written to one of them is discarded before binding ever happens.
        ///
        /// Reported once for the tag, and — as with a span end — a parameter
        /// still holding an unresolved `$variable` reference survives.
        case droppedUnacceptedParameters(GMNTag.Name)

        // This is `checkExist` (`TagParameterMap.cpp:110–119`). guidolib keeps
        // the parameter in its map, warns, and never reads it again, and its
        // own `getParamsStr()` can still echo it — so a score normalized here
        // and one round-tripped through guidolib differ by exactly these, as
        // they already do over an inert parameter.

        /// A parameter the tag does not support was dropped. The associated
        /// values are the tag name it appeared on and the name it bound to.
        ///
        /// The name is not one the tag accepts, so nothing can ever read it.
        ///
        /// **A parameter holding an *unresolved* `$variable` is never
        /// dropped**, even under an unsupported name: a reference is
        /// substituted before the name is looked at, so it is live regardless
        /// of the name it was written under. Such a tag stays
        /// ``GMNTag/reserved(_:)``, and on a parsed score the reference has
        /// already been refused by
        /// ``GMNParser/Error/unresolvableVariableReference(_:)`` — the
        /// exemption is what a *hand-built* score relies on, since no
        /// rejection guards that path. A reference that *does* resolve is
        /// substituted first — see ``expandedVariableReference(_:_:)`` — and
        /// whatever it expands to is then dropped like any other unsupported
        /// value, so `\beam<bogus=$x>` records both changes.
        case droppedUnsupportedParameter(GMNTag.Name, String)

        // This is `GuidoParser::varParam` (`GuidoParser.cpp:319–321`), which
        // switches on the variable's declared type — `kString`, `kInt`, or
        // `kFloat`. A last declaration of the same name wins, matching
        // guidolib's `fEnv`. A reference in symbol position is a textual macro
        // re-lexed in place (`variableSymbols`).

        /// A `$variable` reference in tag-parameter position was substituted
        /// by the value its declaration carries. The associated values are
        /// the tag name it appeared on and the variable name.
        ///
        /// The substituted value **never carries a unit**, whatever the
        /// declaration says. Where a name is declared more than once, the
        /// last declaration wins.
        ///
        /// The substitution is unambiguous because a declaration is a
        /// prologue only, so the environment is complete before any
        /// reference. It is done here rather than in ``GMNParser`` so that a
        /// parsed score still round-trips byte for byte — expanding at the
        /// parser would turn `$x = 1; [\beam<dy=$x>(c d)]` into
        /// `[\beam<dy=1>(c d)]` with the declaration left dangling.
        ///
        /// A reference in *symbol* position is untouched by this; splicing
        /// that one in is not implemented anywhere in IvorGuido.
        ///
        /// A reference to a name no declaration carries is left exactly as
        /// written rather than guessed at. ``GMNParser`` has already refused
        /// one on a parsed score — see
        /// ``GMNParser/Error/unresolvableVariableReference(_:)`` — so this is
        /// what a hand-built score relies on.
        case expandedVariableReference(GMNTag.Name, GMNVariable.Name)

        /// A deprecated tag-parameter name was renamed to its current form
        /// (`\volta`’s `m` → `mark`, for instance). The associated values are
        /// the tag name the parameter appeared on, the deprecated parameter
        /// name, and its replacement.
        ///
        /// Reported only for a tag that did not promote to a typed payload —
        /// see the note on ``GMNNormalizer/Change`` itself. ``GMNVolta``
        /// binds `mark`, so a `\volta<m="1.">` that promoted emits `mark`
        /// from the payload without this change ever being recorded.
        case renamedParameter(GMNTag.Name, String, String)
    }
}

// MARK: -

extension GMNNormalizer.Change {

    // MARK: Public Instance Properties

    /// A human-readable description of this change.
    public var message: String {
        switch self {
        case let .canonicalizedTagName(alias, canonical):
            "Tag name ‘\(alias.stringValue)’ canonicalized to ‘\(canonical.stringValue)’"

        case let .droppedInertParameter(tagName, parameterName):
            "Inert parameter ‘\(parameterName)’ dropped from tag ‘\(tagName.stringValue)’"

        case let .droppedParameterUnit(tagName, parameterName):
            "Unit dropped from parameter ‘\(parameterName)’ on tag ‘\(tagName.stringValue)’"

        case let .droppedRawIdentifierParameter(tagName, identifier):
            "Raw identifier parameter ‘\(identifier)’ dropped from tag ‘\(tagName.stringValue)’"

        case let .droppedSpanEndParameters(tagName):
            "All parameters dropped from span-end tag ‘\(tagName.stringValue)’"

        case let .droppedUnacceptedParameters(tagName):
            "All parameters dropped from tag ‘\(tagName.stringValue)’, which keeps none"

        case let .droppedUnsupportedParameter(tagName, parameterName):
            "Unsupported parameter ‘\(parameterName)’ dropped from tag ‘\(tagName.stringValue)’"

        case let .expandedVariableReference(tagName, variableName):
            "Variable reference ‘$\(variableName.stringValue)’ expanded on tag ‘\(tagName.stringValue)’"

        case let .renamedParameter(tagName, oldName, newName):
            "Parameter ‘\(oldName)’ on tag ‘\(tagName.stringValue)’ renamed to ‘\(newName)’"
        }
    }
}

// MARK: - Equatable

extension GMNNormalizer.Change: Equatable {
}

// MARK: - Sendable

extension GMNNormalizer.Change: Sendable {
}
