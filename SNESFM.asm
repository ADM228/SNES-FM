;!!!!NOTES!!!!


;ROM NOTES
;#030000 [#068000] - Palette information
;#032000 [#06A000] - Tile information
;#038000 [#078000] - Tilemap information
;VAR NOTES
;$7FFFFD - Modulation Strength
incsrc "header.asm"
incsrc "initSNES.asm"

org $068000
incbin "palette.pal"
org $06A000
incbin "tiles.chr"
org $06FC00
incbin "sinetable.bin"
org $078000
incbin "tilemap.bin"
org $07A000
incbin "bg3map.map"
org $01FFFF ;set size of the file, irrelevant lmao
db $00


;========================
; Start
;========================

org $008129
    lda #$80            ; = 10000000
    sta $2100           ; Turn on screen, full brightness
SPCTransfer:         ;__
    PEA $0000       ;   set dp to 00 since RAM
    PLD				;__
    LDA #$01        ;
    PHA             ;   set db to 01 since that's where the code is
    PLB

SPCTransferLoop00:
    LDA $2140
    CMP #$AA
    BNE SPCTransferLoop00
    LDA $2141
    CMP #$BB
    BNE SPCTransferLoop00
                    ;__
    LDX #$01E0      ;
    STX $01         ;   Base address: $01E000
    STZ $00         ;__
SPCTA:
    LDY #$0002      ;
    LDA [$00],Y     ;
    STA $2142       ;
    INY             ;   Give address to SPC
    LDA [$00],Y     ;
    STA $2143       ;__
    LDY #$0000      ;
    LDA [$00],Y     ;
    STA $04         ;
    INY             ;   Get the length, put it in $04-$05
    LDA [$00],Y     ;
    STA $05         ;__
    INY             ;
    LDX $04         ;   If length = 0 it's a jump, therefore end transmission
    BEQ SPCTransferJump;__
    LDA #$CC
    NOP
    STA $2140
    STA $2141
SPCTransferLoop01:
    LDA $2140
    CMP #$CC
    BNE SPCTransferLoop01
    LDY #$0000
    CLC
    LDA $00
    ADC #$04
    STA $00
    LDA $01
    ADC #$00
    STA $01
SPCTransferLoop02:
    LDA [$00],Y
    STA $2141
    TYA
    STA $2140
    STA $03
SPCTransferLoop03:
    LDA $2140
    CMP $03
    BNE SPCTransferLoop03
    INY
    CPY $04
    BNE SPCTransferLoop02
    TYA
    CLC
    ADC $00
    STA $00
    LDA $01
    ADC $05
    STA $01
    TYA
    INC A
    STA $2140
    BRA SPCTA

SPCTransferJump:
    LDA #$00
    STA $2141
    STA $2140
    LDA #$0F
    STA $60
dmaToCGRAM:
    LDA #$00        ;
    PHA             ;   set db to 00
    PLB

    PHA
    PHX
    PHP
    PHD
    
    PEA $4300
    PLD				;set dp to 43
    
    REP #%00010000	;set xy to 16bit
    SEP #%00100000 	;set a to 8bit
    LDA #$00		;Address to write to in CGRAM
    STA $2121		;Write it to tell Snes that
    LDA #$22		;CGRAM Write register
    STA $01			;DMA 0 B Address
    LDA #$06		;Bank of palette
    STA $04			;DMA 0 A Bank
    LDX #$8000		;Address of palette
    STX $02			;DMA 0 A Offset
    LDX #$0200		;Amount of data
    STX $05			;DMA 0 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (000 = 1 byte, write once)
    STA $00
dmaToVRAM1:
    LDX #$0000		;Address to write to in VRAM
    STX $2116		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA $11			;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA $14			;DMA 1 A Bank
    LDX #$A000		;Address of tiles
    STX $12			;DMA 1 A Offset
    LDX #$0C00		;Amount of data
    STX $15			;DMA 1 Number of bytes
    LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
    STA $10
    LDA #%00000011	;bit 2 corresponds to channel 0
    STA $420B		;Init
dmaToVRAM2:
    LDX #$0800		;Address to write to in VRAM
    STX $2116		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA $21			;DMA 2 B Address
    LDA #$07		;Bank of tilemap
    STA $24			;DMA 2 A Bank
    LDX #$8000		;Address of tilemap
    STX $22			;DMA 2 A Offset
    LDX #$2700		;Amount of data
    STX $25			;DMA 2 Number of bytes
    LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
    STA $20
    LDA #%00000100	;bit 2 corresponds to channel 0
    STA $420B		;Init
