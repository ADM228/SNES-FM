;Song data variables for more readability when assembling manually
    ;Instrument data
        ;   Flags
            !UPD_SAMPLE = %01000000
            !UPD_SMP_POS_RELATIVE = %00001000   ;Unimplemented
            !UPD_ENVELOPE = %00000100
            !UPD_ARPEGGIO = %00000010
            !UPD_PITCHBEND = %00000001          ;Unimplemented
        ;   GAIN Envelopes
            !ENV_DIRECT = %00000000
            !ENV_DECREASE_LINEAR = %10000000
            !ENV_DECREASE_EXPONENTIAL = %10100000
            !ENV_INCREASE_LINEAR = %11000000
            !ENV_INCREASE_LINEAR = %11100000
        ;   Commands
            !COMMAND_CHANGE_INSTRUMENT_TYPE = %10000000
            !COMMAND_LOOP = %10100000

        ;   Instrument types
            !SAMPLE_SUBPAGE_0 = %00000000
            !SAMPLE_SUBPAGE_1 = %00010000
            !SAMPLE_SUBPAGE_2 = %00100000
            !SAMPLE_SUBPAGE_3 = %00110000
            !SAMPLE_HIGH_PAGE_0 = %00000000
            !SAMPLE_HIGH_PAGE_1 = %01000000
            !SAMPLE_USE_INDEX = %00001000
            !PITCHBEND_ABSOLUTE = %00000000
            !PITCHBEND_RELATIVE = %00000100
            !ENVELOPE_TYPE_ADSR = %00000000
            !ENVELOPE_TYPE_GAIN = %00000010
            !INSTRUMENT_TYPE_NOISE = %0000000
            !INSTRUMENT_TYPE_SAMPLE = %00000001 
    ;Song data
        !KEY_OFF = $FD
    ;Effect data
        !SET_VOLUME_LR_SAME = $00
        !SET_VOLUME_LR_DIFF = $01
        !SET_VOLUME_L = $02
        !SET_VOLUME_R = $03
        !VOLUME_LR_SLIDE_DOWN = $04
        !VOLUME_LR_SLIDE_UP = $05
        !VOLUME_LR_SLIDE_DOWN = $06
        !VOLUME_LR_SLIDE_UP = $07
        !VOLUME_L_SLIDE_DOWN = $08
        !VOLUME_R_SLIDE_DOWN = $09
        !VOLUME_L_SLIDE_UP = $0A
        !VOLUME_R_SLIDE_UP = $0B
    ;Common shit
        !WAIT = $FE
        !END_DATA = $FF

;Temporary variables, basically a shitton of names for the same thing
;$D0-DF are usually inputs while $E0-EF are just temporary variables used by routines
    ;Echo FIR set
        !ECH_FIR_FIRSTBYTE = $D0
    ;Pulse generation
        !PUL_OUT_PAGE = $D0
        !PUL_DUTY = $D1
        !PUL_FLAGS = $D2

        !PUL_OUT_PTR_L = $EE
        !PUL_OUT_PTR_H = $EF
    ;Long to short sample conversion
        !LTS_IN_PAGE = $D0
        !LTS_OUT_PAGE = $D1
        !LTS_OUT_SUBPAGE = $D2

        !LTS_IN_PTR_L = $EC
        !LTS_IN_PTR_H = $ED
        !LTS_OUT_PTR_L = $EE
        !LTS_OUT_PTR_H = $EF
    ;Phase modulation
        !MOD_CAR_PAGE = $D0
        !MOD_MOD_PAGE = $D1
        !MOD_OUT_PAGE = $D2
        !MOD_MOD_STRENGTH = $D3
        !MOD_MOD_PHASE_SHIFT = $D4
        !MOD_SUBPAGE = $D5  ;Only in short version (obviously)

        !MOD_CAR_INDEX_L = $E8  ;   Only in short phase modulation
        !MOD_END_INDEX_L = $E9  ;__
        !MOD_OUT_INDEX_L = $EA
        !MOD_OUT_INDEX_H = $EB
        !MOD_MOD_INDEX_L = $EC
        !MOD_MOD_INDEX_H = $ED
        !MOD_MAIN_TEMP_L = $EE
        !MOD_MAIN_TEMP_H = $EF
    ;Set/clear DP bit
        !CHG_BIT_ADDRESS = $D0
    ;PCM to BRR conversion
        !BRR_PCM_PAGE = $D0
        !BRR_OUT_INDEX = $D1
        !BRR_FLAGS = $D2

        !BRR_BUFF1_PTR_L = $20
        !BRR_BUFF1_PTR_H = $21
        !BRR_MAXM0_L = $F8  ;These registers are so unused
        !BRR_MAXM0_H = $F9  ;they're practically RAM!
        !BRR_TEMP_FLAGS = $E5
        !BRR_SMPPT_L = $E6
        !BRR_SMPPT_H = $E7
        !BRR_CSMPT_L = $E8
        !BRR_CSMPT_H = $E9
        !BRR_LSMPT_L = $EA  ;Last sample point of previous block for filter 1 adjustment
        !BRR_LSMPT_H = $EB  ;
        !BRR_IN0_PTR_L = $EC
        !BRR_IN0_PTR_H = $ED
        !BRR_OUT_PTR_L = $EE
        !BRR_OUT_PTR_H = $EF


