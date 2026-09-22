// © 2026 John Gary Pusey (see LICENSE.md)

extension GMNTagTemplate {

    // MARK: Internal Nested Types

    // guidolib's parameter template strings, transcribed verbatim from
    // `src/engine/abstract/TagParameterStrings.cpp`.
    //
    // Each constant keeps guidolib's own name minus the `kAR` prefix and
    // `Params` suffix — `kARTempoParams` is `arTempo` — so any string here
    // is one grep from its declaration. Nothing is normalized, reordered, or
    // tidied: the stray trailing `;` in `arFingering` is guidolib's, and
    // `Slot.init?(specification:)` drops the resulting empty element exactly
    // as `str2tagParam` does.
    //
    // `kARBembelParams` is deliberately absent: `\bembel` is declared in
    // `Tags.cpp` but dispatched nowhere in `ARFactory::createTag`, so it
    // reaches the unknown-name fallback and builds an `ARTDummy`. It is not
    // a tag, and it has no template.
    internal enum Specification {
    }
}

// MARK: -

extension GMNTagTemplate.Specification {

    // MARK: Internal Type Properties

    // `kARAccelerandoParams` (`TagParameterStrings.cpp:31`).
    internal static let arAccelerando = "S,before,,o;S,after,,o;U,dx2,0hs,o;"
        + "S,font,Times New Roman,o;U,fsize,10pt,o;S,textformat,lc,o"

    // `kARAccidentalParams` (`TagParameterStrings.cpp:32`).
    internal static let arAccidental = "S,style,,o"

    // `kARAccoladeParams` (`TagParameterStrings.cpp:33`).
    internal static let arAccolade = "I,id,,r;S,range,,r;S,type,standard,o"

    // `kARAlterParams` (`TagParameterStrings.cpp:34`).
    internal static let arAlter = "F,detune,0.0,r;S,text,,o"

    // `kARArpeggioParams` (`TagParameterStrings.cpp:35`).
    internal static let arArpeggio = "S,direction,,o"

    // `kARArticulationParams` (`TagParameterStrings.cpp:36`).
    internal static let arArticulation = "S,position,,o"

    // `kARAutoParams` (`TagParameterStrings.cpp:25`).
    internal static let arAuto = "S,endBar,on,o;S,pageBreak,on,o;S,systemBreak,on,o;"
        + "S,clefKeyMeterOrder,on,o;S,stretchLastLine,off,o;S,stretchFirstLine,off,o;"
        + "S,lyricsAutoPos,off,o;S,instrAutoPos,off,o;S,intensAutoPos,off,o;"
        + "S,autoEndBar,on,o;S,autoPageBreak,on,o;S,autoSystemBreak,on,o;"
        + "S,autoClefKeyMeterOrder,on,o;S,autoStretchLastLine,off,o;"
        + "S,autoStretchFirstLine,off,o;S,autoInstrPos,off,o;S,autoLyricsPos,off,o;"
        + "S,autoIntensPos,off,o;S,fingeringPos,,o;F,fingeringSize,,o;S,harmonyPos,,o;"
        + "S,autoHideTiedAccidentals,on,o;S,resolveMultiVoiceCollisions,off,o"

    // `kARBarParams` (`TagParameterStrings.cpp:38`).
    internal static let arBar = "S,displayMeasNum,false,o;I,measNum,,o;S,hidden,false,o;"
        + "U,numDx,0,o;U,numDy,0,o"

    // `kARBarFormatParams` (`TagParameterStrings.cpp:37`).
    internal static let arBarFormat = "S,style,staff,o;S,range,,o"

    // `kARBeamParams` (`TagParameterStrings.cpp:39`).
    internal static let arBeam = "U,dy,0,o;U,dx1,0hs,o;U,dy1,0hs,o;U,dx2,0hs,o;U,dy2,1hs,o;"
        + "U,dx3,0hs,o;U,dy3,0hs,o;U,dx4,0hs,o;U,dy4,1hs,o"

    // `kARBowParams` (`TagParameterStrings.cpp:40`).
    internal static let arBow = "S,type,,r"

    // `kARBowingParams` (`TagParameterStrings.cpp:41`).
    internal static let arBowing = "S,curve,down,o;U,dx1,2hs,o;U,dy1,1hs,o;U,dx2,-2hs,o;"
        + "U,dy2,1hs,o;F,r3,0.5,o;U,h,2hs,o"

    // `kARClefParams` (`TagParameterStrings.cpp:42`).
    internal static let arClef = "S,type,treble,r"

    // `kARClusterParams` (`TagParameterStrings.cpp:43`).
    internal static let arCluster = "U,hdx,0hs,o;U,hdy,0hs,o"

    // `kARColorParams` (`TagParameterStrings.cpp:45`).
    //
    // Line 44 holds a commented-out four-channel form; the live
    // declaration is the single string parameter on line 45.
    internal static let arColor = "S,color,black,r"

