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
    ;           1 byte:
    ;               00ppire0
    ;               pp - looping type for Pitchbend macro,
    ;       i - Choose sample by index, not absolute position
    ;       r - Relative pitchbends (not done yet)
    ;       e - Envelope type (if 0 - GAIN, if 1 - ADSR) (same as DSP register x5.7)
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
    ;[old]  i - Choose sample by index, not absolute position
    ;[old]  r - Relative pitchbends (not done yet)
    ;[old]  e - Envelope type (if 0 - GAIN, if 1 - ADSR) (same as DSP register x5.7)
    ;       t - Instrument type (0 - Noise, 1 - Sample)
    ;   3. The rest of the macros are straightforward
    ;   4. Instrument data instruction macros:
    ;   lss|$00 S D - If l=0 copy 128 PCM samples from page S to page D
    ;                   if l=1 resample 128 PCM samples from page S
    ;                   to 32 samples at page D subpage ss
    ;   lm0|$01 C [M] O S P [s] - Phase modulation:
    ;                   l - length (0 = 128 samples, 1 = 32 samples)
    ;                   C - Carrier page
    ;                   M - Modulator page [Only present if m=0, otherwise M=C]
    ;                   O - Output page
    ;                   S - Modulation strength
    ;                   P - Phase shift
    ;                   [s]-Subpages: ccmmoo-- [Only present if l=1]
    ;                       cc - Carrier subpage
    ;                       mm - Modulator subpage
    ;                       oo - Output subpage
    ;       $02     - Meta-opcode for the second half of phase modulation
    ;   lss|$03 O D F - Generate pulse wave
    ;                   O - Output page
    ;                   D - Duty cycle
    ;                   F - Flags: ddddddsz
    ;                       dddddd - Duty cycle (fractional part)
    ;                       s - starting value (0 - low, 1 - high)
    ;                       z - the low value (0 - 0, 1 - -$8000)



    ;   x00|$1A S D F [X] - BRR sample conversion:
    ;                   x - extended sample length mode (more than 1 sample)
    ;                   S - Source PCM page
    ;                   D - Destination BRR page
    ;                   F - Flags: fsi0ppbb
    ;                       f - whether to use filter mode 1
    ;                       s - short sample mode (32 samples instead of 128)
    ;                       i - high bit of output index
    ;                       pp - PCM sample subpage number (0-3, if s is set)
    ;                       bb - BRR output subpage number (0-3, if s is set)
    ;                   [X]-Number of samples-2 [Only present if x is set]
    ;    0ss|$1C X Y - Conserve the opcode arguments (as bitmasked by X, unnes. args count)
    ;                   for Y opcodes after it
    ;                   Can have 4 conservation settings at once, indicated by ss
    ;       $1D [db]- New instrument header
    ;                   The pointers in the data block are relative
    ;                   to the beginning of the aforementioned raw
    ;                   global instrument data block
    ;       $1E X X - Raw global instrument data block
    ;                   X X - 16-bit size
    ;       $1F     - End of instrument generation data

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
            !INSTRUMENT_TYPE_NOISE = %00000000
            !INSTRUMENT_TYPE_SAMPLE = %00000001
    ;Instrument data opcodes
        !COPY_RSMP      = $00
        !PHASEMOD       = $01
        !PULSEGEN       = $03

        !BRRGEN         = $1A
        !CONSERVE_ARGS  = $1C
        !INS_NEW_HDR    = $1D
        !INS_DATA_BLOCK = $1E
        !INS_DATA_END   = $1F
    ;Instrument data internal parameters
        !LONG_          = %00000000
        !SHORT          = %10000000

        !SUBP0          = %00000000
        !SUBP1          = %00100000
        !SUBP2          = %01000000
        !SUBP3          = %01100000

        !MOD_SELF       = %01000000

    ;Memory locations
        !BASE_MEMORY    = $5000

arch spc700
base $1000
InstrGenData:
db !SHORT|!SUBP0|!COPY_RSMP, $0F, $20
db !SHORT|!MOD_SELF|!PHASEMOD, $20, $20, $20, $00, $04
db !SUBP0|!CONSERVE_ARGS, %11000000, 14 ; Carrier and modulator pages remain the same
db !SUBP1|!CONSERVE_ARGS, %00100000, 2  ; Output page
db !SHORT|!PHASEMOD,      $1E, $02, $08
db !SHORT|!PHASEMOD,      $1C, $04, $0C

db !SHORT|!PHASEMOD, $21, $1A, $06, $00
db !SUBP1|!CONSERVE_ARGS, %00100000, 3  ; Output page
db !SHORT|!PHASEMOD,      $18, $08, $04
db !SHORT|!PHASEMOD,      $16, $0A, $08
db !SHORT|!PHASEMOD,      $14, $0C, $0C

db !SHORT|!PHASEMOD, $22, $12, $0E, $00
db !SUBP1|!CONSERVE_ARGS, %00100000, 3  ; Output page
db !SHORT|!PHASEMOD,      $10, $10, $04
db !SHORT|!PHASEMOD,      $0E, $12, $08
db !SHORT|!PHASEMOD,      $0C, $14, $0C

db !SHORT|!PHASEMOD, $23, $0A, $16, $00
db !SUBP1|!CONSERVE_ARGS, %00100000, 3  ; Output page
db !SHORT|!PHASEMOD,      $08, $18, $04
db !SHORT|!PHASEMOD,      $06, $1A, $08
db !SHORT|!PHASEMOD,      $04, $1C, $0C


db !BRRGEN, $20, $00, %11000100
db !SUBP0|!CONSERVE_ARGS, %10000000, 2  ; Source page
db !BRRGEN,      $01, %11001000
db !BRRGEN,      $02, %11001100