;For channel updates, first 2 blocks of 8 bytes are stored in $C0-$CF, while the last one is stored in $D8-$DF
    !CH1_SONG_POINTER_L = $00
    !CH1_SONG_POINTER_H = $01
    !CH1_EFFECT_POINTER_L = $02
    !CH1_EFFECT_POINTER_H = $03
    !CH1_INSTRUMENT_INDEX = $04
    !CH1_INSTRUMENT_TYPE = $05
    !CH1_SAMPLE_POINTER_L = $06
    !CH1_SAMPLE_POINTER_H = $07

    !CH1_SONG_COUNTER = $40
    !CH1_EFFECT_COUNTER = $41
    !CH1_EFFECT_AMOUNT = $42
    ;$43 and $44 will be used by pitchbend
    !CH1_ARPEGGIO = $45
    !CH1_NOTE = $46
    !CH1_FLAGS = $47

    !CH1_INSTRUMENT_TYPE_COUNTER = $80
    !CH1_ENVELOPE_COUNTER = $81
    !CH1_SAMPLE_POINTER_COUNTER = $82
    !CH1_ARPEGGIO_COUNTER = $83
    !CH1_PITCHBEND_COUNTER = $84
    !CH1_COUNTERS_HALT = $86
    !CH1_COUNTERS_DIRECTION = $87


    !CHTEMP_POINTER_0 = $BF
    !CHTEMP_POINTER_1 = $C7
    !CHTEMP_POINTER_2 = $D7
    !CHTEMP_SONG_POINTER_L = $C0
    !CHTEMP_SONG_POINTER_H = $C1
    !CHTEMP_EFFECT_POINTER_L = $C2
    !CHTEMP_EFFECT_POINTER_H = $C3
    !CHTEMP_INSTRUMENT_INDEX = $C4
    !CHTEMP_INSTRUMENT_TYPE = $C5
    !CHTEMP_SAMPLE_POINTER_L = $C6
    !CHTEMP_SAMPLE_POINTER_H = $C7

    !CHTEMP_SONG_COUNTER = $C8
    !CHTEMP_EFFECT_COUNTER = $C9
    !CHTEMP_EFFECT_AMOUNT = $CA
    !CHTEMP_ARPEGGIO = $CD
    !CHTEMP_NOTE = $CE
    !CHTEMP_FLAGS = $CF

    !CHTEMP_INSTRUMENT_TYPE_COUNTER = $D8
    !CHTEMP_ENVELOPE_COUNTER = $D9
    !CHTEMP_SAMPLE_POINTER_COUNTER = $DA
    !CHTEMP_ARPEGGIO_COUNTER = $DB
    !CHTEMP_PITCHBEND_COUNTER = $DC
    !CHTEMP_COUNTERS_HALT = $DE     ;000paset
    !CHTEMP_COUNTERS_DIRECTION = $DF ;000paset

    ;Saved in the bottom half of the stack, not transferred to temporary registers
    !CH1_INSTRUMENT_TYPE_POINTER = $00
    !CH1_ENVELOPE_POINTER = $01
    !CH1_SAMPLE_POINTER_POINTER = $02
    !CH1_ARPEGGIO_POINTER = $03
    !CH1_PITCHBEND_POINTER = $04


;Just global variables used in song playback
    !TEMP_VALUE = $E0
    !CHTEMP_REGISTER_INDEX = $E1
    !TIMER_VALUE = $E2
    !PATTERN_END_FLAGS = $E3
    !PATTERN_POINTER_L = $E4
    !PATTERN_POINTER_H = $E5
    !TEMP_POINTER0_L = $E6
    !TEMP_POINTER0_H = $E7
    !TEMP_POINTER1_L = $F8
    !TEMP_POINTER1_H = $F9

