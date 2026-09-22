# ``IvorGuido``

@Metadata {
    @PageColor(blue)
}

A Guido Music Notation parser, normalizer, validator, and formatter.

## Overview

The IvorGuido framework provides a [Guido Music Notation
(GMN)](https://guidodoc.grame.fr) parser, normalizer, validator, and
formatter written in Swift, with a strict-concurrency-ready, value-type API.

IvorGuido works entirely at the level of *syntax*: a **syntactic** core turns
GMN text into a typed, round-trippable abstract syntax tree (``GMNScore`` →
``GMNVoice`` → ``GMNSymbol``) and back to text, without interpreting the
music. Tags are typed too: ``GMNTag`` is an enum over 59 payload structs —
``GMNClef`` knows it has a type and a line, ``GMNTempo`` knows it has a text
and a metronome spec — with two untyped lanes for everything else:
``GMNReservedTag`` for a name GMN reserves that the catalog models no payload
for, and ``GMNCustomTag`` for a name GMN does not reserve at all.

### The pipeline

Everything flows through a small, explicit pipeline of four value types, each
a `Sendable` value type with a no-argument initializer:

 Stage     | Type              | Input → Output
:-----     |:----              |:--------------
 Parse     | ``GMNParser``     | `Data` → ``GMNScore``
 Normalize | ``GMNNormalizer`` | ``GMNScore`` → ``GMNScore`` (canonical spellings)
 Validate  | ``GMNValidator``  | ``GMNScore`` → validated ``GMNScore``
 Format    | ``GMNFormatter``  | ``GMNScore`` → `Data`

A ``GMNScore`` carries two Boolean state flags that enforce the order of the
pipeline: a score must be normalized before it can be validated, and
validated before it can be formatted. Both normalization and validation are
idempotent, so it is always safe to run the full pipeline:

```swift
import Foundation
import IvorGuido

let data = try Data(contentsOf: url)

let (parsed, diagnostics) = try GMNParser().parse(data)
let (normalized, changes) = GMNNormalizer().normalize(parsed)
let (validated, issues)   = try GMNValidator().validate(normalized)

issues.forEach { print($0.message) }

guard issues.isEmpty
else { return }

let output = try GMNFormatter().format(validated)     // back to GMN
```

Unlike ABC notation, which groups many tunes into a tunebook, GMN describes a
**single score with multiple voices** — there is no tunebook-equivalent type.

See <doc:UsingIvorGuido> for a full guide to each stage, the models, and
error handling.

## Topics

### Guides

- <doc:UsingIvorGuido>

### Processing

- ``GMNParser``
- ``GMNNormalizer``
- ``GMNValidator``
- ``GMNFormatter``

### Scores

- ``GMNScore``
- ``GMNVoice``
- ``GMNVariable``

### Symbols

- ``GMNSymbol``
- ``GMNNote``
- ``GMNRest``
- ``GMNChord``
- ``GMNTablature``
- ``GMNPitch``
- ``GMNDuration``

### Tags

``GMNTag`` is an enum over 59 typed payloads plus two untyped fallbacks,
which divide on whether GMN reserves the name. The payloads are grouped below
by their four behavioral buckets — the same classification the internal tag
promoter sorts them into.

- ``GMNTag``
- ``GMNReservedTag``
- ``GMNCustomTag``

### Tag payloads — timing and pitch

- ``GMNAccidental``
- ``GMNAlter``
- ``GMNCluster``
- ``GMNDisplayDuration``
- ``GMNGrace``
- ``GMNKey``
- ``GMNMeter``
- ``GMNMultiMeasureRest``
- ``GMNOctava``
- ``GMNTuplet``

### Tag payloads — staff and score structure

- ``GMNAccolade``
- ``GMNAuto``
- ``GMNBarFormat``
- ``GMNBarLine``
- ``GMNClef``
- ``GMNCue``
- ``GMNHarmony``
- ``GMNInstrument``
- ``GMNJump``
- ``GMNLayoutBreak``
- ``GMNMerge``
- ``GMNPageFormat``
- ``GMNRepeat``
- ``GMNShareLocation``
- ``GMNSpace``
- ``GMNStaff``
- ``GMNStaffFormat``
- ``GMNStaffVisibility``
- ``GMNSystemFormat``
- ``GMNTempo``
- ``GMNUnits``
- ``GMNVolta``

### Tag payloads — performance

- ``GMNArpeggio``
- ``GMNArticulation``
- ``GMNBreathMark``
- ``GMNDynamicRamp``
- ``GMNFingering``
- ``GMNGlissando``
- ``GMNIntensity``
- ``GMNOrnament``
- ``GMNPedal``
- ``GMNSlur``
- ``GMNTempoChange``
- ``GMNTie``
- ``GMNTremolo``

### Tag payloads — visual and text

- ``GMNBeam``
- ``GMNBeamState``
- ``GMNColor``
- ``GMNDotFormat``
- ``GMNGraphicSymbol``
- ``GMNLyrics``
- ``GMNMark``
- ``GMNNoteFormat``
- ``GMNNoteHeads``
- ``GMNRestFormat``
- ``GMNSpecial``
- ``GMNStemDirection``
- ``GMNText``
- ``GMNTitleBlock``

### Shared tag vocabulary

The value types the payloads share, factored out of the parameter groups
several tags share in common: color/offset/size, font styling, placement
above or below the staff, and the control-point families.

- ``GMNLength``
- ``GMNTag/Appearance``
- ``GMNTag/ControlPoints``
- ``GMNTag/Curve``
- ``GMNTag/Placement``
- ``GMNTag/RangeSetting``
- ``GMNTag/Span``
- ``GMNTag/TextStyle``
- ``GMNTag/Ident``
- ``GMNTag/Name``
- ``GMNTag/Parameter``
