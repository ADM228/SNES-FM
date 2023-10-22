arch spc700-inline

namespace nested on
namespace SPC

warnings disable W1008
Configuration:
    ; SNESFM can be configured in 2 different ways:
        ;
        ; 1. Right here, in the configuration section - just 
        ; comment/uncomment the defines below to disable/enable features.
        ;
        ; 2. Externally, by specifying the defines somewhere else
        ; in your project. To use it, define !SNESFM_CFG_EXTERNAL=1
        ; and specify the defines before including SNESFM. The demo
        ; ROM uses this.
        ;__
        ;
    ; There are several configuration sections:
        ; 1. Features of instrument generation
        ;__

    !SNESFM_CFG_EXTERNAL ?= 0

    if !SNESFM_CFG_EXTERNAL == 0

    ;========== 1. Features of instrument generation ==========

        ; Whether to generate samples at all - the main gimmick
        ; of this sound driver. Disabling this will disable all
        ; sample generation capabilities and automatically
        ; enable the ability to supply custom samples within
        ; instrument data, which you will have to do.
        !SNESFM_CFG_SAMPLE_GENERATE = 1

        ; Whether to generate phase modulated instruments - 
        ; just like on Yamaha chips. Not to be confused with
        ; hardware pitch modulation.
        !SNESFM_CFG_PHASEMOD = 1

        ; Whether to generate pulse wave samples.
        !SNESFM_CFG_PULSEGEN = 1

        ; Whether to generate long samples (128 sample points
        ; long, good for higher quality in bass).
        !SNESFM_CFG_LONG_SMP_GEN = 1

        ; Whether to generate short samples (32 sample points
        ; long, the only way to get high pitched instruments).
        !SNESFM_CFG_SHORTSMP_GEN = 1

        ; Whether to be able to include custom samples from
        ; instrument data. Automatically set if you don't set
        ; it while disabling sample generation.
        !SNESFM_CFG_INSDATA_CUSTOM_SAMPLES = 1

        ; Amount of space for repeating opcode parameters in 
        ; the instrument generation routine. Lesser values will
        ; slightly reduce code size and execution time at the
        ; cost of possibly increasing the size of instrument 
        ; data. Can range from 0 to 4. Should be supplied by
        ; the tool that compiled the instrument data. 
        !SNESFM_CFG_INSGEN_REPEAT_AMOUNT = 4

        ; Amount of space for doing arithmetic opcode
        ; parameters in the instrument generation routine.
        ; Lesser values will slightly reduce code size and
        ; execution time at the cost of possibly increasing the
        ; size of instrument data. Can range from 0 to 4.
        ; Should be supplied by the tool that compiled the
        ; instrument data. 
        !SNESFM_CFG_INSGEN_ARITHMETIC_AMOUNT = 4

        ; Whether to generate pitch tables on the SPC700 itself.
        ; If disabled, you will be responsible for supplying the
        ; pitch table yourself (at location $0E00 - $0EBF, the
        ; first 96 bytes being low bytes and the last 96 being
        ; high bytes, the topmost note is a B7, close to the max
        ; pitch on the SNES).
        !SNESFM_CFG_PITCHTABLE_GEN = 1

    endif
Documentation:
	;   ==== Code/data distribution table: ====
		;   Page		Purpose
        ;   $00			$20 - $3F: Temporary storage of flags, counters and pointers for note stuff
        ;               $40 - $4F: Communicating with S-CPU stuff
        ;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
        ;   $01 _ _ _ _ Stack
        ;   $02 _ _ _ _ Sample Directory
        ;   $03			$00 - $7F: Effect IDs
        ;   |__ _ _ _ _ $80 - $FF: Basic effect time counters
        ;   $04-$07 _ _ Effect q
        ;   $08 _ _ _ _ Permanent storage of flags, counters and pointers for note stuff
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
        ;   $1  |    |           |           |   Start sending data
        ;   $2  |    |           |           |   Got the data
        ;   $3  |    |           |           |   Have started compiling instruments
        ;   $4  |     20-bit tick counter    |   Currently playing song, here's what tick it is
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
        ;   $9  |    |    16 bits of data    |   Get a load of this data
        ;   $A  |    |           |           |   Data transfer finished
        ;   $F  |    |           |           |   What? 
    ;   Sound engine documentation:
        ;   Channel flags: n00af0ir
        ;   n - sample number (0 or 1)
        ;   a - whether to disable the attack
        ;   f - whether to reset the instrument
        ;   i - whether to not parse instrument data
        ;   r - whether a reference is in effect
InternalDefines:
    ;Song data variables for more readability when assembling manually
        ;Instrument data
            ;   Instrument types
                !SAMPLE_USE_ADDRESS = %00001000
                !ENVELOPE_TYPE_ADSR = %00000010
    ;Pointers to channel 1's variables (permanent storage during song playback)
        !CH1_SONG_POINTER_L = $0800
        !CH1_SONG_POINTER_H = $0801

        !CH1_INSTRUMENT_INDEX = $0804
        !CH1_INSTRUMENT_TYPE = $0805
        !CH1_SAMPLE_POINTER_L = $0806
        !CH1_SAMPLE_POINTER_H = $0807

        !CH1_SONG_COUNTER = $0840
        !CH1_EFFECT_COUNTER = $0841
        !CH1_EFFECT_AMOUNT = $0842
        ;$43 and $44 will be used by pitchbend
        !CH1_ARPEGGIO = $0845
        !CH1_NOTE = $0846
        !CH1_FLAGS = $0847

        !CH1_INSTRUMENT_TYPE_COUNTER = $0880
        !CH1_ENVELOPE_COUNTER = $0881
        !CH1_SAMPLE_POINTER_COUNTER = $0882
        !CH1_ARPEGGIO_COUNTER = $0883
        !CH1_PITCHBEND_COUNTER = $0884
        !CH1_COUNTERS_HALT = $0887

        !CH1_INSTRUMENT_TYPE_POINTER = $08C0
        !CH1_ENVELOPE_POINTER = $08C1
        !CH1_SAMPLE_POINTER_POINTER = $08C2
        !CH1_ARPEGGIO_POINTER = $08C3
        !CH1_PITCHBEND_POINTER = $08C4
        !CH1_COUNTERS_DIRECTION = $08C7
    ;Pointers for temporary <-> permanent storage transfers
        CHTEMP_POINTER_0 = $20
        CHTEMP_POINTER_1 = $28
        CHTEMP_POINTER_2 = $30
        CHTEMP_POINTER_3 = $38

        CH1_POINTER_0 = $0800
        CH1_POINTER_1 = $0840
        CH1_POINTER_2 = $0880
        CH1_POINTER_3 = $08C0

    ;Internal configuration

        !SNESFM_CFG_SAMPLE_GENERATE ?= 0

        !SNESFM_CFG_PHASEMOD ?= 0
        !SNESFM_CFG_PULSEGEN ?= 0

        !SNESFM_CFG_LONG_SMP_GEN ?= 0
        !SNESFM_CFG_SHORTSMP_GEN ?= (!SNESFM_CFG_SAMPLE_GENERATE)&~(!SNESFM_CFG_LONG_SMP_GEN)

        !SNESFM_CFG_BOTH_SMP_GEN ?= (!SNESFM_CFG_LONG_SMP_GEN)&(!SNESFM_CFG_SHORTSMP_GEN)

        !SNESFM_CFG_PITCHTABLE_GEN ?= 0

        !SNESFM_CFG_INSGEN_REPEAT_AMOUNT ?= 0
        !SNESFM_CFG_INSGEN_ARITHMETIC_AMOUNT ?= 0

        ; if !SNESFM_CFG_SAMPLE_GENERATE && ( ~(!SNESFM_CFG_LONG_SMP_GEN+!SNESFM_CFG_SHORTSMP_GEN) )
        ;     error "You have specified to generate samples, but have specified to not generate short nor long samples. Pick one"
        ; endif

    ;Temporary channel pointers during song playback

        CHTEMP_SONG_POINTER_L = $20
        CHTEMP_SONG_POINTER_H = $21
        CHTEMP_REF0_POINTER_L = $22
        CHTEMP_REF0_POINTER_H = $23
        CHTEMP_INSTRUMENT_INDEX = $24
        CHTEMP_INSTRUMENT_TYPE = $25
        CHTEMP_SAMPLE_POINTER_L = $26
        CHTEMP_SAMPLE_POINTER_H = $27

        CHTEMP_SONG_COUNTER = $28
        CHTEMP_REF0_COUNTER = $29
        ;CHTEMP_EFFECT_AMOUNT = $2A
        ;$2B and $2C will be used by pitchbend
        CHTEMP_ARPEGGIO = $2D
        CHTEMP_NOTE = $2E
        CHTEMP_FLAGS = $2F

        CHTEMP_MACRO_COUNTERS = $30
        CHTEMP_INSTRUMENT_TYPE_COUNTER = $30
        CHTEMP_ENVELOPE_COUNTER = $31
        CHTEMP_SAMPLE_POINTER_COUNTER = $32
        CHTEMP_ARPEGGIO_COUNTER = $33
        CHTEMP_PITCHBEND_COUNTER = $34
        CHTEMP_COUNTERS_HALT = $37     ;000paset

        CHTEMP_MACRO_POINTERS = $38
        CHTEMP_INSTRUMENT_TYPE_POINTER = $38
        CHTEMP_ENVELOPE_POINTER = $39
        CHTEMP_SAMPLE_POINTER_POINTER = $3A
        CHTEMP_ARPEGGIO_POINTER = $3B
        CHTEMP_PITCHBEND_POINTER = $3C
        CHTEMP_COUNTERS_DIRECTION = $3F   ;000paset

        CHTEMP_INSTRUMENT_SECTION_HIGHBITS = $35


    ;Just global variables used in song playback
        !TEMP_VALUE = $00
        !TIMER_VALUE = $01
        !CHANNEL_REGISTER_INDEX = $02
        !CHANNEL_BITMASK = $03
        !TEMP_VALUE2 = $06
        !TEMP_POINTER0_L = $0C
        !TEMP_POINTER0_H = $0D
        !TEMP_POINTER1_L = $0E
        !TEMP_POINTER1_H = $0F

    ; S-CPU communication
        MESSAGE_CNT_TH1 = $40

    ; Instrument generation
        OPCODE_ARGUMENT = $50
        REPEAT_BITMASK  = $58
        REPEAT_COUNTER  = $5C

        INSDATA_PTR_L   = $60
        INSDATA_PTR_H   = $61
        INSBLOCK_PTR_L  = $62
        INSBLOCK_PTR_H  = $63

        INSDATA_OPCODE  = $64
        
        INSDATA_INS_CNT     = $69
        INSDATA_TMP_CNT     = $6A
        INSDATA_TMP_VALUE   = $6B
        INSDATA_TMP_PTR_0_L = $6C
        INSDATA_TMP_PTR_0_H = $6D
        INSDATA_TMP_PTR_1_L = $6E
        INSDATA_TMP_PTR_1_H = $6F

warnings enable W1008
;

org $5000
Init:       ;init routine, totally not grabbed from tales of phantasia
    CLRP
    MOV A, #$00     ;__
    MOV $F4, A      ;
    MOV $F5, A      ;
    MOV $F6, A      ;   Clear the in/out ports with the SNES, disable timers
    MOV $F7, A      ;
    MOV MESSAGE_CNT_TH1, A
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
    ;MOV $FA, #$85   ;   Set Timer 0 to 16.625 ms (~60 Hz)
    MOV $FA, #$50   ;   Set Timer 0 to 10 ms     (100 Hz)
    ;MOV $FA, #$A0   ;   Set Timer 0 to 20 ms     (50 Hz)
    ;MOV $FA, #$FF   ;   Set Timer 0 to 31.875 ms (~31 Hz)
    MOV $F1, #$07   ;__

