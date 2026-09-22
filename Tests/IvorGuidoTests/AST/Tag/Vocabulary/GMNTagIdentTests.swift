// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNTagIdentTests {
}

// MARK: -

extension GMNTagIdentTests {
    @Test
    func equatable() {
        let a = GMNTag.Ident(uintValue: 1)
        let b = GMNTag.Ident(uintValue: 1)
        let c = GMNTag.Ident(uintValue: 2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_acceptsZero() {
        // guidolib accepts `\tag:0`; `0` is preserved distinctly from an
        // absent identifier (`nil`).
        #expect(GMNTag.Ident(uintValue: 0) != nil)
        #expect(GMNTag.Ident(uintValue: 0)?.uintValue == 0)
    }

    @Test
    func init_storesValue() {
        let ident = GMNTag.Ident(uintValue: 7)

        #expect(ident?.uintValue == 7)
    }

    @Test
    func isValid_acceptsAnyValue() {
        #expect(GMNTag.Ident.isValid(0))
        #expect(GMNTag.Ident.isValid(.max))
    }
}
