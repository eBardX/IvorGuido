// © 2026 John Gary Pusey (see LICENSE.md)

// Bucket D's dispatch arms — the visual and textual tags, the last of the 59
// payloads.
//
// A file of its own for the same reason `GMNTagPromoter.BucketC.swift` is one:
// `GMNTagPromoter.swift` is close to SwiftLint's `file_length`, and
// `promoteBucketD(_:_:_:_:_:)` is `internal` rather than `private` because it
// is called from there.
//
// Only `\beam` and `\fBeam` span. Everything else in this tranche is either a
// position tag or a state tag, and the five `\heads…` and four `\stems…`
// names are ranges without an open form at all.
extension GMNTagPromoter {

    // MARK: Internal Type Methods

    internal static func promoteBucketD(_ ident: GMNTag.Ident?,
                                        _ name: GMNTag.Name,
                                        _ binding: GMNTagBinder.Binding,
                                        _ parameters: [GMNTag.Parameter],
                                        _ body: [GMNSymbol]) -> GMNTag? {
        switch name.stringValue {
        case "color",
             "colour":
            GMNColor(ident: ident,
                     binding: binding,
                     body: body).map { .color($0) }

        case "dotFormat":
            .dotFormat(GMNDotFormat(ident: ident,
                                    binding: binding,
                                    body: body))

        case "lyrics":
            GMNLyrics(ident: ident,
                      binding: binding,
                      body: body).map { .lyrics($0) }

        case "mark":
            GMNMark(ident: ident,
                    binding: binding,
                    body: body).map { .mark($0) }

        case "noteFormat":
            .noteFormat(GMNNoteFormat(ident: ident,
                                      binding: binding,
                                      body: body))

        case "restFormat":
            .restFormat(GMNRestFormat(ident: ident,
                                      binding: binding,
                                      body: body))

        case "s",
             "symbol":
            GMNGraphicSymbol(ident: ident,
                             binding: binding,
                             body: body).map { .graphicSymbol($0) }

        case "special":
            GMNSpecial(ident: ident,
                       binding: binding,
                       body: body).map { .special($0) }

        default:
            _promoteBeam(ident,
                         name,
                         binding,
                         parameters,
                         body)
                ?? _promoteBeamState(ident,
                                     name,
                                     body)
                ?? _promoteNoteHeads(ident,
                                     name,
                                     binding,
                                     body)
                ?? _promoteStemDirection(ident,
                                         name,
                                         binding,
                                         body)
                ?? _promoteText(ident,
                                name,
                                binding,
                                body)
                ?? _promoteTitleBlock(ident,
                                      name,
                                      binding,
                                      body)
        }
    }

    // MARK: Private Type Methods

    private static func _promoteBeam(_ ident: GMNTag.Ident?,
                                     _ name: GMNTag.Name,
                                     _ binding: GMNTagBinder.Binding,
                                     _ parameters: [GMNTag.Parameter],
                                     _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNBeam.Kind.kind(forTagName: name.stringValue),
              let span = Self.span(of: name, parameters)
        else { return nil }

        return GMNBeam(ident: ident,
                       binding: binding,
                       kind: kind,
                       span: span,
                       body: body).map { .beam($0) }
    }

    // `\beamsAuto` and its two siblings keep no parameters at all, so there is
    // no binding to read — the promoter's `acceptsParameters` guard has
    // already refused anything written to them.
    private static func _promoteBeamState(_ ident: GMNTag.Ident?,
                                          _ name: GMNTag.Name,
                                          _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNBeamState.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return .beamState(GMNBeamState(ident: ident,
                                       kind: kind,
                                       body: body))
    }

    private static func _promoteNoteHeads(_ ident: GMNTag.Ident?,
                                          _ name: GMNTag.Name,
                                          _ binding: GMNTagBinder.Binding,
                                          _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNNoteHeads.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return .noteHeads(GMNNoteHeads(ident: ident,
                                       binding: binding,
                                       kind: kind,
                                       body: body))
    }

    private static func _promoteStemDirection(_ ident: GMNTag.Ident?,
                                              _ name: GMNTag.Name,
                                              _ binding: GMNTagBinder.Binding,
                                              _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNStemDirection.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return .stemDirection(GMNStemDirection(ident: ident,
                                               binding: binding,
                                               kind: kind,
                                               body: body))
    }

    private static func _promoteText(_ ident: GMNTag.Ident?,
                                     _ name: GMNTag.Name,
                                     _ binding: GMNTagBinder.Binding,
                                     _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNText.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return GMNText(ident: ident,
                       binding: binding,
                       kind: kind,
                       body: body).map { .text($0) }
    }

    private static func _promoteTitleBlock(_ ident: GMNTag.Ident?,
                                           _ name: GMNTag.Name,
                                           _ binding: GMNTagBinder.Binding,
                                           _ body: [GMNSymbol]) -> GMNTag? {
        guard let kind = GMNTitleBlock.Kind.kind(forTagName: name.stringValue)
        else { return nil }

        return GMNTitleBlock(ident: ident,
                             binding: binding,
                             kind: kind,
                             body: body).map { .titleBlock($0) }
    }
}
