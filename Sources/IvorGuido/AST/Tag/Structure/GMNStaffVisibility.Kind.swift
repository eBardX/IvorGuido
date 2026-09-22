// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNStaffVisibility {

    // MARK: Public Nested Types

    /// Which way a ``GMNStaffVisibility`` switches the staff.
    public enum Kind {
        /// The staff is hidden from here on (`\staffOff`).
        case off

        /// The staff is shown from here on (`\staffOn`).
        case on
    }
}

// MARK: -

extension GMNStaffVisibility.Kind {

    // MARK: Internal Instance Properties

    // The tag name this kind is written as. Neither has an alias.
    internal var tagName: String {
        switch self {
        case .off:
            "staffOff"

        case .on:
            "staffOn"
        }
    }
}

// MARK: - Equatable

extension GMNStaffVisibility.Kind: Equatable {
}

// MARK: - Sendable

extension GMNStaffVisibility.Kind: Sendable {
}
