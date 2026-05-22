incsrc "ram.asm"

incsrc "apu_upload.asm"

org $8289EF
HandleApuCommandQueue:
{
PHP : SEP #$30
LDA ApuCommandState : ASL : TAX
JSR (.states,x)
PLP : RTL

.states
dw ApuCommandState0_Idle
dw ApuCommandState1_WaitForApu
}

ApuCommandState0_Idle:
{
LDX ApuCommandQueueStart : CPX ApuCommandQueueEnd : BEQ .ret
; Send command to APU
LDA ApuCommandQueue+1,x : STA $2141
LDA ApuCommandQueue+2,x : STA $2142
LDA ApuCommandQueue+3,x : STA $2143
LDA ApuCommandQueue+0,x : STA $2140
DEC : BNE +

LDA ApuCommandQueue+1,x : STA $07F5 ; music track index
BRA .done

+
DEC : BNE .done

LDA ApuCommandQueue+1,x : STA $07F3 : TAX ; music data index
REP #$20
LDA $8FE7E1,x : STA $00 : LDA $8FE7E2,x : STA $01
JSL UploadToAPU_MusicData
SEP #$20

.done
INC ApuCommandState ; ApuCommandState = 1
.ret
RTS
}

ApuCommandState1_WaitForApu:
{
LDA ApuCommandCtr : CMP $2140 : BEQ +
INC : STA ApuCommandCtr
DEC ApuCommandState ; ApuCommandState = 0
LDA ApuCommandQueueStart : CLC : ADC #$04 : CMP.b #4*25 : BCC + : TDC : + : STA ApuCommandQueueStart
+
RTS
}

; replace an instance of handling music queue
org $80A136 : JSL HandleApuCommandQueue

; Check if music is queued
org $808EF4
CheckIfMusicQueued:
{
PHP : SEP #$20
LDA ApuCommandQueueStart : CMP ApuCommandQueueEnd : BNE +
PLP : CLC : RTL
+
PLP : SEC : RTL
}

; Handle music queue
org $808F0C : RTL ; just RTL it out

org $808FC1
QueueMusicTrack:
{
PHX : PHP : REP #$30
LDX $0998 : CPX #$0028 : BCS .ret ; If in demo: return

LDX ApuCommandQueueEnd
ORA #$0000 : BMI .musicData
ORA #$0100 : BRA .merge
.musicData
AND #$02FF
.merge
XBA : STA ApuCommandQueue,x
STZ ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*25 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLP : PLX : RTL
assert pc() <= $808FF7
}

org $808FF7 ; Queue music data or music track, max([Y], 8) frame delay, can overwrite old entries
BRA QueueMusicTrack

org $809051 ; Queue sound, sound library 1
QueueSound1:
{
REP #$30
LDX $05F5 : BNE .ret ; If sounds disabled: return
LDX $0998 : CPX #$0028 : BCS .ret ; If in demo: return
LDX $0592 : BMI .ret ; If [power bomb explosion status] = exploding: return
; ignore max queued sounds for now
LDX ApuCommandQueueEnd
AND #$FF00 : ORA #$0003 : STA ApuCommandQueue+0,x
STZ ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*25 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLP : PLY : PLX : RTL
}

org $8090D3 ; Queue sound, sound library 2
QueueSound2:
{
REP #$30
LDX $05F5 : BNE .ret
LDX $0998 : CPX #$0028 : BCS .ret
LDX $0592 : BMI .ret
LDX ApuCommandQueueEnd
AND #$FF00 : ORA #$0004 : STA ApuCommandQueue+0,x
STZ ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*25 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLP : PLY : PLX : RTL
}

org $809155 ; Queue sound, sound library 3
QueueSound3:
{
REP #$30
LDX $05F5 : BNE .ret
LDX $0998 : CPX #$0028 : BCS .ret
LDX $0592 : BMI .ret
LDX ApuCommandQueueEnd
AND #$FF00 : ORA #$0005 : STA ApuCommandQueue+0,x
STZ ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*25 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLP : PLY : PLX : RTL
}

org $82E2AE ; Door transition function - wait for sounds to finish
JSL CheckIfMusicQueued : BCS +
LDA #$E2DB : STA $099C ; Door transition function = $E2DB (fade out the screen)
+
PLP : RTS
