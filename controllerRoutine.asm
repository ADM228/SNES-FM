    PHA
    PHP
    REP #%00100000 ;set xy to 8bit
    SEP #%00010000 ;set a to 16bit
CPU_ControllerRead_WaitLoop:
    LSR $4212
    BCS CPU_ControllerRead_WaitLoop
LDA $4218
AND #$000F
ASL A
TAX 
JMP (CPU_ControllerRead_RoutineTable, X)
CPU_ControllerRead_RoutineTable:
    dw CPU_ControllerRead_0_RoutineHandler;SNES Joypad
    dw CPU_ControllerRead_End           ;SNES Mouse
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End           ;NTT Data Pad
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End
    dw CPU_ControllerRead_End           ;Konami Justifier + other shit
    dw CPU_ControllerRead_End           ;Super Scope

; Routines for controllers

; Controller 0 - Standard joypad

CPU_ControllerRead_0_RoutineHandler:
    LDA $4218
    STA $00     ;Joypad data 
    LDX #$00
CPU_ControllerRead_0_Loop:
    ROL $00
    BCC CPU_ControllerRead_0_AfterLoop
    JSR (CPU_ControllerRead_RoutineTable0, X)
CPU_ControllerRead_0_AfterLoop:
    INX
    INX
    CPX #$18
    BNE CPU_ControllerRead_0_Loop
    JMP CPU_ControllerRead_End
CPU_ControllerRead_RoutineTable0:   ;The jump table for the standard joypad (signature 0000)
    dw CPU_ControllerRead_0_EmptyRTS    ;B
    dw CPU_ControllerRead_0_EmptyRTS    ;Y
    dw CPU_ControllerRead_0_EmptyRTS    ;Select
    dw CPU_ControllerRead_0_EmptyRTS    ;Start
    dw CPU_ControllerRead_0_EmptyRTS    ;Up
    dw CPU_ControllerRead_0_EmptyRTS    ;Down
    dw CPU_ControllerRead_0_Left        ;Left
    dw CPU_ControllerRead_0_Right       ;Right
    dw CPU_ControllerRead_0_EmptyRTS    ;A
    dw CPU_ControllerRead_0_EmptyRTS    ;X
    dw CPU_ControllerRead_0_EmptyRTS    ;L
    dw CPU_ControllerRead_0_EmptyRTS    ;R

CPU_ControllerRead_0_Left:
    LDA $FF
    DEC A
    AND #$003F
    STA $00
    JSR UpdateRow
    JMP UpdateColumn    ;This is a subroutine so the RTS is contained there

CPU_ControllerRead_0_Right:
    LDA $FF
    INC A
    AND #$003F
    STA $00
    JSR UpdateRow
    JMP UpdateColumn    ;This is a subroutine so the RTS is contained there

CPU_ControllerRead_0_EmptyRTS:
    RTS

CPU_ControllerRead_End:
;