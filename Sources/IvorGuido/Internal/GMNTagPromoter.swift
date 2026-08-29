// © 2026 John Gary Pusey (see LICENSE.md)

// Turns a written tag into the most specific `GMNTag` case that fits it.
//
// Promotion is a **total, idempotent function of `(name, parameters)`** with
// the two untyped lanes as its fallback. It never throws, and it never repairs
// or discards anything: a tag that does not promote is carried through exactly
// as written, so a later pass can repair it and promote it again.
//
// Which untyped lane it falls to is settled by `GMNTag.untyped(…)` on one
// question — whether guidolib dispatches the name — so reason 1 below is the
// whole of `.custom` and reasons 2 through 5 are the whole of `.reserved`.
//
// Four things stop a tag from promoting, and only the second is temporary:
//
//   1. guidolib does not dispatch the name, so there is no template to bind
//      against (`GMNTagTemplate.Registry.template(for:)` returns `nil`).
//   2. The name is dispatched but no typed payload has been written for it
//      yet. Every tranche shrinks this set.
//   3. The tag does not bind cleanly — a parameter the tag does not support,
//      a required one missing, or an unnamed parameter past the end of the
//      template. This is guidolib's own `Match` test, and it is what
//      `GMNTagBinder.Binding.isMatched` reports.
//   4. Something written cannot be carried in a typed field without loss: a
//      value whose type the tag's own reader would cast away
//      (`illTypedParameterNames`), an unresolved `$variable` reference or a
//      unit on a ratio (`unrepresentableParameterNames`), or a raw
//      identifier, which guidolib discards outright and IvorGuido keeps for
//      round-tripping.
//
// A fifth blocker joins them in tranche 1b. Six dispatched names are not
// `ARMTParameter`s, so `ARFactory::addTagParameter` throws every parameter
// written to them away before binding (`ARFactory.cpp:2012–2016`) — the
// `acceptsParameters: false` templates. Binding one yields an empty map, so a
// payload built from it would carry nothing and the written parameter would
// vanish. Such a tag stays untyped instead. This is *not* the inert-parameter
// case: an inert parameter is one guidolib binds and then ignores, and the
// normalizer drops it only because the typed payload can prove it read as
// nothing. Here there is no binding at all to reason from.
//
// **Every blocker except reason 1 and reason 2 is now repairable**, and
// repairing it is the normalizer's job — this runs again afterwards on what
// the repair left behind, which is exactly why it must be idempotent. The
// normalizer takes the last four: a parameter written to a class that keeps
// none is dropped, so is a raw identifier, a unit on an `F` slot is dropped
// from the value, and a `$variable` in tag-parameter position is substituted
// by its declaration. What remains unrepairable here is a `$variable` no
// declaration answers, which must survive to be reported, and a value the
// tag's own class cannot read, which is `isUnreadable(_:)` below.
internal enum GMNTagPromoter {
}

// MARK: -

extension GMNTagPromoter {

    // MARK: Internal Type Properties

    // The dispatched names that stay on the `.reserved` lane permanently.
    //
    // `\port` builds an `ARTDummy` and means nothing; `\DrHoos` and `\DrRenz`
    // are real classes with a real parameter that simply fall outside the
    // 59-payload catalog. All three are in the registry, so all three bind
    // — they just have nowhere to go, and staying reserved is the right
    // answer rather than a defect. `isUnreadable(_:)` and the catalog-
    // closure test both read this rather than restating it.
    //
    // This is also the whole of the `.reserved` lane once normalization has
    // run: every other reason a dispatched name stays untyped is repaired by
    // then, or thrown.
    internal static let namesWithoutPayload: Set<String> = ["DrHoos",
                                                            "DrRenz",
                                                            "port"]

    // MARK: Internal Type Methods

