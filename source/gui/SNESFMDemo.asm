;ROM Memory allocation:
;Bank 0 - most code
;Bank 1 - some code + SPC700 everything
;Bank 2 - Unicode tileset
;Bank 3 - Locales
;Bank 4 - 
;Bank 5 -
;Bank 6 - Palette, 65816 sine table
;VAR NOTES
;$7FFFFD - Modulation Strength
;RAM Map:
;$0000-000F:    Arguments passed to subroutines
;$0010-001F:    RAM for subroutines, extremely volatile
;$0020:         Program mode:
;                   $00 - Tracker/DAW ($10 - compact mode)
;                   $01 - Instrument editor
;                   $02 - Modular synth
;                   $03 - Envelope macro editor
;                   $04 - Arpeggio editor
;                   bits 4-5 - unique to mode flags
;                   bit 6 - Tracker (0, instrument list on top side) or DAW (1, instrument list on right side)
;                   bit 7 - resolution (0 = 512x478; 1 = 256x239)
;$0060:         Last message number from first thread
;$0061:         Last message number from second thread
;$0062-0063:    Last word tranferred through the second thread
;$0064:         Instrument page start (*4 in 256x239 mode, *8 in 512x478 mode)
;$00E0-00EF:    States of write-only registers:
;                   $00E0 - $4200   (Interrupts enable)
;                   $00E1 - $420C   (HDMA enable)
;$00F0:         Tracker horizontal scroll position (in blocks, not pixels/tiles)
;$00F1-00F2:    Pattern row (9-bit)
;$00F4-00FD:    HDMA table of horizontal scroll position:
;                   $00F5-00F6: Horizontal scroll position for header
;                   $00F8-00F9: Horizontal scroll position for 1 tile where octave is
;                   $00FB-00FC: Horizontal scroll position for everything else
;$00FE:         Base horizontal offset in tiles
;$00FF:         Base vertical offset in tiles
;$9800-FFFF:    Song data buffer: (6 bytes per cell/6*8+4 bytes per row, up to 512 rows can fit before compressing to SRAM)
;                   $9800-99FF: Global speed
;                   $9A00-9BFF: Effect amount
;                   $9C00-9DFF: Effect pointer (low byte)
;                   $9E00-9FFF: Effect pointer (high byte)
;                   $A000-A1FF: Note number (channel 1)
;                   $A200-A3FF: Note number (channel 2)
;                   $A400-A5FF: Note number (channel 3)
;                   $A600-A7FF: Note number (channel 4)
;                   $A800-A9FF: Note number (channel 5)
;                   $AA00-ABFF: Note number (channel 6)
;                   $AC00-ADFF: Note number (channel 7)
;                   $AE00-AFFF: Note number (channel 8)
;                   $B000-BFFF: Instrument number (channels 1-8 in the same fashion)
;                   $C000-CFFF: Effect amount (channels 1-8)
;                   $D000-DFFF: Effect shown (channels 1-8)
;                   $E000-EFFF: Effect pointer (low byte) (channels 1-8)
;                   $F000-FFFF: Effect pointer (high byte) (channels 1-8)
;SRAM Map:
;$0000-0003:    Verification code "SNES" ($53 $4E $45 $53)
;$0004:         Major SRAM format revision
;$0005:         Last mode used
;$0006:         Locale
;$00FE-00FF:    Second verification code BASS ($BA $55)
;$0200-027F:    Instruments' palettes
;$0280-03FF:    Instruments' names (high bits)
;$0400-0FFF:    Instruments' names

;Tracker interface (512x478):
;channel:     --   |    0    |    1    |    2    |    3    |    4    | 5|
;layout: RRR|SS EEE|nn ii eee|nn ii eee|nn ii eee|nn ii eee|nn ii eee|nn 
;block:      00  01 02 03  04 05 06  07 08 09  0A 0B 0C  0D 0E 0F  10 11
;block%3:     0  1   2  0  1   2  0  1   2  0   1  2  0   1  2  0  1   2
;center of screen:                      --
;block%3:     2  0  1   2  0  1   2  0   1  2  0   1  2  0   1  2  0   1
;block:      08 09  0A 0B 0C  0D 0E 0F  10 11 12  13 14 15  16 17 18  19
;layout: RRR|nn ii eee|nn ii eee|nn ii eee|nn ii eee|nn ii eee|nn ii eee|
;channel: --|    2    |    3    |    4    |    5    |    6    |    7    |

;Tracker interface (256x239): (tis gon be trouble)
;channel:     --   |    0    |    1    |2
;layout: RRR|SS EEE|nn ii eee|nn ii eee|n
;block:      00  01 02 03  04 05 06  07 8
;block%3:     0  1   2  0  1   2  0  1  2
;center of screen:    --
;block%3:      0  1   2  0  1   2  0   1
;block:       12  13 14 15  16 17 18  19
;layout: RRR| ii eee|nn ii eee|nn ii eee|
;channel:   |  5    |    6    |    7    |

;Tracker interface (compact mode, 512x478):
;channel:|     --     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
;layout: |||RRR|SS EEE|nn ii|nn ii|nn ii|nn ii|nn ii|nn ii|nn ii|nn ii|||
;block:         00 01  02 03 05 06 08 09 0B 0C 0E 0F 11 12 14 15 17 18
;center of screen:                      --

;Tracker interface (compact mode, 256x239):
;channel:|  --- | 0| 1| 2| 3| 4| 5| 6| 7|
;layout: |RRR|SS|nn|nn|nn|nn|nn|nn|nn|nn|
;block:       00 02 05 08 0B 0E 11 14 17
;center of screen:    --

macro SetDP_PEA(dp)
    PEA <dp>
    PLD
    dpbase <dp>
endmacro

macro SetDP_TCD(dp)
    LDA <dp>
    TCD
    dpbase <dp>
endmacro

macro SetDP_PPU_PEA()
	%SetDP_PEA($2100)
endmacro

macro SetDP_DMA_PEA()
	%SetDP_PEA($4300)
endmacro

macro ResetDP_PEA()
	%SetDP_PEA($0000)
