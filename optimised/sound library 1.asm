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

.branch_silence
mov a,#$00 : mov !sound1,a
ret

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo1_read
cmp a,#$03 : bcc +
mov a,!sound1Priority : bne .branch_noChange

+
mov a,!sound1 : beq +
mov x,#$00 : call resetSoundChannel
mov x,#$01 : call resetSoundChannel
mov x,#$02 : call resetSoundChannel
mov x,#$03 : call resetSoundChannel

+
mov x,!cpuIo1_write : mov !sound1,x
mov a,sound1InstructionLists_high-1+x : mov y,a : mov a,sound1InstructionLists_low-1+x : movw !sound_instructionListPointerSet,ya
mov y,#$00 : mov a,(!sound_instructionListPointerSet)+y : mov y,a
and a,#$0F : beq .branch_silence : mov !misc1,a
mov a,y : xcn a : and a,#$0F : mov !sound1Priority,a

mov x,#$00
call soundInitialisation
}

processSound1:
{
mov x,#$00 : call processSoundChannel
mov x,#$01 : call processSoundChannel
mov x,#$02 : call processSoundChannel
mov x,#$03 : call processSoundChannel

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

; Sound 1: Power bomb explosion
.sound1
db $04 : dw .PowerBombVoice0, .PowerBombVoice1, .PowerBombVoice2, .PowerBombVoice3
.PowerBombVoice0 : db $F5,$B0,$C7, $05,$D0,$98,$46, $FF
.PowerBombVoice1 : db $F6,$0F, $F5,$A0,$C7, $09,$D0,$80,$50, $F6,$0A, $F5,$50,$80, $09,$D0,$AB,$46, $FF
.PowerBombVoice2 : db $F6,$0F, $09,$D0,$87,$10, $F5,$B0,$C7, $05,$D0,$80,$60, $FF
.PowerBombVoice3 : db $F6,$05, $09,$D0,$82,$30, $F5,$A0,$80, $05,$D0,$C7,$60, $FF

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

; Sound 2Ah: Selected save file
.sound2A
db $01 : dw ..voice0
..voice0 : db $07,$90,$C5,$12, $FF

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
