handleCpuIo2:
{
mov !i_soundLibrary,#$02

mov y,!cpuIo2_read_prev
mov a,!cpuIo2_read : mov !cpuIo2_read_prev,a
mov !cpuIo2_write,a
cmp y,!cpuIo2_read : beq .branch_noChange

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo2_read
cmp a,#$71 : beq +
cmp a,#$7E : beq +
mov a,!sound2Priority : bne .branch_noChange

+
mov a,!sound2 : beq +
call resetSound

+
mov x,!cpuIo2_write : mov !sound2,x
mov a,sound2InstructionLists_high-1+x : mov y,a : mov a,sound2InstructionLists_low-1+x : movw !sound_instructionListPointerSet,ya
mov y,#$00 : mov a,(!sound_instructionListPointerSet)+y : mov y,a
and a,#$0F : beq .branch_silence : mov !misc1,a
mov a,y : xcn a : and a,#$0F : mov !sound2Priority,a

call soundInitialisation

.branch_noChange
ret

.branch_silence
mov a,#$00 : mov !sound2,a
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
;     F8h dd tt -        pitch slide with subnote delta = d, target note = t
;     F9h aaaa - voice's ADSR settings = a
;     FBh - repeat
;     FCh - enable noise
;     FDh - decrement repeat counter and repeat if non-zero
;     FEh cc - set repeat pointer with repeat counter = c
;     FFh - end

; Otherwise:
;     nn vv tt
;     n: Note (range 80h..D3h). F0h is a tie
;     v: Volume
;     t: Length in tics. 1 tic = 16 ms

; There's a 1 tic delay after a note (except when there's legato)
}

; Sound 1: Collected small health drop
.sound1
db $11 : dw ..voice0
..voice0 : db $15, $C7,$80,$0A, $C7,$50,$0A, $C7,$20,$0A, $FF

; Sound 2: Collected big health drop
.sound2
db $11 : dw ..voice0
..voice0 : db $15, $C7,$E0,$0A, $C7,$60,$0A, $C7,$30,$0A, $FF

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
; Sound 8: Bomb explosion
.sound7
.sound8
db $01 : dw ..voice0
..voice0 : db $08, $98,$E0,$03, $95,$E0,$03, $9A,$E0,$03, $8C,$E0,$03, $8C,$E0,$20, $FF

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

; Sound 16h: Fake Kraid cry
.sound16
db $11 : dw ..voice0
..voice0 : db $25, $A8,$60,$10, $FF

; Sound 17h: Morph ball eye's ray
.sound17
db $11 : dw ..voice0
..voice0 : db $F5,$70,$AA, $06, $A1,$40,$40,\
              $FE,$00, $AA,$40,$F0, $FB,\
              $FF

; Sound 18h: Beacon
.sound18
db $01 : dw ..voice0
..voice0 : db $0B, $8C,$20,$03, $8C,$30,$03, $8C,$40,$03, $8C,$50,$03, $8C,$60,$03, $8C,$70,$03, $8C,$80,$03, $8C,$60,$03, $8C,$50,$03, $8C,$40,$03, $8C,$30,$03, $FF

; Sound 19h: Tourian statue unlocking particle
.sound19
db $02 : dw ..voice0, ..voice1
..voice0 : db $10, $C1,$50,$03, $C2,$40,$03, $C3,$30,$03, $C4,$20,$03, $C5,$10,$03, $C6,$10,$03, $C7,$10,$03, $C7,$00,$30, $C7,$60,$03, $C6,$50,$03, $C5,$30,$03, $C4,$30,$03, $C3,$20,$03, $C2,$20,$03, $C1,$10,$03, $C0,$10,$03, $FF
..voice1 : db $08, $99,$D0,$03, $9C,$D0,$04, $0F, $8B,$30,$03, $8C,$40,$03, $8E,$50,$0E, $FF

; Sound 1Ah: n00b tube shattering
.sound1A
db $02 : dw ..voice0, sound3InstructionLists_motherBrainGlassShatteringVoice1
..voice0 : db $08, $94,$D0,$03, $97,$D0,$02, $98,$D0,$03, $9A,$D0,$04, $97,$D0,$03, $9A,$D0,$04, $9D,$D0,$03, $9F,$D0,$03, $94,$D0,$1A, $25, $8C,$40,$26, $FF

