incsrc "SPC_constants.asm"
;   ==== Code/data distribution table: ====
;   page        purpose
;   $00         $00 - $BF: Flags & pointers for the note stuff:
;   |           Song data pointer, Instrument data pointer, Effect data pointer, Sample pointer, note index, pitch, pitchbend
;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
;   $01         $00 - $7F: Effect q
;   |__ _ _ _ _ $80 - $FF: Stack
;   $02(-$03?)_ Sample Directory
;   $04-$07 _ _ BRR conversion buffer
;   $0A-$0B _ _ 256 instrument data pointers
;   $0C _ _ _ _ 7/8 multiplication lookup table
;   $0D _ _ _ _ 15/16 multiplication lookup table
;   $0E         $00 - $BF: Pitch table, 96 entries long
;   |__ _ _ _ _ $C0 - $C8: Dummy empty sample (for beginnings and noise)
;   $0F _ _ _ _ Sine table, only $0F00-$0F42 is written, everything else is calculated
;   $10-$1F _ _ Music data and custom BRR samples (indexed from end)
;   $20-$3F _ _ Code
;   $40-$5F _ _ 32 FM generation buffers, 1 page long each
;   $60-$FE _ _ Actual sample storage, echo buffer (separated depending on the delay & amount of samples)
;   $FF         $00 - $BF: Hardsync routine (here for use with PCALL to save 2 cycles)
;   |__ _ _ _ _ $C0 - $FF: TCALL pointers/Boot ROM
org $2000
init:       ;init routine, totally not grabbed from tales of phantasia
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
    BCC +           ;   Load {echo delay}+1 into y, capping off at 16 if needed
    MOV Y, #$0F     ;
+:                  ;
    INC Y           ;__
-:                  ;
    MOV A, $FD      ;
    BEQ -           ;   Time-wasting loop to clear the echo buffer
    DBNZ Y,-        ;__

    MOV $F2, #$6C   ;
    MOV $F3, #$BF   ;___
    MOV Y, #$06     ;
    -:              ;Wait 97.5 ms for some reason
        MOV A, $FD  ;
        BEQ -
        DBNZ Y, -
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
    MOV $FA, #$85   ;   Set Timer 0 to 16.625 ms
;    MOV $FA, #$FF   ;   Set Timer 0 to 16.625 ms
    MOV $F1, #$07   ;__

; Setting up the sine table

    MOV X, #$02     ;__ X contains the source index,
    MOV Y, #$3E     ;__ Y contains the destination index

    SPC_SineSetup_loop0:
        MOV A, $0C00+X
        INC X
        MOV $0C40+Y, A
        MOV A, $0C00+X
        INC X
        MOV $0C41+Y, A
        DEC Y
        DBNZ Y, SPC_SineSetup_loop0
    
    MOV Y, #$3F

    SPC_SineSetup_loop1:
        MOV A, $0C00+Y
        EOR A, #$FF
        MOV $0C80+Y, A
        MOV A, $0C40+Y
        EOR A, #$FF
        MOV $0CC0+Y, A
        DBNZ Y, SPC_SineSetup_loop1
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$40
    MOV !MOD_MOD_STRENGTH, #$20
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$41
    MOV !MOD_MOD_STRENGTH, #$1E
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$42
    MOV !MOD_MOD_STRENGTH, #$1C
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$43
    MOV !MOD_MOD_STRENGTH, #$1A
    CALL SPC_PhaseModulation_128

    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$40
    MOV !MOD_MOD_STRENGTH, #$20
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$41
    MOV !MOD_MOD_STRENGTH, #$1E
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$42
    MOV !MOD_MOD_STRENGTH, #$1C
    CALL SPC_PhaseModulation_128
    MOV !MOD_CAR_PAGE, #$0F
    MOV !MOD_MOD_PAGE, #$0F
    MOV !MOD_OUT_PAGE, #$43
    MOV !MOD_MOD_STRENGTH, #$1A
    CALL SPC_PhaseModulation_128
    ;Tryna play a BRR sample
    MOV $F2, #$00;
    MOV $F3, #$7F;vol left
    MOV $F2, #$01;
    MOV $F3, #$7F;vol right
    MOV $F2, #$05
    MOV $F3, #$00;use GAIN
    ;CH2
    MOV $F2, #$10;
    MOV $F3, #$7F;vol left
    MOV $F2, #$11;
    MOV $F3, #$7F;vol right
    MOV $F2, #$15
    MOV $F3, #$00;use GAIN

    MOV $F2, #$20;
    MOV $F3, #$7F;vol left
    MOV $F2, #$21;
    MOV $F3, #$7F;vol right
    MOV $F2, #$25
    MOV $F3, #$00;use GAIN
    ;CH2
    MOV $F2, #$30;
    MOV $F3, #$7F;vol left
    MOV $F2, #$31;
    MOV $F3, #$7F;vol right
    MOV $F2, #$35
    MOV $F3, #$00;use GAIN

    MOV $F2, #$5C
    MOV $F3, #$00
    MOV $F2, #$6C
    MOV $F3, #$00

    MOV X, #$00
    MOV !PATTERN_END_FLAGS, #$00
    MOV A, $0EC9
    MOV !PATTERN_POINTER_L, A
    MOV A, $0ECA
    MOV !PATTERN_POINTER_H, A
    MOV A, $FD
    MOV X, #$00
    CALL SPC_ParsePatternData
    JMP SPC_mainLoop_00

