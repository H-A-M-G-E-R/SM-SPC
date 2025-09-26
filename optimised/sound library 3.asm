handleCpuIo3:
{
mov !i_soundLibrary,#$03

mov a,!cpuIo3_read : mov !cpuIo3_write,a
beq .branch_noChange
cmp a,!cpuIo3_read_prev : beq .branch_noChange

cmp a,#$01 : beq +
mov y,!sound3Priority : cmp y,#$02 : beq .branch_noChange
cmp a,#$02 : beq +
dec y : beq .branch_noChange

+
call resetSound

mov x,!cpuIo3_write : cmp x,#$C0 : bcs .songSpecificSoundInitialisation
mov a,sound3InstructionLists_high-1+x : mov y,a : mov a,sound3InstructionLists_low-1+x
jmp soundInitialisation

.songSpecificSoundInitialisation
jmp songSpecificSoundInitialisation

.branch_noChange
ret
}

sound3InstructionLists:
{
.low
db .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  sampleData_eof,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F

.high
db .sound1>>8,  .sound2>>8,  .sound3>>8,  .sound4>>8,  .sound5>>8,  .sound6>>8,  .sound7>>8,  .sound8>>8,  .sound9>>8,  .soundA>>8,  sampleData_eof>>8,  .soundC>>8,  .soundD>>8,  .soundE>>8,  .soundF>>8,  .sound10>>8,\
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
;     0..7Fh - select instrument
;     F5h dd tt - legato pitch slide with subnote delta = d, target note = t
;     F6h pp - panning bias = (p & 1Fh) / 14h. If p & 80h, left side phase inversion is enabled. If p & 40h, right side phase inversion is enabled
;     F7h ss - subtranspose = s / 100h semitones
;     F8h dd tt -        pitch slide with subnote delta = d, target note = t
;     F9h aaaa - voice's ADSR settings = a (unused in vanilla, removed by default)
;     FBh - repeat
;     FCh - enable noise (unused in vanilla, removed by default)
;     FDh - decrement repeat counter and repeat if non-zero
;     FEh cc - set repeat pointer with repeat counter = c
;     FFh - end

; Otherwise:
;     nn vv tt
;     n: Note (range 80h..D3h, no psychoacoustic adjustment made). F0h is a tie
;     v: Volume
;     t: Length in tics. 1 tic = 16 ms. FFh = play forever

; There's a 1 tic delay after a note (except when there's legato)
}

; Sound Bh is at sampleData_eof

; Sound 1: Silence
; Sound 15h: (Empty)
; Sound 19h: (Empty)
; Sound 1Ah: (Empty)
; Sound 20h: (Empty)
; Sound 22h: (Empty)
; Sound 23h: (Empty)
; Sound 25h: Silence (clear speed booster / elevator sound)
; Sound 26h: (Empty)
; Sound 27h: (Empty)
; Sound 2Ah: (Empty)
; Sound 2Fh: (Empty)
.sound1
.sound15
.sound19
.sound1A
.sound20
.sound22
.sound23
.sound25
.sound26
.sound27
.sound2A
.sound2F
db $00

; Sound 2: Low health beep
.sound2
db $21 : dw ..voice0
..voice0 : db $15, $BC,$90,$FF

; Sound 3: Speed booster
.sound3
db $01 : dw .speedBoosterVoice

; Speed booster / Dachora speed booster (sound library 2)
.speedBoosterVoice
db $F5,$E0,$C7, $11, $98,$60,$12, $F5,$E0,$C7, $A4,$70,$11, $F5,$E0,$C7, $B0,$80,$10, $F5,$E0,$C7, $B4,$80,$08, $F5,$E0,$C7, $B9,$80,$07, $F5,$E0,$C7, $BC,$80,$06, $F5,$E0,$C1, $BC,$80,$06, $F5,$E0,$C7, $C5,$80,$06

; Shared by speed booster and resume speed booster / shinespark
.resumeSpeedBoosterVoice
db $FE,$00, $11, $C7,$60,$10, $FB

; Sound 4: Samus landed hard
.sound4
  db $01 : dw ..voice0
..voice0
  db !sampleSamusLand
  !c5,150*65/50,3
  db $FF

; Sound 5: Samus landed / wall-jumped
.sound5
  db $01 : dw ..voice0
..voice0
  db !sampleSamusLand
  !c5,150*50/50,3
  db $FF

; Sound 6: Samus' footsteps
.sound6
  db $01 : dw ..voice0
..voice0
  db !sampleSamusFootstep
  !c5,150,2
  db $FF

; Sound 7: Door opened
.sound7
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06, $91,$80,$18, $FF
..voice1 : db $F5,$F0,$A8, $02, $90,$80,$18, $FF

; Sound 8: Door closed
.sound8
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$89, $06, $A1,$80,$15, $FF
..voice1 : db $F5,$F0,$87, $02, $9F,$80,$15, $FF

; Sound 9: Missile door shot with missile
.sound9
db $01 : dw ..voice0
..voice0 : db $02, $8C,$B0,$03, $90,$D0,$03, $8C,$D0,$03, $90,$D0,$03, $FF

; Sound Ah: Enemy frozen
.soundA
db $11 : dw ..voice0
..voice0 : db $0D, $A3,$70,$01, $A1,$80,$01, $9F,$80,$02, $9D,$80,$02, $9C,$70,$02, $9A,$50,$01, $97,$60,$01, $98,$60,$03, $FF

; Sound Ch: Stored shinespark
.soundC
db $01 : dw .storedShinesparkVoice

; Stored shinespark / Dachora stored shinespark (sound library 2)
.storedShinesparkVoice
db $11, $C7,$A0,$B0, $FF