    // Whether the given untyped tag stayed untyped *despite* binding cleanly
    // against guidolib's own schema.
    //
    // This is the four blockers above with every explicable one removed: the
    // name is dispatched, a payload exists for it, the tag keeps what is
    // written to it, no parameter is a raw identifier, every parameter is
    // supported, every required one is present, and nothing is ill-typed or
    // unrepresentable — and yet no builder accepted it. What is left is a
    // *value* the tag's own reader could not make sense of: a `position`
    // outside `above`/`below` (`GMNTag.Placement`), a `curve` guidolib would
    // only recognize by re-spelling it (`GMNTag.Curve`), a `bpm` that
    // `ARTempo::ParseBpm` rejects.
    //
    // The residual is deliberately not narrowed to a parameter name. Which
    // value a builder balked at is the builder's business — encoding it here
    // would mean a second table of tag names to drift against the first,
    // exactly the duplication this design avoids. The validator reports the
    // tag and leaves the value visible, as written, for the reader to find.
    //
    // The last step has to be running promotion rather than reasoning about
    // it. Being untyped is not by itself evidence of anything — a score built
    // by hand, or one that has been parsed but not normalized, is full of
    // tags that are untyped only because nobody has offered them to a builder
    // yet. Only a tag that clears every blocker above *and still comes back
    // untyped* was actually refused.
    //
    // A `.custom` tag answers `false` at the first guard: an undispatched
    // name has no template, so there is no schema it could have bound
    // cleanly against and nothing was refused.
    internal static func isUnreadable(_ tag: any GMNUntypedTag) -> Bool {
        guard !namesWithoutPayload.contains(tag.name.stringValue),
              let template = GMNTagTemplate.Registry.template(for: tag.name,
                                                              parameters: tag.parameters),
              template.acceptsParameters || tag.parameters.isEmpty,
              !tag.parameters.contains(where: Self._isRawIdentifier)
        else { return false }

        let binding = GMNTagBinder.bind(tag.parameters,
                                        to: template)

        guard binding.isMatched,
              binding.illTypedParameterNames.isEmpty,
              binding.unrepresentableParameterNames.isEmpty,
              Self.promote(ident: tag.ident,
                           name: tag.name,
                           parameters: tag.parameters,
                           body: tag.body).untypedPayload != nil
        else { return false }

        return true
    }

    // Returns the typed `GMNTag` for the given tag, or the untyped case that
    // fits it if none does.
    internal static func promote(ident: GMNTag.Ident?,
                                 name: GMNTag.Name,
                                 parameters: [GMNTag.Parameter],
                                 body: [GMNSymbol]) -> GMNTag {
        let untyped = GMNTag.untyped(ident: ident,
                                     name: name,
                                     parameters: parameters,
                                     body: body)

        guard let template = GMNTagTemplate.Registry.template(for: name,
                                                              parameters: parameters),
              template.acceptsParameters || parameters.isEmpty,
              !parameters.contains(where: Self._isRawIdentifier)
        else { return untyped }

        let binding = GMNTagBinder.bind(parameters,
                                        to: template)

        guard binding.isMatched,
              binding.illTypedParameterNames.isEmpty,
              binding.unrepresentableParameterNames.isEmpty,
              let promoted = Self._promote(ident,
                                           name,
                                           binding,
                                           parameters,
                                           body)
        else { return untyped }

        return promoted
    }

    // Which part of a spanning construct the given name is, or `nil` if it
    // is an `…End` written with parameters.
    //
    // An `…End` tag is an `ARDummyRangeEnd`, which takes no parameters at
    // all. Its template is the shared range-end one, so
    // `\tupletEnd<dx=2>` would otherwise bind cleanly against `kCommonParams`
    // and promote to a payload with nowhere to put what was written. Leaving
    // it reserved keeps it intact for the normalizer to repair: it drops
    // what was written and re-runs promotion on the emptied list.
    //
    // Every spanning payload routes through here, which is why the rule is
    // stated once rather than once per tag.
    internal static func span(of name: GMNTag.Name,
                              _ parameters: [GMNTag.Parameter]) -> GMNTag.Span? {
        let span = GMNTagTemplate.Registry.span(of: name)

        guard span != .end || parameters.isEmpty
        else { return nil }

        return span
    }

    // MARK: Private Type Methods

    private static func _isRawIdentifier(_ parameter: GMNTag.Parameter) -> Bool {
        if case .parameter = parameter.value {
            true
        } else {
            false
        }
    }