endmacro

optimize dp always
optimize address mirrors

!SRAM_VERSION_MAJOR = #$00

!P_A = #%00100000
!P_XY = #%00010000

MESSAGE_CNT_TH1 = $60
MESSAGE_CNT_TH2 = $61

org $068000
incbin "palette.pal"
org $028000
incbin "tilesetUnicode.chr"
org $06FC00
incbin "sinetable.bin"
org $838000
incsrc "locale.asm"

org $81E000
!SNESFM_ASM ?= 0
if !SNESFM_ASM == 1
	incsrc "../sound/demoConfig.asm"
else
	incbin "SNESFM.bin"
endif


InstrumentData:
    incsrc "../sound/instrumentData.asm"
InstrumentData_End:
SongData:
    incsrc "../sound/songData.asm"
SongData_End:

org $07FFFF ;set size of the file, irrelevant lmao

db $00

!INIT_USE_FASTROM = 1

incsrc "header.asm"
incsrc "initSNES.asm"

;========================
; Start
;========================
Start:
    %InitSNES()
    lda #$80            ;    Turn off screen, no brightness
    sta INIDISP           ;__
SPCTransfer:
    .LoopConfirm:
        LDA APUIO0
        CMP #$AA
        BNE SPCTransfer_LoopConfirm
        LDA APUIO1
        CMP #$BB
        BNE SPCTransfer_LoopConfirm
                        ;__
        LDX #$81E0      ;
        STX $01         ;   Base address: $81E000
        STZ $00         ;__
    .TransferAddress:
        LDY #$0002      ;
        LDA [$00],Y     ;
        STA APUIO2      ;
        INY             ;   Give address to SPC
        LDA [$00],Y     ;
        STA APUIO3      ;__
        LDY #$0000      ;
        LDA [$00],Y     ;
        STA $04         ;
        INY             ;   Get the length, put it in $04-$05
        LDA [$00],Y     ;
        STA $05         ;__
        LDX $04         ;   If length = 0 it's a jump, therefore end transmission
        BEQ SPCTransfer_Jump;__
        LDA #$CC
        STA APUIO0
        STA APUIO1
        INY
    .Loop01:
        LDA APUIO0
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
        STA APUIO1
        TYA
        STA APUIO0
        STA $03
    .Loop03:
        LDA APUIO0
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
        STA APUIO0
        JMP SPCTransfer_TransferAddress

    .Jump:
        LDA #$00
        STA APUIO1
        STA APUIO0
    LDA #$0F
    STA $60
org $800000|pc()         ;Here purely for not causing errors purpose
bank $80
dmaToCGRAM:
    
    %SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
    REP !P_XY     	;set xy to 16bit
    SEP !P_A       	;set a to 8bit
    LDA #$00		;Address to write to in CGRAM
    STA CGADD		;Write it to tell Snes that
    LDA #$22		;CGRAM Write register
    STA BBAD0		;DMA 0 B Address
    LDA #$86		;Bank of palette
    STA A1B0		;DMA 0 A Bank
    LDX #$8000		;Address of palette
    STX A1T0L		;DMA 0 A Offset
    LDX #$0200		;Amount of data
    STX DAS0L		;DMA 0 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (000 = 1 byte, write once)
    STA DMAP0
    LDA #%00000001	;bit 2 corresponds to channel 0
    STA MDMAEN		;Init
EmptyPlotData:
    LDX #$1000		;Address to write to in VRAM
    STX VMADDL		;Write it to tell Snes that
    LDA #$18		;VRAM Write register
    STA BBAD1		;DMA 1 B Address
    LDA #$86		;Bank of tileset
    STA A1B1			;DMA 1 A Bank
    LDX #$A0C0		;Address of tiles
    STX A1T1L			;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX DAS1L			;DMA 1 Number of bytes
    LDA #%00001001	;Settings d--uummm (Direction (0 = A to B) Update (01 = don't) Mode (001 = 2 bytes, write once)
    STA DMAP1
    LDA #%00000010  ;bit 1 corresponds to channel 1
    STA MDMAEN		;Init
InitSRAM:
    .CheckSRAM:
        % ResetDP_PEA();   Set DP to $00
        REP !P_A        ;   Set A to 16 bit
        SEP !P_XY       ;__ Set XY to 8 bit
        PEA $00F0       ;   Set DB to $F0 (SRAM first bank)
        PLB             ;__
        ..VerificationCodes:
            LDA $00FE       ;
            CMP #$55BA      ;   Second verification code BASS
            BNE InitSRAM_ClearSRAM;__
            LDA $0000       ;
            CMP #$4E53      ;   First half of first verification code "SN"
            BNE InitSRAM_ClearSRAM;__
            LDA $0002       ;
            CMP #$5345      ;   Second half of first verification code "ES"
            BNE InitSRAM_ClearSRAM;__
        ..VersionNumber:
            LDX $0004         
            CPX !SRAM_VERSION_MAJOR+1
            BCS InitSRAM_ClearSRAM
            JMP ReadLocale



    .ClearSRAM:
        JSR ClearTrackerPattern
        JSR ClearInstrumentBuffer
        LDA #$55BA          ;
        STA $00FE           ;__ Second verification code BASS
        LDA #$4E53          ;
        STA $0000           ;__ First half of first verification code "SN"
        LDA #$5345          ;
        STA $0002           ;__ Second half of first verification code "ES"
        LDX !SRAM_VERSION_MAJOR
        STX $0004

ReadLocale:
    LDA $0006     ;   Load locale
    AND #$007F      ;__
    CMP #$0004      ;
    BMI +           ;   Default to English if locale number is invalid
        LDA #$0000  ;__
        STA $0006
    +:
    PLB             ;__ Set DB to $00
    ASL
    ASL
    ORA #$8380
    STA $15
UnicodeToVRAM:
    SEP !P_A        ;__ Set A to 8 bit
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
    LDA #$FF
    STA $00
    STZ $01
