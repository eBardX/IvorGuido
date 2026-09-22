# Using IvorGuido

Take Guido Music Notation from text to a validated syntax tree, and back to
GMN text.

## Overview

IvorGuido exposes four processing types. Each is a `Sendable` value type with
a no-argument initializer and a single primary method:

 Type              | Method                | Result
:----              |:------                |:------
 ``GMNParser``     | `parse(_:)`           | `(GMNScore, [GMNParser.Diagnostic])`
 ``GMNNormalizer`` | `normalize(_:)`       | `(GMNScore, [GMNNormalizer.Change])`
 ``GMNValidator``  | `validate(_:)`        | `(GMNScore, [GMNValidator.Issue])`
 ``GMNFormatter``  | `format(_:)`          | `Data`

A ``GMNScore`` carries two Boolean state flags that enforce the order of the
pipeline:

- **`isNormalized`** — `validate(_:)` throws unless this is `true`.
- **`isValidated`** — `format(_:)` throws unless this is `true`.

So the canonical order is **parse → normalize → validate → format**:

```swift
let (parsed, diagnostics) = try GMNParser().parse(data)
let (normalized, changes) = GMNNormalizer().normalize(parsed)
let (validated, issues)   = try GMNValidator().validate(normalized)

issues.forEach { print($0.message) }

guard issues.isEmpty
else { return }

let text = try GMNFormatter().format(validated)
```

