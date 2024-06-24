;------------------------------------------------------------------------
;-  Originally written by: Neviksti
;-  Converted to use with Asar and improved by: alexmush
;-     If you use my code, please share your creations with me
;-     as I am always curious :)
;------------------------------------------------------------------------

asar 1.90

incsrc "SNES_constants.asm"

optimize dp always
optimize address mirrors

!INIT_USE_FASTROM ?= 0

if !INIT_USE_FASTROM
org $808000
bank $80
else
org $008000
bank $00
endif
_InitSNES:
	.Start:
		PHK			;set Data Bank = Program Bank
		PLB

		SEP #$10	; mem/A = 16 bit, idx/XY = 8 bit

		PLA			;we clear all the mem at one point ...
		STA $4372  	;so save the return address in a place that won't get overwritten
		PLX			;(that place is DMA registers)
		STX $4374

		SEP #$30	; mem/A = 8 bit, idx/XY = 8 bit
		
		JSR SetRegisters
		JSR ClearVRAM
		JSR ClearPalette
		JSR ClearOAM

	.ClearWRAM:
		;**** clear WRAM ********
		
		!WRAM_FILL_BYTE = (..WRAMFillInstr+1)
		; The instruction is LDX #$0000, assembles as
		; $A2 $00 $00, the second byte of that
		; is a consistent 0 we can use

		REP #$10		; idx/XY = 16 bit

		STX WMADDL		; (X is 0 after the loop)
		STZ WMADDH		;set WRAM address to $000000

		; it is not worth it to set the DP to $4300

		LDX #$8008
		STX $4300		;Set DMA mode to fixed source, BYTE to $2180
		LDX #!WRAM_FILL_BYTE
		STX $4302		;Set source offset
		LDA.b #bank(!WRAM_FILL_BYTE)
		STA $4304		;Set source bank
	#..WRAMFillInstr:	LDX #$0000
		PHX				; Push to return to DP $0000 later on	
		STX $4305		;Set transfer size to 64k bytes
		LDA.b #$01
		STA $420B		;Initiate transfer
		STA $420B		;Initiate second transfer for 64k more bytes

		PHK			;make sure Data Bank = Program Bank
		PLB

		PLD			;DP = $0000 from the PHX
		dpbase $0000	; tell Asar to optimize the following everything

		CLI			;enable interrupts again

		LDA $4374  	;get our return address...
		if !INIT_USE_FASTROM
			ORA #$80	; Force FastROM
		endif
		PHA
		LDX $4372
		PHX
		RTL

;----------------------------------------------------------------------------
; ClearVRAM -- Sets every byte of VRAM to zero
; In: None
; Out: None
; Modifies: Nothing
;----------------------------------------------------------------------------
ClearVRAM:
	pha
	phx
	php

	REP #$30		; mem/A = 8 bit, X/Y = 16 bit
	SEP #$20

	LDA #$80
	STA VMAIN         ;Set VRAM port to word access
	LDX #$1809
	STX $4300         ;Set DMA mode to fixed source, WORD to $2118/9
	LDX #$0000
	STX VMADDL        ;Set VRAM port address to $0000
	STX $00        ;Set $00:0000 to $0000 (assumes scratchpad ram)
	STX $4302         ;Set source address to $xx:0000
	LDA #$00
	STA $4304         ;Set source bank to $00
	LDX #$FFFF
	STX $4305         ;Set transfer size to 64k-1 bytes
	LDA #$01
	STA $420B         ;Initiate transfer

	STZ $2119         ;clear the last byte of the VRAM

	plp
	plx
	pla
	RTS

;----------------------------------------------------------------------------
; ClearPalette -- Reset all palette colors to zero
; In: None
; Out: None
; Modifies: Nothing
;----------------------------------------------------------------------------
ClearPalette:
	PHX
	PHP
	PHD
	REP #$30		; mem/A = 16 bit, X/Y = 16 bit
	SEP #$20		; mem/A = 8 bit, X/Y = 16 bit

	PEA $2100		; set DP to $2100
	PLD				; for faster access
	dpbase $2100	; tell Asar that

	STZ CGADD
	LDX #$0100
	.Loop:
		STZ CGDATA
		STZ CGDATA
		DEX
		BNE .Loop

	PLD
	dpbase $0000
	PLP
	PLX
	RTS


;----------------------------------------------------------------------------
; ClearPalette -- Reset all palette colors to zero
; In: None
; Out: None
; Modifies: Nothing
;----------------------------------------------------------------------------
ClearOAM:
	PHA
	PHX
	PHP
	PHD
	SEP #$20		; mem/A = 8 bit
	REP #$10		; idx/XY = 16 bit

	PEA $2100		; set DP to $2100
	PLD				; for faster access
	dpbase $2100	; tell Asar that

	STZ OAMADDL	;sprites initialized to be off the screen, palette 0, character 0
	STZ OAMADDH
	LDX.w #$80
	LDA #$01
	.Loop08:
		STA OAMDATA	;set X = 1 (-255 really because of the next loop)
		STZ OAMDATA	;set Y = 0
		STZ OAMDATA	;set character = $00
		STZ OAMDATA	;set priority=0, no flips
		DEX
		BNE .Loop08

	LDX.w #$20
	LDA #%01010101
	.Loop09:
		STA OAMDATA		;set size bit=0, x MSB = 1
		DEX
		BNE .Loop09

	PLD
	PLP
	PLX
	PLA
	RTS
	

