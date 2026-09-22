// © 2026 John Gary Pusey (see LICENSE.md)

// The guidolib parameter schema for one tag, transcribed.
//
// guidolib keeps *two* different parameter lists per tag class, and they are
// not the same list:
//
//   - `getParamsStr()` returns a single template string and is used for one
//     purpose only: binding *unnamed* parameters to names by position
//     (`ARMusicalTag::checkTagParameters`, `ARMusicalTag.cpp:85–107`). That
//     is `slots`.
//   - `fParamsTemplate` is the accumulated set of *supported* parameters,
//     built by every `setupTagParameters` call along the construction chain
//     — `ARMusicalTag::init` adds `kCommonParams` first
//     (`ARMusicalTag.cpp:50–54`), then each base and finally the class
//     itself adds its own map, each `Add` overwriting by name
//     (`TagParameterMap.cpp:130–134`). That is `supportedParameters`, and it
//     is what `checkExist`, `checkRequired`, `checkUnit`, and
//     `getParameter(_:usedefault:)` all consult.
//
// The two coincide for most tags, but not all. `\fingering` binds positions
// against `kARTextParams` (inherited from `ARText`) while supporting
// `kARFingeringParams` on top of it; `\segno` has no positional slots at all
// yet supports `kARJumpParams`; `\repeatEnd` binds against `kARBarParams`
// and supports `kARRepeatParams` as well. Keeping only `slots` would make
// the requiredness and unknown-parameter checks wrong for exactly those
// tags.
internal struct GMNTagTemplate {

    // MARK: Internal Initializers

    // Creates a template for one tag class.
    //
    // - Parameter acceptsParameters:       Whether the class descends from
    //                                      `ARMTParameter`. `false` means
    //                                      guidolib throws every written
    //                                      parameter away before binding —
    //                                      `ARFactory::addTagParameter`
    //                                      guards on
    //                                      `dynamic_cast<ARMTParameter*>`
    //                                      (`ARFactory.cpp:2012–2016`).
    // - Parameter slotSpecification:       The string the class's own
    //                                      `getParamsStr()` returns. Empty
    //                                      for the classes that override it
    //                                      to `""`.
    // - Parameter parameterSpecifications: Every template string added by
    //                                      `setupTagParameters` along the
    //                                      construction chain, base first,
    //                                      *excluding* `kCommonParams` —
    //                                      which is prepended here, exactly
    //                                      as `ARMusicalTag::init` does.
    // - Parameter clearedParameterNames:   Every name the class removes from
    //                                      the accumulated set with
    //                                      `clearTagDefaultParameter`, which
    //                                      is `TagParameterMap::Remove`
    //                                      (`ARMusicalTag.cpp:109–112`).
    //                                      Removal happens *after* the chain
    //                                      has been walked, so it takes an
    //                                      inherited parameter back out again
    //                                      — see `\title` and `\composer` in
    //                                      the registry.
    // - Parameter rangeSetting:            The class's `rangesetting`, or
    //                                      `.no` where it never assigns one
    //                                      (`ARMusicalTag.cpp:35`).
    // - Parameter alternateParameterKinds: The second C++ type the class reads
    //                                      a parameter under, for each name it
    //                                      reads twice. See
    //                                      `alternateParameterKinds` for the
    //                                      derivation.
    internal init(acceptsParameters: Bool = true,
                  slotSpecification: String,
                  parameterSpecifications: [String],
                  clearedParameterNames: [String] = [],
                  rangeSetting: GMNTag.RangeSetting,
                  alternateParameterKinds: [String: Slot.Kind] = [:]) {
        var parameters: [Slot] = []

        for specification in [Specification.common] + parameterSpecifications {
            for slot in Self.slots(from: specification) {
                if let index = parameters.firstIndex(where: { $0.name == slot.name }) {
                    parameters[index] = slot
                } else {
                    parameters.append(slot)
                }
            }
        }

        parameters.removeAll { clearedParameterNames.contains($0.name) }

        self.acceptsParameters = acceptsParameters
        self.alternateParameterKinds = alternateParameterKinds
        self.isFontAble = parameterSpecifications.contains(Specification.fontAble)
        self.rangeSetting = rangeSetting
        self.slots = Self.slots(from: slotSpecification)
        self.supportedParameters = parameters
    }

