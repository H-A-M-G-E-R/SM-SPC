; $172D
getNextTrackerCommand:
{
; YA = [[tracker pointer]]
; Tracker pointer += 2

mov y,#$00 : mov a,(!p_tracker)+y : incw !p_tracker
push a
mov a,(!p_tracker)+y : incw !p_tracker : mov y,a
pop a
ret
}

; $173B
loadNewMusicData:
{
call receiveDataFromCpu
mov !cpuIo0_read_prev,a

; Fall through
}

; $1740
loadNewMusicTrack:
{
;; Parameters:
;;     A: Music track to load. Caller is responsible for setting previous value read from CPU IO 0

mov !cpuIo0_write,a

; Tracker pointer = [[!p_trackerData] + ([A] - 1) * 2]
dec a : asl a : mov y,a : mov a,(!p_trackerData)+y : mov x,a : inc y : mov a,(!p_trackerData)+y : mov y,a : mov a,x : movw !p_tracker,ya

; Music track status = new music track loaded
mov !musicTrackStatus,#$02

; Fall through
}

; $1750
keyOffMusicVoices:
{
mov a,!enableSoundEffectVoices : eor a,#$FF : tset !keyOffFlags,a
ret
}

; $1758
musicTrackInitialisation:
{
mov x,#$0E

-
{
mov a,#$FC
mov !trackNoteRingLengths+x,a
mov !trackNoteVolumes+x,a
mov a,#$FF : call staticVolume
mov a,#$0A : call staticPanning
mov !trackSubtransposes+x,a
mov !trackTransposes+x,a
mov !trackSlideLengths+x,a
mov !trackVibratoExtents+x,a
mov !trackTremoloExtents+x,a
mov !trackDynamicVolumeTimers+x,a
mov !trackDynamicPanningTimers+x,a
dec x : dec x : bpl -
}

mov !dynamicMusicVolumeTimer,a
mov !dynamicEchoVolumeTimer,a
mov !dynamicMusicTempoTimer,a
mov !musicTranspose,a
mov !trackerTimer,a
mov !percussionInstrumentsBaseIndex,a
mov !disablePsychoacousticAdjustment,a
mov y,#$C0 : movw !musicVolume,ya
mov y,#$20 : movw !musicTempo,ya
mov a,#sharedNoteRingLengthTable&$FF : mov y,#sharedNoteRingLengthTable>>8 : movw !p_noteRingLengthTable,ya
mov a,#sharedEchoFirFilters&$FF : mov y,#sharedEchoFirFilters>>8 : movw !p_echoFirFilters,ya
mov !noteEndInTicks,#$02

.ret
ret
}

