incsrc "SPC_constants.asm"
;   ==== Code/data distribution table: ====
;   Page        Purpose
;   $00         $00 - $BF: Flags & pointers for the note stuff:
;   |           Song data pointer, Instrument data pointer, Effect data pointer, Sample pointer, note index, pitch, pitchbend
;   |__ _ _ _ _ $C0 - $EF: Operating space of subroutines (how exactly described before every subroutine)
;   $01         $00 - $7F: Effect q
;   |__ _ _ _ _ $80 - $FF: Stack
;   $02(-$03?)_ Sample Directory
;   $0A-$0B _ _ 256 instrument data pointers
;   $0C _ _ _ _ 7/8 multiplication lookup table
;   $0D _ _ _ _ 15/16 multiplication lookup table
;   $0E         $00 - $BF: Pitch table, 96 entries long
;   |__ _ _ _ _ $C0 - $C8: Dummy empty sample (for beginnings and noise)
;   $0F _ _ _ _ Sine table, only $0F00-$0F42 is written, everything else is calculated
;   $10-$1F _ _ Instrument data      \_ Combined for
;   $20-$4F _ _ FM generation buffers/  song data   (16KB!!!!)
;   $50-$5F _ _ Code
;   $60-$FE _ _ Actual sample storage, echo buffer (separated depending on the delay & amount of samples)
;   $FF         $00 - $BF: Hardsync routine (here for use with PCALL to save 2 cycles)
;   |__ _ _ _ _ $C0 - $FF: TCALL pointers/Boot ROM
;   ==== Communication with SNES: ====
;       (Port 0 is always message number; Port 1's high 4 bits is message ID)
;       === To SNES: ===
;   Id  | P1 |    Pt2    |    Pt3    |   Meaning
;   $0  |    |           |           |   Waiting for yo command
;   $1  |    |  id | location & $FFF |   Read, jumping to transfer routine, redirect me to $5000 | location
;   $2  |    |    location - $1000   |   Send song data to location + $1000
;   $3  |     20-bit tick counter    |   Currently playing song, here's what tick it is
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
;   $F  |    |           |           |   What? 
org $5000
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
;    MOV $FA, #$85   ;   Set Timer 0 to 16.625 ms (60 Hz)
    MOV $FA, #$50   ;   Set Timer 0 to 10 ms     (100 Hz)
    MOV $F1, #$07   ;__

; Setting up the sine table

    MOV X, #$02     ;__ X contains the source index,
    MOV Y, #$3E     ;__ Y contains the destination index

    SPC_SineSetup_loop0:
        MOV A, $0F00+X
        INC X
        MOV $0F40+Y, A
        MOV A, $0F00+X
        INC X
        MOV $0F41+Y, A
        DEC Y
        DBNZ Y, SPC_SineSetup_loop0
    
    MOV Y, #$3F

    SPC_SineSetup_loop1:
        MOV A, $0F00+Y
        EOR A, #$FF
        MOV $0F80+Y, A
        MOV A, $0F40+Y
        EOR A, #$FF
        MOV $0FC0+Y, A
        DBNZ Y, SPC_SineSetup_loop1
    MOV !PUL_OUT_PAGE, #$28
    MOV !PUL_DUTY, #$20
    MOV !PUL_FLAGS, #$03
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$20
    MOV !PUL_DUTY, #$02
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$21
    MOV !PUL_DUTY, #$04
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$22
    MOV !PUL_DUTY, #$06
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$23
    MOV !PUL_DUTY, #$08
    CALL SPC_GeneratePulse_32

    MOV !PUL_OUT_PAGE, #$24
    MOV !PUL_DUTY, #$0A
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$25
    MOV !PUL_DUTY, #$0C
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$26
    MOV !PUL_DUTY, #$0E
    CALL SPC_GeneratePulse_32
    MOV !PUL_OUT_PAGE, #$27
    MOV !PUL_DUTY, #$10
    CALL SPC_GeneratePulse_32
    MOV !BRR_PCM_PAGE, #$20
    MOV !BRR_OUT_INDEX, #$01    ;As if it matters lmao
    MOV !BRR_FLAGS, #%11000000
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$21
    MOV !BRR_OUT_INDEX, #$02    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$22
    MOV !BRR_OUT_INDEX, #$03    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$23
    MOV !BRR_OUT_INDEX, #$04    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$24
    MOV !BRR_OUT_INDEX, #$05    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$25
    MOV !BRR_OUT_INDEX, #$06    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$26
    MOV !BRR_OUT_INDEX, #$07    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$27
    MOV !BRR_OUT_INDEX, #$08    ;As if it matters lmao
    CALL SPC_ConvertToBRR
    MOV !BRR_PCM_PAGE, #$28
    MOV !BRR_OUT_INDEX, #$00    ;As if it matters lmao
    CALL SPC_ConvertToBRR

    MOV !PUL_FLAGS, #$03
    MOV !PUL_OUT_PAGE, #$28
    MOV !PUL_DUTY, #$20
    CALL SPC_GeneratePulse_32
    MOV !BRR_PCM_PAGE, #$28
    MOV !BRR_OUT_INDEX, #$09
    MOV !BRR_FLAGS, #%01000000
    CALL SPC_ConvertToBRR
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
    MOV $F3, #$20

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
    MOV $ED, A
    BBC7 $ED, SPC_ParseSongData_NoRetrigger
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
    MOV !CHTEMP_NOTE, $ED
    MOV $F2, #$5C       ;
    MOV $F3, #$00       ;   Key off the needed channel
    MOV !CHG_BIT_ADDRESS, #$F3       ;
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
    CALL SPC_ParseInstrumentData
    INC !CHTEMP_INSTRUMENT_COUNTER
    MOV $F2, #$5C       ;
    MOV $F3, #$00       ;   Key off nothing (so no overrides happen)
    MOV $F2, #$4C       ;
    MOV $F3, #$00       ;   Key on the needed channel
    MOV !CHG_BIT_ADDRESS, #$F3       ;
    TCALL 13            ;__
.NoRetrigger:
    MOV A, $ED              ;
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
.NoisePitch:
    AND A, #$1F  ;
    MOV $F2, #$6C;  Update noise clock
    AND $F3, #$E0;
    OR A, $F3    ;
    MOV $F3, A   ;__
+:
-:
    MOV Y, #$00
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y
    DEC A
    MOV !CHTEMP_SONG_COUNTER, A
    INCW !CHTEMP_SONG_POINTER_L
    MOV A, (!CHTEMP_SONG_POINTER_L)+Y
    RET
.Keyoff:
    SET1 !CHTEMP_FLAGS
    MOV $F2, #$5C
    MOV $F3, #$00
    POP X
    PUSH X
    MOV !CHG_BIT_ADDRESS, #$F3
    TCALL 13
.NoPitch:
    INCW !CHTEMP_SONG_POINTER_L
    POP X
    JMP -
.End:
    SET0 !CHTEMP_FLAGS
    MOV !CHG_BIT_ADDRESS, #!PATTERN_END_FLAGS
    POP X
    TCALL 13
    INCW !CHTEMP_SONG_POINTER_L
    JMP -
.routineTable:
    dw SPC_ParseSongData_NoPitch
    dw SPC_ParseSongData_Keyoff
    dw SPC_ParseSongData_End
SPC_mainLoop:
.00:
    MOV $E2, $FD
    MOV A, $E2
    BEQ SPC_mainLoop_00
.01:
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
    BNE SPC_mainLoop_01
    CMP !PATTERN_END_FLAGS, #$0F
    BNE SPC_mainLoop_00
    CALL SPC_ParsePatternData
    JMP SPC_mainLoop_01

SPC_ParseInstrumentData:
    BBC1 !CHTEMP_FLAGS, +
    RET
+:
    MOV Y, #$00
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y
    MOV $E0, A
    INCW !CHTEMP_INSTRUMENT_POINTER_L
    BBC7 $E0, SPC_ParseInstrumentData_UpdateSamplePointer
    AND A, #$60
    XCN A    
    BNE +
    MOV A, $E0
    AND A, #$1F
    MOV !CHTEMP_INSTRUMENT_TYPE, A
    MOV $F2, #$3D                           ;   Enable noise if needed
    MOV !CHG_BIT_ADDRESS, #$F3
    BBC0 !CHTEMP_INSTRUMENT_TYPE, SPC_ParseInstrumentData_Noise0
    TCALL 12
    JMP +
.Noise0:
    TCALL 13
+:
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y
    MOV $E0, A
    INCW !CHTEMP_INSTRUMENT_POINTER_L
.UpdateSamplePointer:
    BBC6 $E0, SPC_ParseInstrumentData_UpdateEnvelope ;__ If no sample pointer update, skip
    BBC3 !CHTEMP_INSTRUMENT_TYPE, +         ;__ If use sample index,
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;
    MOV Y, A                                ;
    MOV A, $E0                              ;
    AND A, #$30                             ;
    XCN A                                   ;
    MOV $EF, A                              ;  Get pointer from sample index
    MOV A, !CHTEMP_INSTRUMENT_TYPE          ;
    AND A, #$10                             ;
    OR A, $EF                               ;
    TCALL 11                                ;
    MOVW !CHTEMP_SAMPLE_POINTER_L, YA       ;
    MOV Y, #$00                             ;
    JMP ++                                  ;__
+   MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV !CHTEMP_SAMPLE_POINTER_L, A         ;   If no, just blatantly
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;   Load sample pointer into memory
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV !CHTEMP_SAMPLE_POINTER_H, A         ;
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
++  CALL SPC_updatePointer                  ;__ Update the sample pointer
.UpdateEnvelope:
    BBC2 $E0, SPC_ParseInstrumentData_UpdateArpeggio;__ If no envelope update, skip
    AND !CHTEMP_REGISTER_INDEX, #$70        ;
    OR !CHTEMP_REGISTER_INDEX, #$07         ;
    MOV $F2, !CHTEMP_REGISTER_INDEX         ;   Update GAIN envelope
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    MOV $F3, A                              ;
    MOV $F3, A                              ;__
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;
.UpdateArpeggio:
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
+:
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    DEC A                                   ;
    MOV !CHTEMP_INSTRUMENT_COUNTER, A       ;   Update instrument counter
    INCW !CHTEMP_INSTRUMENT_POINTER_L       ;__
    MOV A, (!CHTEMP_INSTRUMENT_POINTER_L)+Y ;
    CMP A, #$FF                             ;   Stop instrument data if the next byte is $FF
    BNE +                                   ;   (should really be in the beginning of the code)
    SET1 !CHTEMP_FLAGS                      ;__
+:
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

SPC_updatePointer:         ;When the sample is 0
    BBS7 !CHTEMP_FLAGS, SPC_updatePointer_1  ;If the sample currently playing is 1, update sample 0
.0:
    MOV A, !CHTEMP_SAMPLE_POINTER_H     ;   Check if high byte is the same
    CMP A, $0203+X                      ;__
    BNE SPC_updatePointer_0_withRestart
    MOV A, !CHTEMP_SAMPLE_POINTER_L     ;
    MOV $0202+X, A                      ;__ Update low byte of sample pointer
    RET
    
..withRestart:
    MOV $0207+X, A                      ;   If high byte is different,
    MOV A, !CHTEMP_SAMPLE_POINTER_L     ;   Update sample 1 loop pointer
    MOV $0206+X, A                      ;__
    MOV A, #$C0                         ;
    MOV $0204+X, A                      ;   Reset sample 1 start pointer to blank sample
    MOV A, #$0E                         ;
    MOV $0205+X, A                      ;__
    AND !CHTEMP_REGISTER_INDEX, #$70    ;   
    OR !CHTEMP_REGISTER_INDEX, #$04     ;   Write address to DSP
    MOV $F2, !CHTEMP_REGISTER_INDEX     ;__
    MOV A, !CHTEMP_REGISTER_INDEX       ;
    LSR A                               ;
    LSR A                               ;   Write Source Number to DSP
    LSR A                               ;
    OR A, #$01                          ;
    MOV $F3, A                          ;__
    SET7 !CHTEMP_FLAGS                  ;__ Next time update sample 0
    RET


.1:
    MOV A, !CHTEMP_SAMPLE_POINTER_H     ;   Check if high byte is the same
    CMP A, $0207+X                      ;__
    BNE SPC_updatePointer_1_withRestart
    MOV A, !CHTEMP_SAMPLE_POINTER_L     ;
    MOV $0206+X, A                      ;__ Update low byte of sample pointer
    RET
    
..withRestart:
    MOV $0203+X, A                      ;   If high byte is different,
    MOV A, !CHTEMP_SAMPLE_POINTER_L     ;   Update sample 1 loop pointer
    MOV $0202+X, A                      ;__
    MOV A, #$C0                         ;
    MOV $0200+X, A                      ;   Reset sample 1 start pointer to blank sample
    MOV A, #$0E                         ;
    MOV $0201+X, A                      ;__
    AND !CHTEMP_REGISTER_INDEX, #$70    ;   
    OR !CHTEMP_REGISTER_INDEX, #$04     ;   Write address to DSP
    MOV $F2, !CHTEMP_REGISTER_INDEX     ;__
    MOV A, !CHTEMP_REGISTER_INDEX       ;
    LSR A                               ;
    LSR A                               ;   Write Source Number to DSP
    LSR A                               ;
    MOV $F3, A                          ;__
    CLR7 !CHTEMP_FLAGS                  ;__ Next time sample 1 is updated
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
SPC_GeneratePulse_128:
;Low byte of first part
    MOV !PUL_OUT_INDEX_H, !PUL_OUT_PAGE
    MOV !PUL_OUT_INDEX_L, #$00
    MOV A, !PUL_DUTY        ;   Get finishing low byte
    AND A, #$FE             ;__
    MOV Y, A                ;   If there are no bytes in the first part, skip the part
    BEQ +                   ;__
    MOV A, !PUL_FLAGS
    AND A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+1+X
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$00
    BNE -
;High byte of first part
    MOV A, !PUL_DUTY        ;   Get finishing high byte
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+X
    EOR A, #$80
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$01
    BNE -
+:
;Second part, the fractional value
    MOV A, !PUL_FLAGS           ;
    AND A, #$03                 ;
    MOV X, A                    ;   Get the inversion value into "temp variable"
    MOV A, SPC_GeneratePulse_128_LookupTable+4+X
    MOV !PUL_OUT_INDEX_L, A     ;__
    MOV A, !PUL_DUTY            ;
    LSR A                       ;   Get the actual fraction,
    MOV A, !PUL_FLAGS           ;   while also getting 
    ROR A                       ;   z flag into carry
    AND A, #$FE                 ;__
    BCC +                       ;   If z flag is set, 
    LSR A                       ;__ halve the fraction
+   EOR A, !PUL_OUT_INDEX_L     ;__ Invert the fraction as needed
    MOV Y, A
    MOV A, !PUL_DUTY            ;   Get index for the fraction
    AND A, #$FE                 ;
    MOV !PUL_OUT_INDEX_L, A     ;__
    MOV A, Y
    MOV Y, #$01
    MOV (!PUL_OUT_INDEX_L)+Y, A
    MOV A, #$00
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    INC !PUL_OUT_INDEX_L
    INC !PUL_OUT_INDEX_L
;Third part
    MOV A, !PUL_DUTY
    EOR A, #$FE
    AND A, #$FE
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$02
    EOR A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+1+X
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$00
    BNE -
;High byte of first part
    MOV A, !PUL_DUTY        ;   Get finishing high byte
    EOR A, #$FE             ;
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    EOR A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+X
    EOR A, #$80
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$01
    BNE -
+:
RET
.LookupTable:   ;In order:
;Highbyte with sz = 00 (8000),
;Lowbyte with s=0 (8000/0000) / Highbyte with sz = 01 (0000), 
;Highbyte with sz = 1- (7FFF),
;Lowbyte with s=1 (7FFF) / Highbyte with sz = 1- (7FFF)
;Highbytes are EOR #$80'd.
db $80, $00, $FF, $FF
;Inversion values for fractional value
db $7F, $FE, $00, $80

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
SPC_GeneratePulse_32:
;Low byte of first part
    MOV !PUL_OUT_INDEX_H, !PUL_OUT_PAGE
    MOV !PUL_OUT_INDEX_L, !PUL_DUTY
    AND !PUL_OUT_INDEX_L, #$C0
    MOV A, !PUL_DUTY        ;   Get finishing low index
    AND A, #$3E             ;__
    MOV Y, A                ;   If there are no bytes in the first part, skip the part
    BEQ +                   ;__
    MOV A, !PUL_FLAGS
    AND A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+1+X
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$00
    BNE -
;High byte of first part
    MOV A, !PUL_DUTY        ;
    AND A, #$3E             ;   Get finishing high index
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+X
    EOR A, #$80
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$01
    BNE -
+:
;Second part, the fractional value
    MOV A, !PUL_FLAGS           ;
    AND A, #$03                 ;
    MOV X, A                    ;   Get the inversion value into "temp variable"
    MOV A, SPC_GeneratePulse_128_LookupTable+4+X
    MOV !PUL_OUT_INDEX_L, A     ;__
    MOV A, !PUL_DUTY            ;
    LSR A                       ;   Get the actual fraction,
    MOV A, !PUL_FLAGS           ;   while also getting 
    ROR A                       ;   z flag into carry
    AND A, #$FE                 ;__
    BCC +                       ;   If z flag is set, 
    LSR A                       ;__ halve the fraction
+   EOR A, !PUL_OUT_INDEX_L     ;__ Invert the fraction as needed
    MOV Y, A
    MOV A, !PUL_DUTY            ;   Get index for the fraction
    AND A, #$FE                 ;
    MOV !PUL_OUT_INDEX_L, A     ;__
    MOV A, Y
    MOV Y, #$01
    MOV (!PUL_OUT_INDEX_L)+Y, A
    MOV A, #$00
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    INC !PUL_OUT_INDEX_L
    INC !PUL_OUT_INDEX_L
;Third part
    MOV A, !PUL_DUTY
    EOR A, #$FE
    AND A, #$3E
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$02
    EOR A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+1+X
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$00
    BNE -
;High byte of first part
    MOV A, !PUL_DUTY        ;   Get finishing high byte
    EOR A, #$3E             ;
    AND A, #$3E             ;
    OR A, #$01              ;__
    MOV Y, A
    MOV A, !PUL_FLAGS
    AND A, #$03
    EOR A, #$02
    MOV X, A
    MOV A, SPC_GeneratePulse_128_LookupTable+X
    EOR A, #$80
-:
    DEC Y
    DEC Y
    MOV (!PUL_OUT_INDEX_L)+Y, A
    CMP Y, #$01
    BNE -
+:
RET

;   Memory allocation:
;   Inputs:
;       $D0 - Carrier page
;       $D1 - Modulator page
;       $D2 - Output page
;       $D3 - Modulation strength
;   Temp variables:
;       $EA-EB - Output pointer
;       $EC-ED - Modulator pointer
;       $EE-EF - Main temp variable
SPC_PhaseModulation_128:
    MOV X, #$00
    MOV !MOD_OUT_INDEX_H, !MOD_OUT_PAGE
    MOV !MOD_MOD_INDEX_H, !MOD_MOD_PAGE
    MOV !MOD_OUT_INDEX_L, X
    MOV !MOD_MOD_INDEX_L, X
.loop:
    INC !MOD_MOD_INDEX_L
    MOV A, (!MOD_MOD_INDEX_L+X)
    MOV !MOD_MAIN_TEMP_H, A
    BMI SPC_PhaseModulation_128_loop_negative 
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
.loop_negative:
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
.loop_afterMul:

    LSR !MOD_MAIN_TEMP_H
    ROR A
    LSR !MOD_MAIN_TEMP_H
    ROR A
    LSR !MOD_MAIN_TEMP_H
    ROR A
    LSR !MOD_MAIN_TEMP_H
    ROR A
    LSR !MOD_MAIN_TEMP_H
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

;   Memory allocation:
;   Inputs:
;       $D0 - PCM sample page
;       $D1 - BRR output index
;       $D2 - Flags: fsi-ppbb 
;               f - whether to use filter mode 1
;               s - short sample mode (32 samples instead of 128)
;               i - high bit of output index 
;               pp - PCM sample subpage number (0-3, if s is set)
;               bb - BRR output subpage number (0-3, if s is set)
;   Temp variables:
;       $E5 - Temporary flags: bf-n----
;               b - whether it is the first block
;               f - whether to use filter mode 1
;               n - negative flag
;       $E6-$EB - 3 sample points
;       $F8-$F9 - Temporary space for 1 sample point
;       $EC-$ED - Input pointer
;       $EE-$EF - Output pointer
SPC_ConvertToBRR:
    SET7 !BRR_TEMP_FLAGS
    MOV !BRR_IN0_PTR_H, !BRR_PCM_PAGE;   Set up the PCM sample page
    MOV A, !BRR_FLAGS               ;__
    XCN A                           ;
    AND A, #$C0                     ;   Set up the PCM sample subpage 
    MOV !BRR_IN0_PTR_L, A           ;__
    MOV A, !BRR_FLAGS               ;
    AND A, #$40                     ;   Set up the ending low byte of the address
    CLRC                            ;
    ADC A, !BRR_IN0_PTR_L           ;__
    MOV !BRR_LSMPT_L, #$00          ;   
    MOV !BRR_LSMPT_H, #$00          ;__ smppoint = 0
    PUSH A
    PUSH A
    MOV Y, !BRR_OUT_INDEX           ;
    MOV A, !BRR_FLAGS               ;
    AND A, #$23                     ;   Get the sample pointer from index
    TCALL 11                        ;
    MOVW !BRR_OUT_PTR_L, YA         ;__

.SetupCopy:
    MOV X, #$20                     ;__ Set up the destination address (it's (X+))
    MOV Y, #$00
.CopyLoop:  ;Copy the PCM sample to the PCM buffer while halving it #
    MOV A, (!BRR_IN0_PTR_L)+Y       ;                               #
    MOV !BRR_CSMPT_L, A             ;                               #
    INCW !BRR_IN0_PTR_L             ;   Python code:                #
    MOV A, (!BRR_IN0_PTR_L)+Y       ;   currentsmppoint = array[i]  #
    MOV !BRR_CSMPT_H, A             ;                               #
    BPL +                           ;                               #
    EOR A, #$FF                     ;   Invert negative numbers     #
    EOR !BRR_CSMPT_L, #$FF          ;__                             #
+:                                  ;                               #
    INCW !BRR_IN0_PTR_L             ;__                             #
    CLRC                            ;   Python code:                #
    LSR A                           ;   currentsmppoint /= 2        #   OG Python code:
    ROR !BRR_CSMPT_L                ;__                             #   for i in range(len(BRRBuffer)):
    BBC7 !BRR_CSMPT_H, +            ;                               #       BRRBuffer[i] = (array[i&(length-1)])/2
    EOR A, #$FF                     ;   Invert negative numbers     #
    EOR !BRR_CSMPT_L, #$FF          ;__                             #
+:                                  ;                               #
    MOV !BRR_CSMPT_H, A             ;                               #
    MOV A, !BRR_CSMPT_L             ;                               #
    MOV (X+), A                     ;   Python code:                #
    MOV A, !BRR_CSMPT_H             ;   BRRBuffer[i]=currentsmppoint#
    MOV (X+), A                     ;                               #
    CMP X, #$40                     ;   Loop                        #
    BNE SPC_ConvertToBRR_CopyLoop   ;__                             #
.SetupFilter
    BBS7 !BRR_TEMP_FLAGS, SPC_ConvertToBRR_FirstBlock;   If this is the first block, Or filter 0 is forced,
    BBS7 !BRR_FLAGS, SPC_ConvertToBRR_FirstBlock     ;Skip doing filter 1 entirely   
    MOV X, #$00


    CLR4 !BRR_TEMP_FLAGS
    MOV !BRR_SMPPT_L, !BRR_LSMPT_L  ;   OG Python code:
    MOV !BRR_SMPPT_H, !BRR_LSMPT_H  ;__ currentsmppoint = 0
    BBC7 !BRR_SMPPT_H, +        ;                                       #
    SET4 !BRR_TEMP_FLAGS        ;   Inverting negative numbers          #
    EOR !BRR_SMPPT_L, #$FF      ;                                       #
    EOR !BRR_SMPPT_H, #$FF      ;__     
+:
    POP A
    MOV !BRR_CSMPT_H, A
    POP A
    MOV !BRR_CSMPT_L, A
    JMP SPC_ConvertToBRR_FilterLoop
.FirstBlock:

    MOV !BRR_MAXM0_L, #$FF
    MOV !BRR_MAXM0_H, #$7F
    MOV X, #$20
    JMP SPC_ConvertToBRR_BRREncoding_OuterLoop
.FilterLoop:

-:                              ;                                       #
    MOV Y, !BRR_SMPPT_L         ;                                       #
    MOV A, $0D00+Y              ;                                       #
    BBS4 !BRR_TEMP_FLAGS, +     ;                                       #                        
    CLRC                        ;   Python code:                        #
    ADC A, !BRR_CSMPT_L         ;   currentsmppoint += smppoint_L*15/16 #
    MOV !BRR_CSMPT_L, A         ;   (for positive numbers)              #
    ADC !BRR_CSMPT_H, #$00      ;                                       #
    JMP ++                      ;__                                     #
+:                              ;                                       #
    EOR A, #$FF                 ;                                       #
    SETC                        ;   Python code:                        #
    ADC A, !BRR_CSMPT_L         ;   currentsmppoint += smppoint_L*15/16 #
    MOV !BRR_CSMPT_L, A         ;   (for negative numbers)              #
    SBC !BRR_CSMPT_H, #$00      ;__                                     #
++:                             ;                                       #   OG Python code:
    MOV A, !BRR_SMPPT_H         ;                                       #   smppoint *= 0.9375
    MOV Y, #$F0                 ;   Python code:                        #   smppoint += BRRBuffer[i]
    MUL YA                      ;__ smpppoint_H *=15                    #
    BBC4 !BRR_TEMP_FLAGS, +     ;                                       #
    MOV !BRR_SMPPT_H, Y         ;   Invert negative                     #
    EOR A, #$FF                 ;                                       #
    EOR !BRR_SMPPT_H, #$FF      ;__                                     #
    MOV Y, !BRR_SMPPT_H         ;                                       #
+:                              ;   Python code:                        #
    ADDW YA, !BRR_CSMPT_L       ;   smppoint_H<<8 += currentsmppoint    #
    MOVW !BRR_SMPPT_L, YA       ;__                                     #__



    CLR4 !BRR_TEMP_FLAGS
    MOV A, !BRR_BUFF1_PTR_L+X   ;                                       #
    MOV !BRR_CSMPT_L, A         ;                                       #
    MOV A, !BRR_BUFF1_PTR_H+X   ;   currentsmppoint = BRRBuffer[i]      #
    MOV !BRR_CSMPT_H, A         ;                                       #
    MOVW YA, !BRR_CSMPT_L       ;   Python code:                        #   OG Python code:
    SUBW YA, !BRR_SMPPT_L       ;   currentsmppoint -= smppoint         #   BRRBuffer[i] -= smppoint
    MOVW !BRR_CSMPT_L, YA       ;__                                     #
    MOV (X+), A   ;                                       #
    MOV A, !BRR_CSMPT_H         ;   BRRBuffer[i] = currentsmppoint      #
    MOV (X+), A   ;__                                     #
    BBC7 !BRR_SMPPT_H, +        ;                                       #
    SET4 !BRR_TEMP_FLAGS        ;   Inverting negative numbers          #
    EOR !BRR_SMPPT_L, #$FF      ;                                       #
    EOR !BRR_SMPPT_H, #$FF      ;__                                     #
+   CMP X, #$20                 ;   Loop                                #
    BNE SPC_ConvertToBRR_FilterLoop;__ 
    
    MOV !BRR_LSMPT_L, !BRR_SMPPT_L
    MOV !BRR_LSMPT_H, !BRR_SMPPT_H
    BBC4 !BRR_TEMP_FLAGS, SPC_ConvertToBRR_BRREncoding
    EOR !BRR_LSMPT_L, #$FF
    EOR !BRR_LSMPT_H, #$FF
    CLR4 !BRR_TEMP_FLAGS

.BRREncoding:
    SET6 !BRR_TEMP_FLAGS
    MOV X, #$00
..OuterLoop:
    MOV A, (X+)   
    MOV !BRR_SMPPT_L, A         
    MOV A, (X+)
    BPL +
    EOR !BRR_SMPPT_L, #$FF
    EOR A, #$FF
+:
    MOV !BRR_SMPPT_H, A         
..MaximumFilter1:
    MOV A, (X+)  
    MOV !BRR_CSMPT_L, A         
    MOV A, (X+)  
    BPL +
    EOR !BRR_CSMPT_L, #$FF
    EOR A, #$FF
+:
    MOV Y, A
    MOV A, !BRR_CSMPT_L
    CMPW YA, !BRR_SMPPT_L
    BMI +
    MOVW !BRR_SMPPT_L, YA
+:
    MOV A, X
    AND A, #$1F
    BNE SPC_ConvertToBRR_BRREncoding_MaximumFilter1
    CMP X, #$40
    BEQ +
    MOVW YA, !BRR_SMPPT_L
    MOVW !BRR_MAXM0_L, YA
    ;Set up the routine for maximum in the OG PCM buffer
    JMP  SPC_ConvertToBRR_BRREncoding_OuterLoop
+:
    MOV X, #$00
    MOVW YA, !BRR_SMPPT_L
    CMPW YA, !BRR_MAXM0_L
    BPL +
    MOVW !BRR_MAXM0_L, YA
    MOV X, #$20
    CLR6 !BRR_TEMP_FLAGS
+: 
..ShiftValuePart1:
    MOV Y, #12
    MOV A, !BRR_MAXM0_H
    BEQ +
-
    ASL A
    BCS SPC_ConvertToBRR_BRREncoding_CheckIf8
    DEC Y
    CMP Y, #$04
    BNE -
+
    MOV Y, #$04
..ShiftValuePart2:
    MOV A, !BRR_MAXM0_L
    CLRC
-
    ASL A
    BCS SPC_ConvertToBRR_BRREncoding_CheckIf8
    DEC Y
    BNE -
    JMP SPC_ConvertToBRR_FormHeader
..CheckIf8:
    CMP Y, #$05
    BEQ +
    CMP Y, #$06
    BNE SPC_ConvertToBRR_BRREncoding_Check8
; Executed if Y = 6, aka the high bit to check is in the high byte and the low bit is in low byte
    BBS0 !BRR_MAXM0_H, SPC_ConvertToBRR_FormHeader
    BBS7 !BRR_MAXM0_L, SPC_ConvertToBRR_FormHeader
    JMP ++
+   MOV A, !BRR_MAXM0_L ;Executed if Y = 5, aka both bits to check are in the low byte
..Check8:   ;Executed if Y = 1..4 or Y = 7..12 - aka the bits to check are in the same byte
    ASL A
    BCS SPC_ConvertToBRR_FormHeader
    ASL A
    BCC ++      ; = BCS FormHeader; JMP +
.FormHeader:
    INC Y
++:
    MOV !BRR_MAXM0_L, Y ;
    MOV A, Y            ;   Get the shift value
    OR A, #%00100000    ;   Set the loop flag
    POP Y               ;   Get the ending low byte
    CMP Y, !BRR_IN0_PTR_L
    BNE +               ;   Set the end flag if it's the last block
    OR A, #%00010000    ;__
+:
    MOV !BRR_MAXM0_H, !BRR_TEMP_FLAGS;   Set the filter to 1
    AND !BRR_MAXM0_H, #%01000000    ;   if appropriate
    OR A, !BRR_MAXM0_H              ;__
    XCN A                           ;__ Swap the nybbles to make a valid header
    MOV Y, #$00                     ;
    MOV (!BRR_OUT_PTR_L)+Y, A       ;   Write the header out
    INCW !BRR_OUT_PTR_L             ;__
.FormData:
    CLR4 !BRR_TEMP_FLAGS
    MOV A, (X+)
    MOV !BRR_CSMPT_L, A
    MOV A, (X+)
    BPL +
    EOR A, #$FF
    EOR !BRR_CSMPT_L, #$FF
    SET4 !BRR_TEMP_FLAGS
+:
    MOV !BRR_CSMPT_H, A ;
    MOV Y, !BRR_CSMPT_L ;
    MOV A, $0C00+Y      ;
    MOV !BRR_CSMPT_L, A ;
    MOV Y, !BRR_CSMPT_H ;
    MOV A, #$E0         ;   7/8 multiplication
    MUL YA              ;
    MOV !BRR_CSMPT_H, Y ;
    CLRC                ;
    ADC A, !BRR_CSMPT_L ;
    MOV !BRR_CSMPT_L, A ;__
    MOV A, !BRR_CSMPT_H
    AND A, #$7F
    MOV Y, !BRR_MAXM0_L
    CMP Y, #$05
    BMI +
-:
    CLRC
    LSR A
    ROR !BRR_CSMPT_L
    DEC Y
    CMP Y, #$04
    BNE -
+:
    MOV A, !BRR_CSMPT_L
    CMP Y, #$00
    BEQ +
-:
    CLRC
    LSR A
    DEC Y
    BNE -
+:
    AND A, #$07
    ADC A, #$00
    CMP A, #$08
    BMI +
    MOV A, #$07
+   BBC4 !BRR_TEMP_FLAGS, +
    EOR A, #$0F
    INC A
    CMP A, #$10
    BMI +
    DEC A
+   PUSH A
    MOV A, X
    AND A, #$03
    BNE SPC_ConvertToBRR_FormData
    POP A
    MOV !BRR_CSMPT_L, A
    POP A
    XCN A
    OR A, !BRR_CSMPT_L
    MOV (!BRR_OUT_PTR_L)+Y, A       ;   Write the data out
    INCW !BRR_OUT_PTR_L             ;__
    MOV A, X
    AND A, #$1F
    BNE SPC_ConvertToBRR_FormData
    CLR7 !BRR_TEMP_FLAGS
    POP A                           ;
    CMP A, !BRR_IN0_PTR_L           ;   If this is the last block, end
    BEQ SPC_ConvertToBRR_End        ;__
    PUSH A                          ;   If it ain't, push the finishing low byte back
    PUSH A                          ;__      
    BBS7 !BRR_FLAGS, ++             ;
+   CMP X, #$20                     ;   
    BNE +                           ;   If we just used filter mode 1, 
    MOV A, $1E                      ;
    PUSH A                          ;   currentsmppoint = BRRBuffer[last]
    MOV A, $1F                      ;
    PUSH A                          ;__
++  JMP SPC_ConvertToBRR_SetupCopy
+:                                  ;   If we just used filter mode 0,   
    MOV !BRR_LSMPT_L, $3E           ;   smppoint = BRRBuffer[last]
    MOV !BRR_LSMPT_H, $3F           ;__
    MOV A, #$00                     ;
    PUSH A                          ;   currentsmppoint = 0
    PUSH A                          ;__
    JMP SPC_ConvertToBRR_SetupCopy
.End:
    
ret

.LookuptableMul18:
db $00, $12, $24, $36


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
    MOV SPC_SetFlagdp_act, A
    MOV A, $D0
    MOV SPC_SetFlagdp_act+1, A
.act:
    SET1 $00
    RET

SPC_ClrFlagdp:  ;TCALL 12

    MOV A, X
    ASL A
    ASL A
    AND A, #$E0
    OR A, #$12
    MOV SPC_ClrFlagdp_act, A
    MOV A, $D0
    MOV SPC_ClrFlagdp_act+1, A
.act:
    CLR1 $00
    RET

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
SPC_IndexToSamplePointer: ;TCALL 11
    PUSH A                      ;
    PUSH A                      ;
    MOV A, #$48                 ;   Use main byte of index
    MUL YA                      ;
    MOVW $EE, YA                ;
    POP A                       ;__
    AND A, #$03                 ;
    MOV Y, A                    ;   Set up the BRR sample subpage
    MOV A, SPC_IndexToSamplePointer_LookuptableMul18+Y
    MOV Y, #$00                 ;
    ADDW YA, $EE                ;
    MOVW $EE, YA                ;__
    POP A                       ;
    AND A, #$FC                 ;
    BEQ +                       ;   Apply the high bit
    CLRC                        ;
    ADC $EF, #$48               ;__
+:                              ;
    CLRC                        ;   Actually make it a valid pointer
    ADC $EF, #$60               ;__
    MOVW YA, $EE                ;   Return with pointer in YA
RET                             ;__
.LookuptableMul18:
db $00, $12, $24, $36

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
    incsrc "songData.asm"
org $0A00
    ;instrument data pointers
    dw Instr00Data, Instr01Data, Instr02Data, Instr03Data
org $FFC0   ;For TCALLs
    dw SPC_transferChToTemp, SPC_transferTempToCh, SPC_SetFlagdp, SPC_ClrFlagdp, SPC_IndexToSamplePointer
startpos init