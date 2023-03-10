;!!!!NOTES!!!!


;ROM NOTES
;#030000 [#068000] - Palette information
;#032000 [#06A000] - Tile information
;#038000 [#078000] - Tilemap information
;VAR NOTES
;$7FFFFD - Modulation Strength
;RAM Map:
;$0000-000F:    Arguments passed to subroutines
;$0010-001F:    RAM for subroutines, extremely volatile
;$0020:         Program mode:
;                   $00 - Tracker/DAW
;                   $01 - Instrument editor
;                   $02 - Modular synth
;                   $03 - Envelope macro editor
;                   $04 - Arpeggio editor
;                   bit 6 - Tracker (0, instrument list on top side) or DAW (1, instrument list on right side)
;                   bit 7 - resolution (0 = 512x478; 1 = 256x239)
;$0060:         Last message number from first thread
;$0061:         Last message number from second thread
;$0062-0063:    Last word tranferred through the second thread
;$0064:         Instrument page start (*4 in 256x239 mode, *8 in 512x478 mode)
;$00F0-00FE:    Columns list, 00 or length terminated
;$00FF:         [Row tile number, will be obsolete] Base vertical offset in tiles
;$8B00-8BFF:    Instruments' palettes
;$8C00-97FF:    Instruments' names
;$9800-FFFF:    Song data buffer (6 bytes per cell/6*8+4 bytes per row, up to 512 rows can fit before compressing to SRAM)
;SRAM Map:
;$0000 - Locale
;$0100+:        Instrument data
incsrc "header.asm"
incsrc "initSNES.asm"

org $068000
incbin "palette.pal"
org $028000
incbin "tilesetUnicode.chr"
org $06FC00
incbin "sinetable.bin"
org $838000
incsrc "locale.asm"
org $07FFFF ;set size of the file, irrelevant lmao
db $00


;========================
; Start
;========================

org $008129
    LDA #$01            ;   Enable FastROM
    STA $420D           ;__
    lda #$80            ;    Turn on screen, full brightness
    sta $2100           ;__
SPCTransfer:        ;   Kept in SlowROM for compatibility/laziness
    PEA $0000       ;   set dp to 00 since RAM
    PLD				;__

    .LoopConfirm:
        LDA $2140
        CMP #$AA
        BNE SPCTransfer_LoopConfirm
        LDA $2141
        CMP #$BB
        BNE SPCTransfer_LoopConfirm
                        ;__
        LDX #$81E0      ;
        STX $01         ;   Base address: $81E000
        STZ $00         ;__
    .TransferAddress:
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
        LDX $04         ;   If length = 0 it's a jump, therefore end transmission
        BEQ SPCTransfer_Jump;__
        LDA #$CC
        STA $2140
        STA $2141
        INY
    .Loop01:
        LDA $2140
        CMP #$CC
        BNE SPCTransfer_Loop01
        LDY #$0000
        CLC
        LDA $00
        ADC #$04
        STA $00
        LDA $01
        ADC #$00
        STA $01
    .Loop02:
        LDA [$00],Y
        STA $2141
        TYA
        STA $2140
        STA $03
    .Loop03:
        LDA $2140
        CMP $03
        BNE SPCTransfer_Loop03
        INY
        CPY $04
        BNE SPCTransfer_Loop02
        TYA
        CLC
        ADC $00
        STA $00
        LDA $01
        ADC $05
        STA $01
        TYA
        INC A
        INC A
        INC A
        STA $2140
        JMP SPCTransfer_TransferAddress

    .Jump:
        LDA #$00
        STA $2141
        STA $2140
    LDA #$0F
    STA $60
    JML $8081C7 ;81C3-81C6  ;__ Use FastROM for faster execution