; Sound 1Bh: Spike platform stops / tatori hits wall
.sound1B
db $01 : dw ..voice0
..voice0 : db $08, $94,$D0,$19, $FF

; Sound 1Ch: Chozo grabs Samus
.sound1C
db $11 : dw ..voice0
..voice0 : db $F6,$0C, $0D, $8B,$40,$02, $89,$50,$02, $87,$60,$03, $85,$50,$03, $FF

; Sound 1Dh: Dachora cry
.sound1D
db $01 : dw ..voice0
..voice0 : db $14, $9F,$D0,$03, $A4,$D0,$03, $A4,$90,$03, $A3,$40,$03, $A2,$30,$03, $FF

; Sound 1Eh: Sound library 2 version of Mother Brain's glass shattering
.sound1E
db $12 : dw sound3InstructionLists_motherBrainGlassShatteringVoice0, sound3InstructionLists_motherBrainGlassShatteringVoice1

; Sound 1Fh: Fune spits
.sound1F
db $11 : dw ..voice0
..voice0 : db $25, $90,$D0,$09, $00, $97,$D8,$07, $FF

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
..voice0 : db $F6,$0C, $14, $84,$E0,$03, $89,$D0,$03, $84,$E0,$03, $89,$D0,$03, $FF

; Sound 24h: Small explosion (enemy death)
.sound24
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$03, $8C,$D0,$25, $FF

