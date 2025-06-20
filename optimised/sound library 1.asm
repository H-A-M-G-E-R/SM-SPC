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

mov x,!cpuIo1_write
mov a,sound1InstructionLists_high-1+x : mov y,a : mov a,sound1InstructionLists_low-1+x
jmp soundInitialisation

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
; Sound 29h: Wave SBA end
; Sound 2Bh: (Empty)
; Sound 2Ch: (Empty)
; Sound 2Dh: (Empty)
; Sound 32h: Spin jump end
; Sound 34h: Screw attack end
; Sound 3Ah: (Empty)
.sound2
.soundA
.sound29
.sound2B
.sound2C
.sound2D
.sound32
.sound34
.sound3A
db $00

; Sound 3: Missile
.sound3
db $01 : dw ..voice0
..voice0 : db $00, $95,$D8,$08, $01, $8B,$D8,$30, $FF

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
db $02 : dw ..voice0, ..voice1
..voice0 : db $05, $B4,$00,$15, $F5,$30,$C7, $B7,$50,$25,\
              $FE,$00, $07, $C7,$60,$30, $FB
..voice1 : db $02, $9C,$00,$07, $9C,$10,$03, $9C,$00,$05, $9C,$20,$08

; Shared by charging beam and resume charging beam
.resumeChargingBeamVoice
db $02, $9C,$20,$04, $9C,$30,$06, $9C,$00,$04, $9C,$30,$03, $9C,$30,$07, $9C,$00,$0A, $9C,$30,$03, $9C,$00,$04, $9C,$40,$03, $9C,$40,$07, $9C,$00,$05, $9C,$40,$06, $9C,$40,$03, $9C,$00,$0A, $9C,$50,$03, $9C,$50,$03, $9C,$60,$05, $9C,$00,$06, $9C,$60,$07, $9C,$00,$03, $9C,$60,$04, $9C,$60,$03, $9C,$00,$03,\
   $FE,$00, $9C,$40,$05, $9C,$40,$06, $9C,$40,$07, $9C,$40,$03, $9C,$40,$04, $9C,$40,$03, $9C,$40,$03, $FB

; Sound 9: X-ray
.sound9
db $01 : dw ..voice0
..voice0 : db $F5,$70,$AD, $06, $A4,$40,$FF

; Sound Bh: Uncharged power beam
.soundB
db $01 : dw ..voice0
..voice0 : db $04, $89,$90,$03, $84,$90,$0E, $FF

; Sound Ch: Uncharged ice beam
; Sound Eh: Uncharged ice + wave beam
.soundC
.soundE
db $01 : dw ..voice0
..voice0 : db $04, $8B,$B0,$03, $89,$B0,$07, $F5,$90,$C7, $10, $BC,$90,$0A, $C3,$60,$06, $C7,$30,$03, $C7,$20,$03, $FF

; Sound Dh: Uncharged wave beam
.soundD
db $01 : dw ..voice0
..voice0 : db $04, $89,$90,$03, $84,$70,$0B, $84,$30,$08, $FF

; Sound Fh: Uncharged spazer beam
; Sound 12h: Uncharged spazer + wave beam
.soundF
.sound12
db $01 : dw ..voice0
..voice0 : db $00, $98,$D0,$0C, $04, $80,$C0,$10, $80,$30,$08, $80,$10,$06, $FF

; Sound 10h: Uncharged spazer + ice beam
; Sound 11h: Uncharged spazer + ice + wave beam
; Sound 14h: Uncharged plasma + ice beam
; Sound 15h: Uncharged plasma + ice + wave beam
.sound10
.sound11
.sound14
.sound15
db $01 : dw ..voice0
..voice0 : db $00, $98,$D0,$0C, $F5,$90,$C7, $10, $BC,$90,$0A, $C3,$60,$06, $C7,$30,$03, $C7,$20,$03, $FF

; Sound 13h: Uncharged plasma beam
; Sound 16h: Uncharged plasma + wave beam
.sound13
.sound16
db $01 : dw ..voice0
..voice0 : db $00, $98,$D0,$0C, $04, $80,$B0,$13, $FF

