; Cover of Ultra Trailer by Masarada
; Possibly to become a trailer for SNESFM when it's featured enough
; No proper vocals until streaming


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
	;       $6B xx  - Fine pitch (center is $80, $00 = -1 semitone, $FF ≈ +1 semitone)
	;		$6C X Y	- Pitch slide (indefinitely long,
	;					adds X to pitch index, Y to note number)
	;
	;       $6D-$6F - Not filled yet
	;		Planned: portamento, vibrato,
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
		!PITCH_SLIDE = $6C

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

		!WAIT = $80
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
dw NoteDataBass1, NoteDataDrums, NoteDataMelody1, NoteDataMelody2
dw NoteDataNone, NoteDataNone, NoteDataNone, NoteDataNone

NoteDataBass1:
	db !INSTRUMENT|($03<<1)

	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($01<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($01<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	db $17, !WAIT|($0B<<1)
	db !KEY_OFF, !WAIT|($0D<<1)
	; ===

	db $16, !WAIT|($24<<1)
	db !PITCH_SLIDE, $95, $00
	db !WAIT|($0C<<1)
	db !PITCH_SLIDE, $00, $00
	db !WAIT|($24<<1)


	db !JUMP
	dw NoteDataNone

NoteDataDrums:
	db !VOL_SET_BOTH, $60
	db !INSTRUMENT|($02<<1)

	db $00, !WAIT|($0C<<1)
	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($0C<<1)

	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($18<<1)
	db $00, !WAIT|($18<<1)

	db $00, !WAIT|($30<<1)
	db $00, !WAIT|($40<<1), !WAIT|($08<<1)

	db !INSTRUMENT|($01<<1)
	db $3C, !WAIT|($18<<1)
	db $3C, !WAIT|($18<<1)
	db !INSTRUMENT|($02<<1)
	db $00, !WAIT|($3C<<1)

	db !JUMP
	dw NoteDataNone

NoteDataMelody1:
	db !INSTRUMENT|($00<<1)

	db $45, !WAIT|($0C<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($0C<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($18<<1)
	db $45, !WAIT|($18<<1)
	; ===

	db $46, !WAIT|($24<<1)
	db !PITCH_SLIDE, $00, $01
	db !WAIT|($0C<<1)
	db !PITCH_SLIDE, $00, $00
	db !WAIT|($40<<1)
	db !KEY_OFF, !WAIT|($08<<1)

	db $46, !WAIT|($18<<1)
	db $4A, !WAIT|($18<<1)
	db $4B, !WAIT|($18<<1)

	db !JUMP
	dw NoteDataNone
NoteDataMelody2:
	db !INSTRUMENT|($00<<1)

	db $42, !WAIT|($0C<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($0C<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($18<<1)
	db $42, !WAIT|($18<<1)
	; ===

	db $41, !WAIT|($24<<1)
	db !PITCH_SLIDE, $00, $01
	db !WAIT|($0C<<1)
	db !PITCH_SLIDE, $00, $00
	db !WAIT|($40<<1)
	db !KEY_OFF, !WAIT|($08<<1)

	db $52, !WAIT|($18<<1)
	db $56, !WAIT|($18<<1)
	db $57, !WAIT|($18<<1)



NoteDataNone:
	db !KEY_OFF
	.ref0
	db !WAIT|($40<<1)
	db !JUMP
	dw .ref0


arch 65816
base off