SPC_ParseSongData:

    BBC0 !CHTEMP_FLAGS, +
    RET
+:
    MOV Y, #$00
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y 
    MOV $EF, A
    BBC7 $EF, SPC_ParseSongData_NoRetrigger
;Retrigger
    AND A, #$7F
    SETC
    SBC A, #$60
    BMI +
    ASL A
    SETC
    SBC A, #$3A
    PUSH X
    MOV X, A
    JMP (SPC_ParseSongData_routineTable+X)
+:
    MOV !CHTEMP_NOTE, $EF
    MOV $F2, #$5C       ;
    MOV $F3, #$00       ;   Key off the needed channel
    MOV $D0, #$F3       ;
    TCALL 13            ;__
    MOV Y, #$00
    INCW !CHTEMP_SONG_POINTER_L
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y
    ASL A
    MOV Y, A
    MOV A, $0A01+Y
    MOV !CHTEMP_INSTRUMENT_POINTER_H, A
    MOV A, $0A00+Y
    MOV !CHTEMP_INSTRUMENT_POINTER_L, A
    CLR1 !CHTEMP_FLAGS
    SET6 !CHTEMP_FLAGS
    CALL SPC_ParseInstrumentData
    MOV $F2, #$5C       ;
    MOV $F3, #$00       ;   Key off nothing (so no overrides happen)
    MOV $F2, #$4C       ;
    MOV $F3, #$00       ;   Key on the needed channel
    MOV $D0, #$F3       ;
    TCALL 13            ;__
    SPC_ParseSongData_NoRetrigger:
    MOV A, $EF              ;
    MOV !CHTEMP_NOTE, A     ;   Apply arpeggio
    CLRC                    ;
    ADC A, !CHTEMP_ARPEGGIO ;__
    INCW !CHTEMP_SONG_POINTER_L
    BBC0 !CHTEMP_INSTRUMENT_TYPE, SPC_ParseSongData_NoisePitch
    ASL A
    MOV Y, A             
    MOV A, $0E00+Y
    AND !CHTEMP_REGISTER_INDEX, #$70
    OR !CHTEMP_REGISTER_INDEX, #$02
    MOV $F2, !CHTEMP_REGISTER_INDEX;
    MOV $F3, A
    MOV A, $0E01+Y
    OR !CHTEMP_REGISTER_INDEX, #$01    
    MOV $F2, !CHTEMP_REGISTER_INDEX;
    MOV $F3, A ;pitch
    JMP +
