;Song data variables for more readability when assembling manually
    ;Instrument data
        ;   GAIN Envelopes
            !ENV_DIRECT = %00000000
            !ENV_DECREASE_LINEAR = %10000000
            !ENV_DECREASE_EXPONENTIAL = %10100000
            !ENV_INCREASE_LINEAR = %11000000
            !ENV_INCREASE_LINEAR = %11100000
        ;   Instrument types
            !SAMPLE_SUBPAGE_0 = %00000000
            !SAMPLE_SUBPAGE_1 = %00010000
            !SAMPLE_SUBPAGE_2 = %00100000
            !SAMPLE_SUBPAGE_3 = %00110000
            !SAMPLE_HIGH_PAGE_0 = %00000000
            !SAMPLE_HIGH_PAGE_1 = %01000000
            !SAMPLE_USE_INDEX = %00000000
            !SAMPLE_USE_ADDRESS = %00001000
            !PITCHBEND_ABSOLUTE = %00000000
            !PITCHBEND_RELATIVE = %00000100
            !ENVELOPE_TYPE_GAIN = %00000000
            !ENVELOPE_TYPE_ADSR = %00000010
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
    !CH1_SONG_POINTER_L = $0800
    !CH1_SONG_POINTER_H = $0801
    !CH1_EFFECT_POINTER_L = $0802
    !CH1_EFFECT_POINTER_H = $0803
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

    CHTEMP_POINTER_0 = $20
    CHTEMP_POINTER_1 = $28
    CHTEMP_POINTER_2 = $30
    CHTEMP_POINTER_3 = $38

    CH1_POINTER_0 = $0800
    CH1_POINTER_1 = $0840
    CH1_POINTER_2 = $0880
    CH1_POINTER_3 = $08C0

    CHTEMP_SONG_POINTER_L = $20
    CHTEMP_SONG_POINTER_H = $21
    CHTEMP_EFFECT_POINTER_L = $22
    CHTEMP_EFFECT_POINTER_H = $23
    CHTEMP_INSTRUMENT_INDEX = $24
    CHTEMP_INSTRUMENT_TYPE = $25
    CHTEMP_SAMPLE_POINTER_L = $26
    CHTEMP_SAMPLE_POINTER_H = $27

    CHTEMP_SONG_COUNTER = $28
    CHTEMP_EFFECT_COUNTER = $29
    CHTEMP_EFFECT_AMOUNT = $2A
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

;Just global variables used in song playback
    !TEMP_VALUE = $00
    !TIMER_VALUE = $01
    !CHANNEL_REGISTER_INDEX = $02
    !CHANNEL_BITMASK = $03
    !PATTERN_POINTER_L = $04
    !PATTERN_POINTER_H = $05
    !TEMP_VALUE2 = $06
    !PATTERN_END_FLAGS = $07
    !TEMP_POINTER0_L = $0C
    !TEMP_POINTER0_H = $0D
    !TEMP_POINTER1_L = $0E
    !TEMP_POINTER1_H = $0F




