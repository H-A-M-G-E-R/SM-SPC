determineSoundVoiceOrder:
{
mov y,#7

; Empty tracks
mov x,#7*2

-
mov a,!trackPointers+1+x : bne +
mov a,x : mov !sound_voiceOrder+y,a : dec y

+
dec x : dec x : bpl -

; Non-empty tracks
mov x,#7*2

-
mov a,!trackPointers+1+x : beq +
mov a,x : mov !sound_voiceOrder+y,a : dec y

+
dec x : dec x : bpl -

ret
}


soundInitialisation:
{
;; Parameters:
;;     X: Global channel index. Range 0..7
;;     !misc1: Number of sound channels (non-zero)

; Requires !i_soundLibrary to be set

mov !misc0,#$08

.loop
mov y,!misc0 : mov a,!sound_voiceOrder-1+y : mov !misc0+1,a
lsr a : mov y,a : mov a,channelBitsets+y : mov !misc1+1,a

; Check if voice is not occupied
and a,!enableSoundEffectVoices : bne .skipVoice

; Initialise sound variables
mov a,!misc1 : asl a : dec a : mov y,a
mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionListsLow+x,a : inc y : mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionListsHigh+x,a
mov a,!misc0+1 : mov !sound_voiceIndices+x,a
mov a,#$00
mov !sound_releaseFlags+x,a
mov !sound_updateAdsrSettingsFlags+x,a
mov !sound_pitchSlideFlags+x,a
mov !sound_legatoFlags+x,a
mov !sound_pitchSlideLegatoFlags+x,a
inc a : mov !sound_instructionTimers+x,a
mov a,#$0A : mov !sound_panningBiases+x,a

mov a,!misc1+1
tset !enableSoundEffectVoices,a
tclr !echoEnableFlags,a
mov !sound_voiceBitsets+x,a
mov y,!i_soundLibrary : or a,!sound_enabledVoices+y : mov !sound_enabledVoices+y,a

; Return if no channels left
dec !misc1 : beq .ret

inc x

.skipVoice
dbnz !misc0,.loop

.ret
ret
}


resetSoundChannel:
{
;; Parameters:
;;     X: Global channel index. Range 0..7

; Requires !i_soundLibrary to be set

mov a,!sound_voiceBitsets+x : beq +

tclr !enableSoundEffectVoices,a
mov $F2,#$5C : mov $F3,a
tset !sound_endedVoices,a
eor a,#$FF : mov y,!i_soundLibrary : and a,!sound_enabledVoices+y : mov !sound_enabledVoices+y,a
mov a,#$00 : mov !sound_voiceBitsets+x,a

; Reset sound if no enabled voices
mov a,!sound_enabledVoices+y : bne +
mov !sounds+y,a
mov !sound_priorities+y,a

+
ret
}


getNextDataByte:
{
;; Parameters:
;;     X: Global channel index. Range 0..7
mov a,!sound_p_instructionListsLow+x : mov y,!sound_p_instructionListsHigh+x : movw !misc0,ya
mov y,#$00 : mov a,(!misc0)+y
inc !sound_p_instructionListsLow+x : bne + : inc !sound_p_instructionListsHigh+x : +
ret
}


