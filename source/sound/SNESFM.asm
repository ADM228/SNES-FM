asar 1.90

norom
org 0

arch spc700

dpbase $0000
optimize dp always

namespace nested on
namespace SPC

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
		; 1. Driver compilation options
		; 2. General sample generation options
		; 3. Phase modulation options
		; 4. Pulse generation options
		; 5. Pitch table generation options
		; 6. Other generation options
		; 7. Song playback options
		;__

	!SNESFM_CFG_EXTERNAL ?= 0

	if !SNESFM_CFG_EXTERNAL == 0

	; ============= 1. Driver compilation options =============

		; The type of spcblock to compile this with. Look into
		; the asar user manual to find possible options.
		; Default is "nspc".
		!SNESFM_CFG_SPCBLOCK_TYPE = nspc

	;========== 2. General sample generation options ==========

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


	;=============== 3. Phase modulation options ==============

		; Dictates whether to generate phase modulated
		; instruments - just like on Yamaha chips. Not to be
		; confused with SNES hardware pitch modulation.

		; Enables phase modulation with long samples.
		!SNESFM_CFG_PHASEMOD_LONG = 1

		; Enables phase modulation with short samples.
		!SNESFM_CFG_PHASEMOD_SHORT = 1

	;=============== 4. Pulse generation options ==============

		; Dictates whether to generate pulse wave samples.

		; Enables generation of long pulse wave samples.
		!SNESFM_CFG_PULSEGEN_LONG = 1

		; Enables generation of short pulse wave samples.
		!SNESFM_CFG_PULSEGEN_SHORT = 1

	;============ 5. Pitch table generation options ===========

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

	;=============== 6. Other generation options ==============

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

	;================ 7. Song playback options ================

		!SNESFM_CFG_DYNAMIC_TIMER_SPEED = 0

		!SNESFM_CFG_HARDWARE_NOISE_SUPPORT	= 1

		!SNESFM_CFG_FINE_PITCH				= 1
		!SNESFM_CFG_INSTRUMENT_PITCHBEND 	= 1

		!SNESFM_CFG_PITCH_SLIDE 			= 1

		!SNESFM_CFG_VIRTUAL_CHANNELS = 1

	endif
Documentation:
	;   ==== Code/data distribution table: ====
		;   Page		Purpose
		;   $00			$20 - $3F: Temporary storage of flags, counters and pointers for note stuff
		;               $40 - $4F: Communicating with S-CPU stuff
		;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
		;   $01 _ _ _ _ Stack
		;   $02-$05 _ _ Sample Directory
		;				During instrument generation:
		;   $06 _ _ _ _ 7/8 multiplication lookup table	- generated on the fly
		;   $07 _ _ _ _ 15/16 multiplication lookup table - generated on the fly
		;   $06-$07 _ _ During playback - permanent storage of flags, counters and pointers for note stuff for "real" channels
		;   $08-$09 _ _ Same but for virtual channels
		;	$0A _ _ _ _ Global settings
		;   $0B _ _ _ _ Log table for pitchbends
		;   $0C _ _ _ _ Low bytes of instrument data pointers
		;   $0D _ _ _ _ High bytes of instrument data pointers
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

InternalConfig:

	!SNESFM_CFG_SPCBLOCK_TYPE ?= nspc

	macro cfgClamp(def)
		!SNESFM_CFG_<def> #= clamp(!SNESFM_CFG_<def>, 0, 1)
	endmacro

	macro cfgClampMax(def, max)
		!SNESFM_CFG_<def> #= clamp(!SNESFM_CFG_<def>, 0, <max>)
	endmacro

	macro tblCfg(cfg, ptr)	; For filling when a define is false
		if !SNESFM_CFG_<cfg> : dw <ptr> : else : dw !SNESFM_CURRENT_TBL_FILL : endif
	endmacro

	macro fillW(count)		; Just fill some space
		for i = 0..<count> : dw !SNESFM_CURRENT_TBL_FILL : endfor
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
	if !SNESFM_CFG_PITCHTABLE_GEN
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

	endif

	!SNESFM_CFG_INSGEN_REPEAT_AMOUNT ?= 0
	!SNESFM_CFG_INSGEN_ARITHMETIC_AMOUNT ?= 0
	%cfgClampMax(INSGEN_REPEAT_AMOUNT, 4)
	%cfgClampMax(INSGEN_ARITHMETIC_AMOUNT, 4)

	!SNESFM_CFG_HARDWARE_NOISE_SUPPORT ?= 0
	%cfgClamp(HARDWARE_NOISE_SUPPORT)

	!SNESFM_CFG_PITCH_SLIDE ?= 0
	%cfgClamp(PITCH_SLIDE)

	!SNESFM_CFG_FINE_PITCH ?= 0
	!SNESFM_CFG_INSTRUMENT_PITCHBEND ?= 0
	!SNESFM_CFG_PITCH_EFFECTS = !SNESFM_CFG_PITCH_SLIDE 	; More effects later
	%cfgClamp(FINE_PITCH) : %cfgClamp(INSTRUMENT_PITCHBEND) : %cfgClamp(PITCH_EFFECTS)

	!SNESFM_CFG_PITCHBEND_ANY = (!SNESFM_CFG_INSTRUMENT_PITCHBEND)|(!SNESFM_CFG_PITCH_EFFECTS)|(!SNESFM_CFG_FINE_PITCH)
	!SNESFM_CFG_PITCHBEND_ALL = (!SNESFM_CFG_INSTRUMENT_PITCHBEND)&(!SNESFM_CFG_PITCH_EFFECTS)&(!SNESFM_CFG_FINE_PITCH)

	!SNESFM_CFG_CONTINOUS_EFFECTS = !SNESFM_CFG_PITCH_SLIDE	; More effects later
	!SNESFM_CFG_CONTINOUS_PITCH_EFFECTS = !SNESFM_CFG_PITCH_SLIDE	; More effects later
	%cfgClamp(CONTINOUS_EFFECTS) : %cfgClamp(CONTINOUS_PITCH_EFFECTS)

	!SNESFM_CFG_VIRTUAL_CHANNELS ?= 0

	if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
		print "Virtual channels enabled"
		macro realChannelWrite()
			TCALL 13
		endmacro
	else
		print "Virtual channels disabled"
		macro realChannelWrite()
			MOV $F3, A
		endmacro
	endif

spcblock $5000 !SNESFM_CFG_SPCBLOCK_TYPE