db !BRRGEN, $21, $03, %11000000
db !SUBP0|!CONSERVE_ARGS, %10000000, 3  ; Source page
db !BRRGEN,      $04, %11000100
db !BRRGEN,      $05, %11001000
db !BRRGEN,      $06, %11001100

db !BRRGEN, $22, $07, %11000000
db !SUBP0|!CONSERVE_ARGS, %10000000, 3  ; Source page
db !BRRGEN,      $08, %11000100
db !BRRGEN,      $09, %11001000
db !BRRGEN,      $0A, %11001100

db !BRRGEN, $23, $0B, %11000000
db !SUBP0|!CONSERVE_ARGS, %10000000, 3  ; Source page
db !BRRGEN,      $0C, %11000100
db !BRRGEN,      $0D, %11001000
db !BRRGEN,      $0E, %11001100

db !SHORT|!PULSEGEN, $28, $20, $03
db !BRRGEN, $28, $FF, %11000000

db !INS_DATA_BLOCK
dw InsDBEnd-InsDB ; InsDB is already 0

pushbase
base $0000
InsDB:
    i00InsType:
    i03InsType:
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_ADSR|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX|!SAMPLE_SUBPAGE_0
    i01InsType:
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_ADDRESS
    i02InsType:
    i04InsType:
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE|!SAMPLE_USE_INDEX
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX
    db !PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE|!SAMPLE_USE_INDEX

    i00Envelope:
    i03Envelope:
    db $5E, $90
    i01Envelope:
    db $7F, $00
    i02Envelope:
    db $0C, $7F, $7F, $10, !ENV_DECREASE_LINEAR|$06
    i04Envelope:
    db $0C, !ENV_DECREASE_LINEAR|$0A

    i03SmpPtr:
    db $00, $00, $01, $02
    db $03, $04, $05, $06
    db $07, $08, $09, $0A
    db $0B, $0C, $0D, $0E
    i00SmpPtr:
    db $0E
    i01SmpPtr:
    dw $6288
    i04SmpPtr:
    i02SmpPtr:
    db $FF

    i00Pitchbend:
    i01Arpeggio:
    i01Pitchbend:
    i02Pitchbend:
    i03Arpeggio:
    i03Pitchbend:
    i04Pitchbend:
    db $00, $F4, $EE, $E8
    db $E5, $E2, $DF, $DC
    db $DB, $DA, $D9, $D8
    db $00

    i02Arpeggio:
    db $1D, $2C, $2A, $1D

    i04Arpeggio:
    db $3F

    i00Arpeggio:
    db $0C, $00

InsDBEnd:

pullbase

db !INS_NEW_HDR

    Instr00Data:
    .Header:
    db %00000000, %00000000    ;Looping, everything one-shot for now

    dw !BASE_MEMORY-(InsDBEnd-i00InsType)
    db $01, $00     ;
    dw !BASE_MEMORY-(InsDBEnd-i00Envelope)
    db $02, $00
    dw !BASE_MEMORY-(InsDBEnd-i00SmpPtr)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i00Arpeggio)
    db $02, $00
    dw !BASE_MEMORY-(InsDBEnd-i00Pitchbend)
    db $01, $00

db !INS_NEW_HDR

    Instr01Data:
    .Header:
    db %00000000, %00000000

    dw !BASE_MEMORY-(InsDBEnd-i01InsType)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i01Envelope)
    db $02, $0B
    dw !BASE_MEMORY-(InsDBEnd-i01SmpPtr)
    db $02, $00
    dw !BASE_MEMORY-(InsDBEnd-i01Arpeggio)
    db $0C, $00
    dw !BASE_MEMORY-(InsDBEnd-i01Pitchbend)
    db $01, $00

db !INS_NEW_HDR

    Instr02Data:
    i02:
    .Header:
    db %00000000, %00000000

    dw !BASE_MEMORY-(InsDBEnd-i02InsType)
    db $04, $00
    dw !BASE_MEMORY-(InsDBEnd-i02Envelope)
    db $05, $00
    dw !BASE_MEMORY-(InsDBEnd-i02SmpPtr)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i02Arpeggio)
    db $04, $00
    dw !BASE_MEMORY-(InsDBEnd-i02Pitchbend)
    db $01, $00

db !INS_NEW_HDR

    Instr03Data:
    .Header:
    db %00000000, %00000000    ;Looping, everything one-shot for now

    dw !BASE_MEMORY-(InsDBEnd-i03InsType)
    db $01, $00     ;
    dw !BASE_MEMORY-(InsDBEnd-i03Envelope)
    db $02, $00
    dw !BASE_MEMORY-(InsDBEnd-i03SmpPtr)
    db $10, $03
    dw !BASE_MEMORY-(InsDBEnd-i03Arpeggio)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i03Pitchbend)
    db $01, $00

db !INS_NEW_HDR

    Instr04Data:
    i04:
    .Header:
    db %00000000, %00000000

    dw !BASE_MEMORY-(InsDBEnd-i04InsType)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i04Envelope)
    db $02, $00
    dw !BASE_MEMORY-(InsDBEnd-i04SmpPtr)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i04Arpeggio)
    db $01, $00
    dw !BASE_MEMORY-(InsDBEnd-i04Pitchbend)
    db $01, $00


db !INS_DATA_END
arch 65816
base off
; some ol data:
    ;     db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX

    ;     db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
    ;     db $FF, $7F, $00, $02

    ;     db !UPD_ENVELOPE
    ;     db $8A, $03
    ;     db !END_DATA



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