    // The name → payload dispatch, one arm per typed tag. Every arm may
    // still decline, which is what makes the whole function total: a builder
    // that cannot read a required parameter returns `nil` and the tag stays
    // untyped.
    //
    // Split by tranche purely to stay inside SwiftLint's function-body
    // length; the split point carries no meaning.
    private static func _promote(_ ident: GMNTag.Ident?,
                                 _ name: GMNTag.Name,
                                 _ binding: GMNTagBinder.Binding,
                                 _ parameters: [GMNTag.Parameter],
                                 _ body: [GMNSymbol]) -> GMNTag? {
        _promoteBucketA(ident,
                        name,
                        binding,
                        parameters,
                        body)
            ?? _promoteBucketB(ident,
                               name,
                               binding,
                               body)
            ?? _promoteBucketBPartTwo(ident,
                                      name,
                                      binding,
                                      parameters,
                                      body)
            ?? promoteBucketC(ident,
                              name,
                              binding,
                              parameters,
                              body)
            ?? promoteBucketD(ident,
                              name,
                              binding,
                              parameters,
                              body)
    }
}

// MARK: -

// The dispatch arms themselves, one function per tranche plus a handful of
// name→kind helpers. They live in an extension so that the type body stays
// within what SwiftLint allows; the split points carry no meaning beyond
// that.
extension GMNTagPromoter {

    // MARK: Private Type Methods

    private static func _promoteBarLine(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ body: [GMNSymbol]) -> GMNTag? {
        let kind: GMNBarLine.Kind

        switch name.stringValue {
        case "doubleBar":
            kind = .double

        case "endBar":
            kind = .final

        case "|",
             "bar":
            kind = .single

        default:
            return nil
        }

        return .barLine(GMNBarLine(ident: ident,
                                   binding: binding,
                                   kind: kind,
                                   body: body))
    }

    private static func _promoteBucketA(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ parameters: [GMNTag.Parameter],
                                        _ body: [GMNSymbol]) -> GMNTag? {
        switch name.stringValue {
        case "acc",
             "accidental":
            .accidental(GMNAccidental(ident: ident,
                                      binding: binding,
                                      body: body))

        case "alter":
            GMNAlter(ident: ident,
                     binding: binding,
                     body: body).map { .alter($0) }

        case "cluster":
            .cluster(GMNCluster(ident: ident,
                                binding: binding,
                                body: body))

        case "dispDur",
             "displayDuration":
            GMNDisplayDuration(ident: ident,
                               binding: binding,
                               body: body).map { .displayDuration($0) }

        case "grace":
            .grace(GMNGrace(ident: ident,
                            binding: binding,
                            body: body))

        case "key":
            GMNKey(ident: ident,
                   binding: binding,
                   body: body).map { .key($0) }

        case "meter":
            GMNMeter(ident: ident,
                     binding: binding,
                     body: body).map { .meter($0) }

        case "mrest":
            GMNMultiMeasureRest(ident: ident,
                                binding: binding,
                                body: body).map { .multiMeasureRest($0) }

        case "oct",
             "octava":
            GMNOctava(ident: ident,
                      binding: binding,
                      body: body).map { .octava($0) }

        case "tuplet",
             "tupletBegin",
             "tupletEnd":
            _promoteTuplet(ident,
                           name,
                           binding,
                           parameters,
                           body)

        default:
            nil
        }
    }

    private static func _promoteBucketB(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ body: [GMNSymbol]) -> GMNTag? {
        switch name.stringValue {
        case "accol",
             "accolade":
            GMNAccolade(ident: ident,
                        binding: binding,
                        body: body).map { .accolade($0) }

        case "auto",
             "set":
            .auto(GMNAuto(ident: ident,
                          binding: binding,
                          body: body))

        case "barFormat":
            .barFormat(GMNBarFormat(ident: ident,
                                    binding: binding,
                                    body: body))

        case "clef":
            GMNClef(ident: ident,
                    binding: binding,
                    body: body).map { .clef($0) }

        case "cue":
            .cue(GMNCue(ident: ident,
                        binding: binding,
                        body: body))

        case "harmony":
            GMNHarmony(ident: ident,
                       binding: binding,
                       body: body).map { .harmony($0) }

        case "instr",
             "instrument":
            GMNInstrument(ident: ident,
                          binding: binding,
                          body: body).map { .instrument($0) }

        case "merge":
            .merge(GMNMerge(ident: ident,
                            body: body))

        default:
            _promoteBarLine(ident,
                            name,
                            binding,
                            body)
                ?? _promoteJump(ident,
                                name,
                                binding,
                                body)
                ?? _promoteLayoutBreak(ident,
                                       name,
                                       binding,
                                       body)
        }
    }