InternalDefines:

	;Song data variables for more readability when assembling manually
		;Instrument data
			;   Instrument types
				!SAMPLE_USE_ADDRESS = %00001000
				!ENVELOPE_TYPE_ADSR = %00000010
	;Pointers to channel 1's variables (permanent storage during song playback)

		CH1_SONG_POINTER_L = $0600
		CH1_SONG_POINTER_H = $0601
		CH1_REF0_POINTER_L = $0602
		CH1_REF0_POINTER_H = $0603
		CH1_INSTRUMENT_INDEX = $0604
		CH1_INSTRUMENT_TYPE = $0605
		CH1_SAMPLE_POINTER_L = $0606
		CH1_SAMPLE_POINTER_H = $0607

		CH1_SONG_COUNTER = $0640
		CH1_REF0_COUNTER = $0641
		CH1_PITCHBEND_L = $0642
		CH1_PITCHBEND_H = $0643
		CH1_ARPEGGIO = $0644
		CH1_NOTE = $0645

		CH1_FLAGS = $0647

		CH1_MACRO_COUNTERS = $0680
		CH1_INSTRUMENT_TYPE_COUNTER = $0680
		CH1_ENVELOPE_COUNTER = $0681
		CH1_SAMPLE_POINTER_COUNTER = $0682
		CH1_ARPEGGIO_COUNTER = $0683
		CH1_PITCHBEND_COUNTER = $0684
		CH1_COUNTERS_HALT = $0687		;000paset

		CH1_MACRO_POINTERS = $06C0
		CH1_INSTRUMENT_TYPE_POINTER = $06C0
		CH1_ENVELOPE_POINTER = $06C1
		CH1_SAMPLE_POINTER_POINTER = $06C2
		CH1_ARPEGGIO_POINTER = $06C3
		CH1_PITCHBEND_POINTER = $06C4
		CH1_COUNTERS_DIRECTION = $06C7	;000paset

		CH1_INSTRUMENT_SECTION_HIGHBITS = $0685

		CH1_PITCH_EFFECT_ID = $0700
		CH1_PITCH_EFFECT_CNT = $0701
		CH1_PITCH_EFFECT_ACC_L = $0702
		CH1_PITCH_EFFECT_ACC_H = $0703
		CH1_PITCH_EFFECT_VAL_L = $0704
		CH1_PITCH_EFFECT_VAL_H = $0705

		CH1_FINE_PITCH	= $0706

		GBL_TIMER_SPEED = $0A00

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

		; Global register buffers
		!KOFF_BUF		= $50
		!KON_BUF		= $51
		!NCLK_BUF		= $52
		!NON_BUF		= $53
		!EON_BUF		= $54
		!ESA_BUF		= $55

		; Register buffer update flags
		; Flags are set per channel
		!UPD_VOL		= $58
		!UPD_PITCH		= $59
		!UPD_SRC		= $5A
		!UPD_SRC_MODE	= $5B
		!UPD_ENV		= $5C

		; Channel register buffers
		CH1_VOLL		= $60
		CH1_VOLR		= $61
		CH1_PITCHLO		= $62
		CH1_PITCHHI		= $63
		CH1_SRCN		= $64
		CH1_ADSR1		= $65
		CH1_ADSR2		= $66	;	Intentionally the same address
		CH1_GAIN		= $66	;__

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
		SMP_DIR_P0	= $0200
		SMP_DIR_P1	= $0300
		SMP_DIR_P2	= $0400
		SMP_DIR_P3	= $0500

		PERM_CH_STORAGE_P0 = $0600
		PERM_CH_STORAGE_P1 = $0700

		TBL_7over8 		= $0600
		TBL_15over16	= $0700

		GBL_STORAGE	= $0A00

		InstrumentPtrLo = $0C00
		InstrumentPtrHi = $0D00

		PitchTableLo = $0E00
		PitchTableHi = $0E60

		SineTable = $0F00

incsrc "SMP_DSP_constants.asm"

;

Init:       ;init routine by KungFuFurby
	;------------Clear DSP Registers------------
	;DSP register initialization will now take place.
	.clear:
		clrp                    ;Zero direct page flag.
		mov A, #KOFF            ;Stop all channels first.
		mov Y, #$FF             ;KOFF will be cleared
		movw DSPADDR, YA        ;later on, though.
		inc Y
		mov A, #$7F
		..loop:
			movw DSPADDR, YA    ;Clear DSP register.
			mov Y, #$00
			cmp A, #FLG+1
			bne ..not_flg
			mov Y, #%01100000

		..not_flg:
			cmp A, #ESA+1
			bne ..not_esa
		;For ESA, set to $80.
		;(Max EDL is $0F, which consumes $7800 bytes.
		;ESA is set to $80 in case echo writes are accidentally on.)
			mov Y, #$80

		..not_esa:
			dec A
			bpl ..loop

	.set_vol:
		MOV A, #EVOLR
		MOV Y, #$7F
		SETC
		..loop:
			MOVW DSPADDR, YA
			; SETC      ; not needed as it's set in the beginning, and when it clears we need to exit
			SBC A, #$10
			BCS ..loop

	INC A           ; Set A to 0

	MOVW CPUIO0, YA	;   Clear output ports
	MOVW CPUIO1, YA	;__
	MOV MESSAGE_CNT_TH1, A
	MOV CONTROL, #$30	;__ Clear input ports
	MOV DSPADDR, #DIR				;   Set sample directory
	MOV DSPDATA, #(SMP_DIR_P0>>8)	;__
	MOV CONTROL, #$00	;__
	MOV $FA, #$43	;   Set Timer 0 to 8.375 ms  (~120 Hz)
	;MOV $FA, #$50	;   Set Timer 0 to 10 ms     (100 Hz)
	;MOV $FA, #$64	;   Set Timer 0 to 12.5 ms   (80 Hz)
	;MOV $FA, #$85	;   Set Timer 0 to 16.625 ms (~60 Hz)
	;MOV $FA, #$A0	;   Set Timer 0 to 20 ms     (50 Hz)
	;MOV $FA, #$FF	;   Set Timer 0 to 31.875 ms (~31 Hz)
	MOV $F1, #$07	;__

	if !SNESFM_CFG_PITCHTABLE_GEN
		if !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS
			MOV A, #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO
			MOV Y, #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO
			MOVW !GenPitch_Ratio_Lo, YA
		endif
		MOV A, #$7D
		MOV Y, #$21
		CALL GeneratePitchTable_Start
	endif

	if !SNESFM_CFG_PITCHBEND_ANY
		CALL Log2Generate
	endif

SineSetup:

	; Setting up the sine table

	MOV X, #$02     ;__ X contains the source index,
	MOV Y, #$3E     ;__ Y contains the destination index
	.loopCopy:
		MOV A, SineTable+X
		INC X
		MOV SineTable+$40+Y, A
		MOV A, SineTable+X
		INC X
		MOV SineTable+$41+Y, A
		DEC Y
		DBNZ Y, .loopCopy

	MOV Y, #$3F

	.loopInvert:
		MOV A, SineTable+Y
		EOR A, #$FF
		MOV SineTable+$80+Y, A
		MOV A, SineTable+$40+Y
		EOR A, #$FF
		MOV SineTable+$C0+Y, A
		DBNZ Y, .loopInvert

RAMClear:
	MOV Y, #$00
	MOV A, Y
	-:
		MOV PERM_CH_STORAGE_P0+Y, A
		MOV PERM_CH_STORAGE_P1+Y, A
		MOV SMP_DIR_P0+Y, A
		DBNZ Y, -


SetVolume:
	MOV X, #$7F
	MOV Y, #$08
	MOV A, #$00
	.loop:
		MOV $F2, A
		MOV $F3, X
		INC $F2
		MOV $F3, X
		CLRC
		ADC A, #$10
		DBNZ Y, .loop

