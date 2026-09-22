// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Type Aliases

internal typealias ParseDurationResult = (numerator: UInt?, denominator: UInt?, dots: UInt?)
internal typealias ParseNoteResult = (pitch: ParsePitchResult, duration: ParseDurationResult?)
internal typealias ParsePitchResult = (name: GMNPitch.Name, accidental: GMNPitch.Accidental?, octave: GMNPitch.Octave?)
internal typealias ParseRestResult = (String, duration: ParseDurationResult?)
internal typealias ParseTablatureResult = (tabString: UInt, fret: (value: String, unrecognizedEscape: String?), duration: ParseDurationResult?)

// MARK: Internal Functions

internal func convertString(_ tidyInput: Substring) -> (value: String, unrecognizedEscape: String?)? {
    var reader = SequenceReader<Substring>(tidyInput)

    guard let delimiter = reader.read()
    else { return nil }

    var delimiterSeen = false
    var cvtValue = ""
    var unrecognizedEscape: String?

    while let chr = reader.read(), !delimiterSeen {
        if chr == "\\" {
            guard let (cvtChr, escape) = _convertEscapedCharacter(&reader)
            else { return nil }

            cvtValue += cvtChr

            if unrecognizedEscape == nil {
                unrecognizedEscape = escape
            }
        } else if chr != delimiter {
            cvtValue.append(chr)
        } else {
            delimiterSeen = true
        }
    }

    return delimiterSeen && !reader.hasMore ? (cvtValue, unrecognizedEscape) : nil
}

internal func parseDuration(_ tidyInput: Substring) -> ParseDurationResult? {
    //
    // One of:
    //
    //  *<numerator>
    //  *<numerator><dots>
    //  *<numerator>/<denominator>
    //  *<numerator>/<denominator><dots>
    //  *<numerator>ms
    //  *<numerator>ms<dots>
    //
    if tidyInput.hasPrefix("*") {
        let stext = tidyInput.dropFirst()
        let result1 = stext.splitBeforeFirst(".")

        if result1.head.hasSuffix("ms") {
            guard let ms = _parseMilliseconds(result1.head.dropLast(2)),
                  let dots = _parseDots(result1.tail)
            else { return nil }

            if dots > 0 {
                return (ms, nil, dots)
            }

            return (ms, nil, nil)
        }

        let result2 = result1.head.splitBeforeFirst("/")

        guard let (numer, denom) = _parseFraction(result2.head,
                                                  result2.tail?.dropFirst()),
              let dots = _parseDots(result1.tail)
        else { return nil }

        if dots > 0 {
            return (numer, denom, dots)
        }

        return (numer, denom, nil)
    }

    //
    // One of:
    //
    //  /<denominator>
    //  /<denominator><dots>
    //
    //
    if tidyInput.hasPrefix("/") {
        let result = tidyInput.dropFirst().splitBeforeFirst(".")

        guard let (numer, denom) = _parseFraction(nil, result.head),
              let dots = _parseDots(result.tail)
        else { return nil }

        if dots > 0 {
            return (numer, denom, dots)
        }

        return (numer, denom, nil)
    }

    //
    // <dots>
    //
    guard let dots = _parseDots(tidyInput),
          dots > 0
    else { return nil }

    return (nil, nil, dots)
}

internal func parseNote(_ tidyInput: Substring) -> ParseNoteResult? {
    let result = tidyInput.splitBeforeFirst(durationCS)
    let ptext = result.head

    guard let pitch = parsePitch(ptext)
    else { return nil }

    guard let dtext = result.tail
    else { return (pitch, nil) }

    return (pitch, parseDuration(dtext))
}

internal func parsePitch(_ tidyInput: Substring) -> ParsePitchResult? {
    let cleanInput = _stripVestigialCount(tidyInput)
    let result1 = cleanInput.splitBeforeFirst(octaveCS)
    let result2 = result1.head.splitBeforeFirst(accidentalCS)

    guard let (name, impliedSharp) = pitchNames[result2.head]
    else { return nil }

    let accidental: GMNPitch.Accidental?
    let octave: GMNPitch.Octave?

    if impliedSharp {
        accidental = .impliedSharp
    } else if let atext = result2.tail {
        accidental = pitchAccidentals[atext]
    } else {
        accidental = nil
    }

    if let otext = result1.tail {
        guard let intValue = Int(otext),
              let value = GMNPitch.Octave(intValue: intValue)
        else { return nil }

        octave = value
    } else {
        octave = nil
    }

    return (name, accidental, octave)
}

internal func parseRest(_ tidyInput: Substring) -> ParseRestResult? {
    let result = tidyInput.splitBeforeFirst(durationCS)
    let rtext = _stripVestigialCount(result.head)

    guard let rest = (rtext == "_" ? String(rtext) : nil)
    else { return nil }

    guard let dtext = result.tail
    else { return (rest, nil) }

    return (rest, parseDuration(dtext))
}

