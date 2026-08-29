// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

// Binds `parameters` against the registry template for `name`. The name must
// be one guidolib dispatches.
internal func makeBinding(_ name: String,
                          _ parameters: [GMNTag.Parameter] = []) -> GMNTagBinder.Binding {
    GMNTagBinder.bind(parameters,
                      to: GMNTagTemplate.Registry.template(for: makeTagName(name),
                                                           parameters: parameters).require())
}

internal func makeChord(_ segments: [GMNChord.Segment]) -> GMNChord {
    GMNChord(segments: segments).require()
}

internal func makeChordSegment(_ symbols: [GMNSymbol]) -> GMNChord.Segment {
    GMNChord.Segment(symbols: symbols).require()
}

// Builds an untyped tag payload for a name guidolib does not dispatch.
//
// Fails — and so traps through `require()` — for a name it does, which is the
// initializer's own rule rather than the helper's: `.custom` is the
// undispatched lane.
internal func makeCustomTag(_ name: GMNTag.Name,
                            ident: GMNTag.Ident? = nil,
                            parameters: [GMNTag.Parameter] = [],
                            body: [GMNSymbol] = []) -> GMNCustomTag {
    GMNCustomTag(ident: ident,
                 name: name,
                 parameters: parameters,
                 body: body).require()
}

internal func makeDuration(_ milliseconds: UInt,
                           dots: GMNDuration.DotCount? = nil) -> GMNDuration {
    GMNDuration(milliseconds: milliseconds,
                dots: dots).require()
}

internal func makeDuration(_ numerator: UInt,
                           _ denominator: UInt,
                           dots: GMNDuration.DotCount? = nil) -> GMNDuration {
    GMNDuration(numerator: numerator,
                denominator: denominator,
                dots: dots).require()
}

internal func makeDuration(dots: GMNDuration.DotCount) -> GMNDuration {
    GMNDuration(dots: dots)
}

internal func makeNote(_ pitch: GMNPitch,
                       _ duration: GMNDuration? = nil) -> GMNNote {
    GMNNote(pitch: pitch,
            duration: duration)
}

internal func makePitch(_ name: GMNPitch.Name,
                        _ accidental: GMNPitch.Accidental,
                        _ octave: GMNPitch.Octave? = nil) -> GMNPitch {
    GMNPitch(name: name,
             accidental: accidental,
             octave: octave)
}

internal func makePitch(_ name: GMNPitch.Name,
                        _ octave: GMNPitch.Octave? = nil) -> GMNPitch {
    GMNPitch(name: name,
             accidental: .omitted,
             octave: octave)
}

// Runs promotion over a written tag, giving a test the same typed value the
// parser would have built. Falls back to whichever untyped lane fits,
// exactly as promotion does, so a name no payload claims is still
// representable here.
internal func makePromotedTag(_ name: String,
                              parameters: [GMNTag.Parameter] = [],
                              ident: GMNTag.Ident? = nil,
                              body: [GMNSymbol] = []) -> GMNTag {
    GMNTagPromoter.promote(ident: ident,
                           name: makeTagName(name),
                           parameters: parameters,
                           body: body)
}

internal func makeRest(_ duration: GMNDuration?) -> GMNRest {
    GMNRest(duration: duration)
}

internal func makeScore(_ variables: [GMNVariable] = [],
                        _ voices: [GMNVoice] = []) -> GMNScore {
    GMNScore(variables: variables,
             voices: voices)
}

internal func makeTablature(_ tabString: UInt,
                            _ fret: String,
                            _ duration: GMNDuration? = nil) -> GMNTablature {
    GMNTablature(tabString: tabString,
                 fret: fret,
                 duration: duration).require()
}

// Builds the untyped `GMNTag` case that fits `name`, whichever it is.
//
// The helper every caller of the `makeTag(_:…)` family goes through, and the
// reason none of them has to know whether the name it names is dispatched.
// One signature, not the eight overloads this replaced.
//
// The eight existed only because `ident` was positional and defaulted, so
// every combination of "which trailing arguments are present" needed its own
// entry — and `makeTag(name, [x])` picked its overload by the element type of
// the array, which is unsafe to reorder mechanically: omitting a trailing
// positional argument silently rebinds instead of failing to compile.
// Labelling them settles it: a stale call is now a build error.
internal func makeTag(_ name: GMNTag.Name,
                      ident: GMNTag.Ident? = nil,
                      parameters: [GMNTag.Parameter] = [],
                      body: [GMNSymbol] = []) -> GMNTag {
    .untyped(ident: ident,
             name: name,
             parameters: parameters,
             body: body)
}

internal func makeTagIdent(_ uintValue: UInt) -> GMNTag.Ident {
    GMNTag.Ident(uintValue)
}

internal func makeTagName(_ stringValue: String) -> GMNTag.Name {
    GMNTag.Name(stringValue)
}

internal func makeTagParameter(_ name: GMNTag.Parameter.Name,
                               _ value: GMNTag.Parameter.Value) -> GMNTag.Parameter {
    GMNTag.Parameter(name: name,
                     value: value)
}

internal func makeTagParameter(_ value: GMNTag.Parameter.Value) -> GMNTag.Parameter {
    GMNTag.Parameter(name: nil,
                     value: value)
}

// Builds a reserved untyped tag payload for a name guidolib dispatches.
//
// Reaches the internal initializer, because the type has no public one: the
// lane is readable but not constructible outside the package. `name` must be
// one guidolib dispatches, which `GMNTag.untyped(ident:name:parameters:body:)`
// enforces for real and this helper trusts its caller for.
internal func makeReservedTag(_ name: GMNTag.Name,
                              ident: GMNTag.Ident? = nil,
                              parameters: [GMNTag.Parameter] = [],
                              body: [GMNSymbol] = []) -> GMNReservedTag {
    GMNReservedTag(unchecked: ident,
                   name: name,
                   parameters: parameters,
                   body: body)
}

internal func makeVariable(_ name: GMNVariable.Name,
                           _ value: GMNVariable.Value,
                           _ symbols: [GMNSymbol]? = nil) -> GMNVariable {
    GMNVariable(name: name,
                value: value,
                symbols: symbols)
}

internal func makeVoice(_ symbols: [GMNSymbol] = []) -> GMNVoice {
    GMNVoice(symbols: symbols)
}