org $8081C7         ;Here purely for not causing errors purpose
dmaToCGRAM:
    
    PEA $4300
    PLD				;set dp to 43
    REP #%00010000	;set xy to 16bit
    SEP #%00100000 	;set a to 8bit
    LDA #$00		;Address to write to in CGRAM
    STA $2121		;Write it to tell Snes that
    LDA #$22		;CGRAM Write register
    STA $01			;DMA 0 B Address
    LDA #$86		;Bank of palette
    STA $04			;DMA 0 A Bank
    LDX #$8000		;Address of palette
    STX $02			;DMA 0 A Offset
    LDX #$0200		;Amount of data
    STX $05			;DMA 0 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (000 = 1 byte, write once)
    STA $00
    LDA #%00000001	;bit 2 corresponds to channel 0
    STA $420B		;Init
EmptyPlotData:
    LDX #$1000		;Address to write to in VRAM
    STX $2116		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA $11			;DMA 1 B Address
    LDA #$86		;Bank of tileset
    STA $14			;DMA 1 A Bank
    LDX #$A0C0		;Address of tiles
    STX $12			;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX $15			;DMA 1 Number of bytes
    LDA #%00001001	;Settings d--uummm (Direction (0 = A to B) Update (01 = don't) Mode (001 = 2 bytes, write once)
    STA $10
    LDA #%00000010  ;bit 1 corresponds to channel 1
    STA $420B		;Init
ReadLocale:
    PEA $0000
    PLD				;set dp to 00
    REP #%00100000  ;   Set A to 16 bit
    SEP #%00010000  ;__ Set XY to 8 bit
    LDA #$BA55
    STA $F00001
    LDA $F00000     ;   Load locale
    AND #$007F      ;__
    CMP #$0004      ;
    BMI +           ;   Default to English if locale number is invalid
        LDA #$0000  ;__
    +:
    ASL
    ASL
    ORA #$8380
    STA $15
UnicodeToVRAM:
    SEP #%00100000  ;__ Set A to 8 bit
    STZ $14
    LDY #$00
    -:
        LDA [$14], Y
        STA $00
        STY $01
        JSR DecompressUnicodeBlock
        INY
        CPY #$04
        BNE -

TurnOnScreen:
    JSR InitiateTrackerMode
forever:
    WAI
    REP #%00010000 ;set XY to 16bit
    SEP #%00100000 ;set A to 8bit
    LDA $0060
    CMP #$0E
    BEQ +
    LDA $2140
    CMP #$89
    BNE +
    LDA $2141
    CMP #$AB
    BNE +
    LDA $2142
    CMP #$CD
    BNE +
    LDA $2143
    CMP #$EF
    BNE +
    LDA #$0E
    STA $60
+:
    LDA #$00
    PEA $0000
    PLD				;set dp to 00
    JSL clearPaletteData
    JSL PhaseModulation
    SEP #%00100000 ;A 8-bit
    lda $60            ; = 00001111
    sta $2100           ; Turn on screen, full or quarter brightness
    JMP forever
NMI_Routine:
    JML $800000|NMI_Routine_InFastROM         ;Take advantage of FastROM
.InFastROM:
REP #%00010000 ;set XY to 16bit
SEP #%00100000 ;set A to 8bit
    lda #$0F             ; = 00001111
    sta $2100           ; Turn on screen, full brightness

incsrc "controllerRoutine.asm"

REP #%00010000 ;set XY to 16bit
SEP #%00100000 ;set A to 8bit

    LDA $FF
    DEC A
    DEC A
    ASL A
    ASL A
    ASL A
    STA $1F
    LDA #$00
    ROL A
    STA $1E
    LDA $1F
    STA $210E
    LDA $1E
    STA $210E
    LDA $1F
    STA $2110
    LDA $1E
    STA $2110

lda #$0F            ; = 00001111
sta $2100           ; Turn on screen, full brightness





PLP
PLA
RTI 