internal func parseTablature(_ tidyInput: Substring) -> ParseTablatureResult? {
    guard tidyInput.hasPrefix("s")
    else { return nil }

    let result1 = tidyInput.dropFirst().splitBeforeFirst(durationCS)
    let result2 = result1.head.splitBeforeFirst(":")

    guard let tabString = UInt(result2.head),
          let ftext = result2.tail,
          let fret = _convertFret(ftext)
    else { return nil }

    guard let dtext = result1.tail
    else { return (tabString, fret, nil) }

    return (tabString, fret, parseDuration(dtext))
}

internal func splitTagNameIdent(_ tidyInput: Substring) -> (GMNTag.Name, GMNTag.Ident?) {
    let result = tidyInput.splitBeforeFirst(":")
    let nameText = result.head.hasPrefix("\\") ? result.head.dropFirst() : result.head
    let name = GMNTag.Name(String(nameText))

    if let itext = result.tail?.dropFirst(),
       let identValue = UInt(itext) {
        return (name, GMNTag.Ident(identValue))
    }

    return (name, nil)
}

// MARK: Private Type Aliases

private typealias PitchNameResult = (name: GMNPitch.Name, impliedSharp: Bool)

// MARK: Private Constants

private let accidentalCS: Set<Character> = ["#", "&"]

private let dots: [Substring: UInt] = [".": 1,
                                       "..": 2,
                                       "...": 3]

private let durationCS: Set<Character> = [".", "*", "/"]
private let octaveCS: Set<Character>   = ["-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

private let pitchAccidentals: [Substring: GMNPitch.Accidental] = ["&": .flat,
                                                                  "&&": .doubleFlat,
                                                                  "#": .sharp,
                                                                  "##": .doubleSharp]

private let pitchNames: [Substring: PitchNameResult] = ["a": (.a, false),
                                                        "ais": (.ais, true),
                                                        "b": (.b, false),
                                                        "c": (.c, false),
                                                        "cis": (.cis, true),
                                                        "d": (.d, false),
                                                        "dis": (.dis, true),
                                                        "do": (.do, false),
                                                        "e": (.e, false),
                                                        "empty": (.empty, false),
                                                        "f": (.f, false),
                                                        "fa": (.fa, false),
                                                        "fis": (.fis, true),
                                                        "g": (.g, false),
                                                        "gis": (.gis, true),
                                                        "h": (.h, false),
                                                        "la": (.la, false),
                                                        "mi": (.mi, false),
                                                        "re": (.re, false),
                                                        "si": (.si, false),
                                                        "sol": (.sol, false),
                                                        "ti": (.ti, false)]

// MARK: Private Functions

private func _convertEscapedCharacter(_ reader: inout SequenceReader<Substring>) -> (value: String, unrecognizedEscape: String?)? {
    guard let chr = reader.read()
    else { return nil }

    switch chr {
    case " ",
         ";",
         "'",
         "\"",
         "\\":
        return (String(chr), nil)

    case "n":
        return ("\u{0a}", nil)

    default:
        // guidolib's own `unescape()` never fails on an unrecognized escape —
        // it passes the backslash and the following character through unchanged.
        let escape = "\\\(chr)"

        return (escape, escape)
    }
}

private func _convertFret(_ tidyInput: Substring) -> (value: String, unrecognizedEscape: String?)? {
    var reader = SequenceReader<Substring>(tidyInput)

    guard let delimiter = reader.read()
    else { return nil }

    var cvtValue = ""
    var unrecognizedEscape: String?

    while let chr = reader.read() {
        if chr == "\\" {
            guard let (cvtChr, escape) = _convertEscapedCharacter(&reader)
            else { return nil }

            cvtValue += cvtChr

            if unrecognizedEscape == nil {
                unrecognizedEscape = escape
            }
        } else if chr != delimiter {
            cvtValue.append(chr)
        } else {
            return (cvtValue, unrecognizedEscape)
        }
    }

    return nil
}

private func _parseDots(_ tidyInput: Substring?) -> UInt? {
    if let tidyInput {
        dots[tidyInput]
    } else {
        0       // no dots, success
    }
}

private func _parseFraction(_ ntext: Substring?,
                            _ dtext: Substring?) -> (UInt, UInt)? {
    var numerator: UInt = 1

    if let ntext {
        guard let nvalue = UInt(ntext)
        else { return nil }

        numerator = nvalue
    }

    var denominator: UInt = 1

    if let dtext {
        guard let dvalue = UInt(dtext)
        else { return nil }

        denominator = dvalue
    }

    return (numerator, denominator)
}

private func _parseMilliseconds(_ tidyInput: Substring?) -> UInt? {
    if let tidyInput {
        UInt(tidyInput)
    } else {
        nil
    }
}

private func _stripVestigialCount(_ tidyInput: Substring) -> Substring {
    // Discards the vestigial `<n>` count suffix on rests (`_<4>`) and note
    // names (`c<3>`): dead grammar in guidolib itself, whose own semantic
    // actions never reference the captured number either.
    guard let openIndex = tidyInput.firstIndex(of: "<"),
          let closeIndex = tidyInput[openIndex...].firstIndex(of: ">")
    else { return tidyInput }

    var cleanInput = tidyInput

    cleanInput.removeSubrange(openIndex...closeIndex)

    return cleanInput
}