GetInstrumentData:
	MOV MESSAGE_CNT_TH1, #$01
	MOV TDB_OUT_PTR_L, #$00
	MOV TDB_OUT_PTR_H, #$10
	CALL TransferDataBlock

if !SNESFM_CFG_SAMPLE_GENERATE

GenerateMultTables:
	MOV X, #$00			;0, 1	;
	MOV A, X			;2		;	Zero everything out
	MOV !TEMP_VALUE, X	;3, 4	;__

	CALL GMT_loop

	MOV A, #256*15/16			;
	MOV GMT_loop+1+1, A			;
	MOV A, #(TBL_15over16>>8)	;	Set everything for round 2
	MOV GMT_loop+6+2, A			;__
	MOV A, X
	MOV !TEMP_VALUE, X

	CALL GMT_loop

endif

; namespace CompileInstruments
CompileInstruments:
	.Start:
		MOV Y, #$00
		MOV INSDATA_PTR_L, Y
		MOV INSDATA_PTR_H, #$10

		if !SNESFM_CFG_SAMPLE_GENERATE

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

		if !SNESFM_CFG_SAMPLE_GENERATE

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

		if !SNESFM_CFG_INSGEN_REPEAT_AMOUNT
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

		if !SNESFM_CFG_SAMPLE_GENERATE
			JMP (.JumpTable+X)
		else
			JMP (.JumpTable-($1D*2)+X)
		endif


	if !SNESFM_CFG_SAMPLE_GENERATE

	.ArgCountTable:
		fillbyte $00
		db $02, $00, $00, $03
		fill ($1A-1-$03)
		db $83, $00, $00, $00, $00, $00

	endif   ; !SNESFM_CFG_SAMPLE_GENERATE

	.JumpTable:
		!SNESFM_CURRENT_TBL_FILL = .RETJump

		if !SNESFM_CFG_SAMPLE_GENERATE

			dw .CopyResample

			%tblCfg(PHASEMOD_ANY, .PhaseModPart1)
			%tblCfg(PHASEMOD_ANY, .PhaseModPart2)

			%tblCfg(PULSEGEN_ANY, .PulseGen)
			%fillW($1A-3-1)
			dw .BRRGen
			dw .RETJump
			%tblCfg(INSGEN_REPEAT_AMOUNT, .ConserveArgs)
		endif   ; !SNESFM_CFG_SAMPLE_GENERATE
		dw .NewInstrument, .InstrumentRawDataBlock, .End

	if !SNESFM_CFG_SAMPLE_GENERATE

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
		if !SNESFM_CFG_RESAMPLE
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

		if !SNESFM_CFG_RESAMPLE
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

	if !SNESFM_CFG_PHASEMOD_ANY
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
		if !SNESFM_CFG_PHASEMOD_BOTH
			BBS7 INSDATA_OPCODE, +
				CALL PhaseModulation_128
				MOV Y, #$00
				RET
			+   CALL PhaseModulation_32
				MOV Y, #$00
				RET
		elseif !SNESFM_CFG_PHASEMOD_LONG
			CALL PhaseModulation_128
			MOV Y, #$00
			RET
		elseif !SNESFM_CFG_PHASEMOD_SHORT
			CALL PhaseModulation_32
			MOV Y, #$00
			RET
		endif
	endif   ; !SNESFM_CFG_PHASEMOD_ANY

	if !SNESFM_CFG_PULSEGEN_ANY
	.PulseGen:
		MOV X, #OPCODE_ARGUMENT
		CALL .CopyArguments

		if !SNESFM_CFG_PULSEGEN_BOTH
			MOV A, INSDATA_OPCODE
			BMI +
		endif
		if !SNESFM_CFG_PULSEGEN_LONG+!SNESFM_CFG_PULSEGEN_BOTH >= 1
				CALL GeneratePulse_128
				DEC Y   ; Y is always 1
				RET
		endif
		if !SNESFM_CFG_PULSEGEN_BOTH
			+:
		endif
		if !SNESFM_CFG_PULSEGEN_SHORT+!SNESFM_CFG_PULSEGEN_BOTH >= 1
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
	MOV !NON_BUF, X
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
		if !SNESFM_CFG_CONTINOUS_PITCH_EFFECTS
			MOV CH1_PITCH_EFFECT_ID+X, A
		endif
		if !SNESFM_CFG_PITCHBEND_ANY
			if !SNESFM_CFG_PITCH_EFFECTS		;
				MOV CH1_PITCH_EFFECT_VAL_H+X, A	;
				MOV CH1_PITCH_EFFECT_VAL_L+X, A	;
			endif								;
			if !SNESFM_CFG_INSTRUMENT_PITCHBEND	;
				MOV CH1_PITCHBEND_H+X, A		;	Zero out pitch FX
				MOV CH1_PITCHBEND_L+X, A		;
			endif								;
			if !SNESFM_CFG_FINE_PITCH			;
				MOV CH1_FINE_PITCH+X, A			;
			endif								;__
		endif
		INC A								;	Bit 0 to mark as sample instrument
		MOV CH1_INSTRUMENT_TYPE+X, A		;__
		INC A								;   Bit 1 set to stop from
		MOV CH1_FLAGS+X, A                  ;__ parsing nonexistent instrument data
		MOV A, #$C0							;
		MOV SMP_DIR_P0+4+X, A				;
		MOV SMP_DIR_P0+0+X, A				;   Reset sample start pointers to blank sample
		MOV A, #$0E                         ;
		MOV SMP_DIR_P0+5+X, A				;
		MOV SMP_DIR_P0+1+X, A				;
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

	MOV DSPADDR, #KOFF	;	Key Off Nothing
	MOV DSPDATA, X		;__
	MOV DSPADDR, #NON	;	Disable noise on all channels
	MOV DSPDATA, X		;__
	MOV DSPADDR, #FLG	;	Unmute, disable echo
	MOV DSPDATA, #$20	;__

	MOV A, T0OUT		;__	Reset timer
	JMP MainLoop_WaitLoop


