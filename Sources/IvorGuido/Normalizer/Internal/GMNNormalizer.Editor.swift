// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension GMNNormalizer {

    // MARK: Internal Nested Types

    internal struct Editor {

        // MARK: Internal Initializers

        internal init(score: GMNScore) {
            // Last declaration wins, matching guidolib's `fEnv`, which is a
            // map (`GuidoParser.cpp`). The AST keeps every declaration —
            // `$x = 1; $x = 2;` is two of them — so the agreement has to be
            // built here rather than assumed.
            //
            // The environment is complete before any reference, because a
            // declaration is a prologue only (`gmn: score | variables score`),
            // which is what makes substituting one unambiguous.
            self.changes = []
            self.score = score
            self.variables = score.variables.reduce(into: [:]) { $0[$1.name] = $1.value }
        }

        // MARK: Private Instance Properties

        private let score: GMNScore

        private let variables: [GMNVariable.Name: GMNVariable.Value]

        private var changes: [Change] = []
    }
}

// MARK: -

extension GMNNormalizer.Editor {

    // MARK: Internal Type Properties

    // `\volta`'s `m` parameter was renamed to `mark` in guidolib 1.5.5;
    // current `ARVolta::getMark()` looks up only `mark`. Applies to `volta`
    // and `voltaBegin` (both back onto `ARVolta` with the same parameter
    // map, `ARFactory.cpp` `createTag`); `voltaEnd` constructs a generic
    // `ARDummyRangeEnd` that takes no parameters at all.
    //
    // **Applies to the untyped lanes only, like `tagNameAliases` below — but
    // this one is a repair, not a fallback.** The distinction matters. An
    // alias is a last resort, reached only when a tag failed to promote for
    // some *other* reason; this rename is itself what lets the tag promote,
    // since `GMNVolta` binds `mark` and knows nothing about `m`. So it runs
    // on the untyped lanes the way `_dropInertParameters` does — repair
    // first, then re-promote — rather than the way `_canonicalize` does.
    //
    // Reaching this table from source at all also required fixing the
    // tokenizer first: `m` is a length unit, every unit spelling is also a
    // legal parameter name, and `m=` used to lex as a unit and fail in the
    // grammar. See `regexUnit` for how the two are now separated.
    internal static let renamableParameter: [String: (old: String, new: String)] = ["volta": ("m", "mark"),
                                                                                    "voltaBegin": ("m", "mark")]

