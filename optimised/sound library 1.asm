handleCpuIo1:
{
mov a,#$00 : mov !i_soundLibrary,a

mov y,!cpuIo1_read_prev
mov a,!cpuIo1_read : mov !cpuIo1_read_prev,a
mov !cpuIo1_write,a
cmp y,!cpuIo1_read : bne .branch_change

.branch_noChange
mov a,!sound1 : bne +
ret

+
jmp processSound1

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo1_read
cmp a,#$02 : beq +
cmp a,#$01 : beq +
mov a,!sound1Priority : bne .branch_noChange

+
mov a,!sound1 : beq +
mov a,#$00 : mov !sound1_enabledVoices,a
call resetSound1Channel0
call resetSound1Channel1
call resetSound1Channel2
call resetSound1Channel3

+
mov a,#$00
mov !sound1_channel0_legatoFlag,a
mov !sound1_channel1_legatoFlag,a
mov !sound1_channel2_legatoFlag,a
mov !sound1_channel3_legatoFlag,a
mov a,!cpuIo1_write : dec a : asl a : mov !i_sound1,a
mov x,!i_sound1 : mov a,sound1InstructionLists+x : mov !sound1_instructionListPointerSet,a : inc x : mov a,sound1InstructionLists+x : mov !sound1_instructionListPointerSet+1,a
mov a,!cpuIo1_write : mov !sound1,a
mov y,#$00 : mov a,(!sound1_instructionListPointerSet)+y : mov y,a
and a,#$0F : mov !sound1_n_voices,a
mov a,y : lsr a : lsr a : lsr a : lsr a : mov !sound1Priority,a
}

processSound1:
{
mov a,#$FF : cmp a,!sound1_initialisationFlag : beq +
call sound1Initialisation
mov y,#$01 : mov a,(!sound1_instructionListPointerSet)+y : mov !sound1_channel0_p_instructionListLow,a : call getSound1ChannelInstructionListPointer : mov !sound1_channel0_p_instructionListHigh,a
call getSound1ChannelInstructionListPointer              : mov !sound1_channel1_p_instructionListLow,a : call getSound1ChannelInstructionListPointer : mov !sound1_channel1_p_instructionListHigh,a
call getSound1ChannelInstructionListPointer              : mov !sound1_channel2_p_instructionListLow,a : call getSound1ChannelInstructionListPointer : mov !sound1_channel2_p_instructionListHigh,a
call getSound1ChannelInstructionListPointer              : mov !sound1_channel3_p_instructionListLow,a : call getSound1ChannelInstructionListPointer : mov !sound1_channel3_p_instructionListHigh,a
mov a,!sound1_channel0_voiceIndex : asl a : asl a : asl a : mov !sound1_channel0_dspIndex,a
mov a,!sound1_channel1_voiceIndex : asl a : asl a : asl a : mov !sound1_channel1_dspIndex,a
mov a,!sound1_channel2_voiceIndex : asl a : asl a : asl a : mov !sound1_channel2_dspIndex,a
mov a,!sound1_channel3_voiceIndex : asl a : asl a : asl a : mov !sound1_channel3_dspIndex,a

mov y,#$00
mov !sound1_channel0_i_instructionList,y
mov !sound1_channel1_i_instructionList,y
mov !sound1_channel2_i_instructionList,y
mov !sound1_channel3_i_instructionList,y

inc y
mov !sound1_channel0_instructionTimer,y
mov !sound1_channel1_instructionTimer,y
mov !sound1_channel2_instructionTimer,y
mov !sound1_channel3_instructionTimer,y

+
mov x,#$00 : mov !i_globalChannel,x : call processSoundChannel
mov x,#$01 : mov !i_globalChannel,x : call processSoundChannel
mov x,#$02 : mov !i_globalChannel,x : call processSoundChannel
mov x,#$03 : mov !i_globalChannel,x : call processSoundChannel

ret
}

resetSound1Channel0: : mov x,#$00 : mov !i_globalChannel,x : jmp resetSoundChannel
resetSound1Channel1: : mov x,#$01 : mov !i_globalChannel,x : jmp resetSoundChannel
resetSound1Channel2: : mov x,#$02 : mov !i_globalChannel,x : jmp resetSoundChannel
resetSound1Channel3: : mov x,#$03 : mov !i_globalChannel,x : jmp resetSoundChannel

