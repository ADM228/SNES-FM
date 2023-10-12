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
    ;2. New song data
    ;   Is opcode-based.
    ;   Opcodes:
    ;       $00-$5F - Note (C0-B7)
    ;       $60     - Set the instrument number high bits to 00,
    ;       $61     -                                        01,
    ;       $62     -                                        10,
    ;       $63     -                                        11
    ;       $64-$67 - Set instrument section to (opcode - $64)
    ;       $68     - Disable attack
    ;       $69 xx  - Set separate arpeggio table ($00 means none,
    ;                   overrides the instruments arpeggio)
    ;       $6A xx  - Same but with pitch 
    ;       $6B xx  - Fine pitch (center is $80,
    ;                   formula - Probably a lookup table or some shit
    ;
    ;       $6C-$6F - Not filled yet       
    ;
    ;       $70 xx  - Set left volume
    ;       $71 xx  - Set right volume
    ;       $72 xx  - Set both volumes
    ;       $73 X Y Z - Left volume slide
    ;       $74 X Y Z - Right volume slide
    ;       $75 X Y Z - Both volume slide
    ;           (X - Step size whole part & sign,
    ;            Y - Step size fractional part,
    ;            Z - Target volume,
    ;            1 byte each)
    ;
    ;       $76-$7C - Not filled yet
    ;
    ;       $7D     - Key off
    ;       $7E     - Set reference
    ;       $7F     - Loop
    
    ;       $80-$FE - Set instrument to (high bits) | (opcode >> 1)
    ;       $81-$FF - Wait opcode >> 1 frames
    ;       
    ;       with



    ;2. Legacy song data
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
    ;3. Probably legacy Effect data
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
        !SET_INST_HIGHBITS = $60
        !SET_INST_SECTION = $64

        !NO_ATTACK = $68
        !ARP_TABLE = $69
        !PITCH_TABLE = $6A
        !FINE_PITCH = $6B

        !VOL_SET_L = $70
        !VOL_SET_R = $71
        !VOL_SET_BOTH = $72
        !VOL_SLIDE_L = $73
        !VOL_SLIDE_R = $74
        !VOL_SLIDE_BOTH = $75

        !KEY_OFF = $7D
        !SET_REF  = $7E
        !LOOP = $7F
        
        !INSTRUMENT = $80
        !nWAIT = $81

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
;    db $01, $02, $00, $00, $00, $00, $00, $00
;    db $01, $03, $00, $00, $00, $00, $00, $00
;    db $01, $02, $00, $00, $00, $00, $00, $00
;    db $01, $01, $02, $00, $00, $00, $00, $00

    ;db $01, $02, $00, $00, $00, $00, $00, $00
;    db $04, $00, $00, $00, $00, $00, $00, $00
    db !END_DATA
PatternPointers:
    dw NoteDataNone
    ; dw NoteDataBass1
    dw nNoteDataBass1
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

nNoteDataBass1:
    db !INSTRUMENT|($00<<1)  ; Set instrument to 0
    db !VOL_SET_BOTH, $7F
    db $30, !nWAIT|($10<<1)
    db !VOL_SET_BOTH, $40
    db $30, !nWAIT|($10<<1)
    db !VOL_SET_BOTH, $20
    db $30, !nWAIT|($10<<1)
    db !VOL_SET_BOTH, $7F
    db $3C, !nWAIT|($10<<1)
    db $30, !nWAIT|($10<<1)
    db $33, !nWAIT|($10<<1)
    db $3F, !nWAIT|($10<<1)
    db $33, !nWAIT|($10<<1)
    db $36, !nWAIT|($10<<1)
    db $42, !nWAIT|($10<<1)
    db $39, !nWAIT|($10<<1)

    db !END_DATA

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