EmptyPlotData:
    LDX #$0280		;Address to write to in VRAM
    STX $2116		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA $11			;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA $14			;DMA 1 A Bank
    LDX #$A0C0		;Address of tiles
    STX $12			;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX $15			;DMA 1 Number of bytes
    LDA #%00001001	;Settings d--uummm (Direction (0 = A to B) Update (01 = don't) Mode (001 = 2 bytes, write once)
    STA $10
    LDA #%00001010  ;bit 2 corresponds to channel 0
    STA $420B		;Init
    
    PLD
    PLP
    PLX
    PLA

TurnOnScreen:
    SEP #%00100000 ;A 8-bit
    
    lda #%00000001
    sta $4200
    REP #%00010000 ;set xy to 16bit
    SEP #%00100000 ;set a to 8bit
    LDA #%00001001	; = 8/8/8/8 px tile size, BG3 hpri, mode 1
    STA $2105
    STZ $210E
    LDA #%00000100
    STA $212C
    LDA #%00001000
    STA $2107
    LDA #%00011000
    STA $2109
    lda #$80            ; = 10000000
    sta $2100           ; F-Blank
    LDA #$00
    PEA $0000
    PLD				;set dp to 00
    JSL tableROMtoWRAM
    JSL clearPaletteData
    JSL RoutineSelect
    JSL Decompress
    SEP #%00100000 ;A 8-bit
    lda #$0F            ; = 00001111
    sta $2100           ; Turn on screen, full brightness
    lda #%10000001
    sta $4200
    STZ $2115
forever:
        jmp forever
org $008400
nmi:
    ; Scrolling
    LDA $20
    STA $210d
    LDA $21
    STA $210d
    LDA $22
    STA $210E
    LDA $23
    STA $210E

    ;Update the mod strength number
    LDX #$1ACC
    STX $2116

    LDA $10
    AND #$F0
    LSR
    LSR
    LSR
    LSR
    ORA #$10
    STA $2118

    LDA $10
    AND #$0F
    ORA #$10
    STA $2118

    LDX #$16EC
    STX $2116

    LDA $11
    STA $2118
    LDA $12
    STA $2118

    ; Plot the graph
    lda #$8F            ; = 10001111
    sta $2100           ; Turn on screen, full brightness
    JSL Decompress
    lda #$0F             ; = 00001111
    sta $2100           ; Turn on screen, full brightness

    PHA
    PHP
    REP #%00100000 ;set xy to 8bit
    SEP #%00010000 ;set a to 16bit

incsrc "controllerRoutine.asm"

REP #%00010000 ;set XY to 16bit
SEP #%00100000 ;set A to 8bit

LDA #%00000101
STA $212C
LDA #%00000100
STA $212D
lda #$0F            ; = 00001111
sta $2100           ; Turn on screen, full brightness

lda #%00000001
sta $4200
LDA #$00
PEA $0000
PLD				;set dp to 00
lda #$08            ; = 00000111
sta $2100           ; Turn on screen, half brightness
JSL clearPaletteData
JSL RoutineSelect
SEP #%00100000 ;A 8-bit
lda $60            ; = 00001111
sta $2100           ; Turn on screen, full or quarter brightness
lda #%10000001
sta $4200

LDA $2140
CMP #$89
BNE NMIEnd
LDA $2141
CMP #$AB
BNE NMIEnd
LDA $2142
CMP #$CD
BNE NMIEnd
LDA $2143
CMP #$EF
BNE NMIEnd
LDA #$0C
STA $60

NMIEnd:

PLP
PLA
RTI 

org $018000 ;The plotting engine for now
;1bpp to 2bpp converter

tableROMtoWRAM:		
	PEA $4300
    PLD				;set dp to 43

	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$0800		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA $01			;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA $04			;DMA 1 A Bank
    LDX #$FC00		;Address of tiles
    STX $02			;DMA 1 A Offset
    LDX #$0400		;Amount of data
    STX $05			;DMA 1 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (000 = 1 byte, write once)
    STA $00
	LDA #%00000001  ;bit 2 corresponds to channel 0
    STA $420B		;Init