SPC_ParseSongData_NoisePitch:
    AND A, #$1F  ;
    MOV $F2, #$6C;  Update noise clock
    AND $F3, #$E0;
    OR A, $F3    ;
    MOV $F3, A   ;__
    MOV $F2, #$3D
    MOV A, $F3
    NOP
    MOV $F3, A
+:
-:
    MOV Y, #$00
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y
    DEC A
    MOV !CHTEMP_SONG_COUNTER, A
    INCW !CHTEMP_SONG_POINTER_L
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y
    RET
SPC_ParseSongData_Keyoff:
    SET1 !CHTEMP_FLAGS
    MOV $F2, #$5C
    MOV $F3, #$00
    POP X
    PUSH X
    MOV $D0, #$F3
    TCALL 13
SPC_ParseSongData_NoPitch:
    INCW !CHTEMP_SONG_POINTER_L
    POP X
    JMP -
SPC_ParseSongData_End:
    SET0 !CHTEMP_FLAGS
    MOV $D0, #!PATTERN_END_FLAGS
    POP X
    TCALL 13
    INCW !CHTEMP_SONG_POINTER_L
    JMP -
SPC_ParseSongData_routineTable:
    dw SPC_ParseSongData_NoPitch
    dw SPC_ParseSongData_Keyoff
    dw SPC_ParseSongData_End
SPC_mainLoop_00:
    MOV $E2, $FD
    MOV A, $E2
    BEQ SPC_mainLoop_00
SPC_mainLoop_02:
    TCALL 15
    SETC
    SBC !CHTEMP_SONG_COUNTER, $E2
    BPL +
    CALL SPC_ParseSongData
+:
    SETC
    SBC !CHTEMP_INSTRUMENT_COUNTER, $E2
    BPL +
    CALL SPC_ParseInstrumentData
+:
    TCALL 14    ;Transfer shit back
    MOV A, X
    CLRC
    ADC A, #$08
    AND A, #$18
    MOV !CHTEMP_REGISTER_INDEX, A
    ASL !CHTEMP_REGISTER_INDEX
    MOV X, A
    BNE SPC_mainLoop_02
    CMP !PATTERN_END_FLAGS, #$0F
    BNE SPC_mainLoop_00
    CALL SPC_ParsePatternData
    JMP SPC_mainLoop_02

SPC_ParseInstrumentData:
    BBC1 !CHTEMP_FLAGS, +
    JMP +++
+:
    MOV Y, #$00
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y
    MOV $E0, A
    INCW !CHTEMP_INSTRUMENT_POINTER_L
    BBC7 $E0, ++
    AND A, #$70
    XCN A    
    BNE +
    MOV A, $E0
    AND A, #$07
    MOV !CHTEMP_INSTRUMENT_TYPE, A
    MOV $F2, #$3D                           ;   Enable noise if needed
    MOV $D0, #$F3
    MOV1 C, !CHTEMP_INSTRUMENT_TYPE.0       ;
    BCC SPC_ParseInstrumentData_Noise0
    TCALL 12
    JMP +
SPC_ParseInstrumentData_Noise0:
    TCALL 13
+:
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y
    MOV $E0, A
    INCW !CHTEMP_INSTRUMENT_POINTER_L