; $1793
handleMusicTrack:
{
; Check CPU IO 0
mov a,!cpuIo0_read
cmp a,#$F0 : beq keyOffMusicVoices
cmp a,#$F1 : beq +
cmp a,#$FF : beq loadNewMusicData
cmp a,!cpuIo0_read_prev : bne loadNewMusicTrack

+
mov a,!cpuIo0_write : beq musicTrackInitialisation_ret
mov a,!musicTrackStatus : beq .branch_musicTrackPlaying
dbnz !musicTrackStatus,musicTrackInitialisation

.loop_tracker
{
call getNextTrackerCommand
bne .branch_loadNewTrackData
mov y,a : bne +
jmp loadNewMusicTrack

+
dec !trackerTimer : bpl +
mov !trackerTimer,a

+
call getNextTrackerCommand
mov x,!trackerTimer : beq .loop_tracker
movw !p_tracker,ya
bra .loop_tracker

.branch_loadNewTrackData
; Load track pointers
movw !misc1,ya
mov y,#$0F

-
mov a,(!misc1)+y : mov !trackPointers+y,a : dec y : bpl -
call determineSoundVoiceOrder

; Reset music tracks
mov x,#$0E

-
{
mov a,#$00
mov !trackRepeatedSubsectionCounters+x,a
bbs0 !enableLateKeyOff,+
mov !trackDynamicVolumeTimers+x,a
mov !trackDynamicPanningTimers+x,a

+
inc a : mov !trackNoteTimers+x,a
dec x : dec x : bpl -
}

.branch_musicTrackPlaying
mov x,#$00
mov !musicVoiceVolumeUpdateBitset,x
mov !musicVoiceBitset,#$01

.loop_track
{
mov !trackIndex,x
mov a,!trackPointers+1+x : beq .branch_noTrackCommands
dec !trackNoteTimers+x : bne .branch_noteIsPlaying

.loop_track_command
{
call getNextTrackDataByte
bne +

; End of section
mov a,!trackRepeatedSubsectionCounters+x : beq .loop_tracker
call repeatSubsection_setTrackPointer
dec !trackRepeatedSubsectionCounters+x : bne .loop_track_command
mov a,!trackRepeatedSubsectionReturnAddresses+x : mov !trackPointers+x,a : mov a,!trackRepeatedSubsectionReturnAddresses+1+x : mov !trackPointers+1+x,a
bra .loop_track_command

+
bmi +

; Note parameters
mov !trackNoteLengths+x,a
call getNextTrackDataByte
bmi +

; Extended note parameters
push a : xcn a : and a,#$07 : mov y,a : mov a,(!p_noteRingLengthTable)+y : mov !trackNoteRingLengths+x,a : pop a
and a,#$0F : clrc : adc a,#$08 : mov y,a : mov a,(!p_noteRingLengthTable)+y : mov !trackNoteVolumes+x,a
call getNextTrackDataByte

+
cmp a,#$E0 : bcc +
call handleTrackCommand
bra .loop_track_command
}

+
; Note
mov a,y : call processNewNote
mov a,!trackNoteLengths+x : mov !trackNoteTimers+x,a
mov y,a : mov a,!trackNoteRingLengths+x : mul ya : mov a,y : bne + : inc a : + : mov !trackNoteRingTimers+x,a
bra .branch_next

.branch_noteIsPlaying
call handleCurrentNote

.branch_next
call maybeDoPitchSlide

.branch_noTrackCommands
inc x : inc x
asl !musicVoiceBitset : bne .loop_track
}
}

; Dynamic tempo
mov a,!dynamicMusicTempoTimer : beq ++
movw ya,!musicTempoDelta : addw ya,!musicTempo
dbnz !dynamicMusicTempoTimer,+
movw ya,!dynamicMusicTempoTimer

+
movw !musicTempo,ya

++
; Dynamic echo
mov a,!dynamicEchoVolumeTimer : beq ++
movw ya,!echoVolumeLeftDelta : addw ya,!echoVolumeLeft : movw !echoVolumeLeft,ya
movw ya,!echoVolumeRightDelta : addw ya,!echoVolumeRight
dbnz !dynamicEchoVolumeTimer,+
movw ya,!dynamicEchoVolumeTimer : movw !echoVolumeLeft,ya
mov y,!targetEchoVolumeRight

+
movw !echoVolumeRight,ya

++
; Dynamic volume
mov a,!dynamicMusicVolumeTimer : beq ++
movw ya,!musicVolumeDelta : addw ya,!musicVolume
dbnz !dynamicMusicVolumeTimer,+
movw ya,!dynamicMusicVolumeTimer

+
movw !musicVolume,ya
mov !musicVoiceVolumeUpdateBitset,#$FF

++
; Handle track volumes
mov x,#$00
mov !musicVoiceBitset,#$01

-
{
mov a,!trackPointers+1+x : beq +
call handleTrackVolume

+
inc x : inc x
asl !musicVoiceBitset : bne -
}

ret
}

; $5800
sharedNoteRingLengthTable:
db $32,$65,$7F,$98,$B2,$CB,$E5,$FC

sharedNoteVolumeTable:
db $19,$32,$4C,$65,$72,$7F,$8C,$98,$A5,$B2,$BF,$CB,$D8,$E5,$F2,$FC

; $18DD
handleTrackCommand:
{
; Set return address to [$1B62 + ([A] - E0h) * 2]
asl a : mov y,a : mov a,trackCommandPointers-($E0*2&$FF)+1+y : push a : mov a,trackCommandPointers-($E0*2&$FF)+y : push a

; Number of command parameter bytes
mov a,y : lsr a : mov y,a : mov a,trackCommandParameterBytes-($E0*2&$FF)/2+y
beq incrementTrackPointer_yAssignA

; Fall through
}

; $18EF
getNextTrackDataByte:
{
mov a,(!trackPointers+x)

; Fall through
}

; $18F1
incrementTrackPointer:
{
inc !trackPointers+x : bne +
inc !trackPointers+1+x

+
.yAssignA
mov y,a
ret
}

; $18F9
selectInstrument: ; Track command E0h
{
mov !trackInstrumentIndices+x,a

; Fall through
}