tableROMtoWRAM2:		
    ;JMP clearPaletteData
	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$0C00		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA $01			;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA $04			;DMA 1 A Bank
    LDX #$FC00		;Address of tiles
    STX $02			;DMA 1 A Offset
    LDX #$0400		;Amount of data
    STX $05			;DMA 1 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (000 = 1 byte, write once)
    STA $00
	LDA #%00000001  ;bit 2 corresponds to channel 0
    STA $420B		;Init
    RTL
clearPaletteData:		
    PEA $4300
    PLD				;set dp to 43
	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$FE00		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA $01			;DMA 1 B Address
    LDA #$01		;Bank of tileset
    STA $04			;DMA 1 A Bank
    LDX #$FFFF		;Address of tiles
    STX $02			;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX $05			;DMA 1 Number of bytes
    LDA #%00001000	;Settings d--uummm (Direction (0 = A to B) Update (01 = don't) Mode (010 = 2 bytes, write twice)
    STA $00
    LDA #%00000001  ;bit 2 corresponds to channel 0
    STA $420B		;Init
    RTL
Decompress:
    REP #%00010000 ;set xy to 16bit
    SEP #%00100000 ;set a to 8bit
    PEA $0000
    PLD				;set db to 7f
    LDA #$7F
    PHA
    PLB
    LDX #$00FF
    LDY #$003F
DecompressLoop:
    LDA $0000, X
    EOR #$80
    STA $FDC0, Y
    STX $00
    LDA $00
    SEC
    SBC #$04
    STA $00
    LDA $01
    SBC #$00
    STA $01
    LDX $00
    DEY
    BPL DecompressLoop
Plot:
    REP #%00110000 ;set xy and a to 16bit
    LDA #$01C0
    LDY #$0000
PlotLoop:
    TAX
    SEP #%00100000 ;set a to 8bit
	LDA #$FF
    STA $FE01,X
    STA $FE03,X
    STA $FE05,X
    STA $FE07,X
    STA $FE09,X
    STA $FE0B,X
    STA $FE0D,X
    STA $FE0F,X
    STA $FE11,X
    STA $FE13,X
    STA $FE15,X
    STA $FE17,X
    STA $FE19,X
    STA $FE1B,X
    STA $FE1D,X
    STA $FE1F,X
    STA $FE21,X
    STA $FE23,X
    STA $FE25,X
    STA $FE27,X
    STA $FE29,X
    STA $FE2B,X
    STA $FE2D,X
    STA $FE2F,X
    STA $FE31,X
    STA $FE33,X
    STA $FE35,X
    STA $FE37,X
    STA $FE39,X
    STA $FE3B,X
    STA $FE3D,X
    STA $FE3F,X
    REP #%00110000 ;set xy and a to 16bit
    TXA         ;\
    LSR A       ; |
    LSR A       ; | Get the index of the 
    LSR A       ; | entry in the input table
    ADC #$0007  ; |
    TAY         ;/
; bit 7
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF01
    ORA $FE00, Y
    STA $FE00, Y
; bit 6
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF02
    ORA $FE00, Y
    STA $FE00, Y
; bit 5
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF04
    ORA $FE00, Y
    STA $FE00, Y
; bit 4
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF08
    ORA $FE00, Y
    STA $FE00, Y
; bit 3
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF10
    ORA $FE00, Y
    STA $FE00, Y
; bit 2
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF20
    ORA $FE00, Y
    STA $FE00, Y
; bit 1
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    PHY
    TAY

    LDA #$FF40
    ORA $FE00, Y
    STA $FE00, Y
; bit 0
    PLY
    DEY
    LDA $FDC0, Y
    LSR A
    LSR A
    AND #%0000000000111110
    EOR #%0000000000111110
    STX $0000
    ORA $0000
    TAY

    LDA #$FF80
    ORA $FE00, Y
    STA $FE00, Y
;final
    TXA
    SEC
    SBC #$0040
    BMI Afterloop
    JML PlotLoop
Afterloop:
    REP #%00010000 ;set xy to 16bit
    SEP #%00100000 ;set a to 8bit
    PEA $4300
    PLD	;set dp to 43
    LDA #$00
    PHA
	PLB
WRAMtoVRAM:
	lda #$80            ; = 10000000
    sta $2100           ; F-Blank
    LDX #$0280		;Address to write to in VRAM
    STX $2116		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA $01			;DMA 1 B Address
    LDA #$7F		;Bank of tileset
    STA $04			;DMA 1 A Bank
    LDX #$FE00		;Address of tiles
    STX $02			;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX $05			;DMA 1 Number of bytes
    LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (001 = 2 bytes, write once)
    STA $00
    LDA #%00000001  ;bit 2 corresponds to channel 0
    STA $420B		;Init
    PEA $0000
    PLD				;set dp to 00
	lda #$0F            ; = 00001111
    sta $2100           ; Turn on screen, full brightness
