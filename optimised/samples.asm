spcblock !instrumentTable nspc
{
db $00,$FF,$E0,$B8,$04,$70
db $01,$FF,$E0,$B8,$03,$50
db $02,$FF,$E0,$B8,$06,$F0
db $03,$FF,$E0,$B8,$07,$A0
db $04,$FF,$E0,$B8,$07,$A0
db $05,$FF,$E0,$B8,$00,$40
db $06,$FF,$E0,$B8,$01,$10
db $07,$FF,$E0,$B8,$00,$30
db $08,$FF,$E0,$B8,$02,$90
db $09,$FF,$E0,$B8,$01,$90
db $0A,$FF,$F4,$B8,$04,$90 ; Unused in this optimised engine; in vanilla, used only by sounds 32h and 34h in library 1 (silence)
db $0B,$FF,$E0,$B8,$04,$90
db $0C,$FF,$E0,$B8,$06,$F0
db $0D,$FF,$E0,$B8,$05,$70
db $0E,$FF,$E0,$B8,$04,$D0
db $0F,$FF,$E0,$B8,$04,$30
db $10,$FF,$E0,$B8,$01,$00
db $11,$FF,$F2,$B8,$03,$90 ; Unused in this optimised engine; in vanilla, used only by sound 1 in library 3 (silence)
db $12,$FF,$E4,$B8,$03,$90
db $13,$FF,$E0,$B8,$04,$A0
db $14,$FF,$E0,$B8,$03,$B0
db $15,$FF,$E0,$B8,$00,$40

if defined("instrument16")
db $16,$FF,$E0,$B8,$04,$C0 ; Unused
endif
}
endspcblock

spcblock !sampleTable nspc
{
dw Sample00,Sample00+1476
dw Sample01,Sample01+1476
dw Sample02,Sample02+36
dw Sample03,Sample03+342
dw Sample04,Sample04+1278
dw Sample05,Sample05+36
dw Sample06,Sample06+27
dw Sample07,Sample07+27
dw Sample08,Sample08+1530
dw Sample09,Sample09+27
dw Sample0A_0B,Sample0A_0B+864
dw Sample0A_0B,Sample0A_0B+864
dw Sample0C,Sample0C+27
dw Sample0D,Sample0D+180
dw Sample0E,Sample0E+396
dw Sample0F,Sample0F+981
dw Sample10,Sample10+36
dw Sample11_12,Sample11_12+27
dw Sample11_12,Sample11_12+27
dw Sample13,Sample13+774
dw Sample14,Sample14+675
dw Sample15,Sample15+36

if defined("instrument16")
dw Sample16,Sample16+774
endif
}
endspcblock

; Need to do this so the labels are referenced outside spcblock
dw sampleData_eof-!sampleData, !sampleData
base !sampleData
{
Sample00: incbin "samples/Sample00.brr"
Sample01: incbin "samples/Sample01.brr"
Sample02: incbin "samples/Sample02.brr"
Sample03: incbin "samples/Sample03.brr"
Sample04: incbin "samples/Sample04.brr"
Sample05: incbin "samples/Sample05.brr"
Sample06: incbin "samples/Sample06.brr"
Sample07: incbin "samples/Sample07.brr"
Sample08: incbin "samples/Sample08.brr"
Sample09: incbin "samples/Sample09.brr"
Sample0A_0B: incbin "samples/Sample0A_0B.brr"
Sample0C: incbin "samples/Sample0C.brr"
Sample0D: incbin "samples/Sample0D.brr"
Sample0E: incbin "samples/Sample0E.brr"
Sample0F: incbin "samples/Sample0F.brr"
Sample10: incbin "samples/Sample10.brr"
Sample11_12: incbin "samples/Sample11_12.brr"
Sample13: incbin "samples/Sample13.brr"
Sample14: incbin "samples/Sample14.brr"
Sample15: incbin "samples/Sample15.brr"

if defined("instrument16")
Sample16: incbin "samples/Sample16.brr"
endif

sampleData_eof:
}

; EOF, jump to main_engine
dw $0000, main_engine