;----------------------------------------------------------------------------
; SetRegisters -- set PPU and CPU registers to a known state (as per snesdev)
; In: None
; Out: None
; Modifies: Nothing
;----------------------------------------------------------------------------
SetRegisters:
	PHD
	PHA
	PHX
	PHY
	PHP

	PEA $2100	;set Direct Page = $2100 for easier writes to VRAM registers
	PLD			;Transfer Accumulator to Direct Register
	dpbase $2100	; tell Asar to optimize the following everything

	SEP #$30	; mem/A = 8 bit, idx/XY = 8 bit

	STZ NMITIMEN	;reg $4200  - disable timers, NMI, and auto-joyread
	STZ HDMAEN		;reg $420C  - turn off all HDMA channels

	LDA #$8F
	STA INIDISP	;turn screen off for now, set brightness to normal

	LDX #(BG34NBA-OBSEL)
	.Loop00:		;regs $2101-$210C
		STZ OBSEL,X		;set Sprite,Character,Tile sizes to lowest, and set addresses to $0000
		DEX
		BPL .Loop00

	LDA #$FF
	LDX #(BG4VOFS-BG1HOFS)
	.ScrollClearLoop:		;regs $210D-$2114
		STA BG1VOFS,X		;Set all vertical BG scroll values to $FFFF (-1)
		STA BG1VOFS,X

		STZ BG1HOFS,X		;Set all horizontal BG scroll values to $0000
		STZ BG1HOFS,X
		DEX
		DEX
		BPL .ScrollClearLoop

	LDA #$80		;reg $2115
	STA VMAIN		; Initialize VRAM transfer mode to word-access, increment by 1

	STZ VMADDL		;regs $2116-$2117
	STZ VMADDH		;VRAM address = $0000

			;reg $2118-$2119
			;VRAM write register... don't need to initialize

	LDA #$01
	STZ M7A		;clear Mode7 setting
	STA M7A

	STZ M7D
	STA M7D

	LDX #1
	.Mode7BCXYLoop:		;regs $211B-$2120
		STZ M7B,X		;clear out the Mode7 matrix values
		STZ M7B,X
		STZ M7X,X
		STZ M7X,X
		DEX
		BPL .Mode7BCXYLoop

				;reg $2121 - Color address, doesn't need initilaizing
				;reg $2122 - Color data, is initialized later

	LDX #(TSW-W12SEL)
	.WindowEnableLoop:		;regs $2123-$2133
		STZ W12SEL,X	;turn off windows, main screens, sub screens
		DEX
		BPL .WindowEnableLoop

	LDA #%00110000	;deactivate windows, no direct color mode, use fixed color as base
	STA CGWSEL

	STZ CGADSUB		;color math on nothing, add, no halving

	LDA #%11100000	;Fixed color: write color 0 to bgr
	STA COLDATA

	STZ SETINI		;no super-impose (external synchronization),
					;no interlaced mode, normal resolution

			;regs $2134-$2136  - multiplication result, no initialization needed
			;reg $2137 - software H/V latch, no initialization needed
			;reg $2138 - Sprite data read, no initialization needed
			;regs $2139-$213A  - VRAM data read, no initialization needed
			;reg $213B - Color RAM data read, no initialization needed
			;regs $213C-$213D  - H/V latched data read, no initialization needed

			;reg $213E - PPU1 status flags, no initialization needed
			;reg $213F - PPU2 status flags, no initialization needed

			;reg $2140-$2143 - APU communication regs, no initialization required

			;reg $2180  -  read/write WRAM register, no initialization required
			;reg $2181-$2183  -  WRAM address, no initialization required

			;reg $4016-$4017  - serial JoyPad read registers, no need to initialize


	LDA #$FF
	STA WRIO		;reg $4201  - programmable I/O write port, initalize to allow reading at in-port

			;regs $4202-$4203  - multiplication registers, no initialization required
			;regs $4204-$4206  - division registers, no initialization required

			;regs $4207-$4208  - Horizontal-IRQ timer setting, since we disabled this, it is OK to not init
			;regs $4209-$420A  - Vertical-IRQ timer setting, since we disabled this, it is OK to not init

	STZ MDMAEN		;reg $420B  - turn off all general DMA channels

	if !INIT_USE_FASTROM
		STA MEMSEL		;reg $420D  - ROM access time to fast (3.78Mhz)
	else
		STZ MEMSEL		;reg $420D  - ROM access time to slow (2.68Mhz)
	endif

	LDA RDNMI		;reg $4210  - NMI status, reading resets

			;reg $4211  - IRQ status, no need to initialize
			;reg $4212  - H/V blank and JoyRead status, no need to initialize
			;reg $4213  - programmable I/O inport, no need to initialize

			;reg $4214-$4215  - divide results, no need to initialize
			;reg $4216-$4217  - multiplication or remainder results, no need to initialize

			;regs $4218-$421f  - JoyPad read registers, no need to initialize

			;regs $4300-$437F
			;no need to intialize because DMA was disabled above
			;also, we're not sure what all of the registers do, so it is better to leave them at
			;their reset state value
	PLP
	PLY
	PLX
	PLA
	PLD
	dpbase $0000
	RTS



;----------------------------------------------------------------------------
; InitSNES -- the "standard" initialization of SNES memory and registers
;----------------------------------------------------------------------------

macro InitSNES()
	SEI                     ;disable interrupts
	CLC                     ;switch to native mode
	XCE

	REP #$38		; mem/A = 16 bit, X/Y = 16 bit, decimal mode off

	LDX #$1FFF	;Setup the stack
	TXS			;Transfer Index X to Stack Pointer Register

	if !INIT_USE_FASTROM
		STX $420D	; 420E doesn't exist, we don't affect anything
	endif

	;do the rest of the initialization in a routine
	JSL _InitSNES

	SEP #$20		; mem/A = 8 bit
endmacro