// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension GMNValidator {

    // MARK: Internal Nested Types

    // Checks one tag against the schema the tag template registry
    // transcribes: its parameters against the template's slots, its body
    // against the range setting.
    //
    // Separate from `Checker`, which walks the score: this type knows nothing
    // about traversal and answers only for the tag in front of it, which is
    // what makes every check here a pure function of the tag.
    //
    // ## Why this runs after normalization and not before
    //
    // `GMNNormalizer` repairs; it does not judge. A defect is only definite
    // once every repair has been tried — `\volta<m="1.">` is missing its
    // required `mark` as written and has one a rename later, and
    // `\slurEnd<1,2,3,4,5>` overruns a template it no longer has parameters to
    // overrun. Judging any of this at the parser would refuse scores that are
    // merely denormalized, which is why `validate(_:)` demands a normalized
    // score rather than checking one itself.
    //
    // ## Both lanes, through one code path
    //
    // A typed payload restates its parameters explicitly named
    // (`GMNTagPayload.namedParameters`), so a hand-built `GMNClef` binds
    // against `kARClefParams` exactly as a written `\clef` does. On a parsed
    // score the requiredness check can only fire on an untyped lane, because
    // promotion already made `isMatched` a precondition; on a hand-built one it
    // can fire anywhere, and an AST constructible by hand is goal 1 of the
    // typed tag model.
    //
    // ## What is deliberately not checked
    //
    // A name guidolib does not dispatch at all — `\bembel`, `\splitChord`,
    // `\shortFermata` — has no template, so there is nothing to check it
    // against and it is passed over in silence. That is not an oversight:
    // guidolib itself accepts the name and builds an `ARTDummy` for it
    // (`ARFactory.cpp:1636–1640`), so there is no defect to report.
    internal enum SchemaChecker {
    }
}

// MARK: -

extension GMNValidator.SchemaChecker {

    // MARK: Internal Type Methods

    // Returns every schema issue the given tag raises, in a stable order:
    // parameters before body, since a tag that lost a parameter to binding
    // is being read against a schema it never matched.
    internal static func check(_ tag: GMNTag) -> [GMNValidator.Issue] {
        guard let template = GMNTagTemplate.Registry.template(for: tag.name,
                                                              parameters: _parameters(of: tag))
        else { return [] }

        let span = GMNTagTemplate.Registry.span(of: tag.name)

        // Nothing is checked on a closing half. Nothing is required of one
        // and nothing can overrun it: its template is the shared range-end
        // one, so every name in it is supported, none is required, and its
        // range setting is the shared one too — reporting against that
        // would say nothing true about a tag whose real schema is that it
        // has none.
        guard span != .end
        else { return [] }

        return Self._checkParameters(tag, template)
            + Self._checkBody(tag, template, span)
    }

    // MARK: Private Type Methods

    // Only the `whole` form is checked. An open span writes its halves as
    // `\slurBegin … \slurEnd`, and both share the whole tag's template —
    // including its `ONLY` range setting — while neither can carry a body
    // by construction, so checking them would report every well-formed
    // open span in the corpus.
    private static func _checkBody(_ tag: GMNTag,
                                   _ template: GMNTagTemplate,
                                   _ span: GMNTag.Span) -> [GMNValidator.Issue] {
        guard span == .whole
        else { return [] }

        switch template.rangeSetting {
        case .either:
            return []

        case .no:
            return tag.body.isEmpty ? [] : [.unexpectedTagBody(tag.name)]

        case .only:
            return tag.body.isEmpty ? [.missingTagBody(tag.name)] : []
        }
    }

    // At most one issue, because the three cascade: an overrun leaves
    // everything after it unbound, which would report a required parameter
    // missing that was written and merely misplaced, and readability is
    // the residual of both.
    private static func _checkParameters(_ tag: GMNTag,
                                         _ template: GMNTagTemplate) -> [GMNValidator.Issue] {
        let binding = GMNTagBinder.bind(Self._parameters(of: tag),
                                        to: template)

        if case let .unboundPositionalParameter(index) = binding.failure {
            return [.unboundPositionalParameter(tag.name,
                                                index: index)]
        }

        if let missing = binding.missingRequiredParameterNames.first {
            return [.missingRequiredParameter(tag.name,
                                              GMNTag.Parameter.Name(missing))]
        }

        return Self._checkReadability(tag)
    }

    // The residual: a tag that satisfied every check above and still did
    // not promote. `GMNTagPromoter.isUnreadable(_:)` subtracts every
    // explicable reason and runs promotion rather than reasoning about
    // it, because being untyped is not by itself evidence of anything.
    private static func _checkReadability(_ tag: GMNTag) -> [GMNValidator.Issue] {
        guard let untyped = tag.untypedPayload,
              GMNTagPromoter.isUnreadable(untyped)
        else { return [] }

        return [.unreadableParameterValue(untyped.name)]
    }

    // Which template `\pageFormat` uses depends on what it carries, so
    // the lookup above has to be told. An untyped tag's parameters are
    // what was written, in order; a typed payload restates its own
    // explicitly named, where order is irrelevant.
    private static func _parameters(of tag: GMNTag) -> [GMNTag.Parameter] {
        tag.untypedPayload?.parameters ?? tag.payload.namedParameters
    }
}