    // Collapses each alias to its canonical long form. Stored names are
    // already backslash-free; source catalog is `ARFactory`'s `createTag`
    // (`ARFactory.cpp` ~606–1630), cross-checked against each canonical
    // form's `AR*` class name.
    //
    // Two categories of version-upgrade rename are NOT implemented here —
    // both would require guessing at behavior no longer present in
    // guidolib's own source, which contradicts "guidolib is the ultimate
    // arbiter":
    //   - `\special`'s "scale"→"size" rename (guidolib 1.5.6): current
    //     `ARSpecial` has no "size" parameter at all anymore (only `char`)
    //     — the target of the rename is itself obsolete, so rewriting to it
    //     would produce a parameter current guidolib also ignores.
    //   - The 1.6.5 `\trill`/`\mordent`/`\turn` ornament argument-shape
    //     redesign (old chord-based form → new tag-parameter form): the old
    //     form's chord-handling code has been fully removed from `ARTrill`;
    //     nothing in the current source documents its exact semantics
    //     (which chord segment is the auxiliary note, how multiple
    //     segments map to parameters, etc.), so there is no authoritative
    //     basis to convert against. A residual risk, left unimplemented
    //     rather than implemented on a guess.
    // Eight entries were removed: `accelBegin`/`accelEnd`,
    // `crescBegin`/`crescEnd`, `ritBegin`/`ritEnd`, and
    // `staccBegin`/`staccEnd` used to be rewritten to `accelerandoBegin`,
    // `crescendoEnd`, and so on — names `Tags.cpp` does not declare and
    // `ARFactory::createTag` does not dispatch. Renaming to them turned a
    // legal tag into an unknown one, so a `\staccBegin` that failed to
    // promote came back out of the formatter as `\staccatoBegin`. The short
    // spellings *are* the canonical ones for these open halves, which is what
    // `GMNArticulation.name` and its neighbours report. `decrescBegin`,
    // `dimEnd`, `tremBegin`, and `tremEnd` keep their entries, because
    // `diminuendoBegin`, `diminuendoEnd`, `tremoloBegin`, and `tremoloEnd`
    // really are declared.
    //
    // **This table now serves the untyped lanes only, and is not deleted.**
    // A typed payload has no name to canonicalize — the case *is* the
    // canonical identity, and `GMNTagPayload.name` is what the formatter
    // emits — so for every tag that promoted, the table is dead. It stays
    // because a tag that *failed* to promote keeps the name it was written
    // with, and that name would reach the formatter as an alias, violating
    // the canonical-name rule. `\sl<curve="banana">` is the reachable
    // example: no repair touches a value outside a closed vocabulary —
    // re-spelling is exactly what the parser declines to do — so the tag
    // stays untyped, and only this table turns it back into
    // `\slur<curve="banana">`. Every one of the 31 entries is a name the
    // registry dispatches, so every one of them is reachable that way and
    // none can be pruned.
    //
    // `\bm<bogus=1>` used to be the example quoted here and no longer is:
    // an unsupported parameter is now dropped rather than reported, so that
    // tag re-promotes and takes its canonical name from its payload. The
    // table is unaffected — a repair that succeeds never needed it — but the
    // set of tags that still reach it is smaller.
    //
    // `GMNNormalizerAliasTableTests` pins both halves of that: each entry
    // agrees with the name its own typed payload reports, and the table does
    // not fire on a tag that promoted.
    internal static let tagNameAliases: [String: String] = ["acc": "accidental",
                                                            "accel": "accelerando",
                                                            "accol": "accolade",
                                                            "b": "beam",
                                                            "bm": "beam",
                                                            "colour": "color",
                                                            "cresc": "crescendo",
                                                            "decresc": "diminuendo",
                                                            "decrescBegin": "diminuendoBegin",
                                                            "decrescEnd": "diminuendoEnd",
                                                            "decrescendo": "diminuendo",
                                                            "dim": "diminuendo",
                                                            "dimBegin": "diminuendoBegin",
                                                            "dimEnd": "diminuendoEnd",
                                                            "fing": "fingering",
                                                            "i": "intensity",
                                                            "instr": "instrument",
                                                            "intens": "intensity",
                                                            "mord": "mordent",
                                                            "newLine": "newSystem",
                                                            "oct": "octava",
                                                            "pizz": "pizzicato",
                                                            "rit": "ritardando",
                                                            "s": "symbol",
                                                            "sl": "slur",
                                                            "stacc": "staccato",
                                                            "t": "text",
                                                            "ten": "tenuto",
                                                            "trem": "tremolo",
                                                            "tremBegin": "tremoloBegin",
                                                            "tremEnd": "tremoloEnd"]

    // MARK: Internal Instance Methods

    internal mutating func editScore() -> (GMNScore, [GMNNormalizer.Change]) {
        let variables = score.variables.map { _editVariable($0) }
        let voices = score.voices.map { _editVoice($0) }

        let normalized = GMNScore(variables: variables,
                                  voices: voices,
                                  isNormalized: true,
                                  isValidated: false)

        return (normalized, changes)
    }

    // MARK: Private Type Methods

    // The tag-parameter value a declared variable substitutes to.
    //
    // Transcribes `varParam`'s switch over the three declared types, unit and
    // all — which is to say without one, since `varParam` attaches none.
    private static func _substituted(_ value: GMNVariable.Value) -> GMNTag.Parameter.Value {
        switch value {
        case let .floating(magnitude):
            .floating(magnitude, nil)

        case let .integer(magnitude):
            .integer(magnitude, nil)

        case let .string(text):
            .string(text)
        }
    }