; Sound 1 channel variable pointers
{
sound1ChannelVoiceBitsets:
dw !sound1_channel0_voiceBitset, !sound1_channel1_voiceBitset, !sound1_channel2_voiceBitset, !sound1_channel3_voiceBitset

sound1ChannelVoiceMasks:
dw !sound1_channel0_voiceMask, !sound1_channel1_voiceMask, !sound1_channel2_voiceMask, !sound1_channel3_voiceMask

sound1ChannelVoiceIndices:
dw !sound1_channel0_voiceIndex, !sound1_channel1_voiceIndex, !sound1_channel2_voiceIndex, !sound1_channel3_voiceIndex
}

sound1Initialisation:
{
mov a,#$09 : mov !sound1_voiceId,a
mov a,!enableSoundEffectVoices : mov !sound1_remainingEnabledSoundVoices,a
mov a,#$00
mov !sound1_2i_channel,a
mov !sound1_i_channel,a
mov !sound1_channel0_voiceBitset,a
mov !sound1_channel1_voiceBitset,a
mov !sound1_channel2_voiceBitset,a
mov !sound1_channel3_voiceBitset,a
mov !sound1_channel0_voiceIndex,a
mov !sound1_channel1_voiceIndex,a
mov !sound1_channel2_voiceIndex,a
mov !sound1_channel3_voiceIndex,a
dec a
mov !sound1_initialisationFlag,a
mov !sound1_channel0_voiceMask,a
mov !sound1_channel1_voiceMask,a
mov !sound1_channel2_voiceMask,a
mov !sound1_channel3_voiceMask,a
mov !sound1_channel0_disableByte,a
mov !sound1_channel1_disableByte,a
mov !sound1_channel2_disableByte,a
mov !sound1_channel3_disableByte,a
mov a,#$0A
mov !sound1_channel0_panningBias,a
mov !sound1_channel1_panningBias,a
mov !sound1_channel2_panningBias,a
mov !sound1_channel3_panningBias,a

.loop
dec !sound1_voiceId : bne +

.ret
ret

+
asl !sound1_remainingEnabledSoundVoices : bcs .loop
mov a,#$00 : cmp a,!sound1_n_voices : beq .ret
dec !sound1_n_voices
mov a,#$00 : mov x,!sound1_i_channel : mov !sound1_disableBytes+x,a
inc !sound1_i_channel
mov a,!sound1_2i_channel : mov x,a
mov a,sound1ChannelVoiceBitsets+x : mov !sound1_p_charVoiceBitset,a
mov a,sound1ChannelVoiceMasks+x   : mov !sound1_p_charVoiceMask,a
mov a,sound1ChannelVoiceIndices+x : mov !sound1_p_charVoiceIndex,a
inc x
mov a,sound1ChannelVoiceBitsets+x : mov !sound1_p_charVoiceBitset+1,a
mov a,sound1ChannelVoiceMasks+x   : mov !sound1_p_charVoiceMask+1,a
mov a,sound1ChannelVoiceIndices+x : mov !sound1_p_charVoiceIndex+1,a
inc !sound1_2i_channel : inc !sound1_2i_channel
mov a,!sound1_voiceId : mov !sound1_i_voice,a : dec !sound1_i_voice : clrc : asl !sound1_i_voice
mov x,!sound1_i_voice : mov y,!sound1_i_channel
mov a,!trackOutputVolumes+x         : mov !sound1_trackOutputVolumeBackups+y,a
mov a,!trackPhaseInversionOptions+x : mov !sound1_trackPhaseInversionOptionsBackups+y,a
mov y,#$00 : mov a,!sound1_i_voice : mov (!sound1_p_charVoiceIndex)+y,a
mov y,!sound1_voiceId : call setVoice : jmp .loop
}

getSound1ChannelInstructionListPointer:
{
inc y : mov a,(!sound1_instructionListPointerSet)+y
ret
}

