; Build with:
;     asar --fix-checksum=off main.asm SM.sfc

; where SM.sfc is your vanilla ROM with an sfc extension (asar requirement).
; The `--fix-checksum=off` is there because asar's checksum generation is incorrect (probably related to the bottom of this file)

warnings disable Wfeature_deprecated ; The workarounds for the things warned about do not work
math pri on ; Use conventional maths priority (otherwise is strict left-to-right evaluation)

!printAramSummary = ""
if defined("printRamMsl") || defined("printRamMap") : undef printAramSummary


; The SPC engine data block is written via the spc700 arch, and sets the base to !p_end_ram
; This is a workaround for spcblock with labels referenced outside the spcblock

lorom
org $CF8000 ; The actual ROM location the engine is going to be written to

!version = 2

incsrc "ram.asm"

arch spc700

dw main_eof-main_metadata, !p_end_ram-$D
base !p_end_ram-$D
{
main_metadata:
{
db !version
dw main_engine,\
   main_sharedTrackers,\
   !instrumentTable,\
   !sampleTable,\
   !sampleData,\
   !p_extra
}

main_engine:
incsrc "engine.asm"

main_utility:
incsrc "utility.asm"

main_music:
incsrc "music.asm"

main_soundLibrary:
incsrc "sound library.asm" ; Contains code that's generic across sound libraries

main_soundLibrary1:
incsrc "sound library 1.asm"

main_soundLibrary2:
incsrc "sound library 2.asm"

main_soundLibrary3:
incsrc "sound library 3.asm"

main_sharedTrackers:
incsrc "shared trackers.asm"

main_eof:
}

; Instrument, sample and EOF blocks
incsrc "samples.asm"

if defined("printAramSummary")
    print "$",hex(main_engine), ": RAM end / engine"
    print "$",hex(main_utility), ": Utility"
    print "$",hex(main_music), ": Music"
    print "$",hex(main_soundLibrary), ": Sound library"
    print "$",hex(main_soundLibrary1), ": Sound library 1"
    print "$",hex(main_soundLibrary2), ": Sound library 2"
    print "$",hex(main_soundLibrary3), ": Sound library 3"
    print "$",hex(main_sharedTrackers), ": Shared trackers"
    print "$",hex(main_eof), ": EOF"
    print "$",hex(!instrumentTable), ": Instrument table"
    print "$",hex(!sampleTable), ": Sample table"
    print "$",hex(!sampleData), ": Shared sample data"
    print "$",hex(sampleData_eof), ": Song-specific sample data / trackers / echo buffer"
    print ""
    
    ; These are the options to pass to repoint.py
    print \
        "REPOINT:",\
        " --version=",dec(!version),\
        " --p_spcEngine=",hex(main_engine),\
        " --p_sharedTrackers=",hex(main_sharedTrackers),\
        " --p_instrumentTable=",hex(!instrumentTable),\
        " --p_sampleTable=",hex(!sampleTable),\
        " --p_sampleData=",hex(!sampleData),\
        " --p_extra=",hex(!p_extra)
endif