    // The same value with any unit removed, or `nil` if it carries none.
    private static func _withoutUnit(_ value: GMNTag.Parameter.Value) -> GMNTag.Parameter.Value? {
        switch value {
        case let .floating(magnitude, unit):
            unit.map { _ in .floating(magnitude, nil) }

        case let .integer(magnitude, unit):
            unit.map { _ in .integer(magnitude, nil) }

        default:
            nil
        }
    }

    // MARK: Private Instance Methods

    private mutating func _canonicalize(_ name: GMNTag.Name) -> GMNTag.Name {
        guard let canonical = Self.tagNameAliases[name.stringValue]
        else { return name }

        let canonicalName = GMNTag.Name(canonical)

        changes.append(.canonicalizedTagName(name, canonicalName))

        return canonicalName
    }

    // Drops the unit from every parameter no read of whose name is of the `U`
    // kind, keeping the magnitude.
    //
    // guidolib renders these. A unit is a field on the value rather than a
    // separate class, so the `dynamic_cast` still succeeds and `checkUnit`
    // merely warns; the class reads the magnitude and never looks at the
    // unit. An `F` or `I` field is a bare scalar — `size` is a ratio, not a
    // length; a staff `id` is a count — so the unit was never going to survive
    // into a typed payload, and this makes the loss explicit and recorded
    // rather than silent and untyped.
    //
    // This was originally written for `F` alone, which left `I` holding the
    // same hole: `\coda<id=2hs>` promoted and `binding.integer(named:)`
    // discarded the unit with nothing said. `GMNTagTemplate.readsAsLength(_:)`
    // is now what decides, so both kinds are covered and a name a class reads
    // twice is measured against both of its reads.
    //
    // A parameter the tag does not read at all is skipped: it is inert or
    // unsupported, `_dropUnreadParameters` removes the whole thing, and
    // stripping its unit first would record a repair of something about to be
    // deleted.
    //
    // This is deliberately *not* done by removing the case from
    // `Binding.unrepresentableParameterNames`. That property is what stops
    // `GMNTagPromoter` promoting the tag, and promotion runs in the parser
    // too, where a tag must round-trip byte-for-byte. Stripping the unit here
    // and leaving the blocker in place gives both: the parser carries
    // `size=1.5cm` through as written, and the normalizer turns it into
    // `size=1.5` and lets it promote.
    //
    // Rewrites values in place rather than removing parameters, so no
    // positional binding shifts.
    private mutating func _dropParameterUnits(_ parameters: [GMNTag.Parameter],
                                              on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        guard let template = GMNTagTemplate.Registry.template(for: tagName,
                                                              parameters: parameters)
        else { return parameters }

        let binding = GMNTagBinder.bind(parameters,
                                        to: template)

        guard binding.failure == nil
        else { return parameters }

        return parameters.enumerated().map { index, parameter in
            guard let boundName = binding.boundNames[index],
                  template.reads(parameter.value,
                                 as: boundName),
                  !template.readsAsLength(boundName),
                  let bare = Self._withoutUnit(parameter.value)
            else { return parameter }

            changes.append(.droppedParameterUnit(tagName, boundName))

            return GMNTag.Parameter(name: parameter.name,
                                    value: bare)
        }
    }

    // Drops every raw (unquoted) identifier parameter, logging each.
    //
    // guidolib never receives one: the grammar reduces it to a null parameter
    // (`guido.y:188`) and `GuidoParser::tagParameter` drops nulls before
    // `ARFactory` is called (`GuidoParser.cpp:291`). That happens in the
    // grammar, below dispatch, so it holds for an unknown tag name as much as
    // for a known one and no template is consulted here.
    //
    // `_dropSpanEndParameters` has dropped these all along, for the reason
    // that now applies everywhere: keeping one costs a whole tag its typing,
    // over a token provably nothing reads. This generalizes that rather than
    // duplicating it — the span-end case is now just the one where the
    // identifier was not the only thing wrong.
    //
    // Removing one cannot disturb the binding of anything after it:
    // `GMNTagBinder.bind(_:to:)` skips a raw identifier *without consuming an
    // index*, precisely so that positional binding agrees with guidolib's.
    private mutating func _dropRawIdentifierParameters(_ parameters: [GMNTag.Parameter],
                                                       on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        parameters.filter { parameter in
            guard case let .parameter(identifier) = parameter.value
            else { return true }

            changes.append(.droppedRawIdentifierParameter(tagName, identifier))

            return false
        }
    }