ParseSongData:	; WHEN ARE THE NAMESPACES COMING BACK
	.POPX_ReadByte:
		MOV X, !BACKUP_X
	.Start:
	.ReadByte:
		MOV Y, #$00
	.Y00ReadByte:           ; Use if Y and X not modified
		MOV A, (CHTEMP_SONG_POINTER_L)+Y

	; If the opcode ≥ $80, then it's either an instrument change or a waiting opcode
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
			OR !KOFF_BUF, !CHANNEL_BITMASK	;__	Key off the needed channel
			OR !KON_BUF, !CHANNEL_BITMASK	;__	Key on the needed channel
			if !SNESFM_CFG_PITCH_EFFECTS
				SET0 !PLAYBACK_FLAGS
				MOV A, #$00						;
				MOV CH1_PITCH_EFFECT_VAL_L+X, A	;	Reset pitch effect value
				MOV A, Y	; Y is 0			;	TODO: configurability???
				MOV CH1_PITCH_EFFECT_VAL_H+X, A	;__
			endif
		BBS5 CHTEMP_FLAGS, .ReadByte
			CALL .CallInstrumentParser
			MOV A, CH1_NOTE+X
		.PitchUpdate:
			CLR4 CHTEMP_FLAGS
		-	JMP .ReadByte



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
		OR !KOFF_BUF, !CHANNEL_BITMASK	;__	Key off the needed channel
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
		OR !UPD_VOL, !CHANNEL_BITMASK
		MOV X, !BACKUP_X
		BBS0 $E0, ..R			;__   Store to right volume register if bit 0 set
			MOV CH1_VOLL+X, A
			JMP .ReadByte
		..R:
			MOV CH1_VOLR+X, A
			JMP .ReadByte

	.SetVolumeBoth:
		MOV A, (CHTEMP_SONG_POINTER_L)+Y
		INCW CHTEMP_SONG_POINTER_L
		MOV X, !BACKUP_X
		MOV CH1_VOLL+X, A
		MOV CH1_VOLR+X, A
		OR !UPD_VOL, !CHANNEL_BITMASK
		JMP .ReadByte

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

    if !SNESFM_CFG_FINE_PITCH
    .FinePitch:
		MOV X, !BACKUP_X					;
		MOV A, (CHTEMP_SONG_POINTER_L)+Y	;
		CMP A, CH1_FINE_PITCH+X				;
        BEQ +								;	Update low byte of pitch if needed
            MOV CH1_FINE_PITCH+X, A			;
            SET0 !PLAYBACK_FLAGS			;__
		+ INCW CHTEMP_SONG_POINTER_L
		JMP .Y00ReadByte
    endif

	if !SNESFM_CFG_PITCH_SLIDE
	.PitchSlide:
		; MOV A, X						;- Unnecessary as MOV X, A was right before JMP
		MOV X, !BACKUP_X				;	Store pitch effect ID
		MOV CH1_PITCH_EFFECT_ID+X, A	;__

		MOV A, (CHTEMP_SONG_POINTER_L)+Y	;
		MOV CH1_PITCH_EFFECT_ACC_L+X, A		;	Update low byte of pitch if needed
		INCW CHTEMP_SONG_POINTER_L			;__
		MOV A, (CHTEMP_SONG_POINTER_L)+Y	;
		MOV CH1_PITCH_EFFECT_ACC_H+X, A		;	Update high byte of pitch if needed
		INCW CHTEMP_SONG_POINTER_L			;__
        JMP .Y00ReadByte
	endif

	.OpcodeTable:
		!SNESFM_CURRENT_TBL_FILL = .POPX_ReadByte

		dw .NoAttack		; $68, Disable attack
		dw .POPX_ReadByte	; $69, Arp table
        %tblCfg(PITCH_EFFECTS, .POPX_ReadByte)	; $6A, Pitch table
		%tblCfg(FINE_PITCH, .FinePitch)			; $6B, Fine pitch
		%tblCfg(PITCH_SLIDE, .PitchSlide)		; $6C, Pitch slide
		%fillW(3)

		dw .SetVolumeL_or_R	; $70, Set left volume
		dw .SetVolumeL_or_R	; $71, Set right volume
		dw .SetVolumeBoth	; $72, Set both volumes
		dw .POPX_ReadByte	; $73, Left volume slide
		dw .POPX_ReadByte	; $74, Right volume slide
		dw .POPX_ReadByte	; $75, Both volume slide
		%fillW(6)
		dw .Keyoff			; $7C, Keyoff
		dw .ReferenceRepeat	; $7D, Repeat last reference
		dw .ReferenceSet	; $7E, Set reference
		dw .Jump			; $7F, Loop/Jump