if !SNESFM_CFG_PITCHTABLE_GEN >= 1
    MOV A, #$7D
    MOV Y, #$21
    CALL GeneratePitchTable_Start
endif

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
    -:
        MOV $0300+Y, A
        DBNZ Y, -

RAMClear:
    MOV A, Y
    -:
        MOV $0800+Y, A
		MOV $0200+Y, A
        DBNZ Y, -


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

    MOV MESSAGE_CNT_TH1, #$01
    MOV TDB_OUT_PTR_L, #$00
    MOV TDB_OUT_PTR_H, #$10
    CALL TransferDataBlock

namespace CompileInstruments
    Start:
        MOV Y, #$00
        MOV INSDATA_PTR_L, Y
        MOV INSDATA_PTR_H, #$10

        if !SNESFM_CFG_SAMPLE_GENERATE >= 1

        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
            MOV REPEAT_BITMASK+0, Y
            MOV REPEAT_COUNTER+0, Y
        endif
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
            MOV REPEAT_BITMASK+1, Y
            MOV REPEAT_COUNTER+1, Y
        endif
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
            MOV REPEAT_BITMASK+2, Y
            MOV REPEAT_COUNTER+2, Y
        endiF
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
            MOV REPEAT_BITMASK+3, Y
            MOV REPEAT_COUNTER+3, Y
        endif

        endif   ; !SNESFM_CFG_SAMPLE_GENERATE

    ReadByte:
        MOV A, (INSDATA_PTR_L)+Y
        INCW INSDATA_PTR_L

        if !SNESFM_CFG_SAMPLE_GENERATE >= 1

        MOV INSDATA_OPCODE, A
        AND A, #$1F
        MOV X, A
        MOV A, ArgCountTable+X
        MOV INSDATA_TMP_CNT, A
        BEQ Jump
        AND A, INSDATA_OPCODE
        BPL +   ; If bit 7 is set in both the counter and the opcode it has 1 less argument
            INC INSDATA_TMP_CNT
        +
        AND INSDATA_TMP_CNT, #$7F

        CLRC
        ADC INSDATA_TMP_CNT, #OPCODE_ARGUMENT

        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
            CALL RepeatBitmask
        endif

        MOV X, #OPCODE_ARGUMENT


    GetArguments:
        MOV A, (INSDATA_PTR_L)+Y
        ASL INSDATA_TMP_VALUE
        BCS +
            MOV (X), A
            INCW INSDATA_PTR_L
        + INC X
        CMP X, INSDATA_TMP_CNT
        BNE GetArguments

    Jump:
        MOV A, INSDATA_OPCODE

        endif   ; !SNESFM_CFG_SAMPLE_GENERATE

        CALL +
        JMP ReadByte
    +

        AND A, #$1F
        ASL A
        MOV X, A

        if !SNESFM_CFG_SAMPLE_GENERATE >= 1
            JMP (JumpTable+X)
        else
            JMP (JumpTable-($1D*2)+X)
        endif


    if !SNESFM_CFG_SAMPLE_GENERATE >= 1

    ArgCountTable:
        fillbyte $00
        db $02, $00, $00, $03
        fill ($1A-1-$03)
        db $83, $00, $00, $00, $00, $00 

    endif   ; !SNESFM_CFG_SAMPLE_GENERATE

    JumpTable:
        fillword RETJump
        if !SNESFM_CFG_SAMPLE_GENERATE >= 1
            dw CopyResample
            if !SNESFM_CFG_PHASEMOD >= 1
                dw PhaseModPart1, PhaseModPart2
            else
                fill 2*2
            endif

            if !SNESFM_CFG_PULSEGEN >= 1
                dw PulseGen
            else
                fill 2*1
            endif
            fill ($1A-1-$03)*2
            dw BRRGen
            dw RETJump, ConserveArgs
        endif
        dw NewInstrument, InstrumentRawDataBlock, End

    if !SNESFM_CFG_SAMPLE_GENERATE >= 1

    if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
    RepeatBitmask:
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
            MOV A, REPEAT_BITMASK+0
            OR  A, REPEAT_BITMASK+1
            if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
                OR  A, REPEAT_BITMASK+2
                if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
                    OR  A, REPEAT_BITMASK+3
                endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
            endif ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
            MOV INSDATA_TMP_VALUE, A
        else    ; if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT == 1, then just copy the value
            MOV INSDATA_TMP_VALUE, REPEAT_BITMASK+0
        endif ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2 

        DEC REPEAT_COUNTER+0
        BNE +
            MOV REPEAT_BITMASK+0, Y
        +:
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
            DEC REPEAT_COUNTER+1
            BNE +
                MOV REPEAT_BITMASK+1, Y
            +:
        endif
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
            DEC REPEAT_COUNTER+2
            BNE +
                MOV REPEAT_BITMASK+2, Y
            +:
        endif
        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
            DEC REPEAT_COUNTER+3
            BNE +
                MOV REPEAT_BITMASK+3, Y
            +:
        endif
        RET
    endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1

    CopyResample:
        MOV A, INSDATA_OPCODE
        BMI CopyResample_Resample
        MOV A, OPCODE_ARGUMENT+0        ;   Self-modifying code is
        MOV CopyResample_CopyLoop+2, A  ;   faster than (dp)+Y
        MOV A, OPCODE_ARGUMENT+1        ;   (8 cycles vs 2*256 cycles)
        MOV CopyResample_CopyLoop+4, A  ;__

        .CopyLoop:
            MOV A, $4000+Y
            MOV $4000+Y, A
            DBNZ Y, CopyResample_CopyLoop
        RET

        .Resample:
            ASL A
            AND A, #$C0
            MOV LTS_OUT_SUBPAGE, A
            MOVW YA, OPCODE_ARGUMENT+0
            MOVW LTS_IN_PAGE, YA
            CALL SPC_LongToShort
            RET

    CopyArguments:
        MOV A, (X+)
        MOV $D0-OPCODE_ARGUMENT-1+X, A
        CMP X, INSDATA_TMP_CNT
        BNE CopyArguments
    RET

    if !SNESFM_CFG_PHASEMOD >= 1
    PhaseModPart1:      
        MOV INSDATA_TMP_CNT, #OPCODE_ARGUMENT+5
        MOV A, INSDATA_OPCODE
        BPL +   ; If bit 7 is set in both the counter and the opcode it has 1 less argument
            INC INSDATA_TMP_CNT
        +
        INC INSDATA_OPCODE

        if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
            CALL RepeatBitmask
        endif

        MOV X, #OPCODE_ARGUMENT+2

        ASL INSDATA_TMP_VALUE
        BCS +
            MOV A, (INSDATA_PTR_L)+Y
            MOV OPCODE_ARGUMENT+0, A
            INCW INSDATA_PTR_L
        + 
        ASL INSDATA_TMP_VALUE
        BCS ++
            MOV A, OPCODE_ARGUMENT+0
            BBS6 INSDATA_OPCODE, +   ; Bit 6 is set, copy modulator from carrier
                MOV A, (INSDATA_PTR_L)+Y
                INCW INSDATA_PTR_L
            + MOV OPCODE_ARGUMENT+1, A
        ++ JMP GetArguments

    PhaseModPart2:
        MOV X, #OPCODE_ARGUMENT
        CALL CopyArguments
        if !SNESFM_CFG_BOTH_SMP_GEN >= 1
            BBS7 INSDATA_OPCODE, +
                CALL SPC_PhaseModulation_128
                MOV Y, #$00
                RET
            +   CALL SPC_PhaseModulation_32
                MOV Y, #$00
                RET
        elseif !SNESFM_CFG_LONG_SMP_GEN >= 1
            CALL SPC_PhaseModulation_128
            MOV Y, #$00
            RET
        else
            CALL SPC_PhaseModulation_32
            MOV Y, #$00
            RET
        endif
    endif   ; !SNESFM_CFG_PHASEMOD

    if !SNESFM_CFG_PULSEGEN >= 1
    PulseGen: 
        MOV X, #OPCODE_ARGUMENT
        CALL CopyArguments

        if !SNESFM_CFG_BOTH_SMP_GEN >= 1
            MOV A, INSDATA_OPCODE
            BMI +
        endif
        if !SNESFM_CFG_BOTH_SMP_GEN+!SNESFM_CFG_LONG_SMP_GEN >= 1
                CALL SPC_GeneratePulse_128
                DEC Y   ; Y is always 1
                RET
        endif
        if !SNESFM_CFG_BOTH_SMP_GEN >= 1
            +:
        endif
        if !SNESFM_CFG_BOTH_SMP_GEN+!SNESFM_CFG_SHORTSMP_GEN >= 1
                MOV A, Y    ; 0
                LSR PUL_DUTY
                ROL PUL_FLAGS
                ADC A, #$00
                ASL A
                LSR PUL_DUTY
                ROL PUL_FLAGS
                ADC A, #$00
                AND PUL_FLAGS, #$FC
                TSET PUL_FLAGS, A

                MOV A, INSDATA_OPCODE
                ASL A
                AND A, #$C0
                TSET PUL_DUTY, A

                CALL SPC_GeneratePulse_32
                DEC Y
                RET
        endif
    endif   ; !SNESFM_CFG_PULSEGEN

    BRRGen: 
        MOV X, #OPCODE_ARGUMENT
        CALL CopyArguments
        BBC7 INSDATA_OPCODE, +  ;   Ironically this takes the same cycles as MOV1
            OR BRR_FLAGS, #$10  ;__ when it sets the bit, and 3 less if it doesn't
        + CALL SPC_ConvertToBRR
        RET

    ConserveArgs: 
        MOV A, INSDATA_OPCODE   ;
        XCN A                   ;
        LSR A                   ;   Get pointer into dp
        AND A, #$03             ;
        MOV X, A                ;__
        
        MOV A, (INSDATA_PTR_L)+Y
        MOV REPEAT_BITMASK+X, A
        INCW INSDATA_PTR_L

        MOV A, (INSDATA_PTR_L)+Y
        MOV REPEAT_COUNTER+X, A
        INCW INSDATA_PTR_L
        RET
    endif   ; !SNESFM_CFG_SAMPLE_GENERATE

    NewInstrument:
        ; Adjust pointer
        MOV A, #$EA     ;   Constant #$FFDE = -22
        DEC Y           ;__
        ADDW YA, INSDATA_TMP_PTR_0_L    ;
        MOVW INSDATA_TMP_PTR_0_L, YA    ;__ Get pointer
        MOV ByteTransferLoop+4, A       ;   Store it into lo byte of 2nd MOV
        MOV ByteTransferLoop+5, Y       ;__ Store it into hi byte of 2nd MOV
        MOV X, INSDATA_INS_CNT          ;
        MOV InstrumentPtrLo+X, A        ;
        MOV A, Y                        ;   Store it in instrument table 
        MOV InstrumentPtrHi+X, A        ;
        INC INSDATA_INS_CNT             ;__

        MOVW YA, INSDATA_PTR_L
        MOV ByteTransferLoop+1, A   ; Lo byte of 1st MOV
        MOV ByteTransferLoop+2, Y   ; Hi byte of 1st MOV

        MOV Y, #22-1
        CALL ByteTransferLoop
        ; Y is 0 after DBNZ
        MOV A, (INSDATA_PTR_L)+Y
        MOV (INSDATA_TMP_PTR_0_L)+Y, A

        MOV A, #22
        ADDW YA, INSDATA_PTR_L
        MOVW INSDATA_PTR_L, YA

        MOV Y, #$00

        RET

        
    InstrumentRawDataBlock:
        MOV A, (INSDATA_PTR_L)+Y
        MOV INSBLOCK_PTR_L, A
        MOV INSDATA_TMP_PTR_0_L, A
        INCW INSDATA_PTR_L

        MOV A, (INSDATA_PTR_L)+Y
        MOV INSBLOCK_PTR_H, A
        MOV INSDATA_TMP_PTR_0_H, A
        INCW INSDATA_PTR_L

        MOV A, Y    ; 0
        MOV Y, #$50
        SUBW YA, INSDATA_TMP_PTR_0_L
        MOVW INSDATA_TMP_PTR_1_L, YA
        MOVW INSBLOCK_PTR_L, YA

        DECW INSDATA_TMP_PTR_0_L

        MOV Y, #$00

        .BigLoop:
            MOVW YA, INSDATA_PTR_L
            MOV ByteTransferLoop+1, A   ; Lo byte of 1st MOV
            MOV ByteTransferLoop+2, Y   ; Hi byte of 1st MOV

            MOVW YA, INSDATA_TMP_PTR_1_L
            MOV ByteTransferLoop+4, A   ; Lo byte of 2nd MOV
            MOV ByteTransferLoop+5, Y   ; Hi byte of 2nd MOV

            DEC INSDATA_TMP_PTR_0_H
            BMI +
                ; If >=$FF bytes left
                MOV Y, #$00
                CALL ByteTransferLoop
                INC INSDATA_PTR_H
                INC INSDATA_TMP_PTR_1_H
                JMP InstrumentRawDataBlock_BigLoop

            +:
                MOV Y, INSDATA_TMP_PTR_0_L
                CALL ByteTransferLoop
                ; Y is 0 after DBNZ
                MOV A, (INSDATA_PTR_L)+Y
                MOV (INSDATA_TMP_PTR_1_L)+Y, A

                INCW INSDATA_TMP_PTR_0_L
                INC INSDATA_TMP_PTR_0_H
                MOV A, INSDATA_TMP_PTR_0_L
                ADDW YA, INSDATA_PTR_L
                MOVW INSDATA_PTR_L, YA

                MOVW YA, INSBLOCK_PTR_L
                MOVW INSDATA_TMP_PTR_0_L, YA

                MOV Y, #$00
                MOV INSDATA_INS_CNT, Y
                RET
        ByteTransferLoop:
            MOV A, $1000+Y
            MOV $4F00+Y, A
            DBNZ Y, ByteTransferLoop
        #RETJump:
        RET


    End:
namespace off
Begin:

    MOV A, #$00
    MOV !TEMP_POINTER0_L, A
    MOV TDB_OUT_PTR_L, A
    MOV A, #$10
    MOV !TEMP_POINTER0_H, A
    MOV TDB_OUT_PTR_H, A

    CALL TransferDataBlock

    MOV X, #$01
    MOV !CHANNEL_BITMASK, X
    DEC X
	MOV !CHANNEL_REGISTER_INDEX, X
    -:
        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y
        MOV !CH1_SONG_POINTER_L+X, A
        INCW !TEMP_POINTER0_L
        MOV A, (!TEMP_POINTER0_L)+Y
        MOV !CH1_SONG_POINTER_H+X, A
        INCW !TEMP_POINTER0_L
        MOV A, #$00
        MOV !CH1_SONG_COUNTER+X, A
        MOV !CH1_FLAGS+X, A
        ; MOV !CH1_EFFECT_COUNTER+X, A


        ; MOV Y, #$00
        ; MOV A, (CHTEMP_SONG_POINTER_L)+Y 
        ; INCW CHTEMP_SONG_POINTER_L
        ; MOV !CH1_EFFECT_POINTER_L+X, A
        ; MOV A, (CHTEMP_SONG_POINTER_L)+Y 
        ; INCW CHTEMP_SONG_POINTER_L
        ; MOV !CH1_EFFECT_POINTER_H+X, A

        MOV A, X
        CLRC
        ADC A, #$08
        AND A, #$38
        MOV X, A
        BNE -

    MOV $F2, #$5C
    MOV $F3, X      ; X is 0
    MOV $F2, #$6C
    MOV $F3, #$20

    MOV A, $FD
    JMP mainLoop_00


namespace ParseSongData
    POPX_ReadByte:
        POP X
    Start:
    ReadByte:
        MOV Y, #$00
        MOV A, (CHTEMP_SONG_POINTER_L)+Y 
    
    ; If the opcode >= $80, then it's either an instrument change or a waiting opcode
        BMI Inst_Or_Wait

        MOV !TEMP_VALUE, A
        INCW CHTEMP_SONG_POINTER_L
        SETC
        SBC A, #$60
        BMI Note

    ; Detect if the opcode is modified by its highest bits
        CMP A, #$08
        BMI Inst_Section_HighBits

    ; Opcode:
        ASL A
        PUSH X
        MOV X, A
        JMP (OpcodeTable-$10+X)


    Inst_Or_Wait:
        INCW CHTEMP_SONG_POINTER_L
        AND A, #$7F
        LSR A
        BCC WaitCmd
        MOV CHTEMP_INSTRUMENT_INDEX, A
        MOV A, CHTEMP_INSTRUMENT_SECTION_HIGHBITS
        AND A, #$C0
        TSET CHTEMP_INSTRUMENT_INDEX, A
        CALL CallInstrumentParser
        JMP ReadByte

    WaitCmd:
        BNE +
        MOV A, #$40
    +   ADC A, CHTEMP_SONG_COUNTER
        ;DEC A
        MOV CHTEMP_SONG_COUNTER, A
        BBS0 CHTEMP_FLAGS, DecrementReference
        RET

    Inst_Section_HighBits:
        MOV !TEMP_VALUE, A
        AND A, #$03
        BBC2 !TEMP_VALUE, Inst_HighBits   ; If it is setting the high bits, call the right routine
        AND CHTEMP_INSTRUMENT_SECTION_HIGHBITS, #$FC
    -   TSET CHTEMP_INSTRUMENT_SECTION_HIGHBITS, A
        JMP ReadByte

    Note:
        MOV CHTEMP_NOTE, !TEMP_VALUE
        BBS4 CHTEMP_FLAGS, PitchUpdate
            ; Retrigger
            MOV $F2, #$5C       		;   Key off the needed channel
            MOV $F3, !CHANNEL_BITMASK	;__
            CALL CallInstrumentParser
        PitchUpdate:
            MOV A, CHTEMP_NOTE          ;
            CLRC                    	;   Apply arpeggio
            ADC A, CHTEMP_ARPEGGIO 		;__
            BBC0 CHTEMP_INSTRUMENT_TYPE, NoisePitch
                MOV Y, A                            ;   Get low pitch byte
                MOV A, PitchTableLo+Y               ;__
                AND !CHANNEL_REGISTER_INDEX, #$70   ;
                OR !CHANNEL_REGISTER_INDEX, #$02    ;   DSP Address (low pitch)
                MOV $F2, !CHANNEL_REGISTER_INDEX;   ;__
                MOV $F3, A                          ;__ Write low pitch byte
                MOV A, PitchTableHi+Y               ;__ Get high pitch byte
                INC $F2                             ;__ DSP Address (high pitch)
                MOV $F3, A                          ;__ Write high pitch byte
                JMP KeyOn
            NoisePitch:
                AND A, #$1F  	;
                MOV $F2, #$6C	;  Update noise clock
                AND $F3, #$E0	;
                TSET $F3, A  	;__
        KeyOn:
            EOR CHTEMP_FLAGS, #%00010000    ;__ Reduces branching
            BBC4 CHTEMP_FLAGS, ReadByte     ;__ (Inverted)
                MOV $F2, #$5C       		;   Key off nothing (so no overrides happen)
                MOV $F3, #$00       		;__ 
                MOV $F2, #$4C       		;   Key on the needed channel
                MOV $F3, !CHANNEL_BITMASK	;__ 
                CLR4 CHTEMP_FLAGS           ;__ Do attack
                JMP ReadByte



    DecrementReference:
        DEC CHTEMP_REF0_COUNTER
        BNE RETJump ; very vulnerable

        ; Return from reference
        CLR0 CHTEMP_FLAGS
        MOV CHTEMP_SONG_POINTER_L, CHTEMP_REF0_POINTER_L
        MOV CHTEMP_SONG_POINTER_H, CHTEMP_REF0_POINTER_H
        RET

    Inst_HighBits:
        XCN A
        ASL A
        ASL A
        AND CHTEMP_INSTRUMENT_SECTION_HIGHBITS, #$3F
        JMP -


    NoAttack:
        SET4 CHTEMP_FLAGS
        JMP POPX_ReadByte


    Keyoff:
        SET1 CHTEMP_FLAGS
        MOV $F2, #$5C
        MOV $F3, !CHANNEL_BITMASK
        JMP POPX_ReadByte

    ; End:
    ;     SET0 CHTEMP_FLAGS
    ;     POP X
    ;     OR !PATTERN_END_FLAGS, !CHANNEL_BITMASK
    ;     CMP !PATTERN_END_FLAGS, #$FF
    ;     BNE RETJump
    ;     CALL SPC_ParsePatternData
    ;     POP A
    ;     POP A
    ;     JMP SPC_mainLoop_01
    Jump:
        MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y assumed to be 0 
        INCW CHTEMP_SONG_POINTER_L 
        PUSH A
        MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y still assumed to be 0 
        INCW CHTEMP_SONG_POINTER_L 
        MOV Y, A
        POP A
        MOVW CHTEMP_SONG_POINTER_L, YA
        JMP POPX_ReadByte


    RETJump:
        RET

    CallInstrumentParser:

        CLR1 CHTEMP_FLAGS
        SET3 CHTEMP_FLAGS
        MOV CHTEMP_COUNTERS_HALT, Y
        MOV CHTEMP_COUNTERS_DIRECTION, Y
        CALL SPC_ParseInstrumentData_Start
        CLRC
        ADC CHTEMP_INSTRUMENT_TYPE_COUNTER, !TIMER_VALUE
        ADC CHTEMP_ENVELOPE_COUNTER, !TIMER_VALUE
        ADC CHTEMP_SAMPLE_POINTER_COUNTER, !TIMER_VALUE
        ADC CHTEMP_ARPEGGIO_COUNTER, !TIMER_VALUE
        ADC CHTEMP_PITCHBEND_COUNTER, !TIMER_VALUE

        RET

    SetVolumeL_or_R:
        MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y assumed to be 0 
        INCW CHTEMP_SONG_POINTER_L 
        AND !CHANNEL_REGISTER_INDEX, #$70
        MOV $F2, !CHANNEL_REGISTER_INDEX
        BBC0 $E0, +         ;   Store to right volume register if bit 0 set
        INC $F2             ;__
    +   MOV $F3, A
        JMP POPX_ReadByte

    SetVolumeBoth:
        MOV A, (CHTEMP_SONG_POINTER_L)+Y
        INCW CHTEMP_SONG_POINTER_L 
        AND !CHANNEL_REGISTER_INDEX, #$70
        MOV $F2, !CHANNEL_REGISTER_INDEX
        MOV $F3, A
        INC $F2                             
    +   MOV $F3, A
        JMP POPX_ReadByte

    ReferenceSet:
        MOV CHTEMP_REF0_POINTER_L, CHTEMP_SONG_POINTER_L
        MOV CHTEMP_REF0_POINTER_H, CHTEMP_SONG_POINTER_H

        MOV A, (CHTEMP_REF0_POINTER_L)+Y
        INCW CHTEMP_REF0_POINTER_L
        MOV CHTEMP_REF0_COUNTER, A
        SET0 CHTEMP_FLAGS

        MOV A, (CHTEMP_REF0_POINTER_L)+Y    ; Y assumed to be 0 
        INCW CHTEMP_REF0_POINTER_L 
        MOV CHTEMP_SONG_POINTER_L, A

        MOV A, (CHTEMP_REF0_POINTER_L)+Y    ; Y still assumed to be 0 
        INCW CHTEMP_REF0_POINTER_L 
        MOV CHTEMP_SONG_POINTER_H, A

        JMP POPX_ReadByte

    ReferenceRepeat:
        MOV A, (CHTEMP_SONG_POINTER_L)+Y
        CLRC
        ADC A, #$04                 ;__ 3 bytes of parameters + 1 byte for this opcode
        MOV !TEMP_POINTER0_L, A     ;   Neither of these instructions
        MOV !TEMP_POINTER0_H, Y     ;__ affect carry
        ADC !TEMP_POINTER0_H, #$00
        
        MOVW YA, CHTEMP_SONG_POINTER_L
        MOVW CHTEMP_REF0_POINTER_L, YA
        INCW CHTEMP_REF0_POINTER_L

        SUBW YA, !TEMP_POINTER0_L   ;   Get address of last
        MOVW !TEMP_POINTER0_L, YA   ;__ reference opcode's parameters

        MOV Y, #$00

        MOV A, (!TEMP_POINTER0_L)+Y
        MOV CHTEMP_REF0_COUNTER, A
        INC Y
        SET0 CHTEMP_FLAGS

        MOV A, (!TEMP_POINTER0_L)+Y
        MOV CHTEMP_SONG_POINTER_L, A
        INC Y

        MOV A, (!TEMP_POINTER0_L)+Y
        MOV CHTEMP_SONG_POINTER_H, A

        JMP POPX_ReadByte

    OpcodeTable:
        fillword POPX_ReadByte
        dw NoAttack         ; $68, Disable attack
        dw POPX_ReadByte    ; $69, Arp table
        dw POPX_ReadByte    ; $6A, Pitch table
        dw POPX_ReadByte    ; $6B, Fine pitch
        fill 2*4

        dw SetVolumeL_or_R  ; $70, Set left volume
        dw SetVolumeL_or_R  ; $71, Set right volume
        dw SetVolumeBoth    ; $72, Set both volumes
        dw POPX_ReadByte    ; $73, Left volume slide
        dw POPX_ReadByte    ; $74, Right volume slide
        dw POPX_ReadByte    ; $75, Both volume slide
        fill 2*6
        dw Keyoff           ; $7C, Keyoff
        dw ReferenceRepeat  ; $7D, Repeat last reference
        dw ReferenceSet     ; $7E, Set reference
        dw Jump             ; $7F, Loop/Jump