    // MARK: Internal Instance Properties

    // Whether guidolib keeps any written parameter at all.
    //
    // `ARFactory::addTagParameter` records a parameter only when the tag
    // just created is an `ARMTParameter` (`ARFactory.cpp:2012–2016`). Four
    // dispatched names build classes that descend from `ARMusicalTag`
    // directly and so silently discard everything written to them:
    // `\beamsAuto`/`\beamsFull`/`\beamsOff` (`ARBeamState`), `\newPage`
    // (`ARNewPage`), `\merge` (`ARMerge`), and `\port` (`ARTDummy`).
    //
    // Note that `\newSystem` and `\newLine` are *not* among them —
    // `ARNewSystem` is an `ARMTParameter`, so the pair of layout-break tags
    // differ here despite reading as siblings.
    internal let acceptsParameters: Bool

    // The second C++ type this tag's class reads a parameter under, keyed by
    // parameter name.
    //
    // A template declares one type per parameter and `TagParameterMap::get<T>`
    // is a `dynamic_cast` (`TagParameterMap.h:54–57`), so a value of any other
    // type reads back as null. A class may nonetheless read the same name
    // twice, and where it does, both spellings are live and neither is inert.
    // A name listed here is one this tag reads a second time, mapped to the
    // kind of that second read.
    //
    // Derived from:
    //
    // ```
    // cd src/engine/abstract
    // grep -n 'getParameter<TagParameter[A-Za-z]*>[[:space:]]*([[:space:]]*k[A-Za-z]*Str' *.cpp *.h
    // ```
    //
    // read **per class**, which yields exactly two:
    //
    //   - `key` on `\key` — `ARKey::setTagParameters` reads it as a
    //     `TagParameterString` and then, when that comes back null, as a
    //     `TagParameterInt` (`ARKey.cpp:88–96`).
    //   - `id` on `\staff` — `ARStaff::getStaffNumber()` reads it as a
    //     `TagParameterInt` and returns the sentinel `-1` when
    //     `getParameter<TagParameterString>` answers instead
    //     (`ARStaff.cpp:50–64`).
    //
    // Reading the same grep **by name**, with the class discarded, yields four
    // — `h`, `id`, `key`, `w` — and three of those are artefacts of the
    // discarding. `h` is read as a float by `ARBowing` and `ARPageFormat` and
    // as an int by `ARSymbol`, `w` as a float by `ARPageFormat` and as an int
    // by `ARSymbol`: three classes with one read each, not one class with two.
    // `ARAccolade` does declare both `getIDString()` and `getIDInt()`
    // (`ARAccolade.h:57–58`), but only the latter has a caller
    // (`GRAccolade.cpp:92`), and `ARJump`'s int read of `id` is commented out
    // entirely (`ARJump.cpp:40`) — dead accessors, not second reads. The
    // by-name set was what `GMNTagBinder.Binding` once exempted from the
    // inert-parameter repair, before being corrected to read per class; the
    // four names are recorded here so the correction is legible rather than
    // merely applied. Re-run the grep per class when a new payload is added.
    internal let alternateParameterKinds: [String: Slot.Kind]

    // Whether the tag's class descends from `ARFontAble` and therefore
    // supports `kARFontAbleParams`.
    internal let isFontAble: Bool

    // Whether the tag may carry a body, and whether it must.
    internal let rangeSetting: GMNTag.RangeSetting

    // The tag's positional slots, in declaration order — what an unnamed
    // parameter binds against, and the order the formatter emits in.
    internal let slots: [Slot]

    // Every parameter the tag supports, `kCommonParams` first, then the
    // construction chain base-first, later declarations overwriting earlier
    // ones of the same name.
    //
    // The overwrite is load-bearing: `\harmony` redeclares `dy` with a
    // default of `-1` (`kARHarmonyParams`), shadowing `kCommonParams`' `0`.
    internal let supportedParameters: [Slot]
}

