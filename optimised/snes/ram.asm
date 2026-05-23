optimize address ram

org $7E0619
ApuCommandState: skip 1
ApuCommandCtr: skip 1
ApuCommandQueueStart: skip 2 ; both 8-bit and 16-bit
ApuCommandQueueEnd: skip 2 ; same as above
ApuCommandQueue: skip 4*16 ; 4 bytes in each entry

MusicCommandTimer: skip 2
MusicCommandQueueStart: skip 2
MusicCommandQueueEnd: skip 2
MusicCommandQueue: skip 4*8 ; 3 bytes in each entry, delay is two last entries
assert pc() <= $7E0688
