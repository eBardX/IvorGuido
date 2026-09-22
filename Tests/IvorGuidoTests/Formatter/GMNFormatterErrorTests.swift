// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNFormatterErrorTests {
}

// MARK: -

extension GMNFormatterErrorTests {
    @Test
    func category() {
        #expect(GMNFormatter.Error.notValidated.category?.description == "IvorGuido")
    }

    @Test
    func equatable() {
        #expect(GMNFormatter.Error.notValidated == .notValidated)
    }

    @Test
    func message_notValidated() {
        #expect(GMNFormatter.Error.notValidated.message
                == "Score must be validated before formatting; call GMNValidator.validate(_:) first")
    }
}
