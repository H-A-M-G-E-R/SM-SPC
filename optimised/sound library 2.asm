handleCpuIo2:
{
mov a,#$01 : mov !i_soundLibrary,a

mov y,!cpuIo2_read_prev
mov a,!cpuIo2_read : mov !cpuIo2_read_prev,a
mov !cpuIo2_write,a
cmp y,!cpuIo2_read : bne .branch_change

.branch_noChange
mov a,!sound2 : bne +
ret

+
jmp processSound2

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo2_read
cmp a,#$71 : beq +
cmp a,#$7E : beq +
mov a,!sound2Priority : bne .branch_noChange

+
mov a,!sound2 : beq +
mov a,#$00 : mov !sound2_enabledVoices,a
call resetSound2Channel0
call resetSound2Channel1

+
mov a,#$00
mov !sound2_channel0_legatoFlag,a
mov !sound2_channel1_legatoFlag,a
mov a,!cpuIo2_write : dec a : asl a : mov !i_sound2,a
mov x,!i_sound2 : mov a,sound2InstructionLists+x : mov !sound2_instructionListPointerSet,a : inc x : mov a,sound2InstructionLists+x : mov !sound2_instructionListPointerSet+1,a
mov a,!cpuIo2_write : mov !sound2,a
call goToJumpTableEntry

!sc = sound2Configurations_sound ; Shorthand for the `soundN` sublabels within the sound2Configurations label
dw !{sc}1,  !{sc}2,  !{sc}3,  !{sc}4,  !{sc}5,  !{sc}6,  !{sc}7,  !{sc}8,  !{sc}9,  !{sc}A,  !{sc}B,  !{sc}C,  !{sc}D,  !{sc}E,  !{sc}F,  !{sc}10,\
   !{sc}11, !{sc}12, !{sc}13, !{sc}14, !{sc}15, !{sc}16, !{sc}17, !{sc}18, !{sc}19, !{sc}1A, !{sc}1B, !{sc}1C, !{sc}1D, !{sc}1E, !{sc}1F, !{sc}20,\
   !{sc}21, !{sc}22, !{sc}23, !{sc}24, !{sc}25, !{sc}26, !{sc}27, !{sc}28, !{sc}29, !{sc}2A, !{sc}2B, !{sc}2C, !{sc}2D, !{sc}2E, !{sc}2F, !{sc}30,\
   !{sc}31, !{sc}32, !{sc}33, !{sc}34, !{sc}35, !{sc}36, !{sc}37, !{sc}38, !{sc}39, !{sc}3A, !{sc}3B, !{sc}3C, !{sc}3D, !{sc}3E, !{sc}3F, !{sc}40,\
   !{sc}41, !{sc}42, !{sc}43, !{sc}44, !{sc}45, !{sc}46, !{sc}47, !{sc}48, !{sc}49, !{sc}4A, !{sc}4B, !{sc}4C, !{sc}4D, !{sc}4E, !{sc}4F, !{sc}50,\
   !{sc}51, !{sc}52, !{sc}53, !{sc}54, !{sc}55, !{sc}56, !{sc}57, !{sc}58, !{sc}59, !{sc}5A, !{sc}5B, !{sc}5C, !{sc}5D, !{sc}5E, !{sc}5F, !{sc}60,\
   !{sc}61, !{sc}62, !{sc}63, !{sc}64, !{sc}65, !{sc}66, !{sc}67, !{sc}68, !{sc}69, !{sc}6A, !{sc}6B, !{sc}6C, !{sc}6D, !{sc}6E, !{sc}6F, !{sc}70,\
   !{sc}71, !{sc}72, !{sc}73, !{sc}74, !{sc}75, !{sc}76, !{sc}77, !{sc}78, !{sc}79, !{sc}7A, !{sc}7B, !{sc}7C, !{sc}7D, !{sc}7E, !{sc}7F
}

processSound2:
{
mov a,#$FF : cmp a,!sound2_initialisationFlag : beq +
call sound2Initialisation
mov y,#$00 : mov a,(!sound2_instructionListPointerSet)+y : mov !sound2_channel0_p_instructionListLow,a : call getSound2ChannelInstructionListPointer : mov !sound2_channel0_p_instructionListHigh,a
call getSound2ChannelInstructionListPointer              : mov !sound2_channel1_p_instructionListLow,a : call getSound2ChannelInstructionListPointer : mov !sound2_channel1_p_instructionListHigh,a
mov a,!sound2_channel0_voiceIndex : call sound2MultiplyBy8 : mov !sound2_channel0_dspIndex,a
mov a,!sound2_channel1_voiceIndex : call sound2MultiplyBy8 : mov !sound2_channel1_dspIndex,a

mov y,#$00
mov !sound2_channel0_i_instructionList,y
mov !sound2_channel1_i_instructionList,y

inc y
mov !sound2_channel0_instructionTimer,y
mov !sound2_channel1_instructionTimer,y

+
mov x,#$00+!sound1_n_channels : mov !i_globalChannel,x : call processSoundChannel
mov x,#$01+!sound1_n_channels : mov !i_globalChannel,x : call processSoundChannel

ret
}

resetSound2Channel0: : mov x,#$00+!sound1_n_channels : mov !i_globalChannel,x : jmp resetSoundChannel
resetSound2Channel1: : mov x,#$01+!sound1_n_channels : mov !i_globalChannel,x : jmp resetSoundChannel

