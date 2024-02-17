norom

org 0

arch spc700

dpbase $0000
optimize dp always

namespace nested on
namespace SPC

spcblock $5000 nspc
Configuration:
	; SNESFM can be configured in 2 different ways:
		;
		; 1. Right here, in the configuration section - just
		; comment/uncomment the defines below to disable/enable features.
		;
		; 2. Externally, by specifying the defines somewhere else
		; in your project. To use it, define !SNESFM_CFG_EXTERNAL=1
		; and specify the defines before including SNESFM. The demo
		; ROM uses this.
		;__
		;
	; There are several configuration sections:
		; 1. General sample generation options
		; 2. Phase modulation options
		; 3. Pulse generation options
		; 4. Pitch table generation options
		; 5. Other generation options
		; 6. Song playback options
		;__

	!SNESFM_CFG_EXTERNAL ?= 0

	if !SNESFM_CFG_EXTERNAL == 0

	;========== 1. General sample generation options ==========

		; Whether to generate samples at all - the main gimmick
		; of this sound driver. Disabling this will disable all
		; sample generation capabilities and automatically
		; enable the ability to supply custom samples within
		; instrument data, which you will have to do.
		!SNESFM_CFG_SAMPLE_GENERATE = 1

		; Whether to be able to generate samples using BRR
		; filter mode 1. These samples have finer details, but
		; take longer to produce, and due to the rough nature
		; of the algorithm, may have some details wrong.
		!SNESFM_CFG_SAMPLE_USE_FILTER1 = 1

		; Whether to be able to include custom samples from
		; instrument data. Automatically set if you don't set
		; it while disabling sample generation.
		!SNESFM_CFG_INSDATA_CUSTOM_SAMPLES = 1


	;=============== 2. Phase modulation options ==============

		; Dictates whether to generate phase modulated
		; instruments - just like on Yamaha chips. Not to be
		; confused with SNES hardware pitch modulation.

		; Enables phase modulation with long samples.
		!SNESFM_CFG_PHASEMOD_LONG = 1

		; Enables phase modulation with short samples.
		!SNESFM_CFG_PHASEMOD_SHORT = 1

	;=============== 3. Pulse generation options ==============

		; Dictates whether to generate pulse wave samples.

		; Enables generation of long pulse wave samples.
		!SNESFM_CFG_PULSEGEN_LONG = 1

		; Enables generation of short pulse wave samples.
		!SNESFM_CFG_PULSEGEN_SHORT = 1

	;============ 4. Pitch table generation options ===========

		; Whether to generate pitch tables on the SPC700
		; itself. If disabled, you will be responsible for
		; supplying the pitch table yourself (at location
		; $0E00 - $0EBF, the first 96 bytes being low bytes and
		; the last 96 being high bytes, the topmost note is a
		; B7, close to the max pitch on the SNES).
		!SNESFM_CFG_PITCHTABLE_GEN = 1

		; Arithmetic method used for generating the pitch
		; tables' uppermost octave.
		; When it's set to 0, it proceeds to
		;	1. Multiply the 16-bit pitch by an 8-bit multiplier
		;	2. Divide the 24-bit result by an 8-bit divisor
		; When it's set to 1 (or above), it proceeds to
		;	1. Multiply the 16-bit pitch by a 16-bit multiplier
		;	2. Take the upper 2 bytes of the 32-bit result and
		;		add them to the pitch
		; The latter pitch generation method can account for
		; more different tone scales (e.g. TET17), but takes
		; about 20% more time per note, while the former method
		; was created with regard to TET12, and is the default.
		!SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD = 0

		; Whether to enable different ratios for pitch table
		; generation per song. If set to 0, the pitch table
		; will always be generated with the same ratio, but
		; still allow different base points per song. If set to
		; 1 (or above), you can specify different pitch ratios
		; per song (e.g. one song in TET12 and another in
		; TET17), which is also slower.
		!SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS = 0

		; Whether to enable different note counts per octave in
		; the pitch table. It will take more time to generate.
		!SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_NOTE_COUNTS = 0

		; The ratios for the generation of the pitch table. If
		; dynamic ratios are enabled, this ratio will be the
		; default one (the one initialized at boot and used by
		; songs if not told otherwise), if disabled, it's just
		; the ratio that the pitch tables are generated in.
		; When the ARITHMETIC_METHOD is 0, the HIGHRATIO is the
		; multiplier, and LOWRATIO is the divisor; when it's 1,
		; it's just the bytes of the 16-bit multiplier. Set to
		; the ratio for TET12 by default.
		!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO = 196
		!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO = 185

		; The amount of notes per octave in the pitch table.
		; The total amount of notes always stays at 96, so at
		; higher values you lose more of the bass.
		; !!!! DOES NOT AUTOMATICALLY SET THE RATIO OPTIONS!!!!
		!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT = 12

	;=============== 5. Other generation options ==============

		; Amount of space for repeating opcode parameters in
		; the instrument generation routine. Lesser values will
		; slightly reduce code size and execution time at the
		; cost of possibly increasing the size of instrument
		; data. Can range from 0 to 4. Should be supplied by
		; the tool that compiled the instrument data.
		!SNESFM_CFG_INSGEN_REPEAT_AMOUNT = 4

		; Amount of space for doing arithmetic opcode
		; parameters in the instrument generation routine.
		; Lesser values will slightly reduce code size and
		; execution time at the cost of possibly increasing the
		; size of instrument data. Can range from 0 to 4.
		; Should be supplied by the tool that compiled the
		; instrument data.
		!SNESFM_CFG_INSGEN_ARITHMETIC_AMOUNT = 4

	;================ 6. Song playback options ================

		!SNESFM_CFG_DYNAMIC_TIMER_SPEED = 0

		!SNESFM_CFG_FINE_PITCH				= 1
		!SNESFM_CFG_INSTRUMENT_PITCHBEND 	= 1
		!SNESFM_CFG_PITCHBEND_EFFECTS 		= 1	; To be made automatically later

		!SNESFM_CFG_VIRTUAL_CHANNELS = 1

	endif