namespace off

mainLoop:
    .00:
        MOV !TIMER_VALUE, $FD
        MOV A, !TIMER_VALUE
        BEQ mainLoop_00
    .01:
        TCALL 15
        ; CALL UpdateEffects
        ; SETC
        ; SBC CHTEMP_EFFECT_COUNTER, !TIMER_VALUE
        ; BPL +
        ; CALL ParseEffectData
    ; +:
        SETC
        SBC CHTEMP_SONG_COUNTER, !TIMER_VALUE
        BPL +
        CALL ParseSongData_Start
    +:
        CALL ParseInstrumentData_Start
        TCALL 14    ;Transfer shit back
        MOV A, X
        CLRC
        ADC A, #$08
        ; There is no way in hell the carry should be set here
        ADC !CHANNEL_REGISTER_INDEX, #$10
        MOV X, A
        ASL !CHANNEL_BITMASK
        BNE mainLoop_01
        MOV X, #$00
        INC !CHANNEL_BITMASK
        JMP mainLoop_00

namespace ParseInstrumentData
    Start:
        BBC1 CHTEMP_FLAGS, Load
        RET

    Load:
        MOV Y, CHTEMP_INSTRUMENT_INDEX
        MOV A, InstrumentPtrLo+Y
        MOV !TEMP_POINTER0_L, A
        MOV A, InstrumentPtrHi+Y
        MOV !TEMP_POINTER0_H, A
        MOV Y, #$00

        INCW !TEMP_POINTER0_L
        INCW !TEMP_POINTER0_L

        PUSH X
        MOV X, #$00

        BBS3 CHTEMP_FLAGS, +
        JMP NotFirstTime
        +:
        MOV CHTEMP_ARPEGGIO, X
        MOV $E0, #$05
        
        MOV CHTEMP_INSTRUMENT_TYPE_POINTER, X
        MOV CHTEMP_ENVELOPE_POINTER, X
        MOV CHTEMP_SAMPLE_POINTER_POINTER, X
        MOV CHTEMP_ARPEGGIO_POINTER, X
        MOV CHTEMP_PITCHBEND_POINTER, X
        
        MOV !TEMP_VALUE, #$01
        MOV !TEMP_VALUE2, #$04
        
        -:
            CALL UpdateMacro
            INC X
            ASL !TEMP_VALUE
            DBNZ !TEMP_VALUE2, -

        CLR3 CHTEMP_FLAGS
        POP X
        RET
    NotFirstTime:

        MOV !TEMP_VALUE, #$01
        MOV !TEMP_VALUE2, #$04

        -:
            MOV A, CHTEMP_COUNTERS_HALT
            AND A, !TEMP_VALUE
            BNE +
                SETC
                MOV A, CHTEMP_INSTRUMENT_TYPE_COUNTER+X
                SBC A, !TIMER_VALUE
                MOV CHTEMP_INSTRUMENT_TYPE_COUNTER+X, A
                BPL +
                    CALL UpdateMacro
                    JMP ++
            +
                CLRC    
                ADC !TEMP_POINTER0_L, #$04
                ADC !TEMP_POINTER0_H, #$00
            ++
            INC X
            ASL !TEMP_VALUE
            DBNZ !TEMP_VALUE2, -
        
        POP X
        RET

    UpdateMacro:
        PUSH X
        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y             ;
        MOV !TEMP_POINTER1_L, A                 ;
        INCW !TEMP_POINTER0_L                   ;   Get base 
        MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
        MOV !TEMP_POINTER1_H, A                 ;
        INCW !TEMP_POINTER0_L                   ;__

        MOV A, UpdateMacro_InsTypeMaskTable+X
        AND A, CHTEMP_INSTRUMENT_TYPE
        BEQ +
            MOV A, CHTEMP_MACRO_POINTERS+X      ; 
            ASL A                               ;   Get the current
            BCC ++                              ;   macro pointer (double)
                INC Y                           ;
            JMP ++                              ;__
        +:
            MOV A, CHTEMP_MACRO_POINTERS+X		;   Get the current macro pointer (single)
        ++:
        ADDW YA, !TEMP_POINTER1_L               ;   Get the current
        MOVW !TEMP_POINTER1_L, YA               ;__ macro pointer

        MOV Y, #$00
        MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the amount of steps
        INCW !TEMP_POINTER0_L                   ;__
        CMP A, CHTEMP_MACRO_POINTERS+X
        BNE ++
            OR CHTEMP_COUNTERS_HALT, !TEMP_VALUE
            INCW !TEMP_POINTER0_L
            JMP +
        ++  INC CHTEMP_MACRO_POINTERS+X			;TODO: More looping types
            MOV A, (!TEMP_POINTER0_L)+Y			;   Get the counter value
            INCW !TEMP_POINTER0_L				;__
            MOV CHTEMP_MACRO_COUNTERS+X, A		;__ Store counter value
        +
        MOV A, X
        ASL A
        MOV X, A
        JMP (UpdateMacro_ActualUpdateTable+X)

        .ActualUpdateTable:
            dw UpdateInstrumentType
            dw UpdateEnvelope
            dw UpdateSamplePointer
            dw UpdateArpeggio
        .InsTypeMaskTable:     ; Doubles the actual pointer if the bit is set in instrument type
            db $00, !ENVELOPE_TYPE_ADSR, !SAMPLE_USE_ADDRESS, $00, $00

    UpdateInstrumentType:
        POP X
        MOV A, (!TEMP_POINTER1_L)+Y         ;   Get the current value
        MOV CHTEMP_INSTRUMENT_TYPE, A      	;__
        MOV $F2, #$3D                       ;
        BBC0 CHTEMP_INSTRUMENT_TYPE, +		;
            MOV A, !CHANNEL_BITMASK         ;
            TCLR $F3, A                     ;   Update the noise enable flag
            JMP ++                          ;
        +:                                  ;
            OR $F3, !CHANNEL_BITMASK        ;__ 
    ++  AND !CHANNEL_REGISTER_INDEX, #$70	; 
        OR !CHANNEL_REGISTER_INDEX, #$05	;
        MOV $F2, !CHANNEL_REGISTER_INDEX	;
        MOV A, $F3                          ;
        XCN A                               ;   If the envelope mode isn't changed, 
        LSR A                               ;   don't clear the envelope
        LSR A                               ;
        EOR A, CHTEMP_INSTRUMENT_TYPE		;
        AND A, #$02                         ;
        BEQ RET_                            ;__
        AND !CHANNEL_REGISTER_INDEX, #$70	; 
        BBC1 CHTEMP_INSTRUMENT_TYPE, +		;
            OR !CHANNEL_REGISTER_INDEX, #$05;   Write address to DSP (ADSR1)
            MOV $F2, !CHANNEL_REGISTER_INDEX;__
            MOV $F3, #$80                   ;   If ADSR is used,
            INC $F2                         ;   Clear out the ADSR envelope
            MOV $F3, #$00                   ;__
        #RET_ RET
        +:                                  ;
            OR !CHANNEL_REGISTER_INDEX, #$08;
            MOV $F2, !CHANNEL_REGISTER_INDEX;
            MOV A, $F3                      ;   If GAIN is used,
            DEC $F2                         ;   set the GAIN envelope to the current value
            MOV $F3, A                      ;
            DEC $F2                         ;
            DEC $F2                         ;
            MOV $F3, #$00                   ;__
        RET

    UpdateEnvelope:
        POP X
        AND !CHANNEL_REGISTER_INDEX, #$70           ;
        BBC1 CHTEMP_INSTRUMENT_TYPE, +             	;
            OR !CHANNEL_REGISTER_INDEX, #$05        ;
            MOV $F2, !CHANNEL_REGISTER_INDEX        ;
            MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Attack, Decay
            INCW !TEMP_POINTER1_L                   ;
            OR A, #$80                              ;
            MOV $F3, A                              ;__
            INC $F2                                 ;
            MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Sustain, Release
            MOV $F3, A                              ;__
            RET
        +:
            OR !CHANNEL_REGISTER_INDEX, #$07        ;
            MOV $F2, !CHANNEL_REGISTER_INDEX        ;   Update GAIN envelope
            MOV A, (!TEMP_POINTER1_L)+Y             ;
            MOV $F3, A                              ;__
            RET
    UpdateSamplePointer:

        BBS3 CHTEMP_INSTRUMENT_TYPE, +			;__ If sample index is used,
            MOV A, (!TEMP_POINTER1_L)+Y         ;
            MOV Y, A                            ;
            MOV A, CHTEMP_INSTRUMENT_TYPE		;
            AND A, #$30                         ;
            XCN A                               ;
            MOV $EF, A                          ;  Get pointer from sample index
            MOV A, CHTEMP_INSTRUMENT_TYPE		;
            AND A, #$40                         ;
            OR A, $EF                           ;
            TCALL 13                            ;
            MOVW CHTEMP_SAMPLE_POINTER_L, YA	;
            MOV Y, #$00                         ;
            JMP ++			                    ;__
        +   MOV A, (!TEMP_POINTER1_L)+Y         ;
            MOV CHTEMP_SAMPLE_POINTER_L, A		;   If no, just blatantly
            INCW !TEMP_POINTER1_L               ;   Load sample pointer into memory
            MOV A, (!TEMP_POINTER1_L)+Y         ;
            MOV CHTEMP_SAMPLE_POINTER_H, A     	;__
        ++:
            MOV A, !CHANNEL_REGISTER_INDEX		;
            LSR A								;	Get current channel's X
            AND A, #$38							;	(cheaper than getting it from stack)
            MOV X, A							;__
    updatePointer:       
            BBS7 CHTEMP_FLAGS, updatePointer_1  ;	If the currently playing sample is 1, update sample 0
        .0:
            MOV A, CHTEMP_SAMPLE_POINTER_H		;   Check if the high byte is the same
            CMP A, $0203+X                      ;__
            BNE updatePointer_0_withRestart		;
            MOV A, CHTEMP_SAMPLE_POINTER_L		;	If yes, update only the low byte of the sample pointer
            MOV $0202+X, A                      ;__ 
            POP X
            RET
            
        ..withRestart:
            MOV $0207+X, A						;   If high byte is different,
            MOV A, CHTEMP_SAMPLE_POINTER_L		;   Update sample 1 loop pointer
            MOV $0206+X, A                      ;__
            MOV A, #$C0                         ;
            MOV $0204+X, A                      ;   Reset sample 1 start pointer to blank sample
            MOV A, #$0E                         ;
            MOV $0205+X, A                      ;__
            AND !CHANNEL_REGISTER_INDEX, #$70	;   
            OR !CHANNEL_REGISTER_INDEX, #$04	;   Write address to DSP
            MOV $F2, !CHANNEL_REGISTER_INDEX	;__
            MOV A, X		                    ;
            LSR A                               ;   Write Source Number to DSP
            LSR A                               ;
            OR A, #$01                          ;
            MOV $F3, A                          ;__
            SET7 CHTEMP_FLAGS					;__ Next time update sample 0
            POP X
            RET


        .1:
            MOV A, CHTEMP_SAMPLE_POINTER_H		;	Check if high byte is the same
            CMP A, $0207+X						;__
            BNE updatePointer_1_withRestart		;
            MOV A, CHTEMP_SAMPLE_POINTER_L		;	If yes, update only the low byte of the sample pointer
            MOV $0206+X, A                      ;__
            POP X
            RET
            
        ..withRestart:
            MOV $0203+X, A                      ;   If high byte is different,
            MOV A, CHTEMP_SAMPLE_POINTER_L		;   Update sample 1 loop pointer
            MOV $0202+X, A                      ;__
            MOV A, #$C0                         ;
            MOV $0200+X, A                      ;   Reset sample 1 start pointer to blank sample
            MOV A, #$0E                         ;
            MOV $0201+X, A                      ;__
            AND !CHANNEL_REGISTER_INDEX, #$70	;   
            OR !CHANNEL_REGISTER_INDEX, #$04	;   Write address to DSP
            MOV $F2, !CHANNEL_REGISTER_INDEX	;__
            MOV A, X		                    ;
            LSR A                               ;   Write Source Number to DSP
            LSR A                               ;
            MOV $F3, A                          ;__
            CLR7 CHTEMP_FLAGS					;__ Next time sample 1 is updated
            POP X
            RET		

    UpdateArpeggio:
        POP X
        MOV A, (!TEMP_POINTER1_L)+Y 			;   Update arpeggio 
        MOV CHTEMP_ARPEGGIO, A                 	;__
        MOV A, CHTEMP_NOTE                     	;
        CLRC                                    ;   Apply arpeggio
        ADC A, CHTEMP_ARPEGGIO                 	;__
        BBC0 CHTEMP_INSTRUMENT_TYPE, ++
            AND A, #$7F
            MOV Y, A                                ;__
            MOV A, PitchTableLo+Y                   ;
            AND !CHANNEL_REGISTER_INDEX, #$70       ;
            OR !CHANNEL_REGISTER_INDEX, #$02        ;   Update low byte of pitch
            MOV $F2, !CHANNEL_REGISTER_INDEX;       ;
            MOV $F3, A                              ;__
            MOV A, PitchTableHi+Y                   ;
            OR !CHANNEL_REGISTER_INDEX, #$01        ;   Update high byte of pitch
            MOV $F2, !CHANNEL_REGISTER_INDEX;       ;
            MOV $F3, A                              ;
            MOV Y, #$00                             ;__
            RET
        ++:
            AND A, #$1F                             ;
            MOV $F2, #$6C                           ;  Update noise clock
            AND $F3, #$E0                           ;
            OR A, $F3                               ;
            MOV $F3, A                              ;__
            RET