processSoundChannel:
{
;; Parameters:
;;     X: Global channel index. Range 0..7

; Requires !i_soundLibrary to be set
; Valid indexed non-DP address mode opcodes are mov/cmp/adc/sbc/and/or/eor

mov !i_globalChannel,x

mov a,!sound_voiceBitsets+x : bne + : ret : +

mov a,!sound_voiceIndices+x : mov !i_voice,a
mov a,!sound_instructionTimers+x : dec a : mov !sound_instructionTimers+x,a : beq + : jmp .branch_processInstruction_end : +

; Note has ended
mov a,!sound_legatoFlags+x : bne .loop_commands
mov !sound_pitchSlideFlags+x,a
mov !sound_subnoteDeltas+x,a
mov !sound_targetNotes+x,a
mov a,!sound_releaseFlags+x : bne +
inc a : mov !sound_instructionTimers+x,a : mov !sound_releaseFlags+x,a
mov a,!sound_voiceBitsets+x : tset !keyOffFlags,a
ret

+
; Note release has ended
mov a,#$00 : mov !sound_releaseFlags+x,a

if defined("noiseSounds")
mov a,!sound_voiceBitsets+x : tclr !noiseEnableFlags,a
endif

.loop_commands
call getNextDataByte
cmp a,#$F6 : bne +

; F6h pp - panning bias = p / 14h
call getNextDataByte : mov !sound_panningBiases+x,a
bra .loop_commands

+
cmp a,#$F9 : bne +

; F9h aaaa - voice's ADSR settings = a
call getNextDataByte : mov !sound_adsrSettingsLow+x,a
call getNextDataByte : mov !sound_adsrSettingsHigh+x,a
mov a,#$FF : mov !sound_updateAdsrSettingsFlags+x,a
bra .loop_commands

+
cmp a,#$F5 : bne +

; F5h dd tt - legato pitch slide with subnote delta = d, target note = t
mov !sound_pitchSlideLegatoFlags+x,a
bra ++

+
cmp a,#$F8 : bne .branch_pitchSlide_end

; F8h dd tt -        pitch slide with subnote delta = d, target note = t
mov a,#$00 : mov !sound_pitchSlideLegatoFlags+x,a

++
call getNextDataByte : mov !sound_subnoteDeltas+x,a
call getNextDataByte : mov !sound_targetNotes+x,a
mov !sound_pitchSlideFlags+x,a
call getNextDataByte
.branch_pitchSlide_end

cmp a,#$FF : bne +

; FFh - end
jmp resetSoundChannel

+
cmp a,#$FE : bne +

; FEh cc - set repeat pointer with repeat counter = c
call getNextDataByte : mov !sound_repeatCounters+x,a
mov a,!sound_p_instructionListsLow+x : mov !sound_repeatPointsLow+x,a
mov a,!sound_p_instructionListsHigh+x : mov !sound_repeatPointsHigh+x,a
call getNextDataByte

+
cmp a,#$FD : bne .branch_repeatCommand

; FDh - decrement repeat counter and repeat if non-zero
mov a,!sound_repeatCounters+x : dec a : mov !sound_repeatCounters+x,a : bne + : jmp .loop_commands : +

; FBh - repeat
.loop_repeatCommand
mov a,!sound_repeatPointsLow+x : mov !sound_p_instructionListsLow+x,a
mov a,!sound_repeatPointsHigh+x : mov !sound_p_instructionListsHigh+x,a
call getNextDataByte

.branch_repeatCommand
cmp a,#$FB : bne + : jmp .loop_repeatCommand : +

if defined("noiseSounds")
cmp a,#$FC : bne +

; FCh - enable noise
mov a,!sound_voiceBitsets+x : tset !noiseEnableFlags,a
jmp .loop_commands

+
endif

; Process note instruction

; Instrument index
mov x,!i_voice : call setInstrumentSettings

; Volume
mov x,!i_globalChannel : call getNextDataByte : mov y,a
; Save track output volume and phase inversion options
mov x,!i_voice : mov a,!trackOutputVolumes+x : push a
mov a,!trackPhaseInversionOptions+x : push a

mov a,y : mov !trackOutputVolumes+x,a
mov a,#$00 : mov !trackPhaseInversionOptions+x,a

mov x,!i_globalChannel : mov a,!sound_panningBiases+x : mov !panningBias+1,a : mov !panningBias,#$00
mov x,!i_voice : call writeDspVoiceVolumes
; Restore track output volume and phase inversion options
pop a : mov !trackPhaseInversionOptions+x,a
pop a : mov !trackOutputVolumes+x,a

; Note
mov x,!i_globalChannel : call getNextDataByte
; F6h is a tie
cmp a,#$F6 : beq +
mov !sound_notes+x,a
mov a,#$00 : mov !sound_subnotes+x,a

+
; Length
mov x,!i_globalChannel : call getNextDataByte : mov !sound_instructionTimers+x,a
mov a,!sound_updateAdsrSettingsFlags+x : beq +
mov a,!i_voice : asl a : asl a : asl a : or a,#$05 : mov y,a : mov a,!sound_adsrSettingsLow+x : call writeDspRegisterDirect
inc y : mov a,!sound_adsrSettingsHigh+x : call writeDspRegisterDirect

+
mov a,!sound_legatoFlags+x : bne .branch_processInstruction_end
mov a,!sound_voiceBitsets+x : tset !keyOnFlags,a

.branch_processInstruction_end
; Handle pitch slide
mov a,!sound_pitchSlideFlags+x : beq .branch_playNote
mov a,!sound_pitchSlideLegatoFlags+x : beq +
mov !sound_legatoFlags+x,a

+
mov a,!sound_notes+x : cmp a,!sound_targetNotes+x : bcc +
mov a,!sound_subnotes+x : setc : sbc a,!sound_subnoteDeltas+x : mov !sound_subnotes+x,a : bcs .branch_playNote
mov a,!sound_notes+x : dec a
bra ++

+
mov a,!sound_subnoteDeltas+x : clrc : adc a,!sound_subnotes+x : mov !sound_subnotes+x,a : bcc .branch_playNote
mov a,!sound_notes+x : inc a

++
mov !sound_notes+x,a
mov a,!sound_targetNotes+x : setc : sbc a,!sound_notes+x : bne .branch_playNote
mov !sound_pitchSlideFlags+x,a
mov !sound_legatoFlags+x,a

; Play note
.branch_playNote
mov a,!sound_notes+x : mov y,a : mov a,!sound_subnotes+x : movw !note,ya
mov x,!i_voice : call playNoteDirect
ret
}
