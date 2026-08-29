// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

// Rules 1–4 are licensed by `ARMusicalTag::checkTagParameters`
// (`ARMusicalTag.cpp:85–107`), which binds each unnamed parameter to the *i*-th
// name of the tag's own template and yields a name-keyed `TagParameterMap`.
// Four consequences follow: positional and named spellings are provably
// identical; parameter order carries no semantics; a duplicate name overwrites,
// last one winning; and a wrongly-typed value is inert, because
// `TagParameterMap::get<T>` is a `dynamic_cast` (`TagParameterMap.h:54–57`).
//
// Rule 6 rests on `guido.y:180`, which rewrites the `|` token to a `\bar` with
// no parameters and no ident, making the two provably identical in that case
// alone.

/// A type that formats a Guido Music Notation score as UTF-8 data.
///
/// ## Canonical form
///
/// The formatter does not reproduce the source text it was given. It emits
/// the score’s **canonical spelling**, and is free to re-spell anything Guido
/// treats as equivalent: `\bm<dy=2hs>(c d)` may come back as
/// `\beam<dy=2hs>(c d)`, and `\meter<autoBarlines="off","4/4">` as
/// `\meter<"4/4",autoBarlines="off">`. What is preserved is **meaning**, not
/// spelling.
///
/// Rules 1–4 rest on four facts about how Guido reads a tag: positional and
/// named spellings are identical; parameter order carries no meaning; a
/// duplicate name overwrites, last one winning; and a wrongly-typed value is
/// inert.
///
/// 1. **Canonical tag name.** The long form, never an alias — `\bm` is
///    emitted as `\beam`, `\rit` as `\ritardando`.
/// 2. **Positional prefix, then named.** A parameter is emitted unnamed for
///    as long as it occupies the next consecutive slot of the tag’s own
///    template, starting at slot 0. At the first gap — a slot with no
///    emitted value, whether the author omitted it or rule 5 dropped it —
///    every remaining parameter is named. So `\tempo<"Allegro",120>` stays
///    as written, while skipping `bpm` gives
///    `\tempo<"Allegro",font="Times">`.
/// 3. **Declared order.** Parameters follow the tag’s own order, then any
///    common appearance parameters (`color`, `dx`, `dy`, `size`) in their
///    declared order.
/// 4. **Duplicates collapsed**, last-wins.
/// 5. **Defaults omitted only where provably unobservable.** A parameter is
///    dropped only when nothing can tell it apart from its default. All four
///    common appearance parameters fail that test, so ``GMNTag/Appearance``
///    is always emitted as written — `\bar` and `\bar<dx=0>` are observably
///    different scores.
/// 6. **Barlines: `|` when bare, `\bar<…>` when parameterized.** The two are
///    identical in that case alone; a barline carrying parameters or an
///    identifier uses the long form.
/// 7. **Range form and `Begin`/`End` form are both preserved**, never
///    rewritten into each other.
///
/// Canonical form is **compact**, not maximally explicit.
///
/// ## Idempotence
///
/// Formatting canonical text again changes nothing: for any score `s`,
/// `format(parse(format(s))) == format(s)`. This is the property the
/// canonicalization suite measures.
public struct GMNFormatter {

    // MARK: Public Initializers

    /// Creates a new Guido Music Notation formatter.
    public init() {
    }
}

// MARK: -

extension GMNFormatter {

    // MARK: Public Instance Methods

    /// Formats the provided score as Guido Music Notation UTF-8 data.
    ///
    /// - Parameter score:  The score to format.
    ///
    /// - Returns:  The UTF-8 encoded Guido Music Notation representation of
    ///             the score.
    ///
    /// - Throws:   ``Error/notValidated`` if the score has not been
    ///             validated. Call ``GMNValidator/validate(_:)`` first.
    public func format(_ score: GMNScore) throws(Error) -> Data {
        guard score.isValidated
        else { throw Error.notValidated }

        var writer = Writer(score: score)

        return writer.writeScore()
    }
}

// MARK: - Sendable

extension GMNFormatter: Sendable {
}
