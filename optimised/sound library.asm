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
;;     YA: Pointer to sound instruction list pointer set

; Requires !i_soundLibrary to be set

movw !sound_instructionListPointerSet,ya

; First byte (configuration)
mov y,#$00 : mov a,(!sound_instructionListPointerSet)+y : mov y,a
; Number of channels in low nybble
and a,#$0F : beq .ret : mov !misc1,a
; Priority in high nybble
mov a,y : xcn a : and a,#$0F : mov y,!i_soundLibrary : mov !sound_priorities-1+y,a

mov !misc0,#$08

.loop
mov y,!misc0 : mov a,!sound_voiceOrder-1+y : mov x,a
lsr a : mov y,a : mov a,channelBitsets+y : mov !misc1+1,a

; Check if voice is not occupied
and a,!enableSoundEffectVoices : bne .skipVoice

; Initialise sound variables
mov a,!i_soundLibrary : mov !sound_libraryIndices+x,a
mov a,!misc1 : asl a : dec a : mov y,a
mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionLists+x,a : inc y : mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionLists+1+x,a
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
mov y,!i_soundLibrary : or a,!sound_enabledVoices-1+y : mov !sound_enabledVoices-1+y,a

; Return if no channels left
dec !misc1 : beq .ret

.skipVoice
dbnz !misc0,.loop

.ret
ret
}


resetSound:
{
; Requires !i_soundLibrary to be set
mov x,#$00
mov !sound_voiceBitset,#$01

-
mov a,!sound_libraryIndices+x : cbne !i_soundLibrary,+
call resetSoundChannel

+
inc x : inc x
asl !sound_voiceBitset : bne -
ret
}

resetSoundChannel:
{
;; Parameters:
;;     X: Track index. Range 0..Eh

; Requires !sound_voiceBitset to be set

mov a,!sound_voiceBitset : tclr !enableSoundEffectVoices,a
mov $F2,#$5C : mov $F3,a
tset !sound_endedVoices,a
eor a,#$FF : setp : mov.b y,!sound_libraryIndices+x : clrp : and a,!sound_enabledVoices-1+y : mov !sound_enabledVoices-1+y,a
mov a,#$00 : mov !sound_libraryIndices+x,a

; Reset sound if no enabled voices
mov a,!sound_enabledVoices-1+y : bne +
mov !sounds-1+y,a
mov !sound_priorities-1+y,a

+
ret
}


getNextDataByte:
{
;; Parameters:
;;     X: Track index. Range 0..Eh
mov a,!sound_p_instructionLists+x : mov y,!sound_p_instructionLists+1+x : movw !misc0,ya
mov y,#$00 : mov a,(!misc0)+y
inc !sound_p_instructionLists+x : bne + : inc !sound_p_instructionLists+1+x : +
ret
}


processSounds:
{
mov x,#$00
mov !sound_voiceBitset,#$01

-
mov a,!sound_libraryIndices+x : beq +
call processSoundChannel

+
inc x : inc x
asl !sound_voiceBitset : bne -
ret
}


processSoundChannel:
{
;; Parameters:
;;     X: Track index. Range 0..Eh

; Requires !sound_voiceBitset to be set
; Valid indexed non-DP address mode opcodes are mov/cmp/adc/sbc/and/or/eor

mov a,!sound_instructionTimers+x : dec a : mov !sound_instructionTimers+x,a : beq + : jmp .branch_processInstruction_end : +

; Note has ended
mov a,!sound_legatoFlags+x : bne .loop_commands
mov !sound_pitchSlideFlags+x,a
mov !sound_subnoteDeltas+x,a
mov !sound_targetNotes+x,a
mov a,!sound_releaseFlags+x : bne +
inc a : mov !sound_instructionTimers+x,a : mov !sound_releaseFlags+x,a
or !keyOffFlags,!sound_voiceBitset
ret

+
; Note release has ended
mov a,#$00 : mov !sound_releaseFlags+x,a

if defined("noiseSounds")
mov a,!sound_voiceBitset : tclr !noiseEnableFlags,a
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
call getNextDataByte : mov !sound_adsrSettings+x,a
call getNextDataByte : mov !sound_adsrSettings+1+x,a
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
mov a,!sound_p_instructionLists+x : mov !sound_repeatPoints+x,a
mov a,!sound_p_instructionLists+1+x : mov !sound_repeatPoints+1+x,a
call getNextDataByte

+
cmp a,#$FD : bne .branch_repeatCommand

; FDh - decrement repeat counter and repeat if non-zero
mov a,!sound_repeatCounters+x : dec a : mov !sound_repeatCounters+x,a : bne + : jmp .loop_commands : +

; FBh - repeat
.loop_repeatCommand
mov a,!sound_repeatPoints+x : mov !sound_p_instructionLists+x,a
mov a,!sound_repeatPoints+1+x : mov !sound_p_instructionLists+1+x,a
call getNextDataByte

.branch_repeatCommand
cmp a,#$FB : bne + : jmp .loop_repeatCommand : +

if defined("noiseSounds")
cmp a,#$FC : bne +

; FCh - enable noise
or !noiseEnableFlags,!sound_voiceBitset
jmp .loop_commands

+
endif

cmp a,#$80 : bcs +
; 0..7Fh - select instrument
call setInstrumentSettings
call getNextDataByte

; Process note instruction

+
; Note
; F0h is a tie
cmp a,#$F0 : beq +
mov !sound_notes+x,a
mov a,#$00 : mov !sound_subnotes+x,a

+
; Volume
call getNextDataByte : mov y,a
; Save track output volume and phase inversion options
mov a,!trackOutputVolumes+x : push a
mov a,!trackPhaseInversionOptions+x : push a

mov a,y : mov !trackOutputVolumes+x,a
mov a,!sound_panningBiases+x : mov !trackPhaseInversionOptions+x,a
and a,#$1F : mov !panningBias+1,a : mov !panningBias,#$00
call writeDspVoiceVolumes
; Restore track output volume and phase inversion options
pop a : mov !trackPhaseInversionOptions+x,a
pop a : mov !trackOutputVolumes+x,a

; Length
call getNextDataByte : mov !sound_instructionTimers+x,a
mov a,!sound_updateAdsrSettingsFlags+x : beq +
mov a,x : xcn a : lsr a : or a,#$05 : mov y,a : mov a,!sound_adsrSettings+x : call writeDspRegisterDirect
inc y : mov a,!sound_adsrSettings+1+x : call writeDspRegisterDirect

+
mov a,!sound_legatoFlags+x : bne .branch_processInstruction_end
or !keyOnFlags,!sound_voiceBitset

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
call playNoteDirect
ret
}