++:
    BBC6 $E0, +                             ;__ If no sample pointer update, skip
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV !CHTEMP_SAMPLE_POINTER_L, A         ;
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;   Loading sample pointer into memory
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV !CHTEMP_SAMPLE_POINTER_H, A         ;
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    CALL SPC_updatePointer0                 ;__ Updating the sample pointer
+:
    BBC2 $E0, +                             ;__ If no envelope update, skip
    AND !CHTEMP_REGISTER_INDEX, #$70        ;
    OR !CHTEMP_REGISTER_INDEX, #$07         ;
    MOV $F2, !CHTEMP_REGISTER_INDEX         ;   Update GAIN envelope
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV $F3, A                              ;
    MOV $F3, A                              ;__
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;
+:
    BBC1 $E0, +                             ;__ If no apreggio update, skip
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;   
    MOV !CHTEMP_ARPEGGIO, A                 ;   Update arpeggio
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    MOV A, !CHTEMP_NOTE                     ;   Apply arpeggio
    CLRC                                    ;
    ADC A, !CHTEMP_ARPEGGIO                 ;__
    BBC0 !CHTEMP_INSTRUMENT_TYPE, ++
    ASL A                                   ;
    MOV Y, A                                ;__
    MOV A, $0E00+Y                          ;
    AND !CHTEMP_REGISTER_INDEX, #$70        ;
    OR !CHTEMP_REGISTER_INDEX, #$02         ;   Update low byte of pitch
    MOV $F2, !CHTEMP_REGISTER_INDEX;        ;
    MOV $F3, A                              ;__
    MOV A, $0E01+Y                          ;
    OR !CHTEMP_REGISTER_INDEX, #$01         ;   Update high byte of pitch
    MOV $F2, !CHTEMP_REGISTER_INDEX;        ;
    MOV $F3, A                              ;
    MOV Y, #$00                             ;__
    JMP +
++:
    AND A, #$1F                             ;
    MOV $F2, #$6C                           ;  Update noise clock
    AND $F3, #$E0                           ;
    OR A, $F3                               ;
    MOV $F3, A                              ;__
    MOV $F2, #$3D
    MOV A, $F3
    NOP
    MOV $F3, A
+:
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    DEC A                                   ;
    MOV !CHTEMP_INSTRUMENT_COUNTER, A       ;   Update instrument counter
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    CMP A, #$FF                             ;   Stop instrument data if the next byte is $FF
    BNE +++                                 ;   (should really be in the beginning of the code)
    SET1 !CHTEMP_FLAGS                      ;__
+++:
    RET


SPC_ParsePatternData:
    MOV X, #$00
    MOV !PATTERN_END_FLAGS, #$00
-:
    MOV Y, #$00
    MOV A, (!PATTERN_POINTER_L)+Y
    CMP A, #$FF
    BEQ SPC_End
    INCW !PATTERN_POINTER_L
    ASL A
    MOV Y, A
    MOV A, PatternPointers+Y
    MOV !CH1_SONG_POINTER_L+X, A
    INC Y
    MOV A, PatternPointers+Y
    MOV !CH1_SONG_POINTER_H+X, A
    MOV A, #$00
    MOV !CH1_SONG_COUNTER+X, A
    MOV A, !CH1_FLAGS+X
    AND A, #$FE
    MOV !CH1_FLAGS+X, A
    MOV A, X
    CLRC
    ADC A, #$08
    AND A, #$18
    MOV X, A
    BNE -
    RET

SPC_End:
    MOV $6C, #$C0
    MOV $F4, #$89
    MOV $F5, #$AB
    MOV $F6, #$CD
    MOV $F7, #$EF
    STOP

SPC_updatePointer0:         ;When the sample is 0
    BBS7 !CHTEMP_FLAGS, SPC_updatePointer1
    MOV A, !CHTEMP_SAMPLE_POINTER_L
    MOV $0206+X, A
    MOV A, !CHTEMP_SAMPLE_POINTER_H
    MOV $0207+X, A
    BBS6 !CHTEMP_FLAGS, +
    MOV A, !CHTEMP_SAMPLE_POINTER_L
    MOV $0204+X, A
    MOV A, !CHTEMP_SAMPLE_POINTER_H
    MOV $0205+X, A
    JMP ++
+:
    MOV A, #$C0
    MOV $0204+X, A
    MOV A, #$0E
    MOV $0205+X, A
    CLR6 !CHTEMP_FLAGS
