incsrc "ram.asm"

incsrc "apu_upload.asm"

incsrc "panning.asm"

;;; Handle APU command queue ;;;

org $8289EF
HandleApuCommandQueue:
{
PHP : SEP #$30
LDA ApuCommandState : ASL : TAX
JSR (.musicStates,x)
LDA ApuCommandState : ASL : TAX
JSR (.soundStates,x)
PLP : RTL

.musicStates
dw MusicCommandState0_Idle
dw GoToMusicCommandState1_WaitForApu

.soundStates
dw ApuCommandState0_Idle
dw GoToApuCommandState1_WaitForApu
}

GoToApuCommandState1_WaitForApu:
{
JSR ApuCommandState1_WaitForApu
}
; fallthrough
ApuCommandState0_Idle:
{
LDX ApuCommandQueueStart : CPX ApuCommandQueueEnd : BEQ +
JSL Thing1
+
RTS
}

; Same as below, except that it handles music timer
MusicCommandState1_WaitForApu:
{
LDX MusicCommandQueueStart : CPX MusicCommandQueueEnd : BEQ +
REP #$20 : LDA MusicCommandTimer : CMP MusicCommandQueue+2,x : BCS +
INC : STA MusicCommandTimer
+
SEP #$20
}

; fallthrough
ApuCommandState1_WaitForApu:
{
LDA ApuCommandCtr : CMP $2140 : BEQ +
INC : STA ApuCommandCtr
DEC ApuCommandState ; ApuCommandState = 0
+
RTS
}

GoToMusicCommandState1_WaitForApu:
{
JSR MusicCommandState1_WaitForApu
}
; fallthrough
MusicCommandState0_Idle:
{
LDX MusicCommandQueueStart : CPX MusicCommandQueueEnd : BEQ .ret
; timer
REP #$20 : LDA MusicCommandTimer : CMP MusicCommandQueue+2,x : BCS +
INC : STA MusicCommandTimer
SEP #$20
RTS

+
SEP #$20
; Send command to APU
LDA MusicCommandQueue+1,x : STA $2141
LDA MusicCommandQueue+0,x : STA $2140

; music track
DEC : BNE +
LDA MusicCommandQueue+1,x : STA $07F5 ; music track index
BRA .done

+
; music data
DEC : BNE .done
LDA MusicCommandQueue+1,x : STA $07F3 : TAX ; music data index
REP #$20
LDA $8FE7E1,x : STA $00 : LDA $8FE7E2,x : STA $01
JSL UploadToAPU_MusicData
SEP #$20

.done
INC ApuCommandState
LDA MusicCommandQueueStart : CLC : ADC #$04 : CMP.b #4*8 : BCC + : TDC : + : STA MusicCommandQueueStart

.ret
RTS
}

assert pc() <= $828AB0

;;; Bank $80 stuff ;;;

; replace an instance of handling music queue
org $80A136 : JSL HandleApuCommandQueue

; Check if music is queued
org $808EF4
CheckIfMusicQueued:
{
PHP : SEP #$20
LDA MusicCommandQueueStart : CMP MusicCommandQueueEnd : BNE +
PLP : CLC : RTL
+
PLP : SEC : RTL
}

; Handle music queue
org $808F0C : RTL ; just RTL it out

CheckIfSoundsQueued:
{
PHP : SEP #$20
LDA ApuCommandQueueStart : CMP ApuCommandQueueEnd : BNE +
PLP : CLC : RTL
+
PLP : SEC : RTL
}

Thing1:
{
; Send command to APU
LDA ApuCommandQueue+1,x : STA $2141
LDA ApuCommandQueue+2,x : STA $2142
LDA ApuCommandQueue+3,x : STA $2143
LDA ApuCommandQueue+0,x : STA $2140
INC ApuCommandState
LDA ApuCommandQueueStart : CLC : ADC #$04 : CMP.b #4*16 : BCC + : TDC : + : STA ApuCommandQueueStart
RTL
}

Thing2:
{
LDA MusicCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*8 : BCC + : TDC : + : STA MusicCommandQueueEnd
RTS
}

assert pc() <= $808FA3

org $808FC1 ; Queue music data or music track, 8 frame delay, cannot set last queue entry
QueueMusicTrack_8FrameDelay:
{
PHX : PHY : PHP : REP #$30
LDY #$0008
}

; fallthrough
QueueMusicTrack_Common:
{
LDX $0998 : CPX #$0028 : BCS .ret ; If in demo: return

LDX MusicCommandQueueEnd
ORA #$0000 : BMI .musicData
ORA #$0100 : BRA .merge
.musicData
AND #$02FF
.merge
XBA : STA MusicCommandQueue,x
TYA : STA MusicCommandQueue+2,x
JSR Thing2

.ret
PLP : PLY : PLX : RTL
assert pc() <= $808FF7
}

org $808FF7 ; Queue music data or music track, max([Y], 8) frame delay, can overwrite old entries
QueueMusicTrack_YDelay:
{
PHX : PHY : PHP : REP #$30
BRA QueueMusicTrack_Common
}

;;; Queue sound ;;;

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
LDA #$FF00 : STA ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*16 : BCC + : TDC : + : STA ApuCommandQueueEnd

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
LDA #$FF00 : STA ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*16 : BCC + : TDC : + : STA ApuCommandQueueEnd

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
LDA #$FF00 : STA ApuCommandQueue+2,x
LDA ApuCommandQueueEnd : CLC : ADC #$0004 : CMP.w #4*16 : BCC + : TDC : + : STA ApuCommandQueueEnd

.ret
PLP : PLY : PLX : RTL
}

;;; Misc ;;;

org $82E2AE ; Door transition function - wait for sounds to finish
JSL CheckIfSoundsQueued : BCS +
LDA #$E2DB : STA $099C ; Door transition function = $E2DB (fade out the screen)
+
PLP : RTS

org $80A091 : BRA $02 ; disable clearing sounds when starting game
