; Utility constants for this file
{
!n_tracks = 8
}

!p_ram = 0
!canInterleaveBytePairArray = 0
!lastBytePairN = 0

!c2 = "db $80"
!cs2 = "db $81"
!d2 = "db $82"
!ds2 = "db $83"
!e2 = "db $84"
!f2 = "db $85"
!fs2 = "db $86"
!g2 = "db $87"
!gs2 = "db $88"
!a2 = "db $89"
!as2 = "db $8A"
!b2 = "db $8B"
!c3 = "db $8C"
!cs3 = "db $8D"
!d3 = "db $8E"
!ds3 = "db $8F"
!e3 = "db $90"
!f3 = "db $91"
!fs3 = "db $92"
!g3 = "db $93"
!gs3 = "db $94"
!a3 = "db $95"
!as3 = "db $96"
!b3 = "db $97"
!c4 = "db $98"
!cs4 = "db $99"
!d4 = "db $9A"
!ds4 = "db $9B"
!e4 = "db $9C"
!f4 = "db $9D"
!fs4 = "db $9E"
!g4 = "db $9F"
!gs4 = "db $A0"
!a4 = "db $A1"
!as4 = "db $A2"
!b4 = "db $A3"
!c5 = "db $A4"
!cs5 = "db $A5"
!d5 = "db $A6"
!ds5 = "db $A7"
!e5 = "db $A8"
!f5 = "db $A9"
!fs5 = "db $AA"
!g5 = "db $AB"
!gs5 = "db $AC"
!a5 = "db $AD"
!as5 = "db $AE"
!b5 = "db $AF"
!c6 = "db $B0"
!cs6 = "db $B1"
!d6 = "db $B2"
!ds6 = "db $B3"
!e6 = "db $B4"
!f6 = "db $B5"
!fs6 = "db $B6"
!g6 = "db $B7"
!gs6 = "db $B8"
!a6 = "db $B9"
!as6 = "db $BA"
!b6 = "db $BB"
!c7 = "db $BC"
!cs7 = "db $BD"
!d7 = "db $BE"
!ds7 = "db $BF"
!e7 = "db $C0"
!f7 = "db $C1"
!fs7 = "db $C2"
!g7 = "db $C3"
!gs7 = "db $C4"
!a7 = "db $C5"
!as7 = "db $C6"
!b7 = "db $C7"

macro declare(name, n)
{
    if defined("printRamMap") : print "$", hex(!p_ram), " = \!<name>"
    if defined("printRamMsl") : print "SPCRAM:", hex(!p_ram), ":<name>"
    !<name> #= !p_ram
    !p_ram #= !p_ram+<n>
}
endmacro

macro declare_byte(name)
{
    %declare(<name>, 1)
    !canInterleaveBytePairArray = 0
}
endmacro

macro declare_word(name)
{
    %declare(<name>, 2)
    !canInterleaveBytePairArray = 0
}
endmacro

macro declare_byteArray(name, n)
{
    %declare(<name>, <n>)
    !canInterleaveBytePairArray = 0
}
endmacro

macro declare_wordArray(name, n)
{
    %declare(<name>, <n>*2)
    !canInterleaveBytePairArray = 0
}
endmacro

macro declare_bytePairArray(name, n)
{
    if !canInterleaveBytePairArray != 0 && <n> == !lastBytePairN
        !p_ram #= !p_ram-<n>*2+2
        !canInterleaveBytePairArray = 0
    else
        !canInterleaveBytePairArray = 1
        !lastBytePairN = <n>
    endif

    %declare(<name>, <n>*2-1)
}
endmacro

macro generate(prefix, suffix, n, step, size)
{
    !i = 0
    while !i < <n>
        if defined("printRamMap") : print "$", hex(!p_ram+!i*<step>), " = \!<prefix>!{i}<suffix>"
        if defined("printRamMsl") : print "SPCRAM:", hex(!p_ram+!i*<step>), ":<prefix>!{i}<suffix>"
        !{<prefix>!{i}<suffix>} #= !p_ram+!i*<step>
        !i #= !i+1
    endwhile
    !p_ram #= !p_ram+<size>
}
endmacro

macro generate_bytes(prefix, suffix, n)
{
    %generate(<prefix>, <suffix>, <n>, 1, <n>)
}
endmacro

macro generate_words(prefix, suffix, n)
{
    %generate(<prefix>, <suffix>, <n>, 2, <n>*2)
}
endmacro

macro generate_bytePairArray(prefix, suffix, n)
{
    if !canInterleaveBytePairArray != 0 && <n> == !lastBytePairN
        !p_ram #= !p_ram-<n>*2+2
        !canInterleaveBytePairArray = 0
    else
        !canInterleaveBytePairArray = 1
        !lastBytePairN = <n>
    endif

    %generate(<prefix>, <suffix>, <n>, 2, <n>*2-1)
}
endmacro

macro generateIndirect(prefix, suffix, p_base, n, step)
{
    !i = 0
    while !i < <n>
        !{<prefix>!{i}<suffix>} #= <p_base>+!i*<step>
        !i #= !i+1
    endwhile
}
endmacro

