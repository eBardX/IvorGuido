// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTokens
import XestiTools

// Every one of the eight unit spellings is also a legal parameter name, and
// the scanner breaks a tie on match length by rule order — so which token
// `hs` becomes is decided by which rule comes first, not by anything about
// the input. Reordering the two rules cannot resolve that; it only chooses
// which half breaks.
//
// What actually separates them is the character that follows: a parameter
// name is always followed by `=`, and a unit never is. These cases pin both
// directions of that, because a regression in either one is silent — a
// mis-lexed unit does not throw, it produces a tag that binds differently.
struct GMNTokenizerTests {
}

// MARK: -

extension GMNTokenizerTests {
    @Test(arguments: ["m", "cm", "mm", "in", "pt", "pc", "hs", "rl"])
    func tokenize_aBareUnitSpellingIsUnaffected(_ spelling: String) throws {
        // Not followed by `=`, so nothing here changed: a bare identifier
        // that happens to spell a unit still lexes as one, exactly as before.
        let tokenizer = GMNTokenizer(tracing: .silent)
        let tokens = try tokenizer.tokenize("\\tag<\(spelling)>")

        #expect(tokens.map(\.kind) == [.tagName,
                                       .angleBracketOpen,
                                       .unit,
                                       .angleBracketClose])
    }

    @Test
    func tokenize_aNamedLengthParameterKeepsBothItsNameAndItsUnit() throws {
        // Both halves in one input, which is the case that would fail if the
        // discrimination were done by rule order alone.
        let tokenizer = GMNTokenizer(tracing: .silent)
        let tokens = try tokenizer.tokenize("\\staffFormat<dx=5hs,mm=2cm>")

        #expect(tokens.map(\.kind) == [.tagName,
                                       .angleBracketOpen,
                                       .parameterName,
                                       .equalSign,
                                       .integerValue,
                                       .unit,
                                       .comma,
                                       .parameterName,
                                       .equalSign,
                                       .integerValue,
                                       .unit,
                                       .angleBracketClose])
    }

    @Test(arguments: ["m", "cm", "mm", "in", "pt", "pc", "hs", "rl"])
    func tokenize_aUnitSpellingAfterAValueIsStillAUnit(_ spelling: String) throws {
        // The half the rule ordering exists to protect. `\tag<2hs>` must keep
        // lexing as a value and a unit, or every length parameter in the
        // language changes meaning.
        let tokenizer = GMNTokenizer(tracing: .silent)
        let tokens = try tokenizer.tokenize("\\tag<2\(spelling)>")

        #expect(tokens.map(\.kind) == [.tagName,
                                       .angleBracketOpen,
                                       .integerValue,
                                       .unit,
                                       .angleBracketClose])
    }

    @Test(arguments: ["m", "cm", "mm", "in", "pt", "pc", "hs", "rl"])
    func tokenize_aUnitSpellingFollowedByAnEqualsSignIsAParameterName(_ spelling: String) throws {
        let tokenizer = GMNTokenizer(tracing: .silent)
        let tokens = try tokenizer.tokenize("\\tag<\(spelling)=1>")

        #expect(tokens.map(\.kind) == [.tagName,
                                       .angleBracketOpen,
                                       .parameterName,
                                       .equalSign,
                                       .integerValue,
                                       .angleBracketClose])
    }

    @Test
    func tokenize_producesExpectedTokenKinds() throws {
        let tokenizer = GMNTokenizer(tracing: .silent)
        let tokens = try tokenizer.tokenize("[c]")

        #expect(tokens.map(\.kind) == [.squareBracketOpen, .note, .squareBracketClose])
    }

    @Test
    func tracing_reflectsInitializerValue() {
        let tokenizer = GMNTokenizer(tracing: .verbose)

        #expect(tokenizer.tracing == .verbose)
    }
}