; Sound 17h: Charged power beam
.sound17
db $01 : dw ..voice0
..voice0 : db $04, $84,$D0,$05, $80,$D0,$0C, $02, $98,$80,$03, $98,$60,$03, $98,$50,$03, $FF

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
..voice0 : db $00, $98,$E0,$0C, $F5,$B0,$C7, $10, $BC,$E0,$0A, $C3,$70,$06, $C7,$30,$03, $C7,$20,$03, $FF

; Sound 19h: Charged wave beam
.sound19
db $01 : dw ..voice0
..voice0 : db $04, $84,$E0,$03, $80,$E0,$10, $80,$50,$04, $80,$30,$09, $FF

; Sound 1Bh: Charged spazer beam
; Sound 1Eh: Charged spazer + wave beam
.sound1B
.sound1E
db $01 : dw ..voice0
..voice0 : db $00, $95,$D0,$08, $04, $80,$D0,$0F, $80,$80,$0D, $80,$20,$0A, $FF

; Sound 1Fh: Charged plasma beam / hyper beam
; Sound 22h: Charged plasma + wave beam
.sound1F
.sound22
db $01 : dw ..voice0
..voice0 : db $00, $98,$D0,$0E, $04, $80,$D0,$10, $80,$70,$10, $80,$30,$10, $FF

; Sound 23h: Ice SBA
.sound23
db $01 : dw ..voice0
..voice0 : db $FE,$00, $10, $C0,$50,$03, $C1,$50,$03, $C3,$60,$03, $C5,$60,$03, $C7,$70,$03, $C5,$60,$03, $C3,$50,$03, $C1,$50,$03, $FB

; Sound 24h: Ice SBA end
.sound24
db $02 : dw ..voice0, ..voice1
..voice0 : db $10, $BC,$D0,$0A, $C3,$70,$06, $C7,$30,$03, $C7,$20,$03, $C3,$50,$06, $C7,$40,$03, $C7,$40,$03, $C3,$30,$06, $C7,$20,$03, $C7,$20,$03, $FF
..voice1 : db $04, $80,$D0,$10, $80,$70,$10, $80,$30,$10, $FF

; Sound 25h: Spazer SBA
.sound25
db $01 : dw ..voice0
..voice0 : db $04, $80,$D0,$10, $80,$70,$10, $80,$30,$02, $80,$D0,$10, $80,$70,$10, $80,$30,$10, $FF

; Sound 26h: Spazer SBA end
.sound26
db $01 : dw ..voice0
..voice0 : db $04, $80,$D0,$10, $80,$70,$04, $80,$30,$02, $80,$30,$06, $80,$30,$06, $80,$70,$07, $80,$70,$07, $FF

; Sound 27h: Plasma SBA
.sound27
db $02 : dw ..voice0, ..voice1
..voice0 : db $F5,$30,$C7, $07, $B7,$90,$25, $F5,$30,$B7, $F0,$90,$25, $F5,$B0,$C7, $F0,$90,$25, $FF
..voice1 : db $F5,$30,$C7, $05, $B7,$90,$27, $F5,$30,$B7, $F0,$90,$27, $F5,$B0,$C7, $F0,$90,$27, $FF

; Sound 28h: Wave SBA
.sound28
db $01 : dw ..voice0
..voice0 : db $F5,$30,$C7, $05, $B7,$50,$25, $FF

; Sound 2Ah: Selected save file
.sound2A
db $01 : dw ..voice0
..voice0 : db $07, $C5,$90,$12, $FF

; Sound 2Eh: Saving
.sound2E
db $04 : dw ..voice0, ..voice1, ..voice2, ..voice3
..voice0 : db $F5,$F0,$B1, $06, $99,$45,$19, $B1,$45,$80, $F5,$F0,$99, $B1,$45,$19, $FF
..voice1 : db $F5,$F0,$A7, $06, $8F,$45,$19, $A7,$45,$80, $F5,$F0,$8F, $A7,$45,$19, $FF
..voice2 : db $F5,$F0,$A0, $06, $88,$45,$19, $A0,$45,$80, $F5,$F0,$88, $A0,$45,$19, $FF
..voice3 : db $F5,$F0,$98, $06, $80,$45,$19, $98,$45,$80, $F5,$F0,$80, $98,$45,$19, $FF

