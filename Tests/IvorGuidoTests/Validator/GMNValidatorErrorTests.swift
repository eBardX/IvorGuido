// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNValidatorErrorTests {
}

// MARK: -

extension GMNValidatorErrorTests {
    @Test
    func category() {
        #expect(GMNValidator.Error.notNormalized.category?.description == "IvorGuido")
    }

    @Test
    func equatable() {
        #expect(GMNValidator.Error.notNormalized == .notNormalized)
    }

    @Test
    func message_notNormalized() {
        #expect(GMNValidator.Error.notNormalized.message
                == "Score must be normalized before validation; call GMNNormalizer.normalize(_:) first")
    }
}