MainLoop:
	.WaitLoop:
		MOV !TIMER_VALUE, T0OUT
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


		; Select the channel routine

		if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
			MOV A, CHTEMP_FLAGS
			AND A, #$04
			BEQ +
				MOV A, #(WriteToChannel_VirtualChannel&$FF)
				JMP ++
			+:
				MOV A, #(WriteToChannel&$FF)
			++:
			MOV $FFC0+4, A
		endif

		if !SNESFM_CFG_CONTINOUS_EFFECTS > 0
			CALL UpdateEffects
		endif

		SETC
		MOV A, CH1_SONG_COUNTER+X
		SBC A, !TIMER_VALUE
		MOV CH1_SONG_COUNTER+X, A
		BPL +
		CALL ParseSongData_Start
	+:
		CALL ParseInstrumentData_Start

	TCALL 14

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

		CALL TransferRegisterData

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
			PUSH X
			CALL .UpdateMacro
			POP X
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
					PUSH X
					CALL .UpdateMacro
					POP X
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
		MOV Y, #$00
		MOV A, (!TEMP_POINTER0_L)+Y             ;
		MOV !TEMP_POINTER1_L, A                 ;
		INCW !TEMP_POINTER0_L                   ;   Get base
		MOV A, (!TEMP_POINTER0_L)+Y             ;   macro pointer
		MOV !TEMP_POINTER1_H, A                 ;
		INCW !TEMP_POINTER0_L                   ;__

		; TODO: remove doubling, just INC by 2 within 256 bytes

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
		MOV X, !BACKUP_X
		if !SNESFM_CFG_HARDWARE_NOISE_SUPPORT
			MOV0 C, CHTEMP_INSTRUMENT_TYPE		;__ Get the old value
			MOV A, (!TEMP_POINTER1_L)+Y			;   Get the current value
			MOV CHTEMP_INSTRUMENT_TYPE, A		;__
			EOR0 C, CHTEMP_INSTRUMENT_TYPE		;   Don't update if nothing changed
			BCC ..Envelope						;__
				SET0 !PLAYBACK_FLAGS			;	Update the noise enable flag
				OR !NON_BUF, !CHANNEL_BITMASK	;__
		else
			MOV A, (!TEMP_POINTER1_L)+Y         ;   Get the current value
			MOV CHTEMP_INSTRUMENT_TYPE, A      	;__
		endif
		..Envelope:
		AND !CHANNEL_REGISTER_INDEX, #$70	;
		OR !CHANNEL_REGISTER_INDEX, #$05	;
		MOV DSPADDR, !CHANNEL_REGISTER_INDEX;
		MOV1 C, DSPDATA						;	If the envelope mode isn't changed,
		EOR1 C, CHTEMP_INSTRUMENT_TYPE		;	don't clear the envelope
		BCC .R								;__
		OR !UPD_ENV, !CHANNEL_BITMASK
		MOV A, #$00
		BBC1 CHTEMP_INSTRUMENT_TYPE, +		;
			MOV CH1_ADSR2+X, A				;	If ADSR is used,
			MOV A, #$80						;	Clear out the ADSR envelope
			MOV CH1_ADSR1+X, A				;__
		#.R	RET
		+:									;
			MOV CH1_ADSR1+X, A				;
			MOV A, !CHANNEL_REGISTER_INDEX	;
			AND A, #$70						;
			OR A, #$08						;	If GAIN is used,
			MOV DSPADDR, A					;	set the GAIN envelope to the current value
			MOV A, DSPDATA					;
			MOV CH1_GAIN+X, A				;__
		RET

	.UpdateEnvelope:
		MOV X, !BACKUP_X
		OR !UPD_ENV, !CHANNEL_BITMASK
		BBC1 CHTEMP_INSTRUMENT_TYPE, +		;
			MOV A, (!TEMP_POINTER1_L)+Y		;
			INC Y							;	Update Attack, Decay
			OR A, #$80						;
			MOV CH1_ADSR1+X, A				;__
			MOV A, (!TEMP_POINTER1_L)+Y		;	Update Sustain, Release
			MOV CH1_ADSR2+X, A				;__
			RET
		+:
			MOV A, (!TEMP_POINTER1_L)+Y		;	Update GAIN envelope
			MOV CH1_GAIN+X, A				;__
			RET
	.UpdateSamplePointer:
		MOV X, !BACKUP_X					    ;__
		BBS3 CHTEMP_INSTRUMENT_TYPE, +			;__ If sample index is used,
			MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV Y, A                            ;
			MOV A, CHTEMP_INSTRUMENT_TYPE		;
			AND A, #$30                         ;
			XCN A                               ;
			ASL	A								;  Get pointer from sample index
			MOV6 C, CHTEMP_INSTRUMENT_TYPE		;
			ROR	A								;
			TCALL 15                            ;
			MOVW !TEMP_POINTER2_L, YA	        ;
			MOV CH1_SAMPLE_POINTER_L+X, A       ;
			MOV A, Y                            ;
			MOV CH1_SAMPLE_POINTER_H+X, A       ;
			JMP .updatePointer                  ;__
		+   MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV !TEMP_POINTER2_L, A				;   If no, just blatantly
			INC Y								;   Load sample pointer into memory
			MOV A, (!TEMP_POINTER1_L)+Y         ;
			MOV !TEMP_POINTER2_H, A				;__
	.updatePointer:
		OR !UPD_SRC, !CHANNEL_BITMASK			;
		BBC7 CHTEMP_FLAGS, ..sample0			;__ If the currently playing sample is 1, update sample 0
			MOV A, !TEMP_POINTER2_H				;   Check if the high byte is the same
			CMP A, SMP_DIR_P0+7+X				;__
			BNE ..sample1To0					;
			..storeSampleNoChange:
			OR !UPD_SRC_MODE, !CHANNEL_BITMASK	;__
			MOV A, !TEMP_POINTER2_L				;	If yes, update only the low byte of the sample pointer
			MOV CH1_SRCN+X, A					;__
			RET

		..sample1To0:
			MOVW YA, !TEMP_POINTER2_L			;
			MOV SMP_DIR_P0+2+X, A				;   If high byte is different,
			MOV A, Y							;   Update sample loop pointer
			MOV SMP_DIR_P0+3+X, A				;__
			; Reset to blank sample was here, if needed bring back here
			MOV A, X							;
			..storeSampleWithChange:			;
			LSR A								;	Write new Source Number to DSP
			LSR A								;
			MOV CH1_SRCN+X, A					;__
			EOR CHTEMP_FLAGS, #$80				;__ Next time update the other sample
			RET

		..sample0:
			MOV A, !TEMP_POINTER2_H				;   Check if the high byte is the same
			CMP A, SMP_DIR_P0+3+X				;__
			BEQ ..storeSampleNoChange			;__
		..sample0To1:							;
			MOVW YA, !TEMP_POINTER2_L			;
			MOV SMP_DIR_P0+6+X, A				;   If high byte is different,
			MOV A, Y							;   Update sample loop pointer
			MOV SMP_DIR_P0+7+X, A				;__
			; Reset to blank sample was here, if needed bring back here
			MOV A, X							;
			OR A, #$04							;
			JMP ..storeSampleWithChange			;__

	.UpdateArpeggio:
		MOV X, !BACKUP_X
		MOV A, (!TEMP_POINTER1_L)+Y 			;__ Get arpeggio
		CMP A, CH1_ARPEGGIO+X                   ;
		BEQ +                                   ;   If arpeggio changed, update it
			SET0 !PLAYBACK_FLAGS                ;   and set to update the pitch
			MOV CH1_ARPEGGIO+X, A               ;__
		+
		#RET000: RET

