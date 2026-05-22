handleCpuIo0:
{
mov a,!cpuIo0_read : bne +
ret

+
asl a : mov x,a
mov a,!cpuIo1_read
call doCpuIo0Command

; Clear CPUIO ports
mov $F1,#$31

; Tell CPU that it's done
inc !io0CommandCtr
mov !cpuIo0_write,!io0CommandCtr
ret
}

doCpuIo0Command:
jmp (cpuIo0Commands-2+x)

cpuIo0Commands:
{
dw \
    loadNewMusicTrack,\
    loadNewMusicData,\
    cpuIo0Command_sound1,\
    cpuIo0Command_sound2,\
    cpuIo0Command_sound3
}
