# IvorGuido

A Guido Music Notation parser, normalizer, validator, and formatter.

## <a name="overview">Overview</a>

The IvorGuido framework provides a [Guido Music Notation
(GMN)](https://guidodoc.grame.fr) parser, normalizer, validator, and
formatter written in Swift, with a strict-concurrency-ready, value-type API.

IvorGuido works entirely at the level of *syntax*: a **syntactic** core turns
GMN text into a typed, round-trippable abstract syntax tree (`GMNScore` →
`GMNVoice` → `GMNSymbol`) and back to text, without interpreting the music.
Tags are typed too: `GMNTag` is an enum over 59 payload structs — `GMNClef`
knows it has a type and a line, `GMNTempo` knows it has a text and a
beats-per-minute spec — with two untyped lanes that carry, losslessly,
everything else: `GMNReservedTag` for a name GMN reserves that the catalog
models no payload for, and `GMNCustomTag` for a name GMN does not reserve at
all.

Everything flows through a small, explicit pipeline of four value types, each
with a no-argument initializer:

 Stage     | Type            | Input → Output
:-----     |:----            |:--------------
 Parse     | `GMNParser`     | `Data` → `GMNScore`
 Normalize | `GMNNormalizer` | `GMNScore` → `GMNScore` (canonical spellings)
 Validate  | `GMNValidator`  | `GMNScore` → validated `GMNScore`
 Format    | `GMNFormatter`  | `GMNScore` → `Data`

The pipeline is gated by two flags on `GMNScore`: a score must be normalized
before it can be validated, and validated before it can be formatted. Unlike
ABC notation, which groups many tunes into a tunebook, GMN describes a single
score with multiple voices, so there is no tunebook-equivalent type. See the
[usage guide][guide] for a full walkthrough of the API.

## <a name="quick_start">Quick Start</a>

Take GMN text from `Data` all the way back to validated, formatted text:

```swift
import Foundation
import IvorGuido

let data = try Data(contentsOf: url)

// 1. Parse GMN text into a typed AST.
let (parsed, diagnostics) = try GMNParser().parse(data)

// 2. Normalize tag-name aliases and parameter renames to their canonical form.
let (normalized, changes) = try GMNNormalizer().normalize(parsed)

// 3. Validate — tag schema conformance, and every `$variable` reference
//    resolving to a declaration.
let (validated, issues) = try GMNValidator().validate(normalized)

issues.forEach { print($0.message) }

// Every issue is fatal: a score that carries one is not validated, and the
// formatter will not accept it.
guard issues.isEmpty
else { return }

// 4. Format back to GMN text.
let output = try GMNFormatter().format(validated)
```

Each stage is independent, so you can stop at the AST or continue on to
round-trip through the formatter. For the complete story — the AST model and
error handling — see the [usage guide][guide].

## <a name="documentation">Documentation</a>

* [Using IvorGuido][guide] — a guide to using the public API, published as
  part of the DocC documentation.
* Every public declaration carries a DocC comment describing its Guido Music
  Notation behavior.
* [Release notes](RELEASE_NOTES.md) — what changed, and how to migrate.

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorGuido is available under [the MIT license][license].

[docc]:     https://www.swift.org/documentation/docc/
[guide]:    https://eBardX.github.io/ivor-packages-docs/documentation/ivorguido/usingivorguido
[license]:  https://github.com/eBardX/IvorGuido/blob/main/LICENSE.md
[refdoc]:   https://eBardX.github.io/ivor-packages-docs/documentation/ivorguido
