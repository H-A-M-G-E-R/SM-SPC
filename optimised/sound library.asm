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


songSpecificSoundInitialisation:
{
;; Parameters:
;;     X: Sound index. Range C0h..FFh

; Requires !i_soundLibrary to be set

mov a,x : and a,#$3F : asl a : mov y,a
mov a,(!p_songSpecificSoundInstructionLists)+y : push a : inc y : mov a,(!p_songSpecificSoundInstructionLists)+y : mov y,a : pop a

; Fall through
}


soundInitialisation:
{
;; Parameters:
;;     X: Sound index
;;     YA: Pointer to sound instruction list pointer set

; Requires !i_soundLibrary to be set

movw !sound_instructionListPointerSet,ya

; First byte (configuration)
mov y,#$00 : mov !dspVoiceVolumeIndex,y : mov a,(!sound_instructionListPointerSet)+y : mov y,a
; Number of channels in low nybble
and a,#$0F : beq .ret : mov !misc1,a
; Priority in high nybble
mov a,y : xcn a : and a,#$0F : mov y,!i_soundLibrary : mov !sound_priorities-1+y,a

mov !sounds-1+y,x

mov !misc0,#$08

.loop
mov y,!misc0 : mov a,!sound_voiceOrder-1+y : mov x,a
lsr a : mov y,a : mov a,channelBitsets+y : mov !misc1+1,a

; Check if voice is not occupied
and a,!sound_activeVoices : bne .skipVoice

inc !dspVoiceVolumeIndex

; Initialise sound variables
mov a,!i_soundLibrary : mov !sound_libraryIndices+x,a
mov a,!misc1 : asl a : dec a : mov y,a
mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionLists+x,a : inc y : mov a,(!sound_instructionListPointerSet)+y : mov !sound_p_instructionLists+1+x,a
mov a,#$00
mov !sound_releaseFlags+x,a
if defined("adsrSoundCommand")
mov !sound_updateAdsrSettingsFlags+x,a
endif
mov !sound_targetNotes+x,a
mov !sound_legatoFlags+x,a
mov !sound_pitchSlideLegatoFlags+x,a
mov !sound_subtransposes+x,a
inc a : mov !sound_instructionTimers+x,a
mov a,#$0A : mov !sound_panningBiases+x,a

mov a,!misc1+1
tset !enableSoundEffectVoices,a
tset !sound_activeVoices,a
tclr !echoEnableFlags,a
mov y,!i_soundLibrary : or a,!sound_enabledVoices-1+y : mov !sound_enabledVoices-1+y,a

; Return if no channels left
dec !misc1 : beq .ret

.skipVoice
dbnz !misc0,.loop

; Could not initialise all channels, reset sound if no channels are initialised
mov y,!i_soundLibrary : mov a,!dspVoiceVolumeIndex : beq resetSoundChannel_resetSound

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

mov a,!sound_voiceBitset : tclr !sound_activeVoices,a
mov $F2,#$5C : mov $F3,a
eor a,#$FF : setp : mov.b y,!sound_libraryIndices+x : clrp : and a,!sound_enabledVoices-1+y : mov !sound_enabledVoices-1+y,a
mov a,#$00 : mov !sound_libraryIndices+x,a

; Reset sound if no enabled voices
mov a,!sound_enabledVoices-1+y : bne +

.resetSound
mov !sounds-1+y,a
mov !sound_priorities-1+y,a

+
ret
}


getNextDataByte:
{
;; Parameters:
;;     X: Track index. Range 0..Eh
mov a,(!sound_p_instructionLists+x)
inc !sound_p_instructionLists+x : bne + : inc !sound_p_instructionLists+1+x : +
ret
}