    // `kARComposerParams` (`TagParameterStrings.cpp:46`).
    internal static let arComposer = "S,name,,r;S,pageformat,53,o;S,textformat,rb,o;U,fsize,14pt,o"

    // `kARCueParams` (`TagParameterStrings.cpp:47`).
    internal static let arCue = "S,name,,o;U,fsize,9pt,o"

    // `kARDisplayDurationParams` (`TagParameterStrings.cpp:48`).
    internal static let arDisplayDuration = "I,n,,r;I,d,,r;I,ndots,0,o"

    // `kARDrHoosParams` (`TagParameterStrings.cpp:27`).
    internal static let arDrHoos = "I,inverse,0,o"

    // `kARDrRenzParams` (`TagParameterStrings.cpp:28`).
    internal static let arDrRenz = "I,inverse,0,o"

    // `kARDynamicParams` (`TagParameterStrings.cpp:49`).
    internal static let arDynamic = "U,dx1,0,o;U,dx2,0,o;U,deltaY,3,o;U,thickness,0.16,o;"
        + "S,autopos,off,o"

    // `kARFeatheredBeamParams` (`TagParameterStrings.cpp:50`).
    internal static let arFeatheredBeam = "S,durations,,o;S,drawDuration,false,o"

    // `kARFermataParams` (`TagParameterStrings.cpp:51`).
    internal static let arFermata = "S,type,,o;S,position,above,o"

    // `kARFingeringParams` (`TagParameterStrings.cpp:52`) — trailing `;`
    // is guidolib's own.
    internal static let arFingering = "S,position,,o;U,fsize,10pt,o;"

    // `kARFooterParams` (`TagParameterStrings.cpp:53`).
    internal static let arFooter = "S,text,,r;S,pageformat,c6,o;S,font,Times,o;U,fsize,10pt,o;"
        + "S,textformat,cc,o"

    // `kARGlissandoParams` (`TagParameterStrings.cpp:54`).
    internal static let arGlissando = "U,dx1,0,o;U,dy1,0,o;U,dx2,0,o;U,dy2,0,o;S,fill,false,o;"
        + "U,thickness,0.3,o"

    // `kARGraceParams` (`TagParameterStrings.cpp:55`).
    internal static let arGrace = "I,i,,o"

    // `kARHarmonyParams` (`TagParameterStrings.cpp:56`).
    internal static let arHarmony = "S,text,,r;U,dy,-1,o;S,textformat,lt,o;S,font,Arial,o;"
        + "U,fsize,18pt,o"

    // `kARInstrumentParams` (`TagParameterStrings.cpp:57`).
    internal static let arInstrument = "S,name,,r;S,transp,,o;S,autopos,off,o;S,repeat,off,o;"
        + "I,MIDI,-1,o"

    // `kARIntensParams` (`TagParameterStrings.cpp:58`).
    internal static let arIntens = "S,type,,r;S,before,,o;S,after,,o;S,font,Times,o;"
        + "U,fsize,10pt,o;S,fattrib,i,o;S,autopos,off,o"

    // `kARJumpParams` (`TagParameterStrings.cpp:59`).
    internal static let arJump = "S,m,,o;I,id,0,o"

    // `kARKeyParams` (`TagParameterStrings.cpp:60`).
    internal static let arKey = "S,key,,r;S,hideNaturals,false,o;S,free,,o"

    // `kARLyricsParams` (`TagParameterStrings.cpp:61`).
    internal static let arLyrics = "S,text,,r;U,dy,-3,o;S,textformat,ct,o;U,fsize,12pt,o;"
        + "S,autopos,off,o"

    // `kARMarkParams` (`TagParameterStrings.cpp:62`).
    internal static let arMark = "S,text,,r;S,enclosure,none,o;U,dy,0,o"

    // `kARMeterParams` (`TagParameterStrings.cpp:63`).
    internal static let arMeter = "S,type,4/4,r;S,autoBarlines,on,o;S,autoMeasuresNum,off,o;"
        + "S,group,off,o;S,hidden,off,o"

    // `kARMMRestParams` (`TagParameterStrings.cpp:64`).
    internal static let arMMRest = "I,count,,r"

    // `kARNoteFormatParams` (`TagParameterStrings.cpp:65`).
    internal static let arNoteFormat = "S,style,standard,o"

    // `kAROctavaParams` (`TagParameterStrings.cpp:66`).
    internal static let arOctava = "I,i,,r;S,hidden,off,o"

    // `kARPageFormatParams` (`TagParameterStrings.cpp:67`) — declared as
    // one string, but never bound against as one.
    //
    // `ARPageFormat` is the only class in the catalog that overrides
    // `checkTagParameters` (`ARPageFormat.cpp:136–149`). It builds the
    // positional template on the spot, choosing between a page named by
    // `type` and one sized by `w` and `h`, and then *removes* the losing
    // alternative from `fParamsTemplate` with `clearTagDefaultParameter`
    // — which is `TagParameterMap::Remove` (`ARMusicalTag.cpp:109–112`),
    // so the losing names become unsupported outright, not merely
    // un-required.
    //
    // Hence the two constants below instead of one. Neither declares
    // `color`: the hand-built template is `type`-or-`w`/`h` plus the
    // margins and nothing more, so `\pageFormat`'s `color` has no
    // positional slot. It is still *supported*, because `kCommonParams`
    // declares it identically (`S,color,black,o`) and that is merged in
    // for every tag.
    internal static let arPageFormatBySize = "U,w,,r;U,h,,r;" + Self.arPageFormatMargins

