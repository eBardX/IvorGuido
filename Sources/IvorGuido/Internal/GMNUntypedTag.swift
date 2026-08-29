// © 2026 John Gary Pusey (see LICENSE.md)

// What the two untyped lanes have in common: a tag carried exactly as
// written, with its parameters bound to nothing.
//
// `GMNTag` has two such cases and they differ only in *why* the tag is
// untyped — ``GMNTag/reserved(_:)`` for a name guidolib dispatches that no
// payload claims, ``GMNTag/custom(_:)`` for a name guidolib does not dispatch
// at all. Every stage that repairs, formats, or inspects a written parameter
// list wants both and distinguishes neither, so it reads through here rather
// than switching twice. `GMNTag.untypedPayload` is the entry point.
//
// `parameters` is the whole of the difference from `GMNTagPayload`: a typed
// payload restates its parameters explicitly named, where order carries no
// meaning, while an untyped one holds what was written, in order, bound to
// nothing. Positional binding and byte-for-byte round-tripping both need the
// written list.
internal protocol GMNUntypedTag: GMNTagPayload {

    // MARK: Internal Instance Properties

    // The parameters supplied to this tag, in the order they were written.
    var parameters: [GMNTag.Parameter] { get }
}

// MARK: -

extension GMNTag {

    // MARK: Internal Type Methods

    // The untyped case for a tag no payload fits: `.reserved` if guidolib
    // dispatches the name, `.custom` if it does not.
    //
    // The single place the two lanes are chosen between, and the reason
    // neither public initializer's failure branch has to be written anywhere:
    // the test below is exactly the one they make, so on each side of it one
    // of the two is known to answer.
    internal static func untyped(ident: Ident?,
                                 name: Name,
                                 parameters: [Parameter],
                                 body: [GMNSymbol]) -> GMNTag {
        guard GMNTagTemplate.Registry.names.contains(name.stringValue)
        else {
            return .custom(GMNCustomTag(unchecked: ident,
                                        name: name,
                                        parameters: parameters,
                                        body: body))
        }

        return .reserved(GMNReservedTag(unchecked: ident,
                                        name: name,
                                        parameters: parameters,
                                        body: body))
    }

    // MARK: Internal Instance Properties

    // This tag's payload if it is on one of the two untyped lanes, or `nil`
    // if it promoted.
    //
    // Written as one optional rather than as two cases at each call site
    // because no stage in the pipeline treats the lanes differently: what
    // they all want is "did this tag promote, and if not, what was written?"
    internal var untypedPayload: (any GMNUntypedTag)? {
        switch self {
        case let .custom(tag):
            tag

        case let .reserved(tag):
            tag

        default:
            nil
        }
    }
}