Every ``GMNValidator/Issue`` is fatal. A score that carries one is not
validated, and formatting requires a validated score; see
[Validating](#Validating).

Both `normalize(_:)` and `validate(_:)` are idempotent — calling them on a
score that is already normalized or validated returns it unchanged — so it is
always safe to run the full pipeline.

Unlike ABC notation, which groups many tunes into a tunebook, GMN describes a
**single score with multiple voices**. There is no tunebook-equivalent type:
``GMNScore`` is the shared flow type throughout the pipeline.

## Parsing

``GMNParser`` decodes UTF-8 `Data` into a ``GMNScore``:

```swift
let (score, diagnostics) = try GMNParser().parse(data)
```

Unlike ABC (which has strict and loose parse modes), GMN has **a single parse
mode**, with no equivalent of strict/loose: malformed input simply aborts.
``GMNParser/Diagnostic`` is reserved for forms GMN silently accepts rather
than for error recovery: a vestigial
`<n>` count on a rest or note name, or an unrecognized string escape passed
through verbatim. Diagnostics are always returned, never thrown; each has a
human-readable `message`:

```swift
for diagnostic in diagnostics {
    print(diagnostic.message)
}
```

Unrecoverable problems are thrown as a ``GMNParser/Error``, for example
`.invalidNote(_:)`, `.missingTagName`, `.nestedChord`, or `.trailingGarbage`.
Like all IvorGuido errors it conforms to `EnhancedError` and provides a
`message`:

```swift
do {
    let (score, _) = try GMNParser().parse(data)
} catch let error as GMNParser.Error {
    print(error.message)
}
```

### Variable pre-parsing

A GMN variable declaration (`$seq = "a/4 \slur(b c2/2)";`) can carry a string
whose content is itself GMN. The parser makes a **best-effort, one-time
attempt** to parse a string-valued variable’s body into
`GMNVariable.symbols` at the point of declaration, preserving omitted
durations and octaves exactly as written. When the body isn’t GMN (a plain
title string, for instance), `symbols` is `nil`. Splicing this stashed
fragment in at each `$variable` reference is not implemented anywhere in
IvorGuido.

Such a variable is still perfectly usable **as a tag parameter**, which is how
`$title = "My Song"` is meant to be read — substituted there by its declared
type. What it cannot do is stand in symbol position, and a score
that tries throws ``GMNParser/Error/nonSymbolVariableReference(_:)``:

```swift
try GMNParser().parse(Data(#"$x = 3; [ $x c ]"#.utf8))   // throws
try GMNParser().parse(Data(#"$x = 3; [ \beam<dy=$x>(c d) ]"#.utf8))   // fine
```

GMN rejects the first too: a variable substituted into symbol position is
read as GMN text at the point of substitution, where a bare `3` is not a
symbol. An *empty* body is a different thing — it supplies no symbols rather
than being unable to, so `$x = ""` is legal and contributes nothing.

## Normalizing

``GMNNormalizer`` canonicalizes a score’s tag spellings, returning a new score
whose `isNormalized` flag is `true`, together with a list of the changes it
applied:

```swift
let (normalized, changes) = GMNNormalizer().normalize(parsed)

for change in changes {
    print(change.message)
}
```

Normalization is a pure **AST → AST spelling** transform — it never lowers a
tag to an event or attachment. It performs two kinds of rewrite, drawn from
the aliases and renames GMN readers accept in practice rather than from the
published spec documents (which can lag):

- **Tag-name alias canonicalization** — collapsing a short or historical
  spelling to its canonical long form (`"stacc"` → `"staccato"`, `"sl"` →
  `"slur"`, `"decrescBegin"` → `"diminuendoBegin"`, and around thirty more,
  including every `Begin`/`End` form GMN recognizes).
- **Parameter renames** — `\volta`’s `m` parameter, renamed to `mark`.

Each ``GMNNormalizer/Change`` case (`canonicalizedTagName`, `renamedParameter`)
carries the affected tag name, so you can present a precise change log rather
than just a count.

`normalize(_:)` never fails. A defect no repair reaches — a required parameter
still missing, a positional parameter past the end of the tag’s template, a
value the tag’s own class cannot read — is carried through to ``GMNValidator``,
which reports it as an ``GMNValidator/Issue``. Each is judged on the repaired
shape rather than on what was written, which is why it is judged after
normalization and not at the parser; see
[Repaired or reported](#Repaired-or-reported).

## Validating

``GMNValidator`` checks a **normalized** score:

```swift
let (validated, issues) = try GMNValidator().validate(normalized)

issues.forEach { print($0.message) }

guard issues.isEmpty
else { return }

// `validated.isValidated` is true; format it.
```

- If the score has not been normalized, `validate(_:)` throws
  ``GMNValidator/Error/notNormalized``.
- If **any** issue is found, the returned score is the **input unchanged**
  (its `isValidated` flag stays `false`). Fix it and validate again.
- Otherwise the returned score has `isValidated == true` — the prerequisite
  for formatting and resolving — and its issues array is empty.

### Repaired or reported

A syntactically valid GMN score is not always semantically complete: an
unrecognized tag name is legal and becomes a no-op, and a tag written with a
missing, unknown, or unreadable parameter is legal too, even though it may
not mean what was intended. IvorGuido decides for itself how tolerant to be
about that gap, so each such case lands in one of two places.

**Repaired**, where the value is provably unread and dropping it changes
nothing. A parameter the tag does not support (`checkExist`), any parameter on
an `…End` tag, a raw identifier, a value the tag’s own reader would cast away,
a unit on a slot that cannot carry one — ``GMNNormalizer`` drops each and
records a ``GMNNormalizer/Change``, and the tag usually promotes as a result.

**Reported**, everywhere else — as a ``GMNValidator/Issue``, on the repaired
shape. Three of the five are about a tag’s parameters, and each is a case that
would otherwise render the score after silently discarding something that was
written:
``GMNValidator/Issue/missingRequiredParameter(_:_:)``,
``GMNValidator/Issue/unboundPositionalParameter(_:index:)``, and
``GMNValidator/Issue/unreadableParameterValue(_:)``. The other two are about
its body: ``GMNValidator/Issue/missingTagBody(_:)`` and
``GMNValidator/Issue/unexpectedTagBody(_:)`` — a range-form body on a tag whose
``GMNTag/RangeSetting`` is `.no`, or a missing one where it is `.only`. Neither
of those is repairable, because repairing it would mean inventing or discarding
music.

All five are fatal: a score carrying any of them is returned unvalidated, and
formatting requires a validated score.

The one thing refused outright is a `$variable` no declaration answers, on
which ``GMNParser`` throws
``GMNParser/Error/unresolvableVariableReference(_:)``.

## Formatting

``GMNFormatter`` serializes a **validated** score back to GMN-compliant UTF-8
`Data`:

```swift
let data = try GMNFormatter().format(validated)
```

If the score has not been validated, `format(_:)` throws
`GMNFormatter.Error.notValidated`. Because the lossless AST records exactly
what was written — omitted durations and octaves stay omitted, tag names keep
their round-trip-significant shape — `parse → normalize → validate → format`
reproduces the original text (modulo settled whitespace canonicalization).

## The AST model

The syntactic model is a tree of value types:

```
GMNScore
├─ variables: [GMNVariable]
└─ voices:    [GMNVoice]
   └─ symbols: [GMNSymbol]
```

``GMNSymbol`` is an enum covering everything that can appear in a voice:
`.note`, `.chord`, `.rest`, `.tablature`, `.tag`, `.variable`. Tags are
described in [The tag model](#The-tag-model) below.

A ``GMNDuration`` separates the *base* from the *dots*, so every written form
is representable: `c1/4` (a fraction base, no dots), `c.` (no base, one dot),
`c1/4.` (both). `c` (neither written) has no ``GMNDuration`` at all —
``GMNNote``’s (and ``GMNRest``’s, ``GMNTablature``’s) `duration` is `nil`,
inherited at resolve time. Leaf values are wrapped in small validating types
— ``GMNTag/Name``, ``GMNTag/Ident``, ``GMNPitch/Name``, ``GMNPitch/Octave``,
``GMNDuration/DotCount`` — each exposing a failable initializer that returns
`nil` for out-of-range input. All AST types are `Equatable` and `Sendable`.

``GMNScore`` equality compares `variables` and `voices` only; the
`isNormalized` and `isValidated` flags are metadata and are excluded.

## The tag model

``GMNTag`` is an **enum over 59 typed payloads plus two untyped lanes**,
``GMNReservedTag`` and ``GMNCustomTag``. A payload says what its tag *means*: ``GMNTempo`` has a `tempo` text and a
``GMNTempo/Metronome``; ``GMNSlur`` has a ``GMNTag/Span``, a ``GMNTag/Curve``,
and a ``GMNTag/ControlPoints``; ``GMNNoteHeads`` is one type with a `kind`
covering all five `\heads…` spellings.

```swift
switch tag {
case let .clef(clef):
    print(clef.type)            // "treble", "bass", …

case let .tempo(tempo):
    print(tempo.tempo, tempo.metronome as Any)

case let .reserved(reserved):
    print(reserved.name, reserved.parameters)

case let .custom(custom):
    print(custom.name, custom.parameters)

default:
    break
}
```

Constructs GMN writes as two tags collapse into one payload with a
``GMNTag/Span``: `\slur(c d)` is `.whole` with a body, `\slurBegin:1` is
`.begin` with ident `1`, `\slurEnd:1` is `.end`. There is no separate
`GMNSlurBegin` type and no suffix string to strip.

### Reading a tag without switching

Six forwarding properties answer for *any* case, so a consumer that only wants
the canonical name never switches over the enum at all: ``GMNTag/name``,
``GMNTag/ident``, ``GMNTag/body``, ``GMNTag/appearance`` (the `color`, `dx`,
`dy`, `size` group every tag accepts), ``GMNTag/span``, and
``GMNTag/rangeSetting``.

### The two untyped lanes, and when a tag uses one

Promotion — turning a written tag into a case — is a **total, idempotent**
function of the tag’s name and parameters. It never throws and never discards.
A tag stays untyped, intact and exactly as written, when:

- GMN does not reserve the name at all — this is ``GMNTag/custom(_:)``, and
  it is the only reason a tag lands there;
- the name is reserved but the catalog models no payload for it — `\port`,
  `\DrHoos`, and `\DrRenz`, permanently — which is ``GMNTag/reserved(_:)``;
- a parameter does not bind, is of the wrong type, or cannot be carried
  without loss — most of which the normalizer then repairs, leaving only what
  it must not touch (a `$variable`, or a name read under two types); or
- a *value* falls outside a closed vocabulary the payload can represent
  (`\slur<curve="banana">`). Promoting would re-spell it, and the parser does
  not rewrite what an author wrote.

The last two also land on ``GMNTag/reserved(_:)``, because the name is
reserved in both. **The lane is chosen by one question — does GMN reserve the
name?** — so ``GMNCustomTag`` can never carry a reserved name and
``GMNReservedTag`` can never carry an unreserved one, at any stage. “Only the
three names above stay reserved” is a property of a *normalized* score rather
than of the value, since a lossless parser has to be able to carry
`\bm<bogus=1>` before the normalizer repairs it.

That last point is why ``GMNReservedTag`` has no public initializer: its
admission rule has to be wide enough for the parser, which makes it too wide
to keep a hand-built score well formed. You read this lane; you do not write
it. ``GMNCustomTag`` is constructible, because a name GMN does not reserve
has no template and so nothing to be judged against.

Because promotion is total it is also re-runnable, and the normalizer re-runs
it after repairing a tag. One visible consequence: **a parsed score is less
typed than a normalized one.** `\staccato<0.5>` is reserved straight out of
``GMNParser`` — `0.5` is not a legal value for that slot — and becomes
``GMNTag/articulation(_:)`` only after ``GMNNormalizer`` drops the inert
parameter (reporting a ``GMNNormalizer/Change/droppedInertParameter(_:_:)``)
and promotes again. `\slurEnd<dx=2hs>` behaves the same way: a closing `…End`
tag takes no parameters at all, so the offset keeps the tag reserved until
the normalizer drops it (reporting a
``GMNNormalizer/Change/droppedSpanEndParameters(_:)``). If you construct a
score by hand, run it through the normalizer before expecting typed tags.

Neither untyped lane is an error, and neither loses anything: an untyped tag
round-trips through the formatter byte-for-byte as written. ``GMNValidator``
has nothing to say about one that it does not say about a typed tag — its two
issues are about a tag’s *body* against its ``GMNTag/RangeSetting``, and every
issue it raises is fatal.

## Building a score programmatically

You can construct the AST directly rather than parsing text:

```swift
let pitch = GMNPitch(name: .c, accidental: .omitted, octave: 4)
let note  = GMNNote(pitch: pitch, duration: nil)
let clef  = GMNTag.clef(GMNClef(type: "treble"))
let voice = GMNVoice(symbols: [.tag(clef), .note(note)])
let score = GMNScore(variables: [], voices: [voice])
```

Every payload’s initializer defaults everything GMN does not require, so
you write only what you mean — `GMNClef(type: "treble")` rather than a name
string and a positional parameter array whose order you have to look up. This
is what the typed model buys a caller who never parses any text.

A directly-constructed score has `isNormalized == false` and `isValidated ==
false`, so you must run it through the normalizer and validator before
formatting or resolving. The validator’s schema checks apply to a hand-built
tag exactly as they do to a parsed one: a payload restates its parameters by
name, and those are bound against the same template a written tag is bound
against.

### What the AST enforces, and what only a stage enforces

**The AST is not fully self-validating, and this is deliberate.** A value can
only refuse what it can see by itself. Anything that depends on the rest of the
score is enforced by the stage that mints it — and a score you built by hand
has not passed through those stages yet.

An initializer is failable exactly when the node can settle the question alone:

- **A vocabulary type whose spelling is constrained.** ``GMNTag/Name``,
  ``GMNTag/Ident``, ``GMNTag/Parameter/Name``, ``GMNVariable/Name``,
  ``GMNPitch/Octave``, ``GMNDuration/DotCount``.
- **A structure with a shape rule.** ``GMNChord`` needs at least two segments,
  and a ``GMNChord/Segment`` holds only notes and rests. ``GMNDuration``
  refuses a non-positive numerator or denominator, and ``GMNTablature`` a
  string outside `1...6`.
- **An untyped tag on the wrong lane.** ``GMNCustomTag`` requires a name GMN
  does *not* reserve, so it cannot be used as a general escape hatch;
  ``GMNReservedTag``, which holds the reserved names, cannot be constructed at
  all.
- **A required parameter left out.** ``GMNPageFormat`` needs a named page or a
  measured one, ``GMNTuplet`` needs its `format` unless it is a closing half,
  and ``GMNArticulation`` needs a `type` when its kind is
  ``GMNArticulation/Kind/bow`` — each because GMN itself requires it.
- **A closing half carrying parameters.** A tag whose `span` is
  ``GMNTag/Span/end`` takes no parameters at all: it has nowhere to put one,
  so `GMNSlur(curve: .up, span: .end)` is `nil` rather than a value whose
  curve would be dropped at emission.
- **A fraction with a zero denominator.** ``GMNDisplayDuration`` and
  ``GMNTempo/Metronome/BeatUnit`` both represent a fraction whose denominator
  must be non-zero.

Everything else is a *cross-node* invariant, and no initializer can see it:

- **A variable reference resolving.** `GMNScore(variables: [], voices:
  [GMNVoice(symbols: [.variable(“x”)])])` is constructible, normalizes,
  validates, and reports `isValidated == true` — while the same score written
  as `[$x]` is refused by ``GMNParser``. Nothing downstream of the parser
  re-checks a reference, so this is the clearest case where hand-building
  reaches a shape parsing cannot.
- **A span end matching a span begin.** Two halves pair by ``GMNTag/Ident``,
  which is a fact about the voice rather than about either tag.
- **A required parameter being present, and a value being readable.** Both are
  bound against the tag’s template by ``GMNValidator``, on the shape
  ``GMNNormalizer`` produced.
- **A tag body matching its range setting.** ``GMNValidator`` reports
  ``GMNValidator/Issue/missingTagBody(_:)`` and
  ``GMNValidator/Issue/unexpectedTagBody(_:)``.

The practical rule: **an initializer returning a value tells you that value is
well formed, not that the score containing it is.** Run the normalizer and the
validator — they are the only writers of the two gate flags, so a score
carrying either one is a score they returned.

## Error handling

Thrown errors conform to `EnhancedError` (from
[XestiTools](https://github.com/eBardX/XestiTools)): each has a `category` of
`"IvorGuido"` and a human-readable `message`.

 Type                     | Thrown by
:----                     |:---------
 ``GMNParser/Error``      | `GMNParser.parse(_:)`
 ``GMNValidator/Error``   | `GMNValidator.validate(_:)`
 ``GMNFormatter/Error``   | `GMNFormatter.format(_:)`

`normalize(_:)` does not throw at all. Results are returned rather than thrown,
and each also provides a `message`:

 Type                      | Returned by
:----                      |:-----------
 ``GMNParser/Diagnostic``  | `parse(_:)`
 ``GMNNormalizer/Change``  | `normalize(_:)`
 ``GMNValidator/Issue``    | `validate(_:)`

## Concurrency

IvorGuido is built for Swift 6 strict concurrency. Every public type — the
four processing types and the entire AST — is a `Sendable` value type, so
instances can be freely shared across tasks and actor boundaries. The
processing types hold no mutable state, so a single ``GMNParser``,
``GMNNormalizer``, ``GMNValidator``, or ``GMNFormatter`` instance can be
reused for any number of concurrent operations.