InitiateTrackerMode:
    lda #$80            ;   F-Blank 
    sta $2100           ;__
    REP #%00010000      ;   Set XY to 16 bit
    SEP #%00100000      ;__ Set A to 8 bit
    PEA $2100           ;   Set Direct Page to 2100
    PLD				    ;__ For PPU registers
    lda #%00000001      ;   Enable Auto Joypad Read
    sta $4200           ;__
    LDA #%10000000
    BIT $00FF
    LDA #%00000101	    ;   8x16 tile size on both BGs, Mode 5
    STA $05             ;__
    LDA #%00000011      ;
    STA $2C             ;   Enable both BGs on both screens
    STA $2D             ;__
    LDA #%01110010      ;   32x64 tilemap size, 
    STA $07             ;__ at word address $7000 for BG1
    ORA #%00001000      ;   32x64 tilemap size, 
    STA $08             ;__ at word address $7800 for BG2
    LDA #$03|$04        ;   Enable Interlace and Overscan
    STA $33             ;__
    LDA #$40            ;   BG1's tileset is at word address $0000,
    STA $0B             ;__ BG2's tileset is at word address $4000
    STZ $0D             ;
    STZ $0D             ;
    STZ $0E             ;
    STZ $0E             ;   Reset scroll positions
    STZ $0F             ;
    STZ $0F             ;
    STZ $10             ;
    STZ $10             ;__
    PEA $0000           ;   Set Direct Page to 0000 for RAM
    PLD				    ;__
    LDA #$04            ;
    STA $F0             ;
    LDA #$06            ;
    STA $F1             ;
    LDA #$18            ;   Draw some example columns
    STA $F2             ;
    LDA #$19            ;
    STA $F3             ;__
    LDA #$38            ;
    STA $FF             ;   Base location: 00
    STA $00             ;__
    LDA #$1B
    LDA #$00
    JSR ClearInstrumentBuffer
    JSR DrawHeaderTrackerMode
    JSL tableROMtoWRAM
    JSL clearPaletteData
    JSL PhaseModulation
    JSL PlotGraph
    SEP #%00100000 ;A 8-bit
    lda #$0F            ;   Turn on screen, full brightness
    sta $2100           ;__
    lda #%10000001      ;   Enable NMI and Auto Joypad Read
    sta $4200           ;__
    STZ $2115           ;__ Make the PPU bus normal

    RTS

DrawColumn:
    .Setup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        PEA $2100       ;   Set Direct Page to $2100 
        PLD             ;__ because PPU registers
        REP #%00100000  ;   Set A to 16 bit
        SEP #%00010000  ;__ Set XY to 8 bit
        LDX #%10000001  ;   Increment by 32
        STX $15         ;__
        LDX #$00
    .Loop:
        LDA $00F0, X    ;   Get column value, 
        AND #$00FF      ;   end if 0
        BNE +           ;__
            JMP DrawColumn_End
        +   LSR A       ;
        BCC +           ;   Choose BG1 or BG2 tilemap
            ORA #$0800  ;__
        +:              ;
        ORA #$7000      ;   Write the address
        STA $0010       ;
        LDA $00FF       ;
        AND #$003F      ;
        STA $0012       ;
        ASL A           ;
        ASL A           ;
        ASL A           ;
        ASL A           ;
        ASL A           ;
        ADC #$0100      ;
        AND #$07FF      ;
        ORA $0010       ;
        STA $16         ;__
        STA $0014
    .NormalFirst4:
        LDA #$000E
        STA $18
        LDA #$000C
        STA $18
        STA $18
        LDA #$000A
        STA $18
    .BeforeLiteLoop:
        LDY #$00
        LDA #$0034
        SEC
        SBC $0012
        BEQ +
        STA $0010
        LDA #$000C
    .Lite:
        STA $18
        INY
        CPY $0010
        BNE .Lite
    +   LDA $0014
        AND #$781F
        STA $16
        LDA #$000C
        CPY #$34
        BEQ .Skip
    .Lite2:
        STA $18
        INY
        CPY #$34
        BNE .Lite2
    .Skip:
        INX
        CPX #$0F
        BEQ DrawColumn_End
        JMP DrawColumn_Loop
    .End:
        LDX #%10000000  ;   Increment by 1
        STX $15         ;__
        PLP
        PLD
        PLB
        RTS
