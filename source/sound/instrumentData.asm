;Song format description (in development):
    ;1. Instrument data
    ;   1. Header:
    ;           == legacy ==
    ;       2 bytes for looping
    ;           == for future ==
    ;       1 byte: amount of sections (0-3)
    ;       {amount of sections} times:
    ;           5 start indexes for the section
    ;           5 start of loop indexes for the section
    ;           5 end of loop indexes for the section
    ;           5 speed bytes
    ;           1 byte:
    ;               tteessaa
    ;               tt - looping type for Instrument Type macro,
    ;               ee -    Envelope macro,
    ;               ss -    Sample Pointer macro,
    ;               aa -    Arpeggio macro
    ;       1 byte describing looping type for pitchbend macro
    ;           == end of for future ==
    ;       5 times:
    ;           Pointer to {macro} macro,
    ;           Total Length (legacy), Speed (legacy)
    ;       for Instrument Type,
    ;           Envelope,
    ;           Sample Pointer,
    ;           Arpeggio,
    ;           Pitchbend (currently unimplemented)
    ;   2. Instrument Type macro:
    ;       0hssiret
    ;       h - Sample index "page" number
    ;       ss - Subpage of sample index
    ;       i - Choose sample by index, not absolute position
    ;       r - Relative pitchbends (not done yet)
    ;       e - Envelope type (if 0 - GAIN, if 1 - ADSR) (same as DSP register x5.7)
    ;       t - Instrument type (0 - Noise, 1 - Sample)
    ;   3. The rest of the macros are straightforward

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
    ;Common shit
        !WAIT = $FE
        !END_DATA = $FF

; PatternData:
;     db $01, $00, $00, $00, $00, $00, $00, $00
; ;    db $01, $02, $00, $00, $00, $00, $00, $00
; ;    db $01, $03, $00, $00, $00, $00, $00, $00
; ;    db $01, $02, $00, $00, $00, $00, $00, $00
; ;    db $01, $01, $02, $00, $00, $00, $00, $00

;     ;db $01, $02, $00, $00, $00, $00, $00, $00
; ;    db $04, $00, $00, $00, $00, $00, $00, $00
;     db !END_DATA
; PatternPointers:
;     dw NoteDataNone
;     ; dw NoteDataBass1
;     dw nNoteDataBass1
;     dw NoteDataDrums1
;     dw NoteDataDrums2
;     dw NoteDataLong
;     dw NoteDataNone

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

;     db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX

;     db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
;     db $FF, $7F, $00, $02

;     db !UPD_ENVELOPE
;     db $8A, $03
;     db !END_DATA