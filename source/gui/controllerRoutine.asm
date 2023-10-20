namespace ControllerRead
Wait:
    REP #%00100000 ;set xy to 8bit
    SEP #%00010000 ;set a to 16bit
    NOP #16
    .Loop:
        LSR $4212
        BCS Wait_Loop
    LDA $4218
    AND #$000F
    ASL A
    TAX 
    JMP (HandlerTable, X)
HandlerTable:
    dw StandardJoy_RoutineHandler;SNES Joypad
    dw End           ;SNES Mouse
    dw End
    dw End
    dw End           ;NTT Data Pad
    dw End
    dw End
    dw End
    dw End
    dw End
    dw End
    dw End
    dw End
    dw End
    dw End           ;Konami Justifier + other shit
    dw End           ;Super Scope

; Routines for controllers

; Controller 0 - Standard joypad
namespace StandardJoy
    RoutineHandler:
        LDA $4218
        STA $0E     ;Joypad data 
        LDX #$00
    Loop:
        ROL $0E
        BCC +
            JSR (RoutineTable, X)
        + INX
        INX
        CPX #$18
        BNE Loop
        JMP End
    RoutineTable:   ;The jump table for the standard joypad (signature 0000)
        dw EmptyRTS    ;B
        dw EmptyRTS    ;Y
        dw EmptyRTS    ;Select
        dw EmptyRTS    ;Start
        dw Up          ;Up
        dw Down        ;Down
        dw EmptyRTS    ;Left
        dw EmptyRTS    ;Right
        dw EmptyRTS    ;A
        dw EmptyRTS    ;X
        dw EmptyRTS    ;L
        dw EmptyRTS    ;R

    Up:
        LDA $FF
        DEC A
        AND #$003F
        STA $00
        LDA $0E
        AND #$7FFF  ;Disable Up&Down at the same time
        STA $0E
        JMP ScrollHeaderTrackerMode ;This is a subroutine so the RTS is contained there

    Down:
        LDA $FF
        INC A
        AND #$003F
        STA $00
        JMP ScrollHeaderTrackerMode ;This is a subroutine so the RTS is contained there


    EmptyRTS:
        RTS

namespace off


namespace NTTDataPad
namespace off
 
namespace off


End:
;

;Concepts:
;NTT Data Pad usage:
;Tracker mode:
    ;DPAD - Scroll around
    ;L/R - -/+ Octave
    ;</> - Change instrument page
    ;End transmission - Open menu
    ;123*456#7890 - Input note and scroll down
    ;C - Undo
    ;. - Paste
    ;X - Switch to instrument selection mode
    ;Y - Erase note & instrument (when in note or instrument cell) / Clear effect value (when in effect cell)
    ;B - Place note keyoff (when in note cell) / clear instrument (when in instrument cell) / open effects list (when in effect cell)
    ;A - Button combinations:
        ;A + L/R - Change note's octave
        ;A + 123*456#7890 - Change note to button
        ;A + Up/Down - Change note/instrument/effect value by 1
        ;A + Left/Right - Change note value by 4 / Change Instrument value by 8 / Change effect value by 16
        ;A + C - Redo
        ;A + . - Copy
        ;A + X + . - Cut