// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that normalizes a Guido Music Notation score to canonical form.
///
/// ## Normalization is what makes a score fully typed
///
/// ``GMNParser`` promotes only the tags that bind cleanly as written. The
/// normalizer performs the repairs that let the rest promote, then re-runs
/// promotion on the result:
///
/// - a tag-name alias is collapsed to its canonical long form;
/// - a deprecated parameter name is renamed to its current one;
/// - a `$variable` reference in tag-parameter position is substituted by its
///   declared value;
/// - a parameter of the wrong type is dropped, since such a value is inert —
///   `\staccato<0.5>` means the same as a bare `\staccato`;
/// - so is one written to a tag that keeps none, one written on an `…End`
///   tag, and a raw (unquoted) identifier, none of which anything reads;
/// - a unit written on a parameter that cannot carry one is dropped, keeping
///   the magnitude.
///
/// Each of those is something Guido provably never reads, which is what
/// licenses the repair: the score’s meaning is unchanged and the loss is
/// announced rather than silent. The one thing no repair touches is a
/// `$variable` reference no declaration answers, which has to survive to be
/// reported.
///
/// Each is reported as a ``Change``. Re-running promotion is safe because
/// promotion is a total, idempotent function of a tag’s name and parameters,
/// with the two untyped lanes as its fallback: a tag that still does not
/// bind is carried through exactly as written.
///
/// The visible consequence is that **a parsed score is less typed than a
/// normalized one**. A consumer that switches over ``GMNTag`` should read a
/// score whose ``GMNScore/isNormalized`` is `true`.
///
/// ## What it does not do
///
/// Normalization never fails. Three defects survive every repair above — a
/// required parameter still missing, an unnamed parameter past the end of the
/// tag’s template, and a value the tag’s own class cannot read — and each is
/// carried through to ``GMNValidator``, which reports it as an
/// ``GMNValidator/Issue``. Judging is the validator’s job; this stage only
/// repairs, so a caller that wants a diagnosis calls
/// ``GMNValidator/validate(_:)`` on what it gets back.
///
/// A tag carrying one of those three stays on an untyped lane, which is what
/// gives the validator something to read. Otherwise the only untyped tags left
/// after normalization are the ones that belong there: ``GMNTag/custom(_:)``,
/// whose name GMN does not reserve at all, and ``GMNTag/reserved(_:)``,
/// which is down to the three reserved names no typed payload claims —
/// `\port`, `\DrHoos`, and `\DrRenz`.
public struct GMNNormalizer {

    // MARK: Public Initializers

    /// Creates a new Guido Music Notation normalizer.
    public init() {
    }
}

// MARK: -

extension GMNNormalizer {

    // MARK: Public Instance Methods

    /// Returns a copy of the provided score normalized to canonical form,
    /// along with an array describing each change applied.
    ///
    /// Normalization is idempotent: calling `normalize(_:)` on an
    /// already-normalized score returns it immediately with an empty
    /// changes array.
    ///
    /// - Parameter score:  The score to normalize.
    ///
    /// - Returns:  A tuple of a new ``GMNScore`` whose
    ///             ``GMNScore/isNormalized`` is `true`, and an array of
    ///             ``Change`` values describing each normalization applied.
    ///
    ///             A defect no repair reaches is carried through rather than
    ///             refused; call ``GMNValidator/validate(_:)`` on the result to
    ///             have it reported.
    public func normalize(_ score: GMNScore) -> (GMNScore, [Change]) {
        guard !score.isNormalized
        else { return (score, []) }

        var editor = Editor(score: score)

        return editor.editScore()
    }
}

// MARK: - Sendable

extension GMNNormalizer: Sendable {
}
