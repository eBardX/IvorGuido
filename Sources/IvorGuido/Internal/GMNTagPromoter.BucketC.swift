// © 2026 John Gary Pusey (see LICENSE.md)

// Bucket C's dispatch arms — the performance tags.
//
// A file of its own rather than another extension in `GMNTagPromoter.swift`:
// that file is already close to SwiftLint's `file_length`, and this tranche
// is the largest of the four. `promoteBucketC(_:_:_:_:_:)` is `internal`
// rather than `private` for the same reason — it is called from the other
// file — and so carries no leading underscore, unlike its neighbours there.
//
// Seven of the thirteen payloads span. Each reads its `GMNTag.Span` from the
// registry through `span(of:_:)` below, which also enforces the rule that a
// closing half carries no parameters.
extension GMNTagPromoter {

    // MARK: Internal Type Methods

    internal static func promoteBucketC(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ parameters: [GMNTag.Parameter],
                                        _ body: [GMNSymbol]) -> GMNTag? {
        switch name.stringValue {
        case "arpeggio":
            .arpeggio(GMNArpeggio(ident: ident,
                                  binding: binding,
                                  body: body))

        case "breathMark":
            .breathMark(GMNBreathMark(ident: ident,
                                      binding: binding,
                                      body: body))

        case "fing",
             "fingering":
            GMNFingering(ident: ident,
                         binding: binding,
                         body: body).map { .fingering($0) }

        case "glissando",
             "glissandoBegin",
             "glissandoEnd":
            _promoteGlissando(ident,
                              name,
                              binding,
                              parameters,
                              body)

        case "i",
             "intens",
             "intensity":
            GMNIntensity(ident: ident,
                         binding: binding,
                         body: body).map { .intensity($0) }

        case "pedalOff":
            .pedal(GMNPedal(ident: ident,
                            binding: binding,
                            kind: .off,
                            body: body))

        case "pedalOn":
            .pedal(GMNPedal(ident: ident,
                            binding: binding,
                            kind: .on,
                            body: body))

        case "sl",
             "slur",
             "slurBegin",
             "slurEnd":
            _promoteSlur(ident,
                         name,
                         binding,
                         parameters,
                         body)

        case "tie",
             "tieBegin",
             "tieEnd":
            _promoteTie(ident,
                        name,
                        binding,
                        parameters,
                        body)

        case "trem",
             "tremBegin",
             "tremEnd",
             "tremolo",
             "tremoloBegin",
             "tremoloEnd":
            _promoteTremolo(ident,
                            name,
                            binding,
                            parameters,
                            body)

        default:
            _promoteArticulation(ident,
                                 name,
                                 binding,
                                 parameters,
                                 body)
                ?? _promoteDynamicRamp(ident,
                                       name,
                                       binding,
                                       parameters,
                                       body)
                ?? _promoteOrnament(ident,
                                    name,
                                    binding,
                                    parameters,
                                    body)
                ?? _promoteTempoChange(ident,
                                       name,
                                       binding,
                                       parameters,
                                       body)
        }
    }

    // MARK: Private Type Methods

    private static func _promoteArticulation(_ ident: GMNTag.Ident?,
                                             _ name: GMNTag.Name,
                                             _ binding: GMNTagBinder.Binding,
                                             _ parameters: [GMNTag.Parameter],
                                             _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNArticulation.Kind.kind(forTagName: name.stringValue),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNArticulation(ident: ident,
                               binding: binding,
                               kind: kind,
                               span: span,
                               body: body).map { .articulation($0) }
    }

    private static func _promoteDynamicRamp(_ ident: GMNTag.Ident?,
                                            _ name: GMNTag.Name,
                                            _ binding: GMNTagBinder.Binding,
                                            _ parameters: [GMNTag.Parameter],
                                            _ body: [GMNSymbol]) -> GMNTag? {
        guard let direction = GMNDynamicRamp.Direction.direction(forTagName: name.stringValue),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNDynamicRamp(ident: ident,
                              binding: binding,
                              direction: direction,
                              span: span,
                              body: body).map { .dynamicRamp($0) }
    }

    private static func _promoteGlissando(_ ident: GMNTag.Ident?,
                                          _ name: GMNTag.Name,
                                          _ binding: GMNTagBinder.Binding,
                                          _ parameters: [GMNTag.Parameter],
                                          _ body: [GMNSymbol]) -> GMNTag? {
        guard let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNGlissando(ident: ident,
                            binding: binding,
                            span: span,
                            body: body).map { .glissando($0) }
    }

    private static func _promoteOrnament(_ ident: GMNTag.Ident?,
                                         _ name: GMNTag.Name,
                                         _ binding: GMNTagBinder.Binding,
                                         _ parameters: [GMNTag.Parameter],
                                         _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNOrnament.Kind.kind(forTagName: name.stringValue),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNOrnament(ident: ident,
                           binding: binding,
                           kind: kind,
                           span: span,
                           body: body).map { .ornament($0) }
    }

    private static func _promoteSlur(_ ident: GMNTag.Ident?,
                                     _ name: GMNTag.Name,
                                     _ binding: GMNTagBinder.Binding,
                                     _ parameters: [GMNTag.Parameter],
                                     _ body: [GMNSymbol]) -> GMNTag? {
        guard !binding.hasUnreadableCurve(named: "curve"),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNSlur(ident: ident,
                       binding: binding,
                       span: span,
                       body: body).map { .slur($0) }
    }

    private static func _promoteTempoChange(_ ident: GMNTag.Ident?,
                                            _ name: GMNTag.Name,
                                            _ binding: GMNTagBinder.Binding,
                                            _ parameters: [GMNTag.Parameter],
                                            _ body: [GMNSymbol]) -> GMNTag? {
        guard let direction = GMNTempoChange.Direction.direction(forTagName: name.stringValue),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNTempoChange(ident: ident,
                              binding: binding,
                              direction: direction,
                              span: span,
                              body: body).map { .tempoChange($0) }
    }

    private static func _promoteTie(_ ident: GMNTag.Ident?,
                                    _ name: GMNTag.Name,
                                    _ binding: GMNTagBinder.Binding,
                                    _ parameters: [GMNTag.Parameter],
                                    _ body: [GMNSymbol]) -> GMNTag? {
        guard !binding.hasUnreadableCurve(named: "curve"),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNTie(ident: ident,
                      binding: binding,
                      span: span,
                      body: body).map { .tie($0) }
    }

    private static func _promoteTremolo(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ parameters: [GMNTag.Parameter],
                                        _ body: [GMNSymbol]) -> GMNTag? {
        guard let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNTremolo(ident: ident,
                          binding: binding,
                          span: span,
                          body: body).map { .tremolo($0) }
    }
}
