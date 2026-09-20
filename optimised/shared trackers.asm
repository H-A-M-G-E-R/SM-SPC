incsrc "commands.asm"

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

;!end = "db 0"
;!tie = "db $C8"
;!rest = "db $C9"

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

macro toggleEcho()
    db $FB, $03
endmacro

macro toggleKeyOffGain()
    db $FB, $04
endmacro

macro subloop(n_repeats)
    db $FC, <n_repeats>
endmacro
}
}

sharedTrackerPointers:
; Dummy trackers 5..7 to prevent crashing in QuickMet
dw musicTrack1_tracker, musicTrack2_tracker, musicTrack3_tracker, musicTrack4_tracker, !zero, !zero, !zero

; Samus fanfare
musicTrack1:
{
.tracker
  dw .pattern0
  dw $0000

.pattern0: dw .pattern0_0, 0, .pattern0_2, .pattern0_3, 0, 0, 0, 0

.pattern0_0
  !tempo,18
  !musicVolume,180
  !echo,%00001111,10,10
  !echoParameters,2,10,0
  !instr,$0B
  !transpose,244
  !subtranspose,70
  !pan,10
  !volume,170
  !dynamicVolume,24,220
  db 24,$7F
  !g4
  !volume,170
  !dynamicVolume,24,220
  !g4
  !volume,170
  !dynamicVolume,18,180
  !fs4
  !volume,170
  !dynamicVolume,14,140
  !fs4
  db 48
  !f4
  !volume,170
  !dynamicVolume,24,100
  !c2
  db 15
  !rest
  !end

.pattern0_2
  !instr,$0B
  !transpose,0
  !subtranspose,70
  !volume,200
  !pan,3
  !loop : dw .sub5626 : db 1
  !volume,180
  !c3
  !b2
  db 48
  !d2
  !d2
  db 15
  !rest
  !end

.pattern0_3
  !instr,$0B
  !transpose,0
  !subtranspose,30
  !volume,200
  !pan,17
  db 3
  !rest
  !loop : dw .sub5626 : db 1
  !c3
  !a2
  !subtranspose,0
  db 48
  !d2
  db 45
  !d2
  db 15
  !rest
  !end

.sub5626
  db 24,$7F
  !ds3
  !d3
  !end
}

; Item fanfare
musicTrack2:
{
.tracker
  dw .pattern0
  dw $0000

.pattern0: dw .pattern0_0, .pattern0_1, 0, 0, 0, 0, 0, 0

.pattern0_0
  !echo,%00000011,10,0
  !echoParameters,2,10,0
  !instr,$0B
  db 79
  !a2
  db 48
  !f2
  !dynamicVolume,255,100
  !e2
  !echo,%00000011,0,10
  !echoParameters,2,5,0
  !instr,$08
  db 79
  !a2
  db 48
  !f2
  !dynamicVolume,255,100
  !end

.pattern0_1
  !echo,%00000011,0,10
  !echoParameters,2,5,0
  !instr,$08
  db 79
  !a2
  db 48
  !f2
  !dynamicVolume,255,100
  !end
}

; Elevator
musicTrack3:
{
.tracker
dw .introTrackPointers
- : dw .loopTrackPointers, $00FF,-

.loopTrackPointers
dw .loopTrack0, .loopTrack1, .loopTrack2, .loopTrack3, $0000, $0000, $0000, $0000

.introTrackPointers
dw .introTrack0, $0000, $0000, $0000, $0000, $0000, $0000, $0000

.loopTrack0
{
%staticMusicVolume($DC)
%staticMusicTempo($10)
%selectInstrument($0C)
%subtranspose($28)
%staticVolume($46)
%staticPanning($07)
%staticEcho($0F,$0A,$0A)
%echoParameters($02,$0A,$00)
%noteLength($30)
!rest
%noteParameters($18, 2, $F)
%note($BA)
%note($B5)
%note($B9)
%note($B1)
%noteLength($48)
!rest
%noteLength($18)
%note($B0)
%note($B6)
%note($BB)
!rest
!rest
%noteParameters($18, 1, $F)
%note($B5)
%noteLength($0C)
!rest
%noteLength($18)
%note($B2)
%noteLength($7E)
!rest
!rest
!end
}

.loopTrack1
{
%selectInstrument($0C)
%subtranspose($28)
%staticVolume($32)
%noteLength($30)
!rest
%noteParameters($18, 2, $F)
%note($A6)
%note($A1)
%note($A5)
%note($9D)
%noteLength($48)
!rest
%noteLength($18)
%note($9C)
%note($A2)
%note($A7)
!rest
!rest
%note($AD)
%noteLength($0C)
!rest
%noteLength($18)
%note($AA)
%noteLength($7E)
!rest
!rest
}

.loopTrack2
{
%selectInstrument($0C)
%subtranspose($28)
%staticVolume($3C)
%staticPanning($0D)
%noteLength($20)
!rest
%noteParameters($06, 0, $F)
%note($BA)
%note($B5)
%note($B9)
%note($B1)
%note($B0)
%note($B6)
%note($BB)
%noteLength($2A)
!rest
%noteLength($06)
%note($BA)
%note($B5)
%note($B9)
%note($B1)
%note($B0)
%note($B6)
%note($BB)
%noteLength($36)
!rest
%noteLength($06)
%note($B9)
%note($B1)
%note($BA)
%note($B5)
%note($B0)
%note($B6)
%note($BB)
%noteLength($3E)
!rest
%noteLength($06)
%note($BA)
%note($B5)
%note($B9)
%note($B1)
%note($B0)
%note($B6)
%note($BB)
%noteLength($20)
!rest
%noteLength($06)
%note($B5)
%note($BA)
%note($B9)
%note($B1)
%note($B0)
%note($B6)
%note($BB)
%noteLength($6C)
!rest
!rest
}

.loopTrack3
{
%selectInstrument($0B)
%subtranspose($46)
%repeatSubsection(.loopTrack3_repeatedSubsection, $06)
}

.introTrack0
{
%staticMusicTempo($10)
%staticMusicVolume($C8)
%staticEcho($0F,$0A,$0A)
%echoParameters($02,$0A,$00)
%noteLength($0C)
!rest
!end
}

.loopTrack3_repeatedSubsection
{
%staticVolume($3C)
%dynamicVolume($3C,$C8)
%noteLength($3C)
%note($80)
%staticVolume($C8)
%dynamicVolume($30,$3C)
%noteLength($30)
!tie
!end
}
}

; Pre-statue hall
musicTrack4:
{
.tracker
- : dw .trackPointers, $00FF,-

.trackPointers
dw .track0, $0000, $0000, $0000, $0000, $0000, $0000, $0000

.track0
{
%staticMusicTempo($10)
%staticMusicVolume($E6)
%endEcho()
%selectInstrument($0B)
%subtranspose($46)
%staticVolume($32)
%dynamicVolume($3C,$B4)
%noteLength($3C)
%note($80)
%staticVolume($B4)
%dynamicVolume($30,$32)
%noteLength($30)
!tie
!end
}
}