; Sound Dh: Typewriter stroke - intro
.soundD
db $01 : dw ..voice0
..voice0 : db $03, $98,$50,$02, $98,$50,$02, $FF

; Sound Eh: Gate opening/closing
.soundE
db $12 : dw ..voice0, ..voice1
..voice0 : db $03, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $85,$50,$05, $FF
..voice1 : db $F5,$60,$A9, $06, $91,$90,$20, $FF

; Sound Fh: Shinespark
.soundF
db $02 : dw .shinesparkVoice0, .shinesparkVoice1

; Shinespark / Dachora shinespark (sound library 2)
.shinesparkVoice0 : db $01, $90,$00,$0C, $91,$D0,$0C, $93,$D0,$0C, $95,$D0,$0A, $95,$D0,$0A, $97,$D0,$08, $97,$D0,$08, $98,$D0,$06, $98,$D0,$06, $9A,$D0,$04, $9A,$D0,$04, $FF
.shinesparkVoice1 : db $F5,$90,$C7, $11, $98,$C0,$10, $F5,$F0,$C7, $F0,$C0,$30, $C1,$C0,$03, $C3,$C0,$03, $C5,$C0,$03, $C7,$C0,$03, $FF

; Sound 10h: Shinespark ended
.sound10
db $01 : dw .shinesparkEndedVoice

; Shinespark ended / Dachora shinespark ended (sound library 2)
.shinesparkEndedVoice
db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03

; Shared by shinespark ended and shorter version
.shortShinesparkEndedVoice
db $08, $8C,$D0,$03, $8C,$D0,$15, $FF

; Sound 11h: (shorter version of shinespark ended)
.sound11
db $01 : dw .shortShinesparkEndedVoice

; Sound 13h: Mother Brain's projectile hits surface
.sound13
db $01 : dw ..voice0
..voice0
db $08
db $98,$E0,$03
db $95,$E0,$03
db $9A,$E0,$03
db $8C,$E0,$03
db $8C,$E0,$20
db $FF

; Sound 14h:
.sound14
db $01 : dw ..voice0
..voice0
db $F5,$30,$C7
db $11
db $C2,$A0,$FE
db $FF

; Sound 16h: Crunchy footstep that's supposed to play when Mother Brain is being attacked by Shitroid (but doesn't, see $A9:9599)
.sound16
db $01 : dw ..voice0
..voice0 : db $08, $A3,$D0,$03, $8E,$D0,$03, $8E,$D0,$25, $FF

; Sound 17h: Library 3 version of space pirate laser
.sound17
db $01 : dw sound2InstructionLists_laserVoice

; Sound 18h: Genesis ice breath
.sound18
db $01 : dw ..voice0
..voice0
db $12
db $95,$50,$05
db $FF

; Sound 1Bh:
.sound1B
db $01 : dw ..voice0
..voice0
db $F5,$F0,$B5
db $09
db $92,$D0,$08
db $F5,$F0,$B5
db $92,$D0,$08
db $FF

; Sound 1Ch: Library 3 version of kago bug
.sound1C
db $01 : dw sound2InstructionLists_kagoBugVoice

; Sound 1Dh: Zap cannon (Crocomire / Draygon)
.sound1D
db $02 : dw ..voice0, ..voice1
..voice0
db $01
db $9D,$80,$08
db $02
db $96,$50,$07
db $95,$50,$03
db $FF

..voice1
db $00
db $98,$D0,$05
db $FF

; Sound 1Eh: Earthquake (Kraid)
.sound1E
db $01 : dw ..voice0
..voice0
db $08
db $98,$E0,$03
db $95,$E0,$03
db $9A,$E0,$03
db $8C,$E0,$03
db $8C,$E0,$20
db $FF

; Sound 1Fh: Kraid fires lint
.sound1F
db $01 : dw ..voice0
..voice0 : db $00, $90,$D0,$08, $01, $8C,$D0,$20, $FF

; Sound 21h: Ridley whips its tail
.sound21
db $11 : dw ..voice0
..voice0 : db $07, $C7,$D0,$10, $FF

; Sound 24h: Sound library 3 version of pause menu transition / toggled equipment
.sound24
db $11 : dw sound1InstructionLists_unpauseVoice

; Sound 28h: Phantoon materialises attack
.sound28
db $01 : dw ..voice0
..voice0 : db $00, $91,$D0,$08, $91,$D0,$08, $91,$D0,$08, $91,$D0,$08, $91,$D0,$08, $91,$D0,$08, $FF

; Sound 29h: Phantoon's super missiled attack
.sound29
db $01 : dw ..voice0
..voice0 : db $00, $91,$D0,$06, $91,$D0,$06, $91,$D0,$06, $91,$D0,$06, $91,$D0,$06, $FF

; Sound 2Bh: Resume speed booster / shinespark
.sound2B
db $01 : dw .resumeSpeedBoosterVoice

; Sound 2Ch: Ceres door opening
.sound2C
db $12 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$A9, $06, $91,$70,$18, $FF
..voice1 : db $F5,$F0,$A4, $06, $8C,$70,$18, $FF

; Sound 2Dh: Gaining/losing incremental health
.sound2D
  db $01 : dw ..voice0
..voice0
  db !sampleHeatDamage
  !c5,40,2
  db $FF

; Sound 2Eh: DMX door closing
.sound2E
db $12 : dw ..voice0, ..voice1
..voice0
db $F5,$F0,$91
db $06
db $A9,$70,$18
db $FF

..voice1
db $F5,$F0,$8C
db $06
db $A4,$70,$18
db $FF

;;; My sounds below

; Lava damage
.sound12
  db $01 : dw .voice0
.voice0
  db !sampleLavaDamage
  !c5,255,29
  db $FF
}
