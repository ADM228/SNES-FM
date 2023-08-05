;Song format description (in development):
    ;1. Instrument data
    ;======================== irrelevant old ===============================
    ;   t {f ([s s]/[s]) ([v v]/[v]) [a] [p p] t}
    ;   t - Instrument type change command
    ;       100hiret
    ;       h - Sample index "page" number
    ;       i - Choose sample by index, not absolute position
    ;       r - Relative pitchbends (not done yet)
    ;       e - Envelope type (if 0 - ADSR, if 1 - GAIN) (basically reverse x5.7)
    ;       t - Instrument type (0 - Noise, 1 - sample)
    ;   f - Flags
    ;       0sllrvap
    ;       s - Update sample
    ;       ll - Subpage of sample index
    ;       r - Update sample position relative to current position (works independently of i) (not done yet)
    ;       v - Update envelope 
    ;       a - Arpeggio (always relative)
    ;       p - Pitchbend (not done yet)
    ;       OR
    ;       1ccddddd [l]
    ;       cc - Special command
    ;       ddddd - Argument
    ;       Command list:
    ;           00 - Change instrument type to ddddd
    ;           01 - Loop forever to 000ddddd [ l ] + $1000
    ;           11 - End of instrument data
    ;       Afterwards, another f byte is there
    ;   [s s] - Raw sample position/offset in memory (if i is clear and s is set) / 
    ;   [s] - Sample index position/offset (if i is set and s is set)
    ;   [v] - New envelope value (if v is set)
    ;   [a] - Arpeggio (if a is set)
    ;   [p p] - Pitchbend (if p is set)
    ;   t - Time to wait until next updates
    ;============================================================================
    ;2. Song data
    ;   e e {n [i] t} $FF
    ;   n - Note
    ;       rnnnnnnn
    ;       r - Retrigger/change instrument
    ;       nnnnnnn - Note number
    ;       Special commands in note number:
    ;       $FD - Do nothing and wait
    ;       $FE - Key off and wait
    ;       $FF - End of song data for this pattern
    ;   [i] - Instrument number (if r is set)
    ;   t - Time to wait until next note
    ;3. Effect data
    ;   $00 v - Set main left volume
    ;   $01 v - Set main right volume
    ;   $02 v - Set main both left and right volume
    ;   $03 v - Set echo left volume
    ;   $04 v - Set echo right volume
    ;   $05 v - Set echo both left and right volume
    ;   $FE t - Wait 
    ;   $FF - End effect data

;Song data variables for more readability when assembling manually
    ;Instrument data
        ;   GAIN Envelopes
            !ENV_DIRECT = %00000000
            !ENV_DECREASE_LINEAR = %10000000
            !ENV_DECREASE_EXPONENTIAL = %10100000
            !ENV_INCREASE_LINEAR = %11000000
            !ENV_INCREASE_BENTLINE = %11100000
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

PatternData:
    db $01, $00, $00, $00, $00, $00, $00, $00
    db $01, $02, $00, $00, $00, $00, $00, $00
    db $01, $03, $00, $00, $00, $00, $00, $00
    db $01, $02, $00, $00, $00, $00, $00, $00
    db $01, $01, $02, $00, $00, $00, $00, $00

    ;db $01, $02, $00, $00, $00, $00, $00, $00
    db $04, $00, $00, $00, $00, $00, $00, $00
    db !END_DATA
PatternPointers:
    dw NoteDataNone
    dw NoteDataBass1
    dw NoteDataDrums1
    dw NoteDataDrums2
    dw NoteDataLong
    dw NoteDataNone


Instr03Data:
Instr00Data:
.Header:
db %00000000, %00000000    ;Looping, everything one-shot for now

dw Instr00Data_InsType
db $00, $00     ;

dw Instr00Data_Envelope
db $00, $00

dw Instr00Data_SmpPtr
db $0F, $00

dw Instr00Data_Arpeggio
db $00, $00

dw Instr00Data_Pitchbend
db $00, $00
.InsType:
db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_ADSR|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX|!SAMPLE_SUBPAGE_0
.Envelope:
db $5E, $90
.SmpPtr:
db $00, $00, $01, $02
db $03, $04, $05, $06
db $07, $08, $09, $0A
db $0B, $0C, $0D, $0E
.Arpeggio:
.Pitchbend:
db $00



; 
;     db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE

;     db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
;     dw $6240
;     db $60, $00, $01
;     db !UPD_ENVELOPE|!UPD_ARPEGGIO, $30, $EE, $01

