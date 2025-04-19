handleCpuIo3:
{
mov a,#$02 : mov !i_soundLibrary,a

mov a,!disableProcessingCpuIo2 : beq + : +

mov y,!cpuIo3_read_prev
mov a,!cpuIo3_read : mov !cpuIo3_read_prev,a
mov !cpuIo3_write,a
cmp y,!cpuIo3_read : bne .branch_change

.branch_noChange
mov a,!sound3 : bne +
ret

+
jmp processSound3

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo3_read : cmp a,#$01 : beq +
mov a,!sound3LowHealthPriority : cmp a,#$02 : beq .branch_noChange
mov a,!cpuIo3_read : cmp a,#$02 : beq +
mov a,!sound3Priority : bne .branch_noChange

+
mov a,!sound3 : beq +
mov a,#$00 : mov !sound3_enabledVoices,a
call resetSound3Channel0
call resetSound3Channel1

+
mov a,#$00
mov !sound3_channel0_legatoFlag,a
mov !sound3_channel1_legatoFlag,a
mov a,!cpuIo3_write : dec a : asl a : mov !i_sound3,a
mov x,!i_sound3 : mov a,sound3InstructionLists+x : mov !sound3_instructionListPointerSet,a : inc x : mov a,sound3InstructionLists+x : mov !sound3_instructionListPointerSet+1,a
mov a,!cpuIo3_write : mov !sound3,a
cmp a,#$FE : beq processSound3
cmp a,#$FF : beq processSound3
call goToJumpTableEntry

!sc = sound3Configurations_sound ; Shorthand for the `soundN` sublabels within the sound3Configurations label
dw !{sc}1,  !{sc}2,  !{sc}3,  !{sc}4,  !{sc}5,  !{sc}6,  !{sc}7,  !{sc}8,  !{sc}9,  !{sc}A,  !{sc}B,  !{sc}C,  !{sc}D,  !{sc}E,  !{sc}F,  !{sc}10,\
   !{sc}11, !{sc}12, !{sc}13, !{sc}14, !{sc}15, !{sc}16, !{sc}17, !{sc}18, !{sc}19, !{sc}1A, !{sc}1B, !{sc}1C, !{sc}1D, !{sc}1E, !{sc}1F, !{sc}20,\
   !{sc}21, !{sc}22, !{sc}23, !{sc}24, !{sc}25, !{sc}26, !{sc}27, !{sc}28, !{sc}29, !{sc}2A, !{sc}2B, !{sc}2C, !{sc}2D, !{sc}2E, !{sc}2F
}

processSound3:
{
mov a,#$FF : cmp a,!sound3_initialisationFlag : beq +
call sound3Initialisation
mov y,#$00 : mov a,(!sound3_instructionListPointerSet)+y : mov !sound3_channel0_p_instructionListLow,a : call getSound3ChannelInstructionListPointer : mov !sound3_channel0_p_instructionListHigh,a
call getSound3ChannelInstructionListPointer              : mov !sound3_channel1_p_instructionListLow,a : call getSound3ChannelInstructionListPointer : mov !sound3_channel1_p_instructionListHigh,a
mov a,!sound3_channel0_voiceIndex : call sound3MultiplyBy8 : mov !sound3_channel0_dspIndex,a
mov a,!sound3_channel1_voiceIndex : call sound3MultiplyBy8 : mov !sound3_channel1_dspIndex,a

mov y,#$00
mov !sound3_channel0_i_instructionList,y
mov !sound3_channel1_i_instructionList,y

inc y
mov !sound3_channel0_instructionTimer,y
mov !sound3_channel1_instructionTimer,y

+
mov x,#$00+!sound1_n_channels+!sound2_n_channels : mov !i_globalChannel,x : call processSoundChannel
mov x,#$01+!sound1_n_channels+!sound2_n_channels : mov !i_globalChannel,x : call processSoundChannel

ret
}

resetSound3Channel0: : mov x,#$00+!sound1_n_channels+!sound2_n_channels : mov !i_globalChannel,x : jmp resetSoundChannel
resetSound3Channel1: : mov x,#$01+!sound1_n_channels+!sound2_n_channels : mov !i_globalChannel,x : jmp resetSoundChannel

; Sound 3 channel variable pointers
{
sound3ChannelVoiceBitsets:
dw !sound3_channel0_voiceBitset, !sound3_channel1_voiceBitset

sound3ChannelVoiceMasks:
dw !sound3_channel0_voiceMask, !sound3_channel1_voiceMask

sound3ChannelVoiceIndices:
dw !sound3_channel0_voiceIndex, !sound3_channel1_voiceIndex
}

