// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// **Every parameter here is non-omissible, proven, for one shared reason.**
// `ARAuto::setTagParameters` reads all twenty-three without `usedefault` and
// assigns only inside an `if (p)` guard (`ARAuto.cpp:43–96`), so absence
// leaves the class’s own initial state rather than applying the declared
// default. Four of them go further and set an explicit `fHasX` flag —
// `fHasFingeringPos`, `fHasHarmonyPos`, `fHasMVoiceCollision`,
// `fHasFingeringSize` — the class inspecting its own parameters for
// authorship, in its own hand. Each field is therefore `Optional` and its
// absence is preserved.
//
// guidolib: `ARAuto`, `kARAutoParams`
// (`"S,endBar,on,o;S,pageBreak,on,o;S,systemBreak,on,o;S,clefKeyMeterOrder,on,o;S,stretchLastLine,off,o;S,stretchFirstLine,off,o;S,lyricsAutoPos,off,o;S,instrAutoPos,off,o;S,intensAutoPos,off,o;S,autoEndBar,on,o;S,autoPageBreak,on,o;S,autoSystemBreak,on,o;S,autoClefKeyMeterOrder,on,o;S,autoStretchLastLine,off,o;S,autoStretchFirstLine,off,o;S,autoInstrPos,off,o;S,autoLyricsPos,off,o;S,autoIntensPos,off,o;S,fingeringPos,,o;F,fingeringSize,,o;S,harmonyPos,,o;S,autoHideTiedAccidentals,on,o;S,resolveMultiVoiceCollisions,off,o"`,
// `TagParameterStrings.cpp:25`). Range setting: `NO` — `\auto` takes no body.

/// A score-wide automatic-layout setting (`\auto`, `\set`).
///
/// `\auto` takes no body.
///
/// ## Two spellings of one setting
///
/// Eight settings have both a legacy name and an `auto`-prefixed one, and the
/// `auto`-prefixed name wins when both are written. This payload keeps
/// **both fields** rather than collapsing them, so a score round-trips with
/// the name it was written with. The eight pairs are `endBar`/`autoEndBar`,
/// `pageBreak`/`autoPageBreak`, `systemBreak`/`autoSystemBreak`,
/// `clefKeyMeterOrder`/`autoClefKeyMeterOrder`, `instrAutoPos`/`autoInstrPos`,
/// `lyricsAutoPos`/`autoLyricsPos`, `intensAutoPos`/`autoIntensPos`, and
/// `stretchLastLine`/`autoStretchLastLine` together with
/// `stretchFirstLine`/`autoStretchFirstLine`.
///
/// The on/off settings are typed `String` rather than `Bool` because several
/// spellings are accepted, and re-spelling one as another would change what
/// the score says.
public struct GMNAuto {

    // MARK: Public Initializers

    /// Creates a new automatic-layout setting with the provided identifier,
    /// values, appearance, and body.
    ///
    /// Every parameter defaults to `nil`, meaning it was not written. See the
    /// type’s own discussion for why absence is preserved rather than filled
    /// in with the declared default.
    public init(ident: GMNTag.Ident? = nil,
                endBar: String? = nil,
                pageBreak: String? = nil,
                systemBreak: String? = nil,
                clefKeyMeterOrder: String? = nil,
                stretchLastLine: String? = nil,
                stretchFirstLine: String? = nil,
                lyricsAutoPos: String? = nil,
                instrAutoPos: String? = nil,
                intensAutoPos: String? = nil,
                autoEndBar: String? = nil,
                autoPageBreak: String? = nil,
                autoSystemBreak: String? = nil,
                autoClefKeyMeterOrder: String? = nil,
                autoStretchLastLine: String? = nil,
                autoStretchFirstLine: String? = nil,
                autoInstrPos: String? = nil,
                autoLyricsPos: String? = nil,
                autoIntensPos: String? = nil,
                fingeringPos: String? = nil,
                fingeringSize: Double? = nil,
                harmonyPos: String? = nil,
                autoHideTiedAccidentals: String? = nil,
                resolveMultiVoiceCollisions: String? = nil,
                appearance: GMNTag.Appearance = GMNTag.Appearance(),
                body: [GMNSymbol] = []) {
        self.appearance = appearance
        self.autoClefKeyMeterOrder = autoClefKeyMeterOrder
        self.autoEndBar = autoEndBar
        self.autoHideTiedAccidentals = autoHideTiedAccidentals
        self.autoInstrPos = autoInstrPos
        self.autoIntensPos = autoIntensPos
        self.autoLyricsPos = autoLyricsPos
        self.autoPageBreak = autoPageBreak
        self.autoStretchFirstLine = autoStretchFirstLine
        self.autoStretchLastLine = autoStretchLastLine
        self.autoSystemBreak = autoSystemBreak
        self.body = body
        self.clefKeyMeterOrder = clefKeyMeterOrder
        self.endBar = endBar
        self.fingeringPos = fingeringPos
        self.fingeringSize = fingeringSize
        self.harmonyPos = harmonyPos
        self.ident = ident
        self.instrAutoPos = instrAutoPos
        self.intensAutoPos = intensAutoPos
        self.lyricsAutoPos = lyricsAutoPos
        self.pageBreak = pageBreak
        self.resolveMultiVoiceCollisions = resolveMultiVoiceCollisions
        self.stretchFirstLine = stretchFirstLine
        self.stretchLastLine = stretchLastLine
        self.systemBreak = systemBreak
    }

