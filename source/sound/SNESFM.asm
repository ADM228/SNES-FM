incsrc "SPC_constants.asm"
namespace SPC
Documentation:
    ;   ==== Code/data distribution table: ====
        ;   Page        Purpose
        ;   $00         $00 - $BF: Flags & pointers for the note stuff:
        ;   |           Song data pointer, Instrument data pointer, Effect data pointer, Sample pointer, note index, pitch, pitchbend
        ;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
        ;   $01 _ _ _ _ Stack
        ;   $02 _ _ _ _ Sample Directory
        ;   $03         $00 - $7F: Effect IDs
        ;   |__ _ _ _ _ $80 - $FF: Basic effect time counters
        ;   $04-$07 _ _ Effect q
        ;   $0A _ _ _ _ Low bytes of instrument data pointers
        ;   $0B _ _ _ _ High bytes of instrument data pointers
        ;   $0C _ _ _ _ 7/8 multiplication lookup table
        ;   $0D _ _ _ _ 15/16 multiplication lookup table
        ;   $0E         $00 - $BF: Pitch table, 96 entries long
        ;   |__ _ _ _ _ $C0 - $C8: Dummy empty sample (for beginnings and noise)
        ;   $0F _ _ _ _ Sine table, only $0F00-$0F42 is written, everything else is calculated
        ;   $10-$1F _ _ Instrument data      \_ Combined for
        ;   $20-$4F _ _ FM generation buffers/  song data   (16KB!!!!)
        ;   $50-$5F _ _ Code
        ;   $60-$FE _ _ Actual sample storage, echo buffer (separated depending on the delay & amount of samples)
        ;   $FF         $00 - $BF: Hardsync routine (here for use with PCALL to save 2 cycles)
        ;   |__ _ _ _ _ $C0 - $FF: TCALL pointers/Boot ROM
    ;   ==== Communication with SNES: ====
        ;       (Port 0 is always message number; Port 1's high 4 bits is message ID)
        ;       === To SNES: ===
        ;   Id  | P1 |    Pt2    |    Pt3    |   Meaning
        ;   $0  |    |           |           |   Waiting for yo command
        ;   $1  |    |  id | location & $FFF |   Read, jumping to transfer routine, redirect me to $5000 | location
        ;   $2  |    |    location - $1000   |   Send song data to location + $1000
        ;   $3  |     20-bit tick counter    |   Currently playing song, here's what tick it is
        ;   $F  |    |           |           |   What? 
        ;       === To SPC: ===
        ;   Id  | P1 |    Pt2    |    Pt3    |   Meaning
        ;   $0  |    |           |           |   Read yo message
        ;   $1  |    |           |           |   Stop song
        ;   $2  |    |           |  Channels |   Mute channels
        ;   $3  |     20-bit tick counter    |   Seek to tick 
        ;   $4  |    |           |           |   Prepare to get some song data and gimme the location
        ;   $5  |    |           |           |   Prepare to get some instrument data and gimme the location
        ;   $6  |    |           |           |   Play the song you have received
        ;   $7  |    |           |   SFX ID  |   Play sound effect 
        ;   $8  |    | instrument|  note ID  |   Play just a note  
        ;   $F  |    |           |           |   What? 
    ;   Sound engine documentation:
        ;   Channel flags: n0000eis
        ;   n - sample number (0 or 1)
        ;   e - whether to not parse effect data
        ;   i - whether to not parse instrument data
        ;   s - whether to not parse song data
;

org $5000
Init:       ;init routine, totally not grabbed from tales of phantasia
    CLRP
    MOV A, #$00     ;__
    MOV $F4, A      ;
    MOV $F5, A      ;
    MOV $F6, A      ;   Clear the in/out ports with the SNES, disable timers
    MOV $F7, A      ;
    MOV $F1, #$30   ;__
    MOV X, #$FF     ;   Reset the stack
    MOV SP, X       ;__
    MOV $F2, #$4D   ;
    MOV $F3, A      ;
    MOV $F2, #$2C   ;   Disable the echo
    MOV $F3, A      ;
    MOV $F2, #$3C   ;
    MOV $F3, A      ;__
    MOV $F2, #$0C   ;
    MOV $F3, A      ;   Reset volume
    MOV $F2, #$1C   ;
    MOV $F3, A      ;__
    MOV $F2, #$4C   ;   Key On nothing
    MOV $F3, A      ;__
    MOV $F2, #$5C   ;   Key Off everything
    MOV $F3, X      ;__
    MOV $F2, #$5D   ;   Set sample directory at $0200
    MOV $F3, #$02   ;__
    MOV $FA, #$82   ;   Set timer 0 to count every 16.25 ms
    MOV $F1, #$01   ;__
    MOV $F2, #$7D   ;
    MOV Y, $F3      ;
    CMP Y, #$0F     ;
    BCC +           ;   Load {echo delay}+1 into y, capping off at 16 if needed
    MOV Y, #$0F     ;
    +   INC Y       ;__
    -:              ;
        MOV A, $FD  ;
        BEQ -       ;   Time-wasting loop to clear the echo buffer
        DBNZ Y,-    ;__

    MOV $F2, #$6C   ;
    MOV $F3, #$BF   ;___
    MOV Y, #$06     ;
    -:              ;Wait 97.5 ms for some reason
        MOV A, $FD  ;
        BEQ -
        DBNZ Y, -
                    ;__
    MOV A, #$00     ;
    MOV $F2, #$5C   ;   Key off on all channels
    MOV $F3, #$FF   ;__
    MOV $F2, #$2D   ;   Disable Hardware Pitchmod
    MOV $F3, A      ;__
    MOV $F2, #$3D   ;   Disable Noise
    MOV $F3, A      ;__
    CALL set_echoFIR
    MOV $F2, #$0C   ;
    MOV $F3, #$7F   ;   Set main volume to 127
    MOV $F2, #$1C   ;
    MOV $F3, #$7F   ;__
    MOV $F1, #$00   ;
    ; MOV $FA, #$85   ;   Set Timer 0 to 16.625 ms (~60 Hz)
    MOV $FA, #$50   ;   Set Timer 0 to 10 ms     (100 Hz)
    MOV $F1, #$07   ;__

SineSetup:

    ; Setting up the sine table

    MOV X, #$02     ;__ X contains the source index,
    MOV Y, #$3E     ;__ Y contains the destination index
    .loopCopy:
        MOV A, $0F00+X
        INC X
        MOV $0F40+Y, A
        MOV A, $0F00+X
        INC X
        MOV $0F41+Y, A
        DEC Y
        DBNZ Y, SineSetup_loopCopy
    
    MOV Y, #$3F

    .loopInvert:
        MOV A, $0F00+Y
        EOR A, #$FF
        MOV $0F80+Y, A
        MOV A, $0F40+Y
        EOR A, #$FF
        MOV $0FC0+Y, A
        DBNZ Y, SineSetup_loopInvert

EffectSetup:
    MOV Y, #$00
    MOV A, #$FF
    .loopIndexSetup:
        MOV $0300+Y, A
        DBNZ Y, EffectSetup_loopIndexSetup

SetVolume:
    MOV X, #$7F
    MOV Y, #$08
    MOV A, #$00
    .loopVolumeSetup:
        MOV $F2, A
        MOV $F3, X
        INC $F2
        MOV $F3, X
        CLRC
        ADC A, #$10
        DBNZ Y, SetVolume_loopVolumeSetup

CompileInstruments:
    MOV !LTS_IN_PAGE, #$0F
    MOV !LTS_OUT_PAGE, #$20
    MOV !LTS_OUT_SUBPAGE, #$00
    CALL LongToShort
    MOV !MOD_CAR_PAGE, #$20
    MOV !MOD_MOD_PAGE, #$20
    MOV !MOD_OUT_PAGE, #$20
    MOV !MOD_MOD_STRENGTH, #$20
    MOV !MOD_MOD_PHASE_SHIFT, #$00
    MOV !MOD_SUBPAGE, #$04
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$1E
    MOV !MOD_MOD_PHASE_SHIFT, #$02
    MOV !MOD_SUBPAGE, #$08
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$1C
    MOV !MOD_MOD_PHASE_SHIFT, #$04
    MOV !MOD_SUBPAGE, #$0C
    CALL PhaseModulation_32

    MOV !MOD_OUT_PAGE, #$21

    MOV !MOD_MOD_STRENGTH, #$1A
    MOV !MOD_MOD_PHASE_SHIFT, #$06
    MOV !MOD_SUBPAGE, #$00
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$18
    MOV !MOD_MOD_PHASE_SHIFT, #$08
    MOV !MOD_SUBPAGE, #$04
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$16
    MOV !MOD_MOD_PHASE_SHIFT, #$0A
    MOV !MOD_SUBPAGE, #$08
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$14
    MOV !MOD_MOD_PHASE_SHIFT, #$0C
    MOV !MOD_SUBPAGE, #$0C
    CALL PhaseModulation_32

    MOV !MOD_OUT_PAGE, #$22

    MOV !MOD_MOD_STRENGTH, #$12
    MOV !MOD_MOD_PHASE_SHIFT, #$0E
    MOV !MOD_SUBPAGE, #$00
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$10
    MOV !MOD_MOD_PHASE_SHIFT, #$10
    MOV !MOD_SUBPAGE, #$04
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$0E
    MOV !MOD_MOD_PHASE_SHIFT, #$12
    MOV !MOD_SUBPAGE, #$08
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$0C
    MOV !MOD_MOD_PHASE_SHIFT, #$14
    MOV !MOD_SUBPAGE, #$0C
    CALL PhaseModulation_32

    MOV !MOD_OUT_PAGE, #$23

    MOV !MOD_MOD_STRENGTH, #$0A
    MOV !MOD_MOD_PHASE_SHIFT, #$16
    MOV !MOD_SUBPAGE, #$00
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$08
    MOV !MOD_MOD_PHASE_SHIFT, #$18
    MOV !MOD_SUBPAGE, #$04
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$06
    MOV !MOD_MOD_PHASE_SHIFT, #$1A
    MOV !MOD_SUBPAGE, #$08
    CALL PhaseModulation_32
    MOV !MOD_MOD_STRENGTH, #$04
    MOV !MOD_MOD_PHASE_SHIFT, #$1C
    MOV !MOD_SUBPAGE, #$0C
    CALL PhaseModulation_32

    MOV !BRR_PCM_PAGE, #$20
    MOV !BRR_OUT_INDEX, #$00
    MOV !BRR_FLAGS, #%11000100
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$01
    MOV !BRR_FLAGS, #%11001000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$02
    MOV !BRR_FLAGS, #%11001100
    CALL ConvertToBRR

    MOV !BRR_PCM_PAGE, #$21

    MOV !BRR_OUT_INDEX, #$03
    MOV !BRR_FLAGS, #%11000000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$04
    MOV !BRR_FLAGS, #%11000100
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$05
    MOV !BRR_FLAGS, #%11001000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$06
    MOV !BRR_FLAGS, #%11001100
    CALL ConvertToBRR

    MOV !BRR_PCM_PAGE, #$22
    
    MOV !BRR_OUT_INDEX, #$07
    MOV !BRR_FLAGS, #%11000000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$08
    MOV !BRR_FLAGS, #%11000100
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$09
    MOV !BRR_FLAGS, #%11001000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$0A
    MOV !BRR_FLAGS, #%11001100
    CALL ConvertToBRR

    MOV !BRR_PCM_PAGE, #$23
    
    MOV !BRR_OUT_INDEX, #$0B
    MOV !BRR_FLAGS, #%11000000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$0C
    MOV !BRR_FLAGS, #%11000100
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$0D
    MOV !BRR_FLAGS, #%11001000
    CALL ConvertToBRR
    MOV !BRR_OUT_INDEX, #$0E
    MOV !BRR_FLAGS, #%11001100
    CALL ConvertToBRR

    MOV !PUL_FLAGS, #$03
    MOV !PUL_OUT_PAGE, #$28
    MOV !PUL_DUTY, #$20
    CALL GeneratePulse_32
    MOV !BRR_PCM_PAGE, #$28
    MOV !BRR_OUT_INDEX, #$FF
    MOV !BRR_FLAGS, #%11000000
    CALL ConvertToBRR

    MOV $F2, #$5C
    MOV $F3, #$00
    MOV $F2, #$6C
    MOV $F3, #$20

Begin:
    MOV X, #$00
    MOV !PATTERN_END_FLAGS, X
    MOV A, $0EC9
    MOV !PATTERN_POINTER_L, A
    MOV A, $0ECA
    MOV !PATTERN_POINTER_H, A
    MOV A, $FD
    CALL ParsePatternData
    JMP mainLoop_00
;

ParseSongData:

    BBC0 !CHTEMP_FLAGS, +
    RET
    +:
        MOV Y, #$00
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y 
        MOV $ED, A
        BBC7 $ED, ParseSongData_NoRetrigger
    ;Retrigger
        AND A, #$7F
        SETC
        SBC A, #$60
        BMI +
        ASL A
        SETC
        SBC A, #$3A
        PUSH X
        MOV X, A
        JMP (ParseSongData_routineTable+X)
    +:
        MOV !CHTEMP_NOTE, $ED
        MOV $F2, #$5C       ;
        MOV $F3, #$00       ;   Key off the needed channel
        MOV !CHG_BIT_ADDRESS, #$F3       ;
        TCALL 13            ;__
        MOV Y, #$00
        INCW !CHTEMP_SONG_POINTER_L
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y
        MOV !CHTEMP_INSTRUMENT_INDEX, A
        CLR1 !CHTEMP_FLAGS
        SET3 !CHTEMP_FLAGS
        MOV !CHTEMP_COUNTERS_HALT, #$00
        MOV !CHTEMP_COUNTERS_DIRECTION, #$00
        CALL ParseInstrumentData
        CLRC
        ADC !CHTEMP_INSTRUMENT_TYPE_COUNTER, !TIMER_VALUE
        ADC !CHTEMP_ENVELOPE_COUNTER, !TIMER_VALUE
        ADC !CHTEMP_SAMPLE_POINTER_COUNTER, !TIMER_VALUE
        ADC !CHTEMP_ARPEGGIO_COUNTER, !TIMER_VALUE
        ADC !CHTEMP_PITCHBEND_COUNTER, !TIMER_VALUE
        MOV $F2, #$5C       ;
        MOV $F3, #$00       ;   Key off nothing (so no overrides happen)
        MOV $F2, #$4C       ;
        MOV $F3, #$00       ;   Key on the needed channel
        MOV !CHG_BIT_ADDRESS, #$F3;
        TCALL 13            ;__
    .NoRetrigger:
        MOV A, $ED              ;
        MOV !CHTEMP_NOTE, A     ;   Apply arpeggio
        CLRC                    ;
        ADC A, !CHTEMP_ARPEGGIO ;__
        INCW !CHTEMP_SONG_POINTER_L
        BBC0 !CHTEMP_INSTRUMENT_TYPE, ParseSongData_NoisePitch
        ASL A
        MOV Y, A             
        MOV A, $0E00+Y
        AND !CHTEMP_REGISTER_INDEX, #$70
        OR !CHTEMP_REGISTER_INDEX, #$02
        MOV $F2, !CHTEMP_REGISTER_INDEX;
        MOV $F3, A
        MOV A, $0E01+Y
        OR !CHTEMP_REGISTER_INDEX, #$01    
        MOV $F2, !CHTEMP_REGISTER_INDEX;
        MOV $F3, A ;pitch
        JMP +
    .NoisePitch:
        AND A, #$1F  ;
        MOV $F2, #$6C;  Update noise clock
        AND $F3, #$E0;
        TSET $F3    ;__
    +:
    -:
        MOV Y, #$00
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y
        DEC A
        MOV !CHTEMP_SONG_COUNTER, A
        INCW !CHTEMP_SONG_POINTER_L
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y
        RET
    .Keyoff:
        SET1 !CHTEMP_FLAGS
        MOV $F2, #$5C
        MOV $F3, #$00
        POP X
        PUSH X
        MOV !CHG_BIT_ADDRESS, #$F3
        TCALL 13
    .NoPitch:
        INCW !CHTEMP_SONG_POINTER_L
        POP X
        JMP -
    .End:
        SET0 !CHTEMP_FLAGS
        MOV !CHG_BIT_ADDRESS, #!PATTERN_END_FLAGS
        POP X
        TCALL 13
        INCW !CHTEMP_SONG_POINTER_L
        CMP !PATTERN_END_FLAGS, #$FF
        BNE -
        CALL ParsePatternData
        MOV X, #$00
        JMP mainLoop_01
    .routineTable:
        dw ParseSongData_Keyoff
        dw ParseSongData_NoPitch
        dw ParseSongData_End
mainLoop:
    .00:
        MOV !TIMER_VALUE, $FD
        MOV A, !TIMER_VALUE
        BEQ mainLoop_00
    .01:
        TCALL 15
        CALL UpdateEffects
        SETC
        SBC !CHTEMP_EFFECT_COUNTER, !TIMER_VALUE
        BPL +
        CALL ParseEffectData
    +:
        SETC
        SBC !CHTEMP_SONG_COUNTER, !TIMER_VALUE
        BPL +
        CALL ParseSongData
    +:
        CALL ParseInstrumentData
        TCALL 14    ;Transfer shit back
        MOV A, X
        CLRC
        ADC A, #$08
        AND A, #$38
        MOV !CHTEMP_REGISTER_INDEX, A
        ASL !CHTEMP_REGISTER_INDEX
        MOV X, A
        BNE mainLoop_01
        JMP mainLoop_00

ParseInstrumentData:
        BBC1 !CHTEMP_FLAGS, ParseInstrumentData_Load
        RET
    .Load:
        MOV Y, !CHTEMP_INSTRUMENT_INDEX
        MOV A, $0A00+Y
        MOV !TEMP_POINTER0_L, A
        MOV A, $0B00+Y
        MOV !TEMP_POINTER0_H, A
        MOV Y, #$00
        BBS3 !CHTEMP_FLAGS, +
        JMP ParseInstrumentData_NotFirstTime
        +:
        MOV !CHTEMP_ARPEGGIO, #$00
        MOV $E0, #$05
        
        SETP
        MOV A, #$00
        MOV !CH1_INSTRUMENT_TYPE_POINTER+X, A
        MOV !CH1_ENVELOPE_POINTER+X, A
        MOV !CH1_SAMPLE_POINTER_POINTER+X, A
        MOV !CH1_ARPEGGIO_POINTER+X, A
        MOV !CH1_PITCHBEND_POINTER+X, A

        CLRP
        INCW !TEMP_POINTER0_L
        INCW !TEMP_POINTER0_L
        CALL ParseInstrumentData_UpdateInstrumentType
        CALL ParseInstrumentData_UpdateEnvelope
        CALL ParseInstrumentData_UpdateSamplePointer

        CLR3 !CHTEMP_FLAGS
        RET
    .NotFirstTime
        INCW !TEMP_POINTER0_L
        INCW !TEMP_POINTER0_L
        BBS0 !CHTEMP_COUNTERS_HALT, +
            SETC
            SBC !CHTEMP_INSTRUMENT_TYPE_COUNTER, !TIMER_VALUE
            BPL +
                CALL ParseInstrumentData_UpdateInstrumentType
                JMP ++
        +
        CALL ParseInstrumentData_SkipMacro
        ++
        BBS1 !CHTEMP_COUNTERS_HALT, +
            SETC
            SBC !CHTEMP_ENVELOPE_COUNTER, !TIMER_VALUE
            BPL +
                CALL ParseInstrumentData_UpdateEnvelope
                JMP ++
        +
        CALL ParseInstrumentData_SkipMacro
        ++
        BBS2 !CHTEMP_COUNTERS_HALT, +
            SETC
            SBC !CHTEMP_SAMPLE_POINTER_COUNTER, !TIMER_VALUE
            BPL +
                CALL ParseInstrumentData_UpdateSamplePointer
                JMP ++

        +
        CALL ParseInstrumentData_SkipMacro
        ++
        RET
        
    .UpdateInstrumentType
        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y             ;
        MOV !TEMP_POINTER1_L, A                 ;
        INCW !TEMP_POINTER0_L                   ;   Get base instrument type
        MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
        MOV !TEMP_POINTER1_H, A                 ;
        INCW !TEMP_POINTER0_L                   ;__

        SETP                                    ;
        MOV A, !CH1_INSTRUMENT_TYPE_POINTER+X   ;
        CLRP                                    ;   Get the current instrument
        MOV Y, #$00                             ;   type macro pointer
        ADDW YA, !TEMP_POINTER1_L               ;
        MOVW !TEMP_POINTER1_L, YA               ;__
        MOV Y, #$00                             ;
        MOV A, (!TEMP_POINTER1_L)+Y             ;   Get the instrument type
        MOV !CHTEMP_INSTRUMENT_TYPE, A          ;__

        MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the amount of steps
        INCW !TEMP_POINTER0_L                   ;__
        SETP
        CMP A, !CH1_INSTRUMENT_TYPE_POINTER+X   
        BNE ++
            CLRP
            SET0 !CHTEMP_COUNTERS_HALT
            INCW !TEMP_POINTER0_L
            JMP ParseInstrumentData_UpdateInstrumentType_ActualUpdate
        ++  INC !CH1_INSTRUMENT_TYPE_POINTER+X      ;TODO: More looping types
            CLRP
            MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the counter value
            INCW !TEMP_POINTER0_L                   ;__
            MOV !CHTEMP_INSTRUMENT_TYPE_COUNTER, A  ;__ Store counter value
        ..ActualUpdate:
            MOV $F2, #$3D                       ;
            MOV !CHG_BIT_ADDRESS, #$F3          ;
            BBC0 !CHTEMP_INSTRUMENT_TYPE, +     ;
                TCALL 12                        ;   Update the noise enable flag
                JMP ++                          ;
            +:                                  ;
                TCALL 13                        ;__
        ++  AND !CHTEMP_REGISTER_INDEX, #$70    ; 
            OR !CHTEMP_REGISTER_INDEX, #$05     ;
            MOV $F2, !CHTEMP_REGISTER_INDEX     ;
            MOV A, $F3                          ;
            XCN A                               ;   If the envelope mode isn't changed, 
            LSR A                               ;   don't clear the envelope
            LSR A                               ;
            EOR A, !CHTEMP_INSTRUMENT_TYPE      ;
            AND A, #$02                         ;
            BNE RET_                            ;__
            AND !CHTEMP_REGISTER_INDEX, #$70    ; 
            BBS1 !CHTEMP_INSTRUMENT_TYPE, +     ;
                OR !CHTEMP_REGISTER_INDEX, #$05 ;   Write address to DSP (ADSR1)
                MOV $F2, !CHTEMP_REGISTER_INDEX ;__
                MOV $F3, #$80                   ;   If ADSR is used,
                INC $F2                         ;   Clear out the ADSR envelope
                MOV $F3, #$00                   ;__
            #RET_ RET
            +:                                  ;
                OR !CHTEMP_REGISTER_INDEX, #$08 ;
                MOV $F2, !CHTEMP_REGISTER_INDEX ;
                MOV A, $F3                      ;   If GAIN is used,
                DEC $F2                         ;   set the GAIN envelope to the current value
                MOV $F3, A                      ;
                DEC $F2                         ;
                DEC $F2                         ;
                MOV $F3, #$00                   ;__
            RET
    ;

    .UpdateEnvelope:
        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y             ;
        MOV !TEMP_POINTER1_L, A                 ;
        INCW !TEMP_POINTER0_L                   ;   Get base envelope
        MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
        MOV !TEMP_POINTER1_H, A                 ;
        INCW !TEMP_POINTER0_L                   ;__

        SETP                                    ;
        MOV A, !CH1_ENVELOPE_POINTER+X   ;
        CLRP                                    ;
        MOV Y, #$00                             ;
        BBS1 !CHTEMP_INSTRUMENT_TYPE, +         ;
            ASL A                               ;   Get the current envelope macro pointer
            BCC +                               ;
                INC Y                           ;
        +:                                      ;
        ADDW YA, !TEMP_POINTER1_L               ;
        MOVW !TEMP_POINTER1_L, YA               ;__

        MOV Y, #$00                             ;
        MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the amount of steps
        INCW !TEMP_POINTER0_L                   ;__
        SETP
        CMP A, !CH1_ENVELOPE_POINTER+X   
        BNE ++
            CLRP
            SET1 !CHTEMP_COUNTERS_HALT
            INCW !TEMP_POINTER0_L
            JMP ParseInstrumentData_UpdateEnvelope_ActualUpdate
        ++  INC !CH1_ENVELOPE_POINTER+X             ;TODO: More looping types
            CLRP
            MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the counter value
            INCW !TEMP_POINTER0_L                   ;__
            MOV !CHTEMP_ENVELOPE_COUNTER, A         ;__ Store counter value
        ..ActualUpdate:
            AND !CHTEMP_REGISTER_INDEX, #$70        ;
            BBS1 !CHTEMP_INSTRUMENT_TYPE, +         ;
                OR !CHTEMP_REGISTER_INDEX, #$05         ;
                MOV $F2, !CHTEMP_REGISTER_INDEX         ;
                MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Attack, Decay
                INCW !TEMP_POINTER1_L                   ;
                OR A, #$80                              ;
                MOV $F3, A                              ;__
                INC $F2                                 ;
                MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Sustain, Release
                INCW !TEMP_POINTER1_L                   ;
                MOV $F3, A                              ;
                RET
            +:
                OR !CHTEMP_REGISTER_INDEX, #$07         ;
                MOV $F2, !CHTEMP_REGISTER_INDEX         ;   Update GAIN envelope
                MOV A, (!TEMP_POINTER1_L)+Y             ;
                MOV $F3, A                              ;
                INCW !TEMP_POINTER1_L                   ;__
                RET
    ;

    .UpdateSamplePointer:
        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y             ;
        MOV !TEMP_POINTER1_L, A                 ;
        INCW !TEMP_POINTER0_L                   ;   Get base sample pointer
        MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
        MOV !TEMP_POINTER1_H, A                 ;
        INCW !TEMP_POINTER0_L                   ;__

        SETP                                    ;
        MOV A, !CH1_SAMPLE_POINTER_POINTER+X    ;
        CLRP                                    ;
        MOV Y, #$00                             ;
        BBS3 !CHTEMP_INSTRUMENT_TYPE, +         ;
            ASL A                               ;   Get the current sample pointer macro pointer
            BCC +                               ;
                INC Y                           ;
        +:                                      ;
        ADDW YA, !TEMP_POINTER1_L               ;
        MOVW !TEMP_POINTER1_L, YA               ;__

        MOV Y, #$00                             ;
        MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the amount of steps
        INCW !TEMP_POINTER0_L                   ;__
        SETP
        CMP A, !CH1_SAMPLE_POINTER_POINTER+X   
        BNE ++
            CLRP
            SET2 !CHTEMP_COUNTERS_HALT
            INCW !TEMP_POINTER0_L
            JMP ParseInstrumentData_UpdateSamplePointer_ActualUpdate
        ++  INC !CH1_SAMPLE_POINTER_POINTER+X       ;TODO: More looping types
            CLRP
            MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the counter value
            INCW !TEMP_POINTER0_L                   ;__
            MOV !CHTEMP_SAMPLE_POINTER_COUNTER, A   ;__ Store counter value
        ..ActualUpdate:
                BBC3 !CHTEMP_INSTRUMENT_TYPE, +         ;__ If sample index is used,
                MOV A, (!TEMP_POINTER1_L)+Y             ;
                INCW !TEMP_POINTER1_L                   ;
                MOV Y, A                                ;
                MOV A, !CHTEMP_INSTRUMENT_TYPE          ;
                AND A, #$30                             ;
                XCN A                                   ;
                MOV $EF, A                              ;  Get pointer from sample index
                MOV A, !CHTEMP_INSTRUMENT_TYPE          ;
                AND A, #$40                             ;
                OR A, $EF                               ;
                TCALL 11                                ;
                MOVW !CHTEMP_SAMPLE_POINTER_L, YA       ;
                MOV Y, #$00                             ;
                JMP ++                                  ;__
            +   MOV A, (!TEMP_POINTER1_L)+Y             ;
                MOV !CHTEMP_SAMPLE_POINTER_L, A         ;   If no, just blatantly
                INCW !TEMP_POINTER1_L                   ;   Load sample pointer into memory
                MOV A, (!TEMP_POINTER1_L)+Y             ;
                MOV !CHTEMP_SAMPLE_POINTER_H, A         ;
                INCW !TEMP_POINTER1_L                   ;__
            ++  CALL updatePointer                      ;__ Update the sample pointer
                RET
    .SkipMacro:
        CLRC
        ADC !TEMP_POINTER0_L, #$04
        ADC !TEMP_POINTER0_H, #$00
        RET
    ; .UpdateArpeggio:
    ;     BBC1 $E0, +                             ;__ If no apreggio update, skip
    ;     MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;   
    ;     MOV !CHTEMP_ARPEGGIO, A                 ;   Update arpeggio
    ;     INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    ;     MOV A, !CHTEMP_NOTE                     ;   Apply arpeggio
    ;     CLRC                                    ;
    ;     ADC A, !CHTEMP_ARPEGGIO                 ;__
    ;     BBC0 !CHTEMP_INSTRUMENT_TYPE, ++
    ;     ASL A                                   ;
    ;     MOV Y, A                                ;__
    ;     MOV A, $0E00+Y                          ;
    ;     AND !CHTEMP_REGISTER_INDEX, #$70        ;
    ;     OR !CHTEMP_REGISTER_INDEX, #$02         ;   Update low byte of pitch
    ;     MOV $F2, !CHTEMP_REGISTER_INDEX;        ;
    ;     MOV $F3, A                              ;__
    ;     MOV A, $0E01+Y                          ;
    ;     OR !CHTEMP_REGISTER_INDEX, #$01         ;   Update high byte of pitch
    ;     MOV $F2, !CHTEMP_REGISTER_INDEX;        ;
    ;     MOV $F3, A                              ;
    ;     MOV Y, #$00                             ;__
    ;     JMP +
    ; ++:
    ;     AND A, #$1F                             ;
    ;     MOV $F2, #$6C                           ;  Update noise clock
    ;     AND $F3, #$E0                           ;
    ;     OR A, $F3                               ;
    ;     MOV $F3, A                              ;__
    ; +:
    ;     MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    ;     DEC A                                   ;
    ;     MOV !CHTEMP_INSTRUMENT_COUNTER, A       ;   Update instrument counter
    ;     INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    RET

    ; .CommandJumpTable:
    ; dw ParseInstrumentData_ChangeType
    ; dw ParseInstrumentData_LoopInstrumentData
    ; dw ParseInstrumentData_LoadAgain
    ; dw ParseInstrumentData_StopInstrumentData

ParseEffectData:
    BBC2 !CHTEMP_FLAGS, ParseEffectData_Load
    RET
    .Load:
        PUSH X
        MOV Y, #$00
        MOV A, (!CHTEMP_EFFECT_POINTER_L)+Y
        BMI +
        INCW !CHTEMP_EFFECT_POINTER_L
        MOV $E0, A
        AND $E0, #$01
        AND A, #$FE
        MOV X, A
        JMP (ParseEffectData_EffectJumpTable+X)
    +:
        INCW !CHTEMP_EFFECT_POINTER_L
        SETC
        SBC A, #$FE
        ASL A
        MOV X, A
        JMP (ParseEffectData_EndingJumpTable+X)
    .Wait:
        POP X
        MOV A, (!CHTEMP_EFFECT_POINTER_L)+Y
        INCW !CHTEMP_EFFECT_POINTER_L
        DEC A
        MOV !CHTEMP_EFFECT_COUNTER, A
        RET
    .EndEffectData:
        POP X
        SET2 !CHTEMP_FLAGS
        RET
    .SetVolumeL_or_R:
        POP X
        MOV A, (!CHTEMP_EFFECT_POINTER_L)+Y
        INCW !CHTEMP_EFFECT_POINTER_L 
        AND !CHTEMP_REGISTER_INDEX, #$70
        MOV $F2, !CHTEMP_REGISTER_INDEX
        BBC0 $E0, +         ;   Store to right volume register if bit 0 set
        INC $F2             ;__
    +   MOV $F3, A
        JMP ParseEffectData_Load

    .SetVolumeLR:
        POP X
        MOV A, (!CHTEMP_EFFECT_POINTER_L)+Y
        INCW !CHTEMP_EFFECT_POINTER_L 
        AND !CHTEMP_REGISTER_INDEX, #$70
        MOV $F2, !CHTEMP_REGISTER_INDEX
        MOV $F3, A
        BBC0 $E0, +                         ;
        MOV A, (!CHTEMP_EFFECT_POINTER_L)+Y ;   Load different value if bit 0 set
        INCW !CHTEMP_EFFECT_POINTER_L       ;__
    +   INC $F2                             
        MOV $F3, A
        JMP ParseEffectData_Load

    .VolumeSlideLR:
        JMP ParseEffectData_Load
    .EndingJumpTable:
    dw ParseEffectData_Wait
    dw ParseEffectData_EndEffectData
    .EffectJumpTable:
    dw ParseEffectData_SetVolumeLR
    dw ParseEffectData_SetVolumeL_or_R
    dw ParseEffectData_VolumeSlideLR

UpdateEffects:
    RET

ParsePatternData:
    MOV X, #$00
    MOV !PATTERN_END_FLAGS, #$00
    -:
        MOV Y, #$00
        MOV A, (!PATTERN_POINTER_L)+Y
        CMP A, #$FF
        BEQ End
        INCW !PATTERN_POINTER_L
        ASL A
        MOV Y, A
        MOV A, PatternPointers+Y
        MOV !CHTEMP_SONG_POINTER_L, A
        INC Y
        MOV A, PatternPointers+Y
        MOV !CHTEMP_SONG_POINTER_H, A
        MOV A, #$00
        MOV !CH1_SONG_COUNTER+X, A
        MOV !CH1_EFFECT_COUNTER+X, A
        MOV A, !CH1_FLAGS+X
        AND A, #$FA
        MOV !CH1_FLAGS+X, A
        MOV Y, #$00
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y 
        INCW !CHTEMP_SONG_POINTER_L
        MOV !CH1_EFFECT_POINTER_L+X, A
        MOV A, (!CHTEMP_SONG_POINTER_L)+Y 
        INCW !CHTEMP_SONG_POINTER_L
        MOV !CH1_EFFECT_POINTER_H+X, A
        MOVW YA, !CHTEMP_SONG_POINTER_L
        MOV !CH1_SONG_POINTER_L+X, A
        MOV !CH1_SONG_POINTER_H+X, Y
        MOV A, X
        CLRC
        ADC A, #$08
        AND A, #$38
        MOV X, A
        BNE -
    RET

End:
    MOV $F2, #$6C   ;   Mute!
    MOV $F3, #$60   ;__
    MOV $6C, #$C0
    MOV $F4, #$89
    MOV $F5, #$AB
    MOV $F6, #$CD
    MOV $F7, #$EF
    STOP

;

updatePointer:         ;When the sample is 0
        BBS7 !CHTEMP_FLAGS, updatePointer_1  ;If the sample currently playing is 1, update sample 0
    .0:
        MOV A, !CHTEMP_SAMPLE_POINTER_H     ;   Check if high byte is the same
        CMP A, $0203+X                      ;__
        BNE updatePointer_0_withRestart
        MOV A, !CHTEMP_SAMPLE_POINTER_L     ;
        MOV $0202+X, A                      ;__ Update low byte of sample pointer
        RET
        
    ..withRestart:
        MOV $0207+X, A                      ;   If high byte is different,
        MOV A, !CHTEMP_SAMPLE_POINTER_L     ;   Update sample 1 loop pointer
        MOV $0206+X, A                      ;__
        MOV A, #$C0                         ;
        MOV $0204+X, A                      ;   Reset sample 1 start pointer to blank sample
        MOV A, #$0E                         ;
        MOV $0205+X, A                      ;__
        AND !CHTEMP_REGISTER_INDEX, #$70    ;   
        OR !CHTEMP_REGISTER_INDEX, #$04     ;   Write address to DSP
        MOV $F2, !CHTEMP_REGISTER_INDEX     ;__
        MOV A, !CHTEMP_REGISTER_INDEX       ;
        LSR A                               ;
        LSR A                               ;   Write Source Number to DSP
        LSR A                               ;
        OR A, #$01                          ;
        MOV $F3, A                          ;__
        SET7 !CHTEMP_FLAGS                  ;__ Next time update sample 0
        RET


    .1:
        MOV A, !CHTEMP_SAMPLE_POINTER_H     ;   Check if high byte is the same
        CMP A, $0207+X                      ;__
        BNE updatePointer_1_withRestart
        MOV A, !CHTEMP_SAMPLE_POINTER_L     ;
        MOV $0206+X, A                      ;__ Update low byte of sample pointer
        RET
        
    ..withRestart:
        MOV $0203+X, A                      ;   If high byte is different,
        MOV A, !CHTEMP_SAMPLE_POINTER_L     ;   Update sample 1 loop pointer
        MOV $0202+X, A                      ;__
        MOV A, #$C0                         ;
        MOV $0200+X, A                      ;   Reset sample 1 start pointer to blank sample
        MOV A, #$0E                         ;
        MOV $0201+X, A                      ;__
        AND !CHTEMP_REGISTER_INDEX, #$70    ;   
        OR !CHTEMP_REGISTER_INDEX, #$04     ;   Write address to DSP
        MOV $F2, !CHTEMP_REGISTER_INDEX     ;__
        MOV A, !CHTEMP_REGISTER_INDEX       ;
        LSR A                               ;
        LSR A                               ;   Write Source Number to DSP
        LSR A                               ;
        MOV $F3, A                          ;__
        CLR7 !CHTEMP_FLAGS                  ;__ Next time sample 1 is updated
    RET

set_echoFIR:
    MOV $00, #$08
    MOV $01, #$0F
    MOV Y, #$00
    -:
        MOV $F2, $01
        MOV A, set_echoFIR_FIRTable+Y
        MOV $F3, A
        CLRC
        ADC $01, #$10
        INC Y
        DBNZ $00, -
    RET


    .FIRTable:
        db #$7f, #$00, #$00, #$00, #$00, #$00, #$00, #$00

GeneratePulse_128:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - Output page
    ;       $D1 - Duty cycle
    ;       $D2 - Flags: ddddddsz
    ;           dddddd - Duty cycle (fractional part, highest bit of fractional part in $D1)
    ;           s - starting value (0 - 0/-1, 1 - 1)
    ;           z - the low value is -1 instead of 0 (for not ringmod)
    ;   Temp variables:
    ;       $EE-EF - Output pointer
    ;Low byte of first part
        MOV !PUL_OUT_PTR_H, !PUL_OUT_PAGE
        MOV !PUL_OUT_PTR_L, #$00
        MOV A, !PUL_DUTY        ;   Get finishing low byte
        AND A, #$FE             ;__
        MOV Y, A                ;   If there are no bytes in the first part, skip the part
        BEQ +                   ;__
        MOV A, !PUL_FLAGS
        AND A, #$02
        MOV X, A
        MOV A, GeneratePulse_128_LookupTable+1+X
        -:
            DEC Y
            DEC Y
            MOV (!PUL_OUT_PTR_L)+Y, A
            CMP Y, #$00
            BNE -
    ;High byte of first part
        MOV A, !PUL_DUTY        ;   Get finishing high byte
        OR A, #$01              ;__
        MOV Y, A
        MOV A, !PUL_FLAGS
        AND A, #$03
        MOV X, A
        MOV A, GeneratePulse_128_LookupTable+X
        EOR A, #$80
        -:
            DEC Y
            DEC Y
            MOV (!PUL_OUT_PTR_L)+Y, A
            CMP Y, #$01
            BNE -
    +:
    ;Second part, the fractional value
        MOV A, !PUL_FLAGS           ;
        AND A, #$03                 ;
        MOV X, A                    ;   Get the inversion value into "temp variable"
        MOV A, GeneratePulse_128_LookupTable+4+X
        MOV !PUL_OUT_PTR_L, A     ;__
        MOV A, !PUL_DUTY            ;
        LSR A                       ;   Get the actual fraction,
        MOV A, !PUL_FLAGS           ;   while also getting 
        ROR A                       ;   z flag into carry
        AND A, #$FE                 ;__
        BCC +                       ;   If z flag is set, 
        LSR A                       ;__ halve the fraction
    +   EOR A, !PUL_OUT_PTR_L     ;__ Invert the fraction as needed
        MOV Y, A
        MOV A, !PUL_DUTY            ;   Get index for the fraction
        AND A, #$FE                 ;
        MOV !PUL_OUT_PTR_L, A     ;__
        MOV A, Y
        MOV Y, #$01
        MOV (!PUL_OUT_PTR_L)+Y, A
        MOV A, #$00
        DEC Y
        MOV (!PUL_OUT_PTR_L)+Y, A
        INC !PUL_OUT_PTR_L
        INC !PUL_OUT_PTR_L
    ;Third part
        MOV A, !PUL_DUTY
        EOR A, #$FE
        AND A, #$FE
        MOV Y, A
        MOV A, !PUL_FLAGS
        AND A, #$02
        EOR A, #$02
        MOV X, A
        MOV A, GeneratePulse_128_LookupTable+1+X
        -:
            DEC Y
            DEC Y
            MOV (!PUL_OUT_PTR_L)+Y, A
            CMP Y, #$00
            BNE -
    ;High byte of first part
        MOV A, !PUL_DUTY        ;   Get finishing high byte
        EOR A, #$FE             ;
        OR A, #$01              ;__
        MOV Y, A
        MOV A, !PUL_FLAGS
        AND A, #$03
        EOR A, #$02
        MOV X, A
        MOV A, GeneratePulse_128_LookupTable+X
        EOR A, #$80
        -:
            DEC Y
            DEC Y
            MOV (!PUL_OUT_PTR_L)+Y, A
            CMP Y, #$01
            BNE -
    +:
    RET
    .LookupTable:   ;In order:
    ;Highbyte with sz = 00 (8000),
    ;Lowbyte with s=0 (8000/0000) / Highbyte with sz = 01 (0000), 
    ;Highbyte with sz = 1- (7FFF),
    ;Lowbyte with s=1 (7FFF) / Highbyte with sz = 1- (7FFF)
    ;Highbytes are EOR #$80'd.
    db $80, $00, $FF, $FF
    ;Inversion values for fractional value
    db $7F, $FE, $00, $80


GeneratePulse_32:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - Output page
    ;       $D1 - Duty cycle: ppdddddd
    ;           pp - subpage number
    ;           dddddd - Duty cycle 
    ;       $D2 - Flags: ddddddsz
    ;           dddddd - Duty cycle (fractional part, highest bit of fractional part in $D1)
    ;           s - starting value (0 - 0/-1, 1 - 1)
    ;           z - the low value is -1 instead of 0 (for not ringmod)
    ;   Temp variables:
    ;       $EE-EF - Output pointer

    ;Low byte of first part
    MOV !PUL_OUT_PTR_H, !PUL_OUT_PAGE
    MOV !PUL_OUT_PTR_L, !PUL_DUTY
    AND !PUL_OUT_PTR_L, #$C0
    MOV A, !PUL_DUTY        ;   Get finishing low index
    AND A, #$3E             ;__
    MOV Y, A                ;   If there are no bytes in the first part, skip the part
    BEQ +                   ;__
    MOV A, !PUL_FLAGS
    AND A, #$02
    MOV X, A
    MOV A, GeneratePulse_128_LookupTable+1+X
    -:
        DEC Y
        DEC Y
        MOV (!PUL_OUT_PTR_L)+Y, A
        CMP Y, #$00
        BNE -
    ;High byte of first part
    MOV A, !PUL_DUTY        ;
    AND A, #$3E             ;   Get finishing high index
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    MOV X, A
    MOV A, GeneratePulse_128_LookupTable+X
    EOR A, #$80
    -:
        DEC Y
        DEC Y
        MOV (!PUL_OUT_PTR_L)+Y, A
        CMP Y, #$01
        BNE -
    +:
    ;Second part, the fractional value
    MOV A, !PUL_FLAGS           ;
    AND A, #$03                 ;
    MOV X, A                    ;   Get the inversion value into "temp variable"
    MOV A, GeneratePulse_128_LookupTable+4+X
    MOV !PUL_OUT_PTR_L, A     ;__
    MOV A, !PUL_DUTY            ;
    LSR A                       ;   Get the actual fraction,
    MOV A, !PUL_FLAGS           ;   while also getting 
    ROR A                       ;   z flag into carry
    AND A, #$FE                 ;__
    BCC +                       ;   If z flag is set, 
    LSR A                       ;__ halve the fraction
    +   EOR A, !PUL_OUT_PTR_L   ;__ Invert the fraction as needed
    MOV Y, A
    MOV A, !PUL_DUTY            ;   Get index for the fraction
    AND A, #$FE                 ;
    MOV !PUL_OUT_PTR_L, A     ;__
    MOV A, Y
    MOV Y, #$01
    MOV (!PUL_OUT_PTR_L)+Y, A
    MOV A, #$00
    DEC Y
    MOV (!PUL_OUT_PTR_L)+Y, A
    INC !PUL_OUT_PTR_L
    INC !PUL_OUT_PTR_L
    ;Third part
    MOV A, !PUL_DUTY
    EOR A, #$FE
    AND A, #$3E
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$02
    EOR A, #$02
    MOV X, A
    MOV A, GeneratePulse_128_LookupTable+1+X
    -:
        DEC Y
        DEC Y
        MOV (!PUL_OUT_PTR_L)+Y, A
        CMP Y, #$00
        BNE -
    ;High byte of first part
    MOV A, !PUL_DUTY        ;   Get finishing high byte
    EOR A, #$3E             ;
    AND A, #$3E             ;
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    EOR A, #$02
    MOV X, A
    MOV A, GeneratePulse_128_LookupTable+X
    EOR A, #$80
    -:
        DEC Y
        DEC Y
        MOV (!PUL_OUT_PTR_L)+Y, A
        CMP Y, #$01
        BNE -
    RET


LongToShort:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - Input page
    ;       $D1 - Output page
    ;       $D2 - Subpage number: ll------
    ;           ll - subpage number
    ;   Temp variables:
    ;       $EC-ED - Input pointer
    ;       $EE-EF - Output pointer
    MOV X, #$00
    MOV Y, #$20
    MOV !LTS_IN_PTR_H, !LTS_IN_PAGE
    MOV !LTS_OUT_PTR_H, !LTS_OUT_PAGE
    MOV !LTS_IN_PTR_L, #$F9
    MOV A, !LTS_OUT_SUBPAGE
    CLRC
    ADC A, #$3F
    MOV !LTS_OUT_PTR_L, A
    -:
        MOV A, (!LTS_IN_PTR_L+X)    ;   Copy high byte
        MOV (!LTS_OUT_PTR_L+X), A   ;__
        DEC !LTS_IN_PTR_L
        DEC !LTS_OUT_PTR_L
        MOV A, (!LTS_IN_PTR_L+X)    ;   Copy low byte
        MOV (!LTS_OUT_PTR_L+X), A   ;__
        DEC !LTS_OUT_PTR_L
        MOV A, !LTS_IN_PTR_L
        SETC
        SBC A, #$07
        MOV !LTS_IN_PTR_L, A
        DBNZ Y, -
    RET

PhaseModulation_128:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - Carrier page
    ;       $D1 - Modulator page
    ;       $D2 - Output page
    ;       $D3 - Modulation strength
    ;       $D4 - Modulator phase shift (for "detune")
    ;   Temp variables:
    ;       $EA-EB - Output pointer
    ;       $EC-ED - Modulator pointer
    ;       $EE-EF - Main temp variable
    .Setup:
        MOV X, #$00
        MOV !MOD_OUT_INDEX_H, !MOD_OUT_PAGE
        MOV !MOD_MOD_INDEX_H, !MOD_MOD_PAGE
        MOV !MOD_OUT_INDEX_L, X
        MOV !MOD_MOD_INDEX_L, !MOD_MOD_PHASE_SHIFT
        ASL !MOD_MOD_INDEX_L
    .loop:
        INC !MOD_MOD_INDEX_L            ;
        MOV A, (!MOD_MOD_INDEX_L+X)     ;   Get high byte
        MOV !MOD_MAIN_TEMP_H, A         ;
        BMI PhaseModulation_128_loop_negative 
        MOV Y, !MOD_MOD_STRENGTH        ;
        MUL YA                          ;   Multiply high byte by modulation strength
        MOVW !MOD_MAIN_TEMP_L, YA       ;__

        DEC !MOD_MOD_INDEX_L
        MOV A, (!MOD_MOD_INDEX_L+X)
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOV A, Y
        CLRC
        ADC A, !MOD_MAIN_TEMP_L
        ADC !MOD_MAIN_TEMP_H, #$00
        JMP PhaseModulation_128_loop_afterMul
    .loop_negative:
        EOR A, #$FF
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOVW !MOD_MAIN_TEMP_L, YA

        DEC !MOD_MOD_INDEX_L
        MOV A, (!MOD_MOD_INDEX_L+X)
        EOR A, #$FF
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOV A, Y
        CLRC
        ADC A, !MOD_MAIN_TEMP_L
        ADC !MOD_MAIN_TEMP_H, #$00
        EOR A, #$FF
        EOR !MOD_MAIN_TEMP_H, #$FF
    .loop_afterMul:

        LSR !MOD_MAIN_TEMP_H
        ROR A
        LSR !MOD_MAIN_TEMP_H
        ROR A
        LSR !MOD_MAIN_TEMP_H
        ROR A
        LSR !MOD_MAIN_TEMP_H
        ROR A
        LSR !MOD_MAIN_TEMP_H
        ROR A
        AND A, #$FE
        CLRC
        ADC A, !MOD_OUT_INDEX_L 

        MOV !MOD_MAIN_TEMP_H, !MOD_CAR_PAGE
        MOV !MOD_MAIN_TEMP_L, A
        MOV Y, #$00
        MOV A, (!MOD_MAIN_TEMP_L)+Y
        MOV (!MOD_OUT_INDEX_L)+Y, A
        INC Y
        MOV A, (!MOD_MAIN_TEMP_L)+Y
        MOV (!MOD_OUT_INDEX_L)+Y, A
        INC !MOD_OUT_INDEX_L
        INC !MOD_OUT_INDEX_L
        INC !MOD_MOD_INDEX_L
        INC !MOD_MOD_INDEX_L
        MOV A, !MOD_OUT_INDEX_L
        BNE PhaseModulation_128_loop
    RET

PhaseModulation_32:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - Carrier page
    ;       $D1 - Modulator page
    ;       $D2 - Output page
    ;       $D3 - Modulation strength
    ;       $D4 - Modulation phase shift (for "detune")
    ;       $D5 - Subpages: ccmmoo--
    ;           cc - Carrier subpage
    ;           mm - Modulator subpage
    ;           oo - Output subpage
    ;   Temp variables:
    ;       $EA-EB - Output pointer
    ;       $EC-ED - Modulator pointer
    ;       $EE-EF - Main temp variable
    .Setup:
        MOV X, #$00
        MOV !MOD_OUT_INDEX_H, !MOD_OUT_PAGE
        MOV !MOD_MOD_INDEX_H, !MOD_MOD_PAGE
        MOV A, !MOD_MOD_PHASE_SHIFT ;
        ASL A                       ;
        AND A, #$3F                 ;
        MOV !MOD_MOD_INDEX_L, A     ;
        MOV A, !MOD_SUBPAGE         ;   Get low byte of modulator pointer
        ASL A                       ;
        ASL A                       ;
        AND A, #$C0                 ;
        PUSH A                      ;
        TSET !MOD_MOD_INDEX_L      ;__
        MOV A, !MOD_SUBPAGE         ;
        XCN A                       ;   Get low byte of output pointer
        AND A, #$C0                 ;
        MOV !MOD_OUT_INDEX_L, A     ;__
        CLRC                        ;
        ADC A, #$40                 ;   Get low ending byte of output pointer
        MOV !MOD_END_INDEX_L, A     ;__
        MOV A, !MOD_SUBPAGE         ;
        AND A, #$C0                 ;   Get low byte of carrier pointer to add later
        MOV !MOD_CAR_INDEX_L, A     ;__
    .loop:
        INC !MOD_MOD_INDEX_L
        MOV A, (!MOD_MOD_INDEX_L+X)
        MOV !MOD_MAIN_TEMP_H, A
        BMI PhaseModulation_32_loop_negative 
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOVW !MOD_MAIN_TEMP_L, YA

        DEC !MOD_MOD_INDEX_L
        MOV A, (!MOD_MOD_INDEX_L+X)
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOV A, Y
        CLRC
        ADC A, !MOD_MAIN_TEMP_L
        ADC !MOD_MAIN_TEMP_H, #$00
        JMP PhaseModulation_32_loop_afterMul
    .loop_negative:
        EOR A, #$FF
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOVW !MOD_MAIN_TEMP_L, YA

        DEC !MOD_MOD_INDEX_L
        MOV A, (!MOD_MOD_INDEX_L+X)
        EOR A, #$FF
        MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
        MUL YA
        MOV A, Y
        CLRC
        ADC A, !MOD_MAIN_TEMP_L
        ADC !MOD_MAIN_TEMP_H, #$00
        EOR A, #$FF
        EOR !MOD_MAIN_TEMP_H, #$FF
    .loop_afterMul:

        MOV A, !MOD_MAIN_TEMP_H
        ASL A
        CLRC
        ADC A, !MOD_OUT_INDEX_L 
        AND A, #$3E
        CLRC
        ADC A, !MOD_CAR_INDEX_L

        MOV !MOD_MAIN_TEMP_H, !MOD_CAR_PAGE
        MOV !MOD_MAIN_TEMP_L, A
        MOV Y, #$00
        MOV A, (!MOD_MAIN_TEMP_L)+Y
        MOV (!MOD_OUT_INDEX_L)+Y, A
        INC Y
        MOV A, (!MOD_MAIN_TEMP_L)+Y
        MOV (!MOD_OUT_INDEX_L)+Y, A
        INC !MOD_OUT_INDEX_L
        INC !MOD_OUT_INDEX_L
        INC !MOD_MOD_INDEX_L
        INC !MOD_MOD_INDEX_L
        AND !MOD_MOD_INDEX_L, #$3E
        POP A
        PUSH A
        CLRC 
        ADC A, !MOD_MOD_INDEX_L
        MOV !MOD_MOD_INDEX_L, A
        MOV A, !MOD_OUT_INDEX_L
        CMP A, !MOD_END_INDEX_L
        BNE PhaseModulation_32_loop
        POP A
    RET



ConvertToBRR:
    ;   Memory allocation:
    ;   Inputs:
    ;       $D0 - PCM sample page
    ;       $D1 - BRR output index
    ;       $D2 - Flags: fsi-ppbb 
    ;               f - whether to use filter mode 1
    ;               s - short sample mode (32 samples instead of 128)
    ;               i - high bit of output index 
    ;               pp - PCM sample subpage number (0-3, if s is set)
    ;               bb - BRR output subpage number (0-3, if s is set)
    ;   Temp variables:
    ;       $E5 - Temporary flags: bf-n----
    ;               b - whether it is the first block
    ;               f - whether to use filter mode 1
    ;               n - negative flag
    ;       $E6-$EB - 3 sample points
    ;       $F8-$F9 - Temporary space for 1 sample point
    ;       $EC-$ED - Input pointer
    ;       $EE-$EF - Output pointer
    .SetupFirstTime:
        SET7 !BRR_TEMP_FLAGS
        MOV !BRR_IN0_PTR_H, !BRR_PCM_PAGE;   Set up the PCM sample page
        MOV A, !BRR_FLAGS               ;__
        XCN A                           ;
        AND A, #$C0                     ;   Set up the PCM sample subpage 
        MOV !BRR_IN0_PTR_L, A           ;__
        MOV A, !BRR_FLAGS               ;
        AND A, #$40                     ;   Set up the ending low byte of the address
        CLRC                            ;
        ADC A, !BRR_IN0_PTR_L           ;__
        MOV !BRR_LSMPT_L, #$00          ;   
        MOV !BRR_LSMPT_H, #$00          ;__ smppoint = 0
        PUSH A
        PUSH A
        MOV Y, !BRR_OUT_INDEX           ;
        MOV A, !BRR_FLAGS               ;
        AND A, #$23                     ;   Get the sample pointer from index
        TCALL 11                        ;
        MOVW !BRR_OUT_PTR_L, YA         ;__

    .SetupCopy:
        MOV X, #$20                     ;__ Set up the destination address (it's (X+))
        MOV Y, #$00
    .CopyLoop:  ;Copy the PCM sample to the PCM buffer while halving it #
        MOV A, (!BRR_IN0_PTR_L)+Y       ;                               #
        MOV !BRR_CSMPT_L, A             ;                               #
        INCW !BRR_IN0_PTR_L             ;   Python code:                #
        MOV A, (!BRR_IN0_PTR_L)+Y       ;   currentsmppoint = array[i]  #
        MOV !BRR_CSMPT_H, A             ;                               #
        BPL +                           ;                               #
            EOR A, #$FF                 ;   Invert negative numbers     #
            EOR !BRR_CSMPT_L, #$FF      ;__                             #
        +:                              ;                               #
        INCW !BRR_IN0_PTR_L             ;__                             #
        CLRC                            ;   Python code:                #
        LSR A                           ;   currentsmppoint /= 2        #   OG Python code:
        ROR !BRR_CSMPT_L                ;__                             #   for i in range(len(BRRBuffer)):
        BBC7 !BRR_CSMPT_H, +            ;                               #       BRRBuffer[i] = (array[i&(length-1)])/2
            EOR A, #$FF                 ;   Invert negative numbers     #
            EOR !BRR_CSMPT_L, #$FF      ;__                             #
        +:                              ;                               #
        MOV !BRR_CSMPT_H, A             ;                               #
        MOV A, !BRR_CSMPT_L             ;                               #
        MOV (X+), A                     ;   Python code:                #
        MOV A, !BRR_CSMPT_H             ;   BRRBuffer[i]=currentsmppoint#
        MOV (X+), A                     ;                               #
        CMP X, #$40                     ;   Loop                        #
        BNE ConvertToBRR_CopyLoop   ;__                             #
    .SetupFilter
        BBS7 !BRR_TEMP_FLAGS, ConvertToBRR_FirstBlock;   If this is the first block, Or filter 0 is forced,
        BBS7 !BRR_FLAGS, ConvertToBRR_FirstBlock     ;Skip doing filter 1 entirely   
        MOV X, #$00


        CLR4 !BRR_TEMP_FLAGS
        MOV !BRR_SMPPT_L, !BRR_LSMPT_L  ;   OG Python code:
        MOV !BRR_SMPPT_H, !BRR_LSMPT_H  ;__ currentsmppoint = 0
        BBC7 !BRR_SMPPT_H, +        ;                                       #
            SET4 !BRR_TEMP_FLAGS        ;   Inverting negative numbers          #
            EOR !BRR_SMPPT_L, #$FF      ;                                       #
            EOR !BRR_SMPPT_H, #$FF      ;__     
        +:
        POP A
        MOV !BRR_CSMPT_H, A
        POP A
        MOV !BRR_CSMPT_L, A
        JMP ConvertToBRR_FilterLoop
    .FirstBlock:

        MOV !BRR_MAXM0_L, #$FF
        MOV !BRR_MAXM0_H, #$7F
        MOV X, #$20
        JMP ConvertToBRR_BRREncoding_OuterLoop
    .FilterLoop:
        MOV Y, !BRR_SMPPT_L         ;                                       #
        MOV A, $0D00+Y              ;                                       #
        BBS4 !BRR_TEMP_FLAGS, +     ;                                       #                        
            CLRC                    ;   Python code:                        #
            ADC A, !BRR_CSMPT_L     ;   currentsmppoint += smppoint_L*15/16 #
            MOV !BRR_CSMPT_L, A     ;   (for positive numbers)              #
            ADC !BRR_CSMPT_H, #$00  ;                                       #
            JMP ++                  ;__                                     #
        +:                          ;                                       #
            EOR A, #$FF             ;                                       #
            SETC                    ;   Python code:                        #
            ADC A, !BRR_CSMPT_L     ;   currentsmppoint += smppoint_L*15/16 #
            MOV !BRR_CSMPT_L, A     ;   (for negative numbers)              #
            SBC !BRR_CSMPT_H, #$00  ;__                                     #
        ++:                         ;                                       #   OG Python code:
        MOV A, !BRR_SMPPT_H         ;                                       #   smppoint *= 0.9375
        MOV Y, #$F0                 ;   Python code:                        #   smppoint += BRRBuffer[i]
        MUL YA                      ;__ smpppoint_H *=15                    #
        BBC4 !BRR_TEMP_FLAGS, +     ;                                       #
            MOV !BRR_SMPPT_H, Y     ;   Invert negative                     #
            EOR A, #$FF             ;                                       #
            EOR !BRR_SMPPT_H, #$FF  ;__                                     #
            MOV Y, !BRR_SMPPT_H     ;                                       #
        +:                          ;   Python code:                        #
        ADDW YA, !BRR_CSMPT_L       ;   smppoint_H<<8 += currentsmppoint    #
        MOVW !BRR_SMPPT_L, YA       ;__                                     #__



        CLR4 !BRR_TEMP_FLAGS
        MOV A, !BRR_BUFF1_PTR_L+X   ;                                       #
        MOV !BRR_CSMPT_L, A         ;                                       #
        MOV A, !BRR_BUFF1_PTR_H+X   ;   currentsmppoint = BRRBuffer[i]      #
        MOV !BRR_CSMPT_H, A         ;                                       #
        MOVW YA, !BRR_CSMPT_L       ;   Python code:                        #   OG Python code:
        SUBW YA, !BRR_SMPPT_L       ;   currentsmppoint -= smppoint         #   BRRBuffer[i] -= smppoint
        MOVW !BRR_CSMPT_L, YA       ;__                                     #
        MOV (X+), A   ;                                       #
        MOV A, !BRR_CSMPT_H         ;   BRRBuffer[i] = currentsmppoint      #
        MOV (X+), A   ;__                                     #
        BBC7 !BRR_SMPPT_H, +        ;                                       #
        SET4 !BRR_TEMP_FLAGS        ;   Inverting negative numbers          #
        EOR !BRR_SMPPT_L, #$FF      ;                                       #
        EOR !BRR_SMPPT_H, #$FF      ;__                                     #
        +   CMP X, #$20             ;   Loop                                #
        BNE ConvertToBRR_FilterLoop;__ 
        MOV !BRR_LSMPT_L, !BRR_SMPPT_L
        MOV !BRR_LSMPT_H, !BRR_SMPPT_H
        BBC4 !BRR_TEMP_FLAGS, ConvertToBRR_BRREncoding
        EOR !BRR_LSMPT_L, #$FF
        EOR !BRR_LSMPT_H, #$FF
        CLR4 !BRR_TEMP_FLAGS

    .BRREncoding:
        SET6 !BRR_TEMP_FLAGS
        MOV X, #$00
        ..OuterLoop:
            MOV A, (X+)   
            MOV !BRR_SMPPT_L, A         
            MOV A, (X+)
            BPL +
                EOR !BRR_SMPPT_L, #$FF
                EOR A, #$FF
            +:
            MOV !BRR_SMPPT_H, A         
        ..MaximumFilter1:
            MOV A, (X+)  
            MOV !BRR_CSMPT_L, A         
            MOV A, (X+)  
            BPL +
                EOR !BRR_CSMPT_L, #$FF
                EOR A, #$FF
            +:
            MOV Y, A
            MOV A, !BRR_CSMPT_L
            CMPW YA, !BRR_SMPPT_L
            BMI +
                MOVW !BRR_SMPPT_L, YA
            +:
            MOV A, X
            AND A, #$1F
            BNE ConvertToBRR_BRREncoding_MaximumFilter1
            CMP X, #$40
            BEQ +
                MOVW YA, !BRR_SMPPT_L
                MOVW !BRR_MAXM0_L, YA
                ;Set up the routine for maximum in the OG PCM buffer
                JMP  ConvertToBRR_BRREncoding_OuterLoop
            +:
                MOV X, #$00
                MOVW YA, !BRR_SMPPT_L
                CMPW YA, !BRR_MAXM0_L
                BPL ConvertToBRR_BRREncoding_ShiftValuePart1
                MOVW !BRR_MAXM0_L, YA
                MOV X, #$20
                CLR6 !BRR_TEMP_FLAGS
        ..ShiftValuePart1:
            MOV Y, #12
            MOV A, !BRR_MAXM0_H
            BEQ +
            -:
                ASL A
                BCS ConvertToBRR_BRREncoding_CheckIf8
                DEC Y
                CMP Y, #$04
                BNE -
            +
                MOV Y, #$04
        ..ShiftValuePart2:
            MOV A, !BRR_MAXM0_L
            CLRC
            -:
                ASL A
                BCS ConvertToBRR_BRREncoding_CheckIf8
                DEC Y
                BNE -
            JMP ConvertToBRR_FormHeader
        ..CheckIf8:
            CMP Y, #$05
            BEQ +
            CMP Y, #$06
            BNE ConvertToBRR_BRREncoding_Check8
            ; Executed if Y = 6, aka the high bit to check is in the high byte and the low bit is in low byte
            BBS0 !BRR_MAXM0_H, ConvertToBRR_FormHeader
            BBS7 !BRR_MAXM0_L, ConvertToBRR_FormHeader
            JMP ++
            +   MOV A, !BRR_MAXM0_L ;Executed if Y = 5, aka both bits to check are in the low byte
            ..Check8:   ;Executed if Y = 1..4 or Y = 7..12 - aka the bits to check are in the same byte
            ASL A
            BCS ConvertToBRR_FormHeader
            ASL A
            BCC ++      ; = BCS FormHeader; JMP +
    .FormHeader:
            INC Y
        ++:
            MOV !BRR_MAXM0_L, Y ;
            MOV A, Y            ;   Get the shift value
            OR A, #%00100000    ;   Set the loop flag
            POP Y               ;   Get the ending low byte
            CMP Y, !BRR_IN0_PTR_L
            BNE +               ;   Set the end flag if it's the last block
            OR A, #%00010000    ;__
        +:
            MOV !BRR_MAXM0_H, !BRR_TEMP_FLAGS;   Set the filter to 1
            AND !BRR_MAXM0_H, #%01000000    ;   if appropriate
            OR A, !BRR_MAXM0_H              ;__
            XCN A                           ;__ Swap the nybbles to make a valid header
            MOV Y, #$00                     ;
            MOV (!BRR_OUT_PTR_L)+Y, A       ;   Write the header out
            INCW !BRR_OUT_PTR_L             ;__
    .FormData:
        CLR4 !BRR_TEMP_FLAGS
        MOV A, (X+)
        MOV !BRR_CSMPT_L, A
        MOV A, (X+)
        BPL +
            EOR A, #$FF
            EOR !BRR_CSMPT_L, #$FF
            SET4 !BRR_TEMP_FLAGS
        +:
        MOV !BRR_CSMPT_H, A ;
        MOV Y, !BRR_CSMPT_L ;
        MOV A, $0C00+Y      ;
        MOV !BRR_CSMPT_L, A ;
        MOV Y, !BRR_CSMPT_H ;
        MOV A, #$E0         ;   7/8 multiplication
        MUL YA              ;
        MOV !BRR_CSMPT_H, Y ;
        CLRC                ;
        ADC A, !BRR_CSMPT_L ;
        MOV !BRR_CSMPT_L, A ;__
        MOV A, !BRR_CSMPT_H
        AND A, #$7F
        MOV Y, !BRR_MAXM0_L
        CMP Y, #$05
        BMI +
            -:
                CLRC
                LSR A
                ROR !BRR_CSMPT_L
                DEC Y
                CMP Y, #$04
                BNE -
        +:
            MOV A, !BRR_CSMPT_L
            CMP Y, #$00
            BEQ +
            -:
                CLRC
                LSR A
                DEC Y
                BNE -
        +:
            AND A, #$07
            ADC A, #$00
            CMP A, #$08
            BMI +
            MOV A, #$07
        +   BBC4 !BRR_TEMP_FLAGS, +
            EOR A, #$0F
            INC A
            CMP A, #$10
            BMI +
            DEC A
        +   PUSH A
        MOV A, X
        AND A, #$03
        BNE ConvertToBRR_FormData
        .SecondNybble:
            POP A
            MOV !BRR_CSMPT_L, A
            POP A
            XCN A
            OR A, !BRR_CSMPT_L
            MOV (!BRR_OUT_PTR_L)+Y, A       ;   Write the data out
            INCW !BRR_OUT_PTR_L             ;__
            MOV A, X
            AND A, #$1F
            BNE ConvertToBRR_FormData
    .AfterEncoding:
        CLR7 !BRR_TEMP_FLAGS
        POP A                           ;
        CMP A, !BRR_IN0_PTR_L           ;   If this is the last block, end
        BEQ ConvertToBRR_End        ;__
        PUSH A                          ;   If it ain't, push the finishing low byte back
        PUSH A                          ;__      
        BBS7 !BRR_FLAGS, ++             ;
        +   CMP X, #$20                     ;   
            BNE +                           ;   If we just used filter mode 1, 
            MOV A, $1E                      ;
            PUSH A                          ;   currentsmppoint = BRRBuffer[last]
            MOV A, $1F                      ;
            PUSH A                          ;__
        ++  JMP ConvertToBRR_SetupCopy
        +:                                  ;   If we just used filter mode 0,   
            MOV !BRR_LSMPT_L, $3E           ;   smppoint = BRRBuffer[last]
            MOV !BRR_LSMPT_H, $3F           ;__
            MOV A, #$00                     ;
            PUSH A                          ;   currentsmppoint = 0
            PUSH A                          ;__
            JMP ConvertToBRR_SetupCopy
    .End:
    RET
;

transferChToTemp:       ;TCALL 15
    PUSH A
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$07
    MOV X, A
    -:
        MOV A, $00+X
        DEC X
        MOV !CHTEMP_POINTER_0+Y, A
        DBNZ Y, -
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$08
    MOV X, A
    -:
        MOV A, $40+X
        DEC X
        MOV !CHTEMP_POINTER_1+Y, A
        DBNZ Y, -
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$08
    MOV X, A
    -:
        MOV A, $80+X
        DEC X
        MOV !CHTEMP_POINTER_2+Y, A
        DBNZ Y, -
    INC X
    POP A
    RET

transferTempToCh:       ;TCALL 14
    PUSH A
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$07
    MOV X, A
    -:
        MOV.b A, !CHTEMP_POINTER_0+Y
        MOV.b $00+X, A
        DEC X
        DBNZ Y, -
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$08
    MOV X, A
    -:
        MOV.b  A, !CHTEMP_POINTER_1+Y
        MOV.b $40+X, A
        DEC X
        DBNZ Y, -
    MOV Y, #$08
    MOV A, X
    CLRC
    ADC A, #$08
    MOV X, A
    -:
        MOV.b  A, !CHTEMP_POINTER_2+Y
        MOV.b $80+X, A
        DEC X
        DBNZ Y, -
    INC X
    POP A
    RET

SetFlagdp:              ;TCALL 13
    .Setup:
        MOV A, X
        ASL A
        ASL A
        AND A, #$E0
        OR A, #$02
        MOV SetFlagdp_act, A
        MOV A, $D0
        MOV SetFlagdp_act+1, A
    .act:
        SET1 $00
        RET

ClrFlagdp:              ;TCALL 12
    .Setup:
        MOV A, X
        ASL A
        ASL A
        AND A, #$E0
        OR A, #$12
        MOV ClrFlagdp_act, A
        MOV A, $D0
        MOV ClrFlagdp_act+1, A
    .act:
        CLR1 $00
        RET


IndexToSamplePointer:   ;TCALL 11
    ;   Memory allocation:
    ;   Inputs:
    ;       Y - Sample index
    ;       A - hhhhhhll
    ;           h - High bit of page (if at least one is set, it is considered to be set)
    ;           ll - Subpage index
    ;   Outputs:
    ;       YA - Sample pointer
    ;   Memory:
    ;       $EE-$EF - Temp variable
    ;   Stack usage:
    ;       2 entries (+ 2 calling the subroutine)
        PUSH A                      ;
        PUSH A                      ;
        MOV A, #$48                 ;   Use main byte of index
        MUL YA                      ;
        MOVW $EE, YA                ;
        POP A                       ;__
        AND A, #$03                 ;
        MOV Y, A                    ;   Set up the BRR sample subpage
        MOV A, IndexToSamplePointer_LookuptableMul18+Y
        MOV Y, #$00                 ;
        ADDW YA, $EE                ;
        MOVW $EE, YA                ;__
        POP A                       ;
        AND A, #$FC                 ;
        BEQ +                       ;   Apply the high bit
        CLRC                        ;
        ADC $EF, #$48               ;__
    +:                              ;
        CLRC                        ;   Actually make it a valid pointer
        ADC $EF, #$60               ;__
        MOVW YA, $EE                ;   Return with pointer in YA
    RET                             ;__
    .LookuptableMul18:
    db $00, $12, $24, $36

Includes:
    org $0C00
        incbin "lookuptables.bin"
    org $0E00
        incbin "pitchtable.bin"
    org $0EC0   ;Dummy empty sample
        db $03, $00, $00, $00, $00, $00, $00, $00, $00
        dw PatternData
    org $0F00
        incbin "quartersinetable.bin"
    org $1000
        ; Song data
        incsrc "songData.asm"
    org $0A00
        ;instrument data pointers
        db Instr00Data&$FF, Instr01Data&$FF, Instr02Data&$FF, Instr03Data&$FF
    org $0B00
        db (Instr00Data>>8)&$FF, (Instr01Data>>8)&$FF, (Instr02Data>>8)&$FF, (Instr03Data>>8)&$FF
    org $FFC0   ;For TCALLs
        dw transferChToTemp, transferTempToCh, SetFlagdp, ClrFlagdp, IndexToSamplePointer
startpos Init

namespace off
