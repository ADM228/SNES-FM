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
;   t - Time to wait until next updates
;2. Song data
;   n [i] t
;   n - Note
;       rnnnnnnn
;       r - Retrigger/change instrument
;       nnnnnnn - Note number
;   [i] - Instrument number (if r is set)
;   t - Time to wait until next note
PatternData:
; db $00, $01, $00, $00, $00, $00, $00, $00
; db $00, $02, $03, $04, $05, $06, $00, $07
; db $00, $01, $08, $09, $0A, $0B, $00, $0C
; db $00, $02, $0D, $0E, $0F, $10, $00, $11
; db $00, $01, $12, $13, $14, $15, $00, $16
; db $00, $02, $17, $18, $19, $1A, $00, $1B
; db $00, $1C, $1D, $1E, $1F, $20, $00, $21
; db $00, $1C, $22, $23, $24, $25, $00, $26
db $03, $00, $00, $00
db $01, $02, $00, $00
db $01, $02, $00, $00
db $FF


Instr00Data:    ;hi-hat
db %10000010, %01000110
dw $6000
db $7F, $1F, $02

db %00000100
db $BB, $01

db $FF

Instr01Data:    ;snare
db %10000010, %01000110
dw $6000
db $50, $0F, $01

db %00000010
db $16, $01

db %00000010
db $1C, $01

db %00000010
db $1D, $02

db %00000100
db $8A, $02

db $FF

Instr02Data:    ;kick
db %10000011

db %01000110
dw $61F8
db $7F, $00, $02
db %00000010, $F4, $01
db %00000010, $EE, $01
db %00000010, $E8, $01
db %00000010, $E5, $01
db %00000010, $E2, $01
db %00000010, $DF, $01
db %00000010, $DC, $01
db %00000110, $00, $00, $01


db $FF

Instr03Data:    ;Triangle decaying
db %10000011

db %01000110
dw $61F8
db $7F, $00, $01

db %00000100, $6E, $01
db %00000100, $5D, $01
db %00000100, $4C, $01
db %00000100, $3B, $01
db %00000100, $2A, $01
db %00000100, $22, $01
db %00000100, $19, $01
db %00000100, $11, $01
db %00000100, $08, $02
db %00000100, $00, $01
db $FF


PatternPointers:
dw PatternEmpty, Pattern00, Pattern01, Pattern02

PatternEmpty:
db $FE, $01
db $FF

Pattern00:
db $80, $00, $05
db $80, $00, $06
db $80, $00, $05
db $80, $00, $06

db $80, $01, $0B
db $80, $00, $05
db $80, $00, $06

db $80, $00, $05
db $80, $00, $06
db $80, $00, $05
db $80, $00, $06

db $80, $01, $0B
db $80, $00, $05
db $80, $01, $06

db $80, $00, $05
db $80, $00, $06
db $80, $00, $05
db $80, $01, $0B
db $80, $00, $06
db $80, $00, $05
db $80, $00, $06

db $80, $00, $05
db $80, $01, $0B
db $80, $00, $06

db $80, $00, $05
db $80, $00, $06
db $80, $00, $05
db $80, $00, $06

db $FF

Pattern01:

db $BA, $02, $16
db $C6, $02, $16

db $BA, $02, $16
db $C6, $02, $10
db $C6, $02, $06

db $BA, $02, $10
db $C6, $02, $11
db $BA, $02, $10
db $C6, $02, $11
db $BA, $02, $0B
db $BA, $02, $0B

db $FF

Pattern02:
db $FF