; Macros
{
macro noteLength(length)
    db <length>
endmacro

macro noteParameters(length, volume, ringLength)
    db <length>, <volume><<4|<ringLength>
endmacro

macro note(note)
    db <note>
endmacro

macro percussionNote(note)
    db <note>
endmacro

!end = "db 0"
!tie = "db $C8"
!rest = "db $C9"

; Commands
{
macro selectInstrument(i_instrument)
    db $E0, <i_instrument>
endmacro

macro staticPanning(bias)
    db $E1, <bias>
endmacro

macro dynamicPanning(duration, targetBias)
    db $E2, <duration>, <targetBias>
endmacro

macro staticVibrato(delay, rate, extent)
    db $E3, <delay>, <rate>, <extent>
endmacro

macro endVibrato()
    db $E4
endmacro

macro staticMusicVolume(volume)
    db $E5, <volume>
endmacro

macro dynamicMusicVolume(duration, targetVolume)
    db $E6, <duration>, <targetVolume>
endmacro

macro staticMusicTempo(tempo)
    db $E7, <tempo>
endmacro

macro dynamicMusicTempo(duration, targetTempo)
    db $E8, <duration>, <targetTempo>
endmacro

macro musicTranspose(transpose)
    db $E9, <transpose>
endmacro

macro transpose(transpose)
    db $EA, <transpose>
endmacro

macro tremolo(delay, rate, extent)
    db $EB, <delay>, <rate>, <extent>
endmacro

macro endTremolo()
    db $EC
endmacro

macro staticVolume(volume)
    db $ED, <volume>
endmacro

macro dynamicVolume(duration, targetVolume)
    db $EE, <duration>, <targetVolume>
endmacro

macro repeatSubsection(p_subsection, n_repeats)
    db $EF : dw <p_subsection> : db <n_repeats>
endmacro

macro dynamicVibrato(duration)
    db $F0, <duration>
endmacro

macro slideOut(delay, duration, extent)
    db $F1, <delay>, <duration>, <extent>
endmacro

macro slideIn(delay, duration, extent)
    db $F2, <delay>, <duration>, <extent>
endmacro

macro endSlide()
    db $F3
endmacro

macro subtranspose(subtranspose)
    db $F4, <subtranspose>
endmacro

macro staticEcho(voices, volume_left, volume_right)
    db $F5, <voices>, <volume_left>, <volume_right>
endmacro

macro endEcho()
    db $F6
endmacro

macro echoParameters(delay, feedbackVolume, i_firFilter)
    db $F7, <delay>, <feedbackVolume>, <i_firFilter>
endmacro

macro dynamicEchoVolume(delay, volume_left, volume_right)
    db $F8, <delay>, <volume_left>, <volume_right>
endmacro

macro pitchSlide(delay, duration, extent)
    db $F9, <delay>, <duration>, <extent>
endmacro

macro setPercussionInstrumentsIndex(i)
    db $FA, <i>
endmacro

macro setNoteLengthTable(p_noteLengthTable)
    db $FB, $00 : dw <p_noteLengthTable>
endmacro

macro setEchoFirFilters(p_echoFirFilters)
    db $FB, $01 : dw <p_echoFirFilters>
endmacro

macro setDPMiscCommand(p_ram, value)
    db $FB, $02, <p_ram>, <value>
endmacro
}
}