RTL

RoutineSelect:
    ;Input: Carrier wavetable at $7F0800, $0400 bytes long
    ;Input: Modulator wavetable at $7F0C00, $0400 bytes long
    ;Output: Modulated Wavetable at $7F0000, $0400 bytes long
    SEP #%00100000 ;set a to 8bit
    LDA $0020
    STA $7FFFFD
    PEA $2100
    PLD				;set db to 7f
    LDA #$7F
    PHA
    PLB
    LDY #$00FE
    LDA $FFFD
    SEC
    SBC #$80
    BPL PhaseModulation10
PhaseModulation20:
    LDA #$3C
    STA $000011
    LDA #$3A
    STA $000012
    REP #%00110000 ;set a to 16bit
PhaseModulation20Loop:
    ;SLOW AS CRAP, needs fixing
    TYA             ;2
    ASL             ;2
    ASL             ;2
    TAX             ;2
    SEP #$20        ;3
    LDA $0C00, X    ;5
    STA $1B         ;3
    LDA $0C01, X    ;5 _ 16
    STA $1B         ;3
    LDA $FFFD       ;4, Mod strength
    STA $1C         ;3
    REP #$20        ;3
    LDA $35         ;3
    LSR             ;2
    LSR             ;2
    LSR             ;2 _ 23

    STX $FFFE       ;5
    ADC $FFFE       ;5
    AND #$03FE      ;3
    TAX             ;2 _ 15
    ADC #$0C00
    STA $0100, Y
    LDA $0800, X    ;6
    STA $0000, Y    ;5
    DEY             ;2
    DEY             ;2 _ 15
    CPY #$0000
    BPL PhaseModulation20Loop ;2
    JML PhaseModulationFinish

PhaseModulation10:
    SEC
    SBC #$40
    BPL PhaseModulation08
    LDA $FFFD
    SEC
    SBC #$40
    STA $FFFD
    LDA #$3B
    STA $000011
    LDA #$3A
    STA $000012
    REP #%00110000 ;set a to 16bit
PhaseModulation10Loop:
    ;SLOW AS CRAP, needs fixing
    TYA             ;2
    ASL             ;2
    ASL             ;2
    TAX             ;2
    SEP #$20        ;3
    LDA $0C00, X    ;5
    STA $1B         ;3
    LDA $0C01, X    ;5 _ 16
    STA $1B         ;3
    LDA $FFFD       ;4, Mod strength
    STA $1C         ;3
    REP #$20        ;3
    LDA $35         ;3
    LSR             ;2
    LSR             ;2 _ 21

    STX $FFFE       ;5
    ADC $FFFE       ;5
    AND #$03FE      ;3
    TAX             ;2 _ 15
    LDA $0800, X    ;6
    STA $0000, Y    ;5
    DEY             ;2
    DEY             ;2 _ 15
    CPY #$0000
    BPL PhaseModulation10Loop ;2
    JMP PhaseModulationFinish

PhaseModulation08:
    LDA $FFFD
    SEC
    SBC #$80
    STA $FFFD
    LDA #$3A
    STA $000011
    LDA #$3E
    STA $000012
    REP #%00110000 ;set a to 16bit
PhaseModulation08Loop:
    ;SLOW AS CRAP, needs fixing
    TYA             ;2
    ASL             ;2
    ASL             ;2
    TAX             ;2
    SEP #$20        ;3
    LDA $0C00, X    ;5
    STA $1B         ;3
    LDA $0C01, X    ;5 _ 16
    STA $1B         ;3
    LDA $FFFD       ;4, Mod strength
    STA $1C         ;3
    REP #$20        ;3
    LDA $35         ;3
    LSR             ;2 _ 23

    STX $FFFE       ;5
    ADC $FFFE       ;5
    AND #$03FE      ;3
    TAX             ;2 _ 15
    LDA $0800, X    ;6
    STA $0000, Y    ;5
    DEY             ;2
    DEY             ;2 _ 15
    CPY #$0000
    BPL PhaseModulation08Loop ;2