    // Drops every parameter written on an `…End` tag.
    //
    // `ARFactory` builds an `ARDummyRangeEnd` for every closing half and the
    // registry gives it no supported parameters at all, so nothing written
    // here can reach anything. That is the `_dropInertParameters` argument
    // without the binding step: there is no slot to measure a value against,
    // because the tag has no slots.
    //
    // **Raw identifiers go too, though `_dropInertParameters` keeps them.**
    // guidolib never receives one either way — the grammar reduces it to a
    // null parameter and `GuidoParser::tagParameter` drops it before
    // `ARFactory` is called (`GuidoParser.cpp:291`) — so keeping it is a
    // fidelity choice that costs nothing *while the tag survives around it*.
    // Here it would be the one token blocking promotion, since
    // `GMNTagPromoter.span(of:_:)` refuses any non-empty list, so the tag
    // would stay untyped over a value provably nothing reads.
    //
    // **An unresolved `$variable` reference survives**, as it does under
    // every other drop. guidolib substitutes a reference before `ARFactory`
    // is reached, so an undeclared name `YYABORT`s whatever tag it was
    // written on — including a closing half, which never gets as far as
    // having no slots. `GMNParser` refuses a parsed one before this runs;
    // dropping it here would still silence a hand-built
    // `\beamEnd<dx=$missing>`.
    //
    // Runs before `_renameParameters` and `_dropInertParameters`, both of
    // which are then no-ops on an emptied list. It reads the *canonical*
    // name, so `\decrescEnd<dx=2>` is recognized as the span end it is.
    private mutating func _dropSpanEndParameters(_ parameters: [GMNTag.Parameter],
                                                 on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        guard !parameters.isEmpty,
              GMNTagTemplate.Registry.span(of: tagName) == .end
        else { return parameters }

        let kept = parameters.filter { _isUnresolvedVariable($0.value) }

        guard kept.count < parameters.count
        else { return parameters }

        changes.append(.droppedSpanEndParameters(tagName))

        return kept
    }

    // Drops every parameter written on a tag whose class keeps none.
    //
    // `ARFactory::addTagParameter` records a parameter only when the tag just
    // built is an `ARMTParameter` (`ARFactory.cpp:2012–2016`), and six
    // dispatched names build classes that are not — the
    // `acceptsParameters: false` templates. Everything written to one of them
    // is discarded before binding happens at all.
    //
    // That is why `_dropUnreadParameters` cannot see these: `bind` short
    // circuits on `!template.acceptsParameters` and returns an empty `values`,
    // so no name ever reaches `unsupportedParameterNames`. The repair has to
    // be stated separately, and it is the strongest of the three drops — the
    // tag name alone settles it, with no value to bind and no `dynamic_cast`
    // to reason about.
    //
    // As with a span end, an unresolved `$variable` reference survives.
    private mutating func _dropUnacceptedParameters(_ parameters: [GMNTag.Parameter],
                                                    on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        guard !parameters.isEmpty,
              let template = GMNTagTemplate.Registry.template(for: tagName,
                                                              parameters: parameters),
              !template.acceptsParameters
        else { return parameters }

        let kept = parameters.filter { _isUnresolvedVariable($0.value) }

        guard kept.count < parameters.count
        else { return parameters }

        changes.append(.droppedUnacceptedParameters(tagName))

        return kept
    }

