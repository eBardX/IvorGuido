// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTokens

extension GMNParser {

    // MARK: Internal Nested Types

    internal struct Matcher {

        // MARK: Internal Initializers

        internal init(tokens: [Tokenizer.Token]) {
            self.tokenMatcher = TokenMatcher(tokens)
        }

        // MARK: Private Instance Properties

        private var tokenMatcher: TokenMatcher<[Tokenizer.Token]>
    }
}

// MARK: -

extension GMNParser.Matcher {

    // MARK: Internal Instance Methods

    internal mutating func matchScore() throws -> GMNScore {
        //
        // score => variables? voices
        //
        let variables = try _matchVariables()
        let voices = try _matchVoices()

        guard !tokenMatcher.hasMore
        else { throw GMNParseError.trailingGarbage }

        return GMNScore(variables: variables,
                        voices: voices)
    }

    // MARK: Private Instance Methods

    private mutating func _makeDuration(_ result: ParseDurationResult?,
                                        _ context: inout GMNParseContext) -> GMNDuration {
        guard let result
        else { return context.lastDuration }

        if let denom = result.denominator,
           let numer = result.numerator {
            if let duration = GMNDuration(numerator: numer,
                                          denominator: denom,
                                          dots: result.dots ?? 0) {
                context.lastDuration = duration
            }
        } else if let numer = result.numerator,
                  let duration = GMNDuration(milliseconds: numer) {
            context.lastDuration = duration
        } else if let dots = result.dots,    // dots > 0
                  let denom = context.lastDuration.denominator,
                  let numer = context.lastDuration.numerator,
                  let duration = GMNDuration(numerator: numer,
                                             denominator: denom,
                                             dots: dots) {
            // Dots-only: apply dots to the previous fraction duration;
            // ignored if the previous duration was milliseconds.
            context.lastDuration = duration
        }

        return context.lastDuration
    }

    private mutating func _makePitch(_ result: ParsePitchResult,
                                     _ context: inout GMNParseContext) -> GMNPitch {
        if let octave = result.octave {
            context.lastOctave = octave
        }

        return GMNPitch(name: result.name,
                        accidental: result.accidental ?? .natural,
                        octave: context.lastOctave)
    }

    private mutating func _matchChord(_ context: inout GMNParseContext) throws -> GMNSymbol? {
        //
        // chord => <curlyBracketOpen> symbol[inChord]+ (<comma> symbol[inChord]+)* <curlyBracketClose>
        //
        guard tokenMatcher.readIfMatches(.curlyBracketOpen) != nil
        else { return nil }

        var segments: [GMNChord.Segment] = []

        while true {
            var symbols: [GMNSymbol] = []
            var musicSymbolSeen = false

            while let symbol = try _matchSymbol(true, &context) {
                symbols.append(symbol)

                if symbol.isMusic {
                    guard !musicSymbolSeen
                    else { throw GMNParseError.invalidChordSegment(symbols) }

                    musicSymbolSeen = true
                }
            }

            guard musicSymbolSeen
            else { throw GMNParseError.invalidChordSegment(symbols) }

            guard let segment = GMNChord.Segment(symbols: symbols)
            else { throw GMNParseError.nestedChord }

            segments.append(segment)

            guard tokenMatcher.readIfMatches(.comma) != nil
            else { break }
        }

        try tokenMatcher.readMustMatch(.curlyBracketClose)

        return .chord(GMNChord(segments: segments))
    }