processSoundChannel:
{
;; Parameters:
;;     X: Track index. Range 0..Eh

; Requires !sound_voiceBitset to be set
; Valid indexed non-DP address mode opcodes are mov/cmp/adc/sbc/and/or/eor

; Note length of FFh = play forever
mov a,!sound_instructionTimers+x : cmp a,#$FF : beq +
dec a : mov !sound_instructionTimers+x,a : beq ++

+
jmp .branch_processInstruction_end

++
; Note has ended
mov a,!sound_legatoFlags+x : bne .loop_commands
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
cmp a,#$FF : bne +

; FFh - end
jmp resetSoundChannel

+
cmp a,#$F5 : bcc +
call handleSoundCommand
bra .loop_commands

+
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

; Update ADSR
if defined("adsrSoundCommand")
mov a,!sound_updateAdsrSettingsFlags+x : beq +
mov a,x : xcn a : lsr a : or a,#$05 : mov y,a : mov a,!sound_adsrSettings+x : call writeDspRegisterDirect
inc y : mov a,!sound_adsrSettings+1+x : call writeDspRegisterDirect

+
endif
mov a,!sound_legatoFlags+x : bne .branch_processInstruction_end
or !keyOnFlags,!sound_voiceBitset

.branch_processInstruction_end
; Handle pitch slide
mov a,!sound_targetNotes+x : beq .branch_playNote
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
mov !sound_targetNotes+x,a
mov !sound_legatoFlags+x,a

; Play note
.branch_playNote
mov a,!sound_subnotes+x : clrc : adc a,!sound_subtransposes+x : mov !note,a
mov a,!sound_notes+x : adc a,#$00 : mov !note+1,a
call playNoteDirect
ret
}


handleSoundCommand:
{
asl a : mov y,a : mov a,soundCommandPointers-($F5*2&$FF)+1+y : push a : mov a,soundCommandPointers-($F5*2&$FF)+y : push a
mov a,y
ret
}


soundCommandPointers:
{
dw \
    soundCommandF5_legatoPitchSlide,\
    soundCommandF6_staticPanning,\
    soundCommandF7_subtranspose,\
    soundCommandF8_pitchSlide,\
    soundCommandF9_setAdsrSettings,\
    $0000,\
    soundCommandFB_repeat,\
    soundCommandFC_enableNoise,\
    soundCommandFD_repeatLimited,\
    soundCommandFE_setRepeat
}


soundCommandF8_pitchSlide:
{
mov a,#$00

; Fall through
}

soundCommandF5_legatoPitchSlide:
{
mov !sound_pitchSlideLegatoFlags+x,a
call getNextDataByte : mov !sound_subnoteDeltas+x,a
call getNextDataByte : mov !sound_targetNotes+x,a
ret
}

soundCommandF6_staticPanning:
{
call getNextDataByte : mov !sound_panningBiases+x,a
ret
}

soundCommandF7_subtranspose:
{
call getNextDataByte : mov !sound_subtransposes+x,a
ret
}

soundCommandF9_setAdsrSettings:
{
if defined("adsrSoundCommand")
mov !sound_updateAdsrSettingsFlags+x,a
call getNextDataByte : mov !sound_adsrSettings+x,a
call getNextDataByte : mov !sound_adsrSettings+1+x,a
ret
endif
}

soundCommandFC_enableNoise:
{
if defined("noiseSounds")
or !noiseEnableFlags,!sound_voiceBitset
ret
endif
}

soundCommandFD_repeatLimited:
{
mov a,!sound_repeatCounters+x : dec a : mov !sound_repeatCounters+x,a : beq soundCommandFB_repeat_ret

; Fall through
}

soundCommandFB_repeat:
{
mov a,!sound_repeatPoints+x : mov !sound_p_instructionLists+x,a
mov a,!sound_repeatPoints+1+x : mov !sound_p_instructionLists+1+x,a

.ret
ret
}

soundCommandFE_setRepeat:
{
call getNextDataByte : mov !sound_repeatCounters+x,a
mov a,!sound_p_instructionLists+x : mov !sound_repeatPoints+x,a
mov a,!sound_p_instructionLists+1+x : mov !sound_repeatPoints+1+x,a
ret
}