; Sound 25h: Big explosion (Ceres door explosion / Crocomire flailing / Crocomire's wall explodes / Draygon tail whip, also used by Mother Brain)
; Sound 76h: Quake (Crocomire moves / Kraid moves / Ridley's tail hits floor)
.sound25
.sound76
db $01 : dw ..voice0
..voice0 : db $00, $91,$E0,$08, $08, $A1,$D0,$03, $9E,$D0,$03, $A3,$D0,$03, $8E,$D0,$03, $8E,$D0,$25, $FF

; Sound 26h: Bomb Torizo explosive swipe
.sound26
db $01 : dw ..voice0
..voice0 : db $00, $95,$D8,$05, $01, $A4,$90,$08, $F5,$F0,$80, $0B, $B0,$A0,$0E, $F5,$F0,$80, $B0,$70,$0E, $F5,$F0,$80, $B0,$30,$0E, $FF

; Sound 27h: Shot torizo
.sound27
db $12 : dw ..voice0, ..voice1
..voice0 : db $14, $8B,$D0,$11, $89,$D0,$20, $89,$80,$05, $89,$30,$05, $FF
..voice1 : db $14, $80,$D0,$09, $82,$D0,$20, $82,$80,$05, $82,$30,$05, $FF

; Sound 28h:
; Sound 2Ah:
.sound28
.sound2A
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$03, $8C,$D0,$25, $FF

; Sound 29h: Mother Brain rising into phase 2
.sound29
db $01 : dw ..voice0
..voice0 : db $08, $9F,$40,$04, $9C,$40,$03, $A1,$40,$03, $93,$40,$04, $93,$40,$25, $FF

; Sound 2Bh: Ridley's fireball hit surface
.sound2B
db $01 : dw ..voice0
..voice0 : db $08, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $98,$D0,$03, $95,$D0,$03, $9A,$D0,$03, $8C,$D0,$20, $FF

; Sound 2Ch: Shot Spore Spawn
.sound2C
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $8E,$D0,$40, $FF
..voice1 : db $25, $87,$00,$15, $87,$D0,$40, $FF

; Sound 2Dh: Kraid's roar / Crocomire dying cry
.sound2D
db $11 : dw ..voice0
..voice0 : db $25, $95,$D0,$45, $FF

; Sound 2Eh: Kraid's dying cry
.sound2E
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $9F,$D0,$60, $9A,$D0,$30, $98,$D0,$30, $FF
..voice1 : db $25, $9A,$00,$45, $9C,$D0,$60, $97,$D0,$50, $FF

; Sound 2Fh: Yapping maw
.sound2F
db $01 : dw ..voice0
..voice0 : db $08, $AD,$50,$03, $AD,$50,$04, $F5,$90,$C7, $10, $BC,$40,$07, $C3,$20,$03, $FF

; Sound 30h: Shot super-desgeega
.sound30
db $01 : dw ..voice0
..voice0 : db $25, $93,$90,$06, $98,$B0,$10, $98,$40,$03, $98,$30,$03, $FF

; Sound 31h: Brinstar plant chewing
.sound31
db $01 : dw ..voice0
..voice0 : db $0F, $8B,$70,$0D, $92,$80,$0D, $FF

; Sound 32h: Etecoon wall-jump
.sound32
db $01 : dw ..voice0
..voice0 : db $1D, $AC,$70,$0B, $FF

; Sound 33h: Etecoon cry
.sound33
db $01 : dw ..voice0
..voice0 : db $1D, $B4,$70,$04, $B0,$70,$04, $FF

; Sound 34h: Spike shooting plant spikes
; Sound 6Ah: Shot Maridia floater
.sound34
.sound6A
db $01 : dw ..voice0
..voice0 : db $00, $90,$D8,$16, $FF

; Sound 35h: Etecoon's theme
.sound35
db $11 : dw ..voice0
..voice0 : db $1D, $A9,$70,$07, $A9,$20,$07, $AE,$70,$07, $AE,$20,$07, $B0,$70,$07, $B0,$20,$07, $B2,$70,$07, $B2,$20,$07, $B4,$70,$07, $B4,$20,$07, $B0,$70,$07, $B0,$20,$07, $AB,$70,$07, $AB,$20,$07, $B0,$70,$07, $B0,$20,$07, $B5,$70,$07, $B5,$20,$07, $B2,$70,$07, $B2,$20,$07, $AE,$70,$07, $AE,$20,$07, $AB,$70,$07, $AB,$20,$07, $AD,$70,$20, $FF

; Sound 36h: Shot rio / Norfair lava-jumping enemy / lava seahorse
.sound36
db $01 : dw ..voice0
..voice0 : db $14, $8C,$80,$03, $91,$A0,$05, $8C,$50,$03, $91,$30,$06, $FF

; Sound 37h: Refill/map station engaged
.sound37
db $02 : dw ..voice0, ..voice1
..voice0 : db $03, $89,$90,$05, $F5,$F0,$BB, $07, $B0,$40,$20,\
              $FE,$00, $BB,$40,$0A, $FB, $FF
..voice1 : db $03, $87,$90,$05, $F5,$F0,$C7, $07, $BC,$40,$20,\
              $FE,$00, $0B, $B9,$10,$07, $FB, $FF

; Sound 38h: Refill/map station disengaged
.sound38
db $02 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$B0, $07, $BB,$90,$08, $FF
..voice1 : db $F5,$F0,$80, $0B, $B9,$10,$08, $FF

; Sound 39h: Dachora speed booster
.sound39
db $01 : dw sound3InstructionLists_speedBoosterVoice

; Sound 3Ah: Tatori spinning
.sound3A
db $01 : dw ..voice0
..voice0 : db $07, $C7,$60,$10, $FF

; Sound 3Bh: Dachora shinespark
.sound3B
db $01 : dw sound3InstructionLists_shinesparkVoice0

; Sound 3Ch: Dachora shinespark ended
.sound3C
db $01 : dw sound3InstructionLists_shinesparkEndedVoice

; Sound 3Dh: Dachora stored shinespark
.sound3D
db $01 : dw sound3InstructionLists_storedShinesparkVoice

; Sound 3Eh: Shot Maridia spikey shells / Norfair erratic fireball / ripped / kamer / Maridia snail / yapping maw / Wrecked Ship orbs
.sound3E
db $01 : dw ..voice0
..voice0 : db $13, $95,$60,$05, $95,$40,$03, $95,$10,$03, $FF

; Sound 3Fh: Alcoon spit / fake Kraid lint / ninja pirate spin jump
.sound3F
db $01 : dw ..voice0
..voice0 : db $00, $95,$70,$0C, $FF

; Sound 40h:
.sound40
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$80, $0B, $C7,$30,$08, $FF

; Sound 42h: Boulder bounces
.sound42
db $01 : dw ..voice0
..voice0 : db $08, $94,$D0,$20, $FF

; Sound 43h: Boulder explodes
.sound43
db $01 : dw ..voice0
..voice0 : db $08, $94,$D0,$03, $97,$D0,$03, $99,$D0,$20, $FF

; Sound 45h: Typewriter stroke - Ceres self destruct sequence
.sound45
db $01 : dw ..voice0
..voice0 : db $03, $98,$50,$02, $98,$50,$02, $FF

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
..voice0 : db $00, $95,$D8,$08, $F5,$F0,$8C, $0B, $A3,$D0,$06, $F5,$F0,$8C, $A3,$B0,$06, $F5,$F0,$8C, $A3,$70,$06, $FF

; Sound 49h: Shot fish / crab / Maridia refill candy
.sound49
db $01 : dw ..voice0
..voice0 : db $14, $AB,$80,$04, $AB,$50,$04, $AB,$30,$04, $AB,$20,$04, $FF

; Sound 4Ah: Shot mini-Draygon
.sound4A
db $01 : dw ..voice0
..voice0 : db $24, $9C,$70,$03, $9A,$50,$04, $9A,$40,$06, $9A,$10,$06, $FF

; Sound 4Bh: Chozo / torizo footsteps
.sound4B
db $01 : dw ..voice0
..voice0 : db $F6,$0C, $08, $98,$A0,$08, $FF

; Sound 4Ch: Ki-hunter / eye door acid spit
.sound4C
db $01 : dw ..voice0
..voice0 : db $00, $9C,$40,$08, $0F, $93,$80,$13, $FF

; Sound 4Dh: Gunship hover
.sound4D
db $01 : dw ..voice0
..voice0 : db $0B, $89,$20,$03, $89,$30,$03, $89,$40,$03, $89,$50,$03, $89,$60,$03, $89,$70,$03, $89,$80,$03, $89,$60,$03, $89,$50,$03, $89,$40,$03, $89,$30,$03, $FF

; Sound 4Eh: Ceres Ridley getaway
.sound4E
db $12 : dw sound1InstructionLists_PowerBombVoice0, sound1InstructionLists_PowerBombVoice1

; Sound 4Fh:
.sound4F
db $01 : dw ..voice0
..voice0 : db $0F, $93,$B0,$10, $93,$40,$03, $93,$30,$03, $FF

; Sound 50h: Metroid draining Samus / random metroid cry
.sound50
db $12 : dw ..voice0, ..voice1
..voice0 : db $24, $9A,$A0,$0E, $FF
..voice1 : db $24, $8C,$00,$03, $98,$90,$14, $FF

; Sound 51h: Shot Wrecked Ship ghost
.sound51
db $12 : dw ..voice0, ..voice1
..voice0 : db $19, $A4,$60,$13, $A4,$50,$13, $A4,$30,$13, $A4,$10,$13, $FF
..voice1 : db $19, $9F,$60,$16, $9F,$50,$16, $9F,$30,$16, $9F,$10,$16, $FF

; Sound 52h: Shitroid feels remorse
.sound52
db $01 : dw ..voice0
..voice0 : db $22, $92,$D0,$2B, $FF

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
..voice0 : db $F5,$F0,$80, $0B, $C5,$40,$04, $F5,$F0,$80, $F0,$30,$03, $F5,$F0,$80, $F0,$20,$03, $FF

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
..voice0 : db $24, $98,$A0,$0D, $FF
..voice1 : db $24, $94,$00,$03, $9A,$80,$15, $FF

; Sound 59h: Ridley's roar
.sound59
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $9D,$D0,$30, $FF
..voice1 : db $25, $A1,$D0,$30, $FF

; Sound 5Ah: Shot metroid
.sound5A
db $02 : dw ..voice0, ..voice1
..voice0 : db $24, $98,$A0,$15, $FF
..voice1 : db $24, $96,$00,$03, $95,$80,$1D, $FF

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

; Sound 60h:
.sound60
db $01 : dw ..voice0
..voice0 : db $25, $AB,$70,$20, $FF

; Sound 61h: Dragon / magdollite spit / fire geyser
.sound61
db $01 : dw ..voice0
..voice0 : db $F5,$50,$B0, $09, $8C,$D0,$20, $FF

; Sound 62h:
.sound62
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$B0, $09, $8C,$D0,$10, $FF

; Sound 63h: Mother Brain's ketchup beam
.sound63
db $02 : dw ..voice0, ..voice1
..voice0 : db $00, $95,$E0,$05, $01, $A4,$E0,$05, $08,$9F,$E0,$04, $9C,$E0,$03, $A1,$E0,$03, $93,$E0,$04, $93,$E0,$08, $8B,$D0,$13, $89,$D0,$13, $85,$D0,$16, $82,$D0,$18, $FF
..voice1 : db $00, $95,$E0,$05, $18, $A4,$E0,$05, $9F,$E0,$04, $9C,$E0,$03, $A1,$E0,$03, $93,$E0,$04, $93,$E0,$08, $8C,$E0,$05, $87,$E0,$04, $84,$E0,$03, $FF

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
; Sound 6Bh:
.sound67
.sound6B
db $01 : dw ..voice0
..voice0 : db $00, $98,$D8,$05, $F5,$F0,$C7, $0B, $B0,$50,$03, $F5,$F0,$C7, $B0,$50,$03, $F5,$F0,$C7, $B0,$50,$03, $F5,$F0,$BC, $B0,$50,$03, $FF

; Sound 68h: Shot Wrecked Ship robot
.sound68
db $01 : dw ..voice0
..voice0 : db $1B, $94,$A0,$06, $8C,$90,$20, $FF

; Sound 69h: Shot Shaktool
.sound69
db $01 : dw ..voice0
..voice0 : db $02, $89,$80,$05, $89,$40,$03, $89,$10,$03, $FF

; Sound 6Ch: Kago bug
.sound6C
db $01 : dw ..voice0
..voice0 : db $00, $A8,$40,$08, $FF

; Sound 6Dh: Ceres tiles falling from ceiling
.sound6D
db $01 : dw ..voice0
..voice0 : db $00, $91,$E0,$08, $08, $A1,$90,$03, $9E,$90,$03, $A3,$90,$03, $8E,$90,$03, $8E,$90,$25, $FF

; Sound 6Eh: Shot Mother Brain phase 1
.sound6E
db $12 : dw ..voice0, ..voice1
..voice0 : db $23, $80,$D0,$20, $FF
..voice1 : db $23, $87,$D0,$20, $FF

; Sound 6Fh: Mother Brain's cry - low pitch
.sound6F
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $80,$E0,$C0, $FF
..voice1 : db $24, $8C,$E0,$C0, $FF

; Sound 70h: Maridia snail bounce
.sound70
db $01 : dw ..voice0
..voice0 : db $1A, $AB,$60,$06, $B0,$60,$09, $FF

; Sound 15h: Maridia elevatube
; Sound 41h: (Empty)
; Sound 44h: (Empty)
; Sound 71h: Silence
.sound15
.sound41
.sound44
.sound71
db $00

; Sound 72h: Shitroid's cry
.sound72
db $12 : dw ..voice0, ..voice1
..voice0 : db $24, $8C,$A0,$30, $FF
..voice1 : db $24, $9D,$00,$03, $87,$80,$45, $FF

; Sound 73h: Phantoon's cry / Draygon's cry
.sound73
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $A3,$E0,$40, $FF
..voice1 : db $25, $A6,$00,$0C, $A3,$80,$40, $FF

; Sound 74h: Crocomire's cry
.sound74
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $92,$90,$53, $FF
..voice1 : db $26, $A6,$E0,$09, $A4,$E0,$0D, $A2,$E0,$0D, $A0,$E0,$0D, $FF

; Sound 75h: Crocomire's skeleton collapses
.sound75
db $12 : dw ..voice0, ..voice1
..voice0 : db $F6,$0C, $0D, $A3,$00,$05, $A3,$A0,$02, $A1,$C0,$02, $9F,$C0,$03, $9D,$C0,$03, $9C,$B0,$03, $9A,$A0,$02, $A3,$90,$02, $98,$90,$04, $97,$A0,$02, $95,$C0,$02, $93,$C0,$03, $91,$C0,$03, $90,$B0,$03, $8E,$A0,$02, $97,$90,$02, $8C,$90,$04, $FF
..voice1 : db $F6,$0C, $0D, $97,$A0,$02, $90,$B0,$03, $91,$C0,$03, $91,$C0,$03, $90,$B0,$03, $97,$90,$02, $97,$90,$02, $8C,$90,$04, $8B,$A0,$02, $8B,$90,$02, $87,$C0,$03, $85,$C0,$03, $89,$C0,$02, $84,$B0,$03, $89,$C0,$02, $80,$90,$04, $FF

; Sound 77h: Crocomire melting cry
.sound77
db $12 : dw ..voice0, ..voice1
..voice0 : db $25, $A7,$D0,$15, $A3,$D0,$20, $A2,$D0,$63, $A2,$00,$09, $A2,$D0,$60, $A2,$00,$09, $A2,$D0,$60, $A2,$00,$09, $A3,$D0,$20, $A2,$D0,$33, $FF
..voice1 : db $26, $A6,$D0,$0D, $A6,$D0,$0D, $A5,$D0,$0D, $A4,$D0,$0D, $A7,$D0,$0D, $A2,$D0,$0D, $AA,$00,$7B, $AA,$00,$90, $A7,$D0,$0D, $A6,$D0,$0D, $A5,$D0,$0D, $A4,$D0,$0D, $A3,$D0,$0D, $A2,$D0,$0D, $FF

; Sound 78h: Shitroid draining
.sound78
db $02 : dw ..voice0, ..voice1
..voice0 : db $24, $9C,$A0,$20, $FF
..voice1 : db $24, $9D,$00,$05, $95,$80,$40, $FF

; Sound 79h: Phantoon appears 1
.sound79
db $02 : dw ..voice0, ..voice1
..voice0 : db $26, $95,$D0,$38, $FF
..voice1 : db $26, $95,$00,$0A, $9C,$D0,$38, $FF

; Sound 7Ah: Phantoon appears 2
.sound7A
db $02 : dw ..voice0, ..voice1
..voice0 : db $26, $8E,$D0,$40, $FF
..voice1 : db $26, $8E,$00,$0A, $99,$D0,$40, $FF

; Sound 7Bh: Phantoon appears 3
.sound7B
db $02 : dw ..voice0, ..voice1
..voice0 : db $26, $9E,$D0,$3D, $FF
..voice1 : db $26, $9E,$00,$0A, $9D,$D0,$3D, $FF

; Sound 7Ch: Botwoon spit
.sound7C
db $11 : dw ..voice0
..voice0 : db $24, $94,$90,$1A, $94,$30,$10, $FF

; Sound 7Dh: Shitroid feels guilty
.sound7D
db $11 : dw ..voice0
..voice0 : db $22, $88,$D0,$90, $8E,$D0,$37, $FF

; Sound 7Eh: Mother Brain's cry - high pitch / Phantoon's dying cry
.sound7E
db $11 : dw ..voice0
..voice0 : db $25, $87,$D0,$C0, $FF

; Sound 7Fh: Mother Brain charging her rainbow
.sound7F
db $02 : dw ..voice0, ..voice1
..voice0 : db $FE,$00, $24, $84,$D0,$0D, $85,$D0,$0D, $87,$D0,$0D, $89,$D0,$0D, $8B,$D0,$0D, $8C,$D0,$0D, $8E,$D0,$0D, $90,$D0,$0D, $91,$D0,$0D, $93,$D0,$0D, $FB, $FF
..voice1 : db $24, $00,$80,$04,\
              $FE,$00, $84,$D0,$0D, $85,$D0,$0D, $87,$D0,$0D, $89,$D0,$0D, $8B,$D0,$0D, $8C,$D0,$0D, $8E,$D0,$0D, $90,$D0,$0D, $91,$D0,$0D, $93,$D0,$0D, $FB,\
              $FF
}
