incsrc "header.asm"
incsrc "initSNES.asm"

org $00FFFF

org $008129
    lda #$80            ; = 10000000
    sta $2100           ; Turn on screen, full brightness

Loop:
    BRA Loop