macro generateIndirect_bytes(prefix, suffix, p_base, n)
{
    %generateIndirect(<prefix>, <suffix>, <p_base>, <n>, 1)
}
endmacro

macro generateIndirect_words(prefix, suffix, p_base, n)
{
    %generateIndirect(<prefix>, <suffix>, <p_base>, <n>, 2)
}
endmacro

; $00..03 are reserved for echo when echo delay = 0
!p_ram = $04

; CPU IO cache registers
{
%generate_bytes(cpuIo, _read, 4)
%generate_bytes(cpuIo, _write, 4)
%generate_bytes(cpuIo, _read_prev, 4)
}

%declare_byte(musicTrackStatus)
%declare_word(zero)

; Temporaries
{
!note #= !p_ram
!panningBias #= !p_ram
!sound_instructionListPointerSet #= !p_ram
%declare_word(noteOrPanningBias)

!signBit #= !p_ram
%declare_byte(dspVoiceVolumeIndex)

%declare_byte(noteModifiedFlag)
%declare_word(misc0)
%declare_word(misc1)
}

%declare_word(randomNumber)
%declare_byte(enableSoundEffectVoices)

; Sounds
{
%declare_wordArray(sound_p_instructionLists, !n_tracks)
}

%declare_wordArray(trackPointers, !n_tracks)
%declare_word(p_tracker)
%declare_byte(trackerTimer)
%declare_byte(soundEffectsClock)
%declare_byte(trackIndex)

; DSP cache
{
%declare_byte(keyOnFlags)
%declare_byte(keyOffFlags)
%declare_byte(musicVoiceBitset)
%declare_byte(flg)
%declare_byte(noiseEnableFlags)
%declare_byte(echoEnableFlags)
%declare_byte(pitchModulationFlags)
}

; Echo
{
%declare_byte(echoTimer)
%declare_byte(echoDelay)
%declare_byte(echoFeedbackVolume)
}

; Music
{
%declare_byte(musicTranspose)
%declare_word(musicTrackClock)
%declare_word(musicTempo)
%declare_byte(dynamicMusicTempoTimer)
%declare_byte(targetMusicTempo)
%declare_word(musicTempoDelta)
%declare_word(musicVolume)
%declare_byte(dynamicMusicVolumeTimer)
%declare_byte(targetMusicVolume)
%declare_word(musicVolumeDelta)
%declare_byte(musicVoiceVolumeUpdateBitset)
%declare_byte(percussionInstrumentsBaseIndex)
}

; Echo
{
%declare_word(echoVolumeLeft)
%declare_word(echoVolumeRight)
%declare_word(echoVolumeLeftDelta)
%declare_word(echoVolumeRightDelta)
%declare_byte(dynamicEchoVolumeTimer)
%declare_byte(targetEchoVolumeLeft)
%declare_byte(targetEchoVolumeRight)
}

; Track
{
%declare_bytePairArray(trackNoteTimers,                 !n_tracks)
%declare_bytePairArray(trackNoteRingTimers,             !n_tracks)
%declare_bytePairArray(trackRepeatedSubsectionCounters, !n_tracks)
%declare_bytePairArray(trackDynamicVolumeTimers,        !n_tracks)
%declare_bytePairArray(trackDynamicPanningTimers,       !n_tracks)
%declare_bytePairArray(trackPitchSlideTimers,           !n_tracks)
%declare_bytePairArray(trackPitchSlideDelayTimers,      !n_tracks)
%declare_bytePairArray(trackVibratoDelayTimers,         !n_tracks)
%declare_bytePairArray(trackVibratoExtents,             !n_tracks)
%declare_bytePairArray(trackTremoloDelayTimers,         !n_tracks)
%declare_bytePairArray(trackTremoloExtents,             !n_tracks)
%declare_bytePairArray(trackNotes,                      !n_tracks)
}

; Sounds
{
%declare_byte(sound_voiceBitset)
%declare_byte(i_soundLibrary)
}

%declare_byte(fakeEchoEnableFlags)
%declare_word(p_noteRingLengthTable)
%declare_byte(sound_activeVoices)
%declare_word(p_echoFirFilters)

; Sounds
{
%declare_byteArray(sounds, 3)
%declare_byteArray(sound_enabledVoices, 3)
%declare_byteArray(sound_priorities, 3)

!sound1 = !sounds
!sound2 = !sounds+1
!sound3 = !sounds+2
!sound1_enabledVoices = !sound_enabledVoices
!sound2_enabledVoices = !sound_enabledVoices+1
!sound3_enabledVoices = !sound_enabledVoices+2
!sound1Priority = !sound_priorities
!sound2Priority = !sound_priorities+1
!sound3Priority = !sound_priorities+2
}

!p_extra = $E0
if !p_ram >= !p_extra
    print "\!p_ram = ",hex(!p_ram)
    error "Spilled into extra"
endif
!p_ram #= !p_extra
%declare_word(p_trackerData)
%declare_byte(enableLateKeyOff)
%declare_word(p_songSpecificSoundInstructionLists) ; shared across all libraries

%declare_byte(noteEndInTicks) ; Note: Pocky & Rocky 2 changed this to 1 from 2
%declare_byte(disablePsychoacousticAdjustment)