Documentation:
	;   ==== Code/data distribution table: ====
		;   Page		Purpose
		;   $00			$20 - $3F: Temporary storage of flags, counters and pointers for note stuff
		;               $40 - $4F: Communicating with S-CPU stuff
		;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
		;   $01 _ _ _ _ Stack
		;   $02 _ _ _ _ Sample Directory
		;   $03-$04 _ _ Permanent storage of flags, counters and pointers for note stuff for "real" channels
		;   $05-$06 _ _ Same but for virtual channels
		;	$07 _ _ _ _ Global settings
		;   $09 _ _ _ _ Log table for pitchbends
		;   $0A _ _ _ _ Low bytes of instrument data pointers
		;   $0B _ _ _ _ High bytes of instrument data pointers
		;   $0C _ _ _ _ 7/8 multiplication lookup table
		;   $0D _ _ _ _ 15/16 multiplication lookup table
		;   $0E         $00 - $BF: Pitch table, 96 entries long
		;   |__ _ _ _ _ $C0 - $C8: Dummy empty sample (for beginnings and noise)
		;   $0F _ _ _ _ Sine table, only $0F00-$0F42 is written, everything else is calculated
		;   $10-$4F _ _ FM generation buffers, Instrument data (at the end)
		;   $50-$5F _ _ Code
		;   $60-$FE _ _ Actual sample storage, echo buffer (separated depending on the delay & amount of samples)
		;   $FF         $00 - $BF: Fast-called routines (here to save 2 cycles with PCALL)
		;   |__ _ _ _ _ $C0 - $FF: TCALL pointers/Boot ROM
	;   ==== Communication with SNES: ====
		;       (Port 0 is always message number; Port 1's high 4 bits is message ID)
		;       === To SNES: ===
		;   Id  | P1 |    Pt2    |    Pt3    |   Meaning
		;   $0  |    |           |           |   Waiting for yo command
		;   $1  |    |           |           |   Start sending data
		;   $2  |    |           |           |   Got the data
		;   $3  |    |           |           |   Have started compiling instruments
		;   $4  |     20-bit tick counter    |   Currently playing song, here's what tick it is
		;   $F  |    |           |           |   What?
		;       === To SPC: ===
		;   Id  | P1 |    Pt2    |    Pt3    |   Meaning
		;   $0  |    |           |           |   Read yo message
		;   $1  |    |           |           |   Stop song
		;   $2  |    |           |  Channels |   Mute channels
		;   $3  |     20-bit tick counter    |   Seek to tick
		;   $4  |    |           |           |   Prepare to get some song data and gimme the location
		;   $5  |    |           |           |   Prepare to get some instrument data and gimme the location
		;   $6  |    |           |           |   Play the song you have received
		;   $7  |    |           |   SFX ID  |   Play sound effect
		;   $8  |    | instrument|  note ID  |   Play just a note
		;   $9  |    |    16 bits of data    |   Get a load of this data
		;   $A  |    |           |           |   Data transfer finished
		;   $F  |    |           |           |   What?
	;   Sound engine documentation:
		;   Channel flags: n0Iafoir
		;   n - sample number (0 or 1)
		;   I - whether it is the first frame of an instrument (stops from parsing instrument data on that frame)
		;   a - whether to disable the attack
		;   f - whether to reset the instrument
		;   o - in real channels: whether the channel is overridden by a virtual channel
		;       in virtual channels: whether the channel is enabled
		;   i - whether to not parse instrument data
		;   r - whether a reference is in effect
InternalDefines:
	;Song data variables for more readability when assembling manually
		;Instrument data
			;   Instrument types
				!SAMPLE_USE_ADDRESS = %00001000
				!ENVELOPE_TYPE_ADSR = %00000010
	;Pointers to channel 1's variables (permanent storage during song playback)
		CH1_SONG_POINTER_L = $0300
		CH1_SONG_POINTER_H = $0301
		CH1_REF0_POINTER_L = $0302
		CH1_REF0_POINTER_H = $0303
		CH1_INSTRUMENT_INDEX = $0304
		CH1_INSTRUMENT_TYPE = $0305
		CH1_SAMPLE_POINTER_L = $0306
		CH1_SAMPLE_POINTER_H = $0307

		CH1_SONG_COUNTER = $0340
		CH1_REF0_COUNTER = $0341
		CH1_PITCHBEND_L = $0342
		CH1_PITCHBEND_H = $0343
		CH1_ARPEGGIO = $0344
		CH1_NOTE = $0345

		CH1_FLAGS = $0347

		CH1_MACRO_COUNTERS = $0380
		CH1_INSTRUMENT_TYPE_COUNTER = $0380
		CH1_ENVELOPE_COUNTER = $0381
		CH1_SAMPLE_POINTER_COUNTER = $0382
		CH1_ARPEGGIO_COUNTER = $0383
		CH1_PITCHBEND_COUNTER = $0384
		CH1_COUNTERS_HALT = $0387		;000paset

		CH1_MACRO_POINTERS = $03C0
		CH1_INSTRUMENT_TYPE_POINTER = $03C0
		CH1_ENVELOPE_POINTER = $03C1
		CH1_SAMPLE_POINTER_POINTER = $03C2
		CH1_ARPEGGIO_POINTER = $03C3
		CH1_PITCHBEND_POINTER = $03C4
		CH1_COUNTERS_DIRECTION = $03C7	;000paset

		CH1_INSTRUMENT_SECTION_HIGHBITS = $0385

		CH1_PITCH_EFFECT_ID = $0400
		CH1_PITCH_EFFECT_CNT = $0401
		CH1_PITCH_EFFECT_ACC_L = $0402
		CH1_PITCH_EFFECT_ACC_H = $0403
		CH1_PITCH_EFFECT_VAL_L = $0404
		CH1_PITCH_EFFECT_VAL_H = $0405

		GBL_TIMER_SPEED = $0700

	;Internal configuration

	macro cfgClamp(def)
		!SNESFM_CFG_<def> #= clamp(!SNESFM_CFG_<def>, 0, 1)
	endmacro

	macro cfgClampMax(def, max)
		!SNESFM_CFG_<def> #= clamp(!SNESFM_CFG_<def>, 0, <max>)
	endmacro

		!SNESFM_CFG_SAMPLE_GENERATE ?= 0
		!SNESFM_CFG_SAMPLE_USE_FILTER1 ?= 0

		%cfgClamp(SAMPLE_GENERATE) : %cfgClamp(SAMPLE_USE_FILTER1)

		if defined("SNESFM_CFG_PHASEMOD_BOTH")
			!SNESFM_CFG_PHASEMOD_LONG ?= !SNESFM_CFG_PHASEMOD_BOTH
			!SNESFM_CFG_PHASEMOD_SHORT ?= !SNESFM_CFG_PHASEMOD_BOTH
		else
			!SNESFM_CFG_PHASEMOD_LONG ?= 0
			!SNESFM_CFG_PHASEMOD_SHORT ?= 0
			!SNESFM_CFG_PHASEMOD_BOTH = (!SNESFM_CFG_PHASEMOD_LONG)&(!SNESFM_CFG_PHASEMOD_SHORT)
		endif
		%cfgClamp(PHASEMOD_BOTH) : %cfgClamp(PHASEMOD_LONG) : %cfgClamp(PHASEMOD_SHORT)
		!SNESFM_CFG_PHASEMOD_ANY = (!SNESFM_CFG_PHASEMOD_LONG)|(!SNESFM_CFG_PHASEMOD_SHORT)

		if defined("SNESFM_CFG_PULSEGEN_BOTH")
			!SNESFM_CFG_PULSEGEN_LONG ?= !SNESFM_CFG_PULSEGEN_BOTH
			!SNESFM_CFG_PULSEGEN_SHORT ?= !SNESFM_CFG_PULSEGEN_BOTH
		else
			!SNESFM_CFG_PULSEGEN_LONG ?= 0
			!SNESFM_CFG_PULSEGEN_SHORT ?= 0
			!SNESFM_CFG_PULSEGEN_BOTH = (!SNESFM_CFG_PULSEGEN_LONG)&(!SNESFM_CFG_PULSEGEN_SHORT)
		endif
		%cfgClamp(PULSEGEN_BOTH) : %cfgClamp(PULSEGEN_LONG) : %cfgClamp(PULSEGEN_SHORT)
		!SNESFM_CFG_PULSEGEN_ANY = (!SNESFM_CFG_PULSEGEN_LONG)|(!SNESFM_CFG_PULSEGEN_SHORT)

		!SNESFM_CFG_RESAMPLE ?= 0
		%cfgClamp(RESAMPLE)

		!SNESFM_CFG_PITCHTABLE_GEN ?= 1
		%cfgClamp(PITCHTABLE_GEN)
		if !SNESFM_CFG_PITCHTABLE_GEN >= 1
			!SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS ?= 0
			!SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_NOTE_COUNTS ?= 0
			!SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD ?= 0
			%cfgClamp(PITCHTABLE_GEN_DYNAMIC_RATIOS)
			%cfgClamp(PITCHTABLE_GEN_DYNAMIC_NOTE_COUNTS)
			%cfgClamp(PITCHTABLE_GEN_ARITHMETIC_METHOD)
			; Default ratios for TET12
			if !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD == 0
				!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO ?= 196
				!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO ?= 185
			else
				!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO ?= $0F
				!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO ?= $39
			endif
			!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT ?= 12

			; TODO: make support for this
			if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_NOTE_COUNTS >= 1
				error "Sorry, dynamic note counts not supported rn"
			endif

		endif

		!SNESFM_CFG_INSGEN_REPEAT_AMOUNT ?= 0
		!SNESFM_CFG_INSGEN_ARITHMETIC_AMOUNT ?= 0
		%cfgClampMax(INSGEN_REPEAT_AMOUNT, 4)
		%cfgClampMax(INSGEN_ARITHMETIC_AMOUNT, 4)

		!SNESFM_CFG_FINE_PITCH ?= 0
		!SNESFM_CFG_INSTRUMENT_PITCHBEND ?= 0
		!SNESFM_CFG_PITCHBEND_EFFECTS ?= 0	; To be made automatically later
		%cfgClamp(FINE_PITCH) : %cfgClamp(INSTRUMENT_PITCHBEND) : %cfgClamp(PITCHBEND_EFFECTS)

		!SNESFM_CFG_PITCHBEND_ANY = (!SNESFM_CFG_INSTRUMENT_PITCHBEND)|(!SNESFM_CFG_PITCHBEND_EFFECTS)|(!SNESFM_CFG_FINE_PITCH)
		!SNESFM_CFG_PITCHBEND_ALL = (!SNESFM_CFG_INSTRUMENT_PITCHBEND)&(!SNESFM_CFG_PITCHBEND_EFFECTS)&(!SNESFM_CFG_FINE_PITCH)
		

		!SNESFM_CFG_VIRTUAL_CHANNELS ?= 0

		if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
			print "Virtual channels enabled"
			macro realChannelWrite()
				TCALL 14
			endmacro
		else
			print "Virtual channels disabled"
			macro realChannelWrite()
				MOV $F3, A
			endmacro
		endif

	;Temporary channel pointers during song playback

		CHTEMP_SONG_POINTER_L = $20
		CHTEMP_SONG_POINTER_H = $21
		CHTEMP_INSTRUMENT_TYPE = $22
		CHTEMP_FLAGS = $23
		CHTEMP_INSTRUMENT_SECTION_HIGHBITS = $24
		CHTEMP_COUNTERS_HALT = $25
		CHTEMP_COUNTERS_DIRECTION = $26




	;Just global variables used in song playback
		!TEMP_VALUE = $00
		!TIMER_VALUE = $01
		!CHANNEL_REGISTER_INDEX = $02
		!CHANNEL_BITMASK = $03
		!TEMP_VALUE2 = $06
		!BACKUP_X = $07
		!PLAYBACK_FLAGS  = $09  ; 0000000p
								; p = pitch modified
		!TEMP_POINTER0_L = $0A
		!TEMP_POINTER0_H = $0B
		!TEMP_POINTER1_L = $0C
		!TEMP_POINTER1_H = $0D
		!TEMP_POINTER2_L = $0E
		!TEMP_POINTER2_H = $0F

	; S-CPU communication
		MESSAGE_CNT_TH1 = $40

	; Instrument generation
		OPCODE_ARGUMENT = $50
		REPEAT_BITMASK  = $58
		REPEAT_COUNTER  = $5C

		INSDATA_PTR_L   = $60
		INSDATA_PTR_H   = $61
		INSBLOCK_PTR_L  = $62
		INSBLOCK_PTR_H  = $63

		INSDATA_OPCODE  = $64

		INSDATA_INS_CNT     = $69
		INSDATA_TMP_CNT     = $6A
		INSDATA_TMP_VALUE   = $6B
		INSDATA_TMP_PTR_0_L = $6C
		INSDATA_TMP_PTR_0_H = $6D
		INSDATA_TMP_PTR_1_L = $6E
		INSDATA_TMP_PTR_1_H = $6F

		!GenPitch_Ratio_Lo	= $E8

	; Labels, previously scattered around in includes
		PitchTableLo = $0E00
		PitchTableHi = $0E60

;

Init:       ;init routine by KungFuFurby
;------------Clear DSP Registers------------
;DSP register initialization will now take place.
.clear:
	clrp                    ;Zero direct page flag.
	mov A, #$6C             ;Stop all channels first.
	mov Y, #$FF             ;KOFF will be cleared
	movw $F2, YA            ;later on, though.
	inc Y
	mov A, #$7F
..loop:
	movw $F2, YA            ;Clear DSP register.
	mov Y, #$00
	cmp A, #$6C+1
	bne ..not_flg
	mov Y, #%01100000

..not_flg:
	cmp A, #$6D+1
	bne ..not_esa
;For ESA, set to $80.
;(Max EDL is $0F, which consumes $7800 bytes.
;ESA is set to $80 in case echo writes are accidentally on.)
	mov Y, #$80

..not_esa:
	dec A
	bpl ..loop

.set_vol:
	MOV A, #$3C
	MOV Y, #$7F
	SETC
..loop:
	MOVW $F2, YA
	; SETC      ; not needed as it's set in the beginning, and when it clears we need to exit
	SBC A, #$10
	BCS ..loop

	INC A           ; Set A to 0

	MOVW $F4, YA    ;   Clear output ports
	MOVW $F6, YA    ;__
	MOV MESSAGE_CNT_TH1, A
	MOV $F1, #$30   ;__ Clear input ports
	MOV X, #$FF     ;   Reset the stack
	MOV SP, X       ;__
	MOV $F2, #$5D   ;   Set sample directory at $0200
	MOV $F3, #$02   ;__
	MOV $F1, #$00   ;
	;MOV $FA, #$85   ;   Set Timer 0 to 16.625 ms (~60 Hz)
	;MOV $FA, #$50   ;   Set Timer 0 to 10 ms     (100 Hz)
	;MOV $FA, #$A0   ;   Set Timer 0 to 20 ms     (50 Hz)
	;MOV $FA, #$FF   ;   Set Timer 0 to 31.875 ms (~31 Hz)
	MOV $F1, #$07   ;__

if !SNESFM_CFG_PITCHTABLE_GEN >= 1
	if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS >= 1
		MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO
		MOV Y, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO
		MOVW !GenPitch_Ratio_Lo, YA
	endif
	MOV A, #$7D
	MOV Y, #$21
	CALL GeneratePitchTable_Start
endif

	CALL Log2Generate

SineSetup:

	; Setting up the sine table

	MOV X, #$02     ;__ X contains the source index,
	MOV Y, #$3E     ;__ Y contains the destination index
	.loopCopy:
		MOV A, $0F00+X
		INC X
		MOV $0F40+Y, A
		MOV A, $0F00+X
		INC X
		MOV $0F41+Y, A
		DEC Y
		DBNZ Y, .loopCopy

	MOV Y, #$3F

	.loopInvert:
		MOV A, $0F00+Y
		EOR A, #$FF
		MOV $0F80+Y, A
		MOV A, $0F40+Y
		EOR A, #$FF
		MOV $0FC0+Y, A
		DBNZ Y, .loopInvert

EffectSetup:
	MOV Y, #$00
	MOV A, #$FF
	-:
		MOV $0300+Y, A
		DBNZ Y, -

RAMClear:
	MOV A, Y
	-:
		MOV $0300+Y, A
		MOV $0200+Y, A
		DBNZ Y, -


SetVolume:
	MOV X, #$7F
	MOV Y, #$08
	MOV A, #$00
	.loopVolumeSetup:
		MOV $F2, A
		MOV $F3, X
		INC $F2
		MOV $F3, X
		CLRC
		ADC A, #$10
		DBNZ Y, .loopVolumeSetup

	MOV MESSAGE_CNT_TH1, #$01
	MOV TDB_OUT_PTR_L, #$00
	MOV TDB_OUT_PTR_H, #$10
	CALL TransferDataBlock

; namespace CompileInstruments
	CompileInstruments:
	.Start:
		MOV Y, #$00
		MOV INSDATA_PTR_L, Y
		MOV INSDATA_PTR_H, #$10

		if !SNESFM_CFG_SAMPLE_GENERATE >= 1

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
			MOV REPEAT_BITMASK+0, Y
			MOV REPEAT_COUNTER+0, Y
		endif
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
			MOV REPEAT_BITMASK+1, Y
			MOV REPEAT_COUNTER+1, Y
		endif
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
			MOV REPEAT_BITMASK+2, Y
			MOV REPEAT_COUNTER+2, Y
		endiF
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
			MOV REPEAT_BITMASK+3, Y
			MOV REPEAT_COUNTER+3, Y
		endif

		endif   ; !SNESFM_CFG_SAMPLE_GENERATE

	.ReadByte:
		MOV A, (INSDATA_PTR_L)+Y
		INCW INSDATA_PTR_L

		if !SNESFM_CFG_SAMPLE_GENERATE >= 1

		MOV INSDATA_OPCODE, A
		AND A, #$1F
		MOV X, A
		MOV A, .ArgCountTable+X
		MOV INSDATA_TMP_CNT, A
		BEQ .Jump
		AND A, INSDATA_OPCODE
		BPL +   ; If bit 7 is set in both the counter and the opcode it has 1 less argument
			INC INSDATA_TMP_CNT
		+
		AND INSDATA_TMP_CNT, #$7F

		CLRC
		ADC INSDATA_TMP_CNT, #OPCODE_ARGUMENT

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
			CALL .RepeatBitmask
		endif

		MOV X, #OPCODE_ARGUMENT


	.GetArguments:
		MOV A, (INSDATA_PTR_L)+Y
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
		ASL INSDATA_TMP_VALUE
		BCS +
		endif
			MOV (X), A
			INCW INSDATA_PTR_L
		+ INC X
		CMP X, INSDATA_TMP_CNT
		BNE .GetArguments

	.Jump:
		MOV A, INSDATA_OPCODE

		endif   ; !SNESFM_CFG_SAMPLE_GENERATE

		CALL +
		JMP .ReadByte
	+

		AND A, #$1F
		ASL A
		MOV X, A

		if !SNESFM_CFG_SAMPLE_GENERATE >= 1
			JMP (.JumpTable+X)
		else
			JMP (.JumpTable-($1D*2)+X)
		endif


	if !SNESFM_CFG_SAMPLE_GENERATE >= 1

	.ArgCountTable:
		fillbyte $00
		db $02, $00, $00, $03
		fill ($1A-1-$03)
		db $83, $00, $00, $00, $00, $00 

	endif   ; !SNESFM_CFG_SAMPLE_GENERATE

	.JumpTable: 
		if !SNESFM_CFG_SAMPLE_GENERATE >= 1
			dw .CopyResample
			if !SNESFM_CFG_PHASEMOD_ANY >= 1
				dw .PhaseModPart1, .PhaseModPart2
			else
				dw .RETJump, .RETJump
			endif

			if !SNESFM_CFG_PULSEGEN_ANY >= 1
				dw .PulseGen
			else
				dw .RETJump
			endif
			; fill ($1A-1-$03)*2 WHYYYYYYYYYYYYYYYYYYYYYYY
			for i = $03..($1A-1) : dw .RETJump : endfor
			dw .BRRGen
			dw .RETJump
			if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
				dw .ConserveArgs
			else
				dw .RETJump
			endif
		endif   ; !SNESFM_CFG_SAMPLE_GENERATE
		dw .NewInstrument, .InstrumentRawDataBlock, .End

	if !SNESFM_CFG_SAMPLE_GENERATE >= 1

	if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
	.RepeatBitmask:
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
			MOV A, REPEAT_BITMASK+0
			OR  A, REPEAT_BITMASK+1
			if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
				OR  A, REPEAT_BITMASK+2
				if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
					OR  A, REPEAT_BITMASK+3
				endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 4
			endif ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
			MOV INSDATA_TMP_VALUE, A
		else    ; if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT == 1, then just copy the value
			MOV INSDATA_TMP_VALUE, REPEAT_BITMASK+0
		endif ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2 

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
			MOV Y, #!SNESFM_CFG_INSGEN_REPEAT_AMOUNT
			MOV X, #$00
			-   DEC REPEAT_COUNTER-1+Y
				BNE +
					MOV REPEAT_BITMASK-1+Y, X
				+ DBNZ Y, -
			; After DBNZ, Y is 0
		else
			; This code alone takes 6 bytes less than the loop
			DEC REPEAT_COUNTER+0
			BNE +
				MOV REPEAT_BITMASK+0, Y
			+:
			if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
				; This code is the same size, but runs faster than the loop
				DEC REPEAT_COUNTER+1
				BNE +
					MOV REPEAT_BITMASK+1, Y
				+:
			endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 2
		endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 3
		RET
	endif   ; !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1

	.CopyResample:
		if !SNESFM_CFG_RESAMPLE >= 1
			MOV A, INSDATA_OPCODE
			BMI ..Resample
		endif
		MOV A, OPCODE_ARGUMENT+0        ;   Self-modifying code is
		MOV ..CopyLoop+2, A  			;   faster than (dp)+Y
		MOV A, OPCODE_ARGUMENT+1        ;   (8 cycles vs 2*256 cycles)
		MOV ..CopyLoop+4, A  			;__

		..CopyLoop:
			MOV A, $4000+Y
			MOV $4000+Y, A
			DBNZ Y, ..CopyLoop
		RET

		if !SNESFM_CFG_RESAMPLE >= 1
		..Resample:
			ASL A
			AND A, #$C0
			MOV LTS_OUT_SUBPAGE, A
			MOVW YA, OPCODE_ARGUMENT+0
			MOVW LTS_IN_PAGE, YA
			CALL LongToShort
			MOV Y, #$00
			RET
		endif

	.CopyArguments:
		MOV A, (X+)
		MOV $D0-OPCODE_ARGUMENT-1+X, A
		CMP X, INSDATA_TMP_CNT
		BNE .CopyArguments
	RET

	if !SNESFM_CFG_PHASEMOD_ANY >= 1
	.PhaseModPart1:
		MOV INSDATA_TMP_CNT, #OPCODE_ARGUMENT+5
		MOV A, INSDATA_OPCODE
		BPL +   ; If bit 7 is set in both the counter and the opcode it has 1 less argument
			INC INSDATA_TMP_CNT
		+
		INC INSDATA_OPCODE  ; Set the opcode to its meta version

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
			CALL .RepeatBitmask
		endif

		MOV X, #OPCODE_ARGUMENT+2

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
		ASL INSDATA_TMP_VALUE
		BCS +
		endif
			MOV A, (INSDATA_PTR_L)+Y
			MOV OPCODE_ARGUMENT+0, A
			INCW INSDATA_PTR_L
		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT >= 1
		+
		ASL INSDATA_TMP_VALUE
		BCS ++
		endif
			MOV A, OPCODE_ARGUMENT+0
			BBS6 INSDATA_OPCODE, +   ; Bit 6 is set, copy modulator from carrier
				MOV A, (INSDATA_PTR_L)+Y
				INCW INSDATA_PTR_L
			+ MOV OPCODE_ARGUMENT+1, A
		++:
		JMP .GetArguments

	.PhaseModPart2:
		MOV X, #OPCODE_ARGUMENT
		CALL .CopyArguments
		if !SNESFM_CFG_PHASEMOD_BOTH >= 1
			BBS7 INSDATA_OPCODE, +
				CALL PhaseModulation_128
				MOV Y, #$00
				RET
			+   CALL PhaseModulation_32
				MOV Y, #$00
				RET
		elseif !SNESFM_CFG_PHASEMOD_LONG >= 1
			CALL PhaseModulation_128
			MOV Y, #$00
			RET
		elseif !SNESFM_CFG_PHASEMOD_SHORT >= 1
			CALL PhaseModulation_32
			MOV Y, #$00
			RET
		endif
	endif   ; !SNESFM_CFG_PHASEMOD_ANY

	if !SNESFM_CFG_PULSEGEN_ANY >= 1
	.PulseGen:
		MOV X, #OPCODE_ARGUMENT
		CALL .CopyArguments

		if !SNESFM_CFG_PULSEGEN_BOTH >= 1
			MOV A, INSDATA_OPCODE
			BMI +
		endif
		if !SNESFM_CFG_PULSEGEN_BOTH+!SNESFM_CFG_PULSEGEN_LONG >= 1
				CALL GeneratePulse_128
				DEC Y   ; Y is always 1
				RET
		endif
		if !SNESFM_CFG_PULSEGEN_BOTH >= 1
			+:
		endif
		if !SNESFM_CFG_PULSEGEN_BOTH+!SNESFM_CFG_PULSEGEN_SHORT >= 1
				MOV A, Y    ; 0
				LSR PUL_DUTY
				ROL PUL_FLAGS
				ADC A, #$00
				ASL A
				LSR PUL_DUTY
				ROL PUL_FLAGS
				ADC A, #$00
				AND PUL_FLAGS, #$FC
				TSET PUL_FLAGS, A

				MOV A, INSDATA_OPCODE
				ASL A
				AND A, #$C0
				TSET PUL_DUTY, A

				CALL GeneratePulse_32
				DEC Y
				RET
		endif
	endif   ; !SNESFM_CFG_PULSEGEN

	.BRRGen:
		MOV X, #OPCODE_ARGUMENT
		CALL .CopyArguments
		BBC7 INSDATA_OPCODE, +  ;   Ironically this takes the same cycles as MOV1
			OR BRR_FLAGS, #$10  ;__ when it sets the bit, and 3 less if it doesn't
		+ JMP ConvertToBRR  	;__ = CALL : RET

	.ConserveArgs:
		MOV A, INSDATA_OPCODE   ;
		XCN A                   ;
		LSR A                   ;   Get pointer into dp
		AND A, #$03             ;
		MOV X, A                ;__

		MOV A, (INSDATA_PTR_L)+Y
		MOV REPEAT_BITMASK+X, A
		INCW INSDATA_PTR_L

		MOV A, (INSDATA_PTR_L)+Y
		MOV REPEAT_COUNTER+X, A
		INCW INSDATA_PTR_L
		RET
	endif   ; !SNESFM_CFG_SAMPLE_GENERATE

	.NewInstrument:
		; Adjust pointer
		MOV A, #$EA     ;   Constant #$FFEA = -22
		DEC Y           ;__
		ADDW YA, INSDATA_TMP_PTR_0_L    ;
		MOVW INSDATA_TMP_PTR_0_L, YA    ;__ Get pointer
		MOV .ByteTransferLoop+4, A      ;   Store it into lo byte of 2nd MOV
		MOV .ByteTransferLoop+5, Y      ;__ Store it into hi byte of 2nd MOV
		MOV X, INSDATA_INS_CNT          ;
		MOV InstrumentPtrLo+X, A        ;
		MOV A, Y                        ;   Store it in instrument table 
		MOV InstrumentPtrHi+X, A        ;
		INC INSDATA_INS_CNT             ;__

		MOVW YA, INSDATA_PTR_L
		MOV .ByteTransferLoop+1, A   	; Lo byte of 1st MOV
		MOV .ByteTransferLoop+2, Y   	; Hi byte of 1st MOV

		MOV Y, #22-1
		CALL .ByteTransferLoop
		; Y is 0 after DBNZ
		MOV A, (INSDATA_PTR_L)+Y
		MOV (INSDATA_TMP_PTR_0_L)+Y, A

		MOV A, #22
		ADDW YA, INSDATA_PTR_L
		MOVW INSDATA_PTR_L, YA

		MOV Y, #$00

		RET


	.InstrumentRawDataBlock:
		MOV A, (INSDATA_PTR_L)+Y
		MOV INSBLOCK_PTR_L, A
		MOV INSDATA_TMP_PTR_0_L, A
		INCW INSDATA_PTR_L

		MOV A, (INSDATA_PTR_L)+Y
		MOV INSBLOCK_PTR_H, A
		MOV INSDATA_TMP_PTR_0_H, A
		INCW INSDATA_PTR_L

		MOV A, Y    ; 0
		MOV Y, #$50
		SUBW YA, INSDATA_TMP_PTR_0_L
		MOVW INSDATA_TMP_PTR_1_L, YA
		MOVW INSBLOCK_PTR_L, YA

		DECW INSDATA_TMP_PTR_0_L

		MOV Y, #$00

		..BigLoop:
			MOVW YA, INSDATA_PTR_L
			MOV .ByteTransferLoop+1, A		; Lo byte of 1st MOV
			MOV .ByteTransferLoop+2, Y		; Hi byte of 1st MOV

			MOVW YA, INSDATA_TMP_PTR_1_L
			MOV .ByteTransferLoop+4, A		; Lo byte of 2nd MOV
			MOV .ByteTransferLoop+5, Y		; Hi byte of 2nd MOV

			DEC INSDATA_TMP_PTR_0_H
			BMI +
				; If >=$FF bytes left
				MOV Y, #$00
				CALL .ByteTransferLoop
				INC INSDATA_PTR_H
				INC INSDATA_TMP_PTR_1_H
				JMP ..BigLoop

			+:
				MOV Y, INSDATA_TMP_PTR_0_L
				CALL .ByteTransferLoop
				; Y is 0 after DBNZ
				MOV A, (INSDATA_PTR_L)+Y
				MOV (INSDATA_TMP_PTR_1_L)+Y, A

				INCW INSDATA_TMP_PTR_0_L
				INC INSDATA_TMP_PTR_0_H
				MOV A, INSDATA_TMP_PTR_0_L
				ADDW YA, INSDATA_PTR_L
				MOVW INSDATA_PTR_L, YA

				MOVW YA, INSBLOCK_PTR_L
				MOVW INSDATA_TMP_PTR_0_L, YA

				MOV Y, #$00
				MOV INSDATA_INS_CNT, Y
				RET
		.ByteTransferLoop:
			MOV A, $1000+Y
			MOV $4F00+Y, A
			DBNZ Y, .ByteTransferLoop
		#.RETJump:
		RET


	.End:

Begin:

	MOV A, #$00
	MOV !TEMP_POINTER0_L, A
	MOV TDB_OUT_PTR_L, A
	MOV A, #$10
	MOV !TEMP_POINTER0_H, A
	MOV TDB_OUT_PTR_H, A

	CALL TransferDataBlock

	MOV X, #$01
	MOV !CHANNEL_BITMASK, X
	DEC X
	MOV !CHANNEL_REGISTER_INDEX, X
	MOV Y, #$00
	-:
		MOV A, (!TEMP_POINTER0_L)+Y
		MOV CH1_SONG_POINTER_L+X, A
		INC Y
		MOV A, (!TEMP_POINTER0_L)+Y
		MOV CH1_SONG_POINTER_H+X, A
		INC Y
		MOV A, #$00
		MOV CH1_SONG_COUNTER+X, A
		MOV CH1_INSTRUMENT_SECTION_HIGHBITS+X, A
		if !SNESFM_CFG_PITCHBEND_ANY
			if !SNESFM_CFG_PITCHBEND_EFFECTS	;
				MOV CH1_PITCH_EFFECT_VAL_H+X, A	;
			endif								;
			if !SNESFM_CFG_INSTRUMENT_PITCHBEND	;
				MOV CH1_PITCHBEND_H+X, A		;
			endif								;
			MOV A, #$80							;   Zero out pitchbend
			if !SNESFM_CFG_PITCHBEND_EFFECTS	;
				MOV CH1_PITCH_EFFECT_VAL_L+X, A	;
			endif								;
			if !SNESFM_CFG_INSTRUMENT_PITCHBEND	;
				MOV CH1_PITCHBEND_L+X, A		;
			endif								;__
		endif
		MOV A, #$02							;   Bit 1 set to stop from
		MOV CH1_FLAGS+X, A                  ;__ parsing nonexistent instrument data
		MOV A, #$C0							;
		MOV $0204+X, A                      ;
		MOV $0200+X, A                      ;   Reset sample start pointers to blank sample
		MOV A, #$0E                         ;
		MOV $0205+X, A                      ;
		MOV $0201+X, A                      ;__
		; MOV !CH1_EFFECT_COUNTER+X, A


		; MOV Y, #$00
		; MOV A, (CHTEMP_SONG_POINTER_L)+Y
		; INCW CHTEMP_SONG_POINTER_L
		; MOV !CH1_EFFECT_POINTER_L+X, A
		; MOV A, (CHTEMP_SONG_POINTER_L)+Y
		; INCW CHTEMP_SONG_POINTER_L
		; MOV !CH1_EFFECT_POINTER_H+X, A

		MOV A, X
		CLRC
		ADC A, #$08
		AND A, #$38
		MOV X, A
		BNE -

	MOV $F2, #$5C
	MOV $F3, X      ; X is 0
	MOV $F2, #$6C
	MOV $F3, #$20

	MOV A, $FD
	JMP MainLoop_WaitLoop


ParseSongData:	; WHEN ARE THE NAMESPACES COMING BACK
	.POPX_ReadByte:
		MOV X, !BACKUP_X
	.Start:
	.ReadByte:
		MOV Y, #$00
	.Y00ReadByte:           ; Use if Y and X not modified
		MOV A, (CHTEMP_SONG_POINTER_L)+Y

	; If the opcode >= $80, then it's either an instrument change or a waiting opcode
		BMI .Inst_Or_Wait

		MOV !TEMP_VALUE, A
		INCW CHTEMP_SONG_POINTER_L
		SETC
		SBC A, #$60
		BMI .Note

	; Detect if the opcode is modified by its highest bits
		CMP A, #$08
		BMI .Inst_Section_HighBits

	; Opcode:
		ASL A
		MOV X, A
		JMP (.OpcodeTable-$10+X)


	.Inst_Or_Wait:
		INCW CHTEMP_SONG_POINTER_L
		AND A, #$7F
		LSR A
		BCC .WaitCmd
		MOV !TEMP_VALUE, A
		MOV A, CHTEMP_INSTRUMENT_SECTION_HIGHBITS
		AND A, #$C0
		OR A, !TEMP_VALUE
		MOV CH1_INSTRUMENT_INDEX+X, A
		CALL .CallInstrumentParser
		JMP .ReadByte

	.WaitCmd:
		BNE +
		MOV A, #$40
	+   ADC A, CH1_SONG_COUNTER+X
		;DEC A
		MOV CH1_SONG_COUNTER+X, A
		BBS0 CHTEMP_FLAGS, .DecrementReference
		BCC .Y00ReadByte    ; C still in effect since the ADC, indicates that the driver is REALLY falling behind
		RET

	.Inst_Section_HighBits:
		MOV !TEMP_VALUE, A
		AND A, #$03
		BBC2 !TEMP_VALUE, .Inst_HighBits	; If it is setting the high bits, call the right routine
		AND CHTEMP_INSTRUMENT_SECTION_HIGHBITS, #$FC
	--  TSET CHTEMP_INSTRUMENT_SECTION_HIGHBITS, A
		JMP .Y00ReadByte

	.Note:
		MOV A, !TEMP_VALUE
		CMP A, CH1_NOTE+X			;
		BEQ +						;   If absolutely nothing changed
			SET0 !PLAYBACK_FLAGS	;   no need to update the pitch
			MOV CH1_NOTE+X, A       ;__
		+ BBS4 CHTEMP_FLAGS, .PitchUpdate
			; Retrigger
			MOV $F2, #$5C       		;   Key off the needed channel
			MOV $F3, !CHANNEL_BITMASK	;__
		BBS5 CHTEMP_FLAGS, .PitchUpdate
			CALL .CallInstrumentParser
			MOV A, CH1_NOTE+X
		.PitchUpdate:
			TCALL 13
		.KeyOn:
			EOR CHTEMP_FLAGS, #%00010000    ;__ Reduces branching
			BBC4 CHTEMP_FLAGS, .ReadByte    ;__ (Inverted)
				MOV $F2, #$5C       		;   Key off nothing (so no overrides happen)
				MOV $F3, #$00       		;__
				MOV $F2, #$4C       		;   Key on the needed channel
				MOV $F3, !CHANNEL_BITMASK	;__
				CLR4 CHTEMP_FLAGS           ;__ Do attack
			-   JMP .ReadByte



	.DecrementReference:
		MOV A, CH1_REF0_COUNTER+X
		DEC A
		MOV CH1_REF0_COUNTER+X,A
		BNE .RETJump ; very vulnerable

		; Return from reference
		CLR0 CHTEMP_FLAGS
		MOV A, CH1_REF0_POINTER_H+X
		MOV Y, A
		MOV A, CH1_REF0_POINTER_L+X
		MOVW CHTEMP_SONG_POINTER_L, YA

		MOV A, CH1_SONG_COUNTER+X
		BMI -   ; Indicates that the driver is really falling behind

		RET

	.Inst_HighBits:
		XCN A
		ASL A
		ASL A
		AND CHTEMP_INSTRUMENT_SECTION_HIGHBITS, #$3F
		JMP --


	.NoAttack:
		SET4 CHTEMP_FLAGS
		JMP .POPX_ReadByte


	.Keyoff:
		SET1 CHTEMP_FLAGS
		MOV $F2, #$5C
		MOV $F3, !CHANNEL_BITMASK
		JMP .POPX_ReadByte

	; End:
	;     SET0 CHTEMP_FLAGS
	;     POP X
	;     OR !PATTERN_END_FLAGS, !CHANNEL_BITMASK
	;     CMP !PATTERN_END_FLAGS, #$FF
	;     BNE RETJump
	;     CALL SPC_ParsePatternData
	;     POP A
	;     POP A
	;     JMP SPC_mainLoop_01
	.Jump:
		MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y assumed to be 0
		INC Y
		MOV X, A	; I have scrapped X anyway while jumping here
		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		MOV CHTEMP_SONG_POINTER_L, X	;	8 cycles, faster than juggling the regs
		MOV CHTEMP_SONG_POINTER_H, A	;__ and then doing a MOVW (9 cycles)
		JMP .POPX_ReadByte


	.RETJump:
		RET

	.CallInstrumentParser:

		CLR1 CHTEMP_FLAGS
		OR CHTEMP_FLAGS, #%00101000
		MOV CHTEMP_COUNTERS_HALT, Y
		MOV CHTEMP_COUNTERS_DIRECTION, Y
		JMP ParseInstrumentData_Load

	.SetVolumeL_or_R:
		MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y assumed to be 0
		INCW CHTEMP_SONG_POINTER_L
		AND !CHANNEL_REGISTER_INDEX, #$70
		MOV $F2, !CHANNEL_REGISTER_INDEX
		BBC0 $E0, +         ;   Store to right volume register if bit 0 set
		INC $F2             ;__
	+   %realChannelWrite()
		JMP .POPX_ReadByte

	.SetVolumeBoth:
		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		INCW CHTEMP_SONG_POINTER_L
		AND !CHANNEL_REGISTER_INDEX, #$70
		MOV $F2, !CHANNEL_REGISTER_INDEX
		%realChannelWrite()
		INC $F2
	+   %realChannelWrite()
		JMP .POPX_ReadByte

	.ReferenceSet:
		MOV X, !BACKUP_X

		MOV A, (CHTEMP_SONG_POINTER_L)+Y    ; Y assumed to be 0
		INC Y
		MOV CH1_REF0_COUNTER+X, A
		SET0 CHTEMP_FLAGS

		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		INC Y
		MOV !TEMP_POINTER2_L, A

		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		MOV !TEMP_POINTER2_H, A

		MOV A, #$03	;	Fastest way to
		MOV Y, #$00	;__ do this in the West
		ADDW YA, CHTEMP_SONG_POINTER_L

		; 3x INCW + 2x MOV A, d = 18 + 6 = 24 cycles
		; 2x INC Y + 2x MOV r, # + ADDW + MOV r, r = 4 + 4 + 4 + 2 = 14 cycles

		MOV CH1_REF0_POINTER_L+X, A
		MOV A, Y
		MOV CH1_REF0_POINTER_H+X, A

		MOVW YA, !TEMP_POINTER2_L
		MOVW CHTEMP_SONG_POINTER_L, YA

		JMP .ReadByte

	.ReferenceRepeat:
		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		CLRC
		ADC A, #$05                 ;__ 3 bytes of parameters + 1 byte for this opcode + 1 byte for increment afterwards
		MOVW !TEMP_POINTER0_L, YA   ;   Doesn't affect carry, works by pure concidence (Y is high byte and 0, A is the offset - low byte)
		ADC !TEMP_POINTER0_H, #$00

		MOV X, !BACKUP_X

		INCW CHTEMP_SONG_POINTER_L
		MOVW YA, CHTEMP_SONG_POINTER_L
		MOV CH1_REF0_POINTER_L+X, A
		MOV A, Y
		MOV CH1_REF0_POINTER_H+X, A
		MOV A, CHTEMP_SONG_POINTER_L    ; The high byte is correct but the low one got corrupted

		SUBW YA, !TEMP_POINTER0_L   ;   Get address of last
		MOVW !TEMP_POINTER0_L, YA   ;__ reference opcode's parameters

		MOV Y, #$00

		MOV A, (!TEMP_POINTER0_L)+Y
		MOV CH1_REF0_COUNTER+X, A
		INC Y

		SET0 CHTEMP_FLAGS

		MOV A, (!TEMP_POINTER0_L)+Y
		MOV CHTEMP_SONG_POINTER_L, A
		INC Y

		MOV A, (!TEMP_POINTER0_L)+Y
		MOV CHTEMP_SONG_POINTER_H, A

		JMP .ReadByte

    if !SNESFM_CFG_PITCHBEND_EFFECTS
    .FinePitch:
		MOV A, X						;
        MOV X, !BACKUP_X				;	Store pitch effect ID
		MOV CH1_PITCH_EFFECT_ID+X, A	;__

        MOV A, (CHTEMP_SONG_POINTER_L)+Y	;
		CMP A, CH1_PITCH_EFFECT_VAL_L+X		;
        BEQ +								;	Update low byte of pitch if needed
            MOV CH1_PITCH_EFFECT_VAL_L+X, A	;
            SET0 !PLAYBACK_FLAGS			;__
		+ MOV A, Y							;
		CMP A, CH1_PITCH_EFFECT_VAL_H+X		;
		BEQ +								;	Zero out high byte of pitch if needed
			MOV CH1_PITCH_EFFECT_VAL_H+X, A	;
			SET0 !PLAYBACK_FLAGS			;__
		+ INCW CHTEMP_SONG_POINTER_L
        JMP .Y00ReadByte
    endif

	.OpcodeTable:
		dw .NoAttack		; $68, Disable attack
		dw .POPX_ReadByte	; $69, Arp table
        if !SNESFM_CFG_PITCHBEND_EFFECTS
		dw .POPX_ReadByte	; $6A, Pitch table
		dw .FinePitch		; $6B, Fine pitch
        else
		dw .POPX_ReadByte, .POPX_ReadByte	; $6A-$6B, Pitch effects
        endif
		for i = 0..4 : dw .POPX_ReadByte : endfor

		dw .SetVolumeL_or_R	; $70, Set left volume
		dw .SetVolumeL_or_R	; $71, Set right volume
		dw .SetVolumeBoth	; $72, Set both volumes
		dw .POPX_ReadByte	; $73, Left volume slide
		dw .POPX_ReadByte	; $74, Right volume slide
		dw .POPX_ReadByte	; $75, Both volume slide
		for i = 0..6 : dw .POPX_ReadByte : endfor
		dw .Keyoff			; $7C, Keyoff
		dw .ReferenceRepeat	; $7D, Repeat last reference
		dw .ReferenceSet	; $7E, Set reference
		dw .Jump			; $7F, Loop/Jump

MainLoop:
	.WaitLoop:
		MOV !TIMER_VALUE, $FD
		MOV A, !TIMER_VALUE
		BEQ .WaitLoop
	.Action:
	.transferChToTemp:

		MOV A, CH1_FLAGS+X
		MOV CHTEMP_FLAGS, A
		MOV A, CH1_SONG_POINTER_L+X
		MOV CHTEMP_SONG_POINTER_L, A
		MOV A, CH1_SONG_POINTER_H+X
		MOV CHTEMP_SONG_POINTER_H, A
		MOV A, CH1_INSTRUMENT_TYPE+X
		MOV CHTEMP_INSTRUMENT_TYPE, A
		MOV A, CH1_INSTRUMENT_SECTION_HIGHBITS+X
		MOV CHTEMP_INSTRUMENT_SECTION_HIGHBITS, A
		MOV A, CH1_COUNTERS_HALT+X
		MOV CHTEMP_COUNTERS_HALT, A
		MOV A, CH1_COUNTERS_DIRECTION+X
		MOV CHTEMP_COUNTERS_DIRECTION, A

		MOV !BACKUP_X, X

		; CALL UpdateEffects
		; SETC
		; SBC CHTEMP_EFFECT_COUNTER, !TIMER_VALUE
		; BPL +
		; CALL ParseEffectData
	; +:

		; Select the channel routine

		if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
			MOV A, CHTEMP_FLAGS
			AND A, #$04
			BEQ +
				MOV A, #(WriteToChannel_VirtualChannel&$FF)
			+:
			; if (WriteToChannel_VirtualChannel&$FF) > 0    // ASAR YOU FUCKING ASSHOLE
				CLRC
				ADC A, #(WriteToChannel&$FF)
			; endif
			MOV $FFC0+2, A
		endif

		SETC
		MOV A, CH1_SONG_COUNTER+X
		SBC A, !TIMER_VALUE
		MOV CH1_SONG_COUNTER+X, A
		BPL +
		CALL ParseSongData_Start
	+:
		CALL ParseInstrumentData_Start

	TCALL 13

	.transferTempToCh:
		MOV A, CHTEMP_FLAGS
		MOV CH1_FLAGS+X, A
		MOV A, CHTEMP_SONG_POINTER_L
		MOV CH1_SONG_POINTER_L+X, A
		MOV A, CHTEMP_SONG_POINTER_H
		MOV CH1_SONG_POINTER_H+X, A
		MOV A, CHTEMP_INSTRUMENT_TYPE
		MOV CH1_INSTRUMENT_TYPE+X, A
		MOV A, CHTEMP_INSTRUMENT_SECTION_HIGHBITS
		MOV CH1_INSTRUMENT_SECTION_HIGHBITS+X, A
		MOV A, CHTEMP_COUNTERS_HALT
		MOV CH1_COUNTERS_HALT+X, A
		MOV A, CHTEMP_COUNTERS_DIRECTION
		MOV CH1_COUNTERS_DIRECTION+X, A

	.GoToNextChannel:
		MOV A, X
		CLRC
		ADC A, #$08
		; This cannot set carry
		ADC !CHANNEL_REGISTER_INDEX, #$10
		MOV X, A
		ASL !CHANNEL_BITMASK
		BNE .Action

		MOV X, #$00
		INC !CHANNEL_BITMASK
		JMP .WaitLoop

ParseInstrumentData:
	.Start:
		BBS5 CHTEMP_FLAGS, .OneOff
		BBC1 CHTEMP_FLAGS, .Load
		RET

	.OneOff:
		CLR5 CHTEMP_FLAGS
		RET

	.Load:
		MOV X, !BACKUP_X
		MOV A, CH1_INSTRUMENT_INDEX+X
		MOV Y, A
		MOV A, InstrumentPtrLo+Y
		MOV !TEMP_POINTER0_L, A
		MOV A, InstrumentPtrHi+Y
		MOV !TEMP_POINTER0_H, A
		MOV A, #$00
		MOV Y, A

		INCW !TEMP_POINTER0_L
		INCW !TEMP_POINTER0_L

		BBS3 CHTEMP_FLAGS, +
		JMP .NotFirstTime
		+:

		MOV X, !BACKUP_X
		MOV CH1_ARPEGGIO+X, A
		MOV CH1_INSTRUMENT_TYPE_POINTER+X, A
		MOV CH1_ENVELOPE_POINTER+X, A
		MOV CH1_SAMPLE_POINTER_POINTER+X, A
		MOV CH1_ARPEGGIO_POINTER+X, A
		MOV CH1_PITCHBEND_POINTER+X, A
		MOV $E0, #$05

		MOV !TEMP_VALUE, #$01
		MOV !TEMP_VALUE2, #$04

		-:
			CALL .UpdateMacro
			INC X
			ASL !TEMP_VALUE
			DBNZ !TEMP_VALUE2, -

		CLR3 CHTEMP_FLAGS
		JMP .Finish
	.NotFirstTime:

		MOV !TEMP_VALUE, #$01
		MOV !TEMP_VALUE2, #$04

		-:
			MOV A, CHTEMP_COUNTERS_HALT
			AND A, !TEMP_VALUE
			BNE +
				SETC
				MOV A, CH1_MACRO_COUNTERS+X
				SBC A, !TIMER_VALUE
				MOV CH1_MACRO_COUNTERS+X, A
				BPL +
					CALL .UpdateMacro
					JMP ++
			+
				CLRC
				ADC !TEMP_POINTER0_L, #$04
				ADC !TEMP_POINTER0_H, #$00
			++
			INC X
			ASL !TEMP_VALUE
			DBNZ !TEMP_VALUE2, -

	.Finish:
		MOV X, !BACKUP_X
		MOV A, CHTEMP_COUNTERS_HALT		;
		EOR A, #$0F						;	If all counters are halted, parsing
		BNE +                           ;	instrument data is not necessary anymore
			SET1 CHTEMP_FLAGS			;__
		+ RET

	.UpdateMacro:
		PUSH X
		MOV Y, #$00
		MOV A, (!TEMP_POINTER0_L)+Y             ;
		MOV !TEMP_POINTER1_L, A                 ;
		INCW !TEMP_POINTER0_L                   ;   Get base
		MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
		MOV !TEMP_POINTER1_H, A                 ;
		INCW !TEMP_POINTER0_L                   ;__

		MOV Y, !TEMP_VALUE2                     ;	Determine whether to double the pointer
		MOV A, ..InsTypeMaskTable-1+Y 			; -	-1 cuz the Y is never 0
		MOV Y, #$00
		AND A, CHTEMP_INSTRUMENT_TYPE           ;__
		BEQ +
			MOV A, CH1_MACRO_POINTERS+X         ;
			ASL A                               ;   Get the current
			BCC ++                              ;   macro pointer (double)
				INC Y                           ;
			JMP ++                              ;__
		+:
			MOV A, CH1_MACRO_POINTERS+X         ;   Get the current macro pointer (single)
		++:
		ADDW YA, !TEMP_POINTER1_L               ;   Get the current
		MOVW !TEMP_POINTER1_L, YA               ;__ macro pointer

		MOV Y, #$00
		MOV A, (!TEMP_POINTER0_L)+Y             ;   Get the amount of steps
		INCW !TEMP_POINTER0_L                   ;__
		CMP A, CH1_MACRO_POINTERS+X
		BNE ++
			OR CHTEMP_COUNTERS_HALT, !TEMP_VALUE
			JMP +
		++  ;TODO: More looping types
			MOV A, CH1_MACRO_POINTERS+X
			INC A
			MOV CH1_MACRO_POINTERS+X, A
			MOV A, (!TEMP_POINTER0_L)+Y			;__	Get the counter value
			MOV CH1_MACRO_COUNTERS+X, A		    ;__ Store counter value
		+
		INCW !TEMP_POINTER0_L
		MOV A, !TEMP_VALUE2
		ASL A
		MOV X, A
		JMP (..ActualUpdateTable-2+X) 			; -2 cuz it will never be 0, therefore shifting by 1

		..ActualUpdateTable: ; Reversed because DBNZ and shit
			dw .UpdateArpeggio
			dw .UpdateSamplePointer
			dw .UpdateEnvelope
			dw .UpdateInstrumentType
			dw $0000    ; Pitchbend, move to the beginning when implementing
		..InsTypeMaskTable:     ; Reversed, Doubles the actual pointer if the bit is set in instrument type
			db $00, !SAMPLE_USE_ADDRESS, !ENVELOPE_TYPE_ADSR, $00
			db $00 ; Pitchbend, move to the beginning when implementing

	.UpdateInstrumentType:
		POP X
		MOV0 C, CHTEMP_INSTRUMENT_TYPE      ;__ Get the old value
		MOV A, (!TEMP_POINTER1_L)+Y         ;   Get the current value
		MOV CHTEMP_INSTRUMENT_TYPE, A      	;__
		EOR0 C, CHTEMP_INSTRUMENT_TYPE      ;   Don't update if nothing changed
		BCC ++                              ;__
			SET0 !PLAYBACK_FLAGS                ;
			MOV $F2, #$3D                       ;
			BBC0 CHTEMP_INSTRUMENT_TYPE, +		;
				MOV A, !CHANNEL_BITMASK         ;
				TCLR $F3, A                     ;   Update the noise enable flag
				JMP ++                          ;
			+:                                  ;
				OR $F3, !CHANNEL_BITMASK        ;__
	++  AND !CHANNEL_REGISTER_INDEX, #$70	;
		OR !CHANNEL_REGISTER_INDEX, #$05	;
		MOV $F2, !CHANNEL_REGISTER_INDEX	;
		MOV1 C, $F3                         ;   If the envelope mode isn't changed,
		EOR1 C, CHTEMP_INSTRUMENT_TYPE      ;   don't clear the envelope
		BCC .RET_                            ;__
		AND !CHANNEL_REGISTER_INDEX, #$70	;
		BBC1 CHTEMP_INSTRUMENT_TYPE, +		;
			OR !CHANNEL_REGISTER_INDEX, #$05;   Write address to DSP (ADSR1)
			MOV $F2, !CHANNEL_REGISTER_INDEX;__
			MOV $F3, #$80                   ;   If ADSR is used,
			INC $F2                         ;   Clear out the ADSR envelope
			MOV $F3, #$00                   ;__
		#.RET_ RET
		+:                                  ;
			OR !CHANNEL_REGISTER_INDEX, #$08;
			MOV $F2, !CHANNEL_REGISTER_INDEX;
			MOV A, $F3                      ;   If GAIN is used,
			DEC $F2                         ;   set the GAIN envelope to the current value
			%realChannelWrite()             ;
			DEC $F2                         ;
			DEC $F2                         ;
			MOV $F3, #$00                   ;__
		RET

	.UpdateEnvelope:
		POP X
		AND !CHANNEL_REGISTER_INDEX, #$70           ;
		BBC1 CHTEMP_INSTRUMENT_TYPE, +             	;
			OR !CHANNEL_REGISTER_INDEX, #$05        ;
			MOV $F2, !CHANNEL_REGISTER_INDEX        ;
			MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Attack, Decay
			INC Y                                   ;
			OR A, #$80                              ;
			%realChannelWrite()                     ;__
			INC $F2                                 ;
			MOV A, (!TEMP_POINTER1_L)+Y             ;   Update Sustain, Release
			%realChannelWrite()                     ;__
			RET
		+:
			OR !CHANNEL_REGISTER_INDEX, #$07        ;
			MOV $F2, !CHANNEL_REGISTER_INDEX        ;   Update GAIN envelope
			MOV A, (!TEMP_POINTER1_L)+Y             ;
			%realChannelWrite()                     ;__
			RET
	.UpdateSamplePointer:
		MOV X, !BACKUP_X					    ;__
		BBS3 CHTEMP_INSTRUMENT_TYPE, +			;__ If sample index is used,
			MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV Y, A                            ;
			MOV A, CHTEMP_INSTRUMENT_TYPE		;
			AND A, #$30                         ;
			XCN A                               ;
			MOV $EF, A                          ;  Get pointer from sample index
			MOV A, CHTEMP_INSTRUMENT_TYPE		;
			AND A, #$40                         ;
			OR A, $EF                           ;
			TCALL 15                            ;
			MOVW !TEMP_POINTER2_L, YA	        ;
			MOV CH1_SAMPLE_POINTER_L+X, A       ;
			MOV A, Y                            ;
			MOV CH1_SAMPLE_POINTER_H+X, A       ;
			JMP .updatePointer                   ;__
		+   MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV !TEMP_POINTER2_L, A				;   If no, just blatantly
			INC Y								;   Load sample pointer into memory
			MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV !TEMP_POINTER2_H, A				;__
	.updatePointer:
		BBC7 CHTEMP_FLAGS, +                    ;__ If the currently playing sample is 1, update sample 0
			MOV A, X                            ;
			OR A, #$04                          ;   Add 4 to the pointer
			MOV X, A                            ;__
		+
			MOV A, !TEMP_POINTER2_H				;   Check if the high byte is the same
			CMP A, $0203+X                      ;__
			BNE ..withRestart					;
			MOV A, !TEMP_POINTER2_L				;	If yes, update only the low byte of the sample pointer
			MOV $0202+X, A                      ;__
			POP X
			RET

		..withRestart:
			MOV Y, A							;
			MOV A, X							;
			EOR A, #$04							;	Swap byte offset
			MOV X, A							;
			MOV A, Y							;__
			MOV $0203+X, A                      ;   If high byte is different,
			MOV A, !TEMP_POINTER2_L				;   Update sample loop pointer
			MOV $0202+X, A                      ;__
			; Reset to blank sample was here, if needed bring back here
			AND !CHANNEL_REGISTER_INDEX, #$70	;
			OR !CHANNEL_REGISTER_INDEX, #$04	;   Write address to DSP
			MOV $F2, !CHANNEL_REGISTER_INDEX	;__
			MOV A, X		                    ;
			LSR A                               ;   Write Source Number to DSP
			LSR A                               ;
			%realChannelWrite()                 ;__
			EOR CHTEMP_FLAGS, #$80				;__ Next time update the other sample
			POP X
			RET

	.UpdateArpeggio:
		MOV X, !BACKUP_X
		MOV A, (!TEMP_POINTER1_L)+Y 			;__ Get arpeggio
		CMP A, CH1_ARPEGGIO+X                   ;
		BEQ +                                   ;   If arpeggio changed, update it
			SET0 !PLAYBACK_FLAGS                ;   and set to update the pitch
			MOV CH1_ARPEGGIO+X, A               ;__
		+ POP X
		RET

UpdatePitch:
	BBC0 !PLAYBACK_FLAGS, R
	CLR0 !PLAYBACK_FLAGS
	MOV A, CH1_NOTE+X                     	;
	CLRC                                    ;   Apply arpeggio
	ADC A, CH1_ARPEGGIO+X                 	;__
	BBS0 CHTEMP_INSTRUMENT_TYPE, .TonePitch
	.NoisePitch:
		AND A, #$1F                             ;
		MOV $F2, #$6C                           ;  Update noise clock
		AND $F3, #$E0                           ;
		OR A, $F3                               ;
		%realChannelWrite()                     ;__
	#R:	RET
	.TonePitch:
		; Defines
		!L000_NOTE_VALUE = !TEMP_VALUE2
		!L000_BASE_PITCH_L = !TEMP_POINTER0_L
		!L000_BASE_PITCH_H = !TEMP_POINTER0_H
		!L000_TBL_INDEX = !TEMP_POINTER1_H
		!L000_HIGH_RESULT = !TEMP_POINTER2_L

		AND !CHANNEL_REGISTER_INDEX, #$70       ;
		OR !CHANNEL_REGISTER_INDEX, #$02        ;   DSP Address: Low pitch
		MOV $F2, !CHANNEL_REGISTER_INDEX;       ;__
		if !SNESFM_CFG_PITCHBEND_ANY

			MOV !L000_NOTE_VALUE, A

			if !SNESFM_CFG_PITCHBEND_ALL
			
			elseif ((!SNESFM_CFG_PITCHBEND_EFFECTS)+(!SNESFM_CFG_INSTRUMENT_PITCHBEND)+(~!SNESFM_CFG_FINE_PITCH)) == 2

			MOV Y, #$00
			MOV A, CH1_PITCHBEND_L+X		;
			CLRC							;	Add up the low bytes
			ADC A, CH1_PITCH_EFFECT_VAL_L+X	;__
			BCS +							;
				DEC Y						;	If value is less than #$80, dec base
				SETC						;__
			+ SBC A, #$80					;__	Subtract the #$80 hassle-free
			MOV !L000_TBL_INDEX, A			;	Neither of these
			MOV A, Y						;__	affect carry
			ADC A, CH1_PITCHBEND_H+X		;
			CLRC							;	Add up the high bytes, with the overflow
			ADC A, CH1_PITCH_EFFECT_VAL_H+X	;__
			; How the fuck that worked:
				; MOV, CLRC, ADC - The usual business
				; C is set if an overflow occured,
				; Then i DEC Y if that happens,
				; So Y is -1 if the value < $100; and 0 if >= $100

				; Then #$80 is subtracted,
				; and carry stores whether a borrow occured
				; If a borrow did not occur,
				; 1 should be added back to Y
				; so that it becomes mathematically correct.

				; But the ADC adds carry, and that can be used
				; While loading the first byte, the carry is added

				; Result: 44/46 cycles instead of 54 and not dealing with words
			ASL A							;
			CLRC							;	Add up the note immediately
			ADC A, !L000_NOTE_VALUE			;__

			MOV Y, !L000_TBL_INDEX
			BEQ .OneDown
			CMP Y, #$80
			BEQ .NoBend

			else	; not !SNESFM_CFG_PITCHBEND_BOTH

			if !SNESFM_CFG_INSTRUMENT_PITCHBEND

			MOV A, CH1_PITCHBEND_L+X			;
			MOV Y, A							;	Get instrument pitchbend
			MOV A, CH1_PITCHBEND_H+X			;__

			elseif !SNESFM_CFG_PITCHBEND_EFFECTS

			MOV A, CH1_PITCH_EFFECT_VAL_L+X		;
			MOV Y, A							;	Get effect pitchbend
			MOV A, CH1_PITCH_EFFECT_VAL_H+X		;__

			endif

			ASL A								;
			CLRC								;	Add it
			ADC A, !L000_NOTE_VALUE				;	to note
			MOV !L000_NOTE_VALUE, A				;__

			CMP Y, #$80
			BEQ .NoBend
			CMP Y, #$00
			BEQ .OneDown

			endif

			MOV !L000_TBL_INDEX, Y


				; At this point there is definitely multiplication to be done

				CALL .ClampPitch		;
				; MOV A, PitchTableLo+Y <- Done by clampPitch
				MOV !L000_BASE_PITCH_L, A			;	Store the (base) pitch value in TMP0
				MOV A, PitchTableHi+Y			;
				MOV !L000_BASE_PITCH_H, A			;__

				MOV Y, !L000_TBL_INDEX

				MOV A, LogTable+Y			;
				PUSH A						;
				MOV Y, !L000_BASE_PITCH_H	;	Multiply high byte
				MUL YA  					;
				MOVW !L000_HIGH_RESULT, YA	;__
				POP A						;
				MOV Y, !L000_BASE_PITCH_L	;	Multiply low byte
				MUL YA						;__
				CMP A, #$80					;
				MOV A, Y					;	Round the number
				ADC A, #$00					;__

				MOV Y, #$00					;
				ADDW YA, !L000_HIGH_RESULT	;	Get sum of both bytes
				MOV !TEMP_POINTER2_H, Y		;__

				LSR !TEMP_POINTER2_H 		;
				ROR A						;
				LSR !TEMP_POINTER2_H 		;
				ROR A						;	Divide by 8
				LSR !TEMP_POINTER2_H		;
				ROR A						;
				MOV Y, !TEMP_POINTER2_H		;__

				CMP !L000_TBL_INDEX, #$00
				BMI +
					EOR A, #$FF					;
					EOR !TEMP_POINTER2_H, #$FF	;	Invert the negatives
					MOV Y, !TEMP_POINTER2_H		;__
				+:
				ADDW YA, !L000_BASE_PITCH_L

				MOV !TEMP_POINTER0_L, Y		;	Update low byte of pitch
				%realChannelWrite()			;__
				INC $F2						;
				MOV A, !TEMP_POINTER0_L		;	Update high byte of pitch
				%realChannelWrite()			;__
				RET

            .OneDown:
            DEC A
			.NoBend:
		endif
			CALL .ClampPitch
			; MOV A, PitchTableLo+Y <- Done by clampPitch
			%realChannelWrite()                     ;__	Update low byte of pitch
			MOV A, PitchTableHi+Y                   ;
			INC $F2                                 ;   Update high byte of pitch
			%realChannelWrite()                     ;__
		RET
	.ClampPitch:
		MOV Y, A                                ;
		CMP A, #$60                             ;
		BMI +                                   ;
			MOV Y, #$00                         ;   Clamp values to 00..5F
			CMP A, #$B0                         ;
			BPL +                               ;
				MOV Y, #$5F                     ;__
		+ MOV A, PitchTableLo+Y					;__	I always do this immediately after anyway
		RET

TransferDataBlock:
	.Labels:
		TDB_OUT_PTR_L = $D0
		TDB_OUT_PTR_H = $D1
		TDB_TMP_PTR_L = $EE
		TDB_TMP_PTR_H = $EF
	.Documentation:
		; Inputs:
		; $D0-D1 - Output pointer
		; Temp Variables:
		; $EE-EF - Output pointer
		; Other variables used:
		; $40 - Message counter on thread 1
	.Start:
		MOVW YA, TDB_OUT_PTR_L
		MOVW TDB_TMP_PTR_L, YA
		MOV Y, #$00
		CALL WaitCPUMsg
		PUSH A
		AND A, #$E0     ;   Both opcodes 4x and 5x
		CMP A, #$40     ;__ are valid
		BNE .POPA_RET

		MOV A, #$10
		CALL SendCPUMsg
	.GetWord:
		CALL WaitCPUMsg
		CMP A, #$A0
		BEQ .End

		CMP A, #$90
		BNE .POPA_RET

		; Push the 2 bytes where they need to be
		MOV A, $F6
		MOV (TDB_TMP_PTR_L)+Y, A
		INCW TDB_TMP_PTR_L
		MOV A, $F7
		MOV (TDB_TMP_PTR_L)+Y, A
		INCW TDB_TMP_PTR_L

		; Affirm having received data
		MOV A, #$20
		CALL SendCPUMsg
		JMP .GetWord

	.POPA_RET
		POP A : RET

	.End:
		POP A
		AND A, #$10
		BNE SendCPUMsg
		MOV A, #$30

SendCPUMsg:
	; Inputs:
	; A - message ID
	MOV $F5, A
	MOV $F4, MESSAGE_CNT_TH1
	INC MESSAGE_CNT_TH1
	.RETJump:
	RET

WaitCPUMsg:
	-:
		MOV A, $F4
		CBNE MESSAGE_CNT_TH1, -
	INC MESSAGE_CNT_TH1
	MOV A, $F5
	AND A, #$F0
	RET

set_echoFIR:
	MOV $00, #$08
	MOV $01, #$0F
	MOV Y, #$00
	-:
		MOV $F2, $01
		MOV A, set_echoFIR_FIRTable+Y
		MOV $F3, A
		CLRC
		ADC $01, #$10
		INC Y
		DBNZ $00, -
	RET


	.FIRTable:
		db #$7f, #$00, #$00, #$00, #$00, #$00, #$00, #$00
;

if !SNESFM_CFG_SAMPLE_GENERATE >= 1

if !SNESFM_CFG_PULSEGEN_ANY >= 1
PulseGenTables:    ;In order:
	;Highbyte with sz = 00 (8000),
	;Lowbyte with s=0 (8000/0000) / Highbyte with sz = 01 (0000), 
	;Highbyte with sz = 1- (7FFF),
	;Lowbyte with s=1 (7FFF) / Highbyte with sz = 1- (7FFF)
	;Highbytes are EOR #$80'd.
	db $80, $00, $FF, $FF
	;Inversion values for fractional value
	db $7F, $FE, $00, $80
PulseGenLabels:
	PUL_OUT_PAGE    = $D0
	PUL_DUTY        = $D1
	PUL_FLAGS       = $D2

	PUL_OUT_PTR_L   = $EE
	PUL_OUT_PTR_H   = $EF
endif   ; !SNESFM_CFG_PULSEGEN_ANY

if !SNESFM_CFG_PULSEGEN_LONG >= 1
GeneratePulse_128:
	.Documentation:
		;   Memory allocation:
		;   Inputs:
		;       $D0 - Output page
		;       $D1 - Duty cycle
		;       $D2 - Flags: ddddddsz
		;           dddddd - Duty cycle (fractional part, highest bit of fractional part in $D1)
		;           s - starting value (0 - 0/-1, 1 - 1)
		;           z - the low value is -1 instead of 0 (for not ringmod)
		;   Temp variables:
		;       $EE-EF - Output pointer
	.Start:
	;Low byte of first part
		MOV PUL_OUT_PTR_H, PUL_OUT_PAGE
		MOV PUL_OUT_PTR_L, #$00
		MOV A, PUL_DUTY         ;   Get finishing low byte
		AND A, #$FE             ;__
		MOV Y, A                ;   If there are no bytes in the first part, skip the part
		BEQ +                   ;__
		MOV A, PUL_FLAGS
		AND A, #$02
		MOV X, A
		MOV A, PulseGenTables+1+X
		-:
			DEC Y
			DEC Y
			MOV (PUL_OUT_PTR_L)+Y, A
			CMP Y, #$00
			BNE -
	;High byte of first part
		MOV A, PUL_DUTY         ;   Get finishing high byte
		OR A, #$01              ;__
		MOV Y, A
		MOV A, PUL_FLAGS
		AND A, #$03
		MOV X, A
		MOV A, PulseGenTables+X
		EOR A, #$80
		-:
			DEC Y
			DEC Y
			MOV (PUL_OUT_PTR_L)+Y, A
			CMP Y, #$01
			BNE -
	+:
	;Second part, the fractional value
		MOV A, PUL_FLAGS            ;
		AND A, #$03                 ;
		MOV X, A                    ;   Get the inversion value into "temp variable"
		MOV A, PulseGenTables+4+X
		MOV PUL_OUT_PTR_L, A		;__
		MOV A, PUL_DUTY             ;
		LSR A                       ;   Get the actual fraction,
		MOV A, PUL_FLAGS            ;   while also getting
		ROR A                       ;   z flag into carry
		AND A, #$FE                 ;__
		BCC +                       ;   If z flag is set,
		LSR A                       ;__ halve the fraction
	+   EOR A, PUL_OUT_PTR_L		;__ Invert the fraction as needed
		MOV Y, A
		MOV A, PUL_DUTY             ;   Get index for the fraction
		AND A, #$FE                 ;
		MOV PUL_OUT_PTR_L, A		;__
		MOV A, Y
		MOV Y, #$01
		MOV (PUL_OUT_PTR_L)+Y, A
		MOV A, #$00
		DEC Y
		MOV (PUL_OUT_PTR_L)+Y, A
		INC PUL_OUT_PTR_L
		INC PUL_OUT_PTR_L
	;Third part
		MOV A, PUL_DUTY
		EOR A, #$FE
		AND A, #$FE
		MOV Y, A
		MOV A, PUL_FLAGS
		AND A, #$02
		EOR A, #$02
		MOV X, A
		MOV A, PulseGenTables+1+X
		-:
			DEC Y
			DEC Y
			MOV (PUL_OUT_PTR_L)+Y, A
			CMP Y, #$00
			BNE -
	;High byte of first part
		MOV A, PUL_DUTY         ;   Get finishing high byte
		EOR A, #$FE             ;
		OR A, #$01              ;__
		MOV Y, A
		MOV A, PUL_FLAGS
		AND A, #$03
		EOR A, #$02
		MOV X, A
		MOV A, PulseGenTables+X
		EOR A, #$80
		-:
			DEC Y
			DEC Y
			MOV (PUL_OUT_PTR_L)+Y, A
			CMP Y, #$01
			BNE -
	+:
	RET

endif   ; !SNESFM_CFG_PULSEGEN_LONG

if !SNESFM_CFG_PULSEGEN_SHORT >= 1
GeneratePulse_32:
	;   Memory allocation:
	;   Inputs:
	;       $D0 - Output page
	;       $D1 - Duty cycle: ppdddddd
	;           pp - subpage number
	;           dddddd - Duty cycle
	;       $D2 - Flags: ddddddsz
	;           dddddd - Duty cycle (fractional part, highest bit of fractional part in $D1)
	;           s - starting value (0 - 0/-1, 1 - 1)
	;           z - the low value is -1 instead of 0 (for not ringmod)
	;   Temp variables:
	;       $EE-EF - Output pointer

	;Low byte of first part
	MOV PUL_OUT_PTR_H, PUL_OUT_PAGE
	MOV PUL_OUT_PTR_L, PUL_DUTY
	AND PUL_OUT_PTR_L, #$C0
	MOV A, PUL_DUTY         ;   Get finishing low index
	AND A, #$3E             ;__
	MOV Y, A                ;   If there are no bytes in the first part, skip the part
	BEQ +                   ;__
	MOV A, PUL_FLAGS
	AND A, #$02
	MOV X, A
	MOV A, PulseGenTables+1+X
	-:
		DEC Y
		DEC Y
		MOV (PUL_OUT_PTR_L)+Y, A
		CMP Y, #$00
		BNE -
	;High byte of first part
	MOV A, PUL_DUTY         ;
	AND A, #$3E             ;   Get finishing high index
	OR A, #$01              ;__
	MOV Y, A
	MOV A, PUL_FLAGS
	AND A, #$03
	MOV X, A
	MOV A, PulseGenTables+X
	EOR A, #$80
	-:
		DEC Y
		DEC Y
		MOV (PUL_OUT_PTR_L)+Y, A
		CMP Y, #$01
		BNE -
	+:
	;Second part, the fractional value
	MOV A, PUL_FLAGS            ;
	AND A, #$03                 ;
	MOV X, A                    ;   Get the inversion value into "temp variable"
	MOV A, PulseGenTables+4+X
	MOV PUL_OUT_PTR_L, A		;__
	MOV A, PUL_DUTY             ;
	LSR A                       ;   Get the actual fraction,
	MOV A, PUL_FLAGS            ;   while also getting
	ROR A                       ;   z flag into carry
	AND A, #$FE                 ;__
	BCC +                       ;   If z flag is set,
	LSR A                       ;__ halve the fraction
	+   EOR A, PUL_OUT_PTR_L    ;__ Invert the fraction as needed
	MOV Y, A
	MOV A, PUL_DUTY             ;   Get index for the fraction
	AND A, #$FE                 ;
	MOV PUL_OUT_PTR_L, A		;__
	MOV A, Y
	MOV Y, #$01
	MOV (PUL_OUT_PTR_L)+Y, A
	MOV A, #$00
	DEC Y
	MOV (PUL_OUT_PTR_L)+Y, A
	INC PUL_OUT_PTR_L
	INC PUL_OUT_PTR_L
	;Third part
	MOV A, PUL_DUTY
	EOR A, #$FE
	AND A, #$3E
	MOV Y, A
	MOV A, PUL_FLAGS
	AND A, #$02
	EOR A, #$02
	MOV X, A
	MOV A, PulseGenTables+1+X
	-:
		DEC Y
		DEC Y
		MOV (PUL_OUT_PTR_L)+Y, A
		CMP Y, #$00
		BNE -
	;High byte of first part
	MOV A, PUL_DUTY         ;   Get finishing high byte
	EOR A, #$3E             ;
	AND A, #$3E             ;
	OR A, #$01              ;__
	MOV Y, A
	MOV A, PUL_FLAGS
	AND A, #$03
	EOR A, #$02
	MOV X, A
	MOV A, PulseGenTables+X
	EOR A, #$80
	-:
		DEC Y
		DEC Y
		MOV (PUL_OUT_PTR_L)+Y, A
		CMP Y, #$01
		BNE -
	RET

endif   ; !SNESFM_CFG_PULSEGEN_SHORT


if !SNESFM_CFG_PHASEMOD_ANY >= 1
PhaseModulation_Labels:
	MOD_CAR_PAGE        = $D0
	MOD_MOD_PAGE        = $D1
	MOD_OUT_PAGE        = $D2
	MOD_MOD_STRENGTH    = $D3
	MOD_MOD_PHASE_SHIFT = $D4

	MOD_OUT_INDEX_L     = $EA
	MOD_OUT_INDEX_H     = $EB
	MOD_MOD_INDEX_L     = $EC
	MOD_MOD_INDEX_H     = $ED
	MOD_MAIN_TEMP_L     = $EE
	MOD_MAIN_TEMP_H     = $EF

endif   ; !SNESFM_CFG_PHASEMOD_ANY

if !SNESFM_CFG_PHASEMOD_LONG >= 1
PhaseModulation_128:
	.Documentation:
		;   Memory allocation:
		;   Inputs:
		;       $D0 - Carrier page
		;       $D1 - Modulator page
		;       $D2 - Output page
		;       $D3 - Modulation strength
		;       $D4 - Modulator phase shift (for "detune")
		;   Temp variables:
		;       $EA-EB - Output pointer
		;       $EC-ED - Modulator pointer
		;       $EE-EF - Main temp variable
	.Setup:
		MOV X, #$00
		MOV MOD_OUT_INDEX_H, MOD_OUT_PAGE
		MOV MOD_MOD_INDEX_H, MOD_MOD_PAGE
		MOV MOD_OUT_INDEX_L, X
		MOV MOD_MOD_INDEX_L, MOD_MOD_PHASE_SHIFT
		ASL MOD_MOD_INDEX_L
	.loop:
		INC MOD_MOD_INDEX_L             ;
		MOV A, (MOD_MOD_INDEX_L+X)      ;   Get high byte
		BMI .loop_negative
		MOV Y, MOD_MOD_STRENGTH         ;
		MUL YA                          ;   Multiply high byte by modulation strength
		MOVW MOD_MAIN_TEMP_L, YA        ;__

		DEC MOD_MOD_INDEX_L
		MOV A, (MOD_MOD_INDEX_L+X)
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOV A, Y
		CLRC
		ADC A, MOD_MAIN_TEMP_L
		ADC MOD_MAIN_TEMP_H, #$00
		JMP .loop_afterMul
	.loop_negative:
		EOR A, #$FF
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOVW MOD_MAIN_TEMP_L, YA

		DEC MOD_MOD_INDEX_L
		MOV A, (MOD_MOD_INDEX_L+X)
		EOR A, #$FF
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOV A, Y
		CLRC
		ADC A, MOD_MAIN_TEMP_L
		ADC MOD_MAIN_TEMP_H, #$00
		EOR A, #$FF
		EOR MOD_MAIN_TEMP_H, #$FF
	.loop_afterMul:

		ASL A
		ROL MOD_MAIN_TEMP_H
		ASL A
		ROL MOD_MAIN_TEMP_H
		MOV A, MOD_MAIN_TEMP_H  ;   Replaced a third ASL A : ROL MMTH,
		ASL A                   ;__ as well as MOV A, MMTH : AND A, #$FE
		CLRC
		ADC A, MOD_OUT_INDEX_L

		MOV MOD_MAIN_TEMP_H, MOD_CAR_PAGE
		MOV MOD_MAIN_TEMP_L, A
		; X is permanently 0
		MOV A, (MOD_MAIN_TEMP_L+X)
		MOV (MOD_OUT_INDEX_L+X), A
		MOV Y, #$01
		MOV A, (MOD_MAIN_TEMP_L)+Y
		MOV (MOD_OUT_INDEX_L)+Y, A
		CLRC
		ADC MOD_OUT_INDEX_L, #$02
		CLRC
		ADC MOD_MOD_INDEX_L, #$02
		MOV A, MOD_OUT_INDEX_L
		BNE .loop
	RET

endif   ; !SNESFM_CFG_PHASEMOD_LONG

if !SNESFM_CFG_PHASEMOD_SHORT >= 1
PhaseModulation_32:
	.Documentation:
		;   Memory allocation:
		;   Inputs:
		;       $D0 - Carrier page
		;       $D1 - Modulator page
		;       $D2 - Output page
		;       $D3 - Modulation strength
		;       $D4 - Modulation phase shift (for "detune")
		;       $D5 - Subpages: ccmmoo--
		;           cc - Carrier subpage
		;           mm - Modulator subpage
		;           oo - Output subpage
		;   Temp variables:
		;       $E7    - Modulator pointer offset
		;       $EA-EB - Output pointer
		;       $EC-ED - Modulator pointer
		;       $EE-EF - Main temp variable
	.Labels:
		MOD_SUBPAGE     = $D5
		MOD_MOD_PTR_OFF = $E7
		MOD_CAR_INDEX_L = $E8
		MOD_END_INDEX_L = $E9
	.Setup:
		MOV X, #$00
		MOV MOD_OUT_INDEX_H, MOD_OUT_PAGE
		MOV MOD_MOD_INDEX_H, MOD_MOD_PAGE
		MOV A, MOD_MOD_PHASE_SHIFT  ;
		ASL A                       ;
		AND A, #$3F                 ;
		MOV MOD_MOD_INDEX_L, A      ;
		MOV A, MOD_SUBPAGE          ;   Get low byte of modulator pointer
		ASL A                       ;
		ASL A                       ;
		AND A, #$C0                 ;
		MOV MOD_MOD_PTR_OFF, A      ;
		TSET MOD_MOD_INDEX_L, A     ;__
		MOV A, MOD_SUBPAGE          ;
		XCN A                       ;   Get low byte of output pointer
		AND A, #$C0                 ;
		MOV MOD_OUT_INDEX_L, A      ;__
		CLRC                        ;
		ADC A, #$40                 ;   Get low ending byte of output pointer
		MOV MOD_END_INDEX_L, A      ;__
		MOV A, MOD_SUBPAGE          ;
		AND A, #$C0                 ;   Get low byte of carrier pointer to add later
		MOV MOD_CAR_INDEX_L, A      ;__
	.loop:
		INC MOD_MOD_INDEX_L
		MOV A, (MOD_MOD_INDEX_L+X)
		BMI .loop_negative
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOVW MOD_MAIN_TEMP_L, YA

		DEC MOD_MOD_INDEX_L
		MOV A, (MOD_MOD_INDEX_L+X)
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOV A, Y                    ; A = high byte
		MOV Y, #$00
		ADDW YA, MOD_MAIN_TEMP_L
		MOV A, Y
		JMP .loop_afterMul
	.loop_negative:
		EOR A, #$FF
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOVW MOD_MAIN_TEMP_L, YA

		DEC MOD_MOD_INDEX_L
		MOV A, (MOD_MOD_INDEX_L+X)
		EOR A, #$FF
		MOV Y, MOD_MOD_STRENGTH
		MUL YA
		MOV A, Y                    ; A = high byte
		MOV Y, #$00
		ADDW YA, MOD_MAIN_TEMP_L
		MOV A, Y
		EOR A, #$FF
	.loop_afterMul:

		ASL A
		CLRC
		ADC A, MOD_OUT_INDEX_L
		AND A, #$3E
		CLRC
		ADC A, MOD_CAR_INDEX_L

		MOV MOD_MAIN_TEMP_H, MOD_CAR_PAGE
		MOV MOD_MAIN_TEMP_L, A
		; X is permanently 0
		MOV A, (MOD_MAIN_TEMP_L+X)
		MOV (MOD_OUT_INDEX_L+X), A
		MOV Y, #$01
		MOV A, (MOD_MAIN_TEMP_L)+Y
		MOV (MOD_OUT_INDEX_L)+Y, A
		CLRC
		ADC MOD_OUT_INDEX_L, #$02
		CLRC
		ADC MOD_MOD_INDEX_L, #$02
		AND MOD_MOD_INDEX_L, #$3E
		CLRC 
		ADC MOD_MOD_INDEX_L, MOD_MOD_PTR_OFF
		CMP MOD_OUT_INDEX_L, MOD_END_INDEX_L
		BNE .loop
	RET

endif   ; !SNESFM_CFG_PHASEMOD_SHORT



if !SNESFM_CFG_RESAMPLE >= 1
LongToShort:
	.Documentation:
		;   Memory allocation:
		;   Inputs:
		;       $D0 - Input page
		;       $D1 - Output page
		;       $D2 - Subpage number: ll------
		;           ll - subpage number
		;   Temp variables:
		;       None lmfao
	.Labels:
		LTS_IN_PAGE     = $D0
		LTS_OUT_PAGE    = $D1
		LTS_OUT_SUBPAGE = $D2
	.Start:
		MOV A, LTS_IN_PAGE
		MOV .Loop+2, A			; High byte of 1st IN MOV
		MOV .Loop+3+3+2, A		; High byte of 2nd IN MOV
		MOV A, LTS_OUT_PAGE
		MOV .Loop+3+2, A		; High byte of 1st OUT MOV
		MOV .Loop+3+3+3+2, A	; High byte of 2nd OUT MOV

		MOV Y, #$F8

		MOV A, LTS_OUT_SUBPAGE
		CLRC
		ADC A, #$3E
		MOV X, A

	.Loop:
		MOV A, $2001+Y              ;   Copy high byte
		MOV $2001+X, A              ;__
		MOV A, $2000+Y              ;   Copy low byte
		MOV $2000+X, A              ;__
		DEC X : DEC X
		MOV A, Y
		SETC
		SBC A, #$08
		MOV Y, A
		CMP Y, #$F8
		BNE .Loop
	.End:
		RET

endif   ; !SNESFM_CFG_RESAMPLE

ConvertToBRR:
	.Documentation:
		;   Memory allocation:
		;   Inputs:
		;       $D0 - PCM sample page
		;       $D1 - BRR output index
		;       $D2 - Flags: fsixppbb
		;               f - whether to use filter mode 1
		;               s - short sample mode (32 samples instead of 128)
		;               i - high bit of output index
		;               x - extended sample length mode (more than 1 sample)
		;               pp - PCM sample subpage number (0-3, if s is set)
		;               bb - BRR output subpage number (0-3, if s is set)
		;       $D3 - If x is set, sample length in loops (2 added)
		;   Temp variables:
		;       $E3 - Temporary flags: bf-n----
		;               b - whether it is the first block
		;               f - whether to use filter mode 1
		;               n - negative flag
		;       $E4-$E5 - Ending pointer
		;       $E6-$EB - 3 sample points
		;       $F8-$F9 - Temporary space for 1 sample point
		;       $EC-$ED - Input pointer
		;       $EE-$EF - Output pointer
	.Labels:
		BRR_PCM_PAGE    = $D0
		BRR_OUT_INDEX   = $D1
		BRR_FLAGS       = $D2
		BRR_XLEN        = $D3

		BRR_BUFF1_PTR_L = $20
		BRR_BUFF1_PTR_H = $21
		BRR_MAXM0_L     = $F8  ;These registers are so unused
		BRR_MAXM0_H     = $F9  ;they're practically RAM!
		BRR_TEMP_FLAGS  = $E3
		BRR_END_PTR_L   = $E4
		BRR_END_PTR_H   = $E5
		BRR_SMPPT_L     = $E6
		BRR_SMPPT_H     = $E7
		BRR_CSMPT_L     = $E8
		BRR_CSMPT_H     = $E9
		BRR_LSMPT_L     = $EA  ;Last sample point of previous block for filter 1 adjustment
		BRR_LSMPT_H     = $EB  ;
		BRR_IN0_PTR_L   = $EC
		BRR_IN0_PTR_H   = $ED
		BRR_OUT_PTR_L   = $EE
		BRR_OUT_PTR_H   = $EF
	.Start:
		SET7 BRR_TEMP_FLAGS
		MOV BRR_IN0_PTR_H, BRR_PCM_PAGE ;   Set up the PCM sample page
		MOV A, BRR_FLAGS                ;__
		XCN A                           ;
		AND A, #$C0                     ;   Set up the PCM sample subpage 
		MOV BRR_IN0_PTR_L, A            ;__
		MOV A, BRR_FLAGS                ;
		AND A, #$40                     ;   Set up the ending low byte of the address
		CLRC                            ;
		ADC A, BRR_IN0_PTR_L            ;
		MOV BRR_END_PTR_L, A            ;__
		MOV BRR_LSMPT_L, #$00           ;
		MOV BRR_LSMPT_H, #$00           ;__ smppoint = 0
		MOV Y, BRR_OUT_INDEX            ;
		MOV A, BRR_FLAGS                ;
		AND A, #$23                     ;   Get the sample pointer from index
		TCALL 15                        ;
		MOVW BRR_OUT_PTR_L, YA          ;__

	.SetupCopy:
		MOV X, #$20                     ;__ Set up the destination address (it's (X+))
		MOV Y, #$00
	.CopyLoop:  ;Copy the PCM sample to the PCM buffer while halving it #
		MOV A, (BRR_IN0_PTR_L)+Y        ;                               #
		MOV BRR_CSMPT_L, A              ;                               #
		INCW BRR_IN0_PTR_L              ;   Python code:                #
		MOV A, (BRR_IN0_PTR_L)+Y        ;   currentsmppoint = array[i]  #
		INCW BRR_IN0_PTR_L              ;__                             #
		CMP A, #$80                     ;   Python code:                #   OG Python code:
		ROR A                           ;   currentsmppoint /= 2        #   for i in range(len(BRRBuffer)):
		ROR BRR_CSMPT_L                 ;__ (ASR algo from cc65)        #       BRRBuffer[i] = (array[i&(length-1)])/2
		MOV BRR_CSMPT_H, A              ;                               #
		MOV A, BRR_CSMPT_L              ;                               #
		MOV (X+), A                     ;   Python code:                #
		MOV A, BRR_CSMPT_H              ;   BRRBuffer[i]=currentsmppoint#
		MOV (X+), A                     ;                               #
		CMP X, #$40                     ;   Loop                        #
		BNE .CopyLoop   				;__                             #

		if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
		.SetupFilter:
			BBS7 BRR_TEMP_FLAGS, .FirstBlock    ;   If this is the first block, Or filter 0 is forced,
			BBS7 BRR_FLAGS, .FirstBlock         ;__ Skip doing filter 1 entirely

			MOV X, #$00
			CLR4 BRR_TEMP_FLAGS
			MOV BRR_SMPPT_L, BRR_LSMPT_L    ;   OG Python code:
			MOV BRR_SMPPT_H, BRR_LSMPT_H    ;__ currentsmppoint = 0
			BBC7 BRR_SMPPT_H, +        	    ;
				SET4 BRR_TEMP_FLAGS         ;   Inverting negative numbers
				EOR BRR_SMPPT_L, #$FF       ;
				EOR BRR_SMPPT_H, #$FF       ;__
			+:
			POP A
			MOV BRR_CSMPT_H, A
			POP A
			MOV BRR_CSMPT_L, A
			JMP .FilterLoop
		endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1

	.FirstBlock:

		MOV BRR_MAXM0_L, #$FF
		MOV BRR_MAXM0_H, #$7F
		MOV X, #$20
		JMP .BRREncoding_OuterLoop

	if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
	.FilterLoop:
		MOV Y, BRR_SMPPT_L          ;                                       #
		MOV A, $0D00+Y              ;                                       #
		BBS4 BRR_TEMP_FLAGS, +      ;                                       #
			CLRC                    ;   Python code:                        #
			ADC A, BRR_CSMPT_L      ;   currentsmppoint += smppoint_L*15/16 #
			MOV BRR_CSMPT_L, A      ;   (for positive numbers)              #
			ADC BRR_CSMPT_H, #$00   ;                                       #
			JMP ++                  ;__                                     #
		+:                          ;                                       #
			EOR A, #$FF             ;                                       #
			SETC                    ;   Python code:                        #
			ADC A, BRR_CSMPT_L      ;   currentsmppoint += smppoint_L*15/16 #
			MOV BRR_CSMPT_L, A      ;   (for negative numbers)              #
			SBC BRR_CSMPT_H, #$00   ;__                                     #
		++:                         ;                                       #   OG Python code:
		MOV A, BRR_SMPPT_H          ;                                       #   smppoint *= 0.9375
		MOV Y, #$F0                 ;   Python code:                        #   smppoint += BRRBuffer[i]
		MUL YA                      ;__ smpppoint_H *=15                    #
		BBC4 BRR_TEMP_FLAGS, +      ;                                       #
			MOV BRR_SMPPT_H, Y      ;   Invert negative                     #
			EOR A, #$FF             ;                                       #
			EOR BRR_SMPPT_H, #$FF   ;__                                     #
			MOV Y, BRR_SMPPT_H      ;                                       #
		+:                          ;   Python code:                        #
		ADDW YA, BRR_CSMPT_L        ;   smppoint_H<<8 += currentsmppoint    #
		MOVW BRR_SMPPT_L, YA        ;__                                     #__
; Inversions here might not be needed, but that's for another time
		CLR4 BRR_TEMP_FLAGS         ;                                       #
		MOV A, BRR_BUFF1_PTR_L+X    ;                                       #
		MOV BRR_CSMPT_L, A          ;                                       #
		MOV A, BRR_BUFF1_PTR_H+X    ;   currentsmppoint = BRRBuffer[i]      #
		MOV BRR_CSMPT_H, A          ;                                       #
		MOVW YA, BRR_CSMPT_L        ;   Python code:                        #   OG Python code:
		SUBW YA, BRR_SMPPT_L        ;   currentsmppoint -= smppoint         #   BRRBuffer[i] -= smppoint
		MOVW BRR_CSMPT_L, YA        ;__                                     #
		MOV (X+), A   				;                                       #
		MOV A, BRR_CSMPT_H          ;   BRRBuffer[i] = currentsmppoint      #
		MOV (X+), A   				;__                                     #
		BBC7 BRR_SMPPT_H, +         ;                                       #
			SET4 BRR_TEMP_FLAGS     ;   Inverting negative numbers          #
			EOR BRR_SMPPT_L, #$FF   ;                                       #
			EOR BRR_SMPPT_H, #$FF   ;__                                     #
	+   CMP X, #$20                 ;   Loop                                #
		BNE .FilterLoop 			;__

		MOVW YA, BRR_SMPPT_L
		MOVW BRR_LSMPT_L, YA
		BBC4 BRR_TEMP_FLAGS, .BRREncoding
		EOR BRR_LSMPT_L, #$FF
		EOR BRR_LSMPT_H, #$FF
		CLR4 BRR_TEMP_FLAGS

	endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1

	.BRREncoding:
		if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
			SET6 BRR_TEMP_FLAGS
			MOV X, #$00
		endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1
		..OuterLoop:
			MOV A, (X+)
			MOV BRR_SMPPT_L, A
			MOV A, (X+)
			BPL +
				EOR BRR_SMPPT_L, #$FF
				EOR A, #$FF
			+:
			MOV BRR_SMPPT_H, A
		..MaximumFilter1:
			MOV A, (X+)
			MOV BRR_CSMPT_L, A
			MOV A, (X+)
			BPL +
				EOR BRR_CSMPT_L, #$FF
				EOR A, #$FF
			+:
			MOV Y, A
			MOV A, BRR_CSMPT_L
			CMPW YA, BRR_SMPPT_L
			BMI +
				MOVW BRR_SMPPT_L, YA
			+:
			MOV A, X
			AND A, #$1F
			BNE ..MaximumFilter1
			if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
				CMP X, #$40
				BEQ +
					MOVW YA, BRR_SMPPT_L
					MOVW BRR_MAXM0_L, YA
					;Set up the routine for maximum in the OG PCM buffer
					JMP  ..OuterLoop
				+:
					MOV X, #$00
					MOVW YA, BRR_SMPPT_L
					CMPW YA, BRR_MAXM0_L
					BPL ..ShiftValuePart1
					CLR6 BRR_TEMP_FLAGS
			else
					MOVW YA, BRR_SMPPT_L
			endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1
					MOVW BRR_MAXM0_L, YA
					MOV X, #$20
		..ShiftValuePart1:
			MOV Y, #12
			MOV A, BRR_MAXM0_H
			BEQ +
			-:
				ASL A
				BCS ..CheckIf8
				DEC Y
				CMP Y, #$04
				BNE -
			+
				MOV Y, #$04
		..ShiftValuePart2:
			MOV A, BRR_MAXM0_L
			-:
				ASL A
				BCS ..CheckIf8
				DEC Y
				BNE -
			JMP .FormHeader
		..CheckIf8:
			CMP Y, #$05
			BEQ +
			CMP Y, #$06
			BNE ..Check8
			; Executed if Y = 6, aka the high bit to check is in the high byte and the low bit is in low byte
			BBS0 BRR_MAXM0_H, .FormHeader
			BBS7 BRR_MAXM0_L, .FormHeader
			JMP ++
			+   MOV A, BRR_MAXM0_L ;Executed if Y = 5, aka both bits to check are in the low byte
			..Check8:   ;Executed if Y = 1..4 or Y = 7..12 - aka the bits to check are in the same byte
			ASL A
			BCS .FormHeader
			ASL A
			BCC ++      ; = BCS FormHeader : JMP ++
	.FormHeader:
			INC Y
		++:
			MOV BRR_MAXM0_L, Y              ;
			MOV A, Y                        ;   Get the shift value
			OR A, #%00100000                ;   Set the loop flag
			CMP BRR_END_PTR_L, BRR_IN0_PTR_L;   Compare the ending low byte
			BNE +                           ;   Set the end flag if it's the last block
			OR A, #%00010000                ;__
		+:
			if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
				MOV BRR_MAXM0_H, BRR_TEMP_FLAGS ;	Set the filter to 1
				AND BRR_MAXM0_H, #%01000000     ;   if appropriate
				OR A, BRR_MAXM0_H               ;__
			endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1
			XCN A                           ;__ Swap the nybbles to make a valid header
			MOV Y, #$00                     ;
			MOV (BRR_OUT_PTR_L)+Y, A        ;   Write the header out
			INCW BRR_OUT_PTR_L              ;__
	.FormData:
		CLR4 BRR_TEMP_FLAGS
		MOV A, (X+)
		MOV BRR_CSMPT_L, A
		MOV A, (X+)
		BPL +
			EOR A, #$FF
			EOR BRR_CSMPT_L, #$FF
			SET4 BRR_TEMP_FLAGS
		+:
		MOV BRR_CSMPT_H, A  ;
		MOV Y, BRR_CSMPT_L  ;
		MOV A, $0C00+Y      ;
		MOV BRR_CSMPT_L, A  ;
		MOV Y, BRR_CSMPT_H  ;
		MOV A, #$E0         ;   7/8 multiplication
		MUL YA              ;
		MOV BRR_CSMPT_H, Y  ;
		CLRC                ;
		ADC A, BRR_CSMPT_L  ;
		MOV BRR_CSMPT_L, A  ;__
		MOV A, BRR_CSMPT_H
		AND A, #$7F
		MOV Y, BRR_MAXM0_L
		CMP Y, #$05
		BMI +
			-:
				LSR A
				ROR BRR_CSMPT_L
				DEC Y
				CMP Y, #$04
				BNE -
		+:
			MOV A, BRR_CSMPT_L
			CMP Y, #$00
			BEQ +
			-:
				LSR A
				DEC Y
				BNE -
		+:
			AND A, #$07
			ADC A, #$00
			CMP A, #$08
			BMI +
			MOV A, #$07
		+   BBC4 BRR_TEMP_FLAGS, +
			EOR A, #$0F
			INC A
			CMP A, #$10
			BMI +
			DEC A
		+   PUSH A
		MOV A, X
		AND A, #$03
		BNE .FormData
		.SecondNybble:
			POP A
			MOV BRR_CSMPT_L, A
			POP A
			XCN A
			OR A, BRR_CSMPT_L
			MOV (BRR_OUT_PTR_L)+Y, A        ;   Write the data out
			INCW BRR_OUT_PTR_L              ;__
			MOV A, X
			AND A, #$1F
			BNE .FormData
	.AfterEncoding:
		CLR7 BRR_TEMP_FLAGS
		CMP BRR_END_PTR_L, BRR_IN0_PTR_L	;   If this is the last block, end
		BEQ .End        	;__
		if !SNESFM_CFG_SAMPLE_USE_FILTER1 >= 1
			BBS7 BRR_FLAGS, ++
			+   CMP X, #$20                     ;
				BNE +                           ;
				MOV A, $1E                      ;   If we just used filter mode 1,
				PUSH A                          ;   currentsmppoint = BRRBuffer[last]
				MOV A, $1F                      ;
				PUSH A                          ;__
			++  JMP .SetupCopy
			+:                                  ;   If we just used filter mode 0,
				MOV BRR_LSMPT_L, $3E            ;   smppoint = BRRBuffer[last]
				MOV BRR_LSMPT_H, $3F            ;__
				MOV A, #$00                     ;
				PUSH A                          ;   currentsmppoint = 0
				PUSH A                          ;__
				JMP .SetupCopy
		else
			JMP .SetupCopy
		endif   ; !SNESFM_CFG_SAMPLE_USE_FILTER1
	.End:
	RET

endif   ; !SNESFM_CFG_SAMPLE_GENERATE

if !SNESFM_CFG_PITCHTABLE_GEN >= 1
GeneratePitchTable:
	.Documentation:
		; Inputs:
		; YA = base pitch value of C7
	.Defines:
		!GenPitch_Ratio_Lo	= $E8
		!GenPitch_Ratio_Hi	= $E9

		!L001_CounterA		= $EA

		if !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD == 0
			!L001_NewPitch_Lo = $EC
			!L001_NewPitch_Hi = $ED
		else
			!L001_NewPitch_Lo	= $EB
			!L001_NewPitch_Md	= $EC
			!L001_NewPitch_Hi	= $ED
		endif

		!L001_PrevPitch_Lo	= $EE
		!L001_PrevPitch_Hi	= $EF

	.Start:

		MOVW !L001_PrevPitch_Lo, YA
		MOV PitchTableLo+96-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT, A
		MOV PitchTableHi+96-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT, Y

		MOV !L001_CounterA, X

		; TODO: Dynamic pitch counts implement here

		MOV X, #$00

	if !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD == 0
	; old method, 123 cycles

	.SemitoneUpLoop:
		MOV !L001_CounterA, X

		MOV Y, !L001_PrevPitch_Lo		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO	;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Hi						;
		endif												;__
		MUL YA                          ;
		MOV !L001_NewPitch_Lo, A		;	Multiply low byte
		MOV !L001_NewPitch_Hi, Y		;__

		MOV !L001_PrevPitch_Lo, #$00 	;
		MOV Y, !L001_PrevPitch_Hi		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO	;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Hi						;
		endif												;__
		MUL YA                          ;__	Multiply high byte
		ADDW YA, !L001_NewPitch_Hi   	; The next byte is 0, so it adds only the high byte as the mid byte

		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV X, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO		;
		else												;	Get divisor
			MOV X, !GenPitch_Ratio_Lo						;
		endif												;__
		DIV YA, X                       ;   YA very conveniently stores the high and mid bytes
		MOV !L001_NewPitch_Hi, A     	;__	Divide mid and high bytes

		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV X, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO		;
		else												;	Get divisor
			MOV X, !GenPitch_Ratio_Lo						;
		endif												;__
		MOV A, !L001_NewPitch_Lo     	;   Y very conveniently stores the remainder as the high byte
		DIV YA, X                       ;__	Divide low byte with remainder as high byte
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			CMP Y, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO/2   ;
		else												;	Round the number
			; How the fuck do i implement this?				;
		endif												;
		ADC A, #$00                     					;__

		MOV X, !L001_CounterA        										;
		MOV PitchTableLo+96+1-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT+X, A	;   Store low byte
		MOV !L001_PrevPitch_Lo, A    										;__
		MOV A, !L001_NewPitch_Hi     										;
		MOV PitchTableHi+96+1-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT+X, A  	;   Store high byte
		MOV !L001_PrevPitch_Hi, A    										;__

		INC X
		CMP X, #!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT-1
		BNE .SemitoneUpLoop

	else	; !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD
	; new method, 150-158 cycles

	.SemitoneUpLoop:
		MOV Y, !L001_PrevPitch_Hi		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO	;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Hi						;
		endif												;__
		MUL YA							;	Multiply Hi * Hi
		MOVW !L001_NewPitch_Md, YA		;__

		MOV Y, !L001_PrevPitch_Lo		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO		;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Lo						;
		endif												;__
		MUL YA							;__	Multiply Lo * Lo
		ASL A							;-	Equal to CMP #$80 but 1 less byte
		MOV A, Y						;
		ADC A, #$00						;	Round the lowest byte out
		BCC +							;
			INCW !L001_NewPitch_Md		;
		+ MOV !L001_NewPitch_Lo, A		;__

		MOV Y, !L001_PrevPitch_Lo		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO	;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Hi						;
		endif												;__
		MUL YA							;	Multiply Lo * Hi
		ADDW YA, !L001_NewPitch_Lo		;
		ADC !L001_NewPitch_Hi, #$00		;
		MOVW !L001_NewPitch_Lo, YA		;__

		MOV Y, !L001_PrevPitch_Hi		;
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS == 0	;
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO		;
		else												;	Get multiplier
			MOV A, !GenPitch_Ratio_Lo						;
		endif												;__
		MUL YA							;__	Multiply Hi * Lo
		ADDW YA, !L001_NewPitch_Lo		;	Add final Mid&Lo bytes
		MOV !L001_NewPitch_Md, Y	 	;__
		ASL A							;-	Equal to CMP #$80 but 1 byte less
		BCC +							;	Round low byte
			INCW !L001_NewPitch_Md		;__
		+

		ASL !L001_NewPitch_Md			;__	Round mid byte (CMP #$80 but 1 byte and 1 cycle less)
		ADC !L001_PrevPitch_Lo, !L001_NewPitch_Md
		ADC !L001_PrevPitch_Hi, !L001_NewPitch_Hi

		MOV A, !L001_PrevPitch_Lo											;	Store the low pitch byte
		MOV PitchTableLo+96+1-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT+X, A	;__
		MOV A, !L001_PrevPitch_Hi											;	Store the high pitch byte
		MOV PitchTableHi+96+1-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT+X, A	;__

		INC X
		CMP X, #!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT-1
		BNE .SemitoneUpLoop

	endif	; !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD

	.BitShiftStart:
		MOV Y, #(96-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT)

	.BitShiftLoop:
		MOV A, PitchTableHi+!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT-1+Y	;	Get high byte
		LSR A															;	Shift it
		MOV X, A														;__	It's now in X
		MOV A, PitchTableLo+!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT-1+Y	;	Get low byte
		ROR A															;__	Shift it
		ADC A, #$00														;__	Round it
		MOV PitchTableLo-1+Y, A											;__	Store it
		MOV A, X														;	Get high back into A
		ADC A, #$00														;	Round it
		MOV PitchTableHi-1+Y, A											;__	Store it
		DBNZ Y, .BitShiftLoop

	.OverflowCorrection:
		MOV Y, #96

		..Loop:
			MOV A, PitchTableHi-1+Y		;
			CMP A, #$40                 ;   If the value isn't overflowing, exit
			BMI .End  ;__

			MOV A, #$3F                 ;
			MOV PitchTableHi-1+Y, A		;   Cap the pitch value
			MOV A, #$FF                 ;
			MOV PitchTableLo-1+Y, A		;__

			DBNZ Y, ..Loop

	.End:
		RET

endif   ; !SNESFM_CFG_PITCHTABLE_GEN

IndexToSamplePointer:   ;TCALL 15
	;   Memory allocation:
	;   Inputs:
	;       Y - Sample index
	;       A - hhhhhhll
	;           h - High bit of page (if at least one is set, it is considered to be set)
	;           ll - Subpage index
	;   Outputs:
	;       YA - Sample pointer
	;   Memory:
	;       $EE-$EF - Temp variable
	;   Stack usage:
	;       2 entries (+ 2 calling the subroutine)
		PUSH A                      ;
		PUSH A                      ;
		MOV A, #$48                 ;   Use main byte of index
		MUL YA                      ;
		MOVW $EE, YA                ;
		POP A                       ;__
		AND A, #$03                 ;
		MOV Y, A                    ;   Set up the BRR sample subpage
		MOV A, IndexToSamplePointer_LookuptableMul18+Y
		MOV Y, #$60                 ;
		ADDW YA, $EE                ;
		MOVW $EE, YA                ;__
		POP A                       ;
		AND A, #$FC                 ;
		BEQ +                       ;   Apply the high bit
		CLRC                        ;
		ADC $EF, #$48               ;__
	+:                              ;
		MOVW YA, $EE                ;   Return with pointer in YA
	RET                             ;__
	.LookuptableMul18:
		db $00, $12, $24, $36

if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
	print pc
	print "If the low byte >= FD, uncomment the line following this"
	; fill $03

	WriteToChannel: ; TCALL 14
	.RealChannel:
	MOV $F3, A
	RET
	.VirtualChannel:
	MOV Y, $F2
	MOV $400+Y, A
	MOV Y, #$00
	RET
endif

END_OF_CODE: ; Label to determine how much space i have left

print "End of code:"
print pc

assert pc() < $6000
endspcblock

Includes:
	spcblock $0C00 nspc
		LookupTables:
		incbin "multTables.bin"
	endspcblock
	if not(!SNESFM_CFG_PITCHTABLE_GEN)
		spcblock $0E00 nspc
			PitchTableLo:
			incbin "pitchLo.bin"
			PitchTableHi:
			incbin "pitchHi.bin"
	else
		spcblock $0EC0 nspc
	endif
		db $03, $00, $00, $00, $00, $00, $00, $00, $00 ;Dummy empty sample
		endspcblock
	spcblock $0F00 nspc
		SineTable:
		incbin "quartersinetable.bin"
	if !SNESFM_CFG_PITCHBEND_ANY
		Log2Generate:
			MOV X, #$00
			MOV A, #(256-115)
			MOV Y, #$00
			.LoopPart1:
				PUSH A
				MOV A, LogTableTable+X
				INC X
				MOV !TEMP_VALUE, A
				POP A
			.LoopPart2:
				CMP Y, !TEMP_VALUE
				BEQ +
					MOV LogTable+Y, A
					INC A
					INC Y
					BNE .LoopPart2
			MOV Y, #$80
			.InvertLoop:
				MOV A, LogTable-1+Y
				EOR A, #$FF
				INC A
				MOV LogTable-1+Y, A
				DBNZ Y, .InvertLoop
			RET

			+:
				MOV LogTable+Y, A
				INC Y
				BRA .LoopPart1

	LogTableTable:
		db 4, 12, 20, 29, 37, 46, 56, 65, 76, 86, 97, 109, 121, 134, 149, 164, 182, 203, 229
	LogTable = $0900

	endspcblock

	endif

	spcblock $FFC0 nspc   ;For TCALLs
		dw IndexToSamplePointer
		if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
			dw WriteToChannel
		endif
		dw UpdatePitch

	InstrumentPtrLo = $0A00
	InstrumentPtrHi = $0B00

	endspcblock execute Init

namespace off