namespace off

TransferDataBlock:
    .Labels:
        TDB_OUT_PTR_L = $D0
        TDB_OUT_PTR_H = $D1
        TDB_TMP_PTR_L = $EE
        TDB_TMP_PTR_H = $EF
    .Documentation:
        ; Inputs:
        ; $D0-D1 - Output pointer
        ; Temp Variables:
        ; $EE-EF - Output pointer
        ; Other variables used:
        ; $40 - Message counter on thread 1
    .Start:
        MOVW YA, TDB_OUT_PTR_L
        MOVW TDB_TMP_PTR_L, YA
        MOV Y, #$00
        CALL WaitCPUMsg
        PUSH A
        AND A, #$E0     ;   Both opcodes 4x and 5x
        CMP A, #$40     ;__ are valid
        BNE TransferDataBlock_POPA_RET

        MOV A, #$10
        CALL SendCPUMsg
    .GetWord:
        CALL WaitCPUMsg
        CMP A, #$A0
        BEQ TransferDataBlock_End

        CMP A, #$90
        BNE TransferDataBlock_POPA_RET
        
        ; Push the 2 bytes where they need to be
        MOV A, $F6
        MOV (TDB_TMP_PTR_L)+Y, A
        INCW TDB_TMP_PTR_L
        MOV A, $F7
        MOV (TDB_TMP_PTR_L)+Y, A
        INCW TDB_TMP_PTR_L

        ; Affirm having received data
        MOV A, #$20
        CALL SendCPUMsg
        JMP TransferDataBlock_GetWord

    .POPA_RET
        POP A : RET

    .End:
        POP A
        AND A, #$10
        BNE SendCPUMsg
        MOV A, #$30

SendCPUMsg:
    ; Inputs:
    ; A - message ID
    MOV $F5, A
    MOV $F4, MESSAGE_CNT_TH1
    INC MESSAGE_CNT_TH1
    .RETJump:
    RET

WaitCPUMsg:
    -:
        MOV A, $F4
        CMP A, MESSAGE_CNT_TH1
        BNE -
    INC MESSAGE_CNT_TH1
    MOV A, $F5
    AND A, #$F0
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
;

if !SNESFM_CFG_SAMPLE_GENERATE >= 1

if !SNESFM_CFG_PULSEGEN >= 1
PulseGenTables:    ;In order:
    ;Highbyte with sz = 00 (8000),
    ;Lowbyte with s=0 (8000/0000) / Highbyte with sz = 01 (0000), 
    ;Highbyte with sz = 1- (7FFF),
    ;Lowbyte with s=1 (7FFF) / Highbyte with sz = 1- (7FFF)
    ;Highbytes are EOR #$80'd.
    db $80, $00, $FF, $FF
    ;Inversion values for fractional value
    db $7F, $FE, $00, $80
PulseGenLabels:
    PUL_OUT_PAGE    = $D0
    PUL_DUTY        = $D1
    PUL_FLAGS       = $D2

    PUL_OUT_PTR_L   = $EE
    PUL_OUT_PTR_H   = $EF
;
if !SNESFM_CFG_LONG_SMP_GEN >= 1
GeneratePulse_128:
    .Documentation:
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
    .Start:
    ;Low byte of first part
        MOV PUL_OUT_PTR_H, PUL_OUT_PAGE
        MOV PUL_OUT_PTR_L, #$00
        MOV A, PUL_DUTY         ;   Get finishing low byte
        AND A, #$FE             ;__
        MOV Y, A                ;   If there are no bytes in the first part, skip the part
        BEQ +                   ;__
        MOV A, PUL_FLAGS
        AND A, #$02
        MOV X, A
        MOV A, PulseGenTables+1+X
        -:
            DEC Y
            DEC Y
            MOV (PUL_OUT_PTR_L)+Y, A
            CMP Y, #$00
            BNE -
    ;High byte of first part
        MOV A, PUL_DUTY         ;   Get finishing high byte
        OR A, #$01              ;__
        MOV Y, A
        MOV A, PUL_FLAGS
        AND A, #$03
        MOV X, A
        MOV A, PulseGenTables+X
        EOR A, #$80
        -:
            DEC Y
            DEC Y
            MOV (PUL_OUT_PTR_L)+Y, A
            CMP Y, #$01
            BNE -
    +:
    ;Second part, the fractional value
        MOV A, PUL_FLAGS            ;
        AND A, #$03                 ;
        MOV X, A                    ;   Get the inversion value into "temp variable"
        MOV A, PulseGenTables+4+X
        MOV PUL_OUT_PTR_L, A		;__
        MOV A, PUL_DUTY             ;
        LSR A                       ;   Get the actual fraction,
        MOV A, PUL_FLAGS            ;   while also getting 
        ROR A                       ;   z flag into carry
        AND A, #$FE                 ;__
        BCC +                       ;   If z flag is set, 
        LSR A                       ;__ halve the fraction
    +   EOR A, PUL_OUT_PTR_L		;__ Invert the fraction as needed
        MOV Y, A
        MOV A, PUL_DUTY             ;   Get index for the fraction
        AND A, #$FE                 ;
        MOV PUL_OUT_PTR_L, A		;__
        MOV A, Y
        MOV Y, #$01
        MOV (PUL_OUT_PTR_L)+Y, A
        MOV A, #$00
        DEC Y
        MOV (PUL_OUT_PTR_L)+Y, A
        INC PUL_OUT_PTR_L
        INC PUL_OUT_PTR_L
    ;Third part
        MOV A, PUL_DUTY
        EOR A, #$FE
        AND A, #$FE
        MOV Y, A
        MOV A, PUL_FLAGS
        AND A, #$02
        EOR A, #$02
        MOV X, A
        MOV A, PulseGenTables+1+X
        -:
            DEC Y
            DEC Y
            MOV (PUL_OUT_PTR_L)+Y, A
            CMP Y, #$00
            BNE -
    ;High byte of first part
        MOV A, PUL_DUTY         ;   Get finishing high byte
        EOR A, #$FE             ;
        OR A, #$01              ;__
        MOV Y, A
        MOV A, PUL_FLAGS
        AND A, #$03
        EOR A, #$02
        MOV X, A
        MOV A, PulseGenTables+X
        EOR A, #$80
        -:
            DEC Y
            DEC Y
            MOV (PUL_OUT_PTR_L)+Y, A
            CMP Y, #$01
            BNE -
    +:
    RET

endif   ; !SNESFM_CFG_LONG_SMP_GEN