PhaseModulationFinish:
    SEP #%00100000 ;set a to 8bit
    LDA $FFFD
    STA $000010
    STZ $FFFD
    PEA $0000
    PLD				;set db to 00
    LDA #$00
    PHA
    PLB
    RTL

org $01E000
arch spc700-inline
;   ==== Code/data distribution table: ====
;   page        purpose
;   $00 _ _ _ _ $00 - $0F: Operating space of subroutines (how exactly described before every subroutine)
;   $01         $00 - $7F: Some other variables maybe
;   |__ _ _ _ _ $80 - $FF: Stack
;   $02(-$03?)_ Sample Directory
;   $0C-$0F _ _ Sine table, only $0C00-0D02 is written, everything else is calculated
;   $10-$1F _ _ Music data and custom BRR samples (indexed from end)
;   $20-$3F _ _ Code
;   $40-$5F _ _ 8 FM generation buffers, 4 pages long each
;   $60-$6F _ _ BRR conversion buffer
;   $70-$7F _ _ Channel 8 PCM mode PCM buffer ?
;   $88-$FF _ _ Echo buffer later
org $2000
init:       ;init routine, totally not grabbed from tales of phantasia
    NOP
    CLRP
    MOV A, #$00     ;__
    MOV $F4, A      ;
    MOV $F5, A      ;
    MOV $F6, A      ;   Clear the in/out ports with the SNES, disable timers
    MOV $F7, A      ;
    MOV $F1, #$30   ;__
    MOV X, #$FF     ;   Reset the stack
    MOV SP, X       ;__
    MOV $F2, #$4D   ;
    MOV $F3, A      ;
    MOV $F2, #$2C   ;   Disable the echo
    MOV $F3, A      ;
    MOV $F2, #$3C   ;
    MOV $F3, A      ;__
    MOV $F2, #$0C   ;
    MOV $F3, A      ;   Reset volume
    MOV $F2, #$1C   ;
    MOV $F3, A      ;__
    MOV $F2, #$4C   ;   Key On nothing
    MOV $F3, A      ;__
    MOV $F2, #$5C   ;   Key Off everything
    MOV $F3, X      ;__
    MOV $F2, #$5D   ;   Set sample directory at $0200
    MOV $F3, #$02   ;__
    MOV $FA, #$82   ;   Set timer 0 to count every 16.25 ms
    MOV $F1, #$01   ;__
    MOV $F2, #$7D   ;
    MOV Y, $F3      ;
    CMP Y, #$0F     ;
    BCC spcinit_000 ;   Load {echo delay}+1 into y, capping off at 16 if needed
    MOV Y, #$0F     ;
spcinit_000:        ;
    INC Y           ;__
    spcinit_001:    ;
        MOV A, $FD      ;
        BEQ spcinit_001 ;   Time-wasting loop to clear the echo buffer
        DBNZ Y,spcinit_001;__

    MOV $F2, #$6C   ;
    MOV $F3, #$BF   ;___
    MOV Y, #$06     ;
    spcinit_002:    ;Wait 97.5 ms for some reason
        MOV A, $FD  ;
        BEQ spcinit_002
        DBNZ Y, spcinit_002
                    ;__
    MOV A, #$00     ;
    MOV $F2, #$5C   ;   Key off on all channels
    MOV $F3, #$FF   ;__
    MOV $F2, #$2D   ;   Disable Hardware Pitchmod
    MOV $F3, A      ;__
    MOV $F2, #$3D   ;   Disable Noise
    MOV $F3, A      ;__
    CALL SPC_set_echoFIR
    MOV $F2, #$0C   ;
    MOV $F3, #$7F   ;   Set main volume to 127
    MOV $F2, #$1C   ;
    MOV $F3, #$7F   ;__
    MOV $F1, #$00   ;
    MOV $FA, #$08   ;   Set Timer 0 to 1 ms
    MOV $F1, #$07   ;__

