// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagBinder {

    // MARK: Internal Nested Types

    // The result of binding one tag's parameters against its template.
    //
    // The values are keyed by the name each parameter bound to, which is
    // exactly guidolib's `TagParameterMap`: it stores no order, because
    // after binding there is none to store.
    internal struct Binding {

        // MARK: Internal Instance Properties

        // The name each written parameter bound to, in written order, or
        // `nil` where it bound to none.
        //
        // Parallel to the parameter list handed to `bind(_:to:)`. A `nil`
        // entry is a raw identifier (which guidolib discards outright), a
        // parameter written to a tag that keeps none, or — after a binding
        // failure — one of the parameters guidolib's `break` throws away.
        //
        // This is what lets the normalizer rewrite a parameter list *by
        // name* rather than by position. Dropping a positional parameter in
        // place would silently rebind every parameter after it, so a repair
        // that removes one must restate the survivors named.
        internal let boundNames: [String?]

        // The failure that stopped binding, or `nil` if every parameter
        // bound.
        internal let failure: Failure?

        // The template bound against.
        internal let template: GMNTagTemplate

        // Each bound parameter, keyed by the name it bound to.
        internal let values: [String: GMNTag.Parameter.Value]
    }
}

// MARK: -

extension GMNTagBinder.Binding {

    // MARK: Internal Instance Properties

    // The names bound to a value guidolib's own reader would cast away,
    // sorted.
    //
    // These are guidolib's inert parameters: `\staccato<0.5>` binds `0.5` to
    // `type`, an `S` slot, and `TagParameterMap::get<TagParameterString>`
    // returns null on it — so guidolib reads the tag as a bare `\staccato`.
    // The parser leaves such a tag alone; the normalizer drops the parameter
    // and re-promotes.
    //
    // A parameter the tag does not support at all is not listed here: there
    // is no slot to measure it against, and `unsupportedParameterNames`
    // already accounts for it.
    //
    // Nor is a parameter whose value matches the *second* type its class
    // reads the name under. `ARKey` reads `key` as a `TagParameterString` and
    // then, failing that, as a `TagParameterInt` (`ARKey.cpp:88–96`), so
    // `\key<2>` really does set a key even though the template says `S`; the
    // reverse holds for `id` on `\staff`. `GMNTagTemplate.reads(_:as:)` is
    // where both reads are consulted and
    // `GMNTagTemplate.alternateParameterKinds` where they are derived.
    //
    // This is therefore exactly the set the normalizer may drop. It once was
    // not: a second property used to subtract four names — `h`, `id`, `key`,
    // `w` — that a by-name reading of the same grep appeared to make
    // ambiguous; per class only two survive, and both are now carried by a
    // typed payload rather than exempted from a repair.
    internal var illTypedParameterNames: [String] {
        values.filter { name, value in
            guard template.supportedParameter(named: name) != nil,
                  !Self._isUnrepresentable(value)
            else { return false }

            return !template.reads(value,
                                   as: name)
        }
        .keys
        .sorted()
    }

    // Whether the binding satisfies guidolib's own acceptance test,
    // `TagParameterMap::Match = checkExist && checkRequired`
    // (`TagParameterMap.cpp:75–78`).
    //
    // guidolib only warns on a mismatch — a score that fails this still
    // parses and still renders. It is the signal for a schema-check
    // diagnostic, never for an error.
    internal var isMatched: Bool {
        failure == nil
            && missingRequiredParameterNames.isEmpty
            && unsupportedParameterNames.isEmpty
    }

    // The names of required parameters the tag did not receive, sorted.
    //
    // Transcribes `checkRequired` (`TagParameterMap.cpp:96–107`).
    internal var missingRequiredParameterNames: [String] {
        template.supportedParameters
                .filter { $0.isRequired && values[$0.name] == nil }
                .map { $0.name }
                .sorted()
    }

