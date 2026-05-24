
org $89AEFD ; some freespace
;; Parameters:
;;     A low: Sound index
;;     A high: Library index. Range 1..3
;;     Y low: Panning modifier. 0 = center, Ah = left, -Ah = right
;;     Y high: Volume modifier. FFh = max volume
PlaySoundWithParameters:
{
PHX
LDX $05F5 : BNE .ret ; If sounds disabled: return
LDX $0998 : CPX #$0028 : BCS .ret ; If in demo: return
LDX $0592 : BMI .ret ; If [power bomb explosion status] = exploding: return

LDX ApuCommandQueueEnd
XBA : INC : INC : STA ApuCommandQueue+0,x
TYA : STA ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*16 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLX : RTL
}

; A is room X position
; Returns Y = panning and volume multipliers
CalculateSoundPanningFromXPos:
{
; (screen pos) = (room pos) - [layer 1 X pos]
SEC : SBC $0911
; panning = -((screen pos) - 80h) * (6h / 80h))
; stored in high byte after the multiplication
SEC : SBC #$0080
BMI .negative

; cap at D6h because 80h * Ah / 6 = D5.555...h
CMP #$00D6 : BCC + : LDA #$00D6 : +
AND #$00FF : ORA #$0C00 : STA $004202 ; 80h * Ch = 600h, D6h * Ch = A08h
NOP : NOP : LDA $004216
EOR #$FFFF : CLC : ADC #$0100
BRA .ret

.negative
EOR #$FFFF : INC
CMP #$00D6 : BCC + : LDA #$00D6 : +
AND #$00FF : ORA #$0C00 : STA $004202
NOP : NOP : LDA $004216

.ret
XBA : ORA #$FF00 : TAY ; max volume
RTS
}

;; Parameters:
;;     A low: Sound index
;;     A high: Library index. Range 1..3
;;     $12: X position
PlaySoundAt12XPos:
{
PHY
PHA
LDA $12 : JSR CalculateSoundPanningFromXPos
PLA
JSL PlaySoundWithParameters
PLY : RTL
}

PlaySoundAtSamusPos:
{
PHY
PHA
LDA $0AF6 : JSR CalculateSoundPanningFromXPos
PLA
JSL PlaySoundWithParameters
PLY : RTL
}

;; Parameters:
;;     A: Sound index
PlaySound2AtEnemyPos:
{
ORA #$0200
}

; fallthrough

PlaySoundAtEnemyPos:
{
PHY
PHA : PHX
LDX $0E54
LDA $0F7A,x : JSR CalculateSoundPanningFromXPos
PLX : PLA
JSL PlaySoundWithParameters
PLY : RTL
}

; X is projectile index
PlaySoundAtXProjPos:
{
PHY
PHA
LDA $0B64,x : JSR CalculateSoundPanningFromXPos
PLA
JSL PlaySoundWithParameters
PLY : RTL
}

; Same as above, but with Y as projectile index
PlaySoundAtYProjPos:
{
PHY
PHA
LDA $0B64,y : JSR CalculateSoundPanningFromXPos
PLA
JSL PlaySoundWithParameters
PLY : RTL
}

PlaySoundAt14ProjPos:
{
PHY
PHA : PHX
LDX $14
LDA $0B64,x : JSR CalculateSoundPanningFromXPos
PLX : PLA
JSL PlaySoundWithParameters
PLY : RTL
}

;;; Adding panning to existing sounds
; Used https://patrickjohnston.org/ASM/Lists/Super%20Metroid/Sound%20effect%20calls%20by%20index.asm as a reference
; Foe now, doesn't support looped sounds

org $A0A843 : JSL PlaySound2AtEnemyPos ; enemy hurt cry

; Projectile sounds

; beam sounds
; Uncharged
org $90C28F
dw $010B, ; 0: Power
   $010D, ; 1: Wave
   $010C, ; 2: Ice
   $010E, ; 3: Ice + wave
   $010F, ; 4: Spazer
   $0112, ; 5: Spazer + wave
   $0110, ; 6: Spazer + ice
   $0111, ; 7: Spazer + ice + wave
   $0113, ; 8: Plasma
   $0116, ; 9: Plasma + wave
   $0114, ; Ah: Plasma + ice
   $0115  ; Bh: Plasma + ice + wave

; Charged
dw $0117, ; 0: Power
   $0119, ; 1: Wave
   $0118, ; 2: Ice
   $011A, ; 3: Ice + wave
   $011B, ; 4: Spazer
   $011E, ; 5: Spazer + wave
   $011C, ; 6: Spazer + ice
   $011D, ; 7: Spazer + ice + wave
   $011F, ; 8: Plasma
   $0122, ; 9: Plasma + wave
   $0120, ; Ah: Plasma + ice
   $0121  ; Bh: Plasma + ice + wave

; Non-beam projectiles
dw $0000,
   $0103, ; Missiles
   $0104  ; Super missiles

org $90B8E1 : JSL PlaySoundAtXProjPos ; uncharged beam
org $90B9DB : JSL PlaySoundAtXProjPos ; charged beam
org $90BEEF : JSL PlaySoundAt14ProjPos ; missile

org $9380EF : LDA #$020C : JSL PlaySoundAtXProjPos ; beam hit wall
org $9380FD : LDA #$0207 : JSL PlaySoundAtXProjPos ; missile hit wall

; Samus sounds
org $91F09A : LDA #$0304 : JSL PlaySoundAtSamusPos ; landed hard
org $91F08C : LDA #$0305 : JSL PlaySoundAtSamusPos ; landed
org $91F2E8 : LDA #$0305 : JSL PlaySoundAtSamusPos ; walljump
org $90A41B : LDA #$0306 : JSL PlaySoundAtSamusPos ; footstep
org $90D0A3 : LDA #$030F : JSL PlaySoundAtSamusPos ; shinespark
org $91FAF3 : LDA #$030F : JSL PlaySoundAtSamusPos ; shinespark
org $90D33D : LDA #$0310 : JSL PlaySoundAtSamusPos ; shinespark end