++:
    AND !CHTEMP_REGISTER_INDEX, #$70
    OR !CHTEMP_REGISTER_INDEX, #$04
    MOV $F2, !CHTEMP_REGISTER_INDEX
    MOV A, !CHTEMP_REGISTER_INDEX
    LSR A
    LSR A
    LSR A
    OR A, #$01 
    MOV $F3, A;SCRN
    SET7 !CHTEMP_FLAGS
    RET


SPC_updatePointer1:
    MOV A, !CHTEMP_SAMPLE_POINTER_L
    MOV $0202+X, A
    MOV A, !CHTEMP_SAMPLE_POINTER_H
    MOV $0203+X, A
    BBS6 !CHTEMP_FLAGS, +
    MOV A, !CHTEMP_SAMPLE_POINTER_L
    MOV $0200+X, A
    MOV A, !CHTEMP_SAMPLE_POINTER_H
    MOV $0201+X, A
    JMP ++
+:
    MOV A, #$C0
    MOV $0200+X, A
    MOV A, #$0E
    MOV $0201+X, A
    CLR6 !CHTEMP_FLAGS
++:
    AND !CHTEMP_REGISTER_INDEX, #$70
    OR !CHTEMP_REGISTER_INDEX, #$04
    MOV $F2, !CHTEMP_REGISTER_INDEX
    MOV A, !CHTEMP_REGISTER_INDEX
    LSR A
    LSR A
    LSR A
    MOV $F3, A;SCRN
    CLR7 !CHTEMP_FLAGS
    RET

SPC_set_echoFIR:
    MOV $00, #$08
    MOV $01, #$0F
    MOV Y, #$00
-:
    MOV $F2, $01
    MOV A, echoFIRtable+Y
    MOV $F3, A
    CLRC
    ADC $01, #$10
    INC Y
    DBNZ $00, -
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
;       $04-05 - Output pointer
;       $06-07 - Modulator pointer
;       $08-09 - Main temp variable
SPC_PhaseModulation_128:
    MOV X, #$00
    MOV !MOD_OUT_INDEX_H, !MOD_OUT_PAGE
    MOV !MOD_MOD_INDEX_H, !MOD_MOD_PAGE
    MOV !MOD_OUT_INDEX_L, X
    MOV !MOD_MOD_INDEX_L, X
SPC_PhaseModulation_128_loop:
    INC !MOD_MOD_INDEX_L
    MOV A, (!MOD_MOD_INDEX_L+X)
    MOV !MOD_MAIN_TEMP_H, A
    BBS7 !MOD_MAIN_TEMP_H, SPC_PhaseModulation_128_loop_negative 
    MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
    MUL YA
    MOVW !MOD_MAIN_TEMP_L, YA

    DEC !MOD_MOD_INDEX_L
    MOV A, (!MOD_MOD_INDEX_L+X)
    MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
    MUL YA
    MOV A, Y
    CLRC
    ADC A, !MOD_MAIN_TEMP_L
    ADC !MOD_MAIN_TEMP_H, #$00
    JMP SPC_PhaseModulation_128_loop_afterMul
SPC_PhaseModulation_128_loop_negative:
    EOR A, #$FF
    MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
    MUL YA
    MOVW !MOD_MAIN_TEMP_L, YA

    DEC !MOD_MOD_INDEX_L
    MOV A, (!MOD_MOD_INDEX_L+X)
    EOR A, #$FF
    MOV Y, !MOD_MOD_STRENGTH      ;Mod strength
    MUL YA
    MOV A, Y
    CLRC
    ADC A, !MOD_MAIN_TEMP_L
    ADC !MOD_MAIN_TEMP_H, #$00
    EOR A, #$FF
    EOR !MOD_MAIN_TEMP_H, #$FF