    // Drops every parameter guidolib's own reader never reads, logging each
    // as a `Change`. Two disjoint sets go, in one pass:
    //
    //   - **Inert** — bound to a slot no read the tag
    //     performs on that name can occupy. `TagParameterMap::get<T>` is a
    //     `dynamic_cast` (`TagParameterMap.h:54–57`), so the value reads back
    //     as null and the tag behaves as though it were never written:
    //     `\staccato<0.5>` is semantically a bare `\staccato`. Two names are
    //     read twice and satisfying either read is enough
    //     (`GMNTagTemplate.alternateParameterKinds`), which is why `\key<2>`
    //     keeps its `2`.
    //   - **Unsupported** — a name absent from the accumulated template, so
    //     `checkExist` fails and no `getParameter` call can find it
    //     (`TagParameterMap.cpp:110–119`). guidolib keeps it in its map,
    //     warns, and never reads it again.
    //
    // They are disjoint by construction: `illTypedParameterNames` measures a
    // value against a slot, and an unsupported name has none.
    //
    // **A parameter carrying a `$variable` is never dropped under either
    // heading**, even when its name is unsupported. guidolib substitutes the
    // reference before `ARFactory` is reached and `YYABORT`s when it does not
    // resolve (`GuidoParser.cpp:319–321`), so the reference is live whether
    // or not the name it was written under is one the tag reads. Dropping it
    // would silence it entirely on a hand-built `\beam<bogus=$missing>`; a
    // parsed one never gets here, because `GMNParser` refuses the reference
    // outright. `unrepresentableParameterNames` is what
    // holds those back, and the tag stays untyped around them.
    //
    // Two details carry the whole correctness of this step:
    //
    //   - **The survivors keep their written spelling only if it still binds
    //     them the same way.** Removing a positional parameter in place
    //     shifts every later one onto a different slot —
    //     `\stacc<0.5,"above">` would rebind `"above"` from `position` to
    //     `type` — so whenever the shortened list does not reproduce the
    //     original binding, it is restated by the name each parameter
    //     actually bound to. That is lossless: after binding, a parameter is
    //     identified by name only. Where the shortened list *does*
    //     reproduce it, as in `\tempo<"Allegro",120>`, nothing is renamed and
    //     the positional spelling survives.
    //   - **Every write to an inert name goes, not just the last.** In
    //     `\meter<"4/4",type=0.5>` both parameters bind to `type` and the
    //     float wins, leaving guidolib with no meter at all. Keeping the
    //     first one would resurrect a value guidolib had already discarded.
    //
    // A binding that failed outright is left completely alone: guidolib
    // throws away every parameter after the failure, and re-spelling a list
    // whose tail is already lost is not a repair.
    private mutating func _dropUnreadParameters(_ parameters: [GMNTag.Parameter],
                                                on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        guard let template = GMNTagTemplate.Registry.template(for: tagName,
                                                              parameters: parameters)
        else { return parameters }

        let binding = GMNTagBinder.bind(parameters,
                                        to: template)
        let liveNames = Set(binding.unrepresentableParameterNames)
        let inertNames = Set(binding.illTypedParameterNames).subtracting(liveNames)
        let unsupportedNames = Set(binding.unsupportedParameterNames).subtracting(liveNames)
        let droppedNames = inertNames.union(unsupportedNames)

        guard binding.failure == nil,
              !droppedNames.isEmpty
        else { return parameters }

        var asWritten: [GMNTag.Parameter] = []
        var named: [GMNTag.Parameter] = []

        for (index, parameter) in parameters.enumerated() {
            // Nothing bound, so there is nothing to measure this against and
            // nothing to rename it to. Unreachable from `_editUntypedTag` as
            // the chain now stands — a raw identifier is gone by here, a tag
            // that keeps no parameters returned early above, and a failed
            // binding is guarded against — but the array is parallel to
            // `parameters` under every path and this reads it.
            guard let boundName = binding.boundNames[index]
            else {
                asWritten.append(parameter)
                named.append(parameter)

                continue
            }

            guard !droppedNames.contains(boundName)
            else {
                changes.append(inertNames.contains(boundName)
                    ? .droppedInertParameter(tagName, boundName)
                    : .droppedUnsupportedParameter(tagName, boundName))

                continue
            }

            asWritten.append(parameter)
            named.append(GMNTag.Parameter(name: GMNTag.Parameter.Name(boundName),
                                          value: parameter.value))
        }

        let rebound = GMNTagBinder.bind(asWritten,
                                        to: template)

        return rebound.failure == nil && rebound.values == binding.values.filter { !droppedNames.contains($0.key) }
            ? asWritten
            : named
    }