; $18FC
setInstrumentSettings:
{
;; Parameters:
;;     A: Instrument index
;;     X: Track index

; If [A] >= 80h:
;     A = [A] - CAh + [percussion instruments index]

; $14 = $6C00 + [A] * 6

; If voice is sound effect enabled:
;     Return

; If [[$14]] & 80h: (always false in vanilla)
;     Enable voice noise with frequency [[$14]], voice source number = 2
; Else:
;     Disable voice noise, voice source number = [[$14]]
;
; Voice ADSR settings = [[$14] + 1]
; Voice gain settings = [[$14] + 3]
; Track instrument pitch multiplier = [[$14] + 4] * 100h + [[$14] + 5]

; Percussion instrument check
mov y,a : bpl +
setc : sbc a,#$CA : clrc : adc a,!percussionInstrumentsBaseIndex

+
mov y,#$06 : mul ya : movw !misc0,ya : clrc : adc !misc0,#!instrumentTable&$FF : adc !misc0+1,#!instrumentTable>>8
mov a,!sound_activeVoices : and a,!musicVoiceBitset : bne .ret
mov a,!musicVoiceBitset : tclr !enableSoundEffectVoices,a
push x
mov a,x : xcn a : lsr a : or a,#$04 : mov x,a
mov y,#$00

if defined("noiseInstruments")
mov a,(!misc0)+y : bpl +
and a,#$1F : and !flg,#$20 : tset !flg,a
or (!noiseEnableFlags),(!musicVoiceBitset)
mov a,#$02 ; first looping sample for noise to work, see https://snes.nesdev.org/wiki/S-DSP_registers#NON
bra .branch_dsp

+
endif
mov a,!musicVoiceBitset : tclr !noiseEnableFlags,a

.loop_dsp
{
mov a,(!misc0)+y

.branch_dsp
mov $F2,x : mov $F3,a
inc x
inc y
cmp y,#$04 : bne .loop_dsp
}

pop x
mov a,(!misc0)+y : mov !trackInstrumentPitches+1+x,a : inc y : mov a,(!misc0)+y : mov !trackInstrumentPitches+x,a

.ret
ret
}

; $1952
staticPanning: ; Track command E1h
{
mov !trackPhaseInversionOptions+x,a
and a,#$1F : mov !trackPanningBiases+1+x,a
mov a,#$00 : mov !trackPanningBiases+x,a
ret
}

; $1960
dynamicPanning: ; Track command E2h
{
mov !trackDynamicPanningTimers+x,a
push a
call getNextTrackDataByte : mov !trackTargetPanningBiases+x,a
setc : sbc a,!trackPanningBiases+1+x : pop x : call division : mov !trackPanningBiasDeltas+x,a : mov a,y : mov !trackPanningBiasDeltas+1+x,a
ret
}

; $1979
staticVibrato: ; Track command E3h
{
mov !trackVibratoDelays+x,a
call getNextTrackDataByte : mov !trackVibratoRates+x,a
call getNextTrackDataByte

; Fall through
}

; $1985
endVibrato: ; Track command E4h
{
mov !trackVibratoExtents+x,a
mov !trackStaticVibratoExtents+x,a
mov a,#$00 : mov !trackDynamicVibratoLengths+x,a
ret
}

; $1990
dynamicVibrato: ; Track command F0h
{
; Not used by any Super Metroid tracks
mov !trackDynamicVibratoLengths+x,a
push a : mov y,#$00 : mov a,!trackVibratoExtents+x : pop x : div ya,x : mov x,!trackIndex : mov !trackVibratoExtentDeltas+x,a
ret
}

; $19A0
staticMusicVolume: ; Track command E5h
{
mov a,#$00 : movw !musicVolume,ya
ret
}

; $19A5
dynamicMusicVolume: ; Track command E6h
{
mov !dynamicMusicVolumeTimer,a
call getNextTrackDataByte : mov !targetMusicVolume,a
setc : sbc a,!musicVolume+1 : mov x,!dynamicMusicVolumeTimer : call division : movw !musicVolumeDelta,ya
ret
}

; $19B7
staticMusicTempo: ; Track command E7h
{
mov a,#$00 : movw !musicTempo,ya
ret
}

; $19BC
dynamicMusicTempo: ; Track command E8h
{
mov !dynamicMusicTempoTimer,a
call getNextTrackDataByte : mov !targetMusicTempo,a
setc : sbc a,!musicTempo+1 : mov x,!dynamicMusicTempoTimer : call division : movw !musicTempoDelta,ya
ret
}

; $19CE
musicTranspose: ; Track command E9h
{
mov !musicTranspose,a
ret
}