    // The names bound to a value no typed payload can carry, sorted.
    //
    // A `$variable` reference is a placeholder guidolib substitutes before a
    // tag is ever built (`GuidoParser.cpp:319–321`); IvorGuido keeps it in
    // the AST unresolved, so there is no value to read into a field. Unlike
    // an ill-typed parameter this is **not** inert and must never be
    // dropped — it simply keeps the tag on the `.reserved` lane, where it
    // round-trips as written.
    // A unit written where no read of that name is of the `U` kind is the
    // second case. guidolib tolerates it — a unit is a field on the value, not
    // a separate class, so the cast still succeeds and `checkUnit` merely
    // warns — but an `F` or `I` field is a bare scalar (`size` is a ratio, not
    // a length; a staff `id` is a count), so the unit would be silently lost
    // on the way back out. Keeping the tag reserved preserves it instead.
    // `GMNTagTemplate.readsAsLength(_:)` is what decides, and it consults both
    // reads for a name a class reads twice.
    //
    // That second case is still listed here even though the normalizer now
    // repairs it (`GMNNormalizer.Change.droppedParameterUnit`), and the
    // reason is that promotion also runs in the parser, where a score must
    // round-trip byte-for-byte. The blocker is what keeps the parser from
    // dropping the unit with nothing recorded; the normalizer strips it from
    // the *value* before re-promoting, so by the time promotion sees the tag
    // again there is no unit for this to report.
    //
    // A value the tag does not read at all is not listed: it is inert or
    // unsupported, the whole parameter goes rather than just its unit, and
    // listing it here would exempt it from that drop and strand the tag.
    internal var unrepresentableParameterNames: [String] {
        values.filter { name, value in
            if Self._isUnrepresentable(value) {
                return true
            }

            guard Self._unit(of: value) != nil,
                  template.reads(value,
                                 as: name)
            else { return false }

            return !template.readsAsLength(name)
        }
        .keys
        .sorted()
    }

    // The names bound that the tag does not support, sorted.
    //
    // Transcribes `checkExist` (`TagParameterMap.cpp:110–119`). This is the
    // set that keeps a tag `.reserved`: the parser promotes only what binds
    // cleanly, and an unrecognized parameter name is not clean.
    internal var unsupportedParameterNames: [String] {
        values.keys
              .filter { template.supportedParameter(named: $0) == nil }
              .sorted()
    }

    // MARK: Private Type Methods

    private static func _isUnrepresentable(_ value: GMNTag.Parameter.Value) -> Bool {
        if case .variable = value {
            true
        } else {
            false
        }
    }

    private static func _unit(of value: GMNTag.Parameter.Value) -> GMNTag.Parameter.Unit? {
        switch value {
        case let .floating(_, unit):
            unit

        case let .integer(_, unit):
            unit

        default:
            nil
        }
    }
}

// MARK: -

extension GMNTagBinder.Binding {

    // MARK: Internal Instance Properties

    // The four `kCommonParams` parameters, read off the binding.
    //
    // Every tag has these, whether or not they occupy positional slots, so
    // reading them is a property of the binding rather than of any one
    // payload. All four are non-omissible, which is why each is `Optional`
    // and absence is preserved rather than filled in.
    internal var appearance: GMNTag.Appearance {
        GMNTag.Appearance(color: string(named: "color"),
                          dx: length(named: "dx"),
                          dy: length(named: "dy"),
                          size: double(named: "size"))
    }

    // The `dx1`/`dy1`/`dx2`/`dy2` quartet, read off the binding.
    //
    // Meaningful only for the three tags that declare all four — `\slur`,
    // `\tie`, and `\glissando`. For any other tag the names it does not
    // declare are unsupported, so the binding never carries them.
    internal var controlPoints: GMNTag.ControlPoints {
        GMNTag.ControlPoints(dx1: length(named: "dx1"),
                             dy1: length(named: "dy1"),
                             dx2: length(named: "dx2"),
                             dy2: length(named: "dy2"))
    }

    // The four `kARFontAbleParams` parameters, read off the binding.
    //
    // Meaningful only for a payload whose tag derives from `ARFontAble`; for
    // any other tag the four names are unsupported, so the binding never
    // carries them and this reads as empty.
    internal var textStyle: GMNTag.TextStyle {
        GMNTag.TextStyle(textFormat: string(named: "textformat"),
                         font: string(named: "font"),
                         fontSize: length(named: "fsize"),
                         fontAttributes: string(named: "fattrib"))
    }

