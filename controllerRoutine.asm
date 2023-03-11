CPU_ControllerRead:
    PHA
    PHP
    REP #%00100000 ;set xy to 8bit
    SEP #%00010000 ;set a to 16bit
    .WaitLoop:
        LSR $4212
        BCS CPU_ControllerRead_WaitLoop
    LDA $4218
    AND #$000F
    ASL A
    TAX 
    JMP (CPU_ControllerRead_RoutineTable, X)
.RoutineTable:
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

.0:
    ..RoutineHandler:
        LDA $4218
        STA $0E     ;Joypad data 
        LDX #$00
    ..Loop:
        ROL $0E
        BCC CPU_ControllerRead_0_AfterLoop
        JSR (CPU_ControllerRead_0_RoutineTable, X)
    ..AfterLoop:
        INX
        INX
        CPX #$18
        BNE CPU_ControllerRead_0_Loop
        JMP CPU_ControllerRead_End
    ..RoutineTable:   ;The jump table for the standard joypad (signature 0000)
        dw CPU_ControllerRead_0_EmptyRTS    ;B
        dw CPU_ControllerRead_0_EmptyRTS    ;Y
        dw CPU_ControllerRead_0_EmptyRTS    ;Select
        dw CPU_ControllerRead_0_EmptyRTS    ;Start
        dw CPU_ControllerRead_0_Up          ;Up
        dw CPU_ControllerRead_0_Down        ;Down
        dw CPU_ControllerRead_0_EmptyRTS    ;Left
        dw CPU_ControllerRead_0_EmptyRTS    ;Right
        dw CPU_ControllerRead_0_EmptyRTS    ;A
        dw CPU_ControllerRead_0_EmptyRTS    ;X
        dw CPU_ControllerRead_0_EmptyRTS    ;L
        dw CPU_ControllerRead_0_EmptyRTS    ;R

    ..Up:
        LDA $FF
        DEC A
        AND #$003F
        STA $00
        JMP ScrollHeaderTrackerMode ;This is a subroutine so the RTS is contained there

    ..Down:
        LDA $FF
        INC A
        AND #$003F
        STA $00
        JMP ScrollHeaderTrackerMode ;This is a subroutine so the RTS is contained there

    ..EmptyRTS:
        RTS

.End:
;