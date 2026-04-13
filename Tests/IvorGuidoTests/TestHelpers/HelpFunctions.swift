// © 2026 John Gary Pusey (see LICENSE.md)

import IvorGuido

internal func fdur(_ num: UInt,
                   _ den: UInt,
                   _ dots: UInt = 0) -> GMNDuration {
    GMNDuration(numerator: num,
                denominator: den,
                dots: dots)!        // swiftlint:disable:this force_unwrapping
}

internal func mdur(_ ms: UInt) -> GMNDuration {
    GMNDuration(milliseconds: ms)!  // swiftlint:disable:this force_unwrapping
}
