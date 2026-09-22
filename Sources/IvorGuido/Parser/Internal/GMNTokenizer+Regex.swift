// © 2025–2026 John Gary Pusey (see LICENSE.md)

@preconcurrency import RegexBuilder

extension GMNTokenizer {

    // MARK: Internal Type Properties

    internal nonisolated(unsafe) static let doubleQuotedString = Regex {
        "\""
        ZeroOrMore {
            ChoiceOf {
                "\\\\"
                Regex {
                    "\\"
                    /./
                }
                CharacterClass.anyOf("\\\"").inverted
            }
        }
        "\""
    }

    internal nonisolated(unsafe) static let regexFloatingValue = Regex {
        Optionally {
            signCC
        }
        decUInteger
        "."
        decUInteger
    }

    internal nonisolated(unsafe) static let regexIntegerValue = Regex {
        Optionally {
            signCC
        }
        decUInteger
    }

    internal nonisolated(unsafe) static let regexNote = Regex {
        pitch
        Optionally {
            duration
        }
    }

    internal nonisolated(unsafe) static let regexParameterName = Regex {
        name
    }

    internal nonisolated(unsafe) static let regexRest = Regex {
        "_"
        Optionally {
            vestigialCount
        }
        Optionally {
            duration
        }
    }

    internal nonisolated(unsafe) static let regexStringValue = Regex {
        ChoiceOf {
            doubleQuotedString
            singleQuotedString
        }
    }

    internal nonisolated(unsafe) static let regexTablature = Regex {
        tablature
        Optionally {
            duration
        }
    }

    internal nonisolated(unsafe) static let regexTagName = Regex {
        ChoiceOf {
            "|"
            Regex {
                "\\"
                name
                Optionally {
                    ":"
                    decUInteger
                }
            }
        }
    }

    internal nonisolated(unsafe) static let regexUnit = Regex {
        unit
        unitDelimiterLookahead
    }

    internal nonisolated(unsafe) static let regexVariableName = Regex {
        "$"
        name
    }

    internal nonisolated(unsafe) static let singleQuotedString = Regex {
        "'"
        ZeroOrMore {
            ChoiceOf {
                "\\\\"
                Regex {
                    "\\"
                    /./
                }
                CharacterClass.anyOf("\\'").inverted
            }
        }
        "'"
    }
}

// MARK: -

extension GMNTokenizer {

    // MARK: Private Type Properties

    private static let accidentalCC = CharacterClass(.anyOf("#&"))

    private nonisolated(unsafe) static let accidentals = Regex {
        Repeat(1...2) {
            accidentalCC
        }
    }

    private nonisolated(unsafe) static let chromatic = Regex {
        ChoiceOf {
            "ais"
            "cis"
            "dis"
            "fis"
            "gis"
        }
    }

    private nonisolated(unsafe) static let decUInteger = Regex {
        OneOrMore {
            digitCC
        }
    }

    private static let delimiterCC = letterCC.inverted

    private nonisolated(unsafe) static let delimiterLookahead = Regex {
        Lookahead {
            ChoiceOf {
                delimiterCC
                /$/
            }
        }
    }

    private nonisolated(unsafe) static let denominator = Regex {
        "/"
        decUInteger
    }

    private static let diatonicCC = CharacterClass("a"..."h")

    private static let digitCC = CharacterClass("0"..."9")

    private nonisolated(unsafe) static let dots = Regex {
        Repeat(1...3) {
            "."
        }
    }

    private nonisolated(unsafe) static let duration = Regex {
        ChoiceOf {
            // Tried before the fraction/numerator alternative below: a bare
            // "*500" would otherwise already satisfy that alternative
            // (denominator and dots are both optional there), leaving a
            // trailing "ms" unconsumed.
            Regex {
                numerator
                "ms"
                Optionally {
                    dots
                }
            }
            Regex {
                ChoiceOf {
                    Regex {
                        numerator
                        Optionally {
                            denominator
                        }
                    }
                    Regex {
                        denominator
                    }
                }
                Optionally {
                    dots
                }
            }
            Regex {
                dots
            }
        }
    }

    private nonisolated(unsafe) static let fret = Regex {
        ":"
        ZeroOrMore {
            ChoiceOf {
                Regex {
                    "\\"
                    CharacterClass.anyOf(": ")
                }
                CharacterClass.anyOf(":\\\n").inverted
            }
        }
        ":"
    }

    private static let letterCC = CharacterClass("A"..."Z",
                                                 "a"..."z")

    private nonisolated(unsafe) static let name = Regex {
        nameHeadCC
        ZeroOrMore {
            nameTailCC
        }
    }

    private static let nameHeadCC = letterCC.union(.anyOf("_"))

    private static let nameTailCC = nameHeadCC.union(digitCC)

    private nonisolated(unsafe) static let numerator = Regex {
        "*"
        decUInteger
    }

    private nonisolated(unsafe) static let octave = Regex {
        Optionally {
            signCC
        }
        decUInteger
    }

    private nonisolated(unsafe) static let pitch = Regex {
        pitchClass
        Optionally {
            accidentals
        }
        Optionally {
            vestigialCount
        }
        Optionally {
            octave
        }
    }

    private nonisolated(unsafe) static let pitchClass = Regex {
        ChoiceOf {
            chromatic
            diatonicCC
            solfege
            "empty"
        }
        delimiterLookahead
    }

    private static let signCC = CharacterClass(.anyOf("-+"))

    private nonisolated(unsafe) static let solfege = Regex {
        ChoiceOf {
            "do"
            "re"
            "mi"
            "fa"
            "sol"
            "la"
            "si"
            "ti"
        }
    }

    private nonisolated(unsafe) static let tablature = Regex {
        "s"
        tabStringCC
        fret
    }

    private static let tabStringCC = CharacterClass("1"..."6")

    private nonisolated(unsafe) static let unit = Regex {
        ChoiceOf {
            "m"
            "cm"
            "mm"
            "in"
            "pt"
            "pc"
            "hs"
            "rl"
        }
    }

    private static let unitDelimiterCC = letterCC.union(.anyOf("=")).inverted

    // Every unit spelling is also a legal parameter name, and the scanner
    // resolves a tie on match length by rule order — so `hs` in `<2hs>` and
    // `m` in `<m="1.">` are the *same* ambiguity, decided the same way, and
    // reordering the two rules only moves the breakage from one to the other.
    //
    // What separates them is not the spelling but what follows it: a
    // parameter name is always followed by `=`, and a unit never is (it
    // terminates a value, so `<2hs=…>` is not a thing). Excluding `=` from
    // the unit's delimiter set therefore makes the two rules disjoint exactly
    // where they used to collide, and nowhere else. A bare identifier that
    // happens to spell a unit — `\noteFormat<mm>`, where nothing follows but
    // `>` — is untouched and still lexes as a unit, as it did before.
    private nonisolated(unsafe) static let unitDelimiterLookahead = Regex {
        Lookahead {
            ChoiceOf {
                unitDelimiterCC
                /$/
            }
        }
    }

    private nonisolated(unsafe) static let vestigialCount = Regex {
        "<"
        decUInteger
        ">"
    }
}
