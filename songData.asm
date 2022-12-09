;Song format description (in developement):
;1. Pointers to song & instrument data
;   x000pppp pppppppp
;   x - Instrument data (0) or song data (1) pointer
;   pppp pppppppp - The actual contents of the pointer
;   No further pointers are processed after the song data pointer.
;2. Instrument data
;   TBD
;3. Song data
;   TBD
; dw instrdata
; dw 1chdata
; dw 1chdata
; dw 1chdata
; dw 1chdata
; dw 1chdata
; dw 1chdata
; dw 1chdata
; dw 1chdata

; instrdata:
; db $10, $15


; 1chdata:
db $B0, $0C
db $3C, $0C
db $30, $0C
db $3c, $0C
db $B0, $0C
db $33, $0C
db $34, $0C
db $B5, $18

db $B5, $0C
db $41, $0C 
db $BF, $18

db $41, $0C 
db $B5, $0C
db $34, $0C
db $B3, $0C
db $FF