TurnOnScreen:
    JSR InitiateTrackerMode
    SEP !P_A       ;set A to 8bit
    LDA #$00
    % ResetDP_PEA()   ; set dp to 00
    REP !P_XY      ;set XY to 16bit
    LDA #$01
    STA MESSAGE_CNT_TH1
    LDX #InstrumentData&$FFFF
    STX $00
    LDX #(InstrumentData_End-InstrumentData)
    STX $03
    LDA.b #bank(InstrumentData)
    STA $02
    LDA #$40
    JSR SendSongSPC

    JSR WaitMsgBase


    LDX #SongData&$FFFF
    STX $00
    LDX #(SongData_End-SongData)
    STX $03
    LDA.b #bank(SongData)
    STA $02
    LDA #$50
    JSR SendSongSPC


; Send "hey i have song data, ill send it"
SendSongSPC:
    .Start:
        JSR SendMsgBase

    .WaitForAffirmative:
        ; Prepare pointers while waiting anyway:
            LDY #$0000
        JSR WaitMsgBase
        CMP #$10    ; Verify that the response is affirmative:
        BNE SendSongSPC_What
    .SendBytes:
        ; Send 2 bytes of data:
            REP !P_A
            LDA [$00], Y
            STA APUIO2
            SEP !P_A
            INY #2
        ; Finish message:
            LDA #$90
            JSR SendMsgBase
        ; Wait for response
            JSR WaitMsgBase
            CMP #$20
            BEQ +
        ; If bytes not received or whatever, resend them
            DEY #2
            JMP SendSongSPC_SendBytes
        +   ; Compare if Y is finished
            CPY $03
            BPL SendSongSPC_End
            JMP SendSongSPC_SendBytes

    .What:
        LDA #$F0
        JSR SendMsgBase
        JSR WaitMsgBase
        JMP SendSongSPC

    .End:
        LDA #$A0
        JSR SendMsgBase
        RTS

forever:
    WAI
    JMP forever

SendMsgBase:
    STA APUIO1  ; CMD ID in A

    LDA MESSAGE_CNT_TH1
    STA APUIO0
    INC.b MESSAGE_CNT_TH1
    RTS

WaitMsgBase:
        LDA APUIO0
        CMP MESSAGE_CNT_TH1
        BNE WaitMsgBase
    INC.b MESSAGE_CNT_TH1
    LDA APUIO1
    AND #$F0
    RTS

NMI_Routine:
    JML $800000|.InFastROM         ;Take advantage of FastROM
    .InFastROM:
    PHA
    PHX
    PHY
    PHP

    REP !P_XY      ;set XY to 16bit
    SEP !P_A       ;set A to 8bit
    lda #$0F             ; = 00001111
    sta INIDISP           ; Turn on screen, full brightness

    incsrc "controllerRoutine.asm"

    REP !P_XY      ;set XY to 16bit
    SEP !P_A       ;set A to 8bit

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
    STA BG1VOFS
    LDA $1E
    STA BG1VOFS
    LDA $1F
    STA BG2VOFS
    LDA $1E
    STA BG2VOFS

    lda #$0F            ; = 00001111
    sta INIDISP           ; Turn on screen, full brightness

    PLP
    PLY
    PLX
    PLA
    RTI 

InitiateTrackerMode:
    lda #$80            ;   F-Blank 
    sta INIDISP           ;__
    REP !P_XY           ;   Set XY to 16 bit
    SEP !P_A            ;__ Set A to 8 bit
    %SetDP_PPU_PEA()	;__ Set Direct Page to 2100 for PPU registers
    lda #%00000001      ;   Enable Auto Joypad Read
    sta $4200           ;
    STA $00E0           ;__
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
    % ResetDP_PEA()   ;__ Set Direct Page to 0000 for RAM

    .FEByte:
    STZ $FE             ;__
    LDA #$38            ;
    STA $FF             ;   Base location: 00
    STA $00             ;__
    LDA #$1B
    LDA #$00
            ; ;Division test
            ;     SEP #%00110000      ;__ Set A, XY to 8 bit
            ;     PHD
            ;     PEA $4200           ;   Set Direct Page to 4200 for CPU regs
            ;     PLD				    ;__
            ;     LDA #$03
            ;     STA $04
            ;     LDA #$FF
            ;     STA $05
            ;     LDA #$0B
            ;     STA $06
            ; ;Part 1:
            ;     LDA $14     ;
            ;     LDX $14     ;   Get low byte on cycles 2, 5, 8
            ;     LDY $14     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+2*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+2*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+5*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+5*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+8*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+8*12

            ;     LDA #$0B
            ;     STA $06
            ; ;Part 2:
            ;     LDA $4214   ;
            ;     LDX $14     ;   Get low byte on cycles 3, 6, 9
            ;     LDY $14     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+3*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+3*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+6*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+6*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+9*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+9*12

            ;     LDA #$0B
            ;     STA $06
            ; ;Part 3:
            ;     LDA $004214   ;
            ;     LDX $14     ;   Get low byte on cycles 4, 7, 10
            ;     LDY $14     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+4*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+4*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+7*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+7*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C02+10*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C03+10*12


            ;     LDA #$0B
            ;     STA $06
            ; ;Part 1:
            ;     LDA $15     ;
            ;     LDX $15     ;   Get low byte on cycles 2, 5, 8
            ;     LDY $15     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+2*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+2*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+5*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+5*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+8*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+8*12

            ;     LDA #$0B
            ;     STA $06
            ; ;Part 2:
            ;     LDA $4215   ;
            ;     LDX $15     ;   Get low byte on cycles 3, 6, 9
            ;     LDY $15     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+3*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+3*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+6*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+6*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+9*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+9*12

            ;     LDA #$0B
            ;     STA $06
            ; ;Part 3:
            ;     LDA $004215   ;
            ;     LDX $15     ;   Get low byte on cycles 4, 7, 10
            ;     LDY $15     ;__
            ;     STA $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+4*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+4*12

            ;     STX $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+7*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+7*12

            ;     STY $0000
            ;     JSR HexToTiles
            ;     LDA $0010
            ;     LSR
            ;     STA $7E8C00+10*12
            ;     LDA $0011
            ;     LSR
            ;     STA $7E8C01+10*12



            ;     PEA $0000           ;   Set Direct Page to 4200 for CPU regs
            ;     PLD				    ;__
            ;     REP !P_XY           ;   Set XY to 16 bit
    JSR DrawHeaderTrackerMode
    JSL tableROMtoWRAM
    JSL clearPaletteData
    JSL PhaseModulation
    JSL PlotGraph
    SEP !P_A       ;A 8-bit
    lda #$0F            ;   Turn on screen, full brightness
    sta INIDISP           ;__
    lda #%10000001      ;
    sta $4200           ;   Enable NMI and Auto Joypad Read
    STA $E0             ;__
    LDA #$80            ;
    STA VMAIN           ;__ Make the PPU bus normal

    RTS

