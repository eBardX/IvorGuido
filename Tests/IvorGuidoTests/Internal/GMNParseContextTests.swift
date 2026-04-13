// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing

struct GMNParseContextTests {
}

// MARK: -

extension GMNParseContextTests {
    @Test
    func init_defaults() {
        let context = GMNParseContext()

        #expect(context.lastDuration == fdur(1, 4))
        #expect(context.lastOctave == 4)
    }
}
