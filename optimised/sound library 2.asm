handleCpuIo2:
{
mov !i_soundLibrary,#$02

mov a,!cpuIo2_read : mov !cpuIo2_write,a
beq .branch_noChange
cmp a,!cpuIo2_read_prev : beq .branch_noChange

cmp a,#$71 : beq +
cmp a,#$7E : beq +
mov a,!sound2Priority : bne .branch_noChange

+
call resetSound

mov x,!cpuIo2_write : cmp x,#$C0 : bcs .songSpecificSoundInitialisation
mov a,sound2InstructionLists_high-1+x : mov y,a : mov a,sound2InstructionLists_low-1+x
jmp soundInitialisation

.songSpecificSoundInitialisation
jmp songSpecificSoundInitialisation

.branch_noChange
ret
}

sound2InstructionLists:
{
.low
db .sound1,  .sound2,  .sound3,  .sound4,  .sound5,  .sound6,  .sound7,  .sound8,  .sound9,  .soundA,  .soundB,  .soundC,  .soundD,  .soundE,  .soundF,  .sound10,\
   .sound11, .sound12, .sound13, .sound14, .sound15, .sound16, .sound17, .sound18, .sound19, .sound1A, .sound1B, .sound1C, .sound1D, .sound1E, .sound1F, .sound20,\
   .sound21, .sound22, .sound23, .sound24, .sound25, .sound26, .sound27, .sound28, .sound29, .sound2A, .sound2B, .sound2C, .sound2D, .sound2E, .sound2F, .sound30,\
   .sound31, .sound32, .sound33, .sound34, .sound35, .sound36, .sound37, .sound38, .sound39, .sound3A, .sound3B, .sound3C, .sound3D, .sound3E, .sound3F, .sound40,\
   .sound41, .sound42, .sound43, .sound44, .sound45, .sound46, .sound47, .sound48, .sound49, .sound4A, .sound4B, .sound4C, .sound4D, .sound4E, .sound4F, .sound50,\
   .sound51, .sound52, .sound53, .sound54, .sound55, .sound56, .sound57, .sound58, .sound59, .sound5A, .sound5B, .sound5C, .sound5D, .sound5E, .sound5F, .sound60,\
   .sound61, .sound62, .sound63, .sound64, .sound65, .sound66, .sound67, .sound68, .sound69, .sound6A, .sound6B, .sound6C, .sound6D, .sound6E, .sound6F, .sound70,\
   .sound71, .sound72, .sound73, .sound74, .sound75, .sound76, .sound77, .sound78, .sound79, .sound7A, .sound7B, .sound7C, .sound7D, .sound7E, .sound7F

.high
db .sound1>>8,  .sound2>>8,  .sound3>>8,  .sound4>>8,  .sound5>>8,  .sound6>>8,  .sound7>>8,  .sound8>>8,  .sound9>>8,  .soundA>>8,  .soundB>>8,  .soundC>>8,  .soundD>>8,  .soundE>>8,  .soundF>>8,  .sound10>>8,\
   .sound11>>8, .sound12>>8, .sound13>>8, .sound14>>8, .sound15>>8, .sound16>>8, .sound17>>8, .sound18>>8, .sound19>>8, .sound1A>>8, .sound1B>>8, .sound1C>>8, .sound1D>>8, .sound1E>>8, .sound1F>>8, .sound20>>8,\
   .sound21>>8, .sound22>>8, .sound23>>8, .sound24>>8, .sound25>>8, .sound26>>8, .sound27>>8, .sound28>>8, .sound29>>8, .sound2A>>8, .sound2B>>8, .sound2C>>8, .sound2D>>8, .sound2E>>8, .sound2F>>8, .sound30>>8,\
   .sound31>>8, .sound32>>8, .sound33>>8, .sound34>>8, .sound35>>8, .sound36>>8, .sound37>>8, .sound38>>8, .sound39>>8, .sound3A>>8, .sound3B>>8, .sound3C>>8, .sound3D>>8, .sound3E>>8, .sound3F>>8, .sound40>>8,\
   .sound41>>8, .sound42>>8, .sound43>>8, .sound44>>8, .sound45>>8, .sound46>>8, .sound47>>8, .sound48>>8, .sound49>>8, .sound4A>>8, .sound4B>>8, .sound4C>>8, .sound4D>>8, .sound4E>>8, .sound4F>>8, .sound50>>8,\
   .sound51>>8, .sound52>>8, .sound53>>8, .sound54>>8, .sound55>>8, .sound56>>8, .sound57>>8, .sound58>>8, .sound59>>8, .sound5A>>8, .sound5B>>8, .sound5C>>8, .sound5D>>8, .sound5E>>8, .sound5F>>8, .sound60>>8,\
   .sound61>>8, .sound62>>8, .sound63>>8, .sound64>>8, .sound65>>8, .sound66>>8, .sound67>>8, .sound68>>8, .sound69>>8, .sound6A>>8, .sound6B>>8, .sound6C>>8, .sound6D>>8, .sound6E>>8, .sound6F>>8, .sound70>>8,\
   .sound71>>8, .sound72>>8, .sound73>>8, .sound74>>8, .sound75>>8, .sound76>>8, .sound77>>8, .sound78>>8, .sound79>>8, .sound7A>>8, .sound7B>>8, .sound7C>>8, .sound7D>>8, .sound7E>>8, .sound7F>>8

; Instruction list pointer set format:
{
;     pn [iiii]...
; Where:
;     p = priority
;     {
;         0: Other sounds can override this sound
;         1: Most sounds can't override this sound (except silence and Mother Brain's cry - high pitch / Phantoon's dying cry)
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

; Sound 1: Collected small health drop
; Sound 2: Collected big health drop
.sound1
.sound2
db $11 : dw ..voice0
..voice0 : db $15, $C7,$80,$0A, $C7,$50,$0A, $C7,$20,$0A, $FF

; Sound 3: Collected missile drop
; Sound 4: Collected super missile drop
; Sound 5: Collected power bomb drop
.sound3
.sound4
.sound5
db $11 : dw ..voice0
..voice0 : db $0C, $AF,$60,$02, $AF,$00,$01, $AF,$60,$02, $AF,$00,$01, $AF,$60,$02, $FF

; Sound 6: Block destroyed by contact damage
.sound6
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$03, $FF

; Sound 7: (Super) missile hit wall
.sound7
  db $01 : dw ..voice0
..voice0
  db $08
  !c4,200*1.15,20
  !c4,200*36/128*1.15,20
  !c4,200*12/128*1.15,20
  db $FF

; Sound 8: Bomb explosion
.sound8
db $01 : dw ..voice0
..voice0
db $08
!c4,255,20
db $FF

; Sound 9: Enemy killed
.sound9
db $01 : dw ..voice0
..voice0 : db $08, $8B,$D0,$08, $F5,$D0,$BC, $09, $98,$D0,$10, $FF

; Sound Ah: Block crumbled or destroyed by shot
.soundA
db $01 : dw ..voice0
..voice0 : db $08, $9D,$70,$07, $FF

; Sound Bh: Enemy killed by contact damage
.soundB
db $01 : dw ..voice0
..voice0 : db $08, $99,$D0,$02, $9C,$D0,$03, $0F, $8B,$D0,$03, $8C,$E0,$03, $8E,$D0,$0E, $FF

; Sound Ch: Beam hit wall
.soundC
db $01 : dw ..voice0
..voice0 : db $08, $98,$70,$03, $95,$70,$03, $F5,$F0,$BC, $09, $98,$70,$06, $FF

; Sound Dh: Splashed into water
.soundD
db $01 : dw ..voice0
..voice0 : db $0F, $93,$70,$03, $90,$E0,$08, $84,$70,$15, $FF

; Sound Eh: Splashed out of water
.soundE
db $01 : dw ..voice0
..voice0 : db $0F, $90,$60,$03, $84,$60,$15, $FF

; Sound Fh: Low pitched air bubbles
.soundF
db $01 : dw ..voice0
..voice0 : db $0E, $80,$60,$05, $85,$60,$05, $91,$60,$05, $89,$60,$05, $FF

; Sound 10h: Lava/acid damaging Samus
.sound10
db $01 : dw ..voice0
..voice0 : db $F5,$30,$BB, $12, $95,$10,$15, $FF

; Sound 11h: High pitched air bubbles
.sound11
db $01 : dw ..voice0
..voice0 : db $0E, $8C,$60,$05, $91,$60,$05, $FF

; Sound 12h: Plays at random in heated rooms
.sound12
db $01 : dw ..voice0
..voice0 : db $22, $84,$60,$1C, $90,$60,$19, $0E, $80,$60,$10, $22, $89,$60,$19, $0E, $80,$60,$07, $84,$60,$10, $22, $8B,$60,$1B, $FF

; Sound 13h: Plays at random in heated rooms
.sound13
db $01 : dw ..voice0
..voice0 : db $0E, $80,$60,$0A, $84,$60,$07, $22, $8B,$60,$1F, $89,$60,$16, $0E, $80,$60,$0A, $87,$60,$10, $FF

; Sound 14h: Plays at random in heated rooms
.sound14
db $01 : dw ..voice0
..voice0 : db $0E, $80,$60,$0A, $87,$60,$10, $22, $84,$60,$1A, $0E, $80,$60,$0A, $84,$60,$07, $22, $91,$60,$16, $0E, $80,$60,$0A, $87,$60,$10, $FF

; Sound 17h: SA-X's X-ray
.sound17
db $11 : dw sound1InstructionLists_xRayVoice
..voice0 : db $F5,$70,$AA, $06, $A1,$40,$FF

; Sound 18h:
.sound18
db $01 : dw ..voice0
..voice0
db $1B
db $97,$50,$50
db $FF

; Sound 19h:
.sound19
db $01 : dw ..voice0
..voice0
db $F5,$C0,$C4
db $05
db $B4,$50,$10
db $FF

; Sound 1Ah:
.sound1A
db $01 : dw ..voice0
..voice0
db $22
db $98,$A0,$18
db $FF

; Sound 1Bh:
; Sound 42h: Boulder bounces
.sound1B
.sound42
db $01 : dw ..voice0
..voice0
db $08
db $94,$D0,$19
db $FF

; Sound 1Ch: Chozo grabs Samus
.sound1C
db $11 : dw ..voice0
..voice0 : db $0D, $8B,$40,$02, $89,$50,$02, $87,$60,$03, $85,$50,$03, $FF

; Sound 1Dh:
.sound1D
db $01 : dw ..voice0
..voice0
db $21
db $98,$60,$10
db $FF

; Sound 1Eh:
.sound1E
db $01 : dw ..voice0
..voice0
db $21
db $98,$40,$10
db $FF

; Sound 1Fh: SA-X's screw attack
.sound1F
db $02 : dw ..voice0, ..voice1
..voice0
db $07
db $C7,$60,$07
db $C7,$70,$09
db $C7,$80,$0D
db $C7,$80,$0F
db $FE,$00
db $C7,$80,$10
db $FB

..voice1
db $F5,$E0,$BC
db $20
db $98,$80,$06
db $FE,$00
db $BC,$80,$03
db $C4,$80,$03
db $C6,$80,$03
db $FB

; Sound 20h: Shot fly
.sound20
db $01 : dw ..voice0
..voice0 : db $14, $9F,$80,$03, $98,$80,$0A, $98,$40,$03, $98,$30,$03, $FF

; Sound 21h: Shot skree / wall/ninja space pirate
; Sound 5Bh: Skree launches attack
.sound21
.sound5B
db $01 : dw ..voice0
..voice0 : db $14, $98,$80,$03, $9D,$A0,$07, $98,$50,$03, $9D,$30,$06, $FF

; Sound 22h: Shot pipe bug / high-rising slow-falling enemy
.sound22
db $01 : dw ..voice0
..voice0 : db $14, $90,$D0,$03, $93,$E0,$03, $95,$D0,$03, $95,$50,$03, $FF

; Sound 23h: Shot slug / sidehopper / zoomer
.sound23
db $01 : dw ..voice0
..voice0 : db $14, $84,$E0,$03, $89,$D0,$03, $84,$E0,$03, $89,$D0,$03, $FF

; Sound 24h: Small explosion (enemy death)
; Sound 28h:
; Sound 2Ah:
.sound24
.sound28
.sound2A
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$03, $8C,$D0,$25, $FF

; Sound 25h: Big explosion (Ceres door explosion / Crocomire flailing / Crocomire's wall explodes / Draygon tail whip, also used by Mother Brain)
.sound25
db $01 : dw ..voice0
..voice0 : db $00, $91,$E0,$08, $08, $A1,$D0,$03, $9E,$D0,$03, $A3,$D0,$03, $8E,$D0,$03, $8E,$D0,$25, $FF

; Sound 27h: Shot torizo
.sound27
db $12 : dw ..voice0, ..voice1
..voice0 : db $14, $8B,$D0,$11, $89,$D0,$20, $89,$80,$05, $89,$30,$05, $FF
..voice1 : db $14, $80,$D0,$09, $82,$D0,$20, $82,$80,$05, $82,$30,$05, $FF

; Sound 29h: Mother Brain rising into phase 2
.sound29
db $01 : dw ..voice0
..voice0 : db $08, $9F,$40,$04, $9C,$40,$03, $A1,$40,$03, $93,$40,$04, $93,$40,$25, $FF

; Sound 2Bh: Ridley's fireball hit surface
.sound2B
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$20, $FF

; Sound 2Ch:
.sound2C
db $12 : dw ..voice0, ..voice1
..voice0
db $F6,$09
db $1C
db $97,$38,$50
db $FF

..voice1
db $F6,$0D
db $1C
db $97,$00,$03
db $97,$28,$50
db $FF

; Sound 2Dh: Electric water damage
.sound2D
db $11 : dw ..voice0
..voice0
db $02
db $99,$50,$06
db $FF

; Sound 2Fh: Yapping maw
.sound2F
db $01 : dw ..voice0
..voice0 : db $08, $AD,$50,$03, $AD,$50,$04, $F5,$90,$C7, $10, $BC,$40,$07, $C3,$20,$03, $FF

; Sound 30h:
.sound30
db $01 : dw ..voice0
..voice0
db $08
db $98,$D0,$03
db $95,$D0,$03
db $F5,$90,$C7
db $10
db $BC,$40,$07
db $C3,$20,$03
db $FF

; Sound 31h: Brinstar plant chewing
.sound31
db $01 : dw ..voice0
..voice0 : db $0F, $8B,$70,$0D, $92,$80,$0D, $FF

; Sound 32h:
.sound32
db $01 : dw ..voice0
..voice0
db $0F
db $8F,$60,$0A
db $FF

; Sound 34h: Spike shooting plant spikes
.sound34
db $01 : dw ..voice0
..voice0 : db $00, $90,$D8,$16, $FF

; Sound 36h: Shot rio / Norfair lava-jumping enemy / lava seahorse
.sound36
db $01 : dw ..voice0
..voice0 : db $14, $8C,$80,$03, $91,$A0,$05, $8C,$50,$03, $91,$30,$06, $FF

; Sound 37h:
.sound37
db $01 : dw ..voice0
..voice0
db $F6,$11
db $11
db $C7,$A0,$B0
db $FF

; Sound 38h:
.sound38
db $01 : dw ..voice0
..voice0
db $F6,$04
db $11
db $C7,$A0,$B0
db $FF

; Sound 39h: Dachora speed booster
.sound39
db $01 : dw sound3InstructionLists_speedBoosterVoice

; Sound 3Ah: Tatori spinning
.sound3A
db $01 : dw ..voice0
..voice0
db $07
db $C7,$D0,$10
db $FF

; Sound 3Bh: Dachora shinespark
.sound3B
db $01 : dw sound3InstructionLists_shinesparkVoice0

; Sound 3Ch: Library 3 version of missile
.sound3C
db $01 : dw sound1InstructionLists_missileVoice

; Sound 3Dh: Dachora stored shinespark
.sound3D
db $01 : dw sound3InstructionLists_storedShinesparkVoice

; Sound 3Eh: Shot Maridia spikey shells / Norfair erratic fireball / ripped / kamer / Maridia snail / yapping maw / Wrecked Ship orbs
.sound3E
db $01 : dw ..voice0
..voice0
db $13
db $91,$60,$05
db $91,$40,$03
db $91,$10,$03
db $FF

; Sound 3Fh: Alcoon spit / fake Kraid lint / ninja pirate spin jump
.sound3F
db $01 : dw ..voice0
..voice0 : db $00, $95,$70,$0C, $FF

; Sound 43h: Boulder explodes
.sound43
db $01 : dw ..voice0
..voice0 : db $08, $94,$D0,$03, $97,$D0,$03, $99,$D0,$20, $FF

; Sound 45h: Typewriter stroke - Ceres self destruct sequence
.sound45
db $01 : dw ..voice0
..voice0
db $03
db $98,$40,$02
db $98,$30,$02
db $FF

; Sound 46h: Lavaquake
.sound46
db $11 : dw ..voice0
..voice0 : db $08, $8E,$D0,$07, $8E,$D0,$10, $8E,$D0,$09, $8E,$D0,$0E, $FF

; Sound 47h: Shot waver
.sound47
db $01 : dw ..voice0
..voice0 : db $14, $98,$D0,$03, $97,$E0,$03, $95,$D0,$03, $95,$50,$03, $FF

; Sound 48h: Torizo sonic boom
.sound48
db $01 : dw ..voice0
..voice0
db $00
db $95,$D8,$08
db $F5,$F0,$8C
db $05
db $C3,$D0,$08
db $F5,$F0,$8C
db $C3,$B0,$07
db $F5,$F0,$8C
db $C3,$70,$06
db $FF

; Sound 49h: Shot fish / crab / Maridia refill candy
.sound49
db $01 : dw ..voice0
..voice0 : db $14, $AB,$80,$04, $AB,$50,$04, $AB,$30,$04, $AB,$20,$04, $FF

; Sound 4Bh: Chozo / torizo footsteps
.sound4B
db $01 : dw ..voice0
..voice0 : db $08, $98,$A0,$08, $FF

; Sound 4Ch: Ki-hunter / eye door acid spit
.sound4C
db $01 : dw ..voice0
..voice0 : db $00, $9C,$40,$08, $0F, $93,$80,$13, $FF

; Sound 4Dh: Absorb core-X (?)
.sound4D
db $01 : dw ..voice0
..voice0
db $F5,$C0,$C4
db $05
db $B4,$50,$10
db $FF

; Sound 4Fh:
.sound4F
db $01 : dw ..voice0
..voice0 : db $0F, $93,$B0,$10, $93,$40,$03, $93,$30,$03, $FF

; Sound 50h: Metroid draining Samus / random metroid cry
.sound50
db $12 : dw ..voice0, ..voice1
..voice0
db $1C
db $9A,$A0,$0E
db $FF

..voice1
db $1C
db $8C,$00,$03
db $98,$90,$14
db $FF

; Sound 53h: Shot mini-Crocomire
.sound53
db $01 : dw ..voice0
..voice0 : db $0F, $93,$B0,$10, $93,$40,$03, $93,$30,$03, $FF

; Sound 54h:
.sound54
db $11 : dw ..voice0
..voice0 : db $14, $93,$B0,$05, $9C,$80,$0A, $9C,$40,$03, $9C,$30,$03, $FF

; Sound 55h: Shot beetom
.sound55
db $01 : dw ..voice0
..voice0
db $F5,$F0,$80
db $0B
db $C5,$40,$04
db $F5,$F0,$80
db $F6,$30,$03
db $F5,$F0,$80
db $F6,$20,$03
db $FF

; Sound 56h: Acquired suit
.sound56
db $02 : dw sound1InstructionLists_PowerBombVoice2, sound1InstructionLists_PowerBombVoice3

; Sound 57h: Shot door/gate with dud shot / shot reflec
.sound57
db $01 : dw ..voice0
..voice0 : db $08, $98,$70,$03, $95,$50,$03, $9A,$40,$03, $FF

; Sound 58h: Shot mochtroid
.sound58
db $02 : dw ..voice0, ..voice1
..voice0
db $1C
db $98,$A0,$0D
db $FF

..voice1
db $1C
db $94,$00,$03
db $9A,$80,$15
db $FF

; Sound 5Ah: Shot metroid
.sound5A
db $02 : dw ..voice0, ..voice1
..voice0
db $1C
db $98,$A0,$15
db $FF

..voice1
db $1C
db $96,$00,$03
db $95,$80,$1D
db $FF

; Sound 5Ch: Skree hits the ground
.sound5C
db $01 : dw ..voice0
..voice0 : db $0F, $8B,$B0,$08, $F5,$F0,$BC, $01, $98,$70,$09, $F5,$F0,$BC, $98,$60,$09, $F5,$F0,$BC, $98,$50,$09, $F5,$F0,$BC, $98,$40,$09, $FF

; Sound 5Dh: Sidehopper jumped
.sound5D
db $01 : dw ..voice0
..voice0 : db $01, $80,$B0,$0F, $80,$60,$03, $80,$40,$03, $FF

; Sound 5Eh: Sidehopper landed
.sound5E
db $01 : dw ..voice0
..voice0 : db $00, $84,$A0,$0F, $84,$60,$03, $84,$40,$03, $FF

; Sound 5Fh: Shot Lower Norfair rio / desgeega / Norfair slow fireball / walking lava seahorse / Botwoon
.sound5F
db $01 : dw ..voice0
..voice0 : db $14, $82,$90,$0A, $82,$80,$03, $82,$60,$03, $FF

; Sound 61h: Dragon / magdollite spit / fire geyser
.sound61
db $01 : dw ..voice0
..voice0 : db $F5,$50,$B0, $09, $8C,$D0,$20, $FF

; Sound 62h:
.sound62
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$B0, $09, $8C,$D0,$10, $FF

; Sound 64h: Holtz cry
.sound64
db $01 : dw ..voice0
..voice0 : db $F5,$50,$B0, $09, $8C,$D0,$18, $FF

; Sound 65h: Rio cry
.sound65
db $01 : dw ..voice0
..voice0 : db $14, $97,$A0,$03, $97,$A0,$03, $97,$A0,$03, $97,$30,$03, $97,$20,$03, $FF

; Sound 66h: Shot ki-hunter / walking space pirate
.sound66
db $01 : dw ..voice0
..voice0 : db $14, $98,$80,$0A, $98,$40,$03, $98,$30,$03, $FF

; Sound 67h: Space pirate / Mother Brain laser
.sound67
db $01 : dw .laserVoice
.laserVoice
db $00
db $98,$D8,$05
db $F5,$F0,$C7
db $09
db $B0,$50,$03
db $F5,$F0,$C7
db $B0,$50,$03
db $F5,$F0,$C7
db $B0,$50,$06
db $FF

; Sound 69h: Shot Shaktool
.sound69
db $01 : dw ..voice0
..voice0 : db $02, $89,$80,$05, $89,$40,$03, $89,$10,$03, $FF

; Sound 6Ch: Kago bug
.sound6C
db $01 : dw .kagoBugVoice
.kagoBugVoice : db $00, $A8,$40,$08, $FF

; Sound 6Dh: Ceres tiles falling from ceiling
.sound6D
db $01 : dw ..voice0
..voice0 : db $00, $91,$E0,$08, $08, $A1,$90,$03, $9E,$90,$03, $A3,$90,$03, $8E,$90,$03, $8E,$90,$25, $FF

; Sound 15h: Maridia elevatube
; Sound 41h: (Empty)
; Sound 44h: (Empty)
; Sound 52h: (Empty)
; Sound 71h: Silence
; Sound 72h..7Ch: Swappable sample specific 
.sound15
.sound41
.sound44
.sound52
.sound71
.sound72
.sound73
.sound74
.sound75
.sound76
.sound77
.sound78
.sound79
.sound7A
.sound7B
.sound7C
.sound7D
.sound7E
.sound7F
db $00

;;; My sounds below

; Hornoad hurt
.sound26
  db $01 : dw ..voice0
..voice0
  db $14
  !c4,255*200/255,8
  db $FF

; Halzyn hurt
.sound2E
  db $01 : dw ..voice0
..voice0
  db $14
  !fs4,255*200/255,4-1
  !as3,160*200/255,5
  db $FF

; Halzyn lunge
.sound33
  db $01 : dw ..voice0
..voice0
  db $14
  !c3,160*200/255,3-1
  !g3,200*200/255,4-1
  !c4,255*200/255,3-1
  !c4,0,9-1
  !e4,255*200/255,6-1
  !e4,104*200/255,4-1
  !e4,40*200/255,4
  db $FF

; Moto hurt
.sound35
  db $01 : dw ..voice0
..voice0
  db !sampleMotoCry
  !d3,160*200/255,4-1
  !c4,255*200/255,4-1
  !g3,160*200/255,10
  db $FF

; Yameba hurt
.sound40
  db $01 : dw ..voice0
..voice0
  db !sampleMotoCry
  !f5,255*200/255,6-1
  !c5,104*200/255,7
  db $FF

; Sciser hurt
.sound4A
  db $01 : dw ..voice0
..voice0
  db !sampleMotoCry
  !d4,255*200/255,4-1
  !a3,160*200/255,4-1
  !f3,104*200/255,4
  db $FF

; Gold sciser hurt
.sound4E
  db $01 : dw ..voice0
..voice0
  db !sampleMotoCry
  !gs4,255*200/255,4-1
  !cs4,160*200/255,4-1
  !a3,104*200/255,4
  db $FF

; Geemer hurt
.sound51
  db $01 : dw ..voice0
..voice0
  db $14
  !a4,160*128/255,4-1
  !c5,104*128/255,4-1
  !f5,104*128/255,4
  db $FF

; Kihunter hurt
.sound59
  db $01 : dw ..voice0
..voice0
  db $14
  !a3,160*200/255,3-1
  !g4,160*200/255,3-1
  !e4,160*200/255,3-1
  db $FF

; Reo hurt
.sound60
  db $01 : dw ..voice0
..voice0
  db $14
  !d3,160*200/255,3-1
  !d4,160*200/255,3-1
  db $F9,$FF,$F6
  !a3,160*200/255,14
  db $FF

; Sidehopper hurt
.sound63
  db $01 : dw ..voice0
..voice0
  db !sampleSidehopperCry
  !a5,255*200/255,5-1
  !f5,224*200/255,9
  db $FF

; Dessgeega hurt
.sound68
  db $01 : dw ..voice0
..voice0
  db !sampleSidehopperCry
  !a4,255*200/255,5-1
  !c5,224*200/255,9
  db $FF

; Geruda hurt
.sound6A
  db $01 : dw ..voice0
..voice0
  db !sampleSidehopperCry
  !c5,255*200/255,5-1
  db $F9,$FF,$F6
  db $14
  !f4,200*200/255,10
  db $FF

; Placeholders for skultera hurt which I will add later
.sound6B
.sound6E
db $00

; Yard hurt
.sound6F
  db $01 : dw ..voice0
..voice0
  db !sampleMotoCry
  !f4,255*200/255,7-1
  db !sampleSidehopperCry
  !c4,200*200/255,7-1
  db !sampleMotoCry
  !c4,160*200/255,5
  db $FF

; Geruboss hurt
.sound70
  db $01 : dw ..voice0
..voice0
  db !sampleSidehopperCry
  !g4,255*200/255,4-1
  !g5,255*200/255,4-1
  !c5,200*200/255,4-1
  !d5,200*200/255,6
  db $FF

; Waver hurt
.sound16
  db $01 : dw ..voice0
..voice0
  db !sampleSidehopperCry
  !c4,200*200/255,4-1
  db $F5,0 : !b7 ; enable legato
  !f4,255*200/255,6
  db $F9,$FF,$FB
  !f4,255*200/255,4
  db $FF
}
