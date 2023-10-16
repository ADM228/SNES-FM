    !SNESFM_CFG_EXTERNAL = 1

    !SNESFM_CFG_SAMPLE_GENERATE = 1

    !SNESFM_CFG_PHASEMOD = 1
    !SNESFM_CFG_PULSEGEN = 1

    !SNESFM_CFG_LONG_SMP_GEN = 1
    !SNESFM_CFG_SHORTSMP_GEN = 1

    !SNESFM_CFG_PITCHTABLE_GEN = 1
    
    incsrc "SNESFM.asm"

    namespace SPC
    org $1F00
        ; Song data
        incsrc "instrumentData.asm"
    org $0A00
		ParseInstrumentData_InstrumentPtrLo:
        ;instrument data pointers
        db Instr00Data&$FF, Instr01Data&$FF, Instr02Data&$FF, Instr03Data&$FF
    org $0B00
		ParseInstrumentData_InstrumentPtrHi:
        db (Instr00Data>>8)&$FF, (Instr01Data>>8)&$FF, (Instr02Data>>8)&$FF, (Instr03Data>>8)&$FF

    startpos Init

    namespace off