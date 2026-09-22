// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// What every case of `GMNTag` can answer, whatever its shape.
//
// This is the forwarding surface seen from below: `GMNTag`'s public
// properties are one switch onto `payload` and then a plain member read, so
// adding a tranche adds one line to that switch rather than one line to each
// of six properties.
//
// It is also what makes the formatter's typed lane generic. A payload does
// not know how to spell itself — it exposes its canonical name and its
// parameters *keyed by the template name each one binds to*, and
// `formatTypedTag(_:)` applies the canonical-form rules against the tag
// template registry from there. No payload contains emission logic, so no
// payload can get the positional-prefix rule wrong.
internal protocol GMNTagPayload: Sendable {

    // MARK: Internal Instance Properties

    // The `kCommonParams` parameters written for this tag.
    var appearance: GMNTag.Appearance { get }

    // The symbols scoped to this tag, or empty if it has none.
    var body: [GMNSymbol] { get }

    // The numeric identifier written after this tag's name, if any.
    var ident: GMNTag.Ident? { get }

    // This tag's canonical name — long form, never an alias.
    var name: GMNTag.Name { get }

    // This tag's own parameters, keyed by the template name each binds to,
    // and omitting any the author did not write.
    //
    // `kCommonParams` is *not* included: `appearance` carries it, and
    // `formatTypedTag(_:)` merges the two. A payload that declares one of
    // the four in its own template (`\beam`'s `dy`, `\color`'s `color`) may
    // return it here, and its own value wins.
    var parameterValues: [String: GMNTag.Parameter.Value] { get }
}

// MARK: -

extension GMNTagPayload {

    // MARK: Internal Instance Properties

    // Whether this payload carries nothing a closing half could not carry.
    //
    // An `…End` tag is an `ARDummyRangeEnd`, which declares no parameters of
    // its own and reads none of `kCommonParams` either. So a
    // payload whose `span` is `.end` must hold neither — and "hold" is the
    // whole test, not "would emit", because the formatter is what would
    // silently drop the difference.
    //
    // This is stated once here and guarded by every spanning payload's
    // initializer, the same way `GMNTag.untyped(…)` states the dispatch rule
    // once for the two untyped lanes. Both halves are needed: a payload's own
    // parameters live in `parameterValues` and the four common ones live in
    // `appearance`, and the span-end repair drops both
    // (`Editor._dropSpanEndParameters`).
    internal var carriesNoParameters: Bool {
        parameterValues.isEmpty && appearance.isEmpty
    }

    // Every parameter this payload holds, written out explicitly named.
    //
    // The inverse of a builder: it turns a payload back into the list a
    // binder consumes, which is what lets a typed tag be rebuilt through
    // `GMNTagPromoter` without every payload having to know how to copy
    // itself. Order is unspecified and does not matter — a named parameter
    // binds by name, so any order produces the same binding.
    internal var namedParameters: [GMNTag.Parameter] {
        let values = parameterValues.merging(appearance.parameterValues) { own, _ in own }

        return values.map {
            GMNTag.Parameter(name: GMNTag.Parameter.Name($0.key),
                             value: $0.value)
        }
    }
}
