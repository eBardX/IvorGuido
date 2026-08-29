// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorGuido

// Sample inputs shared by more than one suite.
internal enum Fixtures {

    // Nine mechanisms that can leave a known tag name untyped, one input
    // each. Read by the two tests below — the individual cases above spell
    // their own input out rather than indexing into this, so that each one
    // reads on its own.
    //
    // Mechanism 1's input is `\DrHoos` rather than `\port<1>`, which
    // mechanism 2's repair also reaches; mechanism 7's is
    // `\beam<size=1.5cm>` rather than `\size<1.5cm>`, which is not this
    // mechanism at all.
    internal static let mechanisms = ["[\\DrHoos<inverse=1> c]",
                                      "[\\newPage<dx=2hs> c]",
                                      "[\\beam<foo>(c d)]",
                                      "[\\meter<\"4/4\",1,2,3,4,5,6,7,8> c]",
                                      "[\\key<2> c]",
                                      "$x = 1; [\\beam<dy=$x>(c d)]",
                                      "[\\beam<size=1.5cm>(c d)]",
                                      "[\\clef c]",
                                      "[\\slur<curve=\"banana\">(c d)]"]

    // The three dispatched names that stay on the `.reserved` lane
    // permanently.
    //
    // The list lives on the promoter, which needs it to tell a name that
    // has no payload from one whose payload declined — so this reads it
    // rather than restating it, and `exactlyThreeDispatchedNamesStayReserved`
    // is a test of that list rather than of a copy of it.
    internal static let namesThatStayReserved = GMNTagPromoter.namesWithoutPayload
}