    // MARK: Internal Instance Methods

    // Reads the named parameter as a curve direction, or `nil` if it is
    // absent, of another kind, or outside the closed `up`/`down`
    // vocabulary (case-insensitively) — see `hasUnreadableCurve(named:)`
    // and `GMNTag.Curve.init?(guidoValue:)`.
    internal func curve(named name: String) -> GMNTag.Curve? {
        string(named: name).flatMap { GMNTag.Curve(guidoValue: $0) }
    }

    // Reads the named parameter as a bare number, or `nil` if it is absent
    // or of another kind.
    //
    // Any unit written alongside it is dropped: this is the `F` and `I`
    // kinds, which take none.
    internal func double(named name: String) -> Double? {
        switch values[name] {
        case let .floating(value, _):
            value

        case let .integer(value, _):
            Double(value)

        default:
            nil
        }
    }

    // Whether the named parameter was written with a value the closed
    // curve vocabulary cannot read (case-insensitively) as `up` or `down`.
    //
    // `\slur` and `\tie` decline to promote on this, exactly as the
    // placement payloads decline on `hasUnreadablePlacement(named:)`, so
    // that what was written survives on the `.reserved` lane — see
    // `GMNTag.Curve.init?(guidoValue:)` for why.
    internal func hasUnreadableCurve(named name: String) -> Bool {
        guard let written = string(named: name)
        else { return false }

        return GMNTag.Curve(guidoValue: written) == nil
    }

    // Whether the named parameter was written with a value the closed
    // placement vocabulary cannot read.
    //
    // The three payloads whose classes fall back to `kDefaultPosition` on an
    // unrecognized `position` decline to promote on this, so that what was
    // written survives on the `.reserved` lane — see
    // `GMNTag.Placement.init?(guidoValue:)` for why.
    internal func hasUnreadablePlacement(named name: String) -> Bool {
        guard let written = string(named: name)
        else { return false }

        return GMNTag.Placement(guidoValue: written) == nil
    }

    // Reads the named parameter as a whole number, or `nil` if it is absent
    // or of another kind — the `I` kind.
    //
    // A float never qualifies: `TagParameterInt` derives from
    // `TagParameterFloat` and not the other way round, so
    // `getParameter<TagParameterInt>` casts a written float away.
    internal func integer(named name: String) -> Int? {
        guard case let .integer(value, _) = values[name]
        else { return nil }

        return value
    }

    // Reads the named parameter as a length, or `nil` if it is absent or of
    // another kind — the `U` kind.
    internal func length(named name: String) -> GMNLength? {
        switch values[name] {
        case let .floating(value, unit):
            GMNLength(value,
                      unit: unit)

        case let .integer(value, unit):
            GMNLength(Double(value),
                      unit: unit)

        default:
            nil
        }
    }

    // Reads the named parameter as a whole number or a quoted string, or
    // `nil` if it is absent or of another kind.
    //
    // Only for the two names a class reads under both types — see
    // `GMNTagTemplate.alternateParameterKinds`. For any other name one of the
    // two spellings is inert, and reading it here would resurrect a value
    // guidolib had already cast away.
    internal func numberOrName(named name: String) -> GMNTag.NumberOrName? {
        GMNTag.NumberOrName(values[name])
    }

    // Reads the named parameter as a placement, or `nil` if it is absent, of
    // another kind, or outside the closed vocabulary.
    internal func placement(named name: String) -> GMNTag.Placement? {
        string(named: name).flatMap { GMNTag.Placement(guidoValue: $0) }
    }

    // Reads the named parameter as a string, or `nil` if it is absent or of
    // another kind — the `S` kind.
    //
    // Only a quoted string qualifies. A raw identifier never reaches a
    // binding at all (`GMNTagBinder.bind(_:to:)`), and a number bound to an
    // `S` slot is what guidolib's `dynamic_cast` reduces to null, making it
    // inert rather than a string.
    internal func string(named name: String) -> String? {
        guard case let .string(value) = values[name]
        else { return nil }

        return value
    }
}

// MARK: - Equatable

extension GMNTagBinder.Binding: Equatable {
}

// MARK: - Sendable

extension GMNTagBinder.Binding: Sendable {
}
