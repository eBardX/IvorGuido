// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

// Every spelling below is cited against the reference grammar/lexer in
// `guidolib` (`src/engine/parser/guido.y`, `guido.l`), the source of truth
// for GMN syntax.

internal func formatChord(_ chord: GMNChord) -> String {
    //
    // chord => <curlyBracketOpen> segment (<comma> segment)* <curlyBracketClose>  (guido.y)
    //
    "{" + chord.segments.map(formatSegment).joined(separator: ",") + "}"
}

internal func formatDuration(_ duration: GMNDuration?) -> String {
    //
    // duration => <numerator> <denominator>? <dots>?
    //           | <denominator> <dots>?
    //           | <dots>
    //           | <numerator> "ms"                                 (guido.y `duration`)
    //
    // A `nil` duration (nothing written at all) writes nothing; dots written
    // without a base (e.g. `c.`) still augment whatever duration a later
    // resolver stage infers.
    //
    guard let duration
    else { return "" }

    var result = ""

    if let base = duration.base {
        switch base {
        case let .fraction(numerator, denominator):
            result += "*\(numerator)"

            if denominator != 1 {
                result += "/\(denominator)"
            }

        case let .milliseconds(milliseconds):
            result += "*\(milliseconds)ms"
        }
    }

    if let dots = duration.dots {
        result += String(repeating: ".",
                         count: Int(dots.uintValue))
    }

    return result
}

internal func formatNote(_ note: GMNNote) -> String {
    formatPitch(note.pitch) + formatDuration(note.duration)
}

internal func formatPitch(_ pitch: GMNPitch) -> String {
    //
    // noteid => notename <accidentals>? <octave>?                  (guido.y `noteid`)
    //
    var result = _formatPitchName(pitch.name)

    switch pitch.accidental {
    case .doubleFlat:
        result += "&&"

    case .doubleSharp:
        result += "##"

    case .flat:
        result += "&"

    case .impliedSharp:
        break // already carried by the German chromatic pitch name itself (e.g. "cis")

    case .omitted:
        break

    case .sharp:
        result += "#"
    }

    if let octave = pitch.octave {
        result += "\(octave)"
    }

    return result
}

internal func formatRest(_ rest: GMNRest) -> String {
    //
    // rest => RESTT duration dots                                  (guido.y `rest`; `RESTT` is `_`)
    //
    "_" + formatDuration(rest.duration)
}

internal func formatSegment(_ segment: GMNChord.Segment) -> String {
    segment.symbols.map(formatSymbol).joined(separator: " ")
}

internal func formatSymbol(_ symbol: GMNSymbol) -> String {
    switch symbol {
    case let .chord(chord):
        formatChord(chord)

    case let .note(note):
        formatNote(note)

    case let .rest(rest):
        formatRest(rest)

    case let .tablature(tablature):
        formatTablature(tablature)

    case let .tag(tag):
        formatTag(tag)

    case let .variable(name):
        "$" + name.stringValue
    }
}

internal func formatTablature(_ tablature: GMNTablature) -> String {
    //
    // tab => "s" <tabString> ":" <fret> ":" duration dots           (guido.y `tab`)
    //
    "s\(tablature.tabString):" + _escapeDelimited(tablature.fret, ":") + ":" + formatDuration(tablature.duration)
}

internal func formatTag(_ tag: GMNTag) -> String {
    guard let untyped = tag.untypedPayload
    else { return formatTypedTag(tag.payload) }

    return formatUntypedTag(untyped)
}

internal func formatTagParameter(_ parameter: GMNTag.Parameter) -> String {
    _formatTagParameter(parameter.name,
                        formatTagParameterValue(parameter.value))
}

internal func formatTagParameterValue(_ value: GMNTag.Parameter.Value) -> String {
    switch value {
    case let .floating(value, unit):
        "\(value)" + (unit?.rawValue ?? "")

    case let .integer(value, unit):
        "\(value)" + (unit?.rawValue ?? "")

    case let .parameter(value):
        value

    case let .string(value):
        "\"" + _escapeDelimited(value, "\"") + "\""

    case let .variable(value):
        "$" + value.stringValue
    }
}

// Emits one typed payload in canonical form — the seven rules of
// `GMNFormatter`'s contract, in one place, driven by the tag template
// registry rather than by anything the payload itself knows.
//
// Rule 1 is the payload's canonical `name`. Rules 3 and 2 are the ordering
// and the positional prefix below. Rule 4 is free: a payload holds one value
// per parameter, so a duplicate cannot survive into it. Rule 5 is likewise
// free for now — every field a payload carries is `Optional` and absence is
// preserved, so nothing is ever dropped for equalling a default.
internal func formatTypedTag(_ payload: any GMNTagPayload) -> String {
    let name = payload.name

    var result = name.stringValue == "|" ? "|" : "\\" + name.stringValue

    if let ident = payload.ident {
        result += ":\(ident.uintValue)"
    }

    let parameters = _formatTypedTagParameters(payload)

    if !parameters.isEmpty {
        result += "<" + parameters.joined(separator: ",") + ">"
    }

    if !payload.body.isEmpty {
        result += "(" + payload.body.map(formatSymbol).joined(separator: " ") + ")"
    }

    return result
}

