// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

private import XestiTools

extension GMNFormatter {

    // MARK: Internal Nested Types

    internal struct Writer {

        // MARK: Internal Initializers

        internal init(score: GMNScore) {
            self.buffer = ""
            self.score = score
        }

        // MARK: Private Instance Properties

        private let score: GMNScore

        private var buffer: String
    }
}

// MARK: -

extension GMNFormatter.Writer {

    // MARK: Internal Instance Methods

    internal mutating func writeScore() -> Data {
        for variable in score.variables {
            _writeVariableDeclaration(variable)
        }

        _writeVoices(score.voices)

        return buffer.data(using: .utf8).require()
    }

    // MARK: Private Instance Methods

    private mutating func _writeVariableDeclaration(_ variable: GMNVariable) {
        buffer.append(formatVariableDeclaration(variable))
        buffer.append("\n")
    }

    private mutating func _writeVoices(_ voices: [GMNVoice]) {
        guard voices.count != 1
        else { buffer.append(formatVoice(voices[0])); return }

        buffer.append("{")
        buffer.append(voices.map(formatVoice).joined(separator: ", "))
        buffer.append("}")
    }
}
