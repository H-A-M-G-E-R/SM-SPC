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

.branch_silence
mov a,#$00 : mov !sound2,a
ret

.branch_change
cmp a,#$00 : beq .branch_noChange
mov a,!cpuIo2_read
cmp a,#$71 : beq +
cmp a,#$7E : beq +
mov a,!sound2Priority : bne .branch_noChange

+
mov a,!sound2 : beq +
mov x,#$00+!sound1_n_channels : call resetSoundChannel
mov x,#$01+!sound1_n_channels : call resetSoundChannel

+
mov x,!cpuIo2_write : mov !sound2,x
mov a,sound2InstructionLists_high-1+x : mov y,a : mov a,sound2InstructionLists_low-1+x : movw !sound_instructionListPointerSet,ya
mov y,#$00 : mov a,(!sound_instructionListPointerSet)+y : mov y,a
and a,#$0F : beq .branch_silence : mov !misc1,a
mov a,y : xcn a : and a,#$0F : mov !sound2Priority,a

mov !i_globalChannel,#$00+!sound1_n_channels
mov a,#$00
mov !sound2_channel0_voiceBitset,a
mov !sound2_channel1_voiceBitset,a
call soundInitialisation
}

processSound2:
{
mov x,#$00+!sound1_n_channels : call processSoundChannel
mov x,#$01+!sound1_n_channels : call processSoundChannel

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

; Sound 1: Collected small health drop
.sound1
db $11 : dw ..voice0
..voice0 : db $15,$80,$C7,$0A, $15,$50,$C7,$0A, $15,$20,$C7,$0A, $FF

; Sound 2: Collected big health drop
.sound2
db $11 : dw ..voice0
..voice0 : db $15,$E0,$C7,$0A, $15,$60,$C7,$0A, $15,$30,$C7,$0A, $FF

; Sound 3: Collected missile drop
; Sound 4: Collected super missile drop
; Sound 5: Collected power bomb drop
.sound3
.sound4
.sound5
db $11 : dw ..voice0
..voice0 : db $0C,$60,$AF,$02, $0C,$00,$AF,$01, $0C,$60,$AF,$02, $0C,$00,$AF,$01, $0C,$60,$AF,$02, $FF

; Sound 6: Block destroyed by contact damage
.sound6
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $FF

; Sound 7: (Super) missile hit wall
; Sound 8: Bomb explosion
.sound7
.sound8
db $01 : dw ..voice0
..voice0 : db $08,$E0,$98,$03, $08,$E0,$95,$03, $08,$E0,$9A,$03, $08,$E0,$8C,$03, $08,$E0,$8C,$20, $FF

; Sound 9: Enemy killed
.sound9
db $01 : dw ..voice0
..voice0 : db $08,$D0,$8B,$08, $F5,$D0,$BC, $09,$D0,$98,$10, $FF

; Sound Ah: Block crumbled or destroyed by shot
.soundA
db $01 : dw ..voice0
..voice0 : db $08,$70,$9D,$07, $FF

; Sound Bh: Enemy killed by contact damage
.soundB
db $01 : dw ..voice0
..voice0 : db $08,$D0,$99,$02, $08,$D0,$9C,$03, $0F,$D0,$8B,$03, $0F,$E0,$8C,$03, $0F,$D0,$8E,$0E, $FF

; Sound Ch: Beam hit wall
.soundC
db $01 : dw ..voice0
..voice0 : db $08,$70,$98,$03, $08,$70,$95,$03, $F5,$F0,$BC, $09,$70,$98,$06, $FF

; Sound Dh: Splashed into water
.soundD
db $01 : dw ..voice0
..voice0 : db $0F,$70,$93,$03, $0F,$E0,$90,$08, $0F,$70,$84,$15, $FF

; Sound Eh: Splashed out of water
.soundE
db $01 : dw ..voice0
..voice0 : db $0F,$60,$90,$03, $0F,$60,$84,$15, $FF

; Sound Fh: Low pitched air bubbles
.soundF
db $01 : dw ..voice0
..voice0 : db $0E,$60,$80,$05, $0E,$60,$85,$05, $0E,$60,$91,$05, $0E,$60,$89,$05, $FF

; Sound 10h: Lava/acid damaging Samus
.sound10
db $01 : dw ..voice0
..voice0 : db $F5,$30,$BB, $12,$10,$95,$15, $FF

; Sound 11h: High pitched air bubbles
.sound11
db $01 : dw ..voice0
..voice0 : db $0E,$60,$8C,$05, $0E,$60,$91,$05, $FF

; Sound 12h: Plays at random in heated rooms
.sound12
db $01 : dw ..voice0
..voice0 : db $22,$60,$84,$1C, $22,$60,$90,$19, $0E,$60,$80,$10, $22,$60,$89,$19, $0E,$60,$80,$07, $0E,$60,$84,$10, $22,$60,$8B,$1B, $FF

; Sound 13h: Plays at random in heated rooms
.sound13
db $01 : dw ..voice0
..voice0 : db $0E,$60,$80,$0A, $0E,$60,$84,$07, $22,$60,$8B,$1F, $22,$60,$89,$16, $0E,$60,$80,$0A, $0E,$60,$87,$10, $FF

; Sound 14h: Plays at random in heated rooms
.sound14
db $01 : dw ..voice0
..voice0 : db $0E,$60,$80,$0A, $0E,$60,$87,$10, $22,$60,$84,$1A, $0E,$60,$80,$0A, $0E,$60,$84,$07, $22,$60,$91,$16, $0E,$60,$80,$0A, $0E,$60,$87,$10, $FF

; Sound 16h: Fake Kraid cry
.sound16
db $11 : dw ..voice0
..voice0 : db $25,$60,$A8,$10, $FF

; Sound 17h: Morph ball eye's ray
.sound17
db $11 : dw ..voice0
..voice0 : db $F5,$70,$AA, $06,$40,$A1,$40,\
              $FE,$00, $06,$40,$AA,$F0, $FB,\
              $FF

; Sound 18h: Beacon
.sound18
db $01 : dw ..voice0
..voice0 : db $0B,$20,$8C,$03, $0B,$30,$8C,$03, $0B,$40,$8C,$03, $0B,$50,$8C,$03, $0B,$60,$8C,$03, $0B,$70,$8C,$03, $0B,$80,$8C,$03, $0B,$60,$8C,$03, $0B,$50,$8C,$03, $0B,$40,$8C,$03, $0B,$30,$8C,$03, $FF

; Sound 19h: Tourian statue unlocking particle
.sound19
db $02 : dw ..voice0, ..voice1
..voice0 : db $10,$50,$C1,$03, $10,$40,$C2,$03, $10,$30,$C3,$03, $10,$20,$C4,$03, $10,$10,$C5,$03, $10,$10,$C6,$03, $10,$10,$C7,$03, $10,$00,$C7,$30, $10,$60,$C7,$03, $10,$50,$C6,$03, $10,$30,$C5,$03, $10,$30,$C4,$03, $10,$20,$C3,$03, $10,$20,$C2,$03, $10,$10,$C1,$03, $10,$10,$C0,$03, $FF
..voice1 : db $08,$D0,$99,$03, $08,$D0,$9C,$04, $0F,$30,$8B,$03, $0F,$40,$8C,$03, $0F,$50,$8E,$0E, $FF

; Sound 1Ah: n00b tube shattering
.sound1A
db $02 : dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$03, $08,$D0,$97,$02, $08,$D0,$98,$03, $08,$D0,$9A,$04, $08,$D0,$97,$03, $08,$D0,$9A,$04, $08,$D0,$9D,$03, $08,$D0,$9F,$03, $08,$D0,$94,$1A, $25,$40,$8C,$26, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF

; Sound 1Bh: Spike platform stops / tatori hits wall
.sound1B
db $01 : dw ..voice0
..voice0 : db $08,$D0,$94,$19, $FF

; Sound 1Ch: Chozo grabs Samus
.sound1C
db $11 : dw ..voice0
..voice0 : db $F6,$0C, $0D,$40,$8B,$02, $0D,$50,$89,$02, $0D,$60,$87,$03, $0D,$50,$85,$03, $FF

; Sound 1Dh: Dachora cry
.sound1D
db $01 : dw ..voice0
..voice0 : db $14,$D0,$9F,$03, $14,$D0,$A4,$03, $14,$90,$A4,$03, $14,$40,$A3,$03, $14,$30,$A2,$03, $FF

; Sound 1Eh:
.sound1E
db $12 : dw ..voice0, ..voice1
..voice0 : db $08,$D0,$94,$59, $FF
..voice1 : db $25,$D0,$98,$10, $25,$D0,$93,$16, $25,$90,$8F,$15, $FF

; Sound 1Fh: Fune spits
.sound1F
db $11 : dw ..voice0
..voice0 : db $25,$D0,$90,$09, $00,$D8,$97,$07, $FF

; Sound 20h: Shot fly
.sound20
db $01 : dw ..voice0
..voice0 : db $14,$80,$9F,$03, $14,$80,$98,$0A, $14,$40,$98,$03, $14,$30,$98,$03, $FF

; Sound 21h: Shot skree / wall/ninja space pirate
; Sound 5Bh: Skree launches attack
.sound21
.sound5B
db $01 : dw ..voice0
..voice0 : db $14,$80,$98,$03, $14,$A0,$9D,$07, $14,$50,$98,$03, $14,$30,$9D,$06, $FF

; Sound 22h: Shot pipe bug / high-rising slow-falling enemy
.sound22
db $01 : dw ..voice0
..voice0 : db $14,$D0,$90,$03, $14,$E0,$93,$03, $14,$D0,$95,$03, $14,$50,$95,$03, $FF

; Sound 23h: Shot slug / sidehopper / zoomer
.sound23
db $01 : dw ..voice0
..voice0 : db $F6,$0C, $14,$E0,$84,$03, $14,$D0,$89,$03, $14,$E0,$84,$03, $14,$D0,$89,$03, $FF

; Sound 24h: Small explosion (enemy death)
.sound24
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 25h: Big explosion (Ceres door explosion / Crocomire flailing / Crocomire's wall explodes / Draygon tail whip, also used by Mother Brain)
; Sound 76h: Quake (Crocomire moves / Kraid moves / Ridley's tail hits floor)
.sound25
.sound76
db $01 : dw ..voice0
..voice0 : db $00,$E0,$91,$08, $08,$D0,$A1,$03, $08,$D0,$9E,$03, $08,$D0,$A3,$03, $08,$D0,$8E,$03, $08,$D0,$8E,$25, $FF

; Sound 26h:
.sound26
db $01 : dw ..voice0
..voice0 : db $00,$D8,$95,$05, $01,$90,$A4,$08, $F5,$F0,$80, $0B,$A0,$B0,$0E, $F5,$F0,$80, $0B,$70,$B0,$0E, $F5,$F0,$80, $0B,$30,$B0,$0E, $FF

; Sound 27h: Shot torizo
.sound27
db $12 : dw ..voice0, ..voice1
..voice0 : db $14,$D0,$8B,$11, $14,$D0,$89,$20, $14,$80,$89,$05, $14,$30,$89,$05, $FF
..voice1 : db $14,$D0,$80,$09, $14,$D0,$82,$20, $14,$80,$82,$05, $14,$30,$82,$05, $FF

; Sound 28h:
; Sound 2Ah:
.sound28
.sound2A
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$03, $08,$D0,$8C,$25, $FF

; Sound 29h: Mother Brain rising into phase 2
.sound29
db $01 : dw ..voice0
..voice0 : db $08,$40,$9F,$04, $08,$40,$9C,$03, $08,$40,$A1,$03, $08,$40,$93,$04, $08,$40,$93,$25, $FF

; Sound 2Bh: Ridley's fireball hit surface
.sound2B
db $01 : dw ..voice0
..voice0 : db $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$98,$03, $08,$D0,$95,$03, $08,$D0,$9A,$03, $08,$D0,$8C,$20, $FF

; Sound 2Ch: Shot Spore Spawn
.sound2C
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$8E,$40, $FF
..voice1 : db $25,$00,$87,$15, $25,$D0,$87,$40, $FF

; Sound 2Dh: Kraid's roar / Crocomire dying cry
.sound2D
db $11 : dw ..voice0
..voice0 : db $25,$D0,$95,$45, $FF

; Sound 2Eh: Kraid's dying cry
.sound2E
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$9F,$60, $25,$D0,$9A,$30, $25,$D0,$98,$30, $FF
..voice1 : db $25,$00,$9A,$45, $25,$D0,$9C,$60, $25,$D0,$97,$50, $FF

; Sound 2Fh: Yapping maw
.sound2F
db $01 : dw ..voice0
..voice0 : db $08,$50,$AD,$03, $08,$50,$AD,$04, $F5,$90,$C7, $10,$40,$BC,$07, $10,$20,$C3,$03, $FF

; Sound 30h: Shot super-desgeega
.sound30
db $01 : dw ..voice0
..voice0 : db $25,$90,$93,$06, $25,$B0,$98,$10, $25,$40,$98,$03, $25,$30,$98,$03, $FF

; Sound 31h: Brinstar plant chewing
.sound31
db $01 : dw ..voice0
..voice0 : db $0F,$70,$8B,$0D, $0F,$80,$92,$0D, $FF

; Sound 32h: Etecoon wall-jump
.sound32
db $01 : dw ..voice0
..voice0 : db $1D,$70,$AC,$0B, $FF

; Sound 33h: Etecoon cry
.sound33
db $01 : dw ..voice0
..voice0 : db $1D,$70,$B4,$04, $1D,$70,$B0,$04, $FF

; Sound 34h: Spike shooting plant spikes
; Sound 6Ah: Shot Maridia floater
.sound34
.sound6A
db $01 : dw ..voice0
..voice0 : db $00,$D8,$90,$16, $FF

; Sound 35h: Etecoon's theme
.sound35
db $11 : dw ..voice0
..voice0 : db $1D,$70,$A9,$07, $1D,$20,$A9,$07, $1D,$70,$AE,$07, $1D,$20,$AE,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$B2,$07, $1D,$20,$B2,$07, $1D,$70,$B4,$07, $1D,$20,$B4,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$AB,$07, $1D,$20,$AB,$07, $1D,$70,$B0,$07, $1D,$20,$B0,$07, $1D,$70,$B5,$07, $1D,$20,$B5,$07, $1D,$70,$B2,$07, $1D,$20,$B2,$07, $1D,$70,$AE,$07, $1D,$20,$AE,$07, $1D,$70,$AB,$07, $1D,$20,$AB,$07, $1D,$70,$AD,$20, $FF

; Sound 36h: Shot rio / Norfair lava-jumping enemy / lava seahorse
.sound36
db $01 : dw ..voice0
..voice0 : db $14,$80,$8C,$03, $14,$A0,$91,$05, $14,$50,$8C,$03, $14,$30,$91,$06, $FF

; Sound 37h: Refill/map station engaged
.sound37
db $02 : dw ..voice0, ..voice1
..voice0 : db $03,$90,$89,$05, $F5,$F0,$BB, $07,$40,$B0,$20,\
              $FE,$00, $07,$40,$BB,$0A, $FB, $FF
..voice1 : db $03,$90,$87,$05, $F5,$F0,$C7, $07,$40,$BC,$20,\
              $FE,$00, $0B,$10,$B9,$07, $FB, $FF

; Sound 38h: Refill/map station disengaged
.sound38
db $02 : dw ..voice0, ..voice1
..voice0 : db $F5,$F0,$B0, $07,$90,$BB,$08, $FF
..voice1 : db $F5,$F0,$80, $0B,$10,$B9,$08, $FF

; Sound 39h: Dachora speed booster
.sound39
db $01 : dw sound3InstructionLists_speedBoosterVoice

; Sound 3Ah: Tatori spinning
.sound3A
db $01 : dw ..voice0
..voice0 : db $07,$60,$C7,$10, $FF

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
..voice0 : db $13,$60,$95,$05, $13,$40,$95,$03, $13,$10,$95,$03, $FF

; Sound 3Fh: Alcoon spit / fake Kraid lint / ninja pirate spin jump
.sound3F
db $01 : dw ..voice0
..voice0 : db $00,$70,$95,$0C, $FF

; Sound 40h:
.sound40
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$80, $0B,$30,$C7,$08, $FF

; Sound 42h: Boulder bounces
.sound42
db $01 : dw ..voice0
..voice0 : db $08,$D0,$94,$20, $FF

; Sound 43h: Boulder explodes
.sound43
db $01 : dw ..voice0
..voice0 : db $08,$D0,$94,$03, $08,$D0,$97,$03, $08,$D0,$99,$20, $FF

; Sound 45h: Typewriter stroke - Ceres self destruct sequence
.sound45
db $01 : dw ..voice0
..voice0 : db $03,$50,$98,$02, $03,$50,$98,$02, $FF

; Sound 46h: Lavaquake
.sound46
db $11 : dw ..voice0
..voice0 : db $08,$D0,$8E,$07, $08,$D0,$8E,$10, $08,$D0,$8E,$09, $08,$D0,$8E,$0E, $FF

; Sound 47h: Shot waver
.sound47
db $01 : dw ..voice0
..voice0 : db $14,$D0,$98,$03, $14,$E0,$97,$03, $14,$D0,$95,$03, $14,$50,$95,$03, $FF

; Sound 48h: Torizo sonic boom
.sound48
db $01 : dw ..voice0
..voice0 : db $00,$D8,$95,$08, $F5,$F0,$8C, $0B,$D0,$A3,$06, $F5,$F0,$8C, $0B,$B0,$A3,$06, $F5,$F0,$8C, $0B,$70,$A3,$06, $FF

; Sound 49h: Shot fish / crab / Maridia refill candy
.sound49
db $01 : dw ..voice0
..voice0 : db $14,$80,$AB,$04, $14,$50,$AB,$04, $14,$30,$AB,$04, $14,$20,$AB,$04, $FF

; Sound 4Ah: Shot mini-Draygon
.sound4A
db $01 : dw ..voice0
..voice0 : db $24,$70,$9C,$03, $24,$50,$9A,$04, $24,$40,$9A,$06, $24,$10,$9A,$06, $FF

; Sound 4Bh: Chozo / torizo footsteps
.sound4B
db $01 : dw ..voice0
..voice0 : db $F6,$0C, $08,$A0,$98,$08, $FF

; Sound 4Ch: Ki-hunter / eye door acid spit
.sound4C
db $01 : dw ..voice0
..voice0 : db $00,$40,$9C,$08, $0F,$80,$93,$13, $FF

; Sound 4Dh: Gunship hover
.sound4D
db $01 : dw ..voice0
..voice0 : db $0B,$20,$89,$03, $0B,$30,$89,$03, $0B,$40,$89,$03, $0B,$50,$89,$03, $0B,$60,$89,$03, $0B,$70,$89,$03, $0B,$80,$89,$03, $0B,$60,$89,$03, $0B,$50,$89,$03, $0B,$40,$89,$03, $0B,$30,$89,$03, $FF

; Sound 4Eh: Ceres Ridley getaway
.sound4E
db $12 : dw sound1InstructionLists_PowerBombVoice0, sound1InstructionLists_PowerBombVoice1

; Sound 4Fh:
.sound4F
db $01 : dw ..voice0
..voice0 : db $0F,$B0,$93,$10, $0F,$40,$93,$03, $0F,$30,$93,$03, $FF

; Sound 50h: Metroid draining Samus / random metroid cry
.sound50
db $12 : dw ..voice0, ..voice1
..voice0 : db $24,$A0,$9A,$0E, $FF
..voice1 : db $24,$00,$8C,$03, $24,$90,$98,$14, $FF

; Sound 51h: Shot Wrecked Ship ghost
.sound51
db $12 : dw ..voice0, ..voice1
..voice0 : db $19,$60,$A4,$13, $19,$50,$A4,$13, $19,$30,$A4,$13, $19,$10,$A4,$13, $FF
..voice1 : db $19,$60,$9F,$16, $19,$50,$9F,$16, $19,$30,$9F,$16, $19,$10,$9F,$16, $FF

; Sound 52h: Shitroid feels remorse
.sound52
db $01 : dw ..voice0
..voice0 : db $22,$D0,$92,$2B, $FF

; Sound 53h: Shot mini-Crocomire
.sound53
db $01 : dw ..voice0
..voice0 : db $0F,$B0,$93,$10, $0F,$40,$93,$03, $0F,$30,$93,$03, $FF

; Sound 54h:
.sound54
db $11 : dw ..voice0
..voice0 : db $14,$B0,$93,$05, $14,$80,$9C,$0A, $14,$40,$9C,$03, $14,$30,$9C,$03, $FF

; Sound 55h: Shot beetom
.sound55
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$80, $0B,$40,$C5,$04, $F5,$F0,$80, $0B,$30,$F6,$03, $F5,$F0,$80, $0B,$20,$F6,$03, $FF

; Sound 56h: Acquired suit
.sound56
db $02 : dw sound1InstructionLists_PowerBombVoice2, sound1InstructionLists_PowerBombVoice3

; Sound 57h: Shot door/gate with dud shot / shot reflec
.sound57
db $01 : dw ..voice0
..voice0 : db $08,$70,$98,$03, $08,$50,$95,$03, $08,$40,$9A,$03, $FF

; Sound 58h: Shot mochtroid
.sound58
db $02 : dw ..voice0, ..voice1
..voice0 : db $24,$A0,$98,$0D, $FF
..voice1 : db $24,$00,$94,$03, $24,$80,$9A,$15, $FF

; Sound 59h: Ridley's roar
.sound59
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$9D,$30, $FF
..voice1 : db $25,$D0,$A1,$30, $FF

; Sound 5Ah: Shot metroid
.sound5A
db $02 : dw ..voice0, ..voice1
..voice0 : db $24,$A0,$98,$15, $FF
..voice1 : db $24,$00,$96,$03, $24,$80,$95,$1D, $FF

; Sound 5Ch: Skree hits the ground
.sound5C
db $01 : dw ..voice0
..voice0 : db $0F,$B0,$8B,$08, $F5,$F0,$BC, $01,$70,$98,$09, $F5,$F0,$BC, $01,$60,$98,$09, $F5,$F0,$BC, $01,$50,$98,$09, $F5,$F0,$BC, $01,$40,$98,$09, $FF

; Sound 5Dh: Sidehopper jumped
.sound5D
db $01 : dw ..voice0
..voice0 : db $01,$B0,$80,$0F, $01,$60,$80,$03, $01,$40,$80,$03, $FF

; Sound 5Eh: Sidehopper landed
.sound5E
db $01 : dw ..voice0
..voice0 : db $00,$A0,$84,$0F, $00,$60,$84,$03, $00,$40,$84,$03, $FF

; Sound 5Fh: Shot Lower Norfair rio / desgeega / Norfair slow fireball / walking lava seahorse / Botwoon
.sound5F
db $01 : dw ..voice0
..voice0 : db $14,$90,$82,$0A, $14,$80,$82,$03, $14,$60,$82,$03, $FF

; Sound 60h:
.sound60
db $01 : dw ..voice0
..voice0 : db $25,$70,$AB,$20, $FF

; Sound 61h: Dragon / magdollite spit / fire geyser
.sound61
db $01 : dw ..voice0
..voice0 : db $F5,$50,$B0, $09,$D0,$8C,$20, $FF

; Sound 62h:
.sound62
db $01 : dw ..voice0
..voice0 : db $F5,$F0,$B0, $09,$D0,$8C,$10, $FF

; Sound 63h: Mother Brain's ketchup beam
.sound63
db $02 : dw ..voice0, ..voice1
..voice0 : db $00,$E0,$95,$05, $01,$E0,$A4,$05, $08,$E0,$9F,$04, $08,$E0,$9C,$03, $08,$E0,$A1,$03, $08,$E0,$93,$04, $08,$E0,$93,$08, $08,$D0,$8B,$13, $08,$D0,$89,$13, $08,$D0,$85,$16, $08,$D0,$82,$18, $FF
..voice1 : db $00,$E0,$95,$05, $18,$E0,$A4,$05, $18,$E0,$9F,$04, $18,$E0,$9C,$03, $18,$E0,$A1,$03, $18,$E0,$93,$04, $18,$E0,$93,$08, $18,$E0,$8C,$05, $18,$E0,$87,$04, $18,$E0,$84,$03, $FF

; Sound 64h: Holtz cry
.sound64
db $01 : dw ..voice0
..voice0 : db $F5,$50,$B0, $09,$D0,$8C,$18, $FF

; Sound 65h: Rio cry
.sound65
db $01 : dw ..voice0
..voice0 : db $14,$A0,$97,$03, $14,$A0,$97,$03, $14,$A0,$97,$03, $14,$30,$97,$03, $14,$20,$97,$03, $FF

; Sound 66h: Shot ki-hunter / walking space pirate
.sound66
db $01 : dw ..voice0
..voice0 : db $14,$80,$98,$0A, $14,$40,$98,$03, $14,$30,$98,$03, $FF

; Sound 67h: Space pirate / Mother Brain laser
; Sound 6Bh:
.sound67
.sound6B
db $01 : dw ..voice0
..voice0 : db $00,$D8,$98,$05, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$C7, $0B,$50,$B0,$03, $F5,$F0,$BC, $0B,$50,$B0,$03, $FF

; Sound 68h: Shot Wrecked Ship robot
.sound68
db $01 : dw ..voice0
..voice0 : db $1B,$A0,$94,$06, $1B,$90,$8C,$20, $FF

; Sound 69h: Shot Shaktool
.sound69
db $01 : dw ..voice0
..voice0 : db $02,$80,$89,$05, $02,$40,$89,$03, $02,$10,$89,$03, $FF

; Sound 6Ch: Kago bug
.sound6C
db $01 : dw ..voice0
..voice0 : db $00,$40,$A8,$08, $FF

; Sound 6Dh: Ceres tiles falling from ceiling
.sound6D
db $01 : dw ..voice0
..voice0 : db $00,$E0,$91,$08, $08,$90,$A1,$03, $08,$90,$9E,$03, $08,$90,$A3,$03, $08,$90,$8E,$03, $08,$90,$8E,$25, $FF

; Sound 6Eh: Shot Mother Brain phase 1
.sound6E
db $12 : dw ..voice0, ..voice1
..voice0 : db $23,$D0,$80,$20, $FF
..voice1 : db $23,$D0,$87,$20, $FF

; Sound 6Fh: Mother Brain's cry - low pitch
.sound6F
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$E0,$80,$C0, $FF
..voice1 : db $24,$E0,$8C,$C0, $FF

; Sound 70h: Maridia snail bounce
.sound70
db $01 : dw ..voice0
..voice0 : db $1A,$60,$AB,$06, $1A,$60,$B0,$09, $FF

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
..voice0 : db $24,$A0,$8C,$30, $FF
..voice1 : db $24,$00,$9D,$03, $24,$80,$87,$45, $FF

; Sound 73h: Phantoon's cry / Draygon's cry
.sound73
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$E0,$A3,$40, $FF
..voice1 : db $25,$00,$A6,$0C, $25,$80,$A3,$40, $FF

; Sound 74h: Crocomire's cry
.sound74
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$90,$92,$53, $FF
..voice1 : db $26,$E0,$A6,$09, $26,$E0,$A4,$0D, $26,$E0,$A2,$0D, $26,$E0,$A0,$0D, $FF

; Sound 75h: Crocomire's skeleton collapses
.sound75
db $12 : dw ..voice0, ..voice1
..voice0 : db $F6,$0C, $0D,$00,$A3,$05, $0D,$A0,$A3,$02, $0D,$C0,$A1,$02, $0D,$C0,$9F,$03, $0D,$C0,$9D,$03, $0D,$B0,$9C,$03, $0D,$A0,$9A,$02, $0D,$90,$A3,$02, $0D,$90,$98,$04, $0D,$A0,$97,$02, $0D,$C0,$95,$02, $0D,$C0,$93,$03, $0D,$C0,$91,$03, $0D,$B0,$90,$03, $0D,$A0,$8E,$02, $0D,$90,$97,$02, $0D,$90,$8C,$04, $FF
..voice1 : db $F6,$0C, $0D,$A0,$97,$02, $0D,$B0,$90,$03, $0D,$C0,$91,$03, $0D,$C0,$91,$03, $0D,$B0,$90,$03, $0D,$90,$97,$02, $0D,$90,$97,$02, $0D,$90,$8C,$04, $0D,$A0,$8B,$02, $0D,$90,$8B,$02, $0D,$C0,$87,$03, $0D,$C0,$85,$03, $0D,$C0,$89,$02, $0D,$B0,$84,$03, $0D,$C0,$89,$02, $0D,$90,$80,$04, $FF

; Sound 77h: Crocomire melting cry
.sound77
db $12 : dw ..voice0, ..voice1
..voice0 : db $25,$D0,$A7,$15, $25,$D0,$A3,$20, $25,$D0,$A2,$63, $25,$00,$A2,$09, $25,$D0,$A2,$60, $25,$00,$A2,$09, $25,$D0,$A2,$60, $25,$00,$A2,$09, $25,$D0,$A3,$20, $25,$D0,$A2,$33, $FF
..voice1 : db $26,$D0,$A6,$0D, $26,$D0,$A6,$0D, $26,$D0,$A5,$0D, $26,$D0,$A4,$0D, $26,$D0,$A7,$0D, $26,$D0,$A2,$0D, $26,$00,$AA,$7B, $26,$00,$AA,$90, $26,$D0,$A7,$0D, $26,$D0,$A6,$0D, $26,$D0,$A5,$0D, $26,$D0,$A4,$0D, $26,$D0,$A3,$0D, $26,$D0,$A2,$0D, $FF

; Sound 78h: Shitroid draining
.sound78
db $02 : dw ..voice0, ..voice1
..voice0 : db $24,$A0,$9C,$20, $FF
..voice1 : db $24,$00,$9D,$05, $24,$80,$95,$40, $FF

; Sound 79h: Phantoon appears 1
.sound79
db $02 : dw ..voice0, ..voice1
..voice0 : db $26,$D0,$95,$38, $FF
..voice1 : db $26,$00,$95,$0A, $26,$D0,$9C,$38, $FF

; Sound 7Ah: Phantoon appears 2
.sound7A
db $02 : dw ..voice0, ..voice1
..voice0 : db $26,$D0,$8E,$40, $FF
..voice1 : db $26,$00,$8E,$0A, $26,$D0,$99,$40, $FF

; Sound 7Bh: Phantoon appears 3
.sound7B
db $02 : dw ..voice0, ..voice1
..voice0 : db $26,$D0,$9E,$3D, $FF
..voice1 : db $26,$00,$9E,$0A, $26,$D0,$9D,$3D, $FF

; Sound 7Ch: Botwoon spit
.sound7C
db $11 : dw ..voice0
..voice0 : db $24,$90,$94,$1A, $24,$30,$94,$10, $FF

; Sound 7Dh: Shitroid feels guilty
.sound7D
db $11 : dw ..voice0
..voice0 : db $22,$D0,$88,$90, $22,$D0,$8E,$37, $FF

; Sound 7Eh: Mother Brain's cry - high pitch / Phantoon's dying cry
.sound7E
db $11 : dw ..voice0
..voice0 : db $25,$D0,$87,$C0, $FF

; Sound 7Fh: Mother Brain charging her rainbow
.sound7F
db $02 : dw ..voice0, ..voice1
..voice0 : db $FE,$00, $24,$D0,$84,$0D, $24,$D0,$85,$0D, $24,$D0,$87,$0D, $24,$D0,$89,$0D, $24,$D0,$8B,$0D, $24,$D0,$8C,$0D, $24,$D0,$8E,$0D, $24,$D0,$90,$0D, $24,$D0,$91,$0D, $24,$D0,$93,$0D, $FB, $FF
..voice1 : db $24,$00,$80,$04,\
              $FE,$00, $24,$D0,$84,$0D, $24,$D0,$85,$0D, $24,$D0,$87,$0D, $24,$D0,$89,$0D, $24,$D0,$8B,$0D, $24,$D0,$8C,$0D, $24,$D0,$8E,$0D, $24,$D0,$90,$0D, $24,$D0,$91,$0D, $24,$D0,$93,$0D, $FB,\
              $FF
}
