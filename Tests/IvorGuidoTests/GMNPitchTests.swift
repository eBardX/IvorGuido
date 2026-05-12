// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNPitchTests {
}

// MARK: -

extension GMNPitchTests {
    @Test
    func accidental_allCases() {
        let cases: [GMNPitch.Accidental] = [.doubleFlat, .flat, .natural, .sharp, .doubleSharp]

        #expect(cases.count == 5)

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func equatable() {
        let pitch1 = GMNPitch(name: .c, accidental: .sharp, octave: 4)
        let pitch2 = GMNPitch(name: .c, accidental: .sharp, octave: 4)
        let pitch3 = GMNPitch(name: .c, accidental: .flat, octave: 4)

        #expect(pitch1 == pitch2)
        #expect(pitch1 != pitch3)
    }

    @Test
    func equatable_accidental() {
        let acc1a = GMNPitch.Accidental.sharp
        let acc1b = GMNPitch.Accidental.sharp
        let acc2 = GMNPitch.Accidental.flat

        #expect(acc1a == acc1b)
        #expect(acc1a != acc2)
    }

    @Test
    func equatable_name() {
        let let1a = GMNPitch.Name.c
        let let1b = GMNPitch.Name.c
        let let2 = GMNPitch.Name.d

        #expect(let1a == let1b)
        #expect(let1a != let2)
    }

    @Test
    func `init`() {
        let pitch = GMNPitch(name: .f, accidental: .sharp, octave: 5)

        #expect(pitch.name == .f)
        #expect(pitch.accidental == .sharp)
        #expect(pitch.octave == 5)
    }

    @Test
    func init_differentOctaves() {
        let pitch1 = GMNPitch(name: .c, accidental: .natural, octave: 0)
        let pitch2 = GMNPitch(name: .c, accidental: .natural, octave: 8)

        #expect(pitch1.octave == 0)
        #expect(pitch2.octave == 8)
        #expect(pitch1 != pitch2)
    }

    @Test
    func name_allCases() {
        let cases: [GMNPitch.Name] = [.a, .b, .c, .d, .e, .f, .g, .empty]

        #expect(cases.count == 8)

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
