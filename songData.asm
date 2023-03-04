;Song format description (in developement):
;1. Instrument data
;   t {f ([s s]/[s]) ([v v]/[v]) [a] [p p] t}
;   t - Instrument type
;       ---hiret
;       h - Sample index "page" number
;       i - Choose sample by index, not absolute position
;       r - Relative pitchbends
;       e - Envelope type (if 0 - ADSR, if 1 - GAIN) (basically reverse x5.7)
;       t - Instrument type (0 - Noise, 1 - sample)
;   f - Flags
;       -sllrvap
;       s - Update sample
;       ll - Subpage of sample index
;       r - Update sample position relative to current position (works independently of i)
;       v - Update envelope 
;       a - Arpeggio (always relative)
;       p - Pitchbend
;       OR
;       1cccdddd
;       ccc - Special command
;       dddd - Argument
;       Command list:
;           00 - Change instrument type to ddddd
;           11 - End of instrument data
;       Afterwards, another f byte is there
;   [s s] - Raw sample position/offset in memory (if i is clear and s is set) / 
;   [s] - Sample index position/offset (if i is set and s is set)
;   [v] - New envelope value (if v is set)
;   [a] - Arpeggio (if a is set)
;   [p p] - Pitchbend (if p is set)
;   t - Time to wait until next updates
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
PatternData:
db $01, $00, $00, $00, $00, $00, $00, $00
db $01, $02, $00, $00, $00, $00, $00, $00
db !END_DATA
PatternPointers:
dw NoteDataNone
dw NoteDataBass1
dw NoteDataDrums1
dw NoteDataNone
dw NoteDataNone
dw NoteDataNone

;instrument data
Instr00Data:
db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_ADSR|!INSTRUMENT_TYPE_SAMPLE|!SAMPLE_USE_INDEX

db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO|!SAMPLE_SUBPAGE_0
db $00, $5E, $90, $00, $02

db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
db $01, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $02, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $03, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $04, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $05, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $06, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $07, $03

; db !UPD_SAMPLE|!SAMPLE_SUBPAGE_0
; db $08, $03

db !END_DATA

Instr01Data:
db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE

db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
dw $6288
db $7F, $00, $01
db !UPD_ENVELOPE|!UPD_ARPEGGIO, $8D, $F4, $01
db !UPD_ARPEGGIO, $EE, $01
db !UPD_ARPEGGIO, $E8, $01
db !UPD_ARPEGGIO, $E5, $01
db !UPD_ARPEGGIO, $E2, $01
db !UPD_ARPEGGIO, $DF, $01
db !UPD_ARPEGGIO, $DC, $01
db !UPD_ARPEGGIO, $DB, $01
db !UPD_ARPEGGIO, $DA, $01
db !UPD_ARPEGGIO, $D9, $01
db !UPD_ARPEGGIO, $D8, $01
db !UPD_ENVELOPE|!UPD_ARPEGGIO, $00, $01, $01


db !END_DATA

Instr02Data:
db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE

db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
dw $6240
db $60, $00, $01
db !UPD_ENVELOPE|!UPD_ARPEGGIO, $30, $EE, $01

db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_NOISE
db !UPD_ENVELOPE|!UPD_ARPEGGIO
db $8C, $19, $01
db !UPD_ARPEGGIO
db $1C, $03

db !END_DATA

Instr03Data:
db !COMMAND_CHANGE_INSTRUMENT_TYPE|!PITCHBEND_ABSOLUTE|!ENVELOPE_TYPE_GAIN|!INSTRUMENT_TYPE_SAMPLE

db !UPD_SAMPLE|!UPD_ENVELOPE|!UPD_ARPEGGIO
dw $6288
db $7F, $00, $02

db !UPD_ENVELOPE
db $8A, $03
db !END_DATA

NoteDataBass1:
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
db $BC, $01, $10
db !KEY_OFF, $40
db $BC, $01, $10
db !KEY_OFF, $20
db $BC, $01, $10
db !KEY_OFF, $20

db !END_DATA

NoteDataCh3:
db $FE, $80
db $FE, $80
db $FE, $80
db $FE, $80

db $FE, $80
db $FE, $80
db $FE, $80
db $FE, $80

db $FE, $80
db $FE, $80
db $FE, $80
db $FE, $80

db $FE, $18
db $CF, $00, $18
db $FE, $0C
db $CF, $00, $18
db $FE, $0C
db $D0, $00, $18
db $FE, $0C
db $FE, $01


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
db !END_DATA

NoteDataNoise:
db $81, $03, $7F
db $80, $03, $7F
db $81, $03, $7F
db $80, $03, $7F
db $81, $03, $7F
db $80, $03, $7F
db $81, $03, $7F
db $80, $03, $7F
db !END_DATA