    private mutating func _editChord(_ chord: GMNChord) -> GMNChord {
        // `_editSegment` maps 1:1 over `chord.segments`, so the segment
        // count — already non-empty going in — always still holds coming
        // out.
        GMNChord(segments: chord.segments.map { _editSegment($0) }).require()
    }

    private mutating func _editSegment(_ segment: GMNChord.Segment) -> GMNChord.Segment {
        // `_editSymbols` maps 1:1 and never introduces a nested chord (it
        // only rewrites tag names/parameters and recurses the same way), so
        // the segment's "non-empty, no nested chord" invariant — already
        // satisfied going in — always still holds coming out.
        GMNChord.Segment(symbols: _editSymbols(segment.symbols)).require()
    }

    private mutating func _editSymbol(_ symbol: GMNSymbol) -> GMNSymbol {
        switch symbol {
        case let .chord(chord):
            .chord(_editChord(chord))

        case .note,
             .rest,
             .tablature,
             .variable:
            symbol

        case let .tag(tag):
            .tag(_editTag(tag))
        }
    }

    private mutating func _editSymbols(_ symbols: [GMNSymbol]) -> [GMNSymbol] {
        symbols.map { _editSymbol($0) }
    }

    private mutating func _editTag(_ tag: GMNTag) -> GMNTag {
        guard let untyped = tag.untypedPayload
        else { return _editTypedTag(tag) }

        return _editUntypedTag(untyped)
    }

    // A typed payload needs none of the three edits below: promotion already
    // rejected any tag whose name was an alias, whose parameter carried a
    // deprecated name, or whose value was inert. Its *body* still needs
    // editing, though, so the tag is rebuilt through the promoter from its
    // own parameters — which is exactly the round trip promotion's
    // idempotence guarantees.
    private mutating func _editTypedTag(_ tag: GMNTag) -> GMNTag {
        GMNTagPromoter.promote(ident: tag.ident,
                               name: tag.name,
                               parameters: tag.payload.namedParameters,
                               body: _editSymbols(tag.body))
    }

    // The repair chain, in the one order that works.
    //
    // `_dropSpanEndParameters` goes first so that a closing half never pays
    // for an expansion or a rename it was about to discard anyway.
    // `_expandVariableReferences` goes before every remaining drop, because a
    // substituted value has to be judged inert, unsupported, or unit-bearing
    // on its merits like any other. `_dropRawIdentifierParameters` and
    // `_dropUnacceptedParameters` shorten the list; both are binding-neutral,
    // the first because the binder never counted an identifier and the second
    // because nothing bound at all.
    // Both untyped lanes come through here. A `.custom` tag has no template
    // to be judged against, so most of the chain is a no-op on it — but not
    // all of it: guidolib discards a raw identifier in the grammar
    // (`guido.y:188`), below dispatch, so `\bembel<foo>` loses its parameter
    // exactly as `\beam<foo>` does.
    private mutating func _editUntypedTag(_ tag: any GMNUntypedTag) -> GMNTag {
        let name = _canonicalize(tag.name)
        let kept = _dropSpanEndParameters(tag.parameters,
                                          on: name)
        let expanded = _expandVariableReferences(kept,
                                                 on: name)
        let bare = _dropRawIdentifierParameters(expanded,
                                                on: name)
        let accepted = _dropUnacceptedParameters(bare,
                                                 on: name)
        let renamed = _renameParameters(accepted,
                                        on: name)
        let unitless = _dropParameterUnits(renamed,
                                           on: name)

        // `_dropUnreadParameters` runs **after** `_renameParameters`, and the
        // order is load-bearing rather than incidental: `m` is not a name
        // `ARVolta` supports, so dropping the unread first would delete the
        // very parameter the rename exists to repair and `\volta<m="1.">`
        // would lose its mark instead of gaining one.
        //
        // Re-runs promotion on the edited tag, because any of the edits above
        // may be exactly what was stopping it from binding: `\bm<dy=2hs>`
        // cannot promote under the alias but `\beam<dy=2hs>` can,
        // `\meter<"4/4",0.5>` cannot until the inert `0.5` is gone,
        // `\beam<bogus=1>` cannot until the unsupported `bogus` is,
        // `\slurEnd<dx=2hs>` cannot until the offset is, `\beam<foo>` cannot
        // until the raw identifier is, `\newPage<dx=2hs>` cannot until every
        // parameter is, `\beam<size=1.5cm>` cannot until the unit is, and
        // `$x = 1; \beam<dy=$x>` cannot until the reference is substituted.
        // Safe to do unconditionally — promotion is total and idempotent.
        return GMNTagPromoter.promote(ident: tag.ident,
                                      name: name,
                                      parameters: _dropUnreadParameters(unitless, on: name),
                                      body: _editSymbols(tag.body))
    }