    // MARK: Public Instance Properties

    /// The common appearance parameters written for this tag.
    public let appearance: GMNTag.Appearance

    /// Whether clef, key, and meter are ordered automatically
    /// (`autoClefKeyMeterOrder`); preferred over ``clefKeyMeterOrder``.
    public let autoClefKeyMeterOrder: String?

    /// Whether a final barline is added automatically (`autoEndBar`);
    /// preferred over ``endBar``.
    public let autoEndBar: String?

    /// Whether accidentals on tied notes are hidden
    /// (`autoHideTiedAccidentals`).
    public let autoHideTiedAccidentals: String?

    /// Whether instrument names are positioned automatically
    /// (`autoInstrPos`); preferred over ``instrAutoPos``.
    public let autoInstrPos: String?

    /// Whether intensity marks are positioned automatically
    /// (`autoIntensPos`); preferred over ``intensAutoPos``.
    public let autoIntensPos: String?

    /// Whether lyrics are positioned automatically (`autoLyricsPos`);
    /// preferred over ``lyricsAutoPos``.
    public let autoLyricsPos: String?

    /// Whether pages are broken automatically (`autoPageBreak`); preferred
    /// over ``pageBreak``.
    public let autoPageBreak: String?

    /// Whether the first line is stretched to the page width
    /// (`autoStretchFirstLine`); preferred over ``stretchFirstLine``.
    public let autoStretchFirstLine: String?

    /// Whether the last line is stretched to the page width
    /// (`autoStretchLastLine`); preferred over ``stretchLastLine``.
    public let autoStretchLastLine: String?

    /// Whether systems are broken automatically (`autoSystemBreak`);
    /// preferred over ``systemBreak``.
    public let autoSystemBreak: String?

    /// The symbols scoped to this tag.
    ///
    /// Always empty in a well-formed score: this tag takes no body. The field
    /// exists so a malformed score still round-trips what was written;
    /// reporting it is the validator’s job.
    ///
    /// See ``GMNValidator/Issue/unexpectedTagBody(_:)``.
    public let body: [GMNSymbol]

    /// Whether clef, key, and meter are ordered automatically
    /// (`clefKeyMeterOrder`), the legacy spelling of
    /// ``autoClefKeyMeterOrder``.
    public let clefKeyMeterOrder: String?

    /// Whether a final barline is added automatically (`endBar`), the legacy
    /// spelling of ``autoEndBar``.
    public let endBar: String?

    // `ARAuto.cpp:71–76`: anything but `above`/`below` leaves the position
    // alone while still setting `fHasFingeringPos`, so the value is kept as a
    // `String`.

    /// Which side of the staff fingerings sit on (`fingeringPos`).
    ///
    /// The recognized values are `above` and `below`; anything else leaves
    /// the position as it was.
    public let fingeringPos: String?

    /// The scaling factor applied to fingering text (`fingeringSize`).
    ///
    /// An `F` parameter, hence a bare `Double`: it is a ratio, not a length.
    public let fingeringSize: Double?

    // Read exactly like `fingeringPos` (`ARAuto.cpp:78–83`).

    /// Which side of the staff harmony text sits on (`harmonyPos`).
    ///
    /// The recognized values are `above` and `below`; anything else leaves
    /// the position as it was.
    public let harmonyPos: String?

    /// The numeric identifier written after this tag’s name, if any.
    public let ident: GMNTag.Ident?

    /// Whether instrument names are positioned automatically
    /// (`instrAutoPos`), the legacy spelling of ``autoInstrPos``.
    public let instrAutoPos: String?

    /// Whether intensity marks are positioned automatically
    /// (`intensAutoPos`), the legacy spelling of ``autoIntensPos``.
    public let intensAutoPos: String?

    /// Whether lyrics are positioned automatically (`lyricsAutoPos`), the
    /// legacy spelling of ``autoLyricsPos``.
    public let lyricsAutoPos: String?

    /// Whether pages are broken automatically (`pageBreak`), the legacy
    /// spelling of ``autoPageBreak``.
    public let pageBreak: String?

    /// Whether colliding notes in different voices are moved apart
    /// (`resolveMultiVoiceCollisions`).
    public let resolveMultiVoiceCollisions: String?