// MARK: -

extension GMNTagTemplate {

    // MARK: Internal Type Properties

    // The four parameters every tag supports, from `kCommonParams`
    // (`TagParameterStrings.cpp:20`).
    //
    // These are merged into `fParamsTemplate` separately from the tag's own
    // template, which is why they normally have **no positional slot** and
    // must be written named. Two exceptions, both pinned by the registry
    // consistency test:
    //
    //   - A class that never overrides `getParamsStr()` inherits
    //     `ARMusicalTag`'s base implementation, which returns `kCommonParams`
    //     itself (`ARMusicalTag.h:61`). For `\newPage`, `\systemFormat`,
    //     `\pedalOn`, the `\heads…` family, and every `…End`, these *are* the
    //     positional slots.
    //   - A class's own template may redeclare one of the four:
    //     `kARBeamParams` opens with `U,dy,0,o`, `kARColorParams` is nothing
    //     but `color`, `kARPageFormatParams` ends with it, and the
    //     `kARTextParams` family declares `dy`.
    //
    // What does hold universally is that `kCommonParams` is never *appended*
    // to a tag's own template: `slots` is exactly what `getParamsStr()`
    // returns, no more.
    internal static let commonSlots = Self.slots(from: Specification.common)

    // MARK: Internal Type Methods

    // Parses a whole template string into slots, in declaration order.
    //
    // Transcribes `TagParameterMap::getKeys(const std::string&)`
    // (`TagParameterMap.cpp:179–189`) together with `str2tagParam`: split on
    // `;`, keep declaration order, silently drop any element that does not
    // decode.
    internal static func slots(from specification: String) -> [Slot] {
        specification.split(separator: ";",
                            omittingEmptySubsequences: false)
                     .compactMap { Slot(specification: String($0)) }
    }

    // MARK: Internal Instance Properties

    // Whether the tag has no positional slots at all, so every parameter
    // must be written named.
    internal var hasNoPositionalSlots: Bool {
        slots.isEmpty
    }

    // MARK: Internal Instance Methods

    // Returns whether the given value survives *some* read this tag performs
    // on the named parameter.
    //
    // Normally that is the one `dynamic_cast` the declared kind implies. For a
    // name in `alternateParameterKinds` it is either of two, and a value
    // matching the second is as live as one matching the first.
    //
    // A name the tag does not support at all reads as `false`: there is no
    // slot to measure against, and `checkExist` has already accounted for it.
    internal func reads(_ value: GMNTag.Parameter.Value,
                        as name: String) -> Bool {
        guard let slot = supportedParameter(named: name)
        else { return false }

        return slot.kind.accepts(value)
            || alternateParameterKinds[name]?.accepts(value) == true
    }

    // Returns whether any read this tag performs on the named parameter is of
    // the `U` kind, and so has somewhere to put a written unit.
    //
    // A unit is a field on the value rather than a class of its own, so it
    // never affects the `dynamic_cast` and guidolib's `checkUnit` merely warns
    // about a misplaced one. But an `F` or `I` field is a bare scalar, so a
    // unit written to one has no home in a typed payload and would be lost in
    // silence. `GMNTagBinder.Binding.unrepresentableParameterNames` holds such
    // a parameter back from promotion and the normalizer strips the unit from
    // the value, recording the loss.
    internal func readsAsLength(_ name: String) -> Bool {
        supportedParameter(named: name)?.kind == .length
            || alternateParameterKinds[name] == .length
    }

    // Returns the positional slot with the given name, or `nil`.
    internal func slot(named name: String) -> Slot? {
        slots.first { $0.name == name }
    }

    // Returns the supported parameter with the given name, or `nil` if the
    // tag does not support it — guidolib's `checkExist`
    // (`TagParameterMap.cpp:110–119`).
    internal func supportedParameter(named name: String) -> Slot? {
        supportedParameters.first { $0.name == name }
    }
}

// MARK: - Equatable

extension GMNTagTemplate: Equatable {
}

// MARK: - Sendable

extension GMNTagTemplate: Sendable {
}