; $19D1
transpose: ; Track command EAh
{
mov !trackTransposes+x,a
ret
}

; $19D5
tremolo: ; Track command EBh
{
mov !trackTremoloDelays+x,a
call getNextTrackDataByte : mov !trackTremoloRates+x,a
call getNextTrackDataByte

; Fall through
}

; $19E1
endTremolo: ; Track command ECh
{
mov !trackTremoloExtents+x,a
ret
}

; $19E4
slideOut: ; Track command F1h
{
mov a,#$01
bra setTrackSlide
}

; $19E8
slideIn: ; Track command F2h
{
mov a,#$00

; Fall through
}

; $19EA
setTrackSlide:
{
mov !trackSlideDirections+x,a
mov a,y : mov !trackSlideDelays+x,a
call getNextTrackDataByte : mov !trackSlideLengths+x,a
call getNextTrackDataByte : mov !trackSlideExtents+x,a
ret
}

; $19FE
endSlide: ; Track command F3h
{
mov !trackSlideLengths+x,a
ret
}

; $1A02
staticVolume: ; Track command EDh
{
mov !trackVolumes+1+x,a : mov a,#$00 : mov !trackVolumes+x,a
ret
}

; $1A0B
dynamicVolume: ; Track command EEh
{
mov !trackDynamicVolumeTimers+x,a
push a
call getNextTrackDataByte : mov !trackTargetVolumes+x,a
setc : sbc a,!trackVolumes+1+x : pop x : call division : mov !trackVolumeDeltas+x,a : mov a,y : mov !trackVolumeDeltas+1+x,a
ret
}

; $1A24
subtranspose: ; Track command F4h
{
mov !trackSubtransposes+x,a
ret
}

; $1A28
repeatSubsection: ; Track command EFh
{
mov !trackRepeatedSubsectionAddresses+x,a
call getNextTrackDataByte : mov !trackRepeatedSubsectionAddresses+1+x,a
call getNextTrackDataByte : mov !trackRepeatedSubsectionCounters+x,a
mov a,!trackPointers+x : mov !trackRepeatedSubsectionReturnAddresses+x,a : mov a,!trackPointers+1+x : mov !trackRepeatedSubsectionReturnAddresses+1+x,a

.setTrackPointer
mov a,!trackRepeatedSubsectionAddresses+x : mov !trackPointers+x,a : mov a,!trackRepeatedSubsectionAddresses+1+x : mov !trackPointers+1+x,a
ret
}

; $1A4B
staticEcho: ; Track command F5h
{
mov !fakeEchoEnableFlags,a
mov a,!enableSoundEffectVoices : eor a,#$FF : and a,!fakeEchoEnableFlags : mov !echoEnableFlags,a
call getNextTrackDataByte : mov a,#$00 : movw !echoVolumeLeft,ya
call getNextTrackDataByte : mov a,#$00 : movw !echoVolumeRight,ya
clr5 !flg
ret
}

; $1A5E
dynamicEchoVolume: ; Track command F8h
{
; Not used by any Super Metroid tracks
mov !dynamicEchoVolumeTimer,a
call getNextTrackDataByte : mov !targetEchoVolumeLeft,a
setc : sbc a,!echoVolumeLeft+1 : mov x,!dynamicEchoVolumeTimer : call division : movw !echoVolumeLeftDelta,ya
call getNextTrackDataByte : mov !targetEchoVolumeRight,a
setc : sbc a,!echoVolumeRight+1 : mov x,!dynamicEchoVolumeTimer : call division : movw !echoVolumeRightDelta,ya
ret
}

; $1A7F
endEcho: ; Track command F6h
{
; Not used by any Super Metroid tracks
; Also called at the start of receiveDataFromCpu
movw !echoVolumeLeft,ya
movw !echoVolumeRight,ya
set5 !flg
ret
}

; $1A86
echoParameters: ; Track command F7h
{
call setUpEcho
call getNextTrackDataByte : mov !echoFeedbackVolume,a
call getNextTrackDataByte
mov y,#$08 : mul ya : mov y,a
mov $F2,#$0F
clrc

-
{
mov a,(!p_echoFirFilters)+y : mov $F3,a
inc y
adc $F2,#$10
bpl -
}

mov x,!trackIndex
ret
}

