// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido
import Testing
import XestiTools

struct GMNAccoladeTests {
}

// MARK: -

extension GMNAccoladeTests {
    @Test
    func aStringIdentifierIsDroppedAsInert() {
        // FLIPPED IN PHASE 2. `id` was exempted from the inert-parameter
        // repair as one of four names guidolib was thought to read under two
        // C++ types. `ARAccolade` does declare both `getIDString()` and
        // `getIDInt()` (`ARAccolade.h:57–58`), but only the int accessor has a
        // caller (`GRAccolade.cpp:92`), so the string read is dead code and a
        // string here is inert like any other.
        //
        // Dropping a *required* parameter is the right answer even so: what
        // guidolib does with `id="brace"` is fall back to `0`, which is
        // indistinguishable from having written nothing.
        //
        // The drop leaves the tag short of a required parameter, which the
        // normalizer now refuses rather than leaving to the validator to
        // report. So the repair and the rejection are visible only
        // together — the score is turned away naming `id`, the parameter
        // that was written.
        expectRejected("[\\accolade<id=\"brace\",range=\"1-2\">]",
                       .missingRequiredParameter(makeTagName("accolade"), "id"))
    }

    @Test
    func canonicalNameIsAccolade() {
        #expect(GMNAccolade(id: 1, range: "1-2").name == makeTagName("accolade"))
    }

    @Test
    func equatable() {
        let a = GMNAccolade(id: 1, range: "1-2")
        let b = GMNAccolade(id: 1, range: "1-2")
        let c = GMNAccolade(id: 1, range: "1-2", type: "thinBrace")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func init_defaultsOptionalsToNil() {
        let accolade = GMNAccolade(id: 3, range: "1-4")

        #expect(accolade.appearance.isEmpty)
        #expect(accolade.body.isEmpty)
        #expect(accolade.id == 3)
        #expect(accolade.ident == nil)
        #expect(accolade.range == "1-4")
        #expect(accolade.type == nil)
    }

    @Test
    func isRejectedWithoutTheRequiredRange() {
        expectRejected("[\\accolade<1>]",
                       .missingRequiredParameter(makeTagName("accolade"), "range"))
    }

    @Test
    func promotes() throws {
        guard case let .accolade(accolade) = try normalizedTag("[\\accolade<1,\"1-2\",\"thinBrace\">]")
        else {
            Issue.record("Expected accolade tag")
            return
        }

        #expect(accolade.id == 1)
        #expect(accolade.range == "1-2")
        #expect(accolade.type == "thinBrace")
    }

    @Test
    func promotesFromTheAlias() throws {
        guard case let .accolade(accolade) = try normalizedTag("[\\accol<2,\"1-3\">]")
        else {
            Issue.record("Expected accolade tag")
            return
        }

        #expect(accolade.id == 2)
        #expect(accolade.type == nil)
    }
}