sound3Initialisation:
{
mov a,#$09 : mov !sound3_voiceId,a
mov a,!enableSoundEffectVoices : mov !sound3_remainingEnabledSoundVoices,a
mov a,#$00
mov !sound3_2i_channel,a
mov !sound3_i_channel,a
mov !sound3_channel0_voiceBitset,a
mov !sound3_channel1_voiceBitset,a
mov !sound3_channel0_voiceIndex,a
mov !sound3_channel1_voiceIndex,a
dec a
mov !sound3_initialisationFlag,a
mov !sound3_channel0_voiceMask,a
mov !sound3_channel1_voiceMask,a
mov !sound3_channel0_disableByte,a
mov !sound3_channel1_disableByte,a

.loop
dec !sound3_voiceId : bne +

.ret
ret

+
asl !sound3_remainingEnabledSoundVoices : bcs .loop
mov a,#$00 : cmp a,!sound3_n_voices : beq .ret
dec !sound3_n_voices
mov a,#$00 : mov x,!sound3_i_channel : mov !sound3_channel0_disableByte+x,a
inc !sound3_i_channel
mov a,!sound3_2i_channel : mov x,a
mov a,sound3ChannelVoiceBitsets+x : mov !sound3_p_charVoiceBitset,a
mov a,sound3ChannelVoiceMasks+x   : mov !sound3_p_charVoiceMask,a
mov a,sound3ChannelVoiceIndices+x : mov !sound3_p_charVoiceIndex,a
inc x
mov a,sound3ChannelVoiceBitsets+x : mov !sound3_p_charVoiceBitset+1,a
mov a,sound3ChannelVoiceMasks+x   : mov !sound3_p_charVoiceMask+1,a
mov a,sound3ChannelVoiceIndices+x : mov !sound3_p_charVoiceIndex+1,a
inc !sound3_2i_channel : inc !sound3_2i_channel
mov a,!sound3_voiceId : mov !sound3_i_voice,a : dec !sound3_i_voice : clrc : asl !sound3_i_voice
mov x,!sound3_i_voice : mov y,!sound3_i_channel
mov a,!trackOutputVolumes+x         : mov !sound3_trackOutputVolumeBackups+y,a
mov a,!trackPhaseInversionOptions+x : mov !sound3_trackOutputVolumeBackups+y,a
mov y,#$00 : mov a,!sound3_i_voice : mov (!sound3_p_charVoiceIndex)+y,a
mov y,!sound3_voiceId : %SetVoice(3) : jmp .loop
}

getSound3ChannelInstructionListPointer:
{
inc y : mov a,(!sound3_instructionListPointerSet)+y
ret
}

sound3MultiplyBy8:
{
asl a : asl a : asl a
ret
}

sound3Configurations:
{
.sound1
{
mov a,#$00 : mov !sound3LowHealthPriority,a
}

.soundA
.sound12
.sound20
.sound21
.sound24
{
mov a,#$01 : mov !sound3_n_voices,a
mov a,#$01 : mov !sound3Priority,a
ret
}

.sound2
{
mov a,#$01 : mov !sound3_n_voices,a
mov a,#$02 : mov !sound3LowHealthPriority,a
ret
}

.sound3
.sound6
.sound9
.soundC
.soundD
.sound10
.sound11
.sound13
.sound16
.sound17
.sound18
.sound1A
.sound1C
.sound1D
.sound1E
.sound1F
.sound22
.sound23
.sound25
.sound26
.sound27
.sound28
.sound29
.sound2A
.sound2B
.sound2D
.sound2F
{
mov a,#$01 : mov !sound3_n_voices,a
mov a,#$00 : mov !sound3Priority,a
ret
}

.sound4
.sound5
.soundB
.soundF
{
mov a,#$02 : mov !sound3_n_voices,a
mov a,#$00 : mov !sound3Priority,a
ret
}

.sound7
.sound8
.soundE
.sound14
.sound15
.sound19
.sound1B
.sound2C
.sound2E
{
mov a,#$02 : mov !sound3_n_voices,a
mov a,#$01 : mov !sound3Priority,a
ret
}
}

