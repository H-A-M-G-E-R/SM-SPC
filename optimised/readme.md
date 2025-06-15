SPC engine modification. Frees up just under 8.5kb of ARAM, which can be used for any of: sample data, tracker data, or echo buffer (each echo frames are 2kb each).
ARAM is rearranged so that sample data, tracker data, and echo buffer all use up the same pool of memory; so one can e.g. cut down on sample data to get more echo buffer space.

Run `asar --fix-checksum=off main.asm SM.smc` to patch a ROM to have the engine mod, the main engine NSPC is expected to be at its vanilla location $CF:8104.

As the modified engine uses a different ARAM layout, any NSPCs used with it need to be written accordingly.
In vanilla, the SPC data blocks are:
```
_ARAM_|___Description____
$1500 | SPC engine
$5800 | Note length table
$5820 | Trackers
$6C00 | Instrument table
$6D00 | Sample table
$6E00 | Sample data
```

In the engine mod (these ARAM addresses are just examples, read SPC engine metadata for real addresses):
```
_ARAM_|___Description____
$E0   | Extra (*)
$2E8  | SPC engine
$26E0 | Instrument table
$2800 | Sample table
$2900 | Sample data / trackers
```

(*) Extra is a 3 byte block:
* A two-byte ARAM address of the trackers within the "sample data / trackers" region
* A one byte flag specifying late key-off, corresponding to mITroid's "disable key-off between patterns" and "disable key-off between notes" patches (bits 0 and 1 respectively)

For the purposes of tooling, the first 13 bytes of the SPC engine are metadata (SPC engine block can be identified by looking for the SPC data block whose ARAM destination is also the terminator data block's destination - 0xD).
* 0x0: One byte version number
* Two byte pointers to:
    * 0x1: SPC engine (entry point, metadata address + 0xF)
    * 0x3: Shared trackers (part of the SPC engine)
    * 0x5: Instrument table
    * 0x7: Sample table
    * 0x9: Sample data / trackers
    * 0xB: Extra

`repoint.py` is included to repoint vanilla NSPCs or mITroid generated NSPCs.

After patching a vanilla ROM with the ASM via asar, run:
* `python repoint.py rom SM.smc SM_repointed.smc` (arbitrary filepaths)
    * Where `SM.smc` has the music you want to repoint and `SM_repointed.smc` is the patched ROM you want to insert the repointed music in

To repoint an NSPC file, run either:
* `python repoint.py nspc music.nspc music_repointed.nspc --version=2 --p_spcEngine=2E8 --p_sharedTrackers=21F3 --p_instrumentTable=26E0 --p_sampleTable=2800 --p_sampleData=2900 --p_extra=E0`
    * Where all the pointers are reported by asar when assembling the engine mod
* `python repoint.py nspc music.nspc music_repointed.nspc --rom=SM.smc`
    * Where metadata is extracted from `--rom` argument (a patched ROM)

Version history:
* 2\. Note length table can now be changed by a new track command ($FB $00 pppp), and it resets to default when initialising a music track
* 1\. Initial release (since introducing versioning)
