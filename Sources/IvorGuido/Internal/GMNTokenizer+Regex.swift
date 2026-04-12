// © 2025–2026 John Gary Pusey (see LICENSE.md)

@preconcurrency import RegexBuilder

extension GMNTokenizer {

    // MARK: Internal Type Properties

    nonisolated(unsafe) internal static let regexFloatingValue = Regex {
        Optionally {
            signCC
        }
        decUInteger
        "."
        decUInteger
    }

    nonisolated(unsafe) internal static let regexIntegerValue = Regex {
        Optionally {
            signCC
        }
        decUInteger
    }

    nonisolated(unsafe) internal static let regexNote = Regex {
        pitch
        Optionally {
            duration
        }
    }

    nonisolated(unsafe) internal static let regexParameterName = Regex {
        name
    }

    nonisolated(unsafe) internal static let regexRest = Regex {
        "_"
        Optionally {
            duration
        }
    }

    nonisolated(unsafe) internal static let regexStringValue = Regex {
        ChoiceOf {
            doubleQuotedString
            singleQuotedString
        }
    }

    nonisolated(unsafe) internal static let regexTablature = Regex {
        tablature
        Optionally {
            duration
        }
    }

    nonisolated(unsafe) internal static let regexTagName = Regex {
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

    nonisolated(unsafe) internal static let regexUnit = Regex {
        unit
        delimiterLookahead
    }

    nonisolated(unsafe) internal static let regexVariableName = Regex {
        "$"
        name
    }
}

// MARK: -

extension GMNTokenizer {

    // MARK: Private Type Properties

    nonisolated(unsafe) private static let accidentals = Regex {
        Repeat(1...2) {
            accidentalCC
        }
    }

    nonisolated(unsafe) private static let chromatic = Regex {
        ChoiceOf {
            "ais"
            "cis"
            "dis"
            "fis"
            "gis"
        }
    }

    nonisolated(unsafe) private static let decUInteger = Regex {
        OneOrMore {
            digitCC
        }
    }

    nonisolated(unsafe) private static let delimiterLookahead = Regex {
        Lookahead {
            ChoiceOf {
                delimiterCC
                /$/
            }
        }
    }

    nonisolated(unsafe) private static let denominator = Regex {
        "/"
        decUInteger
    }

    nonisolated(unsafe) private static let dots = Regex {
        Repeat(1...3) {
            "."
        }
    }

    nonisolated(unsafe) internal static let doubleQuotedString = Regex {
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

    nonisolated(unsafe) private static let duration = Regex {
        ChoiceOf {
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
            Regex {
                numerator
                "ms"
            }
        }
    }

    nonisolated(unsafe) private static let fret = Regex {
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

    nonisolated(unsafe) private static let name = Regex {
        nameHeadCC
        ZeroOrMore {
            nameTailCC
        }
    }

    nonisolated(unsafe) private static let numerator = Regex {
        "*"
        decUInteger
    }

    nonisolated(unsafe) private static let octave = Regex {
        Optionally {
            signCC
        }
        decUInteger
    }

    nonisolated(unsafe) private static let pitch = Regex {
        pitchClass
        Optionally {
            accidentals
        }
        Optionally {
            octave
        }
    }

    nonisolated(unsafe) private static let pitchClass = Regex {
        ChoiceOf {
            chromatic
            diatonicCC
            solfege
            "empty"
        }
        delimiterLookahead
    }

    nonisolated(unsafe) internal static let singleQuotedString = Regex {
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

    nonisolated(unsafe) private static let solfege = Regex {
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

    nonisolated(unsafe) private static let tablature = Regex {
        "s"
        tabStringCC
        fret
    }

    nonisolated(unsafe) private static let unit = Regex {
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

    private static let accidentalCC = CharacterClass(.anyOf("#&"))
    private static let delimiterCC  = letterCC.inverted
    private static let diatonicCC   = CharacterClass("a"..."h")
    private static let digitCC      = CharacterClass("0"..."9")
    private static let letterCC     = CharacterClass("A"..."Z",
                                                     "a"..."z")
    private static let nameHeadCC   = letterCC.union(.anyOf("_"))
    private static let nameTailCC   = nameHeadCC.union(digitCC)
    private static let signCC       = CharacterClass(.anyOf("-+"))
    private static let tabStringCC  = CharacterClass("1"..."6")
}