sound3InstructionLists:
{
dw .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F

; Instruction list format:
{
; Commands:
;     F5h dd tt - legato pitch slide with subnote delta = d, target note = t
;     F8h dd tt -        pitch slide with subnote delta = d, target note = t
;     F9h aaaa - voice's ADSR settings = a
;     FBh - repeat
;     FCh - enable noise
;     FDh - decrement repeat counter and repeat if non-zero
;     FEh cc - set repeat pointer with repeat counter = c
;     FFh - end

; Otherwise:
;     ii vv [pp] nn tt
;     i: Instrument index
;     v: Volume
;     p: Panning (optional, if absent, defaults to Ah)
;     n: Note. F6h is a tie
;     t: Length
}

; Sound 1: Silence
.sound1
dw ..voice0
..voice0 : db $11,$00,$BC,$03, $FF

; Sound 2: Low health beep
.sound2
dw ..voice0
..voice0 : db $FE,$00, $15,$90,$BC,$F0, $FB, $FF

; Sound 3: Speed booster
.sound3
dw .speedBoosterVoice

; Speed booster / Dachora speed booster (sound library 2)
.speedBoosterVoice
db $F5,$E0,$C7, $05,$60,$98,$12, $F5,$E0,$C7, $05,$70,$A4,$11, $F5,$E0,$C7, $05,$80,$B0,$10, $F5,$E0,$C7, $05,$80,$B4,$08, $F5,$E0,$C7, $05,$80,$B9,$07, $F5,$E0,$C7, $05,$80,$BC,$06, $F5,$E0,$C1, $05,$80,$BC,$06, $F5,$E0,$C7, $05,$80,$C5,$06

; Shared by speed booster and resume speed booster / shinespark
.resumeSpeedBoosterVoice
db $FE,$00, $05,$60,$C7,$10, $FB,\
   $FF

; Sound 4: Samus landed hard
.sound4
dw ..voice0, ..voice1
..voice0 : db $03,$90,$80,$03, $FF
..voice1 : db $03,$A0,$84,$05, $FF

; Sound 5: Samus landed / wall-jumped
.sound5
dw ..voice0, ..voice1
..voice0 : db $03,$40,$80,$03, $FF
..voice1 : db $03,$50,$84,$05, $FF

; Sound 6: Samus' footsteps
.sound6
dw ..voice0
..voice0 : db $09,$80,$82,$03, $FF

; Sound 7: Door opened
.sound7
dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06,$80,$91,$18, $FF
..voice1 : db $F5,$F0,$A8, $02,$80,$90,$18, $FF

; Sound 8: Door closed
.sound8
dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$89, $06,$80,$A1,$15, $FF
..voice1 : db $F5,$F0,$87, $02,$80,$9F,$15, $FF

; Sound 9: Missile door shot with missile
.sound9
dw ..voice0
..voice0 : db $02,$B0,$8C,$03, $02,$D0,$90,$03, $02,$D0,$8C,$03, $02,$D0,$90,$03, $FF

; Sound Ah: Enemy frozen
.soundA
dw ..voice0
..voice0 : db $0D,$70,$0C,$A3,$01, $0D,$80,$0C,$A1,$01, $0D,$80,$0C,$9F,$02, $0D,$80,$0C,$9D,$02, $0D,$70,$0C,$9C,$02, $0D,$50,$0C,$9A,$01, $0D,$60,$0C,$97,$01, $0D,$60,$0C,$98,$03, $FF

; Sound Bh: Elevator
.soundB
dw ..voice0, ..voice1
..voice0 : db $FE,$00, $0B,$90,$80,$70, $FB, $FF
..voice1 : db $FE,$00, $06,$40,$98,$13, $FB, $FF

; Sound Ch: Stored shinespark
.soundC
dw .storedShinesparkVoice

; Stored shinespark / Dachora stored shinespark (sound library 2)
.storedShinesparkVoice
db $05,$A0,$C7,$B0, $FF

; Sound Dh: Typewriter stroke - intro
.soundD
dw ..voice0
..voice0 : db $03,$50,$98,$02, $03,$50,$98,$02, $FF

; Sound Eh: Gate opening/closing
.soundE
dw ..voice0, ..voice1
..voice0 : db $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $03,$50,$0C,$85,$05, $FF
..voice1 : db $F5,$60,$A9, $06,$90,$91,$20, $FF

; Sound Fh: Shinespark
.soundF
dw .shinesparkVoice0, .shinesparkVoice1

; Shinespark / Dachora shinespark (sound library 2)
.shinesparkVoice0 : db $01,$00,$90,$0C, $01,$D0,$91,$0C, $01,$D0,$93,$0C, $01,$D0,$95,$0A, $01,$D0,$95,$0A, $01,$D0,$97,$08, $01,$D0,$97,$08, $01,$D0,$98,$06, $01,$D0,$98,$06, $01,$D0,$9A,$04, $01,$D0,$9A,$04, $FF
.shinesparkVoice1 : db $F5,$90,$C7, $05,$C0,$98,$10, $F5,$F0,$C7, $05,$C0,$F6,$30, $05,$C0,$C1,$03, $05,$C0,$C3,$03, $05,$C0,$C5,$03, $05,$C0,$C7,$03, $FF

; Sound 10h: Shinespark ended
.sound10
dw .shinesparkEndedVoice

; Shinespark ended / Dachora shinespark ended (sound library 2)
.shinesparkEndedVoice
db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03

; Shared by shinespark ended and shorter version
.shortShinesparkEndedVoice
db $08,$D0,$8C,$03, $08,$D0,$8C,$15

.emptyVoice
db $FF

; Sound 11h: (shorter version of shinespark ended)
.sound11
dw .shortShinesparkEndedVoice

; Sound 12h: (Empty)
; Sound 18h: (Empty)
; Sound 1Ah: (Empty)
; Sound 20h: (Empty)
; Sound 2Fh: (Empty)
.sound12
.sound18
.sound1A
.sound20
.sound2F
dw .emptyVoice

; Sound 13h: Mother Brain's projectile hits surface
.sound13
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 14h: Gunship elevator activated
.sound14
dw ..voice0, ..voice1
..voice0 : db $06,$00,$91,$23, $06,$A0,$91,$18, $F5,$F0,$A9, $06,$A0,$91,$18, $FF
..voice1 : db $02,$00,$90,$23, $02,$20,$90,$18, $F5,$F0,$A8, $02,$20,$90,$18, $FF

; Sound 15h: Gunship elevator deactivated
.sound15
dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$89, $06,$80,$A1,$15, $FF
..voice1 : db $F5,$F0,$87, $02,$10,$9F,$15, $FF

; Sound 16h: Crunchy footstep that's supposed to play when Mother Brain is being attacked by Shitroid (but doesn't, see $A9:9599)
.sound16
dw ..voice0
..voice0 : db $08,$D0,$A3,$03, $08,$D0,$8E,$03, $08,$D0,$8E,$25, $FF