; Sound 2 channel variable pointers
{
sound2ChannelVoiceBitsets:
dw !sound2_channel0_voiceBitset, !sound2_channel1_voiceBitset

sound2ChannelVoiceMasks:
dw !sound2_channel0_voiceMask, !sound2_channel1_voiceMask

sound2ChannelVoiceIndices:
dw !sound2_channel0_voiceIndex, !sound2_channel1_voiceIndex
}

sound2Initialisation:
{
mov a,#$09 : mov !sound2_voiceId,a
mov a,!enableSoundEffectVoices : mov !sound2_remainingEnabledSoundVoices,a
mov a,#$00
mov !sound2_2i_channel,a
mov !sound2_i_channel,a
mov !sound2_channel0_voiceBitset,a
mov !sound2_channel1_voiceBitset,a
mov !sound2_channel0_voiceIndex,a
mov !sound2_channel1_voiceIndex,a
dec a
mov !sound2_initialisationFlag,a
mov !sound2_channel0_voiceMask,a
mov !sound2_channel1_voiceMask,a
mov !sound2_channel0_disableByte,a
mov !sound2_channel1_disableByte,a
mov a,#$0A
mov !sound2_channel0_panningBias,a
mov !sound2_channel1_panningBias,a

.loop
dec !sound2_voiceId : bne +

.ret
ret

+
asl !sound2_remainingEnabledSoundVoices : bcs .loop
mov a,#$00 : cmp a,!sound2_n_voices : beq .ret
dec !sound2_n_voices
mov a,#$00 : mov x,!sound2_i_channel : mov !sound2_disableBytes+x,a
inc !sound2_i_channel
mov a,!sound2_2i_channel : mov x,a
mov a,sound2ChannelVoiceBitsets+x : mov !sound2_p_charVoiceBitset,a
mov a,sound2ChannelVoiceMasks+x   : mov !sound2_p_charVoiceMask,a
mov a,sound2ChannelVoiceIndices+x : mov !sound2_p_charVoiceIndex,a
inc x
mov a,sound2ChannelVoiceBitsets+x : mov !sound2_p_charVoiceBitset+1,a
mov a,sound2ChannelVoiceMasks+x   : mov !sound2_p_charVoiceMask+1,a
mov a,sound2ChannelVoiceIndices+x : mov !sound2_p_charVoiceIndex+1,a
inc !sound2_2i_channel : inc !sound2_2i_channel
mov a,!sound2_voiceId : mov !sound2_i_voice,a : dec !sound2_i_voice : clrc : asl !sound2_i_voice
mov x,!sound2_i_voice : mov y,!sound2_i_channel
mov a,!trackOutputVolumes+x         : mov !sound2_trackOutputVolumeBackups+y,a
mov a,!trackPhaseInversionOptions+x : mov !sound2_trackOutputVolumeBackups+y,a
mov y,#$00 : mov a,!sound2_i_voice : mov (!sound2_p_charVoiceIndex)+y,a
mov y,!sound2_voiceId : %SetVoice(2) : jmp .loop
}

getSound2ChannelInstructionListPointer:
{
inc y : mov a,(!sound2_instructionListPointerSet)+y
ret
}

sound2MultiplyBy8:
{
asl a : asl a : asl a
ret
}

sound2Configurations:
{
.sound6
.sound7
.sound8
.sound9
.soundA
.soundB
.soundC
.soundD
.soundE
.soundF
.sound10
.sound11
.sound12
.sound13
.sound14
.sound15
.sound18
.sound1B
.sound1D
.sound20
.sound21
.sound22
.sound23
.sound24
.sound25
.sound26
.sound28
.sound29
.sound2A
.sound2B
.sound2F
.sound30
.sound31
.sound32
.sound33
.sound34
.sound36
.sound39
.sound3A
.sound3B
.sound3C
.sound3D
.sound3E
.sound3F
.sound40
.sound41
.sound42
.sound43
.sound44
.sound45
.sound47
.sound48
.sound49
.sound4A
.sound4B
.sound4C
.sound4D
.sound4F
.sound52
.sound53
.sound55
.sound57
.sound5B
.sound5C
.sound5D
.sound5E
.sound5F
.sound60
.sound61
.sound62
.sound64
.sound65
.sound66
.sound67
.sound68
.sound69
.sound6A
.sound6B
.sound6C
.sound6D
.sound70
.sound71
.sound76
{
mov a,#$01 : mov !sound2_n_voices,a
mov a,#$00 : mov !sound2Priority,a
ret
}

.sound1
.sound2
.sound3
.sound4
.sound5
.sound16
.sound17
.sound1C
.sound1F
.sound2D
.sound35
.sound46
.sound54
.sound7C
.sound7D
.sound7E
{
mov a,#$01 : mov !sound2_n_voices,a
mov a,#$01 : mov !sound2Priority,a
ret
}

.sound19
.sound1A
.sound37
.sound38
.sound56
.sound58
.sound5A
.sound63
.sound78
.sound79
.sound7A
.sound7B
.sound7F
{
mov a,#$02 : mov !sound2_n_voices,a
mov a,#$00 : mov !sound2Priority,a
ret
}

.sound1E
.sound27
.sound2C
.sound2E
.sound4E
.sound50
.sound51
.sound59
.sound6E
.sound6F
.sound72
.sound73
.sound74
.sound75
.sound77
{
mov a,#$02 : mov !sound2_n_voices,a
mov a,#$01 : mov !sound2Priority,a
ret
}
}