UpdatePitch:
	BBC0 !PLAYBACK_FLAGS, RET000
	CLR0 !PLAYBACK_FLAGS
	MOV A, CH1_NOTE+X                     	;
	CLRC                                    ;   Apply arpeggio
	ADC A, CH1_ARPEGGIO+X                 	;__
	if !SNESFM_CFG_HARDWARE_NOISE_SUPPORT
		BBS0 CHTEMP_INSTRUMENT_TYPE, .TonePitch
		.NoisePitch:
			AND A, #$1F			;	Update noise clock
			MOV !NCLK_BUF, A	;__
			RET
	endif
	.TonePitch:
		; Defines
		!L000_NOTE_VALUE = !TEMP_VALUE2
		!L000_BASE_PITCH_L = !TEMP_POINTER0_L
		!L000_BASE_PITCH_H = !TEMP_POINTER0_H
		!L000_TBL_INDEX = !TEMP_POINTER1_H
		!L000_HIGH_RESULT = !TEMP_POINTER2_L

		if !SNESFM_CFG_PITCHBEND_ANY

			MOV !L000_NOTE_VALUE, A

			if !SNESFM_CFG_PITCHBEND_ALL

				MOV Y, #$00
				MOV A, CH1_FINE_PITCH+X			;
				BPL +							;	Sign extend the fine pitch
					DEC Y						;	Add up the low bytes
				+ CLRC							;
				ADC A, CH1_PITCH_EFFECT_VAL_L+X	;__
				BCC +							;
					INC Y						;	Faster than MOV1 (6/8 vs 10 cycles)
					CLRC						;__
				+ ADC A, CH1_PITCHBEND_L+X		;__	Add the third low byte
				MOV !L000_TBL_INDEX, A			;	Neither of these
				MOV A, Y						;__	affect carry
				ADC A, CH1_PITCH_EFFECT_VAL_H+X	;
				CLRC							;	Add up the high bytes, with overflow
				ADC A, CH1_PITCHBEND_H+X		;__

				CLRC						;	Add up the note
				ADC A, !L000_NOTE_VALUE		;__

				MOV Y, !L000_TBL_INDEX
				BEQ .NoBend

			elseif (\							;
			(!SNESFM_CFG_PITCH_EFFECTS)+\		;	If only 2 components added
			(!SNESFM_CFG_INSTRUMENT_PITCHBEND)+\;
			(!SNESFM_CFG_FINE_PITCH)) == 2		;__

				if (!SNESFM_CFG_PITCH_EFFECTS+!SNESFM_CFG_INSTRUMENT_PITCHBEND) == 2
					!A_LO = CH1_PITCH_EFFECT_VAL_L
					!A_HI = CH1_PITCH_EFFECT_VAL_H
					!B_LO = CH1_PITCHBEND_L
					!B_HI = CH1_PITCHBEND_H
				elseif !SNESFM_CFG_PITCH_EFFECTS		; Fine pitch also enabled
					!A_LO = CH1_FINE_PITCH
					!B_LO = CH1_PITCH_EFFECT_VAL_L
					!B_HI = CH1_PITCH_EFFECT_VAL_H
				elseif !SNESFM_CFG_INSTRUMENT_PITCHBEND	; Fine pitch also enabled
					!A_LO = CH1_FINE_PITCH
					!B_LO = CH1_PITCHBEND_L
					!B_HI = CH1_PITCHBEND_H
				endif

				if defined("A_HI")
					MOV A, !A_HI+X		;
					MOV Y, A			;	Get first word
					MOV	A, !A_LO+X		;__
				else
					MOV Y, #$00			;__	Start the high byte
					MOV A, !A_LO+X		;	Get first word
					BPL +				;	Since it's just a byte,
						DEC Y			;	sign extend
					+					;__
				endif

				CLRC					;	Add the second low byte
				ADC A, !B_LO+X			;__
				MOV !L000_TBL_INDEX, A	;__	Doesn't affect carry
				MOV A, Y				;	Add the second high byte
				ADC A, !B_HI+X			;__
				CLRC					;	Add up the note immediately
				ADC A, !L000_NOTE_VALUE	;__

				MOV Y, !L000_TBL_INDEX
				BEQ .NoBend

				undef A_LO : undef B_LO : undef B_HI
				if defined("A_HI") : undef A_HI : endif

			else	; only 1 component

				if !SNESFM_CFG_INSTRUMENT_PITCHBEND

					MOV A, CH1_PITCHBEND_L+X			;
					MOV Y, A							;	Get instrument pitchbend
					MOV A, CH1_PITCHBEND_H+X			;__

					CLRC								;	Add it to the note
					ADC A, !L000_NOTE_VALUE				;__

				elseif !SNESFM_CFG_PITCH_EFFECTS

					MOV A, CH1_PITCH_EFFECT_VAL_L+X		;
					MOV Y, A							;	Get effect pitchbend
					MOV A, CH1_PITCH_EFFECT_VAL_H+X		;__

					CLRC								;	Add it to the note
					ADC A, !L000_NOTE_VALUE				;__

				elseif !SNESFM_CFG_FINE_PITCH

					MOV A, CH1_FINE_PITCH+X				;	Get fine pitch
					MOV Y, A							;__
					BPL +						;
						DEC !L000_NOTE_VALUE	;	6 or 4 cycles, the fastest way
					+							;__
					MOV A, !L000_NOTE_VALUE
				endif


				CMP Y, #$00
				BEQ .NoBend

				MOV !L000_TBL_INDEX, Y

			endif	; Amount of pitch components


				; At this point there is definitely multiplication to be done
				CALL .ClampPitch		;
				; MOV A, PitchTableLo+Y <- Done by clampPitch
				MOV !L000_BASE_PITCH_L, A	;	Store the (base) pitch value in TMP0
				MOV A, PitchTableHi+Y		;
				MOV !L000_BASE_PITCH_H, A	;__

				MOV Y, !L000_TBL_INDEX		;__

				MOV A, LogTable+Y			;
				PUSH A						;
				MOV Y, !L000_BASE_PITCH_H	;	Multiply high byte
				MUL YA  					;
				MOVW !L000_HIGH_RESULT, YA	;__
				POP A						;
				MOV Y, !L000_BASE_PITCH_L	;	Multiply low byte
				MUL YA						;__
				ASL	A						;
				MOV A, Y					;	Round the number
				ADC A, #$00					;__

				MOV Y, #$00					;
				ADDW YA, !L000_HIGH_RESULT	;	Get sum of both bytes
				MOV !TEMP_POINTER2_H, Y		;__

				LSR !TEMP_POINTER2_H 		;
				ROR A						;
				LSR !TEMP_POINTER2_H 		;
				ROR A						;
				LSR !TEMP_POINTER2_H		;	Divide by 16
				ROR A						;
				LSR	!TEMP_POINTER2_H		;
				ROR A						;
				MOV Y, !TEMP_POINTER2_H		;__

				; Carry set accordingly for 2's complement addition
				ADDW YA, !L000_BASE_PITCH_L

				MOV CH1_PITCHLO+X, A
				MOV CH1_PITCHHI+X, Y
				OR !UPD_PITCH, !CHANNEL_BITMASK
				RET

			.NoBend:
		endif
			CALL .ClampPitch
			; MOV A, PitchTableLo+Y <- Done by clampPitch
			MOV CH1_PITCHLO+X, A		;__	Update low byte of pitch
			MOV A, PitchTableHi+Y		;	Update high byte of pitch
			MOV CH1_PITCHHI+X, A		;__
			OR !UPD_PITCH, !CHANNEL_BITMASK
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

if !SNESFM_CFG_CONTINOUS_EFFECTS > 0
UpdateEffects:
	if !SNESFM_CFG_CONTINOUS_PITCH_EFFECTS > 0
		MOV A, CH1_PITCH_EFFECT_ID+X
		BEQ .PitchEnd
		MOV X, A
		SET0 !PLAYBACK_FLAGS
		CALL .PitchCaller
		.PitchEnd:
	endif
	RET

	if !SNESFM_CFG_CONTINOUS_PITCH_EFFECTS > 0
		.PitchCaller:
			JMP (.PitchEffectTable-$18+X)

		.PitchEffectTable:
			dw .PitchSlide	; ID = $6C, ½ID = $0C, ptr = $18

		.PitchSlide:
			MOV X, !BACKUP_X
			CLRC
			MOV A, CH1_PITCH_EFFECT_VAL_L+X	;
			ADC A, CH1_PITCH_EFFECT_ACC_L+X	;	Add up the low bytes
			MOV CH1_PITCH_EFFECT_VAL_L+X, A	;__

			MOV A, CH1_PITCH_EFFECT_VAL_H+X	;
			ADC A, CH1_PITCH_EFFECT_ACC_H+X	;	And the high bytes
			MOV CH1_PITCH_EFFECT_VAL_H+X, A	;__

			RET
	endif
endif

