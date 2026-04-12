// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single voice in a Guido Music Notation score.
public struct GMNVoice {

    // MARK: Public Initializers

    /// Creates a new voice with the provided symbols.
    ///
    /// - Parameter symbols:    The symbols that make up this voice.
    public init(symbols: [GMNSymbol]) {
        self.symbols = symbols
    }

    // MARK: Public Instance Properties

    /// The symbols that make up this voice.
    public let symbols: [GMNSymbol]
}

// MARK: -

extension GMNVoice {

    // MARK: Public Instance Methods

    /// Returns all tags in this voice whose name matches the provided name.
    ///
    /// - Parameter name:       The tag name to search for.
    /// - Returns:              All matching tags, in the order they appear.
    public func findAllTags(matching name: String) -> [GMNTag] {
        findAllTags(matching: [name])
    }

    /// Returns all tags in this voice whose name appears in the provided list.
    ///
    /// - Parameter names:      The tag names to search for.
    /// - Returns:              All matching tags, in the order they appear.
    public func findAllTags(matching names: [String]) -> [GMNTag] {
        findAllTags { names.contains($0.name) }
    }

    /// Returns all tags in this voice that satisfy the provided predicate.
    ///
    /// - Parameter predicate:  A closure that takes a tag and returns `true`
    ///                         if that tag should be included.
    /// - Returns:              All matching tags, in the order they appear.
    public func findAllTags(where predicate: (GMNTag) -> Bool) -> [GMNTag] {
        Self._findTags(symbols, true, predicate)
    }

    /// Returns the first tag in this voice whose name matches the provided
    /// name, or `nil` if no such tag exists.
    ///
    /// - Parameter name:       The tag name to search for.
    /// - Returns:              The first matching tag, or `nil`.
    public func findFirstTag(matching name: String) -> GMNTag? {
        findFirstTag(matching: [name])
    }

    /// Returns the first tag in this voice whose name appears in the provided
    /// list, or `nil` if no such tag exists.
    ///
    /// - Parameter names:      The tag names to search for.
    /// - Returns:              The first matching tag, or `nil`.
    public func findFirstTag(matching names: [String]) -> GMNTag? {
        findFirstTag { names.contains($0.name) }
    }

    /// Returns the first tag in this voice that satisfies the provided
    /// predicate, or `nil` if no such tag exists.
    ///
    /// - Parameter predicate:  A closure that takes a tag and returns `true`
    ///                         if that tag should be selected.
    /// - Returns:              The first matching tag, or `nil`.
    public func findFirstTag(where predicate: (GMNTag) -> Bool) -> GMNTag? {
        Self._findTags(symbols, false, predicate).first
    }

    // MARK: Private Type Methods

    private static func _findTags(_ symbols: [GMNSymbol],
                                  _ allTags: Bool,
                                  _ predicate: (GMNTag) -> Bool) -> [GMNTag] {
        var outTags: [GMNTag] = []

        for symbol in symbols {
            guard let tag = symbol.tagValue
            else { continue }

            if predicate(tag) {
                outTags.append(tag)

                if !allTags {
                    break
                }
            }

            let tags = _findTags(tag.symbols,
                                 allTags,
                                 predicate)

            if !tags.isEmpty {
                outTags.append(contentsOf: tags)

                if !allTags {
                    break
                }
            }
        }

        return outTags
    }
}

// MARK: - Equatable

extension GMNVoice: Equatable {
}

// MARK: - Sendable

extension GMNVoice: Sendable {
}