; Sound 17h: Mother Brain's blue rings
.sound17
dw ..voice0
..voice0 : db $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $FF

; Sound 19h: Shitroid dies
.sound19
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$93,$26, $FF
..voice1 : db $25,$A0,$8C,$3B, $FF

; Sound 1Bh: Draygon dying cry
.sound1B
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$8E,$30, $25,$D0,$8E,$30, $25,$D0,$8E,$40, $FF
..voice1 : db $25,$00,$A6,$0C, $25,$80,$98,$30, $25,$80,$98,$30, $25,$80,$9A,$10, $25,$80,$98,$40, $FF

; Sound 1Ch: Crocomire spit
.sound1C
dw ..voice0
..voice0 : db $00,$D0,$9C,$20, $FF

; Sound 1Dh: Phantoon's flame
.sound1D
dw ..voice0
..voice0 : db $F5,$F0,$B5, $09,$D0,$93,$08, $F5,$F0,$B5, $09,$D0,$93,$08, $FF

; Sound 1Eh: Earthquake (Kraid)
.sound1E
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 1Fh: Kraid fires lint
.sound1F
dw ..voice0
..voice0 : db $00,$D0,$90,$08, $01,$D0,$8C,$20, $FF

; Sound 21h: Ridley whips its tail
.sound21
dw ..voice0
..voice0 : db $07,$D0,$C7,$10, $FF

; Sound 22h: Crocomire acid damage
.sound22
dw ..voice0
..voice0 : db $09,$B0,$8C,$05, $0E,$B0,$91,$05, $09,$B0,$8C,$05, $0E,$B0,$91,$05, $09,$B0,$8C,$05, $0E,$B0,$91,$05, $FF

; Sound 23h: Baby metroid cry 1
.sound23
dw ..voice0
..voice0 : db $25,$20,$95,$40, $FF

; Sound 24h: Baby metroid cry - Ceres
.sound24
dw ..voice0
..voice0 : db $24,$20,$95,$40, $FF

; Sound 25h: Silence (clear speed booster / elevator sound)
.sound25
dw ..voice0
..voice0 : db $07,$00,$C7,$03, $FF

; Sound 26h: Baby metroid cry 2
.sound26
dw ..voice0
..voice0 : db $25,$20,$92,$09, $25,$30,$92,$40, $FF

; Sound 27h: Baby metroid cry 3
.sound27
dw ..voice0
..voice0 : db $25,$30,$91,$40, $FF

; Sound 28h: Phantoon materialises attack
.sound28
dw ..voice0
..voice0 : db $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $FF

; Sound 29h: Phantoon's super missiled attack
.sound29
dw ..voice0
..voice0 : db $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $FF

; Sound 2Ah: Pause menu ambient beep
.sound2A
dw ..voice0
..voice0 : db $0B,$20,$C7,$03, $0B,$20,$C7,$03, $0B,$10,$C7,$03, $FF

; Sound 2Bh: Resume speed booster / shinespark
.sound2B
dw .resumeSpeedBoosterVoice

; Sound 2Ch: Ceres door opening
.sound2C
dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06,$70,$91,$18, $FF
..voice1 : db $F5,$F0,$A4, $06,$70,$8C,$18, $FF

; Sound 2Dh: Gaining/losing incremental health
.sound2D
dw ..voice0
..voice0 : db $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $FF

; Sound 2Eh: Mother Brain's glass shattering
.sound2E
dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$59, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF
}
