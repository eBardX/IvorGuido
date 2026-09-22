// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorGuido
import Testing
import XestiTools

internal func articulationKindLabel(_ value: GMNArticulation.Kind) -> String {
    switch value {
    case .accent:
        "accent"

    case .bow:
        "bow"

    case .fermata:
        "fermata"

    case .harmonic:
        "harmonic"

    case .marcato:
        "marcato"

    case .pizzicato:
        "pizzicato"

    case .staccato:
        "staccato"

    case .tenuto:
        "tenuto"
    }
}

internal func barLineKindLabel(_ value: GMNBarLine.Kind) -> String {
    switch value {
    case .double:
        "double"

    case .final:
        "final"

    case .single:
        "single"
    }
}

internal func beamKindLabel(_ value: GMNBeam.Kind) -> String {
    switch value {
    case .feathered:
        "feathered"

    case .normal:
        "normal"
    }
}

internal func beamStateKindLabel(_ value: GMNBeamState.Kind) -> String {
    switch value {
    case .auto:
        "auto"

    case .full:
        "full"

    case .off:
        "off"
    }
}

internal func caseName(_ name: GMNTag.Name) -> String? {
    Mirror(reflecting: promote(name)).children.first?.label
}

internal func curveString(_ curve: GMNTag.Curve) -> String {
    switch curve {
    case .down:
        "down"

    case .up:
        "up"
    }
}

internal func durationBaseLabel(_ value: GMNDuration.Base) -> String {
    switch value {
    case .fraction:
        "fraction"

    case .milliseconds:
        "milliseconds"
    }
}

internal func dynamicRampDirectionLabel(_ value: GMNDynamicRamp.Direction) -> String {
    switch value {
    case .crescendo:
        "crescendo"

    case .diminuendo:
        "diminuendo"
    }
}

internal func jumpKindLabel(_ value: GMNJump.Kind) -> String {
    switch value {
    case .coda:
        "coda"

    case .daCapo:
        "daCapo"

    case .daCapoAlFine:
        "daCapoAlFine"

    case .daCoda:
        "daCoda"

    case .dalSegno:
        "dalSegno"

    case .dalSegnoAlFine:
        "dalSegnoAlFine"

    case .fine:
        "fine"

    case .segno:
        "segno"
    }
}

internal func layoutBreakKindLabel(_ value: GMNLayoutBreak.Kind) -> String {
    switch value {
    case .newPage:
        "newPage"

    case .newSystem:
        "newSystem"
    }
}

internal func markEnclosureLabel(_ value: GMNMark.Enclosure) -> String {
    switch value {
    case .bracket:
        "bracket"

    case .circle:
        "circle"

    case .diamond:
        "diamond"

    case .none:
        "none"

    case .oval:
        "oval"

    case .rectangle:
        "rectangle"

    case .square:
        "square"

    case .triangle:
        "triangle"
    }
}

internal func noteHeadsKindLabel(_ value: GMNNoteHeads.Kind) -> String {
    switch value {
    case .center:
        "center"

    case .left:
        "left"

    case .normal:
        "normal"

    case .reverse:
        "reverse"

    case .right:
        "right"
    }
}

internal func ornamentKindLabel(_ value: GMNOrnament.Kind) -> String {
    switch value {
    case .mordent:
        "mordent"

    case .trill:
        "trill"

    case .turn:
        "turn"
    }
}

internal func pedalKindLabel(_ value: GMNPedal.Kind) -> String {
    switch value {
    case .off:
        "off"

    case .on:
        "on"
    }
}

internal func pitchAccidentalLabel(_ value: GMNPitch.Accidental) -> String {
    switch value {
    case .doubleFlat:
        "doubleFlat"

    case .flat:
        "flat"

    case .sharp:
        "sharp"

    case .impliedSharp:
        "impliedSharp"

    case .doubleSharp:
        "doubleSharp"

    case .omitted:
        "omitted"
    }
}

internal func pitchNameLabel(_ value: GMNPitch.Name) -> String {
    switch value {
    case .a:
        "a"

    case .ais:
        "ais"

    case .b:
        "b"

    case .c:
        "c"

    case .cis:
        "cis"

    case .d:
        "d"

    case .dis:
        "dis"

    case .do:
        "do"

    case .e:
        "e"

    case .empty:
        "empty"

    case .f:
        "f"

    case .fa:
        "fa"

    case .fis:
        "fis"

    case .g:
        "g"

    case .gis:
        "gis"

    case .h:
        "h"

    case .la:
        "la"

    case .mi:
        "mi"

    case .re:
        "re"

    case .si:
        "si"

    case .sol:
        "sol"

    case .ti:
        "ti"
    }
}

internal func positionString(_ placement: GMNTag.Placement) -> String {
    switch placement {
    case .above:
        "above"

    case .below:
        "below"
    }
}

internal func rangeName(_ rangeSetting: GMNTag.RangeSetting) -> String {
    switch rangeSetting {
    case .either:
        "RANGEDC"

    case .no:
        "NO"

    case .only:
        "ONLY"
    }
}

internal func repeatKindLabel(_ value: GMNRepeat.Kind) -> String {
    switch value {
    case .begin:
        "begin"

    case .end:
        "end"
    }
}

internal func staffVisibilityKindLabel(_ value: GMNStaffVisibility.Kind) -> String {
    switch value {
    case .off:
        "off"

    case .on:
        "on"
    }
}

internal func stemDirectionKindLabel(_ value: GMNStemDirection.Kind) -> String {
    switch value {
    case .auto:
        "auto"

    case .down:
        "down"

    case .off:
        "off"

    case .up:
        "up"
    }
}

internal func suffix(_ span: GMNTag.Span) -> String {
    switch span {
    case .begin:
        "Begin"

    case .end:
        "End"

    case .whole:
        ""
    }
}

internal func tagParameterUnitLabel(_ value: GMNTag.Parameter.Unit) -> String {
    switch value {
    case .cm:
        "cm"

    case .hs:
        "hs"

    case .in:
        "in"

    case .m:
        "m"

    case .mm:
        "mm"

    case .pc:
        "pc"

    case .pt:
        "pt"

    case .rl:
        "rl"
    }
}

internal func tagParameterValueLabel(_ value: GMNTag.Parameter.Value) -> String {
    switch value {
    case .floating:
        "floating"

    case .integer:
        "integer"

    case .parameter:
        "parameter"

    case .string:
        "string"

    case .variable:
        "variable"
    }
}

internal func tempoChangeDirectionLabel(_ value: GMNTempoChange.Direction) -> String {
    switch value {
    case .accelerando:
        "accelerando"

    case .ritardando:
        "ritardando"
    }
}

internal func textKindLabel(_ value: GMNText.Kind) -> String {
    switch value {
    case .label:
        "label"

    case .text:
        "text"
    }
}

internal func titleBlockKindLabel(_ value: GMNTitleBlock.Kind) -> String {
    switch value {
    case .composer:
        "composer"

    case .footer:
        "footer"

    case .title:
        "title"
    }
}

internal func variableValueLabel(_ value: GMNVariable.Value) -> String {
    switch value {
    case .floating:
        "floating"

    case .integer:
        "integer"

    case .string:
        "string"
    }
}