if !SNESFM_CFG_SHORTSMP_GEN >= 1
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
    MOV PUL_OUT_PTR_H, PUL_OUT_PAGE
    MOV PUL_OUT_PTR_L, PUL_DUTY
    AND PUL_OUT_PTR_L, #$C0
    MOV A, PUL_DUTY         ;   Get finishing low index
    AND A, #$3E             ;__
    MOV Y, A                ;   If there are no bytes in the first part, skip the part
    BEQ +                   ;__
    MOV A, PUL_FLAGS
    AND A, #$02
    MOV X, A
    MOV A, PulseGenTables+1+X
    -:
        DEC Y
        DEC Y
        MOV (PUL_OUT_PTR_L)+Y, A
        CMP Y, #$00
        BNE -
    ;High byte of first part
    MOV A, PUL_DUTY         ;
    AND A, #$3E             ;   Get finishing high index
    OR A, #$01              ;__
    MOV Y, A
    MOV A, PUL_FLAGS
    AND A, #$03
    MOV X, A
    MOV A, PulseGenTables+X
    EOR A, #$80
    -:
        DEC Y
        DEC Y
        MOV (PUL_OUT_PTR_L)+Y, A
        CMP Y, #$01
        BNE -
    +:
    ;Second part, the fractional value
    MOV A, PUL_FLAGS            ;
    AND A, #$03                 ;
    MOV X, A                    ;   Get the inversion value into "temp variable"
    MOV A, PulseGenTables+4+X
    MOV PUL_OUT_PTR_L, A		;__
    MOV A, PUL_DUTY             ;
    LSR A                       ;   Get the actual fraction,
    MOV A, PUL_FLAGS            ;   while also getting 
    ROR A                       ;   z flag into carry
    AND A, #$FE                 ;__
    BCC +                       ;   If z flag is set, 
    LSR A                       ;__ halve the fraction
    +   EOR A, PUL_OUT_PTR_L    ;__ Invert the fraction as needed
    MOV Y, A
    MOV A, PUL_DUTY             ;   Get index for the fraction
    AND A, #$FE                 ;
    MOV PUL_OUT_PTR_L, A		;__
    MOV A, Y
    MOV Y, #$01
    MOV (PUL_OUT_PTR_L)+Y, A
    MOV A, #$00
    DEC Y
    MOV (PUL_OUT_PTR_L)+Y, A
    INC PUL_OUT_PTR_L
    INC PUL_OUT_PTR_L
    ;Third part
    MOV A, PUL_DUTY
    EOR A, #$FE
    AND A, #$3E
    MOV Y, A
    MOV A, PUL_FLAGS
    AND A, #$02
    EOR A, #$02
    MOV X, A
    MOV A, PulseGenTables+1+X
    -:
        DEC Y
        DEC Y
        MOV (PUL_OUT_PTR_L)+Y, A
        CMP Y, #$00
        BNE -
    ;High byte of first part
    MOV A, PUL_DUTY         ;   Get finishing high byte
    EOR A, #$3E             ;
    AND A, #$3E             ;
    OR A, #$01              ;__
    MOV Y, A
    MOV A, PUL_FLAGS
    AND A, #$03
    EOR A, #$02
    MOV X, A
    MOV A, PulseGenTables+X
    EOR A, #$80
    -:
        DEC Y
        DEC Y
        MOV (PUL_OUT_PTR_L)+Y, A
        CMP Y, #$01
        BNE -
    RET

endif   ; !SNESFM_CFG_SHORTSMP_GEN

endif   ; !SNESFM_CFG_PULSEGEN 

if !SNESFM_CFG_PHASEMOD >= 1
PhaseModulation_Labels:
    MOD_CAR_PAGE        = $D0
    MOD_MOD_PAGE        = $D1
    MOD_OUT_PAGE        = $D2
    MOD_MOD_STRENGTH    = $D3
    MOD_MOD_PHASE_SHIFT = $D4

    MOD_OUT_INDEX_L     = $EA
    MOD_OUT_INDEX_H     = $EB
    MOD_MOD_INDEX_L     = $EC
    MOD_MOD_INDEX_H     = $ED
    MOD_MAIN_TEMP_L     = $EE
    MOD_MAIN_TEMP_H     = $EF
;
if !SNESFM_CFG_LONG_SMP_GEN >= 1
PhaseModulation_128:
    .Documentation:
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
        MOV MOD_OUT_INDEX_H, MOD_OUT_PAGE
        MOV MOD_MOD_INDEX_H, MOD_MOD_PAGE
        MOV MOD_OUT_INDEX_L, X
        MOV MOD_MOD_INDEX_L, MOD_MOD_PHASE_SHIFT
        ASL MOD_MOD_INDEX_L
    .loop:
        INC MOD_MOD_INDEX_L             ;
        MOV A, (MOD_MOD_INDEX_L+X)      ;   Get high byte
        BMI PhaseModulation_128_loop_negative 
        MOV Y, MOD_MOD_STRENGTH         ;
        MUL YA                          ;   Multiply high byte by modulation strength
        MOVW MOD_MAIN_TEMP_L, YA        ;__

        DEC MOD_MOD_INDEX_L
        MOV A, (MOD_MOD_INDEX_L+X)
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOV A, Y
        CLRC
        ADC A, MOD_MAIN_TEMP_L
        ADC MOD_MAIN_TEMP_H, #$00
        JMP PhaseModulation_128_loop_afterMul
    .loop_negative:
        EOR A, #$FF
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOVW MOD_MAIN_TEMP_L, YA

        DEC MOD_MOD_INDEX_L
        MOV A, (MOD_MOD_INDEX_L+X)
        EOR A, #$FF
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOV A, Y
        CLRC
        ADC A, MOD_MAIN_TEMP_L
        ADC MOD_MAIN_TEMP_H, #$00
        EOR A, #$FF
        EOR MOD_MAIN_TEMP_H, #$FF
    .loop_afterMul:

        ASL A
        ROL MOD_MAIN_TEMP_H
        ASL A
        ROL MOD_MAIN_TEMP_H
        MOV A, MOD_MAIN_TEMP_H  ;   Replaced a third ASL A : ROL MMTH, 
        ASL A                   ;__ as well as MOV A, MMTH : AND A, #$FE
        CLRC
        ADC A, MOD_OUT_INDEX_L 

        MOV MOD_MAIN_TEMP_H, MOD_CAR_PAGE
        MOV MOD_MAIN_TEMP_L, A
        ; X is permanently 0
        MOV A, (MOD_MAIN_TEMP_L+X)
        MOV (MOD_OUT_INDEX_L+X), A
        MOV Y, #$01
        MOV A, (MOD_MAIN_TEMP_L)+Y
        MOV (MOD_OUT_INDEX_L)+Y, A
        CLRC
        ADC MOD_OUT_INDEX_L, #$02
        CLRC
        ADC MOD_MOD_INDEX_L, #$02
        MOV A, MOD_OUT_INDEX_L
        BNE PhaseModulation_128_loop
    RET

endif   ; !SNESFM_CFG_LONG_SMP_GEN

if !SNESFM_CFG_SHORTSMP_GEN >= 1
PhaseModulation_32:
    .Documentation:
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
        ;       $E7    - Modulator pointer offset
        ;       $EA-EB - Output pointer
        ;       $EC-ED - Modulator pointer
        ;       $EE-EF - Main temp variable
    .Labels:
        MOD_SUBPAGE     = $D5
        MOD_MOD_PTR_OFF = $E7
        MOD_CAR_INDEX_L = $E8
        MOD_END_INDEX_L = $E9
    .Setup:
        MOV X, #$00
        MOV MOD_OUT_INDEX_H, MOD_OUT_PAGE
        MOV MOD_MOD_INDEX_H, MOD_MOD_PAGE
        MOV A, MOD_MOD_PHASE_SHIFT  ;
        ASL A                       ;
        AND A, #$3F                 ;
        MOV MOD_MOD_INDEX_L, A      ;
        MOV A, MOD_SUBPAGE          ;   Get low byte of modulator pointer
        ASL A                       ;
        ASL A                       ;
        AND A, #$C0                 ;
        MOV MOD_MOD_PTR_OFF, A      ;
        TSET MOD_MOD_INDEX_L, A     ;__
        MOV A, MOD_SUBPAGE          ;
        XCN A                       ;   Get low byte of output pointer
        AND A, #$C0                 ;
        MOV MOD_OUT_INDEX_L, A      ;__
        CLRC                        ;
        ADC A, #$40                 ;   Get low ending byte of output pointer
        MOV MOD_END_INDEX_L, A      ;__
        MOV A, MOD_SUBPAGE          ;
        AND A, #$C0                 ;   Get low byte of carrier pointer to add later
        MOV MOD_CAR_INDEX_L, A      ;__
    .loop:
        INC MOD_MOD_INDEX_L
        MOV A, (MOD_MOD_INDEX_L+X)
        BMI PhaseModulation_32_loop_negative 
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOVW MOD_MAIN_TEMP_L, YA

        DEC MOD_MOD_INDEX_L
        MOV A, (MOD_MOD_INDEX_L+X)
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOV A, Y                    ; A = high byte
        MOV Y, #$00
        ADDW YA, MOD_MAIN_TEMP_L
        MOV A, Y
        JMP PhaseModulation_32_loop_afterMul
    .loop_negative:
        EOR A, #$FF
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOVW MOD_MAIN_TEMP_L, YA

        DEC MOD_MOD_INDEX_L
        MOV A, (MOD_MOD_INDEX_L+X)
        EOR A, #$FF
        MOV Y, MOD_MOD_STRENGTH
        MUL YA
        MOV A, Y                    ; A = high byte
        MOV Y, #$00
        ADDW YA, MOD_MAIN_TEMP_L
        MOV A, Y
        EOR A, #$FF
    .loop_afterMul:

        ASL A
        CLRC
        ADC A, MOD_OUT_INDEX_L 
        AND A, #$3E
        CLRC
        ADC A, MOD_CAR_INDEX_L

        MOV MOD_MAIN_TEMP_H, MOD_CAR_PAGE
        MOV MOD_MAIN_TEMP_L, A
        ; X is permanently 0
        MOV A, (MOD_MAIN_TEMP_L+X)
        MOV (MOD_OUT_INDEX_L+X), A
        MOV Y, #$01
        MOV A, (MOD_MAIN_TEMP_L)+Y
        MOV (MOD_OUT_INDEX_L)+Y, A
        CLRC
        ADC MOD_OUT_INDEX_L, #$02
        CLRC
        ADC MOD_MOD_INDEX_L, #$02
        AND MOD_MOD_INDEX_L, #$3E
        CLRC 
        ADC MOD_MOD_INDEX_L, MOD_MOD_PTR_OFF
        CMP MOD_OUT_INDEX_L, MOD_END_INDEX_L
        BNE PhaseModulation_32_loop
    RET

endif   ; !SNESFM_CFG_SHORTSMP_GEN

endif   ; !SNESFM_CFG_PHASEMOD

if !SNESFM_CFG_LONG_SMP_GEN >= 1
LongToShort:
    .Documentation:
        ;   Memory allocation:
        ;   Inputs:
        ;       $D0 - Input page
        ;       $D1 - Output page
        ;       $D2 - Subpage number: ll------
        ;           ll - subpage number
        ;   Temp variables:
        ;       $EC-ED - Input pointer
        ;       $EE-EF - Output pointer
    .Labels:
        LTS_IN_PAGE     = $D0
        LTS_OUT_PAGE    = $D1
        LTS_OUT_SUBPAGE = $D2

        LTS_IN_PTR_L    = $EC
        LTS_IN_PTR_H    = $ED
        LTS_OUT_PTR_L   = $EE
        LTS_OUT_PTR_H   = $EF
    .Start:
        MOV X, #$00
        MOV Y, #$20
        MOV LTS_IN_PTR_H, LTS_IN_PAGE
        MOV LTS_OUT_PTR_H, LTS_OUT_PAGE
        MOV LTS_IN_PTR_L, #$F9
        MOV A, LTS_OUT_SUBPAGE
        CLRC
        ADC A, #$3F
        MOV LTS_OUT_PTR_L, A
        -:
            MOV A, (LTS_IN_PTR_L+X)     ;   Copy high byte
            MOV (LTS_OUT_PTR_L+X), A    ;__
            DEC LTS_IN_PTR_L
            DEC LTS_OUT_PTR_L
            MOV A, (LTS_IN_PTR_L+X)     ;   Copy low byte
            MOV (LTS_OUT_PTR_L+X), A    ;__
            DEC LTS_OUT_PTR_L
            MOV A, LTS_IN_PTR_L
            SETC
            SBC A, #$07
            MOV LTS_IN_PTR_L, A
            DBNZ Y, -
        RET