    internal static let arPageFormatByType = "S,type,,r;" + Self.arPageFormatMargins

    // `kARPizzicatoParams` (`TagParameterStrings.cpp:68`).
    internal static let arPizzicato = "S,type,lefthand,o;S,position,,o"

    // `kARRepeatParams` (`TagParameterStrings.cpp:69`).
    internal static let arRepeat = "S,hidden,false,o"

    // `kARRitardandoParams` (`TagParameterStrings.cpp:70`).
    internal static let arRitardando = "S,before,,o;S,after,,o;U,dx2,0hs,o;"
        + "S,font,Times New Roman,o;U,fsize,10pt,o;S,textformat,lc,o"

    // `kARSpaceParams` (`TagParameterStrings.cpp:71`).
    internal static let arSpace = "U,dd,,r"

    // `kARSpecialParams` (`TagParameterStrings.cpp:72`).
    internal static let arSpecial = "S,char,,r"

    // `kARStaccatoParams` (`TagParameterStrings.cpp:73`).
    internal static let arStaccato = "S,type,,o;S,position,,o"

    // `kARStaffParams` (`TagParameterStrings.cpp:75`).
    internal static let arStaff = "I,id,,r"

    // `kARStaffFormatParams` (`TagParameterStrings.cpp:74`).
    internal static let arStaffFormat = "S,style,standard,o;U,size,3pt,o;F,lineThickness,0.08,o;"
        + "U,distance,0hs,o"

    // `kARSymbolParams` (`TagParameterStrings.cpp:76`).
    internal static let arSymbol = "S,file,,r;S,position,mid,o;I,w,,o;I,h,,o"

    // `kARTempoParams` (`TagParameterStrings.cpp:77`).
    internal static let arTempo = "S,tempo,,r;S,bpm,,o;S,font,Times New Roman,o;"
        + "S,textformat,lc,o;U,fsize,11pt,o"

    // `kARTextParams` (`TagParameterStrings.cpp:78`).
    internal static let arText = "S,text,,r;U,dy,-1,o;S,textformat,lt,o;U,fsize,12pt,o"

    // `kARTitleParams` (`TagParameterStrings.cpp:79`).
    internal static let arTitle = "S,name,,r;S,pageformat,c2,o;U,dy,0,o;S,font,Times,o;"
        + "U,fsize,24pt,o;S,textformat,cc,o"

    // `kARTremoloParams` (`TagParameterStrings.cpp:80`).
    internal static let arTremolo = "S,style,///,o;I,speed,32,o;S,pitch,,o;U,thickness,0.75,o;"
        + "S,text,,o"

    // `kARTrillParams` (`TagParameterStrings.cpp:81`).
    internal static let arTrill = "S,note,,o;S,type,prall,o;F,detune,0.0,o;S,accidental,,o;"
        + "I,dur,32,o;S,begin,on,o;U,adx,0hs,o;U,ady,0hs,o;S,tr,true,o;S,wavy,true,o;"
        + "S,position,above,o;S,repeat,true,o"

    // `kARTStemParams` (`TagParameterStrings.cpp:82`).
    internal static let arTStem = "U,length,7.0,o"

    // `kARTupletParams` (`TagParameterStrings.cpp:83`).
    internal static let arTuplet = "S,format,,r;S,position,above,o;U,dy1,0,o;U,dy2,0,o;"
        + "F,lineThickness,4,o;S,bold,,o;F,textSize,1,o;S,dispNote,,o"

    // `kARUnitsParams` (`TagParameterStrings.cpp:84`).
    internal static let arUnits = "S,type,cm,r"

    // `kARVoltaParams` (`TagParameterStrings.cpp:85`).
    internal static let arVolta = "S,mark,,r;S,format,,o"

    // `kCommonParams` (`TagParameterStrings.cpp:20`).
    internal static let common = "S,color,black,o;U,dx,0,o;U,dy,0,o;F,size,1.0,o"

    // `kARFontAbleParams` (`TagParameterStrings.cpp:21`).
    internal static let fontAble = "S,textformat,rc,o;S,font,Times,o;U,fsize,9pt,o;S,fattrib,,o"

    // MARK: Private Type Properties

    // The tail both of `\pageFormat`'s templates share
    // (`ARPageFormat.cpp:138`), spelled there as a local string rather
    // than taken from `kARPageFormatParams`.
    private static let arPageFormatMargins = "U,lm,2cm,o;U,tm,5cm,o;U,rm,2cm,o;U,bm,3cm,o"
}
