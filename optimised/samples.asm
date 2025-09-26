spcblock !instrumentTable nspc
{
db $00,$FF,$E0,$B8,$04,$70
db $01,$FF,$E0,$B8,$03,$50
db $02,$FF,$E0,$B8,$06,$F0
db $03,$FF,$E0,$00,$05,$08
db $04,$FF,$E0,$B8,$05,$E0
db $05,$FF,$E0,$B8,$00,$80
db $06,$FF,$E0,$B8,$01,$10
db $07,$FF,$E0,$B8,$00,$30
db $08,$FF,$E0,$B8,$02,$64
db $09,$FF,$E0,$B8,$01,$90
db $0A,$FF,$F4,$B8,$05,$E0
db $0B,$FF,$E0,$B8,$05,$E0
db $0C,$FF,$E0,$B8,$06,$F0
db $0D,$FF,$E0,$B8,$05,$70
db $0E,$FF,$E0,$B8,$04,$D0
db $0F,$FF,$E0,$B8,$04,$30
db $10,$FF,$E0,$B8,$01,$00
db $11,$FF,$E0,$B8,$00,$60
db $12,$FF,$E4,$B8,$03,$90
db $13,$FF,$E0,$B8,$05,$08
db $14,$FF,$E0,$B8,$05,$08
db $15,$FF,$E0,$B8,$00,$40

if defined("instrument16")
db $16,$FF,$E0,$B8,$04,$C0 ; Unused
endif
}
endspcblock

spcblock 6*$30+!instrumentTable nspc
{
  db !sampleSamusFootstep,$FF,$E0,$00,$02,$84
  db !sampleSamusLand,$FF,$E0,$00,$02,$84
  db !sampleHeatDamage,$FF,$E0,$00,$02,$84
  db !sampleLavaDamage,$FF,$E0,$00,$00,$F2
  db !sampleMotoCry,$FF,$E0,$00,$02,$84
}
endspcblock

spcblock !sampleTable nspc
{
dw Sample00,0
dw Sample01,0
dw Sample02,Sample02+36
dw Sample03,0
dw Sample04,0
dw Sample05,Sample05+36
dw Sample06,Sample06+27
dw Sample07,Sample07+27
dw Sample08,0
dw Sample09,Sample09+27
dw Sample0A,0
dw Sample0B,Sample0B+9
dw Sample0C,Sample0C+27
dw Sample0D,0
dw Sample0E,0
dw Sample0F,0
dw Sample10,Sample10+36
dw Sample11,Sample11
dw Sample09,Sample09+27
dw Sample13,0
dw Sample14,0
dw Sample15,Sample15+36
}
endspcblock

spcblock 4*$30+!sampleTable nspc
{
  dw SampleSamusFootstep,0
  dw SampleSamusLand,0
  dw SampleHeatDamage,0
  dw SampleLavaDamage,SampleLavaDamage+16*9/16
  dw SampleMotoCry,SampleMotoCry+16*9/16
}
endspcblock

; Need to do this so the labels are referenced outside spcblock
dw Sample04-!sampleData, !sampleData
base !sampleData
{
Sample00: incbin "samples/Sample00.brr"
Sample01: incbin "samples/Sample01.brr"
Sample02: incbin "samples/Sample02.brr"
Sample03: incbin "samples/missile_toggle_10512_noloop.brr"
Sample04:
}

dw Sample0B-(Sample04+$0D41), Sample04+$0D41
base Sample04+$0D41
{
Sample05: incbin "samples/Sample05.brr"
Sample06: incbin "samples/Sample06.brr"
Sample07: incbin "samples/Sample07.brr"
Sample08: incbin "samples/small_explosion_5000_noloop.brr"
Sample09: incbin "samples/Sample09.brr"
Sample0A: incbin "samples/Sample0A.brr"
Sample0B:
}

dw sampleData_eof-(Sample0B+$071A), Sample0B+$071A
base Sample0B+$071A
{
Sample0C: incbin "samples/Sample0C.brr"
Sample0D: incbin "samples/Sample0D.brr"
Sample0E: incbin "samples/Sample0E.brr"
Sample0F: incbin "samples/Sample0F.brr"
Sample10: incbin "samples/Sample10.brr"
Sample11: incbin "samples/Sample11.brr"
Sample13: incbin "samples/samus_hurt_10512_noloop.brr"
Sample14: incbin "samples/hornoad_cry_10512_noloop.brr"
Sample15: incbin "samples/Sample15.brr"

SampleSamusFootstep: incbin "samples/samus_footstep_10512_noloop_fixed.brr"
SampleSamusLand: incbin "samples/samus_land_10512_noloop.brr"
SampleHeatDamage: incbin "samples/heat_damage_10512_noloop_fixed.brr"
SampleLavaDamage: incbin "samples/lava_damage_3951.924_16.brr"
SampleMotoCry: incbin "samples/moto_cry_10512_16.brr"

sampleData_eof:
}

; EOF, jump to main_engine
dw $0000, main_engine