internal func formatUntypedTag(_ tag: any GMNUntypedTag) -> String {
    //
    // tag => <tagName> (<angleBracketOpen> tagParameters <angleBracketClose>)? (<roundBracketOpen> symbol+ <roundBracketClose>)?
    //
    // The leading `\` written before a tag name in source is stripped when
    // building `GMNTag.Name` — except the `|` bar shorthand, which is kept
    // distinct and never carries a backslash.
    //
    // Nothing here re-spells anything. An untyped tag never bound, so its
    // parameters have no slot order to be emitted in and no template to be
    // measured against: the only faithful thing to do is write back what was
    // written. The seven canonical-form rules bite on the typed cases.
    //
    var result = tag.name.stringValue == "|" ? "|" : "\\" + tag.name.stringValue

    if let ident = tag.ident {
        result += ":\(ident.uintValue)"
    }

    if !tag.parameters.isEmpty {
        result += "<" + tag.parameters.map(formatTagParameter).joined(separator: ",") + ">"
    }

    if !tag.body.isEmpty {
        result += "(" + tag.body.map(formatSymbol).joined(separator: " ") + ")"
    }

    return result
}

internal func formatVariableDeclaration(_ variable: GMNVariable) -> String {
    //
    // vardecl => varname EQUAL (STRING | signednumber | floatn) ENDVAR  (guido.y `vardecl`)
    //
    // `variable.name` no longer carries the leading `$` (`guido.l`'s
    // `variableName` token strips it on parse); reinstated here.
    //
    "$" + variable.name.stringValue + " = " + formatVariableValue(variable.value) + ";"
}

internal func formatVariableValue(_ value: GMNVariable.Value) -> String {
    switch value {
    case let .floating(value):
        "\(value)"

    case let .integer(value):
        "\(value)"

    case let .string(value):
        "\"" + _escapeDelimited(value, "\"") + "\""
    }
}

internal func formatVoice(_ voice: GMNVoice) -> String {
    //
    // voice => <squareBracketOpen> symbol* <squareBracketClose>     (guido.y `voice`)
    //
    "[" + voice.symbols.map(formatSymbol).joined(separator: " ") + "]"
}

// MARK: Private Functions

private func _escapeDelimited(_ value: String,
                              _ delimiter: Character) -> String {
    // Mirrors `_convertEscapedCharacter`'s recognized set in reverse: only
    // the delimiter, the backslash itself, and a literal newline need
    // escaping to stay well-formed and round-trippable (`guido.l`'s
    // `unescape()` recognizes `\'`, `\"`, `\\`, `\n`, `\;`, `\ `, but the
    // other two are never load-bearing for a `"`- or `:`-delimited run).
    var result = ""

    for chr in value {
        switch chr {
        case delimiter:
            result.append("\\")
            result.append(chr)

        case "\\":
            result += "\\\\"

        case "\n":
            result += "\\n"

        default:
            result.append(chr)
        }
    }

    return result
}

private func _formatPitchName(_ name: GMNPitch.Name) -> String {
    switch name {
    case .a:
        "a"

    case .ais:
        "ais"

    case .b:
        "b"

    case .c:
        "c"

    case .cis:
        "cis"

    case .d:
        "d"

    case .dis:
        "dis"

    case .do:
        "do"

    case .e:
        "e"

    case .empty:
        "empty"

    case .f:
        "f"

    case .fa:
        "fa"

    case .fis:
        "fis"

    case .g:
        "g"

    case .gis:
        "gis"

    case .h:
        "h"

    case .la:
        "la"

    case .mi:
        "mi"

    case .re:
        "re"

    case .si:
        "si"

    case .sol:
        "sol"

    case .ti:
        "ti"
    }
}

private func _formatTagParameter(_ name: GMNTag.Parameter.Name?,
                                 _ value: String) -> String {
    guard let name
    else { return value }

    return "\(name.stringValue)=\(value)"
}

// The names a typed tag's parameters are emitted in, in order (rule 3):
// the tag's own positional slots first, then anything else it supports, then
// `kCommonParams` last.
//
// The three groups are disjoint by construction. A tag that declares one of
// the four common parameters in its own template — `\beam`'s `dy`,
// `\color`'s `color` — has it among its slots already and it keeps that
// place, which is what rule 2 needs and what "common sorts last" is really
// an approximation of.
private func _formatTypedTagParameterNames(_ template: GMNTagTemplate) -> [String] {
    let commonNames = GMNTagTemplate.commonSlots.map { $0.name }

    var names = template.slots.map { $0.name }
    var seen = Set(names)

    for name in template.supportedParameters.map({ $0.name }) + commonNames where !seen.contains(name) {
        names.append(name)
        seen.insert(name)
    }

    return names
}

// Emits a typed tag's parameters per rule 2: unnamed for as long as
// each one occupies the next consecutive slot of the tag's own template
// starting at slot 0, then named for everything that follows.
//
// A slot with no value is a **gap**, and a gap ends the positional run even
// though it emits nothing — `\tempo` with `bpm` omitted must write
// `font="Times"` named, because positionally that string would bind to
// `bpm`. Getting this wrong silently corrupts the tag rather than merely
// spelling it oddly.
private func _formatTypedTagParameters(_ payload: any GMNTagPayload) -> [String] {
    guard let template = GMNTagTemplate.Registry.template(for: payload.name,
                                                          parameters: payload.namedParameters)
    else { return [] }

    let values = payload.parameterValues.merging(payload.appearance.parameterValues) { own, _ in own }

    var isPositional = true
    var result: [String] = []

    for (index, name) in _formatTypedTagParameterNames(template).enumerated() {
        let isSlot = index < template.slots.count

        guard let value = values[name]
        else {
            isPositional = isPositional && !isSlot

            continue
        }

        if isPositional, isSlot {
            result.append(formatTagParameterValue(value))
        } else {
            isPositional = false

            result.append("\(name)=" + formatTagParameterValue(value))
        }
    }

    return result
}