    // Bucket B's second half. Split arbitrarily rather than along any
    // semantic boundary, purely to keep each file under SwiftLint's
    // `file_length`.
    private static func _promoteBucketBPartTwo(_ ident: GMNTag.Ident?,
                                               _ name: GMNTag.Name,
                                               _ binding: GMNTagBinder.Binding,
                                               _ parameters: [GMNTag.Parameter],
                                               _ body: [GMNSymbol]) -> GMNTag? {
        switch name.stringValue {
        case "pageFormat":
            GMNPageFormat(ident: ident,
                          binding: binding,
                          body: body).map { .pageFormat($0) }

        case "repeatBegin":
            .repeatMark(GMNRepeat(ident: ident,
                                  binding: binding,
                                  kind: .begin,
                                  body: body))

        case "repeatEnd":
            .repeatMark(GMNRepeat(ident: ident,
                                  binding: binding,
                                  kind: .end,
                                  body: body))

        case "shareLocation":
            .shareLocation(GMNShareLocation(ident: ident,
                                            binding: binding,
                                            body: body))

        case "space":
            GMNSpace(ident: ident,
                     binding: binding,
                     body: body).map { .space($0) }

        case "staff":
            GMNStaff(ident: ident,
                     binding: binding,
                     body: body).map { .staff($0) }

        case "staffFormat":
            .staffFormat(GMNStaffFormat(ident: ident,
                                        binding: binding,
                                        body: body))

        case "staffOff":
            .staffVisibility(GMNStaffVisibility(ident: ident,
                                                binding: binding,
                                                kind: .off,
                                                body: body))

        case "staffOn":
            .staffVisibility(GMNStaffVisibility(ident: ident,
                                                binding: binding,
                                                kind: .on,
                                                body: body))

        case "systemFormat":
            .systemFormat(GMNSystemFormat(ident: ident,
                                          binding: binding,
                                          body: body))

        case "tempo":
            GMNTempo(ident: ident,
                     binding: binding,
                     body: body).map { .tempo($0) }

        case "units":
            GMNUnits(ident: ident,
                     binding: binding,
                     body: body).map { .units($0) }

        case "volta",
             "voltaBegin",
             "voltaEnd":
            _promoteVolta(ident,
                          name,
                          binding,
                          parameters,
                          body)

        default:
            nil
        }
    }

    private static func _promoteJump(_ ident: GMNTag.Ident?,
                                     _ name: GMNTag.Name,
                                     _ binding: GMNTagBinder.Binding,
                                     _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNJump.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return .jump(GMNJump(ident: ident,
                             binding: binding,
                             kind: kind,
                             body: body))
    }

    private static func _promoteLayoutBreak(_ ident: GMNTag.Ident?,
                                            _ name: GMNTag.Name,
                                            _ binding: GMNTagBinder.Binding,
                                            _ body: [GMNSymbol]) -> GMNTag? {
        let kind: GMNLayoutBreak.Kind

        switch name.stringValue {
        case "newPage":
            kind = .newPage

        case "newLine",
             "newSystem":
            kind = .newSystem

        default:
            return nil
        }

        return .layoutBreak(GMNLayoutBreak(ident: ident,
                                           binding: binding,
                                           kind: kind,
                                           body: body))
    }

    private static func _promoteTuplet(_ ident: GMNTag.Ident?,
                                       _ name: GMNTag.Name,
                                       _ binding: GMNTagBinder.Binding,
                                       _ parameters: [GMNTag.Parameter],
                                       _ body: [GMNSymbol]) -> GMNTag? {
        guard let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNTuplet(ident: ident,
                         binding: binding,
                         span: span,
                         body: body).map { .tuplet($0) }
    }

    private static func _promoteVolta(_ ident: GMNTag.Ident?,
                                      _ name: GMNTag.Name,
                                      _ binding: GMNTagBinder.Binding,
                                      _ parameters: [GMNTag.Parameter],
                                      _ body: [GMNSymbol]) -> GMNTag? {
        guard let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNVolta(ident: ident,
                        binding: binding,
                        span: span,
                        body: body).map { .volta($0) }
    }
}