; DrawTrackerRow:
    ;     ;Memory allocation:
    ;         ;$0000-0001 - Row to draw
    ;     .Setup:
    ;         PHB             ;
    ;         PHD             ;   Back up some registers
    ;         PHP             ;__
    ;         REP !P_A        ;   Set A to 16 bit
    ;         SEP !P_XY       ;__ Set XY to 8 bit
    ;         PEA $0000       ;   Set DP to 00
    ;         PLD				;__
    ;         LDX #$83        ;
    ;         PHX             ;   Set DB to 83, locales in FastROM
    ;         PLB             ;__   

DrawColumn:
    .Setup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        % ResetDP_PEA()	;   Set Direct Page to 00 because RAM
        SEP #%00110000  ;__ Set A, XY to 8 bit
    .GetColumns:
        LDA $FE         ;
        CLC             ;   First column right after
        ADC #$03        ;   row number
        AND #$3F        ;
        STA $10         ;__
        LDA $F0         ;
        STA $4204       ;
        STZ $4205       ;   Get remainder of block number / 3
        LDA #$03        ;
        STA $4206       ;__
        LDA $F0         ;   3 cycles
        CMP #$09        ;   2 cycles    (If scrolled to the far left, skip this shit)
        BCC DrawColumn_GetColumns_FarLeft ;__ 2 cycles if not taken (doesn't matter otherwise as value is overwritten)
        CMP #$10        ;   2 cycles    (If scrolled to the far right, skip this shit)
        BCS DrawColumn_GetColumns_FarRight ;__ 2 cycles if not taken (doesn't matter otherwise as value is overwritten)
        NOP             ;   2 cycles
        LDX $4216       ;__ 3 cycles to read the opcode - total wait time 16 cycles
        JMP +
        ..FarLeft:
            LDX #$00
            JMP +
        ..FarRight:
            CLC
            LDX #$02
        +:
            LDA $10
            ADC DrawColumn_ColumnOffsetTable_Normal_512, X
            AND #$3F
            STA $11
            LDA DrawColumn_ColumnOffsetTable_Normal_512, X
            CLC
            ADC #$03
            TAY
            LDX #$00
            -:
                LDA $11, X
                CLC
                ADC #$0A
                AND #$3F
                STA $12, X
                INX
                TYA
                CLC
                ADC #$0A
                TAY
                CPY #$40
                BCC -
            STZ $12, X

		%SetDP_PPU_PEA()	;__ Set Direct Page to 2100 for PPU registers
        REP !P_A        ;   Set A to 16 bit
        LDX #%10000001  ;   Increment by 32
        STX $15         ;__
        LDX #$00
    .Loop:
        LDA $0010, X    ;   Get column value, 
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
    .ColumnOffsetTable:
        ..Normal_512:
            db $07, $04, $0A
InitiateHScrollHDMA:


    .HDMATable:
        db $41  ;Transfer 1 unit, wait $40 scanlines
        dw InitiateHScrollHDMA_HDMATable_00
        db $01  ;Transfer 1 unit, wait 1 scanline
        dw $00FC;RAM Where the location is stored
        ..00:
        db $00  ;End/low byte of 00
        db $00
ClearTrackerPattern:
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    REP !P_A        ;   Set A to 16 bit
    SEP !P_XY       ;__ Set XY to 8 bit
    .00Byte:
	%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
    PHK             ;   Set DB to 80 (Hardware registers)
    PLB	            ;__
    STZ $2181       ;   Clear lower 8 bits
    LDA #$0098		;   Address of tick speed .. global effects pointers
    STA $2182		;__
    LDX #$80		;   WRAM Write register, Bank of 00
    STX BBAD1		;__ DMA 1 B Address
    STX A1B1			;__ DMA 1 A Bank
    LDA #(ClearTrackerPattern_00Byte+1);   Address of 00
    STA A1T1L			;__ DMA 1 A Offset
    LDA #$0800		;   Amount of data
    STA DAS1L			;__ DMA 1 Number of bytes
    LDX #%00001000	;   Settings d--uummm: (Direction (0 = A to B),
    STX DMAP1       ;   Update (01 = Do nothing), Mode (000 = 1 byte, write once)
    LDX #%00000010  ;   Bit 1 corresponds to channel 1
    STX MDMAEN		;__ Clear global speed and effects

    STZ $2181       ;   Clear lower 8 bits
    LDA #$00B0		;   Address of instruments .. per-channel effects pointers
    STA $2182		;__
    LDA #$5000		;   Amount of data
    STA DAS1L			;__ DMA 1 Number of bytes
    LDX #%00000010  ;   Bit 1 corresponds to channel 1
    STX MDMAEN		;__ Clear instruments and per-channel effects

    LDA #(InitiateTrackerMode_FEByte+1);   Address of FE
    STA A1T1L			;__ DMA 1 A Offset
    STZ $2181       ;   Clear lower 8 bits
    LDA #$00A0		;   Address of notes
    STA $2182		;__
    LDA #$1000		;   Amount of data
    STA DAS1L			;__ DMA 1 Number of bytes
    LDX #%00000010  ;   Bit 1 corresponds to channel 1
    STX MDMAEN		;__ Clear notes
    PLP
    PLD
    PLB
    RTS


ScrollHeaderTrackerMode:
    .Setup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        REP !P_A        ;   Set A to 16 bit
        SEP !P_XY       ;__ Set XY to 8 bit
        % ResetDP_PEA()	;__	set DP to 00
        LDA $FF		    ;
        AND #$003F      ;
        STA $12         ;
        XBA             ;
        LSR             ;   Address to read from in VRAM
        LSR             ;
        LSR             ;
        ORA #$7000      ;
        PHA             ;
        STA VMADDL		;__
        LDA VMDATALREAD       ;__ Dummy read because VRAM is wacky
    .DMAForward:
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        LDX #$39		;VRAM Read register
        STX BBAD1			;DMA 1 B Address
        LDX #$7E		;Bank of tilemap buffer
        STX A1B1			;DMA 1 A Bank
        LDA #$0100		;Address of tilemap buffer
        STA A1T1L			;DMA 1 A Offset
        LDX #%10000001	;Settings d--uummm (Direction (1 = B to A) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STX DMAP1
        LDY $00FF
        CPY #$38
        BMI ScrollHeaderTrackerMode_DMAForward_Normal
        ..Split:
            LDA #$0040      ;
            SEC             ;
            SBC $0012       ;
            XBA             ;   Amount of data before hitting end of tilemap
            LSR             ;
            LSR             ;
            STA DAS1L         ;__
            LDX #%00000010  ;   Init
            STX MDMAEN      ;__
            PHA             ;
            LDA #$7000      ;   Address in VRAM (beginning of BG1's tilemap)
            STA VMADDL       ;__
            LDA VMDATALREAD       ;__ Dummy read because VRAM is wacky
            LDA $0012       ;
            SEC             ;
            SBC #$0037      ;
            XBA             ;
            LSR             ;   Amount of data after hit end of tilemap
            LSR             ;
            STA DAS1L         ;
            STA $0014       ;__
            LDX #%00000010	;   Init DMA on channel 1
            STX MDMAEN		;__
            PLA             ;   Amount of data before hitting end of tilemap
            STA DAS1L         ;__
            PLA             ;
            ORA #$0800      ;   Address in VRAM
            STA VMADDL		;__
            LDA VMDATALREAD       ;__ Dummy read because VRAM is wacky
            LDX #%00000010	;   Init DMA on channel 1
            STX MDMAEN		;__
            LDA #$7800      ;   Address in VRAM (beginning of BG2's tilemap)
            STA VMADDL	    ;__
            LDA VMDATALREAD       ;__ Dummy read because VRAM is wacky
            LDA $0014       ;   Amount of data after hit end of tilemap
            STA DAS1L         ;__
            LDX #%00000010	;   Init DMA on channel 1
            STX MDMAEN		;__
            JMP ScrollHeaderTrackerMode_DMABack
        ..Normal:
            LDA #$0240		;Amount of data
            STA DAS1L			;DMA 2 Number of bytes
            LDX #%00000010	;bit 1 corresponds to channel 1
            STX MDMAEN		;Init
            STA DAS1L			;DMA 2 Number of bytes
            PLA             ;
            ORA #$0800      ;   Address in VRAM
            STA VMADDL		;__
            LDA VMDATALREAD       ;__ Dummy read because VRAM is wacky
            LDX #%00000010	;bit 1 corresponds to channel 1
            STX MDMAEN		;Init
    .DMABack:
        LDX $0000       ;
        STX $00FF       ; 
        LDA $0000		;
        AND #$003F      ;
        STA $0000       ;
        XBA             ;
        LSR             ;   Address to write to in VRAM
        LSR             ;
        LSR             ;
        ORA #$7000      ;
        PHA             ;
        STA VMADDL		;__
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        LDX #$18		;VRAM Write register
        STX BBAD1			;DMA 2 B Address
        LDX #$7E		;Bank of tilemap
        STX A1B1			;DMA 2 A Bank
        LDA #$0100		;Address of tilemap
        STA A1T1L			;DMA 2 A Offset
        LDX #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STX DMAP1
        LDY $00FF
        CPY #$38
        BMI +
        ;Split DMAs
        LDA #$0040      ;
        SEC             ;
        SBC $0000       ;
        XBA             ;   Amount of data before hitting end of tilemap
        LSR             ;
        LSR             ;
        STA DAS1L         ;__
        LDX #%00000010  ;   Init
        STX MDMAEN      ;__
        PHA             ;
        LDA #$7000      ;   Address in VRAM (beginning of BG1's tilemap)
        STA VMADDL       ;__
        LDA $0000       ;
        SEC             ;
        SBC #$0037      ;
        XBA             ;
        LSR             ;   Amount of data after hit end of tilemap
        LSR             ;
        STA DAS1L         ;
        STA $0014       ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        PLA             ;   Amount of data before hitting end of tilemap
        STA DAS1L         ;__
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA VMADDL		;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        LDA #$7800      ;   Address in VRAM (beginning of BG2's tilemap)
        STA VMADDL	    ;__
        LDA $0014       ;   Amount of data after hit end of tilemap
        STA DAS1L         ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        JMP ScrollHeaderTrackerMode_End

        +   LDA #$0240		;Amount of data
        STA DAS1L			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA VMADDL		;__
        LDA #$0240		;Amount of data
        STA DAS1L			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init
    .End:
        PLP
        PLD
        PLB
        RTS
DrawHeaderTrackerMode:
    .InstrumentListSetup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        REP !P_A        ;   Set A to 16 bit
        SEP !P_XY       ;__ Set XY to 8 bit
        % ResetDP_PEA()	;__	set DP to 00
        PEA $F080       ;   Set DB to 80 (With CPU registers)
        PLB             ;__
        LDX $64         ;
        STX $4202       ;   Set up multiplication for pointer
        LDX #$30        ;
        STX $4203       ;__
        PLB             ;   Set DB to F0 (SRAM bank 0)
        LDA $004216     ;__ The multiplication takes 6 cycles but ill wait 8 anyway because the PLB is useful
        ASL             ;
        ADC #$0400      ;   Make it an actual pointer
        STA $12         ;__
        LDA $64         ;
        ASL             ;
        ASL             ;   
        ASL             ;
        AND #$00F8      ;
        STA $14         ;__
        LSR             ;
        STA $16         ;__
        LDY #$04        ;
        STY $15
        LDY #$00
        
    .BigLoop:
        ;TODO: Palette from palette buffer
        LDX $14
        STX $00
        JSR HexToTiles
        LDX $16
        INC $16
        LDA $0200, X
        AND #$0077
        STA $17
        LSR
        LSR
        LSR
        TAX
        LDA $14
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1000, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1200, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1000, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1200, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1000, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1200, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 2
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $17
        AND #$0007
        ASL
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1040, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1240, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1040, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1240, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1040, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1240, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 3
        LDX $14
        STX $00
        JSR HexToTiles
        LDX $16
        INC $16
        LDA $0200, X
        AND #$0077
        STA $17
        LSR
        LSR
        LSR
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1080, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1280, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1080, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1280, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1080, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1280, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 4
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $17
        AND #$0007
        ASL
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $10C0, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $12C0, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $10C0, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $12C0, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $10C0, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $12C0, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 5
        LDX $14
        STX $00
        JSR HexToTiles
        LDX $16
        INC $16
        LDA $0200, X
        AND #$0077
        STA $17
        LSR
        LSR
        LSR
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1100, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1300, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1100, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1300, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1100, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1300, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 6
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $17
        AND #$0007
        ASL
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1140, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1340, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1140, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1340, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1140, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1340, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 7
        LDX $14
        STX $00
        JSR HexToTiles
        LDX $16
        INC $16
        LDA $0200, X
        AND #$0077
        STA $17
        LSR
        LSR
        LSR
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1180, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1380, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $1180, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $1380, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $1180, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $1380, Y
        TYA
        SEC
        SBC #$000E
        TAY
        INC $14
    ;Part 8
        LDX $14
        STX $00
        JSR HexToTiles
        LDA $17
        AND #$0007
        ASL
        TAX
        LDA $10
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $11C0, Y
        LDA $10
        XBA
        AND #$00FF
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $13C0, Y
        INY
        INY
        LDA #$0074
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
        STA $11C0, Y
        -:
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
            STA $13C0, Y
            INC $12
            INY
            INY
            LDA ($12)
            AND #$00FF
            ASL 
            ORA.l DrawHeaderTrackerMode_PaletteLookupTable_4bpp, X
            STA $11C0, Y
            LDA $12
            INC A
            STA $12
            TYA
            AND #$000F
            CMP #$000E
            BNE -
        LDA #$0040
        ORA.l DrawHeaderTrackerMode_PaletteLookupTable_2bpp, X
        STA $13C0, Y
        TYA
        INY
        INY
        INC $14
        DEC $15
        LDX $15
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
        STA VMADDL		;__
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        LDX #$18		;VRAM Write register
        STX BBAD1			;DMA 2 B Address
        LDX #$F0		;Bank of tilemap
        STX A1B1			;DMA 2 A Bank
        LDA #$1000		;Address of tilemap
        STA A1T1L			;DMA 2 A Offset
        LDX #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STX DMAP1
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
        STA DAS1L         ;__
        LDX #%00000010  ;   Init
        STX MDMAEN      ;__
        PHA             ;
        LDA #$7000      ;   Address in VRAM (beginning of BG1's tilemap)
        STA VMADDL       ;__
        LDA $0012       ;
        SEC             ;
        SBC #$0038      ;
        XBA             ;
        LSR             ;   Amount of data after hit end of tilemap
        LSR             ;
        STA DAS1L         ;
        STA $0014       ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        PLA             ;   Amount of data before hitting end of tilemap
        STA DAS1L         ;__
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA VMADDL		;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        LDA #$7800      ;   Address in VRAM (beginning of BG2's tilemap)
        STA VMADDL	    ;__
        LDA $0014       ;   Amount of data after hit end of tilemap
        STA DAS1L         ;__
        LDX #%00000010	;   Init DMA on channel 1
        STX MDMAEN		;__
        JMP DrawHeaderTrackerMode_DrawRow

        +   LDA #$0200		;Amount of data
        STA DAS1L			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init
        PLA             ;
        ORA #$0800      ;   Address in VRAM
        STA VMADDL		;__
        LDA #$0200		;Amount of data
        STA DAS1L			;DMA 2 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init
    .DrawRow:
		%SetDP_PPU_PEA()	;__	Set Direct Page to 2100 for PPU registers
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
        LDX #$00        ;
        STX VMAIN       ;
        STA $16         ;__
        LDX #$08        ;
        LDY #$00        ;
        -:                  ;   Draw the new row on BG1
            STX $18         ;
            INY             ;
            CPY #$20        ;
            BNE -           ;__

        LDA $0010       ;
        ORA #$7800      ;
        STA $16         ;
        -:                  ;   Draw the new row on BG2
            STX $18         ;
            INY             ;
            CPY #$40        ;
            BNE -           ;__
        LDX $0020
        BNE DrawHeaderTrackerMode_End
        ; LDA $0010
        ; CLC
        ; ADC #$0100
        ; AND #$07FF
        ; STA $0010
        ;             LDA #$0040
        ; -:                  ;   Draw the new rows on BG1
        ;     STA $18         ;
        ;     INX             ;
        ;     CPX #$60        ;
        ;     BNE -           ;__
        ; LDA #$0008
        ; -:                  ;   Draw the new row on BG1
        ;     STA $18         ;
        ;     INX             ;
        ;     CPX #$80        ;
        ;     BNE -           ;__
        ; LDA #$0040
        ; -:                  ;   Draw the new rows on BG2
        ;     STA $18         ;
        ;     INX             ;
        ;     CPX #$60        ;
        ;     BNE -           ;__
        ; LDA #$0008
        ; -:                  ;   Draw the new row on BG2
        ;     STA $18         ;
        ;     INX             ;
        ;     CPX #$80        ;
        ;     BNE -           ;__
    ;JSR DrawColumn
    


    .End:
        LDX #$80        ;
        STX VMAIN       ;
        PLP
        PLD
        PLB
        RTS

    .PaletteLookupTable:
        ..2bpp:
            dw $0000, $1000, $0400, $1400
            dw $0800, $1800, $0C00, $1C00
        ..4bpp:
            dw $0000, $0400, $0800, $0C00
            dw $1000, $1400, $1800, $1C00 

HexToTiles:
    ;Memory allocation:
        ;Inputs:
        ;$0000 - The hex number to convert to tiles
        ;Outputs:
        ;$0010 - The low byte of tile data to shove into VRAM (high nybble)
        ;$0011 - The low byte of tile data to shove into VRAM (low nybble)
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    SEP #%00110000  ;   Set XY and A to 8 bit
    % ResetDP_PEA()	;__	Set DP to $0000
    LDA $00
    AND #$0F
    TAX
    LDA HexToTiles_LookupTable, X
    STA $11

    LDA $00
    LSR
    LSR
    LSR
    LSR
    TAX
    LDA HexToTiles_LookupTable, X
    STA $10
    PLP
    PLD
    PLB
    RTS

    .LookupTable:
        db $60, $62, $64, $66
        db $68, $6A, $6C, $6E
        db $70, $72, $82, $84
        db $86, $88, $8A, $8C

DecompressLocaleBlock:
    ;Memory allocation:
        ;Inputs:
        ;$0000 - The block of text to convert to tiles
        ;Outputs:
        ;$0010-$001F - Tiles to shove into VRAM (little endian)
    PHB             ;
    PHD             ;   Back up some registers
    PHP             ;__
    REP !P_A        ;   Set A to 16 bit
    SEP !P_XY       ;__ Set XY to 8 bit
    % ResetDP_PEA()	;__	Set DP to 00
    LDX #$83        ;
    PHX             ;   Set DB to 83, locales in FastROM
    PLB             ;__   
    LDA $F00000     ;
    AND #$007F      ;__
    ASL
    ASL
    ORA #$8380
    STZ $10
    STZ $12
    STZ $14
    STZ $16
    STZ $18
    STZ $1A
    STZ $1C
    STA $1E
    LDX #$09
    STX $4202
    LDX $00
    STX $4203
    CLC             ;   9 = %00001001; only 4 low bits are used -> 4 cycles wait; CLC takes 2 cycles, 
    LDA $4216       ;__ LDA $4216 takes 3 to read the opcode - waited 5 cycles and did something useful
    ADC $1D
    CLC
    ADC #$0004
    STA $1D
    LDY #$00
    LDX #$00
    SEP #%00110000  ;__ Set A&XY to 8 bit
    LDA [$1D]       ;   The high byte for the tiles
    STA $11         ;__
    INY
    -:
        LDA [$1D], Y
        STA $10, X
        INY
        LDA [$1D], Y
        STA $18, X
        INY
        INX
        INX
        CPX #$08
        BNE -
    STZ $1D
    STZ $1F
    LDX #$06
    -:
        LSR $11
        ROL $19, X
        ASL $18, X
        ROL $19, X
        LSR $11
        ROL $11, X
        ASL $10, X
        ROL $11, X
        DEX
        DEX
        BNE -
    LSR $11
    ROL $19
    ASL $18
    ROL $19
    ASL $10
    ROL $11
    PLP
    PLD
    PLB
    RTS

UpdateColumn:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
		%SetDP_PPU_PEA()	;__	Set Direct Page to 2100 for PPU registers
        REP !P_A        ;   Set XY to 8 bit
        SEP !P_XY       ;__ Set A to 16 bit
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
DrawTrackerRow:
    ;Memory allocation:
        ;$00 - Row number (low byte)
        ;$01 - Row number (high bit, anything not 0 is 1)
        ;$100-180 - Actual tile data to shove into VRAM (little-endian)
    .Setup:
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        % ResetDP_PEA()	;__	Set Direct Page to 0
        PEA $7E7E       ;
        PLB             ;   Set Data Bank to 7E
        PLB             ;__ 

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
        % ResetDP_PEA()	;__	Set Direct Page to 0
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
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        SEP !P_A       	;set a to 8bit
        LDA $0001
        ASL A
        ASL A    
        ASL A
        AND #$18
        ORA #$40
        STA $0013
        STZ $0012
        LDX $0012		;Address to write to in VRAM
        STX VMADDL		;Write it to tell Snes that
        LDA #$18		;VRAM Write register
        STA BBAD1			;DMA 1 B Address
        LDX #$7E01		;Address of tileset
        STX A1T1H			;DMA 1 A Bank
        STZ A1T1L
        LDX #$1000		;Amount of data
        STX DAS1L			;DMA 1 Number of bytes
        LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STA $10
        LDA #%00000010	;bit 1 corresponds to channel 1
        STA MDMAEN		;Init
        % ResetDP_PEA()
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
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        SEP !P_A       	;set a to 8bit
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
        STX VMADDL		;Write it to tell Snes that
        LDA #$18		;VRAM Write register
        STA BBAD1			;DMA 1 B Address
        LDX #$7E01		;Address of tileset
        STX A1T1H			;DMA 1 A Bank
        STZ A1T1L
        LDX #$1000		;Amount of data
        STX DAS1L			;DMA 1 Number of bytes
        LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = increment) Mode (001 = 2 bytes, write once)
        STA DMAP1
        LDA #%00000010	;bit 1 corresponds to channel 1
        STA MDMAEN		;Init

        INC $001F
        LDA $001F
        BIT #$01
        BEQ +
            % ResetDP_PEA()	;__	Set Direct Page to 0
            REP #%00110000  ;__ Set XY, A to 16 bit
            PLY
            LDX #$0000
            JMP -
        +:
        % ResetDP_PEA()	;__	Set Direct Page to 0
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
        ;TODO: WRAM TO SRAM
        PHB             ;
        PHD             ;   Back up some registers
        PHP             ;__
        REP !P_A        ;   Set A to 16 bit
        SEP !P_XY       ;__ Set XY to 8 bit
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        LDX #$80		;WRAM Write register & Data Bank
        PHX             ;   Data bank
        PLB             ;__
        STX BBAD1			;DMA 1 B Address
        STZ A1T1L
        LDA #$8280		;Address of tileset
        STA A1T1H			;DMA 1 A Bank
        LDA #$0200		;Amount of data
        STA DAS1L			;DMA 1 Number of bytes
        LDX #%00001000	;Settings d--uummm (Direction (0 = A to B) Update (01 = do nothing) Mode (000 = 1 byte, write once)
        STX DMAP1       ;__
        STZ $2181       ;
        STZ $2182       ;   DMA to primary RAM buffer
        LDX #$01        ;
        STX $2182       ;__
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init

        LDX.b #(ClearInstrumentBuffer_EmptyTile&$0000FF)
        STX A1T1L
        LDA.w #(ClearInstrumentBuffer_EmptyTile&$FFFF00)>>8		;Address of tile
        STA A1T1H			;DMA 1 A Bank
        LDA #$0C00		;Amount of data
        STA DAS1L			;DMA 1 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init
        LDX #%10000000	;Settings d--uummm (Direction (1 = B to A) Update (00 = increment) Mode (000 = 1 byte, write once)
        STX DMAP1       ;


        STZ A1T1L
        LDA #$F002		;Address of SRAM
        STA A1T1H			;DMA 1 A Bank&Page
        STZ $2181       ;
        STZ $2182       ;   DMA from primary RAM buffer
        LDX #$01        ;
        STX $2182       ;__

        LDA #$0E00		;Amount of data
        STA DAS1L			;DMA 1 Number of bytes
        LDX #%00000010	;bit 1 corresponds to channel 1
        STX MDMAEN		;Init

        PLP
        PLD
        PLB
        RTS
    .EmptyTile:
        db $20
org $818000 ;The plotting engine for now
;1bpp to 2bpp converter

tableROMtoWRAM:		
	%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers

	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$0800		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA BBAD0		;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA A1B0		;DMA 1 A Bank
    LDX #$FC00		;Address of tiles
    STX A1T0L		;DMA 1 A Offset
    LDX #$0400		;Amount of data
    STX DAS0L		;DMA 1 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (000 = 1 byte, write once)
    STA DMAP0
	LDA #%00000001  ;bit 2 corresponds to channel 0
    STA MDMAEN		;Init
tableROMtoWRAM2:		
    ;JMP clearPaletteData
	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$0C00		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA BBAD0		;DMA 1 B Address
    LDA #$06		;Bank of tileset
    STA A1B0		;DMA 1 A Bank
    LDX #$FC00		;Address of tiles
    STX A1T0L		;DMA 1 A Offset
    LDX #$0400		;Amount of data
    STX DAS0L		;DMA 1 Number of bytes
    LDA #%00000000	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (000 = 1 byte, write once)
    STA DMAP0
	LDA #%00000001  ;bit 2 corresponds to channel 0
    STA MDMAEN		;Init
    RTL
clearPaletteData:		
	%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
	LDA #$01        ;WRAM Bank
	STA $2183
    LDX #$FE00		;Address to write to in WRAM
    STX $2181		;Write it to tell Snes that
    LDA #$80		;WRAM Write register
    STA BBAD0		;DMA 1 B Address
    LDA #$01		;Bank of tileset
    STA A1B0		;DMA 1 A Bank
    LDX #$FFFF		;Address of tiles
    STX A1T0L		;DMA 1 A Offset
    LDX #$0200		;Amount of data
    STX DAS0L		;DMA 1 Number of bytes
    LDA #%00001000	;Settings d--uummm (Direction (0 = A to B) Update (01 = don't) Mode (010 = 2 bytes, write twice)
    STA DMAP0
    LDA #%00000001  ;bit 2 corresponds to channel 0
    STA MDMAEN		;Init
    RTL
PlotGraph:
    .Decompress
        REP !P_XY      ;set xy to 16bit
        SEP !P_A       ;set a to 8bit
        % ResetDP_PEA()	;set db to 7f
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
            SEP !P_A       ;set a to 8bit
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
        REP !P_XY      ;set xy to 16bit
        SEP !P_A       ;set a to 8bit
		%SetDP_DMA_PEA()	;__	Set Direct Page to 4300 for DMA registers
        PHK
        PLB
        lda #$80            ; = 10000000
        sta INIDISP           ; F-Blank
        LDX #$1000		;Address to write to in VRAM
        STX VMADDL		;Write it to tell Snes that
        LDA #$18		;VRAM Write register
        STA BBAD0		;DMA 1 B Address
        LDA #$7F		;Bank of tileset
        STA A1B0		;DMA 1 A Bank
        LDX #$FE00		;Address of tiles
        STX A1T0L		;DMA 1 A Offset
        LDX #$0200		;Amount of data
        STX DAS0L		;DMA 1 Number of bytes
        LDA #%00000001	;Settings d--uummm (Direction (0 = A to B) Update (00 = Increment) Mode (001 = 2 bytes, write once)
        STA DMAP0
        LDA #%00000001  ;bit 2 corresponds to channel 0
        STA MDMAEN		;Init
        % ResetDP_PEA()	;set dp to 00
    RTL

PhaseModulation:
    ;Input: Carrier wavetable at $7F0800, $0400 bytes long
    ;Input: Modulator wavetable at $7F0C00, $0400 bytes long
    ;Output: Modulated Wavetable at $7F0000, $0400 bytes long
    .RoutineSelect:
        SEP !P_A       ;set a to 8bit
        LDA $0020
        STA $7FFFFD
		%SetDP_PPU_PEA()	;__	Set Direct Page to 2100 for PPU registers
        LDA #$7F
        PHA;set db to 7f
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
        SEP !P_A       ;set a to 8bit
        LDA $FFFD
        STA $000010
        STZ $FFFD
        % ResetDP_PEA()	;set db to 00
        LDA #$00
        PHA
        PLB
        RTL

DisplaySRAMWarningMessage:
    .LoadLocale:
        nop