sound1InstructionLists:
{
dw .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F, .sound30,\
   .sound31, .sound32, .sound33, .sound34, .sound35, .sound36, .sound37, .sound38, .sound39, .sound3A, .sound3B, .sound3C, .sound3D, .sound3E, .sound3F, .sound40,\
   .sound41, .sound42

; Instruction list format:
{
; Commands:
;     F5h dd tt - legato pitch slide with subnote delta = d, target note = t
;     F6h pp - panning bias = p / 14h
;     F8h dd tt -        pitch slide with subnote delta = d, target note = t
;     F9h aaaa - voice's ADSR settings = a
;     FBh - repeat
;     FCh - enable noise
;     FDh - decrement repeat counter and repeat if non-zero
;     FEh cc - set repeat pointer with repeat counter = c
;     FFh - end

; Otherwise:
;     ii vv nn tt
;     i: Instrument index
;     v: Volume
;     n: Note. F6h is a tie
;     t: Length
}

; Sound 1: Power bomb explosion
.sound1
db $04 : dw .PowerBombVoice0, .PowerBombVoice1, .PowerBombVoice2, .PowerBombVoice3
.PowerBombVoice0 : db $F5,$B0,$C7, $05,$D0,$98,$46, $FF
.PowerBombVoice1 : db $F6,$0F, $F5,$A0,$C7, $09,$D0,$80,$50, $F6,$0A, $F5,$50,$80, $09,$D0,$AB,$46, $FF
.PowerBombVoice2 : db $F6,$0F, $09,$D0,$87,$10, $F5,$B0,$C7, $05,$D0,$80,$60, $FF
.PowerBombVoice3 : db $F6,$05, $09,$D0,$82,$30, $F5,$A0,$80, $05,$D0,$C7,$60, $FF

; Sound 2: Silence
.sound2
db $01 : dw ..voice0
..voice0 : db $15,$00,$BC,$03, $FF

; Sound 3: Missile
.sound3
db $01 : dw ..voice0
..voice0 : db $00,$D8,$95,$08, $01,$D8,$8B,$30, $FF

; Sound 4: Super missile
.sound4
db $01 : dw ..voice0
..voice0 : db $00,$D0,$95,$08, $01,$D0,$90,$30, $FF

; Sound 5: Grapple start
.sound5
db $01 : dw ..voice0
..voice0 : db $01,$80,$9D,$10, $02,$50,$93,$07, $02,$50,$93,$03, $02,$50,$93,$05, $02,$50,$93,$08, $02,$50,$93,$04, $02,$50,$93,$06, $02,$50,$93,$04, $FF

; Sound 6: Grappling
.sound6
db $01 : dw ..voice0
..voice0 : db $0D,$50,$80,$03, $0D,$50,$85,$04,\
              $FE,$00, $02,$50,$93,$07, $02,$50,$93,$03, $02,$50,$93,$05, $02,$50,$93,$08, $02,$50,$93,$04, $02,$50,$93,$06, $02,$50,$93,$04, $FB,\
              $FF

; Sound 7: Grapple end
.sound7
db $01 : dw ..voice0
..voice0 : db $02,$50,$93,$05, $FF

; Sound 8: Charging beam
.sound8
db $02 : dw ..voice0, ..voice1
..voice0 : db $05,$00,$B4,$15, $F5,$30,$C7, $05,$50,$B7,$25,\
              $FE,$00, $07,$60,$C7,$30, $FB,\
              $FF
..voice1 : db $02,$00,$9C,$07, $02,$10,$9C,$03, $02,$00,$9C,$05, $02,$20,$9C,$08

; Shared by charging beam and resume charging beam
.resumeChargingBeamVoice
db $02,$20,$9C,$04, $02,$30,$9C,$06, $02,$00,$9C,$04, $02,$30,$9C,$03, $02,$30,$9C,$07, $02,$00,$9C,$0A, $02,$30,$9C,$03, $02,$00,$9C,$04, $02,$40,$9C,$03, $02,$40,$9C,$07, $02,$00,$9C,$05, $02,$40,$9C,$06, $02,$40,$9C,$03, $02,$00,$9C,$0A, $02,$50,$9C,$03, $02,$50,$9C,$03, $02,$60,$9C,$05, $02,$00,$9C,$06, $02,$60,$9C,$07, $02,$00,$9C,$03, $02,$60,$9C,$04, $02,$60,$9C,$03, $02,$00,$9C,$03,\
   $FE,$00, $02,$40,$9C,$05, $02,$40,$9C,$06, $02,$40,$9C,$07, $02,$40,$9C,$03, $02,$40,$9C,$04, $02,$40,$9C,$03, $02,$40,$9C,$03, $FB,\
   $FF

; Sound 9: X-ray
.sound9
db $01 : dw ..voice0
..voice0 : db $F5,$70,$AD, $06,$40,$A4,$40,\
              $FE,$00, $06,$40,$AD,$F0, $FB,\
              $FF

; Sound Ah: X-ray end
.soundA
db $01 : dw ..voice0
..voice0 : db $06,$00,$AD,$03, $FF

; Sound Bh: Uncharged power beam
.soundB
db $01 : dw ..voice0
..voice0 : db $04,$90,$89,$03, $04,$90,$84,$0E, $FF

; Sound Ch: Uncharged ice beam
; Sound Eh: Uncharged ice + wave beam
.soundC
.soundE
db $01 : dw ..voice0
..voice0 : db $04,$B0,$8B,$03, $04,$B0,$89,$07, $F5,$90,$C7, $10,$90,$BC,$0A, $10,$60,$C3,$06, $10,$30,$C7,$03, $10,$20,$C7,$03, $FF

; Sound Dh: Uncharged wave beam
.soundD
db $01 : dw ..voice0
..voice0 : db $04,$90,$89,$03, $04,$70,$84,$0B, $04,$30,$84,$08, $FF

; Sound Fh: Uncharged spazer beam
; Sound 12h: Uncharged spazer + wave beam
.soundF
.sound12
db $01 : dw ..voice0
..voice0 : db $00,$D0,$98,$0C, $04,$C0,$80,$10, $04,$30,$80,$08, $04,$10,$80,$06, $FF

; Sound 10h: Uncharged spazer + ice beam
; Sound 11h: Uncharged spazer + ice + wave beam
; Sound 14h: Uncharged plasma + ice beam
; Sound 15h: Uncharged plasma + ice + wave beam
.sound10
.sound11
.sound14
.sound15
db $01 : dw ..voice0
..voice0 : db $00,$D0,$98,$0C, $F5,$90,$C7, $10,$90,$BC,$0A, $10,$60,$C3,$06, $10,$30,$C7,$03, $10,$20,$C7,$03, $FF

; Sound 13h: Uncharged plasma beam
; Sound 16h: Uncharged plasma + wave beam
.sound13
.sound16
db $01 : dw ..voice0
..voice0 : db $00,$D0,$98,$0C, $04,$B0,$80,$13, $FF

; Sound 17h: Charged power beam
.sound17
db $01 : dw ..voice0
..voice0 : db $04,$D0,$84,$05, $04,$D0,$80,$0C, $02,$80,$98,$03, $02,$60,$98,$03, $02,$50,$98,$03, $FF

; Sound 18h: Charged ice beam
; Sound 1Ah: Charged ice + wave beam
; Sound 1Ch: Charged spazer + ice beam
; Sound 1Dh: Charged spazer + ice + wave beam
; Sound 20h: Charged plasma + ice beam
; Sound 21h: Charged plasma + ice + wave beam
.sound18
.sound1A
.sound1C
.sound1D
.sound20
.sound21
db $01 : dw ..voice0
..voice0 : db $00,$E0,$98,$0C, $F5,$B0,$C7, $10,$E0,$BC,$0A, $10,$70,$C3,$06, $10,$30,$C7,$03, $10,$20,$C7,$03, $FF

; Sound 19h: Charged wave beam
.sound19
db $01 : dw ..voice0
..voice0 : db $04,$E0,$84,$03, $04,$E0,$80,$10, $04,$50,$80,$04, $04,$30,$80,$09, $FF

; Sound 1Bh: Charged spazer beam
; Sound 1Eh: Charged spazer + wave beam
.sound1B
.sound1E
db $01 : dw ..voice0
..voice0 : db $00,$D0,$95,$08, $04,$D0,$80,$0F, $04,$80,$80,$0D, $04,$20,$80,$0A, $FF

; Sound 1Fh: Charged plasma beam / hyper beam
; Sound 22h: Charged plasma + wave beam
.sound1F
.sound22
db $01 : dw ..voice0
..voice0 : db $00,$D0,$98,$0E, $04,$D0,$80,$10, $04,$70,$80,$10, $04,$30,$80,$10, $FF

; Sound 23h: Ice SBA
.sound23
db $01 : dw ..voice0
..voice0 : db $FE,$00, $10,$50,$C0,$03, $10,$50,$C1,$03, $10,$60,$C3,$03, $10,$60,$C5,$03, $10,$70,$C7,$03, $10,$60,$C5,$03, $10,$50,$C3,$03, $10,$50,$C1,$03, $FB, $FF

; Sound 24h: Ice SBA end
.sound24
db $02 : dw ..voice0, ..voice1
..voice0 : db $10,$D0,$BC,$0A, $10,$70,$C3,$06, $10,$30,$C7,$03, $10,$20,$C7,$03, $10,$50,$C3,$06, $10,$40,$C7,$03, $10,$40,$C7,$03, $10,$30,$C3,$06, $10,$20,$C7,$03, $10,$20,$C7,$03, $FF
..voice1 : db $04,$D0,$80,$10, $04,$70,$80,$10, $04,$30,$80,$10, $FF

; Sound 25h: Spazer SBA
.sound25
db $01 : dw ..voice0
..voice0 : db $04,$D0,$80,$10, $04,$70,$80,$10, $04,$30,$80,$02, $04,$D0,$80,$10, $04,$70,$80,$10, $04,$30,$80,$10, $FF

; Sound 26h: Spazer SBA end
.sound26
db $01 : dw ..voice0
..voice0 : db $04,$D0,$80,$10, $04,$70,$80,$04, $04,$30,$80,$02, $04,$30,$80,$06, $04,$30,$80,$06, $04,$70,$80,$07, $04,$70,$80,$07, $FF

; Sound 27h: Plasma SBA
.sound27
db $02 : dw ..voice0, ..voice1
..voice0 : db $F5,$30,$C7, $07,$90,$B7,$25, $F5,$30,$B7, $07,$90,$F6,$25, $F5,$B0,$C7, $07,$90,$F6,$25, $FF
..voice1 : db $F5,$30,$C7, $05,$90,$B7,$27, $F5,$30,$B7, $05,$90,$F6,$27, $F5,$B0,$C7, $05,$90,$F6,$27, $FF

; Sound 28h: Wave SBA
.sound28
db $01 : dw ..voice0
..voice0 : db $F5,$30,$C7, $05,$50,$B7,$25, $FF

; Sound 29h: Wave SBA end
.sound29
db $01 : dw ..voice0
..voice0 : db $05,$00,$B7,$03, $FF

; Sound 2Ah: Selected save file
.sound2A
db $01 : dw ..voice0
..voice0 : db $07,$90,$C5,$12

.EmptyVoice
db $FF

; Sound 2Bh: (Empty)
; Sound 2Ch: (Empty)
; Sound 2Dh: (Empty)
; Sound 3Ah: (Empty)
.sound2B
.sound2C
.sound2D
.sound3A
db $01 : dw .EmptyVoice

; Sound 2Eh: Saving
.sound2E
db $04 : dw ..voice0, ..voice1, ..voice2, ..voice3
..voice0 : db $F5,$F0,$B1, $06,$45,$99,$19, $06,$45,$B1,$80, $F5,$F0,$99, $06,$45,$B1,$19, $FF
..voice1 : db $F5,$F0,$A7, $06,$45,$8F,$19, $06,$45,$A7,$80, $F5,$F0,$8F, $06,$45,$A7,$19, $FF
..voice2 : db $F5,$F0,$A0, $06,$45,$88,$19, $06,$45,$A0,$80, $F5,$F0,$88, $06,$45,$A0,$19, $FF
..voice3 : db $F5,$F0,$98, $06,$45,$80,$19, $06,$45,$98,$80, $F5,$F0,$80, $06,$45,$98,$19, $FF

; Sound 2Fh: Underwater space jump (without gravity suit)
.sound2F
db $01 : dw ..voice0
..voice0 : db $07,$80,$C7,$10, $FF

; Sound 30h: Resumed spin jump
; Sound 3Fh: Resumed space jump
.sound30
.sound3F
db $01 : dw .resumedSpinJumpVoice

; Sound 31h: Spin jump
.sound31
db $01 : dw ..voice0
..voice0 : db $07,$30,$C5,$10, $07,$40,$C6,$10, $07,$50,$C7,$10

; Shared by resumed spin jump, spin jump and resumed space jump
.resumedSpinJumpVoice
db $FE,$00, $07,$80,$C7,$10, $FB,\
   $FF

; Sound 32h: Spin jump end
.sound32
db $01 : dw ..voice0
..voice0 : db $0A,$00,$87,$03, $FF

; Sound 33h: Screw attack
.sound33
db $02 : dw ..voice0, ..voice1
..voice0 : db $07,$30,$C7,$04, $07,$40,$C7,$05, $07,$50,$C7,$06, $07,$60,$C7,$07, $07,$70,$C7,$09, $07,$80,$C7,$0D, $07,$80,$C7,$0F,\
              $FE,$00, $07,$80,$C7,$10, $FB,\
              $FF
..voice1 : db $F5,$E0,$BC, $05,$60,$98,$0E, $F5,$E0,$BC, $05,$70,$A4,$08, $F5,$E0,$BC, $05,$80,$B0,$06,\
              $FE,$00, $05,$80,$BC,$03, $05,$80,$C4,$03, $05,$80,$C6,$03, $FB,\
              $FF

; Sound 3Eh: Space jump
.sound3E
db $01 : dw .sound33_voice0

; Sound 34h: Screw attack end
.sound34
db $01 : dw ..voice0
..voice0 : db $0A,$00,$87,$03, $FF

; Sound 35h: Samus damaged
.sound35
db $11 : dw ..voice0
..voice0 : db $13,$60,$A4,$10, $13,$10,$A4,$07, $FF

; Sound 36h: Scrolling map
.sound36
db $01 : dw ..voice0
..voice0 : db $0C,$60,$B0,$02, $FF

; Sound 37h: Toggle reserve mode / moved cursor
.sound37
db $01 : dw ..voice0
..voice0 : db $03,$60,$9C,$04, $FF

; Sound 38h: Pause menu transition / toggled equipment
.sound38
db $01 : dw ..voice0
..voice0 : db $F5,$90,$C7, $15,$90,$B0,$15, $FF

; Sound 39h: Switch HUD item
.sound39
db $01 : dw ..voice0
..voice0 : db $03,$40,$9C,$03, $FF

; Sound 3Bh: Hexagon map -> square map transition
.sound3B
db $01 : dw ..voice0
..voice0 : db $05,$90,$9C,$0B, $F5,$F0,$C2, $05,$90,$9C,$12, $FF

; Sound 3Ch: Square map -> hexagon map transition
.sound3C
db $01 : dw ..voice0
..voice0 : db $05,$90,$9C,$0B, $F5,$F0,$80, $05,$90,$9C,$12, $FF

; Sound 3Dh: Dud shot
.sound3D
db $01 : dw ..voice0
..voice0 : db $08,$70,$99,$03, $08,$70,$9C,$05, $FF

; Sound 40h: Mother Brain's rainbow beam
.sound40
db $13 : dw ..voice0, ..voice1, ..voice2
..voice0 : db $FE,$00, $23,$D0,$89,$07, $23,$D0,$8B,$07, $23,$D0,$8C,$07, $23,$D0,$8E,$07, $23,$D0,$90,$07, $23,$D0,$91,$07, $23,$D0,$93,$07, $23,$D0,$95,$07, $23,$D0,$97,$07, $FB, $FF
..voice1 : db $FE,$00, $06,$D0,$BA,$F0, $FB, $FF
..voice2 : db $FE,$00, $06,$D0,$B3,$F0, $FB, $FF

; Sound 41h: Resume charging beam
.sound41
db $02 : dw ..voice0, .resumeChargingBeamVoice
..voice0 : db $F5,$70,$C7, $05,$50,$C0,$03,\
              $FE,$00, $07,$60,$C7,$30, $FB,\
              $FF

; Sound 42h:
.sound42
db $02 : dw ..voice0, ..voice1
..voice0 : db $24,$A0,$9C,$20, $FF
..voice1 : db $24,$00,$9D,$05, $24,$80,$95,$40, $FF
}