TransferRegisterData:
	; X is 0, CHANNEL_BITMASK is 1, as needed
	MOV DSPADDR, #KOFF		;	Send Key Offs
	MOV DSPDATA, !KOFF_BUF	;__
	MOV !CHANNEL_REGISTER_INDEX, X
	.Loop:
		; Order: volume, envelope, source, pitch
		LSR !UPD_VOL
		BCC ..UpdateEnvelope
			MOV DSPADDR, !CHANNEL_REGISTER_INDEX
			MOV A, CH1_VOLL+X
			MOV DSPDATA, A
			INC DSPADDR
			MOV A, CH1_VOLR+X
			MOV DSPDATA, A
		..UpdateEnvelope:
		LSR !UPD_ENV
		BCC ..UpdateSource
			MOV A, !CHANNEL_REGISTER_INDEX
			OR A, #V0ADSR2
			MOV DSPADDR, A

			MOV A, CH1_ADSR2+X	;	aka CH1_GAIN
			MOV Y, CH1_ADSR1+X	;__
			BMI ...ADSR
			...GAIN:
				INC DSPADDR
				MOV DSPDATA, A
				DEC DSPADDR
				JMP +
			...ADSR:
				MOV DSPDATA, A
			+:
				DEC DSPADDR
				MOV DSPDATA, Y
		..UpdateSource:
		LSR !UPD_SRC
		BCC ..UpdatePitchWithSourceMode
			MOV Y, CH1_SRCN+X
			LSR !UPD_SRC_MODE
			BCS ...UpdateSourceLowByte
				; Update Source DSP register:
				MOV A, !CHANNEL_REGISTER_INDEX
				OR A, #V0SRCN
				MOV DSPADDR, A
				MOV DSPDATA, Y
				JMP ..UpdatePitch
			...UpdateSourceLowByte:
				MOV A, CH1_FLAGS+X
				BMI +
					MOV A, Y
					MOV SMP_DIR_P0+2+X, A
					JMP ..UpdatePitch
				+:

					MOV A, Y
					MOV SMP_DIR_P0+6+X, A
					JMP ..UpdatePitch
		..UpdatePitchWithSourceMode:
		LSR !UPD_SRC_MODE
		..UpdatePitch:
		LSR !UPD_PITCH
		BCC ..End
			MOV A, !CHANNEL_REGISTER_INDEX
			AND A, #$70
			OR A, #V0PITCHL
			MOV DSPADDR, A

			MOV A, CH1_PITCHLO+X
			MOV DSPDATA, A
			INC DSPADDR
			MOV A, CH1_PITCHHI+X
			MOV DSPDATA, A
		..End:
		MOV A, X
		CLRC
		ADC A, #$08
		; This cannot set carry
		ADC !CHANNEL_REGISTER_INDEX, #$10
		MOV X, A
		ASL !CHANNEL_BITMASK
		BNE .Loop

	MOV X, #$00
	INC !CHANNEL_BITMASK

	if !SNESFM_CFG_HARDWARE_NOISE_SUPPORT
	MOV DSPADDR, #FLG		;
	MOV A, DSPDATA			;
	AND A, #$E0				;	Update Noise Pitch
	OR A, !NCLK_BUF			;
	MOV DSPDATA, A			;__
	MOV DSPADDR, #NON		;	Send Noise Enable
	EOR DSPDATA, !NON_BUF	;__
	endif
	MOV DSPADDR, #KOFF		;	Send no Key Offs
	MOV DSPDATA, X			;__
	MOV DSPADDR, #KON		;	Send Key Ons
	MOV DSPDATA, !KON_BUF	;__

	MOV !KOFF_BUF, X
	MOV !KON_BUF, X
	MOV !NON_BUF, X
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

if !SNESFM_CFG_SAMPLE_GENERATE

GMT_loop:
	CLRC						; 0
	ADC !TEMP_VALUE, #256*7/8	; 1, 2, 3
	ADC A, #$00					; 4, 5
	MOV TBL_7over8+X, A			; 6, 7, 8
	INC X						; 9
	BNE GMT_loop				; 10, 11
	RET							; 12

endif

set_echoFIR:
	MOV $00, #$08
	MOV $01, #$0F
	MOV Y, #$00
	-:
		MOV $F2, $01
		MOV A, .FIRTable+Y
		MOV $F3, A
		CLRC
		ADC $01, #$10
		INC Y
		DBNZ $00, -
	RET


	.FIRTable:
		db $7f, $00, $00, $00, $00, $00, $00, $00
;

if !SNESFM_CFG_SAMPLE_GENERATE

if !SNESFM_CFG_PULSEGEN_ANY
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

if !SNESFM_CFG_PULSEGEN_LONG
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

if !SNESFM_CFG_PULSEGEN_SHORT
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


if !SNESFM_CFG_PHASEMOD_ANY
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

if !SNESFM_CFG_PHASEMOD_LONG
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

if !SNESFM_CFG_PHASEMOD_SHORT
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



if !SNESFM_CFG_RESAMPLE
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

		if !SNESFM_CFG_SAMPLE_USE_FILTER1
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

	if !SNESFM_CFG_SAMPLE_USE_FILTER1
	.FilterLoop:
		MOV Y, BRR_SMPPT_L          ;                                       #
		MOV A, TBL_15over16+Y		;										#
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
		if !SNESFM_CFG_SAMPLE_USE_FILTER1
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
			if !SNESFM_CFG_SAMPLE_USE_FILTER1
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
			if !SNESFM_CFG_SAMPLE_USE_FILTER1
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
		MOV A, TBL_7over8+Y	;
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
		if !SNESFM_CFG_SAMPLE_USE_FILTER1
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