endif   ; !SNESFM_CFG_LONG_SMP_GEN

ConvertToBRR:
    .Documentation:
        ;   Memory allocation:
        ;   Inputs:
        ;       $D0 - PCM sample page
        ;       $D1 - BRR output index
        ;       $D2 - Flags: fsixppbb 
        ;               f - whether to use filter mode 1
        ;               s - short sample mode (32 samples instead of 128)
        ;               i - high bit of output index 
        ;               x - extended sample length mode (more than 1 sample)
        ;               pp - PCM sample subpage number (0-3, if s is set)
        ;               bb - BRR output subpage number (0-3, if s is set)
        ;       $D3 - If x is set, sample length in loops (2 added)
        ;   Temp variables:
        ;       $E3 - Temporary flags: bf-n----
        ;               b - whether it is the first block
        ;               f - whether to use filter mode 1
        ;               n - negative flag
        ;       $E4-$E5 - Ending pointer 
        ;       $E6-$EB - 3 sample points
        ;       $F8-$F9 - Temporary space for 1 sample point
        ;       $EC-$ED - Input pointer
        ;       $EE-$EF - Output pointer
    .Labels:
        BRR_PCM_PAGE    = $D0
        BRR_OUT_INDEX   = $D1
        BRR_FLAGS       = $D2
        BRR_XLEN        = $D3

        BRR_BUFF1_PTR_L = $20
        BRR_BUFF1_PTR_H = $21
        BRR_MAXM0_L     = $F8  ;These registers are so unused
        BRR_MAXM0_H     = $F9  ;they're practically RAM!
        BRR_TEMP_FLAGS  = $E3
        BRR_END_PTR_L   = $E4
        BRR_END_PTR_H   = $E5
        BRR_SMPPT_L     = $E6
        BRR_SMPPT_H     = $E7
        BRR_CSMPT_L     = $E8
        BRR_CSMPT_H     = $E9
        BRR_LSMPT_L     = $EA  ;Last sample point of previous block for filter 1 adjustment
        BRR_LSMPT_H     = $EB  ;
        BRR_IN0_PTR_L   = $EC
        BRR_IN0_PTR_H   = $ED
        BRR_OUT_PTR_L   = $EE
        BRR_OUT_PTR_H   = $EF
    .Start:
        SET7 BRR_TEMP_FLAGS
        MOV BRR_IN0_PTR_H, BRR_PCM_PAGE ;   Set up the PCM sample page
        MOV A, BRR_FLAGS                ;__
        XCN A                           ;
        AND A, #$C0                     ;   Set up the PCM sample subpage 
        MOV BRR_IN0_PTR_L, A            ;__
        MOV A, BRR_FLAGS                ;
        AND A, #$40                     ;   Set up the ending low byte of the address
        CLRC                            ;
        ADC A, BRR_IN0_PTR_L            ;
        MOV BRR_END_PTR_L, A            ;__
        MOV BRR_LSMPT_L, #$00           ;   
        MOV BRR_LSMPT_H, #$00           ;__ smppoint = 0
        MOV Y, BRR_OUT_INDEX            ;
        MOV A, BRR_FLAGS                ;
        AND A, #$23                     ;   Get the sample pointer from index
        TCALL 13                        ;
        MOVW BRR_OUT_PTR_L, YA          ;__

    .SetupCopy:
        MOV X, #$20                     ;__ Set up the destination address (it's (X+))
        MOV Y, #$00
    .CopyLoop:  ;Copy the PCM sample to the PCM buffer while halving it #
        MOV A, (BRR_IN0_PTR_L)+Y        ;                               #
        MOV BRR_CSMPT_L, A              ;                               #
        INCW BRR_IN0_PTR_L              ;   Python code:                #
        MOV A, (BRR_IN0_PTR_L)+Y        ;   currentsmppoint = array[i]  #
        MOV BRR_CSMPT_H, A              ;                               #
        BPL +                           ;                               #
            EOR A, #$FF                 ;   Invert negative numbers     #
            EOR BRR_CSMPT_L, #$FF       ;__                             #
        +:                              ;                               #
        INCW BRR_IN0_PTR_L              ;__                             #
        CLRC                            ;   Python code:                #
        LSR A                           ;   currentsmppoint /= 2        #   OG Python code:
        ROR BRR_CSMPT_L                 ;__                             #   for i in range(len(BRRBuffer)):
        BBC7 BRR_CSMPT_H, +             ;                               #       BRRBuffer[i] = (array[i&(length-1)])/2
            EOR A, #$FF                 ;   Invert negative numbers     #
            EOR BRR_CSMPT_L, #$FF       ;__                             #
        +:                              ;                               #
        MOV BRR_CSMPT_H, A              ;                               #
        MOV A, BRR_CSMPT_L              ;                               #
        MOV (X+), A                     ;   Python code:                #
        MOV A, BRR_CSMPT_H              ;   BRRBuffer[i]=currentsmppoint#
        MOV (X+), A                     ;                               #
        CMP X, #$40                     ;   Loop                        #
        BNE ConvertToBRR_CopyLoop   	;__                             #
    .SetupFilter
        BBS7 BRR_TEMP_FLAGS, ConvertToBRR_FirstBlock    ;   If this is the first block, Or filter 0 is forced,
        BBS7 BRR_FLAGS, ConvertToBRR_FirstBlock         ;__ Skip doing filter 1 entirely   
        MOV X, #$00


        CLR4 BRR_TEMP_FLAGS
        MOV BRR_SMPPT_L, BRR_LSMPT_L    ;   OG Python code:
        MOV BRR_SMPPT_H, BRR_LSMPT_H    ;__ currentsmppoint = 0
        BBC7 BRR_SMPPT_H, +        	    ;
            SET4 BRR_TEMP_FLAGS         ;   Inverting negative numbers
            EOR BRR_SMPPT_L, #$FF       ;
            EOR BRR_SMPPT_H, #$FF       ;__     
        +:
        POP A
        MOV BRR_CSMPT_H, A
        POP A
        MOV BRR_CSMPT_L, A
        JMP ConvertToBRR_FilterLoop
    .FirstBlock:

        MOV BRR_MAXM0_L, #$FF
        MOV BRR_MAXM0_H, #$7F
        MOV X, #$20
        JMP ConvertToBRR_BRREncoding_OuterLoop
    .FilterLoop:
        MOV Y, BRR_SMPPT_L          ;                                       #
        MOV A, $0D00+Y              ;                                       #
        BBS4 BRR_TEMP_FLAGS, +      ;                                       #                        
            CLRC                    ;   Python code:                        #
            ADC A, BRR_CSMPT_L      ;   currentsmppoint += smppoint_L*15/16 #
            MOV BRR_CSMPT_L, A      ;   (for positive numbers)              #
            ADC BRR_CSMPT_H, #$00   ;                                       #
            JMP ++                  ;__                                     #
        +:                          ;                                       #
            EOR A, #$FF             ;                                       #
            SETC                    ;   Python code:                        #
            ADC A, BRR_CSMPT_L      ;   currentsmppoint += smppoint_L*15/16 #
            MOV BRR_CSMPT_L, A      ;   (for negative numbers)              #
            SBC BRR_CSMPT_H, #$00   ;__                                     #
        ++:                         ;                                       #   OG Python code:
        MOV A, BRR_SMPPT_H          ;                                       #   smppoint *= 0.9375
        MOV Y, #$F0                 ;   Python code:                        #   smppoint += BRRBuffer[i]
        MUL YA                      ;__ smpppoint_H *=15                    #
        BBC4 BRR_TEMP_FLAGS, +      ;                                       #
            MOV BRR_SMPPT_H, Y      ;   Invert negative                     #
            EOR A, #$FF             ;                                       #
            EOR BRR_SMPPT_H, #$FF   ;__                                     #
            MOV Y, BRR_SMPPT_H      ;                                       #
        +:                          ;   Python code:                        #
        ADDW YA, BRR_CSMPT_L        ;   smppoint_H<<8 += currentsmppoint    #
        MOVW BRR_SMPPT_L, YA        ;__                                     #__
