;Song format description (in developement):
;1. Instrument data
;   t {f ([s s]/[s]) ([v v]/[v]) [a] [p p] t}
;   t - Instrument type
;       000000et
;       e - Envelope type (if 0 - ADSR, if 1 - GAIN) (basically reverse x5.7)
;       t - Instrument type (0 - Noise, 1 - sample)
;   f - Flags
;       0sirnvap
;       s - Update sample
;       i - Choose sample by index, not absolute position
;       r - Update sample position relative to current position (works independently of i)
;       n - Index "page" number (when i is set)
;       v - Update envelope 
;       a - Arpeggio (always relative)
;       p - Pitchbend
;       OR
;       1cccdddd
;       ccc - Special command
;       dddd - Argument
;       Command list:
;           000 - Change instrument type to dddd
;           111:
;               if dddd = 1111, end of instrument data
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
db $00, $01, $02, $03, $FF
PatternPointers:
dw NoteDataCh1
dw NoteDataCh2
dw NoteDataCh3
dw NoteDataCh4

;instrument data
Instr00Data:
db %10000011

db %01000110
dw $6000
db $7F, $00, $02

db %01000100
dw $6048
db $8A, $03

db %01000000
dw $6090
db $03

db %01000000
dw $60D8
db $03

db %01000000
dw $6120
db $03

db %01000000
dw $6168
db $03

db %01000000
dw $61B0
db $03

db %01000000
dw $61F8
db $03

db %01000000
dw $6240
db $03

;db %00000100, $10, $00


db $FF

Instr01Data:
db %10000011

db %01000110
dw $6240
db $7F, $00, $01
db %00000110, $8D, $F4, $00
db %00000010, $EE, $00
db %00000010, $E8, $00
db %00000010, $E5, $00
db %00000010, $E2, $00
db %00000010, $DF, $00
db %00000010, $DC, $00
db %00000010, $DB, $00
db %00000010, $DA, $00
db %00000010, $D9, $00
db %00000010, $D8, $00
db %00000110, $00, $00, $00


db $FF

Instr02Data:
db %10000011

db %01000110
dw $6240
db $60, $00, $01
db %00000110, $30, $EE, $00

db %10000010
db %00000110
db $8C, $19, $01
db %00000010
db $1C, $03

db $FF

NoteDataCh1:
db $B0, $00, $0C
db $3C, $0C
db $30, $0C
db $3c, $0C

db $B0, $00, $0C
db $33, $0C
db $34, $0C
db $B5, $00, $18
db $B5, $00, $0C
db $41, $0C 
db $BF, $00, $18
db $41, $0C 
db $B5, $00, $0C
db $34, $0C

db $B3, $00, $24
db $BF, $00, $18
db $B3, $00, $18
db $B0, $00, $18
db $B0, $00, $18
db $BC, $00, $18
db $B0, $00, $0C
db $BC, $00, $18

db $B5, $00, $18
db $C1, $00, $0C
db $B3, $00, $18
db $BF, $00, $0C
db $B0, $00, $18

db $BC, $00, $0C
db $AE, $00, $18
db $BA, $00, $0C

db $AB, $00, $0C
db $A9, $00, $0C
db $AE, $00, $0C
db $AB, $00, $18
db $B0, $00, $30
db $A4, $00, $24

db $B0, $00, $0C
db $AE, $00, $0C
db $FE, $0C
db $A9, $00, $0C

db $FE, $0C
db $AB, $00, $0C
db $FE, $0C
db $AE, $00, $0C

db $B0, $00, $0C
db $3C, $0C
db $30, $0C
db $3c, $0C

db $B0, $00, $0C
db $33, $0C
db $34, $0C
db $B5, $00, $18
db $B5, $00, $0C
db $41, $0C 
db $BF, $00, $18
db $41, $0C 
db $B5, $00, $0C
db $34, $0C

db $B3, $00, $24
db $BF, $00, $18
db $B3, $00, $18
db $B0, $00, $18
db $B0, $00, $18
db $BC, $00, $18
db $B0, $00, $0C
db $BC, $00, $18

db $B5, $00, $18
db $C1, $00, $0C
db $B3, $00, $18
db $BF, $00, $0C
db $B0, $00, $18

db $BC, $00, $0C
db $AE, $00, $18
db $BA, $00, $0C

db $AB, $00, $0C
db $A9, $00, $0C
db $AE, $00, $0C
db $AB, $00, $18
db $B0, $00, $30
db $A4, $00, $24

db $B0, $00, $0C
db $AE, $00, $0C
db $FE, $0C
db $A9, $00, $0C

db $FE, $0C
db $AB, $00, $0C
db $FE, $0C
db $AE, $00, $0C

db $FE, $80

db $FF

NoteDataCh2:
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
db $CB, $00, $24
db $CB, $00, $24
db $CD, $00, $24
db $FE, $01

db $FF

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


db $FF

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


db $FF