DrawHeaderTrackerMode:
    .InstrumentListSetup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        REP #%00100000  ;   Set A to 16 bit
        SEP #%00010000  ;__ Set XY to 8 bit
        PEA $0000       ;   set DP to 00
        PLD				;__
        LDX #$80        ;
        PHX             ;   Set DB to 80 (With CPU registers)
        PLB             ;__
        LDX $64         ;
        STX $4202       ;   Set up multiplication for pointer
        LDX #$30        ;
        STX $4203       ;__
        NOP             ;   The multiplication takes 8 cycles - 2 cycles (because the page is guaranteed to be #$3F maximum) = 6 cycles
        LDA $004216     ;__ NOP takes 2 cycles, and the LDA takes 4 cycles to read the opcode & parameters = 6 cycles
        LDX #$7E        ;
        PHX             ;   Set DB to 7E (RAM bank 0)
        PLB             ;__
        ASL             ;
        ADC #$8C00      ;   Make it an actual pointer
        STA $12         ;__
        LDA $64         ;
        ASL             ;
        ASL             ;   
        ASL             ;
        AND #$00F8      ;
        STA $14         ;__
        LDY #$00        ;
        STZ $15
    .BigLoop:
        ;TODO: Palette from palette buffer
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0100, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0300, Y
        INY
        INY
        LDA #$0074
        STA $0100, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0300, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0100, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0300, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 2
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0140, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0340, Y
        INY
        INY
        LDA #$0074
        STA $0140, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0340, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0140, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0340, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 3
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0180, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0380, Y
        INY
        INY
        LDA #$0074
        STA $0180, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0380, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0180, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0380, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 4
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $01C0, Y
        LDA $10
        XBA
        AND #$00FF
        STA $03C0, Y
        INY
        INY
        LDA #$0074
        STA $01C0, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $03C0, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $01C0, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $03C0, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 5
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0200, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0400, Y
        INY
        INY
        LDA #$0074
        STA $0200, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0400, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0200, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0400, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 6
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0240, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0440, Y
        INY
        INY
        LDA #$0074
        STA $0240, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0440, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0240, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0440, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 7
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $0280, Y
        LDA $10
        XBA
        AND #$00FF
        STA $0480, Y
        INY
        INY
        LDA #$0074
        STA $0280, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0480, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $0280, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $0480, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 8
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $10
        AND #$00FF
        STA $02C0, Y
        LDA $10
        XBA
        AND #$00FF
        STA $04C0, Y
        INY
        INY
        LDA #$0074
        STA $02C0, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            STA $04C0, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            STA $02C0, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        STA $04C0, Y
        TYA
        INY
        INY
        INC $14
        INC $15
        LDA $15
        AND #$0003
        BEQ DrawHeaderTrackerMode_DMAs
        JMP DrawHeaderTrackerMode_BigLoop
    .DMAs:
        LDX #$80        ;
        PHX             ;   Set DB to 80 (With PPU registers)
        PLB             ;__
        LDA $FF		    ;
        AND #$003F      ;
        STA $12         ;
        XBA             ;
        LSR             ;   Address to write to in VRAM
        LSR             ;
        LSR             ;
        ORA #$7000      ;
        PHA             ;
        STA $2116		;__
        PEA $4300       ;   Set DP to 43 because DMA
        PLD				;__
        LDX #$18		;VRAM Write register
        STX $11			;DMA 2 B Address
        LDX #$7E		;Bank of tilemap
        STX $14			;DMA 2 A Bank
        LDA #$0100		;Address of tilemap
        STA $12			;DMA 2 A Offset
        LDX #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STX $10
        LDY $00FF
        CPY #$39
        BMI +
        ;Split DMAs
        LDA #$0040      ;
        SEC             ;
        SBC $0012       ;
        XBA             ;   Amount of data before hitting end of tilemap
        LSR             ;
        LSR             ;
        STA $15         ;__
        LDX #%00000010  ;   Init
        STX $420B       ;__
        PHA             ;
        LDA #$7000      ;   Address in VRAM (beginning of BG1's tilemap)
        STA $2116       ;__
        LDA $0012       ;
        SEC             ;
        SBC #$0038      ;
        XBA             ;
        LSR             ;   Amount of data after hit end of tilemap
        LSR             ;
        STA $15         ;
        STA $0014       ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX $420B		;__
        PLA             ;   Amount of data before hitting end of tilemap
        STA $15         ;__
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA $2116		;__
        LDX #%00000010	;   Init DMA on channel 1
        STX $420B		;__
        LDA #$7800      ;   Address in VRAM (beginning of BG2's tilemap)
        STA $2116	    ;__
        LDA $0014       ;   Amount of data after hit end of tilemap
        STA $15         ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX $420B		;__
        JMP DrawHeaderTrackerMode_DrawRow

        +   LDA #$0200		;Amount of data
        STA $15			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX $420B		;Init
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA $2116		;__
        LDA #$0200		;Amount of data
        STA $15			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX $420B		;Init
    .DrawRow:
        PEA $2100       ;   Set Direct Page to $2100 
        PLD             ;__ because PPU registers
        LDA $00FF       ;
        AND #$00FF      ;
        ASL A           ;
        ASL A           ;
        ASL A           ;   Get new row address 
        ASL A           ;
        ASL A           ;
        ADC #$0100      ;
        AND #$07FF      ;
        STA $0010       ;
        ORA #$7000      ;__
        STA $16         ;
        LDX #$00        ;
        LDA #$0008      ;
        -:                  ;   Draw the new row on BG1
            STA $18         ;
            INX             ;
            CPX #$20        ;
            BNE -           ;__
        LDA #$0040
        -:                  ;   Draw the new rows on BG1
            STA $18         ;
            INX             ;
            CPX #$60        ;
            BNE -           ;__
        LDA #$0008
        -:                  ;   Draw the new row on BG1
            STA $18         ;
            INX             ;
            CPX #$80        ;
            BNE -           ;__
        LDX #$00        ;
        LDA $0010       ;
        ORA #$7800      ;
        STA $16         ;
        LDA #$0008      ;
        -:                  ;   Draw the new row on BG2
            STA $18         ;
            INX             ;
            CPX #$20        ;
            BNE -           ;__
        LDA #$0040
        -:                  ;   Draw the new rows on BG2
            STA $18         ;
            INX             ;
            CPX #$60        ;
            BNE -           ;__
        LDA #$0008
        -:                  ;   Draw the new row on BG2
            STA $18         ;
            INX             ;
            CPX #$80        ;
            BNE -           ;__
    JSR DrawColumn
    PLP
    PLD
    PLB
    RTS

HexToTiles:
    ;Memory allocation:
        ;Inputs:
        ;$0000 - The hex number to convert to tiles
        ;Outputs:
        ;$0010 - The low byte of tile data to shove into VRAM (low nybble)
        ;$0011 - The low byte of tile data to shove into VRAM (high nybble)
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    SEP #%00110000  ;   Set XY and A to 8 bit
    PEA $0000       ;
    PLD				;set dp to 00
    LDA $00
    AND #$0F
    CMP #$0A
    BMI +
        CLC
        ADC #$07
    +   CLC
    ADC #$30
    ASL A
    STA $11
    LDA $00

    AND #$F0
    LSR
    LSR
    LSR
    CMP #$14
    BMI +
        CLC
        ADC #$0E
    +   CLC
    ADC #$60
    STA $10
    PLP
    PLD
    PLB
    RTS

UpdateColumn:
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    PEA $2100       ;   Set Direct Page to $2100 
    PLD             ;__ because PPU registers
    REP #%00100000  ;   Set XY to 8 bit
    SEP #%00010000  ;__ Set A to 16 bit
    LDA $00FF       ;
    ASL A           ;
    ASL A           ;
    ASL A           ;   Get old row address 
    ASL A           ;
    ASL A           ;
    STA $0010       ;__
    LDX #$00
.EraseLoop:
    LDA $00F0, X    ;   Get column value, 
    AND #$00FF      ;   end if 0
    BEQ UpdateColumn_ReplacePrep;__ 
    LSR A           ;
    BCC +           ;   Choose BG1 or BG2 tilemap
    ORA #$0800      ;__
+   ORA $0010       ;
    ORA #$7000      ;   Write the address
    STA $16         ;__
    LDA #$000C      ;
    STA $18         ;
    INX             ;
    CPX #$0F        ;
    BNE UpdateColumn_EraseLoop
.ReplacePrep:
    LDA $0000       ;
    STA $00FF       ;
    ASL A           ;
    ASL A           ;
    ASL A           ;   Get new row address 
    ASL A           ;
    ASL A           ;
    STA $0010       ;__
    LDX #$00
.ReplaceLoop:
    LDA $00F0, X    ;   Get column value, 
    AND #$00FF      ;   end if 0
    BEQ UpdateColumn_End;__ 
    LSR A           ;
    BCC +           ;   Choose BG1 or BG2 tilemap
    ORA #$0800      ;__
+   ORA $0010       ;
    ORA #$7000      ;   Write the address
    STA $16         ;__
    LDA #$000A      ;
    STA $18         ;
    INX             ;
    CPX #$0F        ;
    BNE UpdateColumn_ReplaceLoop
.End:
    PLP
    PLD
    PLB
    RTS

UpdateRow:
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    PEA $2100       ;   Set Direct Page to $2100 
    PLD             ;__ because PPU registers
    REP #%00100000  ;   Set A to 16 bit
    SEP #%00010000  ;__ Set XY to 8 bit
    LDA $00FF       ;
    AND #$00FF      ;
    ASL A           ;
    ASL A           ;
    ASL A           ;   Get old row address 
    ASL A           ;
    ASL A           ;
    STA $0010       ;
    ORA #$7000      ;__
    STA $16         ;
    LDX #$00        ;
    LDA #$0000      ;
-:                  ;   Erase the old row on BG1
    STA $18         ;
    INX             ;
    CPX #$20        ;
    BNE -           ;__
    LDX #$00        ;
    LDA $0010       ;
    ORA #$7800      ;
    STA $16         ;
    LDA #$0000      ;
-:                  ;   Erase the old row on BG2
    STA $18         ;
    INX             ;
    CPX #$20        ;
    BNE -           ;__
.DrawNewRow:
    LDA $0000       ;
    AND #$00FF      ;
    ASL A           ;
    ASL A           ;
    ASL A           ;   Get new row address 
    ASL A           ;
    ASL A           ;
    STA $0010       ;
    ORA #$7000      ;__
    STA $16         ;
    LDX #$00        ;
    LDA #$0008      ;
-:                  ;   Draw the new row on BG1
    STA $18         ;
    INX             ;
    CPX #$20        ;
    BNE -           ;__
    LDX #$00        ;
    LDA $0010       ;
    ORA #$7800      ;
    STA $16         ;
    LDA #$0008      ;
-:                  ;   Draw the new row on BG2
    STA $18         ;
    INX             ;
    CPX #$20        ;
    BNE -           ;__


    PLP
    PLD
    PLB
    RTS
DecompressUnicodeBlock:
    ;Memory allocation:
        ;$00 - Unicode block to use
        ;$01 - VRAM block to write to - 0..3
        ;$10-$11 - Temp pointer
    .2BPP:
        PHA             ;
        PHX             ;
        PHY             ;
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        PEA $0000       ;   Set Direct Page to 0
        PLD             ;__
        PEA $8282       ;
        PLB             ;   Set Data Bank to 82
        PLB             ;__
        REP #%00110000  ;__ Set XY, A to 16 bit
        LDA $00         ;
        ASL A           ;
        ASL A           ;
        ASL A           ;   Set up the source pointer
        AND #$00FF      ;
        ORA #$0080      ;
        XBA             ;
        STA $10         ;__
        LDY #$0000
        LDX #$0000
    -:
        LDA ($10), Y    ;
        STA $0110, X    ;   Line 1/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0112, X    ;   Line 2/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0114, X    ;   Line 3/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0116, X    ;   Line 4/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0118, X    ;   Line 5/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $011A, X    ;   Line 6/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $011C, X    ;   Line 7/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $011E, X    ;   Line 8/8 of tile
        INY             ;
        INY             ;__
        TXA             ;
        CLC             ;
        ADC #$0020      ;   Update tile pointer
        TAX             ;
        CMP #$1000      ;__
        BNE -
    ;DMA TRANSFER 0: 2BPP
        PEA $4300       ;
        PLD				;set dp to 43
        SEP #%00100000 	;set a to 8bit
        LDA $0001
        ASL A
        ASL A    
        ASL A
        AND #$18
        ORA #$40
        STA $0013
        STZ $0012
        LDX $0012		;Address to write to in VRAM
        STX $2116		;Write it to tell Snes that
        LDA #$18		;VRAM Write register
        STA $11			;DMA 1 B Address
        LDX #$7E01		;Address of tileset
        STX $13			;DMA 1 A Bank
        STZ $12
        LDX #$1000		;Amount of data
        STX $15			;DMA 1 Number of bytes
        LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STA $10
        LDA #%00000010	;bit 1 corresponds to channel 1
        STA $420B		;Init
        PEA $0000       ;   Set Direct Page to 0
        PLD             ;__
    .4bpp:
        STZ $001F
        REP #%00110000  ;__ Set XY, A to 16 bit
        LDX #$0000
        -:
            STZ $0100, X    ;
            INX             ;   Clear graphics buffer
            CPX #$1000      ;
            BNE -           ;
        LDA $00         ;
        ASL A           ;
        ASL A           ;
        ASL A           ;   Set up the source pointer
        AND #$00FF      ;
        ORA #$0080      ;
        XBA             ;
        STA $10         ;__
        LDY #$0000
        LDX #$0000
    -:
        LDA ($10), Y    ;
        STA $0100, X    ;   Line 1/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0102, X    ;   Line 2/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0104, X    ;   Line 3/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0106, X    ;   Line 4/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $0108, X    ;   Line 5/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $010A, X    ;   Line 6/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $010C, X    ;   Line 7/8 of tile
        INY             ;
        INY             ;__
        LDA ($10), Y    ;
        STA $010E, X    ;   Line 8/8 of tile
        INY             ;
        INY             ;__
        TXA             ;
        CLC             ;
        ADC #$0040      ;   Update tile pointer
        TAX             ;
        CMP #$1000      ;__
        BNE -
        PHY
    ;4BPP DMA TRANSFERS
        PEA $4300       ;
        PLD				;set dp to 43
        SEP #%00100000 	;set a to 8bit
        LDA $0001
        ASL A
        ORA $001F
        ASL A    
        ASL A
        ASL A
        AND #$38
        STA $0013
        STZ $0012
        LDX $0012		;Address to write to in VRAM
        STX $2116		;Write it to tell Snes that
        LDA #$18		;VRAM Write register
        STA $11			;DMA 1 B Address
        LDX #$7E01		;Address of tileset
        STX $13			;DMA 1 A Bank
        STZ $12
        LDX #$1000		;Amount of data
        STX $15			;DMA 1 Number of bytes
        LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STA $10
        LDA #%00000010	;bit 1 corresponds to channel 1
        STA $420B		;Init

        INC $001F
        LDA $001F
        BIT #$01
        BEQ +
            PEA $0000       ;   Set Direct Page to 0
            PLD             ;__
            REP #%00110000  ;__ Set XY, A to 16 bit
            PLY
            LDX #$0000
            JMP -
        +:
        PEA $0000       ;   Set Direct Page to 0
        PLD             ;__
        REP #%00110000  ;__ Set XY, A to 16 bit
        LDX #$0000      ;
        --:             ;
            STZ $0100, X    ;   Clear the graphics buffer
            INX             ;
            CPX #$1000      ;
            BNE --          ;__
    PLY
    PLP
    PLD
    PLB
    PLY
    PLX
    PLA
    RTS

ClearInstrumentBuffer:
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    REP #%00100000  ;   Set A to 16 bit
    SEP #%00010000  ;__ Set XY to 8 bit
    PEA $4300       ;
    PLD				;set dp to 43
    LDX #$80		;WRAM Write register
    STX $11			;DMA 1 B Address
    STZ $12
    LDA #$8280		;Address of tileset
    STA $13			;DMA 1 A Bank
    LDA #$0100		;Amount of data
    STA $15			;DMA 1 Number of bytes
    LDX #%00001000	;Settings d--uummm (Direction (0 = A to B) Update (01 = do nothing) Mode (000 = 1 byte, write once)
    STX $10
    STZ $2181
    STZ $2183
    LDX #$8B
    STX $2182
    LDX #%00000010	;bit 1 corresponds to channel 1
    STX $420B		;Init

    LDX.b #(ClearInstrumentBuffer_EmptyTile&$0000FF)
    STX $12
    LDA.w #(ClearInstrumentBuffer_EmptyTile&$FFFF00)>>8		;Address of tile
    STA $13			;DMA 1 A Bank
    LDA #$0C00		;Amount of data
    STA $15			;DMA 1 Number of bytes
    LDX #%00001000	;Settings d--uummm (Direction (0 = A to B) Update (01 = do nothing) Mode (000 = 1 byte, write once)
    STX $10
    LDX #%00000010	;bit 1 corresponds to channel 1
    STX $420B		;Init
    PLP
    PLD
    PLB
    RTS
.EmptyTile:
db $20
org $818000 ;The plotting engine for now
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
PlotGraph:
    .Decompress
        REP #%00010000 ;set xy to 16bit
        SEP #%00100000 ;set a to 8bit
        PEA $0000
        PLD				;set db to 7f
        LDA #$7F
        PHA
        PLB
        LDX #$00FF
        LDY #$003F
        ..Loop:
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
            BPL PlotGraph_Decompress_Loop
    .InWRAM:
        REP #%00110000 ;set xy and a to 16bit
        LDA #$01C0
        LDY #$0000
        ..Loop:
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
                BMI PlotGraph_DMA
                JMP PlotGraph_InWRAM_Loop
    .DMA:
        REP #%00010000 ;set xy to 16bit
        SEP #%00100000 ;set a to 8bit
        PEA $4300
        PLD	;set dp to 43
        LDA #$00
        PHA
        PLB
        lda #$80            ; = 10000000
        sta $2100           ; F-Blank
        LDX #$1000		;Address to write to in VRAM
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
    RTL

PhaseModulation:
    ;Input: Carrier wavetable at $7F0800, $0400 bytes long
    ;Input: Modulator wavetable at $7F0C00, $0400 bytes long
    ;Output: Modulated Wavetable at $7F0000, $0400 bytes long
    .RoutineSelect:
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
        BPL PhaseModulation_Divider10
    .Divider20:
        LDA #$3C
        STA $000011
        LDA #$3A
        STA $000012
        REP #%00110000 ;set a to 16bit
        ..Loop:
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
            BPL PhaseModulation_Divider20_Loop ;2
        JMP PhaseModulation_End

    .Divider10:
        SEC
        SBC #$40
        BPL PhaseModulation_Divider08
        LDA $FFFD
        SEC
        SBC #$40
        STA $FFFD
        LDA #$3B
        STA $000011
        LDA #$3A
        STA $000012
        REP #%00110000 ;set a to 16bit
        ..Loop:
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
            BPL PhaseModulation_Divider10_Loop ;2
        JMP PhaseModulation_End

    .Divider08:
        LDA $FFFD
        SEC
        SBC #$80
        STA $FFFD
        LDA #$3A
        STA $000011
        LDA #$3E
        STA $000012
        REP #%00110000 ;set a to 16bit
        ..Loop:
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
            BPL PhaseModulation_Divider08_Loop ;2

    .End:
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

org $81E000
arch spc700-inline
incsrc "SNESFM.asm"