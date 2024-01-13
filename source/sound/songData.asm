;Song format description (in development):
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
    ;       $76-$7B - Not filled yet
    ;
    ;       $7C     - Key off
    ;       $7D X   - Repeat reference from X bytes ago (difference between
    ;                   before the opcode and after the parameters of the 
    ;                   Set reference opcode)
    ;       $7E L ptr - Set reference (L = amount of waiting opcodes)
    ;       $7F     - Loop
    
    ;       $80-$FE - Wait opcode >> 1 frames
    ;       $81-$FF - Set instrument to (high bits) | (opcode >> 1)
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



;Song data variables for more readability when assembling manually
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

        !KEY_OFF = $7C
        !REF_RPT = $7D
        !REF_SET = $7E
        !JUMP = $7F
        
        !nWAIT = $80
        !INSTRUMENT = $81
        

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

arch spc700
base $1000

SongHeader:
dw nNoteDataBass1, NoteDataDrums, NoteDataNone, NoteDataNone
dw NoteDataNone, NoteDataNone, NoteDataNone, NoteDataNone


nNoteDataBass1:
    db !INSTRUMENT|($00<<1)  ; Set instrument to 0
    db !FINE_PITCH, $00
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

    db !FINE_PITCH, $40
    db !REF_SET, 11
    dw nNoteDataBass1+3
    db !FINE_PITCH, $80
    db !REF_RPT, 2
    db !FINE_PITCH, $c0
    db !REF_RPT, 6

    db !JUMP
    dw NoteDataNone

NoteDataDrums:
    db !nWAIT|($00<<1)  ; $40   |
    db !nWAIT|($00<<1)  ; $40   |   $B0
    db !nWAIT|($30<<1)  ; $30   |__

; ===
    db !INSTRUMENT|($01<<1)
    db $3C, !nWAIT|($10<<1)
    db !KEY_OFF, !nWAIT|($40<<1)
    db $3C, !nWAIT|($10<<1)
    db !KEY_OFF, !nWAIT|($20<<1)
    db $3C, !nWAIT|($10<<1)
    db !KEY_OFF, !nWAIT|($20<<1)

; ===
.ref0:
    db $3C, !nWAIT|($10<<1)
    db !KEY_OFF, !nWAIT|($10<<1)

    db $3C, !nWAIT|($10<<1)
    db !INSTRUMENT|($02<<1)
    db $00, !nWAIT|($20<<1)

    db !INSTRUMENT|($01<<1)
    db !REF_SET, 4
    dw NoteDataDrums_ref0

    db !INSTRUMENT|($01<<1)
    db $3C, !nWAIT|($10<<1)
; ===

    db !JUMP
    dw NoteDataNone

NoteDataNone:
    db !nWAIT|($40<<1)
    db !JUMP
    dw NoteDataNone

arch 65816
base off

; NoteDataBass1:
;     dw EffectDataBass
;     db $B0, $00, $10
;     db $B0, $00, $10
;     db $B0, $00, $10
;     db $BC, $00, $10
;     db $B0, $00, $10
;     db $B3, $00, $10
;     db $BF, $00, $10
;     db $B3, $00, $10
;     db $B6, $00, $10
;     db $C2, $00, $10
;     db $B9, $00, $10

;     db !END_DATA

; NoteDataDrums1:
;     ; dw EffectDataNone
;     db $BC, $01, $10
;     db !KEY_OFF, $40
;     db $BC, $01, $10
;     db !KEY_OFF, $20
;     db $BC, $01, $10
;     db !KEY_OFF, $20

;     db !END_DATA

; NoteDataDrums2:
;     ; dw EffectDataNone
;     db $BC, $01, $10
;     db !KEY_OFF, $10
; 	db $BC, $01, $10
; 	db $80, $02, $20

;     db $BC, $01, $10
;     db !KEY_OFF, $10
;     db $BC, $01, $10
;     db $80, $02, $20
; 	db $BC, $01, $10

;     db !END_DATA

; NoteDataLong:
;     ; dw EffectDataNone
;     db !WAIT, $80
;     db !WAIT, $80
;     db !WAIT, $80
;     db !WAIT, $80


;     db !END_DATA

; NoteDataCh4:
;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $0C
;     db $C0, $02, $0C
;     db $C8, $01, $0C

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C0, $02, $0C
;     db $C8, $01, $0C
;     db $FE, $18

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $0C
;     db $C0, $02, $0C
;     db $C8, $01, $0C


;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C0, $02, $0C
;     db $C8, $01, $0C
;     db $FE, $18

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $0C
;     db $C0, $02, $0C
;     db $C8, $01, $0C

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C0, $02, $0C
;     db $C8, $01, $0C
;     db $FE, $18

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $0C
;     db $C0, $02, $0C
;     db $C8, $01, $0C


;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C8, $01, $0C
;     db $FE, $24

;     db $C0, $02, $0C
;     db $C8, $01, $0C
;     db $FE, $18

;     db $FE, $18
;     db $D2, $00, $18
;     db $FE, $0C
;     db $D2, $00, $18
;     db $FE, $0C
;     db $D4, $00, $18
;     db $FE, $18

; NoteDataNoise:
;     ; dw EffectDataNone
;     db $81, $03, $7F
;     db $80, $03, $7F
;     db $81, $03, $7F
;     db $80, $03, $7F
;     db $81, $03, $7F
;     db $80, $03, $7F
;     db $81, $03, $7F
;     db $80, $03, $7F
;     db !END_DATA

; EffectDataBass:
;     db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $40, $00, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $00, $20, !WAIT, $10
;     ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $10, $08, !WAIT, $10
;     ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $00, $40, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $20, $00, !WAIT, $10
;     ; db !SET_VOLUME_LR_SAME, $7F, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $00, $40, !WAIT, $10
;     ; db !SET_VOLUME_LR_DIFF, $20, $00, !WAIT, $10
;     db !END_DATA
