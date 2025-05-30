handleCpuIo3:
{
mov a,#$02 : mov !i_soundLibrary,a

mov y,!cpuIo3_read_prev
mov a,!cpuIo3_read : mov !cpuIo3_read_prev,a
mov !cpuIo3_write,a
cmp y,!cpuIo3_read : bne .branch_change

.branch_noChange
mov a,!sound3 : bne +
ret

+
jmp processSound3

.branch_silence
mov a,#$00 : mov !sound3,a
ret

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo3_read : cmp a,#$01 : beq +
mov y,!sound3Priority : cmp y,#$02 : beq .branch_noChange
mov a,!cpuIo3_read : cmp a,#$02 : beq +
dec y : beq .branch_noChange

+
mov a,!sound3 : beq +
mov x,#$00+!sound1_n_channels+!sound2_n_channels : call resetSoundChannel
mov x,#$01+!sound1_n_channels+!sound2_n_channels : call resetSoundChannel

+
mov x,!cpuIo3_write : mov !sound3,x
mov a,sound3InstructionLists_high-1+x : mov y,a : mov a,sound3InstructionLists_low-1+x : movw !sound_instructionListPointerSet,ya
mov y,#$00 : mov a,(!sound_instructionListPointerSet)+y : mov y,a
and a,#$0F : beq .branch_silence : mov !misc1,a
mov a,y : xcn a : and a,#$0F : mov !sound3Priority,a

mov !i_globalChannel,#$00+!sound1_n_channels+!sound2_n_channels
call soundInitialisation
}

processSound3:
{
mov x,#$00+!sound1_n_channels+!sound2_n_channels : call processSoundChannel
mov x,#$01+!sound1_n_channels+!sound2_n_channels : call processSoundChannel

ret
}

sound3InstructionLists:
{
.low
db .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F

.high
db .sound1>>8,  .sound2>>8,  .sound3>>8,  .sound4>>8,  .sound5>>8,  .sound6>>8,  .sound7>>8,  .sound8>>8,  .sound9>>8,  .soundA>>8,  .soundB>>8,  .soundC>>8,  .soundD>>8,  .soundE>>8,  .soundF>>8,  .sound10>>8,\
   .sound11>>8, .sound12>>8, .sound13>>8, .sound14>>8, .sound15>>8, .sound16>>8, .sound17>>8, .sound18>>8, .sound19>>8, .sound1A>>8, .sound1B>>8, .sound1C>>8, .sound1D>>8, .sound1E>>8, .sound1F>>8, .sound20>>8,\
   .sound21>>8, .sound22>>8, .sound23>>8, .sound24>>8, .sound25>>8, .sound26>>8, .sound27>>8, .sound28>>8, .sound29>>8, .sound2A>>8, .sound2B>>8, .sound2C>>8, .sound2D>>8, .sound2E>>8, .sound2F>>8

; Instruction list pointer set format:
{
;     pn [iiii]...
; Where:
;     p = priority
;     {
;         0: Other sounds can override this sound
;         1: Most sounds can't override this sound (except silence and low health beep)
;         2: Only silence can override this sound
;     }
;     n = number of channels
;     iiii = instruction list pointer per channel
}

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
;     t: Length in ticks. 1 tick = 16 ms

; There's a 1 tick delay after a note (except when there's legato)
}

; Sound 1: Silence
; Sound 12h: (Empty)
; Sound 18h: (Empty)
; Sound 1Ah: (Empty)
; Sound 20h: (Empty)
; Sound 25h: Silence (clear speed booster / elevator sound)
; Sound 2Fh: (Empty)
.sound1
.sound12
.sound18
.sound1A
.sound20
.sound25
.sound2F
db $00

; Sound 2: Low health beep
.sound2
db $21 : dw ..voice0
..voice0 : db $FE,$00, $15,$90,$BC,$F0, $FB, $FF

; Sound 3: Speed booster
.sound3
db $01 : dw .speedBoosterVoice

; Speed booster / Dachora speed booster (sound library 2)
.speedBoosterVoice
db $F5,$E0,$C7, $05,$60,$98,$12, $F5,$E0,$C7, $05,$70,$A4,$11, $F5,$E0,$C7, $05,$80,$B0,$10, $F5,$E0,$C7, $05,$80,$B4,$08, $F5,$E0,$C7, $05,$80,$B9,$07, $F5,$E0,$C7, $05,$80,$BC,$06, $F5,$E0,$C1, $05,$80,$BC,$06, $F5,$E0,$C7, $05,$80,$C5,$06

