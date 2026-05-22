; Fixes the APU upload routine so that data block entries can cross bank boundaries. See https://patrickjohnston.org/bank/80#f8059 for more details.
lorom

org $80802F
UploadToAPU_IPL:
PHP
PHB : PHK : PLB ; DB = $80 (do not remove)
SEP #$20 : LDA #$FF : STA $2140 ; APU IO 0 = FFh (request APU upload)
UploadToAPU_Common:
REP #$30 : LDY $00 ; Y = [$00]
STZ $00 ; $00 = 0
LDA #$BBAA : - : CMP $2140 : BNE - ; Wait until [APU IO 0..1] = AAh BBh
SEP #$20 : LDA #$CC ; Kick = CCh
BRA ProcessDataBlock ; Go to ProcessDataBlock

UploadDataBlock:
JSR GetDataAndIncY : XBA ; Data = [[Y++]]
; Index = 0 (set by the TDC)
BRA UploadData ; Go to UploadData

NextData:
XBA : JSR GetDataAndIncY : XBA ; Data = [[Y++]]
- : CMP $2140 : BNE - ; Wait until APU IO 0 echoes
INC ; Index += 1

UploadData:
REP #$20 : STA $2140 : SEP #$20 ; APU IO 0..1 = [index] [data]
DEX ; Decrement X (block size)
BNE NextData ; If [X] != 0: go to NextData
- : CMP $2140 : BNE - ; Wait until APU IO 0 echoes
- : ADC #$03 ; Kick = [index] + 4
BEQ - ; Ensure kick != 0

ProcessDataBlock:
PHA
JSR GetDataAndIncY : XBA : JSR GetDataAndIncY : XBA : TAX ; X = [[Y]] (block size), Y += 2
JSR GetDataAndIncY : STA $2142 : JSR GetDataAndIncY : STA $2143 ; APU IO 2..3 = [[Y]] (destination address), Y += 2
CPX #$0001 : TDC : ROL : STA $2141 ; If block size = 0: APU IO 1 = 0 (EOF), else APU IO 1 = 1 (arbitrary non-zero value)
ADC #$7F ; Set overflow if block size != 0, else clear overflow
PLA : STA $2140 ; APU IO 0 = kick
BVC + ; If block size = 0: return
- : CMP $2140 : BNE - ; Wait until APU IO 0 echoes
BRA UploadDataBlock ; Go to UploadDataBlock

+
PLB : PLP : RTS

GetDataAndIncY:
LDA [$00],y
IncY:
INY ; Y += 1
BEQ + ; If [Y] != 0: return
RTS
+ : INC $02 ; Increment [$02]
LDY #$8000 ; Y = $8000
RTS

; Same as above, but skips requesting APU upload for IPL
UploadToAPU_MusicData:
JSR .jump
RTL
.jump
PHP
PHB : PHK : PLB
JMP UploadToAPU_Common