; Setting up the sine table

    MOV X, #$02     ;__ X contains the source index,
    MOV Y, #$FE     ;__ Y contains the destination index

    SPC_SineSetup_loop0:
        MOV A, $0C00+X
        INC X
        MOV $0D00+Y, A
        MOV A, $0C00+X
        INC X
        MOV $0D01+Y, A
        DEC Y
        DBNZ Y, SPC_SineSetup_loop0
    
    SPC_SineSetup_loop1:
        MOV A, $0C00+Y
        EOR A, #$FF
        MOV $0E00+Y, A
        MOV A, $0D00+Y
        EOR A, #$FF
        MOV $0F00+Y, A
        DBNZ Y, SPC_SineSetup_loop1
    MOV $00, #$0C
    MOV $01, #$0C
    MOV $02, #$44
    MOV $03, #$10
    CALL SPC_PhaseModulation_1KB
    MOV $00, #$44
    MOV $01, #$0C
    MOV $02, #$40
    MOV $03, #$10
    CALL SPC_PhaseModulation_1KB
    MOV $00, #$0C
    MOV $01, #$0C
    MOV $02, #$44
    MOV $03, #$20
    CALL SPC_PhaseModulation_1KB
    ;Tryna play a BRR sample
    MOV $F2, #$00;
    MOV $F3, #$7F;vol left
    MOV $F2, #$02;
    MOV $F3, #$CE;
    MOV $F2, #$03;
    MOV $F3, #$0F;pitch
    MOV $F2, #$04
    MOV $F3, #$00;SCRN
    MOV $F2, #$05
    MOV $F3, #$00;use GAIN
    MOV $F2, #$07
    MOV $F3, #$7F;max volume right away
    MOV $F2, #$5C
    MOV $F3, #$00
    MOV $F2, #$6C
    MOV $F3, #$20
    MOV $F2, #$4C
    MOV $F3, #$01;PLAY

    MOV $F4, #$89
    MOV $F5, #$AB
    MOV $F6, #$CD
    MOV $F7, #$EF
    STOP

SPC_set_echoFIR:
    MOV $00, #$08
    MOV $01, #$0F
    MOV Y, #$00
SPC_set_echoFIRloop:
    MOV $F2, $01
    MOV A, echoFIRtable+Y
    MOV $F3, A
    CLRC
    ADC $01, #$10
    INC Y
    DBNZ $00, SPC_set_echoFIRloop
    RET


echoFIRtable:
    db #$7f, #$00, #$00, #$00, #$00, #$00, #$00, #$00

;   Memory table:
;       Inputs:
;       $00 - Carrier page
;       $01 - Modulator page
;       $02 - Output page
;       $03 - Modulation strength
;       Temp variables:
;       $04-05 - Output index
;       $06-07 - Modulator index
;       $08-09 - Main temp variable
;       $0A- - - Page counter
SPC_PhaseModulation_1KB:
    MOV X, #$00
    MOV $05, $02
    MOV $07, $01
    ADC $02, #$04
    MOV $0A, X
    MOV $04, X
    MOV $06, X
SPC_PhaseModulation_1KB_loop:
    INC $06
    MOV A, ($06+X)
    MOV $09, A
    BBS7 $09, SPC_PhaseModulation_1KB_loop_negative 
    MOV Y, $03      ;Mod strength
    MUL YA
    MOVW $08, YA

    DEC $06
    MOV A, ($06+X)
    MOV Y, $03      ;Mod strength
    MUL YA
    MOV A, Y
    CLRC
    ADC A, $08
    ADC $09, #$00
    JMP SPC_PhaseModulation_1KB_loop_afterMul
SPC_PhaseModulation_1KB_loop_negative:
    EOR A, #$FF
    MOV Y, $03      ;Mod strength
    MUL YA
    MOVW $08, YA

    DEC $06
    MOV A, ($06+X)
    EOR A, #$FF
    MOV Y, $03      ;Mod strength
    MUL YA
    MOV A, Y
    CLRC
    ADC A, $08
    ADC $09, #$00
    EOR A, #$FF
    EOR $09, #$FF
SPC_PhaseModulation_1KB_loop_afterMul:

    ROR $09
    ROR A
    ROR $09
    ROR A
    ROR $09
    ROR A
    AND A, #$FE
    CLRC
    ADC A, $04 

    ADC $09, $0A
    AND $09, #$03
    ADC $09, $00
    MOV $08, A
    MOV Y, #$00
    MOV A, ($08)+Y
    MOV ($04)+Y, A
    INC Y
    MOV A, ($08)+Y
    MOV ($04)+Y, A
    INC $04
    INC $04
    INC $06
    INC $06
    MOV A, $04
    BNE SPC_PhaseModulation_1KB_loop
    INC $0A
    INC $05
    INC $07
    MOV A, $05
    CBNE $02, SPC_PhaseModulation_1KB_loop
    RET

org $0200
    dw $0204, $0204+9+9
    incbin "brrtest.brr"
org $0C00
    incbin "quartersinetable.bin"
startpos init