; Shared by speed booster and resume speed booster / shinespark
.resumeSpeedBoosterVoice
db $FE,$00, $05,$60,$C7,$10, $FB,\
   $FF

; Sound 4: Samus landed hard
.sound4
db $02 : dw ..voice0, ..voice1
..voice0 : db $03,$90,$80,$03, $FF
..voice1 : db $03,$A0,$84,$05, $FF

; Sound 5: Samus landed / wall-jumped
.sound5
db $02 : dw ..voice0, ..voice1
..voice0 : db $03,$40,$80,$03, $FF
..voice1 : db $03,$50,$84,$05, $FF

; Sound 6: Samus' footsteps
.sound6
db $01 : dw ..voice0
..voice0 : db $09,$80,$82,$03, $FF

; Sound 7: Door opened
.sound7
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06,$80,$91,$18, $FF
..voice1 : db $F5,$F0,$A8, $02,$80,$90,$18, $FF

; Sound 8: Door closed
.sound8
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$89, $06,$80,$A1,$15, $FF
..voice1 : db $F5,$F0,$87, $02,$80,$9F,$15, $FF

; Sound 9: Missile door shot with missile
.sound9
db $01 : dw ..voice0
..voice0 : db $02,$B0,$8C,$03, $02,$D0,$90,$03, $02,$D0,$8C,$03, $02,$D0,$90,$03, $FF

; Sound Ah: Enemy frozen
.soundA
db $11 : dw ..voice0
..voice0 : db $F6,$0C, $0D,$70,$A3,$01, $0D,$80,$A1,$01, $0D,$80,$9F,$02, $0D,$80,$9D,$02, $0D,$70,$9C,$02, $0D,$50,$9A,$01, $0D,$60,$97,$01, $0D,$60,$98,$03, $FF

; Sound Bh: Elevator
.soundB
db $02 : dw ..voice0, ..voice1
..voice0 : db $FE,$00, $0B,$90,$80,$70, $FB, $FF
..voice1 : db $FE,$00, $06,$40,$98,$13, $FB, $FF

; Sound Ch: Stored shinespark
.soundC
db $01 : dw .storedShinesparkVoice

; Stored shinespark / Dachora stored shinespark (sound library 2)
.storedShinesparkVoice
db $05,$A0,$C7,$B0, $FF

; Sound Dh: Typewriter stroke - intro
.soundD
db $01 : dw ..voice0
..voice0 : db $03,$50,$98,$02, $03,$50,$98,$02, $FF

; Sound Eh: Gate opening/closing
.soundE
db $12 : dw ..voice0, ..voice1
..voice0 : db $F6,$0C, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $03,$50,$85,$05, $FF
..voice1 : db $F5,$60,$A9, $06,$90,$91,$20, $FF

; Sound Fh: Shinespark
.soundF
db $02 : dw .shinesparkVoice0, .shinesparkVoice1

; Shinespark / Dachora shinespark (sound library 2)
.shinesparkVoice0 : db $01,$00,$90,$0C, $01,$D0,$91,$0C, $01,$D0,$93,$0C, $01,$D0,$95,$0A, $01,$D0,$95,$0A, $01,$D0,$97,$08, $01,$D0,$97,$08, $01,$D0,$98,$06, $01,$D0,$98,$06, $01,$D0,$9A,$04, $01,$D0,$9A,$04, $FF
.shinesparkVoice1 : db $F5,$90,$C7, $05,$C0,$98,$10, $F5,$F0,$C7, $05,$C0,$F6,$30, $05,$C0,$C1,$03, $05,$C0,$C3,$03, $05,$C0,$C5,$03, $05,$C0,$C7,$03, $FF

; Sound 10h: Shinespark ended
.sound10
db $01 : dw .shinesparkEndedVoice

; Shinespark ended / Dachora shinespark ended (sound library 2)
.shinesparkEndedVoice
db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03

; Shared by shinespark ended and shorter version
.shortShinesparkEndedVoice
db $08,$D0,$8C,$03, $08,$D0,$8C,$15, $FF

; Sound 11h: (shorter version of shinespark ended)
.sound11
db $01 : dw .shortShinesparkEndedVoice