; Sound 2Fh: Underwater space jump (without gravity suit)
.sound2F
db $01 : dw ..voice0
..voice0 : db $07, $C7,$80,$10, $FF

; Sound 30h: Resumed spin jump
; Sound 3Fh: Resumed space jump
.sound30
.sound3F
db $01 : dw .resumedSpinJumpVoice

; Sound 31h: Spin jump
.sound31
db $01 : dw ..voice0
..voice0 : db $07, $C5,$30,$10, $C6,$40,$10, $C7,$50,$10

; Shared by resumed spin jump, spin jump and resumed space jump
.resumedSpinJumpVoice
db $FE,$00, $07, $C7,$80,$10, $FB

; Sound 33h: Screw attack
.sound33
db $02 : dw ..voice0, ..voice1
..voice0 : db $07, $C7,$30,$04, $C7,$40,$05, $C7,$50,$06, $C7,$60,$07, $C7,$70,$09, $C7,$80,$0D, $C7,$80,$0F,\
              $FE,$00, $C7,$80,$10, $FB
..voice1 : db $F5,$E0,$BC, $05, $98,$60,$0E, $F5,$E0,$BC, $A4,$70,$08, $F5,$E0,$BC, $B0,$80,$06,\
              $FE,$00, $BC,$80,$03, $C4,$80,$03, $C6,$80,$03, $FB

; Sound 3Eh: Space jump
.sound3E
db $01 : dw .sound33_voice0

; Sound 35h: Samus damaged
.sound35
db $11 : dw ..voice0
..voice0 : db $13, $A4,$60,$10, $A4,$10,$07, $FF

; Sound 36h: Scrolling map
.sound36
db $01 : dw ..voice0
..voice0 : db $0C, $B0,$60,$02, $FF

; Sound 37h: Toggle reserve mode / moved cursor
.sound37
db $01 : dw ..voice0
..voice0 : db $03, $9C,$60,$04, $FF

; Sound 38h: Pause menu transition / toggled equipment
.sound38
db $01 : dw ..voice0
..voice0 : db $F5,$90,$C7, $15, $B0,$90,$15, $FF

; Sound 39h: Switch HUD item
.sound39
db $01 : dw ..voice0
..voice0 : db $03, $9C,$40,$03, $FF

; Sound 3Bh: Hexagon map -> square map transition
.sound3B
db $01 : dw ..voice0
..voice0 : db $05, $9C,$90,$0B, $F5,$F0,$C2, $9C,$90,$12, $FF

; Sound 3Ch: Square map -> hexagon map transition
.sound3C
db $01 : dw ..voice0
..voice0 : db $05, $9C,$90,$0B, $F5,$F0,$80, $9C,$90,$12, $FF

; Sound 3Dh: Dud shot
.sound3D
db $01 : dw ..voice0
..voice0 : db $08, $99,$70,$03, $9C,$70,$05, $FF

; Sound 40h: Mother Brain's rainbow beam
.sound40
db $13 : dw ..voice0, ..voice1, ..voice2
..voice0 : db $FE,$00, $23, $89,$D0,$07, $8B,$D0,$07, $8C,$D0,$07, $8E,$D0,$07, $90,$D0,$07, $91,$D0,$07, $93,$D0,$07, $95,$D0,$07, $97,$D0,$07, $FB
..voice1 : db $06, $BA,$D0,$FF
..voice2 : db $06, $B3,$D0,$FF

; Sound 41h: Resume charging beam
.sound41
db $02 : dw ..voice0, .resumeChargingBeamVoice
..voice0 : db $F5,$70,$C7, $05, $C0,$50,$03,\
              $FE,$00, $07, $C7,$60,$30, $FB

; Sound 42h:
.sound42
db $02 : dw ..voice0, ..voice1
..voice0 : db $24, $9C,$A0,$20, $FF
..voice1 : db $24, $9D,$00,$05, $95,$80,$40, $FF
}
