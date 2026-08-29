// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNNormalizerChangeTests {
}

// MARK: -

extension GMNNormalizerChangeTests {
    @Test
    func equatable() {
        let a = GMNNormalizer.Change.canonicalizedTagName(makeTagName("stacc"), makeTagName("staccato"))
        let b = GMNNormalizer.Change.canonicalizedTagName(makeTagName("stacc"), makeTagName("staccato"))
        let c = GMNNormalizer.Change.canonicalizedTagName(makeTagName("sl"), makeTagName("slur"))

        #expect(a == b)
        #expect(a != c)
        #expect(a != GMNNormalizer.Change.renamedParameter(makeTagName("volta"), "m", "mark"))
    }

    @Test
    func message_canonicalizedTagName() {
        let change = GMNNormalizer.Change.canonicalizedTagName(makeTagName("stacc"), makeTagName("staccato"))

        #expect(change.message.contains("stacc"))
        #expect(change.message.contains("staccato"))
    }

    @Test
    func message_droppedParameterUnit() {
        let change = GMNNormalizer.Change.droppedParameterUnit(makeTagName("beam"), "size")

        #expect(change.message.contains("beam"))
        #expect(change.message.contains("size"))
    }

    @Test
    func message_droppedRawIdentifierParameter() {
        let change = GMNNormalizer.Change.droppedRawIdentifierParameter(makeTagName("beam"), "foo")

        #expect(change.message.contains("beam"))
        #expect(change.message.contains("foo"))
    }

    @Test
    func message_droppedSpanEndParameters() {
        let change = GMNNormalizer.Change.droppedSpanEndParameters(makeTagName("slurEnd"))

        #expect(change.message.contains("slurEnd"))
    }

    @Test
    func message_droppedUnacceptedParameters() {
        let change = GMNNormalizer.Change.droppedUnacceptedParameters(makeTagName("newPage"))

        #expect(change.message.contains("newPage"))
    }

    @Test
    func message_droppedUnsupportedParameter() {
        let change = GMNNormalizer.Change.droppedUnsupportedParameter(makeTagName("beam"), "bogus")

        #expect(change.message.contains("beam"))
        #expect(change.message.contains("bogus"))
    }

    @Test
    func message_expandedVariableReference() {
        let change = GMNNormalizer.Change.expandedVariableReference(makeTagName("beam"), "x")

        #expect(change.message.contains("beam"))
        #expect(change.message.contains("x"))
    }

    @Test
    func message_renamedParameter() {
        let change = GMNNormalizer.Change.renamedParameter(makeTagName("volta"), "m", "mark")

        #expect(change.message.contains("volta"))
        #expect(change.message.contains("mark"))
    }
}