sound2InstructionLists:
{
dw .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F, .sound30,\
   .sound31, .sound32, .sound33, .sound34, .sound35, .sound36, .sound37, .sound38, .sound39, .sound3A, .sound3B, .sound3C, .sound3D, .sound3E, .sound3F, .sound40,\
   .sound41, .sound42, .sound43, .sound44, .sound45, .sound46, .sound47, .sound48, .sound49, .sound4A, .sound4B, .sound4C, .sound4D, .sound4E, .sound4F, .sound50,\
   .sound51, .sound52, .sound53, .sound54, .sound55, .sound56, .sound57, .sound58, .sound59, .sound5A, .sound5B, .sound5C, .sound5D, .sound5E, .sound5F, .sound60,\
   .sound61, .sound62, .sound63, .sound64, .sound65, .sound66, .sound67, .sound68, .sound69, .sound6A, .sound6B, .sound6C, .sound6D, .sound6E, .sound6F, .sound70,\
   .sound71, .sound72, .sound73, .sound74, .sound75, .sound76, .sound77, .sound78, .sound79, .sound7A, .sound7B, .sound7C, .sound7D, .sound7E, .sound7F

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

; Sound 1: Collected small health drop
.sound1
dw ..voice0
..voice0 : db $15,$80,$C7,$0A, $15,$50,$C7,$0A, $15,$20,$C7,$0A, $FF

; Sound 2: Collected big health drop
.sound2
dw ..voice0
..voice0 : db $15,$E0,$C7,$0A, $15,$60,$C7,$0A, $15,$30,$C7,$0A, $FF

; Sound 3: Collected missile drop
; Sound 4: Collected super missile drop
; Sound 5: Collected power bomb drop
.sound3
.sound4
.sound5
dw ..voice0
..voice0 : db $0C,$60,$AF,$02, $0C,$00,$AF,$01, $0C,$60,$AF,$02, $0C,$00,$AF,$01, $0C,$60,$AF,$02, $FF

; Sound 6: Block destroyed by contact damage
.sound6
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $FF

; Sound 7: (Super) missile hit wall
; Sound 8: Bomb explosion
.sound7
.sound8
dw ..voice0
..voice0 : db $08,$E0,$98,$03, $08,$E0,$95,$03, $08,$E0,$9A,$03, $08,$E0,$8C,$03, $08,$E0,$8C,$20, $FF

; Sound 9: Enemy killed
.sound9
dw ..voice0
..voice0 : db $08,$D0,$8B,$08, $F5,$D0,$BC, $09,$D0,$98,$10, $FF

; Sound Ah: Block crumbled or destroyed by shot
.soundA
dw ..voice0
..voice0 : db $08,$70,$9D,$07, $FF

; Sound Bh: Enemy killed by contact damage
.soundB
dw ..voice0
..voice0 : db $08,$D0,$99,$02, $08,$D0,$9C,$03, $0F,$D0,$8B,$03, $0F,$E0,$8C,$03, $0F,$D0,$8E,$0E, $FF

; Sound Ch: Beam hit wall
.soundC
dw ..voice0
..voice0 : db $08,$70,$98,$03, $08,$70,$95,$03, $F5,$F0,$BC, $09,$70,$98,$06, $FF

; Sound Dh: Splashed into water
.soundD
dw ..voice0
..voice0 : db $0F,$70,$93,$03, $0F,$E0,$90,$08, $0F,$70,$84,$15, $FF

; Sound Eh: Splashed out of water
.soundE
dw ..voice0
..voice0 : db $0F,$60,$90,$03, $0F,$60,$84,$15, $FF

; Sound Fh: Low pitched air bubbles
.soundF
dw ..voice0
..voice0 : db $0E,$60,$80,$05, $0E,$60,$85,$05, $0E,$60,$91,$05, $0E,$60,$89,$05, $FF

; Sound 10h: Lava/acid damaging Samus
.sound10
dw ..voice0
..voice0 : db $F5,$30,$BB, $12,$10,$95,$15, $FF

; Sound 11h: High pitched air bubbles
.sound11
dw ..voice0
..voice0 : db $0E,$60,$8C,$05, $0E,$60,$91,$05, $FF

; Sound 12h: Plays at random in heated rooms
.sound12
dw ..voice0
..voice0 : db $22,$60,$84,$1C, $22,$60,$90,$19, $0E,$60,$80,$10, $22,$60,$89,$19, $0E,$60,$80,$07, $0E,$60,$84,$10, $22,$60,$8B,$1B, $FF

; Sound 13h: Plays at random in heated rooms
.sound13
dw ..voice0
..voice0 : db $0E,$60,$80,$0A, $0E,$60,$84,$07, $22,$60,$8B,$1F, $22,$60,$89,$16, $0E,$60,$80,$0A, $0E,$60,$87,$10, $FF

; Sound 14h: Plays at random in heated rooms
.sound14
dw ..voice0
..voice0 : db $0E,$60,$80,$0A, $0E,$60,$87,$10, $22,$60,$84,$1A, $0E,$60,$80,$0A, $0E,$60,$84,$07, $22,$60,$91,$16, $0E,$60,$80,$0A, $0E,$60,$87,$10, $FF

; Sound 15h: Maridia elevatube
.sound15
dw ..voice0
..voice0 : db $25,$00,$AB,$03, $FF

; Sound 16h: Fake Kraid cry
.sound16
dw ..voice0
..voice0 : db $25,$60,$A8,$10, $FF

; Sound 17h: Morph ball eye's ray
.sound17
dw ..voice0
..voice0 : db $F5,$70,$AA, $06,$40,$A1,$40,\
              $FE,$00, $06,$40,$AA,$F0, $FB,\
              $FF

; Sound 18h: Beacon
.sound18
dw ..voice0
..voice0 : db $0B,$20,$8C,$03, $0B,$30,$8C,$03, $0B,$40,$8C,$03, $0B,$50,$8C,$03, $0B,$60,$8C,$03, $0B,$70,$8C,$03, $0B,$80,$8C,$03, $0B,$60,$8C,$03, $0B,$50,$8C,$03, $0B,$40,$8C,$03, $0B,$30,$8C,$03, $FF

; Sound 19h: Tourian statue unlocking particle
.sound19
dw ..voice0, ..voice1
..voice0 : db $10,$50,$C1,$03, $10,$40,$C2,$03, $10,$30,$C3,$03, $10,$20,$C4,$03, $10,$10,$C5,$03, $10,$10,$C6,$03, $10,$10,$C7,$03, $10,$00,$C7,$30, $10,$60,$C7,$03, $10,$50,$C6,$03, $10,$30,$C5,$03, $10,$30,$C4,$03, $10,$20,$C3,$03, $10,$20,$C2,$03, $10,$10,$C1,$03, $10,$10,$C0,$03, $FF
..voice1 : db $08,$D0,$99,$03, $08,$D0,$9C,$04, $0F,$30,$8B,$03, $0F,$40,$8C,$03, $0F,$50,$8E,$0E, $FF

; Sound 1Ah: n00b tube shattering
.sound1A
dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$03, $08,$D0,$97,$02, $08,$D0,$98,$03, $08,$D0,$9A,$04, $08,$D0,$97,$03, $08,$D0,$9A,$04, $08,$D0,$9D,$03, $08,$D0,$9F,$03, $08,$D0,$94,$1A, $25,$40,$8C,$26, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF

; Sound 1Bh: Spike platform stops / tatori hits wall
.sound1B
dw ..voice0
..voice0 : db $08,$D0,$94,$19, $FF

; Sound 1Ch: Chozo grabs Samus
.sound1C
dw ..voice0
..voice0 : db $F6,$0C, $0D,$40,$8B,$02, $0D,$50,$89,$02, $0D,$60,$87,$03, $0D,$50,$85,$03, $FF

; Sound 1Dh: Dachora cry
.sound1D
dw ..voice0
..voice0 : db $14,$D0,$9F,$03, $14,$D0,$A4,$03, $14,$90,$A4,$03, $14,$40,$A3,$03, $14,$30,$A2,$03, $FF

; Sound 1Eh:
.sound1E
dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$59, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF

; Sound 1Fh: Fune spits
.sound1F
dw ..voice0
..voice0 : db $25,$D0,$90,$09, $00,$D8,$97,$07, $FF

; Sound 20h: Shot fly
.sound20
dw ..voice0
..voice0 : db $14,$80,$9F,$03, $14,$80,$98,$0A, $14,$40,$98,$03, $14,$30,$98,$03, $FF

; Sound 21h: Shot skree / wall/ninja space pirate
; Sound 5Bh: Skree launches attack
.sound21
.sound5B
dw ..voice0
..voice0 : db $14,$80,$98,$03, $14,$A0,$9D,$07, $14,$50,$98,$03, $14,$30,$9D,$06, $FF

; Sound 22h: Shot pipe bug / high-rising slow-falling enemy
.sound22
dw ..voice0
..voice0 : db $14,$D0,$90,$03, $14,$E0,$93,$03, $14,$D0,$95,$03, $14,$50,$95,$03, $FF

; Sound 23h: Shot slug / sidehopper / zoomer
.sound23
dw ..voice0
..voice0 : db $F6,$0C, $14,$E0,$84,$03, $14,$D0,$89,$03, $14,$E0,$84,$03, $14,$D0,$89,$03, $FF

; Sound 24h: Small explosion (enemy death)
.sound24
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 25h: Big explosion (Ceres door explosion / Crocomire flailing / Crocomire's wall explodes / Draygon tail whip, also used by Mother Brain)
; Sound 76h: Quake (Crocomire moves / Kraid moves / Ridley's tail hits floor)
.sound25
.sound76
dw ..voice0
..voice0 : db $00,$E0,$91,$08, $08,$D0,$A1,$03, $08,$D0,$9E,$03, $08,$D0,$A3,$03, $08,$D0,$8E,$03, $08,$D0,$8E,$25, $FF

; Sound 26h:
.sound26
dw ..voice0
..voice0 : db $00,$D8,$95,$05, $01,$90,$A4,$08, $F5,$F0,$80, $0B,$A0,$B0,$0E, $F5,$F0,$80, $0B,$70,$B0,$0E, $F5,$F0,$80, $0B,$30,$B0,$0E, $FF

; Sound 27h: Shot torizo
.sound27
dw ..voice0, ..voice1
..voice0 : db $14,$D0,$8B,$11, $14,$D0,$89,$20, $14,$80,$89,$05, $14,$30,$89,$05, $FF
..voice1 : db $14,$D0,$80,$09, $14,$D0,$82,$20, $14,$80,$82,$05, $14,$30,$82,$05, $FF

; Sound 28h:
; Sound 2Ah:
.sound28
.sound2A
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 29h: Mother Brain rising into phase 2
.sound29
dw ..voice0
..voice0 : db $08,$40,$9F,$04, $08,$40,$9C,$03, $08,$40,$A1,$03, $08,$40,$93,$04, $08,$40,$93,$25, $FF

; Sound 2Bh: Ridley's fireball hit surface
.sound2B
dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$20, $FF

; Sound 2Ch: Shot Spore Spawn
.sound2C
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$8E,$40, $FF
..voice1 : db $25,$00,$87,$15, $25,$D0,$87,$40, $FF

; Sound 2Dh: Kraid's roar / Crocomire dying cry
.sound2D
dw ..voice0
..voice0 : db $25,$D0,$95,$45, $FF

; Sound 2Eh: Kraid's dying cry
.sound2E
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$9F,$60, $25,$D0,$9A,$30, $25,$D0,$98,$30, $FF
..voice1 : db $25,$00,$9A,$45, $25,$D0,$9C,$60, $25,$D0,$97,$50, $FF

; Sound 2Fh: Yapping maw
.sound2F
dw ..voice0
..voice0 : db $08,$50,$AD,$03, $08,$50,$AD,$04, $F5,$90,$C7, $10,$40,$BC,$07, $10,$20,$C3,$03, $FF

; Sound 30h: Shot super-desgeega
.sound30
dw ..voice0
..voice0 : db $25,$90,$93,$06, $25,$B0,$98,$10, $25,$40,$98,$03, $25,$30,$98,$03, $FF

; Sound 31h: Brinstar plant chewing
.sound31
dw ..voice0
..voice0 : db $0F,$70,$8B,$0D, $0F,$80,$92,$0D, $FF

; Sound 32h: Etecoon wall-jump
.sound32
dw ..voice0
..voice0 : db $1D,$70,$AC,$0B, $FF

; Sound 33h: Etecoon cry
.sound33
dw ..voice0
..voice0 : db $1D,$70,$B4,$04, $1D,$70,$B0,$04, $FF

; Sound 34h: Spike shooting plant spikes
; Sound 6Ah: Shot Maridia floater
.sound34
.sound6A
dw ..voice0
..voice0 : db $00,$D8,$90,$16, $FF

; Sound 35h: Etecoon's theme
.sound35
dw ..voice0
..voice0 : db $1D,$70,$A9,$07, $1D,$20,$A9,$07, $1D,$70,$AE,$07, $1D,$20,$AE,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$B2,$07, $1D,$20,$B2,$07, $1D,$70,$B4,$07, $1D,$20,$B4,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$AB,$07, $1D,$20,$AB,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$B5,$07, $1D,$20,$B5,$07, $1D,$70,$B2,$07, $1D,$20,$B2,$07, $1D,$70,$AE,$07, $1D,$20,$AE,$07, $1D,$70,$AB,$07, $1D,$20,$AB,$07, $1D,$70,$AD,$20, $FF

; Sound 36h: Shot rio / Norfair lava-jumping enemy / lava seahorse
.sound36
dw ..voice0
..voice0 : db $14,$80,$8C,$03, $14,$A0,$91,$05, $14,$50,$8C,$03, $14,$30,$91,$06, $FF

; Sound 37h: Refill/map station engaged
.sound37
dw ..voice0, ..voice1
..voice0 : db $03,$90,$89,$05, $F5,$F0,$BB, $07,$40,$B0,$20,\
              $FE,$00, $07,$40,$BB,$0A, $FB, $FF
..voice1 : db $03,$90,$87,$05, $F5,$F0,$C7, $07,$40,$BC,$20,\
              $FE,$00, $0B,$10,$B9,$07, $FB, $FF

; Sound 38h: Refill/map station disengaged
.sound38
dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$B0, $07,$90,$BB,$08, $FF
..voice1 : db $F5,$F0,$80, $0B,$10,$B9,$08, $FF

; Sound 39h: Dachora speed booster
.sound39
dw sound3InstructionLists_speedBoosterVoice

; Sound 3Ah: Tatori spinning
.sound3A
dw ..voice0
..voice0 : db $07,$60,$C7,$10, $FF

; Sound 3Bh: Dachora shinespark
.sound3B
dw sound3InstructionLists_shinesparkVoice0

; Sound 3Ch: Dachora shinespark ended
.sound3C
dw sound3InstructionLists_shinesparkEndedVoice

; Sound 3Dh: Dachora stored shinespark
.sound3D
dw sound3InstructionLists_storedShinesparkVoice

; Sound 3Eh: Shot Maridia spikey shells / Norfair erratic fireball / ripped / kamer / Maridia snail / yapping maw / Wrecked Ship orbs
.sound3E
dw ..voice0
..voice0 : db $13,$60,$95,$05, $13,$40,$95,$03, $13,$10,$95,$03, $FF

; Sound 3Fh: Alcoon spit / fake Kraid lint / ninja pirate spin jump
.sound3F
dw ..voice0
..voice0 : db $00,$70,$95,$0C, $FF

; Sound 40h:
.sound40
dw ..voice0
..voice0 : db $F5,$F0,$80, $0B,$30,$C7,$08

.EmptyVoice:
db $FF

; Sound 41h: (Empty)
; Sound 44h: (Empty)
.sound41
.sound44
dw .EmptyVoice

; Sound 42h: Boulder bounces
.sound42
dw ..voice0
..voice0 : db $08,$D0,$94,$20, $FF

; Sound 43h: Boulder explodes
.sound43
dw ..voice0
..voice0 : db $08,$D0,$94,$03, $08,$D0,$97,$03, $08,$D0,$99,$20, $FF

; Sound 45h: Typewriter stroke - Ceres self destruct sequence
.sound45
dw ..voice0
..voice0 : db $03,$50,$98,$02, $03,$50,$98,$02, $FF

; Sound 46h: Lavaquake
.sound46
dw ..voice0
..voice0 : db $08,$D0,$8E,$07, $08,$D0,$8E,$10, $08,$D0,$8E,$09, $08,$D0,$8E,$0E, $FF

; Sound 47h: Shot waver
.sound47
dw ..voice0
..voice0 : db $14,$D0,$98,$03, $14,$E0,$97,$03, $14,$D0,$95,$03, $14,$50,$95,$03, $FF

; Sound 48h: Torizo sonic boom
.sound48
dw ..voice0
..voice0 : db $00,$D8,$95,$08, $F5,$F0,$8C, $0B,$D0,$A3,$06, $F5,$F0,$8C, $0B,$B0,$A3,$06, $F5,$F0,$8C, $0B,$70,$A3,$06, $FF

; Sound 49h: Shot fish / crab / Maridia refill candy
.sound49
dw ..voice0
..voice0 : db $14,$80,$AB,$04, $14,$50,$AB,$04, $14,$30,$AB,$04, $14,$20,$AB,$04, $FF

; Sound 4Ah: Shot mini-Draygon
.sound4A
dw ..voice0
..voice0 : db $24,$70,$9C,$03, $24,$50,$9A,$04, $24,$40,$9A,$06, $24,$10,$9A,$06, $FF

; Sound 4Bh: Chozo / torizo footsteps
.sound4B
dw ..voice0
..voice0 : db $08,$A0,$0C,$98,$08, $FF

; Sound 4Ch: Ki-hunter / eye door acid spit
.sound4C
dw ..voice0
..voice0 : db $00,$40,$9C,$08, $0F,$80,$93,$13, $FF

; Sound 4Dh: Gunship hover
.sound4D
dw ..voice0
..voice0 : db $0B,$20,$89,$03, $0B,$30,$89,$03, $0B,$40,$89,$03, $0B,$50,$89,$03, $0B,$60,$89,$03, $0B,$70,$89,$03, $0B,$80,$89,$03, $0B,$60,$89,$03, $0B,$50,$89,$03, $0B,$40,$89,$03, $0B,$30,$89,$03, $FF

; Sound 4Eh: Ceres Ridley getaway
.sound4E
dw sound1InstructionLists_PowerBombVoice0, sound1InstructionLists_PowerBombVoice1

; Sound 4Fh:
.sound4F
dw ..voice0
..voice0 : db $0F,$B0,$93,$10, $0F,$40,$93,$03, $0F,$30,$93,$03, $FF

; Sound 50h: Metroid draining Samus / random metroid cry
.sound50
dw ..voice0, ..voice1
..voice0 : db $24,$A0,$9A,$0E, $FF
..voice1 : db $24,$00,$8C,$03, $24,$90,$98,$14, $FF

; Sound 51h: Shot Wrecked Ship ghost
.sound51
dw ..voice0, ..voice1
..voice0 : db $19,$60,$A4,$13, $19,$50,$A4,$13, $19,$30,$A4,$13, $19,$10,$A4,$13, $FF
..voice1 : db $19,$60,$9F,$16, $19,$50,$9F,$16, $19,$30,$9F,$16, $19,$10,$9F,$16, $FF

; Sound 52h: Shitroid feels remorse
.sound52
dw ..voice0
..voice0 : db $22,$D0,$92,$2B, $FF

; Sound 53h: Shot mini-Crocomire
.sound53
dw ..voice0
..voice0 : db $0F,$B0,$93,$10, $0F,$40,$93,$03, $0F,$30,$93,$03, $FF

; Sound 54h:
.sound54
dw ..voice0
..voice0 : db $14,$B0,$93,$05, $14,$80,$9C,$0A, $14,$40,$9C,$03, $14,$30,$9C,$03, $FF

; Sound 55h: Shot beetom
.sound55
dw ..voice0
..voice0 : db $F5,$F0,$80, $0B,$40,$C5,$04, $F5,$F0,$80, $0B,$30,$F6,$03, $F5,$F0,$80, $0B,$20,$F6,$03, $FF

; Sound 56h: Acquired suit
.sound56
dw sound1InstructionLists_PowerBombVoice2, sound1InstructionLists_PowerBombVoice3

; Sound 57h: Shot door/gate with dud shot / shot reflec
.sound57
dw ..voice0
..voice0 : db $08,$70,$98,$03, $08,$50,$95,$03, $08,$40,$9A,$03, $FF

; Sound 58h: Shot mochtroid
.sound58
dw ..voice0, ..voice1
..voice0 : db $24,$A0,$98,$0D, $FF
..voice1 : db $24,$00,$94,$03, $24,$80,$9A,$15, $FF

; Sound 59h: Ridley's roar
.sound59
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$9D,$30, $FF
..voice1 : db $25,$D0,$A1,$30, $FF

; Sound 5Ah: Shot metroid
.sound5A
dw ..voice0, ..voice1
..voice0 : db $24,$A0,$98,$15, $FF
..voice1 : db $24,$00,$96,$03, $24,$80,$95,$1D, $FF

; Sound 5Ch: Skree hits the ground
.sound5C
dw ..voice0
..voice0 : db $0F,$B0,$8B,$08, $F5,$F0,$BC, $01,$70,$98,$09, $F5,$F0,$BC, $01,$60,$98,$09, $F5,$F0,$BC, $01,$50,$98,$09, $F5,$F0,$BC, $01,$40,$98,$09, $FF

; Sound 5Dh: Sidehopper jumped
.sound5D
dw ..voice0
..voice0 : db $01,$B0,$80,$0F, $01,$60,$80,$03, $01,$40,$80,$03, $FF

; Sound 5Eh: Sidehopper landed
.sound5E
dw ..voice0
..voice0 : db $00,$A0,$84,$0F, $00,$60,$84,$03, $00,$40,$84,$03, $FF

; Sound 5Fh: Shot Lower Norfair rio / desgeega / Norfair slow fireball / walking lava seahorse / Botwoon
.sound5F
dw ..voice0
..voice0 : db $14,$90,$82,$0A, $14,$80,$82,$03, $14,$60,$82,$03, $FF

; Sound 60h:
.sound60
dw ..voice0
..voice0 : db $25,$70,$AB,$20, $FF

; Sound 61h: Dragon / magdollite spit / fire geyser
.sound61
dw ..voice0
..voice0 : db $F5,$50,$B0, $09,$D0,$8C,$20, $FF

; Sound 62h:
.sound62
dw ..voice0
..voice0 : db $F5,$F0,$B0, $09,$D0,$8C,$10, $FF

; Sound 63h: Mother Brain's ketchup beam
.sound63
dw ..voice0, ..voice1
..voice0 : db $00,$E0,$95,$05, $01,$E0,$A4,$05, $08,$E0,$9F,$04, $08,$E0,$9C,$03, $08,$E0,$A1,$03, $08,$E0,$93,$04, $08,$E0,$93,$08, $08,$D0,$8B,$13, $08,$D0,$89,$13, $08,$D0,$85,$16, $08,$D0,$82,$18, $FF
..voice1 : db $00,$E0,$95,$05, $18,$E0,$A4,$05, $18,$E0,$9F,$04, $18,$E0,$9C,$03, $18,$E0,$A1,$03, $18,$E0,$93,$04, $18,$E0,$93,$08, $18,$E0,$8C,$05, $18,$E0,$87,$04, $18,$E0,$84,$03, $FF

; Sound 64h: Holtz cry
.sound64
dw ..voice0
..voice0 : db $F5,$50,$B0, $09,$D0,$8C,$18, $FF

; Sound 65h: Rio cry
.sound65
dw ..voice0
..voice0 : db $14,$A0,$97,$03, $14,$A0,$97,$03, $14,$A0,$97,$03, $14,$30,$97,$03, $14,$20,$97,$03, $FF

; Sound 66h: Shot ki-hunter / walking space pirate
.sound66
dw ..voice0
..voice0 : db $14,$80,$98,$0A, $14,$40,$98,$03, $14,$30,$98,$03, $FF

; Sound 67h: Space pirate / Mother Brain laser
; Sound 6Bh:
.sound67
.sound6B
dw ..voice0
..voice0 : db $00,$D8,$98,$05, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$BC, $0B,$50,$B0,$03, $FF

; Sound 68h: Shot Wrecked Ship robot
.sound68
dw ..voice0
..voice0 : db $1B,$A0,$94,$06, $1B,$90,$8C,$20, $FF

; Sound 69h: Shot Shaktool
.sound69
dw ..voice0
..voice0 : db $02,$80,$89,$05, $02,$40,$89,$03, $02,$10,$89,$03, $FF

; Sound 6Ch: Kago bug
.sound6C
dw ..voice0
..voice0 : db $00,$40,$A8,$08, $FF

; Sound 6Dh: Ceres tiles falling from ceiling
.sound6D
dw ..voice0
..voice0 : db $00,$E0,$91,$08, $08,$90,$A1,$03, $08,$90,$9E,$03, $08,$90,$A3,$03, $08,$90,$8E,$03, $08,$90,$8E,$25, $FF

; Sound 6Eh: Shot Mother Brain phase 1
.sound6E
dw ..voice0, ..voice1
..voice0 : db $23,$D0,$80,$20, $FF
..voice1 : db $23,$D0,$87,$20, $FF

; Sound 6Fh: Mother Brain's cry - low pitch
.sound6F
dw ..voice0, ..voice1
..voice0 : db $25,$E0,$80,$C0, $FF
..voice1 : db $24,$E0,$8C,$C0, $FF

; Sound 70h: Maridia snail bounce
.sound70
dw ..voice0
..voice0 : db $1A,$60,$AB,$06, $1A,$60,$B0,$09, $FF

; Sound 71h: Silence
.sound71
dw ..voice0
..voice0 : db $09,$00,$8C,$03, $FF

; Sound 72h: Shitroid's cry
.sound72
dw ..voice0, ..voice1
..voice0 : db $24,$A0,$8C,$30, $FF
..voice1 : db $24,$00,$9D,$03, $24,$80,$87,$45, $FF

; Sound 73h: Phantoon's cry / Draygon's cry
.sound73
dw ..voice0, ..voice1
..voice0 : db $25,$E0,$A3,$40, $FF
..voice1 : db $25,$00,$A6,$0C, $25,$80,$A3,$40, $FF

; Sound 74h: Crocomire's cry
.sound74
dw ..voice0, ..voice1
..voice0 : db $25,$90,$92,$53, $FF
..voice1 : db $26,$E0,$A6,$09, $26,$E0,$A4,$0D, $26,$E0,$A2,$0D, $26,$E0,$A0,$0D, $FF

; Sound 75h: Crocomire's skeleton collapses
.sound75
dw ..voice0, ..voice1
..voice0 : db $F6,$0C, $0D,$00,$A3,$05, $0D,$A0,$A3,$02, $0D,$C0,$A1,$02, $0D,$C0,$9F,$03, $0D,$C0,$9D,$03, $0D,$B0,$9C,$03, $0D,$A0,$9A,$02, $0D,$90,$A3,$02, $0D,$90,$98,$04, $0D,$A0,$97,$02, $0D,$C0,$95,$02, $0D,$C0,$93,$03, $0D,$C0,$91,$03, $0D,$B0,$90,$03, $0D,$A0,$8E,$02, $0D,$90,$97,$02, $0D,$90,$8C,$04, $FF
..voice1 : db $F6,$0C, $0D,$A0,$97,$02, $0D,$B0,$90,$03, $0D,$C0,$91,$03, $0D,$C0,$91,$03, $0D,$B0,$90,$03, $0D,$90,$97,$02, $0D,$90,$97,$02, $0D,$90,$8C,$04, $0D,$A0,$8B,$02, $0D,$90,$8B,$02, $0D,$C0,$87,$03, $0D,$C0,$85,$03, $0D,$C0,$89,$02, $0D,$B0,$84,$03, $0D,$C0,$89,$02, $0D,$90,$80,$04, $FF

; Sound 77h: Crocomire melting cry
.sound77
dw ..voice0, ..voice1
..voice0 : db $25,$D0,$A7,$15, $25,$D0,$A3,$20, $25,$D0,$A2,$63, $25,$00,$A2,$09, $25,$D0,$A2,$60, $25,$00,$A2,$09, $25,$D0,$A2,$60, $25,$00,$A2,$09, $25,$D0,$A3,$20, $25,$D0,$A2,$33, $FF
..voice1 : db $26,$D0,$A6,$0D, $26,$D0,$A6,$0D, $26,$D0,$A5,$0D, $26,$D0,$A4,$0D, $26,$D0,$A7,$0D, $26,$D0,$A2,$0D, $26,$00,$AA,$7B, $26,$00,$AA,$90, $26,$D0,$A7,$0D, $26,$D0,$A6,$0D, $26,$D0,$A5,$0D, $26,$D0,$A4,$0D, $26,$D0,$A3,$0D, $26,$D0,$A2,$0D, $FF

; Sound 78h: Shitroid draining
.sound78
dw ..voice0, ..voice1
..voice0 : db $24,$A0,$9C,$20, $FF
..voice1 : db $24,$00,$9D,$05, $24,$80,$95,$40, $FF

; Sound 79h: Phantoon appears 1
.sound79
dw ..voice0, ..voice1
..voice0 : db $26,$D0,$95,$38, $FF
..voice1 : db $26,$00,$95,$0A, $26,$D0,$9C,$38, $FF

; Sound 7Ah: Phantoon appears 2
.sound7A
dw ..voice0, ..voice1
..voice0 : db $26,$D0,$8E,$40, $FF
..voice1 : db $26,$00,$8E,$0A, $26,$D0,$99,$40, $FF

; Sound 7Bh: Phantoon appears 3
.sound7B
dw ..voice0, ..voice1
..voice0 : db $26,$D0,$9E,$3D, $FF
..voice1 : db $26,$00,$9E,$0A, $26,$D0,$9D,$3D, $FF

; Sound 7Ch: Botwoon spit
.sound7C
dw ..voice0
..voice0 : db $24,$90,$94,$1A, $24,$30,$94,$10, $FF

; Sound 7Dh: Shitroid feels guilty
.sound7D
dw ..voice0
..voice0 : db $22,$D0,$88,$90, $22,$D0,$8E,$37, $FF

; Sound 7Eh: Mother Brain's cry - high pitch / Phantoon's dying cry
.sound7E
dw ..voice0
..voice0 : db $25,$D0,$87,$C0, $FF

; Sound 7Fh: Mother Brain charging her rainbow
.sound7F
dw ..voice0, ..voice1
..voice0 : db $FE,$00, $24,$D0,$84,$0D, $24,$D0,$85,$0D, $24,$D0,$87,$0D, $24,$D0,$89,$0D, $24,$D0,$8B,$0D, $24,$D0,$8C,$0D, $24,$D0,$8E,$0D, $24,$D0,$90,$0D, $24,$D0,$91,$0D, $24,$D0,$93,$0D, $FB, $FF
..voice1 : db $24,$00,$80,$04,\
              $FE,$00, $24,$D0,$84,$0D, $24,$D0,$85,$0D, $24,$D0,$87,$0D, $24,$D0,$89,$0D, $24,$D0,$8B,$0D, $24,$D0,$8C,$0D, $24,$D0,$8E,$0D, $24,$D0,$90,$0D, $24,$D0,$91,$0D, $24,$D0,$93,$0D, $FB,\
              $FF
}
