; Utility constants for this file
{
!n_tracks = 8
!sound1_n_channels = 4
!sound2_n_channels = 2
!sound3_n_channels = 2
!n_channels = 8
}

!p_ram = 0
!canInterleaveBytePairArray = 0
!lastBytePairN = 0

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

macro generateIndirect_sounds(prefix, suffix, p_base)
{
    !{<prefix>1<suffix>} #= <p_base>
    !{<prefix>2<suffix>} #= <p_base>+4
    !{<prefix>3<suffix>} #= <p_base>+6
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
%declare_word(p_return)

; Sounds
{
%declare_byteArray(sound_p_instructionListsLow,  !n_channels)
%declare_byteArray(sound_p_instructionListsHigh, !n_channels)

%generateIndirect_sounds(sound, _p_instructionListsLow,  !sound_p_instructionListsLow)
%generateIndirect_sounds(sound, _p_instructionListsHigh, !sound_p_instructionListsHigh)

%generateIndirect_bytes(sound1_channel, _p_instructionListLow,  !sound1_p_instructionListsLow,  !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _p_instructionListHigh, !sound1_p_instructionListsHigh, !sound1_n_channels)
%generateIndirect_bytes(sound2_channel, _p_instructionListLow,  !sound2_p_instructionListsLow,  !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _p_instructionListHigh, !sound2_p_instructionListsHigh, !sound2_n_channels)
%generateIndirect_bytes(sound3_channel, _p_instructionListLow,  !sound3_p_instructionListsLow,  !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _p_instructionListHigh, !sound3_p_instructionListsHigh, !sound3_n_channels)
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
}

; Sounds
{
%declare_byte(i_globalChannel)
%declare_byte(i_voice)
%declare_byte(i_soundLibrary)
}

%declare_byte(fakeEchoEnableFlags)
%declare_word(p_noteRingLengthTable)
%declare_byte(noteEndInTicks) ; Note: Pocky & Rocky 2 changed this to 1 from 2
%declare_byte(sound_endedVoices)
%declare_word(p_echoFirFilters)

!p_extra = $E0
if !p_ram >= !p_extra
    print "\!p_ram = ",hex(!p_ram)
    error "Spilled into extra"
endif
!p_ram #= !p_extra
%declare_word(p_trackerData)
%declare_byte(enableLateKeyOff)

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
; Note: This one is referenced in code via $00 with direct page = $100
%declare_bytePairArray(trackDynamicVibratoTimers,          !n_tracks)

%declare_bytePairArray(trackNoteLengths,                   !n_tracks)
%declare_bytePairArray(trackNoteRingLengths,               !n_tracks)
%declare_bytePairArray(trackNoteVolume,                    !n_tracks)
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
%declare_bytePairArray(trackNotes,                         !n_tracks)
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

; Sound channels
{
; The real arrays
%declare_byteArray(sound_instructionTimers,                 !n_channels)
%declare_byteArray(sound_voiceBitsets,                      !n_channels)
%declare_byteArray(sound_voiceIndices,                      !n_channels)
%declare_byteArray(sound_releaseFlags,                      !n_channels)
%declare_byteArray(sound_repeatCounters,                    !n_channels)
%declare_byteArray(sound_repeatPointsLow,                   !n_channels)
%declare_byteArray(sound_repeatPointsHigh,                  !n_channels)
%declare_byteArray(sound_adsrSettingsLow,                   !n_channels)
%declare_byteArray(sound_adsrSettingsHigh,                  !n_channels)
%declare_byteArray(sound_updateAdsrSettingsFlags,           !n_channels)
%declare_byteArray(sound_notes,                             !n_channels)
%declare_byteArray(sound_subnotes,                          !n_channels)
%declare_byteArray(sound_subnoteDeltas,                     !n_channels)
%declare_byteArray(sound_targetNotes,                       !n_channels)
%declare_byteArray(sound_pitchSlideFlags,                   !n_channels)
%declare_byteArray(sound_legatoFlags,                       !n_channels)
%declare_byteArray(sound_pitchSlideLegatoFlags,             !n_channels)
%declare_byteArray(sound_panningBiases,                     !n_channels)

; The divisions of the arrays by sound library
%generateIndirect_sounds(sound, _instructionTimers,                 !sound_instructionTimers)
%generateIndirect_sounds(sound, _voiceBitsets,                      !sound_voiceBitsets)
%generateIndirect_sounds(sound, _voiceIndices,                      !sound_voiceIndices)
%generateIndirect_sounds(sound, _releaseFlags,                      !sound_releaseFlags)
%generateIndirect_sounds(sound, _repeatCounters,                    !sound_repeatCounters)
%generateIndirect_sounds(sound, _repeatPointsLow,                   !sound_repeatPointsLow)
%generateIndirect_sounds(sound, _repeatPointsHigh,                  !sound_repeatPointsHigh)
%generateIndirect_sounds(sound, _adsrSettingsLow,                   !sound_adsrSettingsLow)
%generateIndirect_sounds(sound, _adsrSettingsHigh,                  !sound_adsrSettingsHigh)
%generateIndirect_sounds(sound, _updateAdsrSettingsFlags,           !sound_updateAdsrSettingsFlags)
%generateIndirect_sounds(sound, _notes,                             !sound_notes)
%generateIndirect_sounds(sound, _subnotes,                          !sound_subnotes)
%generateIndirect_sounds(sound, _subnoteDeltas,                     !sound_subnoteDeltas)
%generateIndirect_sounds(sound, _targetNotes,                       !sound_targetNotes)
%generateIndirect_sounds(sound, _pitchSlideFlags,                   !sound_pitchSlideFlags)
%generateIndirect_sounds(sound, _legatoFlags,                       !sound_legatoFlags)
%generateIndirect_sounds(sound, _pitchSlideLegatoFlags,             !sound_pitchSlideLegatoFlags)
%generateIndirect_sounds(sound, _panningBiases,                     !sound_panningBiases)

; The divisions of subarrays by channel for each sound library
%generateIndirect_bytes(sound1_channel, _instructionTimer,                 !sound1_instructionTimers,                 !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _voiceBitset,                      !sound1_voiceBitsets,                      !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _voiceIndex,                       !sound1_voiceIndices,                      !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _releaseFlag,                      !sound1_releaseFlags,                      !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _repeatCounter,                    !sound1_repeatCounters,                    !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _repeatPointLow,                   !sound1_repeatPointsLow,                   !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _repeatPointHigh,                  !sound1_repeatPointsHigh,                  !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _adsrSettingsLow,                  !sound1_adsrSettingsLow,                   !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _adsrSettingsHigh,                 !sound1_adsrSettingsHigh,                  !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _updateAdsrSettingsFlag,           !sound1_updateAdsrSettingsFlags,           !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _note,                             !sound1_notes,                             !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _subnote,                          !sound1_subnotes,                          !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _subnoteDelta,                     !sound1_subnoteDeltas,                     !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _targetNote,                       !sound1_targetNotes,                       !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _pitchSlideFlag,                   !sound1_pitchSlideFlags,                   !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _legatoFlag,                       !sound1_legatoFlags,                       !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _pitchSlideLegatoFlag,             !sound1_pitchSlideLegatoFlags,             !sound1_n_channels)
%generateIndirect_bytes(sound1_channel, _panningBias,                      !sound1_panningBiases,                     !sound1_n_channels)

%generateIndirect_bytes(sound2_channel, _instructionTimer,                 !sound2_instructionTimers,                 !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _voiceBitset,                      !sound2_voiceBitsets,                      !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _voiceIndex,                       !sound2_voiceIndices,                      !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _releaseFlag,                      !sound2_releaseFlags,                      !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _repeatCounter,                    !sound2_repeatCounters,                    !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _repeatPointLow,                   !sound2_repeatPointsLow,                   !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _repeatPointHigh,                  !sound2_repeatPointsHigh,                  !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _adsrSettingsLow,                  !sound2_adsrSettingsLow,                   !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _adsrSettingsHigh,                 !sound2_adsrSettingsHigh,                  !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _updateAdsrSettingsFlag,           !sound2_updateAdsrSettingsFlags,           !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _note,                             !sound2_notes,                             !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _subnote,                          !sound2_subnotes,                          !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _subnoteDelta,                     !sound2_subnoteDeltas,                     !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _targetNote,                       !sound2_targetNotes,                       !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _pitchSlideFlag,                   !sound2_pitchSlideFlags,                   !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _legatoFlag,                       !sound2_legatoFlags,                       !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _pitchSlideLegatoFlag,             !sound2_pitchSlideLegatoFlags,             !sound2_n_channels)
%generateIndirect_bytes(sound2_channel, _panningBias,                      !sound2_panningBiases,                     !sound2_n_channels)

%generateIndirect_bytes(sound3_channel, _instructionTimer,                 !sound3_instructionTimers,                 !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _voiceBitset,                      !sound3_voiceBitsets,                      !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _voiceIndex,                       !sound3_voiceIndices,                      !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _releaseFlag,                      !sound3_releaseFlags,                      !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _repeatCounter,                    !sound3_repeatCounters,                    !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _repeatPointLow,                   !sound3_repeatPointsLow,                   !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _repeatPointHigh,                  !sound3_repeatPointsHigh,                  !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _adsrSettingsLow,                  !sound3_adsrSettingsLow,                   !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _adsrSettingsHigh,                 !sound3_adsrSettingsHigh,                  !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _updateAdsrSettingsFlag,           !sound3_updateAdsrSettingsFlags,           !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _note,                             !sound3_notes,                             !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _subnote,                          !sound3_subnotes,                          !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _subnoteDelta,                     !sound3_subnoteDeltas,                     !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _targetNote,                       !sound3_targetNotes,                       !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _pitchSlideFlag,                   !sound3_pitchSlideFlags,                   !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _legatoFlag,                       !sound3_legatoFlags,                       !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _pitchSlideLegatoFlag,             !sound3_pitchSlideLegatoFlags,             !sound3_n_channels)
%generateIndirect_bytes(sound3_channel, _panningBias,                      !sound3_panningBiases,                     !sound3_n_channels)

%declare_byteArray(sound_voiceOrder, !n_tracks)
}

!p_end_ram #= !p_ram

; $32D..295F: SPC engine
!p_ram = $2C00-($2A*6)

%declare_byteArray(instrumentTable, $2A*6)

; Must be 100h aligned
!p_ram #= !p_ram+$100-1
!p_ram #= !p_ram-!p_ram%$100
%declare_byteArray(sampleTable, $A0)

!p_ram #= !sampleTable+$100
!sampleDataBegin #= !p_ram
%declare_byteArray(sampleData, $10000-!p_ram)

; Trackers float around here somewhere

!echoBufferEnd = $10000