    /// Whether the first line is stretched to the page width
    /// (`stretchFirstLine`), the legacy spelling of ``autoStretchFirstLine``.
    public let stretchFirstLine: String?

    /// Whether the last line is stretched to the page width
    /// (`stretchLastLine`), the legacy spelling of ``autoStretchLastLine``.
    public let stretchLastLine: String?

    /// Whether systems are broken automatically (`systemBreak`), the legacy
    /// spelling of ``autoSystemBreak``.
    public let systemBreak: String?

    // MARK: Internal Initializers

    internal init(ident: GMNTag.Ident?,
                  binding: GMNTagBinder.Binding,
                  body: [GMNSymbol]) {
        self.init(ident: ident,
                  endBar: binding.string(named: "endBar"),
                  pageBreak: binding.string(named: "pageBreak"),
                  systemBreak: binding.string(named: "systemBreak"),
                  clefKeyMeterOrder: binding.string(named: "clefKeyMeterOrder"),
                  stretchLastLine: binding.string(named: "stretchLastLine"),
                  stretchFirstLine: binding.string(named: "stretchFirstLine"),
                  lyricsAutoPos: binding.string(named: "lyricsAutoPos"),
                  instrAutoPos: binding.string(named: "instrAutoPos"),
                  intensAutoPos: binding.string(named: "intensAutoPos"),
                  autoEndBar: binding.string(named: "autoEndBar"),
                  autoPageBreak: binding.string(named: "autoPageBreak"),
                  autoSystemBreak: binding.string(named: "autoSystemBreak"),
                  autoClefKeyMeterOrder: binding.string(named: "autoClefKeyMeterOrder"),
                  autoStretchLastLine: binding.string(named: "autoStretchLastLine"),
                  autoStretchFirstLine: binding.string(named: "autoStretchFirstLine"),
                  autoInstrPos: binding.string(named: "autoInstrPos"),
                  autoLyricsPos: binding.string(named: "autoLyricsPos"),
                  autoIntensPos: binding.string(named: "autoIntensPos"),
                  fingeringPos: binding.string(named: "fingeringPos"),
                  fingeringSize: binding.double(named: "fingeringSize"),
                  harmonyPos: binding.string(named: "harmonyPos"),
                  autoHideTiedAccidentals: binding.string(named: "autoHideTiedAccidentals"),
                  resolveMultiVoiceCollisions: binding.string(named: "resolveMultiVoiceCollisions"),
                  appearance: binding.appearance,
                  body: body)
    }
}

// MARK: - GMNTagPayload

extension GMNAuto: GMNTagPayload {

    // MARK: Internal Instance Properties

    internal var name: GMNTag.Name {
        GMNTag.Name("auto")
    }

    internal var parameterValues: [String: GMNTag.Parameter.Value] {
        var values: [String: GMNTag.Parameter.Value] = [:]

        values["autoClefKeyMeterOrder"] = autoClefKeyMeterOrder.map { .string($0) }
        values["autoEndBar"] = autoEndBar.map { .string($0) }
        values["autoHideTiedAccidentals"] = autoHideTiedAccidentals.map { .string($0) }
        values["autoInstrPos"] = autoInstrPos.map { .string($0) }
        values["autoIntensPos"] = autoIntensPos.map { .string($0) }
        values["autoLyricsPos"] = autoLyricsPos.map { .string($0) }
        values["autoPageBreak"] = autoPageBreak.map { .string($0) }
        values["autoStretchFirstLine"] = autoStretchFirstLine.map { .string($0) }
        values["autoStretchLastLine"] = autoStretchLastLine.map { .string($0) }
        values["autoSystemBreak"] = autoSystemBreak.map { .string($0) }
        values["clefKeyMeterOrder"] = clefKeyMeterOrder.map { .string($0) }
        values["endBar"] = endBar.map { .string($0) }
        values["fingeringPos"] = fingeringPos.map { .string($0) }
        values["fingeringSize"] = fingeringSize.map { .number($0) }
        values["harmonyPos"] = harmonyPos.map { .string($0) }
        values["instrAutoPos"] = instrAutoPos.map { .string($0) }
        values["intensAutoPos"] = intensAutoPos.map { .string($0) }
        values["lyricsAutoPos"] = lyricsAutoPos.map { .string($0) }
        values["pageBreak"] = pageBreak.map { .string($0) }
        values["resolveMultiVoiceCollisions"] = resolveMultiVoiceCollisions.map { .string($0) }
        values["stretchFirstLine"] = stretchFirstLine.map { .string($0) }
        values["stretchLastLine"] = stretchLastLine.map { .string($0) }
        values["systemBreak"] = systemBreak.map { .string($0) }

        return values
    }
}

// MARK: - Equatable

extension GMNAuto: Equatable {
}

// MARK: - Sendable

extension GMNAuto: Sendable {
}