; $1AAB
setUpEcho:
{
mov !echoDelay,a
mov $F2,#$7D : mov a,$F3 : cmp a,!echoDelay : beq .branch_noChange

; Echo timer = min(0, [echo timer]) - 1 - [DSP echo delay]
and a,#$0F : eor a,#$FF
bbc7 !echoTimer,+
clrc : adc a,!echoTimer

+
mov !echoTimer,a

.spcInitialisation
; Clear echo DSP registers
mov y,#$04

-
mov a,dspRegisterAddresses-1+y : mov $F2,a : mov $F3,#$00
dbnz y,-

; Disable echo buffer writes
mov $F2,#$6C : set5 $F3

mov a,!echoDelay : mov $F2,#$7D : mov $F3,a

.branch_noChange
; DSP echo buffer address = $10000 - [echo delay] * 800h
asl a : asl a : asl a : eor a,#$FF : inc a ;: setc : adc a,#!echoBufferEnd>>8
mov y,#$6D
jmp writeDspRegisterDirect
}

; $1AF1
setPercussionInstrumentsIndex: ; Track command FAh
{
mov !percussionInstrumentsBaseIndex,a
ret
}

; $1B03
maybeDoPitchSlide:
{
mov a,!trackPitchSlideTimers+x : bne setTrackTargetPitch_ret
mov a,(!trackPointers+x) : cmp a,#$F9 : bne setTrackTargetPitch_ret
call incrementTrackPointer
call getNextTrackDataByte

; Fall through
}

; $1B13
pitchSlide: ; Track command F9h
{
mov !trackPitchSlideDelayTimers+x,a
call getNextTrackDataByte : mov !trackPitchSlideTimers+x,a
call getNextTrackDataByte : clrc : adc a,!musicTranspose : adc a,!trackTransposes+x

; Fall through
}

; $1B23
setTrackTargetPitch:
{
and a,#$7F : mov !trackTargetNotes+x,a
setc : sbc a,!trackNotes+x : mov y,!trackPitchSlideTimers+x : push y : pop x : call division : mov !trackNoteDeltas+x,a : mov a,y : mov !trackNoteDeltas+1+x,a

.ret
ret
}

miscCommand:
{
; Jump to [!miscCommandPointers + [A] * 2] while preserving X
asl a : mov y,a : mov a,miscCommandPointers+1+y : push a : mov a,miscCommandPointers+y : push a : ret
}

miscCommandPointers:
{
dw \
    setNoteLengthTable,\
    setEchoFirFilters,\
    setDPMiscCommand
}

miscCommandParameterBytes:
{
db $02,$02,$02
}

setNoteLengthTable:
{
call getNextTrackDataByte : mov !p_noteRingLengthTable,a
call getNextTrackDataByte : mov !p_noteRingLengthTable+1,a
ret
}

setEchoFirFilters:
{
call getNextTrackDataByte : mov !p_echoFirFilters,a
call getNextTrackDataByte : mov !p_echoFirFilters+1,a
ret
}

setDPMiscCommand:
{
call getNextTrackDataByte : push a : call getNextTrackDataByte : pop a
push x : mov x,a : mov a,y : mov (x),a : pop x
ret
}

; $1B3B
getTrackNote:
{
mov a,!trackNotes+x : mov !note+1,a : mov a,!trackSubnotes+x : mov !note,a
ret
}

; $1B46
division:
{
;; Parameters:
;;     A: Quotient / 100h
;;     X: Divisor
;;     Carry: If set, quotient is assumed to be negative. Otherwise, unsigned division

notc : ror !signBit : bpl +
eor a,#$FF : inc a

+
; YA = [A] / [X] * 100h + ([A] % [X]) * 100h / [X]
mov y,#$00 : div ya,x : push a : mov a,#$00 : div ya,x : pop y

mov x,!trackIndex

; Fall through
}

; $1B58
absoluteValue:
{
bbc7 !signBit,+
movw !misc0,ya : movw ya,!zero : subw ya,!misc0

+
ret
}

; $1B62
trackCommandPointers:
{
dw \
    selectInstrument,\
    staticPanning,\
    dynamicPanning,\
    staticVibrato,\
    endVibrato,\
    staticMusicVolume,\
    dynamicMusicVolume,\
    staticMusicTempo,\
    dynamicMusicTempo,\
    musicTranspose,\
    transpose,\
    tremolo,\
    endTremolo,\
    staticVolume,\
    dynamicVolume,\
    repeatSubsection,\
    dynamicVibrato,\
    slideOut,\
    slideIn,\
    endSlide,\
    subtranspose,\
    staticEcho,\
    endEcho,\
    echoParameters,\
    dynamicEchoVolume,\
    pitchSlide,\
    setPercussionInstrumentsIndex,\
    miscCommand
}