;     db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE
;     db !UPD_ENVELOPE|!UPD_ARPEGGIO
;     db $8C, $19, $01
;     db !UPD_ARPEGGIO
;     db $1C, $03

;     db !END_DATA

Instr01Data:
i01:
.Header:
db %00000000, %00000000

dw i01_InsType
db $00, $00
dw i01_Envelope
db $01, $0B
dw i01_SmpPtr
db $00, $00
dw i01_Arpeggio
db $0B, $00
dw i01_Pitchbend
db $00, $00

.InsType: db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_ADDRESS
.Envelope:
db $7F, $00
.SmpPtr: dw $6288
.Arpeggio:
db $00, $F4, $EE, $E8
db $E5, $E2, $DF, $DC
db $DB, $DA, $D9, $D8
.Pitchbend:
db $00  ;also used by arpeggio

Instr02Data:
i02:
.Header:
db %00000000, %00000000

dw i02_InsType
db $03, $01
dw i02_Envelope
db $04, $01
dw i02_SmpPtr
db $00, $00
dw i02_Arpeggio
db $03, $01
dw i02_Pitchbend
db $00, $00

.InsType:
db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE|!SAMPLE_USE_INDEX
db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX
db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX
db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE|!SAMPLE_USE_INDEX
.Envelope:
db $20, $7F, $7F, $20, !ENV_DECREASE_LINEAR|$06
.SmpPtr:
db $FF
.Arpeggio:
db $1D, $2C, $2A, $1D
.Pitchbend:
db $00


; Instr03Data:
;     db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX

;     db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
;     db $FF, $7F, $00, $02

;     db !UPD_ENVELOPE
;     db $8A, $03
;     db !END_DATA

NoteDataBass1:
    dw EffectDataBass
    db $B0, $00, $10
    db $B0, $00, $10
    db $B0, $00, $10
    db $BC, $00, $10
    db $B0, $00, $10
    db $B3, $00, $10
    db $BF, $00, $10
    db $B3, $00, $10
    db $B6, $00, $10
    db $C2, $00, $10
    db $B9, $00, $10

    db !END_DATA

NoteDataDrums1:
    dw EffectDataNone
    db $BC, $01, $10
    db !KEY_OFF, $40
    db $BC, $01, $10
    db !KEY_OFF, $20
    db $BC, $01, $10
    db !KEY_OFF, $20

    db !END_DATA

NoteDataDrums2:
    dw EffectDataNone
    db $BC, $01, $10
    db !KEY_OFF, $10
	db $BC, $01, $10
	db $80, $02, $20

    db $BC, $01, $10
    db !KEY_OFF, $10
    db $BC, $01, $10
    db $80, $02, $20
	db $BC, $01, $10

    db !END_DATA

NoteDataLong:
    dw EffectDataNone
    db !WAIT, $80
    db !WAIT, $80
    db !WAIT, $80
    db !WAIT, $80


    db !END_DATA

NoteDataCh4:
    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $0C
    db $C0, $02, $0C
    db $C8, $01, $0C

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C0, $02, $0C
    db $C8, $01, $0C
    db $FE, $18

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $0C
    db $C0, $02, $0C
    db $C8, $01, $0C


    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C0, $02, $0C
    db $C8, $01, $0C
    db $FE, $18

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $0C
    db $C0, $02, $0C
    db $C8, $01, $0C

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C0, $02, $0C
    db $C8, $01, $0C
    db $FE, $18

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $0C
    db $C0, $02, $0C
    db $C8, $01, $0C


    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C8, $01, $0C
    db $FE, $24

    db $C0, $02, $0C
    db $C8, $01, $0C
    db $FE, $18

    db $FE, $18
    db $D2, $00, $18
    db $FE, $0C
    db $D2, $00, $18
    db $FE, $0C
    db $D4, $00, $18
    db $FE, $18

NoteDataNone:
    dw EffectDataNone
EffectDataNone:
    db !END_DATA

NoteDataNoise:
    dw EffectDataNone
    db $81, $03, $7F
    db $80, $03, $7F
    db $81, $03, $7F
    db $80, $03, $7F
    db $81, $03, $7F
    db $80, $03, $7F
    db $81, $03, $7F
    db $80, $03, $7F
    db !END_DATA

EffectDataBass:
    db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $40, $00, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $00, $20, !WAIT, $10
    ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $10, $08, !WAIT, $10
    ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $00, $40, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $20, $00, !WAIT, $10
    ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $00, $40, !WAIT, $10
    ; db !SET_VOLUME_LR_DIFF, $20, $00, !WAIT, $10
    db !END_DATA
