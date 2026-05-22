optimize address ram

org $7E0619
ApuCommandState: skip 1
ApuCommandCtr: skip 1
ApuCommandQueueStart: skip 2 ; both 8-bit and 16-bit
ApuCommandQueueEnd: skip 2 ; same as above
ApuCommandQueue: skip 4*25 ; 4 bytes in each entry
assert pc() <= $7E0688