; $1BA0
trackCommandParameterBytes:
{
db $01, $01, $02, $03, $00, $01, $02, $01, $02, $01, $01, $03, $00, $01, $02, $03,\
   $01, $03, $03, $00, $01, $03, $00, $03, $03, $03, $01, $03
}

; $1BBF
handleTrackVolume:
{
mov a,!trackDynamicVolumeTimers+x : beq .branch_dynamicVolume_end
or (!musicVoiceVolumeUpdateBitset),(!musicVoiceBitset)
dec !trackDynamicVolumeTimers+x : bne +
mov a,#$00 : mov !trackVolumes+x,a : mov a,!trackTargetVolumes+x
bra ++

+
clrc : mov a,!trackVolumes+x : adc a,!trackVolumeDeltas+x : mov !trackVolumes+x,a : mov a,!trackVolumes+1+x : adc a,!trackVolumeDeltas+1+x

++
mov !trackVolumes+1+x,a
.branch_dynamicVolume_end

mov y,!trackTremoloExtents+x : beq .branch_noTremolo
mov a,!trackTremoloDelays+x : cbne !trackTremoloDelayTimers+x,.branch_tremoloDelay
or (!musicVoiceVolumeUpdateBitset),(!musicVoiceBitset)
mov a,!trackTremoloPhases+x : bpl +
inc y : bne +
mov a,#$80
bra ++

+
clrc : adc a,!trackTremoloRates+x

++
mov !trackTremoloPhases+x,a
call calculateTrackOutputVolume
bra .branch_tremolo_end

.branch_tremoloDelay
inc !trackTremoloDelayTimers+x

.branch_noTremolo
mov a,#$FF : call calculateTrackOutputVolume_noTremolo

.branch_tremolo_end
mov a,!trackDynamicPanningTimers+x : beq .branch_dynamicPanning_end
or (!musicVoiceVolumeUpdateBitset),(!musicVoiceBitset)
dec !trackDynamicPanningTimers+x
bne +
mov a,#$00 : mov !trackPanningBiases+x,a : mov a,!trackTargetPanningBiases+x
bra ++

+
clrc : mov a,!trackPanningBiases+x : adc a,!trackPanningBiasDeltas+x : mov !trackPanningBiases+x,a : mov a,!trackPanningBiases+1+x : adc a,!trackPanningBiasDeltas+1+x

++
mov !trackPanningBiases+1+x,a
.branch_dynamicPanning_end

mov a,!musicVoiceBitset : and a,!musicVoiceVolumeUpdateBitset : beq writeDspVoiceVolumes_ret
mov a,!trackPanningBiases+1+x : mov y,a : mov a,!trackPanningBiases+x : movw !panningBias,ya

; Fall through
}

; $1C4A
writeDspVoiceVolumes:
{
; This function does panned volume calculation where [$10] / 1400h is the panning bias (so 0 is fully right, 1400h is fully left).

; $1E1D..31 is a table of multipliers to be used for values of [$10] that are multiples of 100h,
; the multiplier used for values of [$10] that are not multiples of 100h is given by linearly interpolation of the closest values from the table.

; So given
;     i_0 = [$10] / 100h
;     i_1 = [$10] / 100h + 1
;
; the indices for the $1E1D table for the multiples of 100h less than and greater than [$10] respectively,
; let
;     y_0 = [$1E1D + i_0]
;     y_1 = [$1E1D + i_1]
;
; be the volume multipliers corresponding to values of $10
;     x_0 = i_0 * 100h
;     x_1 = i_1 * 100h
;
; and let x be the value of [$10], then
;     y = (x - x_0) * (y_1 - y_0) / (x_1 - x_0) + y_0
;
; is the interpolated volume multiplier. Note that x_1 - x_0 = 100h and x - x_0 = [$10] % 100h


; Let i = [$10] / 100h
; Let dy = [$1E1D + i + 1] - [$1E1D + i]
; Let x_l = [$10] % 100h
; Let x_r = (1400h - [$10]) % 100h
; Let y_0 = [$1E1D + i]

; Left volume  = (dy * x_l / 100h + y_0) * [track $0321] / 100h
; Right volume = (dy * x_r / 100h + y_0) * [track $0321] / 100h

; If [track $0351] & 80h != 0:
;     Left volume *= -1

; If [track $0351] & 40h != 0:
;     Right volume *= -1

mov a,x : xcn a : lsr a : mov !dspVoiceVolumeIndex,a

.loop
{
mov y,!panningBias+1 : mov a,panningVolumeMultipliers+1+y : setc : sbc a,panningVolumeMultipliers+y : mov y,!panningBias : mul ya : mov a,y
mov y,!panningBias+1 : clrc : adc a,panningVolumeMultipliers+y : mov y,a : mov a,!trackOutputVolumes+x : mul ya

; Handle phase inversion
mov a,!trackPhaseInversionOptions+x : asl a
bbc0 !dspVoiceVolumeIndex,+
asl a

+
mov a,y
bcc +
eor a,#$FF : inc a

+
mov y,!dspVoiceVolumeIndex : call writeDspRegister
mov y,#$14 : mov a,#$00 : subw ya,!panningBias : movw !panningBias,ya
inc !dspVoiceVolumeIndex : bbc1 !dspVoiceVolumeIndex,.loop
}

.ret
ret
}