    private mutating func _editVariable(_ variable: GMNVariable) -> GMNVariable {
        guard let symbols = variable.symbols
        else { return variable }

        return GMNVariable(name: variable.name,
                           value: variable.value,
                           symbols: _editSymbols(symbols))
    }

    private mutating func _editVoice(_ voice: GMNVoice) -> GMNVoice {
        GMNVoice(symbols: _editSymbols(voice.symbols))
    }

    // Substitutes every `$variable` reference in tag-parameter position by
    // the value its declaration carries, logging each.
    //
    // This is `GuidoParser::varParam` (`GuidoParser.cpp:319–321`): it
    // switches on the declared type and **never attaches a unit**, which is
    // the one detail that makes the result differ from re-reading the written
    // text. A reference no declaration answers is left exactly as written
    // rather than guessed at; `GMNParser` has already refused one on a parsed
    // score, so this is what a hand-built score relies on.
    //
    // Symbol-position references are untouched — `_editSymbol` carries
    // `.variable` through unchanged. That position is a textual macro re-lexed
    // in place (`variableSymbols`) rather than a typed substitution, and
    // splicing it in is not implemented anywhere in IvorGuido.
    private mutating func _expandVariableReferences(_ parameters: [GMNTag.Parameter],
                                                    on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        parameters.map { parameter in
            guard case let .variable(variableName) = parameter.value,
                  let value = variables[variableName]
            else { return parameter }

            changes.append(.expandedVariableReference(tagName, variableName))

            return GMNTag.Parameter(name: parameter.name,
                                    value: Self._substituted(value))
        }
    }

    // Whether the value is a reference to a variable this score does not
    // declare — the one thing no repair may throw away.
    private func _isUnresolvedVariable(_ value: GMNTag.Parameter.Value) -> Bool {
        guard case let .variable(variableName) = value
        else { return false }

        return variables[variableName] == nil
    }

    private func _renamed(_ parameter: GMNTag.Parameter,
                          to newName: String) -> GMNTag.Parameter {
        GMNTag.Parameter(name: GMNTag.Parameter.Name(newName),
                         value: parameter.value)
    }

    private mutating func _renameParameters(_ parameters: [GMNTag.Parameter],
                                            on tagName: GMNTag.Name) -> [GMNTag.Parameter] {
        guard let rename = Self.renamableParameter[tagName.stringValue]
        else { return parameters }

        return parameters.map { parameter in
            guard parameter.name?.stringValue == rename.old
            else { return parameter }

            changes.append(.renamedParameter(tagName, rename.old, rename.new))

            return _renamed(parameter,
                            to: rename.new)
        }
    }
}
