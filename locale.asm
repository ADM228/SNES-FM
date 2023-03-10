org $838000
LocaleENG:  ;English
    .Banks:
        db $00, $01, $00, $01
    .Channel:
        db %00000000, $43, $68, $61, $6E, $6E, $65, $6C, $20  ;"Channel "


org $838400
LocaleGRE:  ;Greek
    .Banks:
        db $00, $01, $02, $02
    ;I don't speak greek


org $838800
LocaleRUS:  ;Russian
    .Banks:
        db $00, $01, $03, $03
    .Channel:
        db %11111000, $1A, $30, $3D, $30, $3B, $20, $20, $20  ;"Канал   "


org $838C00
LocaleJPN:  ;Japanese
    .Banks:
        db $00, $01, $04, $05
    ;I also don't speak Japanese