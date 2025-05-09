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
;;     !misc1: number of sound channels

; Requires !i_soundLibrary and !i_globalChannel to be set

mov !misc0,#$07

.loop
mov y,!misc0 : mov a,!sound_voiceOrder+y : mov !misc0+1,a
lsr a : mov y,a : mov a,channelBitsets+y : mov !misc1+1,a
and a,!enableSoundEffectVoices : bne .skipVoice

mov a,!misc1 : beq .ret
dec a : mov !misc1,a
asl a : inc a : mov y,a
mov a,#$00 : mov x,!i_globalChannel : mov !sound_i_instructionLists+x,a
mov !sound_releaseFlags+x,a
mov !sound_updateAdsrSettingsFlags+x,a
mov !sound_pitchSlideFlags+x,a
mov !sound_legatoFlags+x,a
mov !sound_pitchSlideLegatoFlags+x,a
inc a : mov !sound_instructionTimers+x,a
mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionListsLow+x,a : inc y : mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionListsHigh+x,a

mov a,!misc0+1 : mov !sound_voiceIndices+x,a
mov a,#$0A : mov !sound_panningBiases+x,a

mov a,!misc1+1
tset !enableSoundEffectVoices,a
tclr !echoEnableFlags,a
mov !sound_voiceBitsets+x,a
mov x,!i_soundLibrary : or a,!sound_enabledVoices+x : mov !sound_enabledVoices+x,a

inc !i_globalChannel

.skipVoice
dec !misc0 : bpl .loop

.ret
ret
}


resetSoundChannel:
{
;; Parameters:
;;     X: Global channel index. Range 0..7

; Requires !i_soundLibrary to be set

mov a,!sound_voiceBitsets+x : beq +

mov !i_globalChannel,x

mov a,!sound_voiceIndices+x : mov !i_voice,a

mov a,!sound_voiceBitsets+x : push a : eor a,#$FF : mov x,!i_soundLibrary : and a,!sound_enabledVoices+x : mov !sound_enabledVoices+x,a
pop a : tclr !enableSoundEffectVoices,a
tset !keyOffFlags,a
mov x,!i_voice : mov a,!trackInstrumentIndices+x : call setInstrumentSettings : mov x,!i_globalChannel
mov a,#$00 : mov !sound_voiceBitsets+x,a

; Reset sound if no enabled voices
mov x,!i_soundLibrary
mov a,!sound_enabledVoices+x : bne +
mov !sounds+x,a
mov !sound_priorities+x,a

+
ret
}


getNextDataByte:
{
;; Parameters:
;;     X: Global channel index. Range 0..7
mov a,!sound_p_instructionListsLow+x : mov y,!sound_p_instructionListsHigh+x : movw !misc0,ya
mov a,!sound_i_instructionLists+x : mov y,a
inc a : mov !sound_i_instructionLists+x,a
mov a,(!misc0)+y
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
mov a,!sound_voiceBitsets+x : tclr !noiseEnableFlags,a

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
mov a,!sound_i_instructionLists+x : mov !sound_repeatPoints+x,a
call getNextDataByte

+
cmp a,#$FD : bne .branch_repeatCommand

; FDh - decrement repeat counter and repeat if non-zero
mov a,!sound_repeatCounters+x : dec a : mov !sound_repeatCounters+x,a : bne + : jmp .loop_commands : +

; FBh - repeat
.loop_repeatCommand
mov a,!sound_repeatPoints+x : mov !sound_i_instructionLists+x,a
call getNextDataByte

.branch_repeatCommand
cmp a,#$FB : bne + : jmp .loop_repeatCommand : +
cmp a,#$FC : bne +

; FCh - enable noise
mov a,!sound_voiceBitsets+x : tset !noiseEnableFlags,a
jmp .loop_commands

; Process note instruction
+
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
mov a,!sound_voiceIndices+x : asl a : asl a : asl a : or a,#$05 : mov y,a : mov a,!sound_adsrSettingsLow+x : call writeDspRegisterDirect
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