; $1C88
handleCurrentNote:
{
movw ya,!p_tracker : push y : push a
mov a,!trackNoteRingTimers+x : bne + : jmp .branch_continuePlaying : +
dec !trackNoteRingTimers+x : beq +
mov a,!noteEndInTicks : cmp a,!trackNoteTimers+x : beq +
jmp .branch_continuePlaying

+
; Note ring has ended or note is ending in two ticks
mov !misc1,!trackerTimer
mov a,!trackRepeatedSubsectionCounters+x : mov !misc1+1,a
mov a,!trackPointers+x : mov y,!trackPointers+1+x

.loop_sections
movw !misc0,ya
mov y,#$00

.loop_commands
mov a,(!misc0)+y : beq .branch_end : bmi .branch_command

.loop_noteParameters
inc y : bmi .branch_note
mov a,(!misc0)+y
bpl .loop_noteParameters

.branch_command
bbc1 !enableLateKeyOff,+
cmp a,#$C9 : bcc .branch_continuePlaying

+
cmp a,#$C8 : beq .branch_continuePlaying
cmp a,#$EF : beq .branch_repeatSubsection
cmp a,#$FB : beq .branch_miscCommand
cmp a,#$E0 : bcc .branch_note
push y : mov y,a : pop a : adc a,trackCommandParameterBytes-$E0+y : mov y,a
bra .loop_commands

.branch_end
mov a,!misc1+1 : bne .branch_endSubsection
bbc0 !enableLateKeyOff,.branch_note

.loop_tracker
call getNextTrackerCommand
bne .branch_newTrackData
mov y,a : beq .branch_note

dec !misc1 : bpl +
mov !misc1,a

+
call getNextTrackerCommand
and !misc1,!misc1 : beq .loop_tracker
movw !p_tracker,ya
bra .loop_tracker

.branch_newTrackData
movw !noteOrPanningBias,ya
mov a,x : mov y,a
mov a,(!noteOrPanningBias)+y : push a : inc y : mov a,(!noteOrPanningBias)+y : mov y,a : pop a
bra .loop_sections

.branch_endSubsection
dbnz !misc1+1,+
mov a,!trackRepeatedSubsectionReturnAddresses+1+x : push a : mov a,!trackRepeatedSubsectionReturnAddresses+x : pop y
bra .loop_sections

+
mov a,!trackRepeatedSubsectionAddresses+1+x : push a : mov a,!trackRepeatedSubsectionAddresses+x : pop y
bra .loop_sections

.branch_repeatSubsection
inc y : mov a,(!misc0)+y : push a : inc y : mov a,(!misc0)+y : mov y,a : pop a
jmp .loop_sections

.branch_note
mov a,!musicVoiceBitset : mov y,#$5C : call writeDspRegister

.branch_continuePlaying
clr7 !noteModifiedFlag
pop a : pop y : movw !p_tracker,ya
mov a,!trackPitchSlideTimers+x : beq .branch_pitchSlide_end
mov a,!trackPitchSlideDelayTimers+x : beq +
dec !trackPitchSlideDelayTimers+x
bra .branch_pitchSlide_end

.branch_miscCommand
inc y : mov a,(!misc0)+y : push y : mov y,a : pop a : adc a,miscCommandParameterBytes+y : mov y,a
jmp .loop_commands

+
set7 !noteModifiedFlag
dec !trackPitchSlideTimers+x
bne +
mov a,!trackTargetNotes+1+x : mov !trackSubnotes+x,a
mov a,!trackTargetNotes+x
bra ++

+
clrc : mov a,!trackSubnotes+x : adc a,!trackNoteDeltas+x : mov !trackSubnotes+x,a : mov a,!trackNotes+x : adc a,!trackNoteDeltas+1+x

++
mov !trackNotes+x,a
.branch_pitchSlide_end

call getTrackNote
mov a,!trackVibratoExtents+x : beq playNoteIfModified
mov a,!trackVibratoDelays+x : cbne !trackVibratoDelayTimers+x,playNoteIfModified2
mov a,!trackDynamicVibratoTimers+x : cmp a,!trackDynamicVibratoLengths+x : bne +
mov a,!trackStaticVibratoExtents+x
bra .branch_dynamicVibrato_end

+
setp : inc !trackDynamicVibratoTimers&$FF+x : clrp
mov y,a : beq +
mov a,!trackVibratoExtents+x

+
clrc : adc a,!trackVibratoExtentDeltas+x
.branch_dynamicVibrato_end

mov !trackVibratoExtents+x,a
mov a,!trackVibratoPhases+x : clrc : adc a,!trackVibratoRates+x : mov !trackVibratoPhases+x,a

; Fall through
}

