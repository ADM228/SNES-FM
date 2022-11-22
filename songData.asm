;Song format description (in developement):
; First byte - Opcode
; Bytes after that - Arguments

;Opcode 0: Note KON/KOF
;%0000occc
;       o
;       |   0 - Key on
;       |___1 - Key off
;       ccc - Channel number

db $00