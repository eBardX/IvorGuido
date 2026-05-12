// © 2025–2026 John Gary Pusey (see LICENSE.md)

@preconcurrency import RegexBuilder

extension GMNTokenizer {

    // MARK: Internal Type Properties

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
        delimiterLookahead
    }

    internal nonisolated(unsafe) static let regexVariableName = Regex {
        "$"
        name
    }
}

// MARK: -

extension GMNTokenizer {

    // MARK: Private Type Properties

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

    private nonisolated(unsafe) static let dots = Regex {
        Repeat(1...3) {
            "."
        }
    }

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

    private nonisolated(unsafe) static let duration = Regex {
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

    private nonisolated(unsafe) static let name = Regex {
        nameHeadCC
        ZeroOrMore {
            nameTailCC
        }
    }

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
