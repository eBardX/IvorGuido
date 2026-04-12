// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

@Suite
struct GMNPitchTests {
}

// MARK: -

extension GMNPitchTests {
    @Test
    func test_accidental_allCases() {
        let cases: [GMNPitch.Accidental] = [.doubleFlat, .flat, .natural, .sharp, .doubleSharp]

        #expect(cases.count == 5)

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func test_equatable() {
        let pitch1 = GMNPitch(letter: .c, accidental: .sharp, octave: 4)
        let pitch2 = GMNPitch(letter: .c, accidental: .sharp, octave: 4)
        let pitch3 = GMNPitch(letter: .c, accidental: .flat, octave: 4)

        #expect(pitch1 == pitch2)
        #expect(pitch1 != pitch3)
    }

    @Test
    func test_equatable_accidental() {
        let acc1a = GMNPitch.Accidental.sharp
        let acc1b = GMNPitch.Accidental.sharp
        let acc2 = GMNPitch.Accidental.flat

        #expect(acc1a == acc1b)
        #expect(acc1a != acc2)
    }

    @Test
    func test_equatable_letter() {
        let let1a = GMNPitch.Letter.c
        let let1b = GMNPitch.Letter.c
        let let2 = GMNPitch.Letter.d

        #expect(let1a == let1b)
        #expect(let1a != let2)
    }

    @Test
    func test_init() {
        let pitch = GMNPitch(letter: .f, accidental: .sharp, octave: 5)

        #expect(pitch.letter == .f)
        #expect(pitch.accidental == .sharp)
        #expect(pitch.octave == 5)
    }

    @Test
    func test_init_differentOctaves() {
        let pitch1 = GMNPitch(letter: .c, accidental: .natural, octave: 0)
        let pitch2 = GMNPitch(letter: .c, accidental: .natural, octave: 8)

        #expect(pitch1.octave == 0)
        #expect(pitch2.octave == 8)
        #expect(pitch1 != pitch2)
    }

    @Test
    func test_letter_allCases() {
        let cases: [GMNPitch.Letter] = [.a, .b, .c, .d, .e, .f, .g, .empty]

        #expect(cases.count == 8)

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