if !SNESFM_CFG_PITCHTABLE_GEN
GeneratePitchTable:
	.Documentation:
		; Inputs:
		; YA = base pitch value of C7
		; Dynamic shit: to be implemented
	.Defines:
		!GenPitch_DynNoteCnt #= !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_NOTE_COUNTS
		!GenPitch_DynRatios #= !SNESFM_CFG_PITCHTABLE_GEN_DYNAMIC_RATIOS

		if !GenPitch_DynNoteCnt == 0
			!GenPitch_NoteCount	= !SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT
			!GenPitch_96SubNoteCntOff = 96-!SNESFM_CFG_PITCHTABLE_GEN_NOTE_COUNT
			!GenPitch_96SubNoteCnt = #!GenPitch_96SubNoteCntOff
		else
			!GenPitch_LoTablePtr = $E2
			!GenPitch_HiTablePtr = $E4
			!GenPitch_NoteCount = $E6
			!GenPitch_96SubNoteCnt = $E7
		endif


		if !GenPitch_DynRatios == 0
			!GenPitch_Ratio_Lo  = #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO
			!GenPitch_Ratio_Hi  = #!SNESFM_CFG_PITCHTABLE_GEN_HIGHRATIO
		else
			!GenPitch_Ratio_Lo	= $E8
			!GenPitch_Ratio_Hi	= $E9
		endif


		!L001_CounterA		= $EA

		if !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD == 0
			if !GenPitch_DynRatios == 0
				!GenPitch_HalfRatio_Lo = #!SNESFM_CFG_PITCHTABLE_GEN_LOWRATIO/2
			else
				!GenPitch_HalfRatio_Lo = $EB
			endif
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

		; Assume Note count and Ratios are stored where properly needed
		if !GenPitch_DynNoteCnt == 0
			MOVW !L001_PrevPitch_Lo, YA
			MOV PitchTableLo+!GenPitch_96SubNoteCntOff, A
			MOV PitchTableHi+!GenPitch_96SubNoteCntOff, Y
			MOV X, !GenPitch_96SubNoteCnt+1
		else
			MOVW !L001_PrevPitch_Lo, YA
			MOV A, #96
			SETC
			SBC A, !GenPitch_NoteCount
			MOV !GenPitch_96SubNoteCnt, A
			MOV X, A

			MOV A, !L001_PrevPitch_Lo
			MOV PitchTableLo+X, A
			MOV PitchTableHi+X, Y
			INC X

			; PitchTableLo = $0E00, nothing to add
			MOV A, !GenPitch_NoteCount
			DEC A
			MOV Y, #$0E
			MOVW !GenPitch_LoTablePtr, YA
			CLRC
			ADC A, #96
			MOVW !GenPitch_HiTablePtr, YA
		endif

	if !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD == 0
	; old method, 123 cycles

	if !GenPitch_DynRatios != 0
		MOV A, !GenPitch_Ratio_Lo
		LSR A
		MOV !GenPitch_HalfRatio_Lo, A
	endif

	.SemitoneUpLoop:
		MOV !L001_CounterA, X

		MOV Y, !L001_PrevPitch_Lo
		MOV A, !GenPitch_Ratio_Hi		;__	Get multiplier
		MUL YA                          ;
		MOV !L001_NewPitch_Lo, A		;	Multiply low byte
		MOV !L001_NewPitch_Hi, Y		;__

		MOV !L001_PrevPitch_Lo, #$00 	;
		MOV Y, !L001_PrevPitch_Hi		;
		MOV A, !GenPitch_Ratio_Hi		;__	Get multiplier
		MUL YA                          ;__	Multiply high byte
		ADDW YA, !L001_NewPitch_Hi   	; The next byte is 0, so it adds only the high byte as the mid byte

		MOV X, !GenPitch_Ratio_Lo		;__	Get divisor
		DIV YA, X                       ;   YA very conveniently stores the high and mid bytes
		MOV !L001_NewPitch_Hi, A     	;__	Divide mid and high bytes

		MOV X, !GenPitch_Ratio_Lo		;__	Get divisor
		MOV A, !L001_NewPitch_Lo     	;   Y very conveniently stores the remainder as the high byte
		DIV YA, X                       ;__	Divide low byte with remainder as high byte
		CMP Y, !GenPitch_HalfRatio_Lo	;	Round the number
		ADC A, #$00                     ;__

		MOV X, !L001_CounterA        	;
		MOV PitchTableLo+X, A			;   Store low byte
		MOV !L001_PrevPitch_Lo, A    	;__
		MOV A, !L001_NewPitch_Hi     	;
		MOV PitchTableHi+X, A  			;   Store high byte
		MOV !L001_PrevPitch_Hi, A    	;__

		INC X
		CMP X, #96
		BNE .SemitoneUpLoop

	else	; !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD
	; new method, 150-158 cycles

	.SemitoneUpLoop:
		MOV Y, !L001_PrevPitch_Hi
		MOV A, !GenPitch_Ratio_Hi		;__	Get multiplier
		MUL YA							;	Multiply Hi * Hi
		MOVW !L001_NewPitch_Md, YA		;__

		MOV Y, !L001_PrevPitch_Lo		;
		MOV A, !GenPitch_Ratio_Lo		;__	Get multiplier
		MUL YA							;__	Multiply Lo * Lo
		ASL A							;-	Equal to CMP #$80 but 1 less byte
		MOV A, Y						;
		ADC A, #$00						;	Round the lowest byte out
		BCC +							;
			INCW !L001_NewPitch_Md		;
		+ MOV !L001_NewPitch_Lo, A		;__

		MOV Y, !L001_PrevPitch_Lo		;
		MOV A, !GenPitch_Ratio_Hi		;__	Get multiplier
		MUL YA							;	Multiply Lo * Hi
		ADDW YA, !L001_NewPitch_Lo		;
		ADC !L001_NewPitch_Hi, #$00		;
		MOVW !L001_NewPitch_Lo, YA		;__

		MOV Y, !L001_PrevPitch_Hi		;
		MOV A, !GenPitch_Ratio_Lo		;__	Get multiplier
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

		MOV A, !L001_PrevPitch_Lo		;	Store the low pitch byte
		MOV PitchTableLo+X, A			;__
		MOV A, !L001_PrevPitch_Hi		;	Store the high pitch byte
		MOV PitchTableHi+X, A			;__

		INC X
		CMP X, #96
		BNE .SemitoneUpLoop

	endif	; !SNESFM_CFG_PITCHTABLE_GEN_ARITHMETIC_METHOD

	if !GenPitch_DynNoteCnt == 0 && !GenPitch_NoteCount >= 96
	else
	.BitShiftStart:
		MOV Y, !GenPitch_96SubNoteCnt
		if !GenPitch_DynNoteCnt
			BEQ .OverflowCorrection
		endif

		if !GenPitch_DynNoteCnt
			!PTR_LO = (!GenPitch_LoTablePtr)+Y
			!PTR_HI = (!GenPitch_HiTablePtr)+Y
		else
			!PTR_LO = PitchTableLo+!GenPitch_NoteCount-1+Y
			!PTR_HI = PitchTableHi+!GenPitch_NoteCount-1+Y
		endif

	.BitShiftLoop:
		MOV A, !PTR_HI			;
		LSR A					;	Halve high byte
		MOV X, A				;__
		MOV A, !PTR_LO			;	Halve low byte
		ROR A					;__
		ADC A, #$00				;	Round & store low byte
		MOV PitchTableLo-1+Y, A	;__
		MOV A, X				;
		ADC A, #$00				;	Round & store high byte
		MOV PitchTableHi-1+Y, A	;__
		DBNZ Y, .BitShiftLoop

		undef PTR_LO : undef PTR_HI
	endif

	.OverflowCorrection:
		MOV Y, #96

		..Loop:
			MOV A, PitchTableHi-1+Y		;
			CMP A, #$40					;   If the value isn't overflowing, exit
			BMI .End					;__

			MOV A, #$3F					;
			MOV PitchTableHi-1+Y, A		;   Cap the pitch value
			MOV A, #$FF					;
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

	if pc()&$FF >= $FD : fill $03 : endif 	;__	Ensure the same high page

WriteToChannel: ; TCALL 13
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

print "End of code: ", pc

assert pc() < $6000
endspcblock

Includes:
	if not(!SNESFM_CFG_PITCHTABLE_GEN)
		spcblock PitchTableLo !SNESFM_CFG_SPCBLOCK_TYPE
			incbin "pitchLo.bin"
			incbin "pitchHi.bin"
	else
		spcblock $0EC0 !SNESFM_CFG_SPCBLOCK_TYPE
	endif
		db $03, $00, $00, $00, $00, $00, $00, $00, $00 ;Dummy empty sample
		endspcblock
	spcblock $0F00 !SNESFM_CFG_SPCBLOCK_TYPE
		incbin "quartersinetable.bin"
	if !SNESFM_CFG_PITCHBEND_ANY
		Log2Generate:
			MOV A, #$00
			MOV X, A
			MOV Y, A
			.GetStaggerPoint:
				PUSH A					;
				MOV A, LogTableTable+X	;
				INC X					;	Retrieve the next stagger point
				MOV !TEMP_VALUE, A		;
				POP A					;__
			.Loop:
				CMP Y, !TEMP_VALUE		;	If we're at the stagger value
				BEQ +					;__	do something
					MOV LogTable+Y, A	;
					INC A				;	If we aren't, store value to table
					INC Y				;	And increment value by 1
					BNE .Loop			;__
			RET

			+:
				MOV LogTable+Y, A		;	If we are at a stagger point
				INC Y					;	store value to table
				BRA .GetStaggerPoint	;__	and don't increment

	LogTableTable:
		db 6, 20, 34, 49, 65, 81, 99, 118, 138, 161, 187, 218
		db 0
	LogTable = $0B00

	endspcblock

	endif

	spcblock $FFC0 !SNESFM_CFG_SPCBLOCK_TYPE   ;For TCALLs
		dw IndexToSamplePointer
		dw UpdatePitch
		if !SNESFM_CFG_VIRTUAL_CHANNELS > 0
			dw WriteToChannel
		endif

	endspcblock execute Init

namespace off