; Inversions here might not be needed, but that's for another time
        CLR4 BRR_TEMP_FLAGS         ;                                       #
        MOV A, BRR_BUFF1_PTR_L+X    ;                                       #
        MOV BRR_CSMPT_L, A          ;                                       #
        MOV A, BRR_BUFF1_PTR_H+X    ;   currentsmppoint = BRRBuffer[i]      #
        MOV BRR_CSMPT_H, A          ;                                       #
        MOVW YA, BRR_CSMPT_L        ;   Python code:                        #   OG Python code:
        SUBW YA, BRR_SMPPT_L        ;   currentsmppoint -= smppoint         #   BRRBuffer[i] -= smppoint
        MOVW BRR_CSMPT_L, YA        ;__                                     #
        MOV (X+), A   				;                                       #
        MOV A, BRR_CSMPT_H          ;   BRRBuffer[i] = currentsmppoint      #
        MOV (X+), A   				;__                                     #
        BBC7 BRR_SMPPT_H, +         ;                                       #
            SET4 BRR_TEMP_FLAGS     ;   Inverting negative numbers          #
            EOR BRR_SMPPT_L, #$FF   ;                                       #
            EOR BRR_SMPPT_H, #$FF   ;__                                     #
    +   CMP X, #$20                 ;   Loop                                #
        BNE ConvertToBRR_FilterLoop ;__ 
    
        MOV BRR_LSMPT_L, BRR_SMPPT_L
        MOV BRR_LSMPT_H, BRR_SMPPT_H
        BBC4 BRR_TEMP_FLAGS, ConvertToBRR_BRREncoding
        EOR BRR_LSMPT_L, #$FF
        EOR BRR_LSMPT_H, #$FF
        CLR4 BRR_TEMP_FLAGS

    .BRREncoding:
        SET6 BRR_TEMP_FLAGS
        MOV X, #$00
        ..OuterLoop:
            MOV A, (X+)   
            MOV BRR_SMPPT_L, A         
            MOV A, (X+)
            BPL +
                EOR BRR_SMPPT_L, #$FF
                EOR A, #$FF
            +:
            MOV BRR_SMPPT_H, A         
        ..MaximumFilter1:
            MOV A, (X+)  
            MOV BRR_CSMPT_L, A         
            MOV A, (X+)  
            BPL +
                EOR BRR_CSMPT_L, #$FF
                EOR A, #$FF
            +:
            MOV Y, A
            MOV A, BRR_CSMPT_L
            CMPW YA, BRR_SMPPT_L
            BMI +
                MOVW BRR_SMPPT_L, YA
            +:
            MOV A, X
            AND A, #$1F
            BNE ConvertToBRR_BRREncoding_MaximumFilter1
            CMP X, #$40
            BEQ +
                MOVW YA, BRR_SMPPT_L
                MOVW BRR_MAXM0_L, YA
                ;Set up the routine for maximum in the OG PCM buffer
                JMP  ConvertToBRR_BRREncoding_OuterLoop
            +:
                MOV X, #$00
                MOVW YA, BRR_SMPPT_L
                CMPW YA, BRR_MAXM0_L
                BPL ConvertToBRR_BRREncoding_ShiftValuePart1
                MOVW BRR_MAXM0_L, YA
                MOV X, #$20
                CLR6 BRR_TEMP_FLAGS
        ..ShiftValuePart1:
            MOV Y, #12
            MOV A, BRR_MAXM0_H
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
            MOV A, BRR_MAXM0_L
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
            BBS0 BRR_MAXM0_H, ConvertToBRR_FormHeader
            BBS7 BRR_MAXM0_L, ConvertToBRR_FormHeader
            JMP ++
            +   MOV A, BRR_MAXM0_L ;Executed if Y = 5, aka both bits to check are in the low byte
            ..Check8:   ;Executed if Y = 1..4 or Y = 7..12 - aka the bits to check are in the same byte
            ASL A
            BCS ConvertToBRR_FormHeader
            ASL A
            BCC ++      ; = BCS FormHeader : JMP ++
    .FormHeader:
            INC Y
        ++:
            MOV BRR_MAXM0_L, Y              ;
            MOV A, Y                        ;   Get the shift value
            OR A, #%00100000                ;   Set the loop flag
            CMP BRR_END_PTR_L, BRR_IN0_PTR_L;   Compare the ending low byte
            BNE +                           ;   Set the end flag if it's the last block
            OR A, #%00010000                ;__
        +:
            MOV BRR_MAXM0_H, BRR_TEMP_FLAGS ;	Set the filter to 1
            AND BRR_MAXM0_H, #%01000000     ;   if appropriate
            OR A, BRR_MAXM0_H               ;__
            XCN A                           ;__ Swap the nybbles to make a valid header
            MOV Y, #$00                     ;
            MOV (BRR_OUT_PTR_L)+Y, A        ;   Write the header out
            INCW BRR_OUT_PTR_L              ;__
    .FormData:
        CLR4 BRR_TEMP_FLAGS
        MOV A, (X+)
        MOV BRR_CSMPT_L, A
        MOV A, (X+)
        BPL +
            EOR A, #$FF
            EOR BRR_CSMPT_L, #$FF
            SET4 BRR_TEMP_FLAGS
        +:
        MOV BRR_CSMPT_H, A  ;
        MOV Y, BRR_CSMPT_L  ;
        MOV A, $0C00+Y      ;
        MOV BRR_CSMPT_L, A  ;
        MOV Y, BRR_CSMPT_H  ;
        MOV A, #$E0         ;   7/8 multiplication
        MUL YA              ;
        MOV BRR_CSMPT_H, Y  ;
        CLRC                ;
        ADC A, BRR_CSMPT_L  ;
        MOV BRR_CSMPT_L, A  ;__
        MOV A, BRR_CSMPT_H
        AND A, #$7F
        MOV Y, BRR_MAXM0_L
        CMP Y, #$05
        BMI +
            -:
                CLRC
                LSR A
                ROR BRR_CSMPT_L
                DEC Y
                CMP Y, #$04
                BNE -
        +:
            MOV A, BRR_CSMPT_L
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
        +   BBC4 BRR_TEMP_FLAGS, +
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
            MOV BRR_CSMPT_L, A
            POP A
            XCN A
            OR A, BRR_CSMPT_L
            MOV (BRR_OUT_PTR_L)+Y, A        ;   Write the data out
            INCW BRR_OUT_PTR_L              ;__
            MOV A, X
            AND A, #$1F
            BNE ConvertToBRR_FormData
    .AfterEncoding:
        CLR7 BRR_TEMP_FLAGS
        CMP BRR_END_PTR_L, BRR_IN0_PTR_L;   If this is the last block, end
        BEQ ConvertToBRR_End        	;__   
        BBS7 BRR_FLAGS, ++              ;
        +   CMP X, #$20                     ;   
            BNE +                           ;   If we just used filter mode 1, 
            MOV A, $1E                      ;
            PUSH A                          ;   currentsmppoint = BRRBuffer[last]
            MOV A, $1F                      ;
            PUSH A                          ;__
        ++  JMP ConvertToBRR_SetupCopy
        +:                                  ;   If we just used filter mode 0,   
            MOV BRR_LSMPT_L, $3E            ;   smppoint = BRRBuffer[last]
            MOV BRR_LSMPT_H, $3F            ;__
            MOV A, #$00                     ;
            PUSH A                          ;   currentsmppoint = 0
            PUSH A                          ;__
            JMP ConvertToBRR_SetupCopy
    .End:
    RET

endif   ; !SNESFM_CFG_SAMPLE_GENERATE

if !SNESFM_CFG_PITCHTABLE_GEN >= 1
GeneratePitchTable:
    .Documentation:
        ; Inputs:
        ; YA = base pitch value of C7
    .Defines:
        GenPitch_CounterA      = $EA
        GenPitch_NewPitch_Lo   = $EC
        GenPitch_NewPitch_Hi   = $ED
        GenPitch_PrevPitch_Lo  = $EE
        GenPitch_PrevPitch_Hi  = $EF
        !GenPitch_RatioMult = 196   ;   196/185 ≈ 2^(1/12) - the ratio for 1 semitone
        !GenPitch_RatioDiv = 185    ;__
    
    .Start:
        MOV PitchTableLo+(7*12), A
        MOV PitchTableHi+(7*12), Y
        MOV GenPitch_PrevPitch_Lo, A
        MOV GenPitch_PrevPitch_Hi, Y
        MOV X, #$00
    
    .SemitoneUpLoop:
        MOV GenPitch_CounterA, X

        MOV Y, GenPitch_PrevPitch_Lo    ;
        MOV A, #!GenPitch_RatioMult     ;
        MUL YA                          ;   Multiply low byte
        MOV GenPitch_NewPitch_Lo, A     ;
        MOV GenPitch_NewPitch_Hi, Y     ;__

        MOV GenPitch_PrevPitch_Lo, #$00 ;
        MOV Y, GenPitch_PrevPitch_Hi    ;
        MOV A, #!GenPitch_RatioMult     ;   Multiply high byte
        MUL YA                          ;__
        ADDW YA, GenPitch_NewPitch_Hi   ; The next byte is 0, so it adds only the high byte as the mid byte

        MOV X, #!GenPitch_RatioDiv      ;   YA very conveniently stores the high and mid bytes
        DIV YA, X                       ;   Divide mid and high bytes
        MOV GenPitch_NewPitch_Hi, A     ;__

        MOV A, GenPitch_NewPitch_Lo     ;   Y very conveniently stores the remainder as the high byte
        MOV X, #!GenPitch_RatioDiv      ;   Divide low byte with remainder as high byte
        DIV YA, X                       ;__
        CMP Y, #!GenPitch_RatioDiv/2    ;   Round the number
        ADC A, #$00                     ;__

        MOV X, GenPitch_CounterA        ;
        MOV PitchTableLo+(7*12)+1+X, A  ;   Store low byte
        MOV GenPitch_PrevPitch_Lo, A    ;__
        MOV A, GenPitch_NewPitch_Hi     ;
        MOV PitchTableHi+(7*12)+1+X, A  ;   Store high byte
        MOV GenPitch_PrevPitch_Hi, A    ;__

        INC X
        CMP X, #11
        BNE GeneratePitchTable_SemitoneUpLoop

    .BitShiftStart:
        MOV GenPitch_CounterA, #12

    .BitShiftBigLoop:
        CLRC
        MOV A, #6*12
        ADC A, GenPitch_CounterA
        MOV X, A
        MOV A, PitchTableHi+12-1+X
        MOV GenPitch_NewPitch_Hi, A
        MOV A, PitchTableLo+12-1+X
        

        ..BitShiftLoop:
            LSR GenPitch_NewPitch_Hi        ;
            ROR A                           ;
            ADC A, #$00                     ;
            ADC GenPitch_NewPitch_Hi, #$00  ;__
            MOV Y, A

            MOV PitchTableLo-1+X, A
            MOV A, GenPitch_NewPitch_Hi
            MOV PitchTableHi-1+X, A

            MOV A, X
            SETC
            SBC A, #12
            BMI +
            MOV X, A

            MOV A, Y
            JMP GeneratePitchTable_BitShiftBigLoop_BitShiftLoop
        +:
        DBNZ GenPitch_CounterA, GeneratePitchTable_BitShiftBigLoop
    
    .OverflowCorrection:
        MOV X, #7*12+11

        ..Loop:
            MOV A, PitchTableHi+X       ;
            CMP A, #$40                 ;   If the value isn't overflowing, exit
            BMI GeneratePitchTable_End  ;__

            MOV A, #$3F                 ;
            MOV PitchTableHi+X, A       ;   Cap the pitch value
            MOV A, #$FF                 ;
            MOV PitchTableLo+X, A       ;__

            DEC X
            BPL GeneratePitchTable_OverflowCorrection_Loop

    .End:
        RET

endif   ; !SNESFM_CFG_PITCHTABLE_GEN

transferChToTemp:       ;TCALL 15
    PUSH A
    PUSH X

    MOV A, X
    CLRC
    ADC A, #$07
    MOV Y, A

    MOV X, #$07
    -:
        MOV A, CH1_POINTER_0+Y
        MOV CHTEMP_POINTER_0+X, A
        MOV A, CH1_POINTER_1+Y
        MOV CHTEMP_POINTER_1+X, A
        MOV A, CH1_POINTER_2+Y
        MOV CHTEMP_POINTER_2+X, A
        MOV A, CH1_POINTER_3+Y
        MOV CHTEMP_POINTER_3+X, A
        DEC Y
        DEC X
        BPL -

    POP X
    POP A
    RET

transferTempToCh:       ;TCALL 14
    PUSH A
    PUSH X


    MOV A, X
    CLRC
    ADC A, #$07
    MOV Y, A

    MOV X, #$07
    -:
        MOV A, CHTEMP_POINTER_0+X
        MOV CH1_POINTER_0+Y, A
        MOV A, CHTEMP_POINTER_1+X
        MOV CH1_POINTER_1+Y, A
        MOV A, CHTEMP_POINTER_2+X
        MOV CH1_POINTER_2+Y, A
        MOV A, CHTEMP_POINTER_3+X
        MOV CH1_POINTER_3+Y, A
        DEC Y
        DEC X
        BPL -

    POP X
    POP A
    RET

IndexToSamplePointer:   ;TCALL 13
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

END_OF_CODE: ; Label to determine how much space i have left

warnpc $5FFF

Includes:
    org $0C00
		LookupTables:
        incbin "multTables.bin"
    if !SNESFM_CFG_PITCHTABLE_GEN
        PitchTableLo = $0E00
        ParseInstrumentData_PitchTableLo = $0E00
        PitchTableHi = $0E60
        ParseInstrumentData_PitchTableHi = $0E60
        org $0EC0
    else
        org $0E00
            PitchTableLo:
            ParseInstrumentData_PitchTableLo:
            incbin "pitchLo.bin"
            PitchTableHi:
            ParseInstrumentData_PitchTableHi:
            incbin "pitchHi.bin"
    endif
        db $03, $00, $00, $00, $00, $00, $00, $00, $00 ;Dummy empty sample
    org $0F00
		SineTable:
        incbin "quartersinetable.bin"

    org $FFC0   ;For TCALLs
        dw transferChToTemp, transferTempToCh, IndexToSamplePointer

    ParseInstrumentData_InstrumentPtrLo = $0A00
    ParseInstrumentData_InstrumentPtrHi = $0B00
    InstrumentPtrLo = $0A00
    InstrumentPtrHi = $0B00

namespace off
