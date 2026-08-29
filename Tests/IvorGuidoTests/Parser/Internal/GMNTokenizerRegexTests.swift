// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

// The scanner's rules, stated one at a time. The tokenizer decides between
// overlapping rules by match length and rule order, so a regex that quietly
// stops matching something shows up there as a mis-lexed token rather than as
// an error — which is why each one is pinned on its own here.
struct GMNTokenizerRegexTests {
}

// MARK: -

extension GMNTokenizerRegexTests {
    @Test
    func regexFloatingValue_needsBothSidesOfThePoint() {
        #expect("1.5".wholeMatch(of: GMNTokenizer.regexFloatingValue) != nil)
        #expect("-1.5".wholeMatch(of: GMNTokenizer.regexFloatingValue) != nil)
        #expect("1".wholeMatch(of: GMNTokenizer.regexFloatingValue) == nil)
        #expect("1.".wholeMatch(of: GMNTokenizer.regexFloatingValue) == nil)
    }

    @Test
    func regexIntegerValue_admitsASign() {
        #expect("1".wholeMatch(of: GMNTokenizer.regexIntegerValue) != nil)
        #expect("-12".wholeMatch(of: GMNTokenizer.regexIntegerValue) != nil)
        #expect("+12".wholeMatch(of: GMNTokenizer.regexIntegerValue) != nil)
        #expect("x".wholeMatch(of: GMNTokenizer.regexIntegerValue) == nil)
    }

    @Test
    func regexNote_durationIsOptional() {
        #expect("c".wholeMatch(of: GMNTokenizer.regexNote) != nil)
        #expect("c#2*3/4.".wholeMatch(of: GMNTokenizer.regexNote) != nil)
        #expect("do".wholeMatch(of: GMNTokenizer.regexNote) != nil)
    }

    @Test
    func regexParameterName_isALetterOrUnderscoreThenWordCharacters() {
        #expect("dx".wholeMatch(of: GMNTokenizer.regexParameterName) != nil)
        #expect("_dx1".wholeMatch(of: GMNTokenizer.regexParameterName) != nil)
        #expect("1dx".wholeMatch(of: GMNTokenizer.regexParameterName) == nil)
    }

    @Test
    func regexRest_durationIsOptional() {
        #expect("_".wholeMatch(of: GMNTokenizer.regexRest) != nil)
        #expect("_*1/8".wholeMatch(of: GMNTokenizer.regexRest) != nil)
    }

    @Test
    func regexStringValue_admitsEitherQuote() {
        #expect("\"foo\"".wholeMatch(of: GMNTokenizer.regexStringValue) != nil)
        #expect("'foo'".wholeMatch(of: GMNTokenizer.regexStringValue) != nil)
        #expect("foo".wholeMatch(of: GMNTokenizer.regexStringValue) == nil)
    }

    @Test
    func regexTablature_durationIsOptional() {
        #expect("s1:4:".wholeMatch(of: GMNTokenizer.regexTablature) != nil)
        #expect("s2:x:*1/8".wholeMatch(of: GMNTokenizer.regexTablature) != nil)
    }

    @Test
    func regexUnit_isExactlyTheEightSpellings() {
        for spelling in ["m", "cm", "mm", "in", "pt", "pc", "hs", "rl"] {
            #expect(spelling.wholeMatch(of: GMNTokenizer.regexUnit) != nil)
        }

        #expect("km".wholeMatch(of: GMNTokenizer.regexUnit) == nil)
    }

    @Test
    func regexVariableName_includesTheSigil() {
        // The `$` is part of the token, not something the scanner strips
        // first — a bare name is a parameter name, not a variable.
        #expect("$x".wholeMatch(of: GMNTokenizer.regexVariableName) != nil)
        #expect("$_x1".wholeMatch(of: GMNTokenizer.regexVariableName) != nil)
        #expect("x".wholeMatch(of: GMNTokenizer.regexVariableName) == nil)
        #expect("$1x".wholeMatch(of: GMNTokenizer.regexVariableName) == nil)
    }
}