; Sound 13h: Mother Brain's projectile hits surface
.sound13
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 14h: Gunship elevator activated
.sound14
db $12 : dw ..voice0, ..voice1
..voice0 : db $06,$00,$91,$23, $06,$A0,$91,$18, $F5,$F0,$A9, $06,$A0,$91,$18, $FF
..voice1 : db $02,$00,$90,$23, $02,$20,$90,$18, $F5,$F0,$A8, $02,$20,$90,$18, $FF

; Sound 15h: Gunship elevator deactivated
.sound15
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$89, $06,$80,$A1,$15, $FF
..voice1 : db $F5,$F0,$87, $02,$10,$9F,$15, $FF

; Sound 16h: Crunchy footstep that's supposed to play when Mother Brain is being attacked by Shitroid (but doesn't, see $A9:9599)
.sound16
db $01 : dw ..voice0
..voice0 : db $08,$D0,$A3,$03, $08,$D0,$8E,$03, $08,$D0,$8E,$25, $FF

; Sound 17h: Mother Brain's blue rings
.sound17
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $F5,$F0,$C3, $0B,$90,$A6,$03, $FF

; Sound 19h: Shitroid dies
.sound19
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$93,$26, $FF
..voice1 : db $25,$A0,$8C,$3B, $FF

; Sound 1Bh: Draygon dying cry
.sound1B
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$8E,$30, $25,$D0,$8E,$30, $25,$D0,$8E,$40, $FF
..voice1 : db $25,$00,$A6,$0C, $25,$80,$98,$30, $25,$80,$98,$30, $25,$80,$9A,$10, $25,$80,$98,$40, $FF

; Sound 1Ch: Crocomire spit
.sound1C
db $01 : dw ..voice0
..voice0 : db $00,$D0,$9C,$20, $FF

; Sound 1Dh: Phantoon's flame
.sound1D
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$B5, $09,$D0,$93,$08, $F5,$F0,$B5, $09,$D0,$93,$08, $FF

; Sound 1Eh: Earthquake (Kraid)
.sound1E
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 1Fh: Kraid fires lint
.sound1F
db $01 : dw ..voice0
..voice0 : db $00,$D0,$90,$08, $01,$D0,$8C,$20, $FF

; Sound 21h: Ridley whips its tail
.sound21
db $11 : dw ..voice0
..voice0 : db $07,$D0,$C7,$10, $FF

; Sound 22h: Crocomire acid damage
.sound22
db $01 : dw ..voice0
..voice0 : db $09,$B0,$8C,$05, $0E,$B0,$91,$05, $09,$B0,$8C,$05, $0E,$B0,$91,$05, $09,$B0,$8C,$05, $0E,$B0,$91,$05, $FF

; Sound 23h: Baby metroid cry 1
.sound23
db $01 : dw ..voice0
..voice0 : db $25,$20,$95,$40, $FF

; Sound 24h: Baby metroid cry - Ceres
.sound24
db $11 : dw ..voice0
..voice0 : db $24,$20,$95,$40, $FF

; Sound 26h: Baby metroid cry 2
.sound26
db $01 : dw ..voice0
..voice0 : db $25,$20,$92,$09, $25,$30,$92,$40, $FF

; Sound 27h: Baby metroid cry 3
.sound27
db $01 : dw ..voice0
..voice0 : db $25,$30,$91,$40, $FF

; Sound 28h: Phantoon materialises attack
.sound28
db $01 : dw ..voice0
..voice0 : db $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $00,$D0,$91,$08, $FF

; Sound 29h: Phantoon's super missiled attack
.sound29
db $01 : dw ..voice0
..voice0 : db $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $00,$D0,$91,$06, $FF

; Sound 2Ah: Pause menu ambient beep
.sound2A
db $01 : dw ..voice0
..voice0 : db $0B,$20,$C7,$03, $0B,$20,$C7,$03, $0B,$10,$C7,$03, $FF

; Sound 2Bh: Resume speed booster / shinespark
.sound2B
db $01 : dw .resumeSpeedBoosterVoice

; Sound 2Ch: Ceres door opening
.sound2C
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06,$70,$91,$18, $FF
..voice1 : db $F5,$F0,$A4, $06,$70,$8C,$18, $FF

; Sound 2Dh: Gaining/losing incremental health
.sound2D
db $01 : dw ..voice0
..voice0 : db $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $06,$70,$A8,$01, $06,$00,$A8,$01, $FF

; Sound 2Eh: Mother Brain's glass shattering
.sound2E
db $12 : dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$59, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF
}
