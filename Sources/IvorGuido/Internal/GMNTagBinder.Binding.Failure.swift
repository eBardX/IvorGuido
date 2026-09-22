// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagBinder.Binding {

    // MARK: Internal Nested Types

    // Why binding stopped early.
    internal enum Failure {

        // An unnamed parameter was written at a position past the end of
        // the tag's template, so there is no name to bind it to.
        //
        // guidolib warns and `break`s — every parameter after this one
        // is discarded as well (`ARMusicalTag.cpp:101–104`).
        case unboundPositionalParameter(index: Int)
    }
}

// MARK: - Equatable

extension GMNTagBinder.Binding.Failure: Equatable {
}

// MARK: - Sendable

extension GMNTagBinder.Binding.Failure: Sendable {
}