SPC_PhaseModulation_128_loop_afterMul:

    ROR !MOD_MAIN_TEMP_H
    ROR A
    ROR !MOD_MAIN_TEMP_H
    ROR A
    ROR !MOD_MAIN_TEMP_H
    ROR A
    ROR !MOD_MAIN_TEMP_H
    ROR A
    ROR !MOD_MAIN_TEMP_H
    ROR A
    AND A, #$FE
    CLRC
    ADC A, !MOD_OUT_INDEX_L 

    MOV !MOD_MAIN_TEMP_H, !MOD_CAR_PAGE
    MOV !MOD_MAIN_TEMP_L, A
    MOV Y, #$00
    MOV A, (!MOD_MAIN_TEMP_L)+Y
    MOV (!MOD_OUT_INDEX_L)+Y, A
    INC Y
    MOV A, (!MOD_MAIN_TEMP_L)+Y
    MOV (!MOD_OUT_INDEX_L)+Y, A
    INC !MOD_OUT_INDEX_L
    INC !MOD_OUT_INDEX_L
    INC !MOD_MOD_INDEX_L
    INC !MOD_MOD_INDEX_L
    MOV A, !MOD_OUT_INDEX_L
    BNE SPC_PhaseModulation_128_loop
    RET

SPC_transferChToTemp:
PUSH A
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$07
MOV X, A
-:
    MOV A, $00+X
    DEC X
    MOV !CHTEMP_POINTER_0+Y, A
    DBNZ Y, -
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$08
MOV X, A
-:
    MOV A, $40+X
    DEC X
    MOV !CHTEMP_POINTER_1+Y, A
    DBNZ Y, -
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$08
MOV X, A
-:
    MOV A, $80+X
    DEC X
    MOV !CHTEMP_POINTER_2+Y, A
    DBNZ Y, -
INC X
POP A
RET

SPC_transferTempToCh:
PUSH A
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$07
MOV X, A
-:
    MOV.b A, !CHTEMP_POINTER_0+Y
    MOV.b $00+X, A
    DEC X
    DBNZ Y, -
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$08
MOV X, A
-:
    MOV.b  A, !CHTEMP_POINTER_1+Y
    MOV.b $40+X, A
    DEC X
    DBNZ Y, -
MOV Y, #$08
MOV A, X
CLRC
ADC A, #$08
MOV X, A
-:
    MOV.b  A, !CHTEMP_POINTER_2+Y
    MOV.b $80+X, A
    DEC X
    DBNZ Y, -
INC X
POP A
RET

SPC_SetFlagdp:  ;TCALL 13

    MOV A, X
    ASL A
    ASL A
    AND A, #$E0
    OR A, #$02
    MOV SPC_sfdp_act, A
    MOV A, $D0
    MOV SPC_sfdp_act+1, A
SPC_sfdp_act:
    SET1 $00
    RET

SPC_ClrFlagdp:  ;TCALL 12

    MOV A, X
    ASL A
    ASL A
    AND A, #$E0
    OR A, #$12
    MOV SPC_cfdp_act, A
    MOV A, $D0
    MOV SPC_cfdp_act+1, A
SPC_cfdp_act:
    CLR1 $00
    RET

org $0200
    dw $0EC0, $6000, $0EC0, $6000
org $0C00
    incbin "lookuptables.bin"
org $0E00
    incbin "pitchtable.bin"
org $0EC0   ;Dummy empty sample
    db $03, $00, $00, $00, $00, $00, $00, $00, $00
    dw PatternData
org $0F00
    incbin "quartersinetable.bin"
org $1000
    ; Song data
    incsrc "chipjam.asm"
org $0A00
    ;instrument data pointers
    dw Instr00Data, Instr01Data, Instr02Data
org $6000   ;Actual samples
    incbin "brr0.brr"
    incbin "brr1.brr"
    incbin "brr2.brr"
    incbin "brr3.brr"
    incbin "brr4.brr"
    incbin "brr5.brr"
    incbin "brr6.brr"
    incbin "brr7.brr"
org $FFC0   ;For TCALLs
    dw SPC_transferChToTemp, SPC_transferTempToCh, SPC_SetFlagdp, SPC_ClrFlagdp
startpos init
