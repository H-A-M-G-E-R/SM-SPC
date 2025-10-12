handleCpuIo1:
{
mov !i_soundLibrary,#$01

mov a,!cpuIo1_read : mov !cpuIo1_write,a
beq .branch_noChange
cmp a,!cpuIo1_read_prev : beq .branch_noChange

cmp a,#$03 : bcc +
mov a,!sound1Priority : bne .branch_noChange

+
call resetSound

mov x,!cpuIo1_write : cmp x,#$C0 : bcs .songSpecificSoundInitialisation
mov a,sound1InstructionLists_high-1+x : mov y,a : mov a,sound1InstructionLists_low-1+x
jmp soundInitialisation

.songSpecificSoundInitialisation
jmp songSpecificSoundInitialisation

.branch_noChange
ret
}

sound1InstructionLists:
{
.low
db .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F, .sound30,\
   .sound31, .sound32, .sound33, .sound34, .sound35, .sound36, .sound37, .sound38, .sound39, .sound3A, .sound3B, .sound3C, .sound3D, .sound3E, .sound3F, .sound40,\
   .sound41, .sound42

.high
db .sound1>>8,  .sound2>>8,  .sound3>>8,  .sound4>>8,  .sound5>>8,  .sound6>>8,  .sound7>>8,  .sound8>>8,  .sound9>>8,  .soundA>>8,  .soundB>>8,  .soundC>>8,  .soundD>>8,  .soundE>>8,  .soundF>>8,  .sound10>>8,\
   .sound11>>8, .sound12>>8, .sound13>>8, .sound14>>8, .sound15>>8, .sound16>>8, .sound17>>8, .sound18>>8, .sound19>>8, .sound1A>>8, .sound1B>>8, .sound1C>>8, .sound1D>>8, .sound1E>>8, .sound1F>>8, .sound20>>8,\
   .sound21>>8, .sound22>>8, .sound23>>8, .sound24>>8, .sound25>>8, .sound26>>8, .sound27>>8, .sound28>>8, .sound29>>8, .sound2A>>8, .sound2B>>8, .sound2C>>8, .sound2D>>8, .sound2E>>8, .sound2F>>8, .sound30>>8,\
   .sound31>>8, .sound32>>8, .sound33>>8, .sound34>>8, .sound35>>8, .sound36>>8, .sound37>>8, .sound38>>8, .sound39>>8, .sound3A>>8, .sound3B>>8, .sound3C>>8, .sound3D>>8, .sound3E>>8, .sound3F>>8, .sound40>>8,\
   .sound41>>8, .sound42>>8

; Instruction list pointer set format:
{
;     pn [iiii]...
; Where:
;     p = priority
;     {
;         0: Other sounds can override this sound
;         1: Most sounds can't override this sound (except power bomb explosion and silence)
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

; Sound 1: Power bomb explosion
.sound1
db $04 : dw .PowerBombVoice0, .PowerBombVoice1, .PowerBombVoice2, .PowerBombVoice3
.PowerBombVoice0 : db $F5,$B0,$C7, $05, $98,$D0,$46, $FF
.PowerBombVoice1 : db $F6,$0F, $F5,$A0,$C7, $09, $80,$D0,$50, $F6,$0A, $F5,$50,$80, $AB,$D0,$46, $FF
.PowerBombVoice2 : db $F6,$0F, $09, $87,$D0,$10, $F5,$B0,$C7, $05, $80,$D0,$60, $FF
.PowerBombVoice3 : db $F6,$05, $09, $82,$D0,$30, $F5,$A0,$80, $05, $C7,$D0,$60, $FF

; Sound 2: Silence
; Sound Ah: X-ray end
; Sound 14h:
; Sound 15h:
; Sound 16h:
; Sound 20h:
; Sound 21h:
; Sound 22h:
; Sound 23h:
; Sound 29h: Wave SBA end
; Sound 2Ah:
; Sound 2Ch: (Empty)
; Sound 2Dh: (Empty)
; Sound 32h: Spin jump end
; Sound 34h: Screw attack end
; Sound 3Ah: (Empty)
.sound2
.soundA
.sound14
.sound15
.sound16
.sound20
.sound21
.sound22
.sound23
.sound29
.sound2A
.sound2C
.sound2D
.sound32
.sound34
.sound3A
db $00

; Sound 3: Missile
.sound3
db $01 : dw .missileVoice
.missileVoice : db $00, $95,$D8,$08, $01, $8B,$D8,$30, $FF

; Sound 4: Super missile
.sound4
db $01 : dw ..voice0
..voice0 : db $00, $95,$D0,$08, $01, $90,$D0,$30, $FF

; Sound 5: Grapple start
.sound5
db $01 : dw ..voice0
..voice0 : db $01, $9D,$80,$10, $02, $93,$50,$07, $93,$50,$03, $93,$50,$05, $93,$50,$08, $93,$50,$04, $93,$50,$06, $93,$50,$04, $FF

; Sound 6: Grappling
.sound6
db $01 : dw ..voice0
..voice0 : db $0D, $80,$50,$03, $85,$50,$04,\
              $FE,$00, $02, $93,$50,$07, $93,$50,$03, $93,$50,$05, $93,$50,$08, $93,$50,$04, $93,$50,$06, $93,$50,$04, $FB

; Sound 7: Grapple end
.sound7
db $01 : dw ..voice0
..voice0 : db $02, $93,$50,$05, $FF

; Sound 8: Charging beam
.sound8
db $02 : dw ..voice0, .chargingBeamVoice1
..voice0
  db $F5,(($A4+32/64*12)-($A4-47/64*12))/52*256 : !b7
  %make_sound_subnote_with_instr(!sampleChargingBeamCommon, "!c5", -47/64*12, 80, 52)
  db $F5,0 : !b7
.resumeChargingBeamVoice0
  %make_sound_subnote_with_instr(!sampleChargingBeamCommon, "!c5", 32/64*12, 80, 255)

.chargingBeamVoice1
  db $F5,(($A4+32/64*12)-($A4-47/64*12))/52*256 : !b7
  %make_sound_subnote_with_instr(!sampleChargingBeam1, "!c5", -47/64*12, 27*3, 52)
  db $F5,0 : !b7
.resumeChargingBeamVoice1
  %make_sound_subnote_with_instr(!sampleChargingBeam1, "!c5", 32/64*12, 22*3, 255)

; Sound 41h: Resume charging beam
.sound41
db $02 : dw .resumeChargingBeamVoice0, .resumeChargingBeamVoice1

; Sound 9: X-ray
.sound9
db $01 : dw .xRayVoice
.xRayVoice : db $F5,$70,$AD, $06, $A4,$40,$FF

; Sound Bh: Uncharged power beam
.soundB
db $01 : dw ..voice0
..voice0
db $04
db $98,$70,$18
db $FF

; Sound Ch: Uncharged plasma beam
; Sound 10h: Uncharged wide + plasma beam
; Sound 11h: Uncharged wide + plasma + wave beam
.soundC
.sound10
.sound11
db $01 : dw ..voice0
..voice0
db $04
db $98,$B0,52
db $FF

; Sound Fh: Uncharged wide beam
.soundF
db $01 : dw ..voice0
..voice0
db $04
db $98,$B0,40
db $FF

; Sound Dh: Uncharged wave beam
.soundD
db $01 : dw ..voice0
..voice0
db $04
db $98,$70,$0B
db $97,$30,$18
db $FF

; Sound Eh: Uncharged plasma + wave beam
.soundE
db $01 : dw ..voice0
..voice0
db $04
db $98,$B0,$0B
db $97,$50,52
db $FF

; Sound 12h: Uncharged wide + wave beam
.sound12
db $01 : dw ..voice0
..voice0
db $04
db $98,$B0,$0B
db $97,$40,40
db $FF

; Sound 13h: Overcharged beam
.sound13
db $01 : dw ..voice0
..voice0
db $00
db $9A,$E0,$06
db $F5,$E0,$99
db $04
db $90,$F0,$10
db $99,$50,52
db $FF

; Sound 17h: Charged power beam
.sound17
db $01 : dw ..voice0
..voice0
db $00
db $98,$D0,$05
db $04
db $97,$D0,$10
db $97,$30,$18
db $FF

; Sound 18h: Charged plasma beam
; Sound 1Ah: Charged plasma + wave beam
; Sound 1Ch: Charged wide + plasma beam
; Sound 1Dh: Charged wide + plasma + wave beam
.sound18
.sound1A
.sound1C
.sound1D
db $01 : dw ..voice0
..voice0
db $00
db $98,$E0,$06
db $04
db $98,$E0,$10
db $98,$40,52
db $FF

; Sound 19h: Charged wave beam
.sound19
db $01 : dw ..voice0
..voice0
db $04
db $84,$E0,$03
db $97,$E0,$10
db $97,$50,$04
db $96,$40,$06
db $95,$28,$06
db $FF

; Sound 1Bh: Charged wide beam
; Sound 1Eh: Charged wide + wave beam
.sound1B
.sound1E
db $01 : dw ..voice0
..voice0
db $00
db $98,$D0,$08
db $04
db $98,$D0,$10
db $98,$40,30
db $FF

; Sound 1Fh: Disruptor beam
; Sound 25h:
; Sound 26h:
.sound1F
.sound25
.sound26
db $01 : dw ..voice0
..voice0
db $04
db $98,$A0,$18
db $FF

; Sound 24h: Diffusion missile explosion
.sound24
db $02 : dw ..voice0, ..voice1
..voice0
db $10
db $BC,$90,$0A
db $C3,$60,$06
db $C7,$20,$03
db $C7,$10,$03
db $C3,$40,$06
db $C7,$30,$03
db $C7,$30,$03
db $FF

..voice1
db $F5,$30,$C5
db $11
db $B7,$70,$20
db $F5,$60,$C7
db $B7,$50,$20
db $FF

; Sound 27h:
.sound27
db $02 : dw ..voice0, .sound24_voice1
..voice0
db $F5,$20,$B7
db $07
db $F0,$B0,$20
db $F5,$20,$C7
db $F0,$B0,$20
db $FF

; Sound 28h:
.sound28
db $01 : dw ..voice0
..voice0
db $F5,$60,$C7
db $05
db $B7,$50,$20
db $FF

; Sound 2Bh: Message popup
.sound2B
db $13 : dw ..voice0, ..voice1, ..voice2
..voice0
db $0A
db $98,$F0,$10
db $98,$30,$10
db $FF

..voice1
db $0A
db $98,$C0,$18
db $98,$18,$08
db $FF

..voice2
db $0A
db $98,$00,$08
db $98,$60,$10
db $FF

; Sound 2Eh: Saving
.sound2E
db $04 : dw ..voice0, ..voice1, ..voice2, ..voice3
..voice0
db $F5,$F0,$B1
db $06
db $99,$45,$19
db $B1,$45,$70
db $FF

..voice1
db $F5,$F0,$A7
db $06
db $8F,$45,$19
db $A7,$45,$70
db $FF

..voice2
db $F5,$F0,$A0
db $06
db $88,$45,$19
db $A0,$45,$70
db $FF

..voice3
db $F5,$F0,$98
db $06
db $80,$45,$19
db $98,$45,$70
db $FF

; Sound 2Fh: Underwater space jump (without gravity suit)
.sound2F
db $02 : dw ..voice0, ..voice1
..voice0
db $07
db $CA,$60,$04
db $C9,$60,$10
db $FF

..voice1
db $0B
db $97,$50,$14
db $FF

; Sound 31h: Spin jump
.sound31
db $01 : dw ..voice0
..voice0
db $FE,$00
db $0B
db $98,$60,$07
db $98,$30,$07
db $FB

; Sound 30h: Resumed spin jump
; Sound 33h: Screw attack
; Sound 3Eh: Space jump
; Sound 3Fh: Resumed space jump
.sound30
.sound33
.sound3E
.sound3F
db $01 : dw ..voice0
..voice0
db $FE,$00
db $0B
db $98,$60,$10
db $FB

; Sound 35h: Samus damaged
.sound35
  db $11 : dw ..voice0
..voice0
  db $13
  !c4,255,4-1
  !c4,80,4-1
  !c4,24,4
  db $FF

; Sound 36h: Scrolling map
.sound36
db $01 : dw ..voice0
..voice0 : db $0C, $B0,$60,$02, $FF

; Sound 37h: Toggle reserve mode / moved cursor
.sound37
db $01 : dw ..voice0
..voice0
db $03
db $9C,$50,$04
db $FF

; Sound 38h: Pause menu transition / toggled equipment
.sound38
db $01 : dw .unpauseVoice
.unpauseVoice : db $F5,$90,$C7, $15, $B0,$90,$15, $FF

; Sound 39h: Switch HUD item
.sound39
  db $01 : dw ..voice0
..voice0
  db $03
  !c4,255,3-1
  !c4,64,4
  db $FF

; Sound 3Bh:
.sound3B
db $01 : dw ..voice0
..voice0
db $16
db $A9,$30,$03
db $FF

; Sound 3Ch:
.sound3C
db $01 : dw ..voice0
..voice0
db $10
db $8F,$20,$03
db $FF

; Sound 3Dh: Dud shot
.sound3D
db $01 : dw ..voice0
..voice0 : db $08, $99,$70,$03, $9C,$70,$05, $FF

; Sound 40h: Message popup 2
.sound40
db $13 : dw ..voice0, ..voice1, ..voice2
..voice0
db $F6,$10
db $0A
db $97,$F0,$10
db $FF

..voice1
db $F6,$04
db $0A
db $98,$D0,$14
db $F6,$06
db $98,$20,$08
db $FF

..voice2
db $0A
db $97,$00,$08
db $98,$50,$10
db $FF

; Sound 42h: Refill/map station engaged (moved from library 2)
.sound42
db $02 : dw ..voice0, ..voice1
..voice0
db $03
db $89,$90,$05
db $F5,$F0,$BB
db $07
db $B0,$40,$20
db $FE,$00
db $BB,$40,$0A
db $FB

..voice1
db $03
db $87,$90,$05
db $F5,$F0,$C7
db $07
db $BC,$40,$20
db $FE,$00
db $06
db $A9,$10,$07
db $FB
}