; $F0..FF: IO ports
if !p_ram >= $F0
    print "\!p_ram = ",hex(!p_ram)
    error "Spilled into IO ports"
endif

; First part of page 1 is stack space
!p_ram = $0120 : !canInterleaveBytePairArray = 0
!p_stackBegin #= !p_ram

; Music
{
; Note: These are referenced in code via $00 with direct page = $100
%declare_bytePairArray(trackDynamicVibratoTimers,          !n_tracks)
%declare_bytePairArray(sound_libraryIndices,               !n_tracks)
%declare_bytePairArray(sound_instructionTimers,            !n_tracks)

%declare_bytePairArray(trackNoteLengths,                   !n_tracks)
%declare_bytePairArray(trackNoteRingLengths,               !n_tracks)
%declare_bytePairArray(trackNoteVolumes,                   !n_tracks)
%declare_bytePairArray(trackInstrumentIndices,             !n_tracks)
%declare_bytePairArray(trackSlideLengths,                  !n_tracks)
%declare_bytePairArray(trackSlideDelays,                   !n_tracks)
%declare_bytePairArray(trackSlideDirections,               !n_tracks)
%declare_bytePairArray(trackSlideExtents,                  !n_tracks)
%declare_bytePairArray(trackVibratoPhases,                 !n_tracks)
%declare_bytePairArray(trackVibratoRates,                  !n_tracks)
%declare_bytePairArray(trackVibratoDelays,                 !n_tracks)
%declare_bytePairArray(trackDynamicVibratoLengths,         !n_tracks)
%declare_bytePairArray(trackVibratoExtentDeltas,           !n_tracks)
%declare_bytePairArray(trackStaticVibratoExtents,          !n_tracks)
%declare_bytePairArray(trackTremoloPhases,                 !n_tracks)
%declare_bytePairArray(trackTremoloRates,                  !n_tracks)
%declare_bytePairArray(trackTremoloDelays,                 !n_tracks)
%declare_bytePairArray(trackTransposes,                    !n_tracks)
%declare_bytePairArray(trackTargetVolumes,                 !n_tracks)
%declare_bytePairArray(trackOutputVolumes,                 !n_tracks)
%declare_bytePairArray(trackTargetPanningBiases,           !n_tracks)
%declare_bytePairArray(trackPhaseInversionOptions,         !n_tracks)
%declare_bytePairArray(trackSubnotes,                      !n_tracks)
%declare_bytePairArray(trackTargetNotes,                   !n_tracks)
%declare_bytePairArray(trackSubtransposes,                 !n_tracks)

%declare_wordArray(trackInstrumentPitches,                 !n_tracks)
%declare_wordArray(trackRepeatedSubsectionReturnAddresses, !n_tracks)
%declare_wordArray(trackRepeatedSubsectionAddresses,       !n_tracks)
%declare_wordArray(trackVolumes,                           !n_tracks)
%declare_wordArray(trackVolumeDeltas,                      !n_tracks)
%declare_wordArray(trackPanningBiases,                     !n_tracks)
%declare_wordArray(trackPanningBiasDeltas,                 !n_tracks)
%declare_wordArray(trackNoteDeltas,                        !n_tracks)
}

; Sound channels
{
%declare_bytePairArray(sound_releaseFlags,                      !n_tracks)
%declare_bytePairArray(sound_repeatCounters,                    !n_tracks)
%declare_bytePairArray(sound_updateAdsrSettingsFlags,           !n_tracks)
%declare_bytePairArray(sound_notes,                             !n_tracks)
%declare_bytePairArray(sound_subnotes,                          !n_tracks)
%declare_bytePairArray(sound_subnoteDeltas,                     !n_tracks)
%declare_bytePairArray(sound_targetNotes,                       !n_tracks)
%declare_bytePairArray(sound_legatoFlags,                       !n_tracks)
%declare_bytePairArray(sound_pitchSlideLegatoFlags,             !n_tracks)
%declare_bytePairArray(sound_panningBiases,                     !n_tracks)
%declare_bytePairArray(sound_subtransposes,                     !n_tracks)

%declare_wordArray(sound_repeatPoints,                          !n_tracks)
if defined("adsrSoundCommand")
%declare_wordArray(sound_adsrSettings,                          !n_tracks)
endif

%declare_byteArray(sound_voiceOrder, !n_tracks)
}

!p_end_ram #= !p_ram

; $307..1D2E: SPC engine
!p_ram = $1F00-($40*6)

%declare_byteArray(instrumentTable, $40*6)

; Must be 100h aligned
!p_ram #= !p_ram+$100-1
!p_ram #= !p_ram-!p_ram%$100
%declare_byteArray(sampleTable, $A0)

!p_ram #= !sampleTable+$100
!sampleDataBegin #= !p_ram
%declare_byteArray(sampleData, $10000-!p_ram)

; Trackers float around here somewhere

!echoBufferEnd = $10000

!sampleSamusFootstep = $30
!sampleSamusLand = $31
!sampleHeatDamage = $32
!sampleLavaDamage = $33
!sampleMotoCry = $34