    private mutating func _matchNote(_ context: inout GMNParseContext) throws -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches([.note])
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw GMNParseError.invalidNote(token.value) }

        let note = GMNNote(pitch: _makePitch(result.pitch, &context),
                           duration: _makeDuration(result.duration, &context))

        return .note(note)
    }

    private mutating func _matchParameterUnit() throws -> GMNTag.Parameter.Unit? {
        guard let token = tokenMatcher.readIfMatches(.unit)
        else { return nil }

        guard let unit = GMNTag.Parameter.Unit(rawValue: String(token.value))
        else { throw GMNParseError.invalidParameterUnit(token.value) }

        return unit
    }

    private mutating func _matchRest(_ context: inout GMNParseContext) throws -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches([.rest])
        else { return nil }

        guard let result = parseRest(token.value)
        else { throw GMNParseError.invalidRest(token.value) }

        let rest = GMNRest(duration: _makeDuration(result.duration, &context))

        return .rest(rest)
    }

    private mutating func _matchSymbol(_ inChord: Bool,
                                       _ context: inout GMNParseContext) throws -> GMNSymbol? {
        //
        // symbol => chord | <note> | <rest> | <tablature> | tag | <variableName>
        //
        if tokenMatcher.nextMatches(.curlyBracketOpen) {
            guard !inChord
            else { throw GMNParseError.nestedChord }

            return try _matchChord(&context)
        }

        if tokenMatcher.nextMatches(.note) {
            return try _matchNote(&context)
        }

        if tokenMatcher.nextMatches(.rest) {
            return try _matchRest(&context)
        }

        if tokenMatcher.nextMatches(.tablature) {
            return try _matchTablature(&context)
        }

        if tokenMatcher.nextMatches(.tagName) {
            return try _matchTag(inChord, &context)
        }

        if tokenMatcher.nextMatches(.variableName) {
            return try _matchVariable()
        }

        return nil
    }

    private mutating func _matchTablature(_ context: inout GMNParseContext) throws -> GMNSymbol? {
        guard let token = tokenMatcher.readIfMatches(.tablature)
        else { return nil }

        guard let result = parseTablature(token.value)
        else { throw GMNParseError.invalidTablature(token.value) }

        let tablature = GMNTablature(tabString: result.tabString,
                                     fret: result.fret,
                                     duration: _makeDuration(result.duration, &context))

        return .tablature(tablature)
    }

    private mutating func _matchTag(_ inChord: Bool,
                                    _ context: inout GMNParseContext) throws -> GMNSymbol? {
        //
        // tag => <tagName> (<angleBracketOpen> tagParameters <angleBracketClose>)? (<roundBracketOpen> symbol+ <roundBracketClose>)?
        //
        guard let token = tokenMatcher.readIfMatches(.tagName)
        else { return nil }

        let (name, ident) = splitTagNameIdent(token.value)

        let parameters: [GMNTag.Parameter]

        if tokenMatcher.readIfMatches(.angleBracketOpen) != nil {
            parameters = try _matchTagParameters()

            try tokenMatcher.readMustMatch(.angleBracketClose)
        } else {
            parameters = []
        }

        var symbols: [GMNSymbol] = []

        if tokenMatcher.readIfMatches(.roundBracketOpen) != nil {
            while let symbol = try _matchSymbol(inChord, &context) {
                symbols.append(symbol)
            }

            try tokenMatcher.readMustMatch(.roundBracketClose)
        } else {
            symbols = []
        }

        return .tag(GMNTag(name: name,
                           ident: ident,
                           parameters: parameters,
                           symbols: symbols))
    }

    private mutating func _matchTagParameter() throws -> GMNTag.Parameter? {
        //
        // tagParameter => (<parameterName> <equalSign>)? tagValue
        //
        let name: String?

        if let token = tokenMatcher.readIfMatches(.parameterName) {
            try tokenMatcher.readMustMatch(.equalSign)

            name = String(token.value)
        } else {
            name = nil
        }

        return try _matchTagValue(name)
    }

    private mutating func _matchTagParameters() throws -> [GMNTag.Parameter] {
        //
        // tagParameters => tagParameter (<comma> tagParameter)*
        //
        var params: [GMNTag.Parameter] = []

        while let param = try _matchTagParameter() {
            params.append(param)

            guard tokenMatcher.readIfMatches(.comma) != nil
            else { break }
        }

        return params
    }

    private mutating func _matchTagValue(_ name: String?) throws -> GMNTag.Parameter? {
        //
        // tagValue => <floatingValue> <unit>?
        //           | <integerValue> <unit>?
        //           | <parameterName>
        //           | <stringValue>
        //           | <variableName>
        //
        if let token = tokenMatcher.readIfMatches(.floatingValue) {
            guard let value = Double(token.value)
            else { throw GMNParseError.invalidNumber(token.value) }

            let unit = try _matchParameterUnit()

            return .floating(name, value, unit)
        }

        if let token = tokenMatcher.readIfMatches(.integerValue) {
            guard let value = Int(token.value)
            else { throw GMNParseError.invalidNumber(token.value) }

            let unit = try _matchParameterUnit()

            return .integer(name, value, unit)
        }

        if let token = tokenMatcher.readIfMatches(.parameterName) {
            return .parameter(name, String(token.value))
        }

        if let token = tokenMatcher.readIfMatches(.stringValue) {
            guard let cvtValue = convertString(token.value)
            else { throw GMNParseError.invalidString(token.value) }

            return .string(name, cvtValue)
        }

        if let token = tokenMatcher.readIfMatches(.variableName) {
            return .variable(name, String(token.value))
        }

        return nil
    }

    private mutating func _matchVariable() throws -> GMNSymbol {
        try .variable(_matchVariableName())
    }

    private mutating func _matchVariableDeclaration() throws -> GMNVariable {
        //
        // variableDeclaration => <variableName> <equalSign> <floatingValue> <semicolon>
        //                     | <variableName> <equalSign> <integerValue> <semicolon>
        //                     | <variableName> <equalSign> <stringValue> <semicolon>
        //
        let name = try _matchVariableName()

        try tokenMatcher.readMustMatch(.equalSign)

        guard let value = try _matchVariableValue()
        else { throw GMNParseError.missingVariableValue }

        try tokenMatcher.readMustMatch(.semicolon)

        return GMNVariable(name: name,
                           value: value)
    }

    private mutating func _matchVariableName() throws -> String {
        try String(tokenMatcher.readMustMatch(.variableName).value)
    }

    private mutating func _matchVariables() throws -> [GMNVariable] {
        //
        // variables => variableDeclaration+
        //
        var variables: [GMNVariable] = []

        while tokenMatcher.nextMatches(.variableName) {
            try variables.append(_matchVariableDeclaration())
        }

        return variables
    }

    private mutating func _matchVariableValue() throws -> GMNVariable.Value? {
        if let token = tokenMatcher.readIfMatches(.floatingValue) {
            guard let cvtValue = Double(token.value)
            else { throw GMNParseError.invalidNumber(token.value) }

            return .floating(cvtValue)
        }

        if let token = tokenMatcher.readIfMatches(.integerValue) {
            guard let cvtValue = Int(token.value)
            else { throw GMNParseError.invalidNumber(token.value) }

            return .integer(cvtValue)
        }

        if let token = tokenMatcher.readIfMatches(.stringValue) {
            guard let cvtValue = convertString(token.value)
            else { throw GMNParseError.invalidString(token.value) }

            return .string(cvtValue)
        }

        return nil
    }

    private mutating func _matchVoice() throws -> GMNVoice {
        //
        // voice => <squareBracketOpen> symbol* <squareBracketClose>
        //
        var symbols: [GMNSymbol] = []

        try tokenMatcher.readMustMatch(.squareBracketOpen)

        var context = GMNParseContext()

        while let symbol = try _matchSymbol(false, &context) {
            symbols.append(symbol)
        }

        try tokenMatcher.readMustMatch(.squareBracketClose)

        return GMNVoice(symbols: symbols)
    }

    private mutating func _matchVoices() throws -> [GMNVoice] {
        //
        // voices => <curlyBracketOpen> (voice (<comma> voice)*) <curlyBracketClose>
        //         | voice
        //
        var voices: [GMNVoice] = []

        if tokenMatcher.readIfMatches(.curlyBracketOpen) != nil {
            while !tokenMatcher.nextMatches(.curlyBracketClose) {
                try voices.append(_matchVoice())

                tokenMatcher.readIfMatches(.comma)
            }

            try tokenMatcher.readMustMatch(.curlyBracketClose)
        } else {
            try voices.append(_matchVoice())
        }

        return voices
    }
}