; $1D56
playNoteWithVibrato:
{
mov !signBit,a
asl a : asl a
bcc +
eor a,#$FF

+
mov y,a
mov a,!trackVibratoExtents+x
cmp a,#$F1 : bcc +
and a,#$0F : mul ya
bra ++

+
mul ya : mov a,y : mov y,#$00

++
call addition

.goToPlayNote
jmp playNote
}

; $1D74
playNoteIfModified2:
{
inc !trackVibratoDelayTimers+x

; Fall through
}

; $1D76
playNoteIfModified:
{
bbs7 !noteModifiedFlag,playNoteWithVibrato_goToPlayNote
ret
}

; $1D7A
updatePlayingTrack:
{
clr7 !noteModifiedFlag
mov a,!trackTremoloExtents+x : beq +
mov a,!trackTremoloDelays+x : cbne !trackTremoloDelayTimers+x,+
call updatePlayingTrackOutputVolume

+
mov a,!trackPanningBiases+1+x : mov y,a : mov a,!trackPanningBiases+x : movw !panningBias,ya
mov a,!trackDynamicPanningTimers+x : beq +
mov a,!trackPanningBiasDeltas+1+x : mov y,a : mov a,!trackPanningBiasDeltas+x : call adjustByTicPercentage

+
bbc7 !noteModifiedFlag,+
call writeDspVoiceVolumes

+
clr7 !noteModifiedFlag
call getTrackNote
mov a,!trackPitchSlideTimers+x : beq +
mov a,!trackPitchSlideDelayTimers+x : bne +
mov a,!trackNoteDeltas+1+x : mov y,a : mov a,!trackNoteDeltas+x : call adjustByTicPercentage

+
mov a,!trackVibratoExtents+x : beq playNoteIfModified
mov a,!trackVibratoDelays+x : cbne !trackVibratoDelayTimers+x,playNoteIfModified
mov y,!musicTrackClock+1 : mov a,!trackVibratoRates+x : mul ya : mov a,y : clrc : adc a,!trackVibratoPhases+x
jmp playNoteWithVibrato
}

; $1DD5
adjustByTicPercentage:
{
set7 !noteModifiedFlag
mov !signBit,y : call absoluteValue : push y
mov y,!musicTrackClock+1 : mul ya : mov !misc0,y : mov !misc0+1,#$00
mov y,!musicTrackClock+1 : pop a : mul ya : addw ya,!misc0

; Fall through
}

; $1DEB
addition:
{
call absoluteValue
addw ya,!noteOrPanningBias : movw !noteOrPanningBias,ya
ret
}

; $1DF3
updatePlayingTrackOutputVolume:
{
set7 !noteModifiedFlag
mov y,!musicTrackClock+1 : mov a,!trackTremoloRates+x : mul ya : mov a,y : clrc : adc a,!trackTremoloPhases+x

; Fall through
}

; $1E00
calculateTrackOutputVolume:
{
; A = |[A]| * 2 - ([A] >> 7)
asl a : bcc +
eor a,#$FF

+
; A = FFh - [A] * [track tremolo extent] / 100h
mov y,!trackTremoloExtents+x : mul ya : mov a,y : eor a,#$FF

.noTremolo
mov y,!musicVolume+1 : mul ya
mov a,!trackNoteVolumes+x : mul ya
mov a,!trackVolumes+1+x : mul ya
mov a,y : mul ya
mov a,y : mov !trackOutputVolumes+x,a
ret
}
