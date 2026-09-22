// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNTagBinderBindingFailureTests {
}

// MARK: -

extension GMNTagBinderBindingFailureTests {
    @Test
    func equatable() {
        let a = GMNTagBinder.Binding.Failure.unboundPositionalParameter(index: 2)
        let b = GMNTagBinder.Binding.Failure.unboundPositionalParameter(index: 2)
        let c = GMNTagBinder.Binding.Failure.unboundPositionalParameter(index: 3)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func unboundPositionalParameter_storesIndex() {
        let failure = GMNTagBinder.Binding.Failure.unboundPositionalParameter(index: 5)

        guard case let .unboundPositionalParameter(index) = failure
        else { Issue.record("Expected .unboundPositionalParameter"); return }

        #expect(index == 5)
    }
}
