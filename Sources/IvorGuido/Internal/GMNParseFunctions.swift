// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Types

internal typealias ParseDurationResult = (numerator: UInt?, denominator: UInt?, dots: UInt?)
internal typealias ParseNoteResult = (pitch: ParsePitchResult, duration: ParseDurationResult?)
internal typealias ParsePitchResult = (name: GMNPitch.Name, accidental: GMNPitch.Accidental?, octave: GMNPitch.Octave?)
internal typealias ParseRestResult = (String, duration: ParseDurationResult?)
internal typealias ParseTablatureResult = (tabString: UInt, fret: String, duration: ParseDurationResult?)

// MARK: Internal Functions

internal func convertString(_ tidyInput: Substring) -> String? {
    var reader = SequenceReader<Substring>(tidyInput)

    guard let delimiter = reader.read()
    else { return nil }

    var delimiterSeen = false
    var cvtValue = ""

    while let chr = reader.read(), !delimiterSeen {
        if chr == "\\" {
            guard let cvtChr = _convertEscapedCharacter(&reader)
            else { return nil }

            cvtValue.append(cvtChr)
        } else if chr != delimiter {
            cvtValue.append(chr)
        } else {
            delimiterSeen = true
        }
    }

    return delimiterSeen && !reader.hasMore ? cvtValue : nil
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
    //
    if tidyInput.hasPrefix("*") {
        let stext = tidyInput.dropFirst()

        if stext.hasSuffix("ms") {
            guard let ms = _parseMilliseconds(stext.dropLast(2))
            else { return nil }

            return (ms, nil, nil)
        }

        let result1 = stext.splitBeforeFirst(".")
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
    let result1 = tidyInput.splitBeforeFirst(octaveCS)
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
        octave = GMNPitch.Octave(otext)
    } else {
        octave = nil
    }

    return (name, accidental, octave)
}

internal func parseRest(_ tidyInput: Substring) -> ParseRestResult? {
    let result = tidyInput.splitBeforeFirst(durationCS)
    let rtext = result.head

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

internal func splitTagNameIdent(_ tidyInput: Substring) -> (String, UInt?) {
    let result = tidyInput.splitBeforeFirst(":")
    let name = String(result.head)

    if let itext = result.tail?.dropFirst(),
       let ident = UInt(itext) {
        return (name, ident)
    }

    return (name, nil)
}

// MARK: Private Types

private typealias PitchNameResult = (name: GMNPitch.Name, impliedSharp: Bool)

// MARK: Private Constants

private let accidentalCS: Set<Character> = ["#", "&"]
private let durationCS: Set<Character>   = [".", "*", "/"]
private let octaveCS: Set<Character>     = ["-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

private let dots: [Substring: UInt] = [".": 1,
                                       "..": 2,
                                       "...": 3]

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
                                                        "do": (.`do`, false),
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

private func _convertEscapedCharacter(_ reader: inout SequenceReader<Substring>) -> Character? {
    guard let chr = reader.read()
    else { return nil }

    switch chr {
    case "\"", "\\", "'":
        return chr

    case "n":
        return "\u{0a}"

    default:
        return nil
    }
}

private func _convertFret(_ tidyInput: Substring) -> String? {
    var reader = SequenceReader<Substring>(tidyInput)

    guard let delimiter = reader.read()
    else { return nil }

    var cvtValue = ""

    while let chr = reader.read() {
        if chr == "\\" {
            guard let cvtChr = _convertEscapedCharacter(&reader)
            else { return nil }

            cvtValue.append(cvtChr)
        } else if chr != delimiter {
            cvtValue.append(chr)
        } else {
            return cvtValue
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
