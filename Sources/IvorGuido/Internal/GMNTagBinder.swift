// © 2026 John Gary Pusey (see LICENSE.md)

// Binds a tag's written parameters to the names of its template.
//
// A direct transcription of `ARMusicalTag::checkTagParameters`
// (`ARMusicalTag.cpp:85–107`): once bound, a parameter is identified by
// *name only*, so positional and named spellings are provably the same thing
// and the order they were written in carries no meaning.
//
// The C++ is twenty lines and every one of them matters:
//
// ```
// for (size_t i=0; i < n ; i++) {
//     STagParameterPtr p = params[i];
//     string key = p->getName();
//     if (key.size())          namedParams.Add (p);
//     else if (i < kn)       { p->setName (keys[i]); namedParams.Add (p); }
//     else                   { cerr << …; break; }
// }
// ```
//
// Three consequences the model leans on:
//
//   1. The index used for an unnamed parameter is `i`, the position in the
//      **written** list — not a running count of unnamed ones. So a named
//      parameter still consumes its slot for everything after it, and
//      `\tempo<bpm="1/4=120","Allegro">` binds `"Allegro"` to `keys[1]`,
//      which is `bpm` — silently overwriting the bpm the author wrote and
//      leaving the required `tempo` missing.
//   2. `Add` is a map assignment (`TagParameterMap.cpp:142–146`), so a
//      repeated name overwrites: last one wins.
//   3. An unnamed parameter past the end of the template `break`s the loop.
//      Everything bound before it is kept; everything after it is dropped.
internal enum GMNTagBinder {
}

// MARK: -

extension GMNTagBinder {

    // MARK: Internal Type Methods

    // Binds `parameters` against `template`, returning the name-keyed
    // result together with any binding failure.
    //
    // Never throws and never fails outright: a `Binding` is always produced,
    // because promotion must be total.
    internal static func bind(_ parameters: [GMNTag.Parameter],
                              to template: GMNTagTemplate) -> Binding {
        guard template.acceptsParameters
        else { return Binding(boundNames: Array(repeating: nil,
                                                count: parameters.count),
                              failure: nil,
                              template: template,
                              values: [:]) }

        let keys = template.slots.map { $0.name }

        var boundNames: [String?] = []
        var failure: Binding.Failure?
        var index = 0
        var values: [String: GMNTag.Parameter.Value] = [:]

        for parameter in parameters {
            // A raw (unquoted) identifier never reaches `checkTagParameters`
            // in guidolib: the grammar reduces it to a null parameter
            // (`guido.y:188`, `tagarg: id { $$ = 0; delete $1; }`) and
            // `GuidoParser::tagParameter` drops nulls before `ARFactory`
            // ever sees them (`GuidoParser.cpp:291`). IvorGuido keeps it in
            // the AST for lossless round-tripping, so the binder must skip
            // it *without consuming an index* — counting it would shift
            // every later positional binding by one against guidolib.
            if case .parameter = parameter.value {
                boundNames.append(nil)

                continue
            }

            if let name = parameter.name {
                boundNames.append(name.stringValue)
                values[name.stringValue] = parameter.value
            } else if index < keys.count {
                boundNames.append(keys[index])
                values[keys[index]] = parameter.value
            } else {
                failure = .unboundPositionalParameter(index: index)

                break
            }

            index += 1
        }

        // Only a `break` can leave this short, and a failed binding is never
        // one the normalizer repairs, so the padding exists purely to keep
        // the array parallel to `parameters` under every path.
        boundNames += Array(repeating: nil,
                            count: parameters.count - boundNames.count)

        return Binding(boundNames: boundNames,
                       failure: failure,
                       template: template,
                       values: values)
    }
}
