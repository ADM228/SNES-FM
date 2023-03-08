
;==== FRIENDLY HEADER BY alexmush ====;
!MAPMODE = $30
!ROMTYPE = $02
!ROMSIZE = $09      ; = 512 Kibibytes
!SRAMSIZE = $09     ; = 512 Kibibytes (impossible apparently)
!COUNTRY = $00      ;   International
!DEVNAME = $00
!VERSION = $00
!CHECKSUM = $7329
!CHECKSUMCOMPLEMENT = $BCD6
;=== Interrupt vectors ===;
!NAT_COP = $813E    ; Software interrupt. Triggered by the COP instruction. Similar to BRK. 
!NAT_BRK = $813E    ; Software interrupt. Triggered by the BRK instruction. Similar to COP. 
!NAT_ABORT = $813E  ; Not used in the SNES. 
!NAT_NMI = NMI_Routine&$FFFF; Non-maskable interrupt. Called when vertical refresh (vblank) begins. 
!NAT_IRQ = $813E    ; Interrupt request. Can be set to be called at a certain spot in the horizontal refresh cycle. 

!EMU_COP = $813E    ; Software interrupt. Triggered by the COP instruction. 
!EMU_ABORT = $813E  ; Not used in the SNES. 
!EMU_NMI = $8160    ; Non-maskable interrupt. Called when vertical refresh (vblank) begins. 
!EMU_RES = $811C    ; Reset vector, execution begins via this vector. 
!EMU_IRQBRK = $813E ; Interrupt request. Can be set to be called at a certain spot in the horizontal refresh cycle. Also a software interrupt triggered by the BRK instruction. 

;=== Actually setting the sh*t ===;
org $00fFC0 ;adress of the header 
db "SNESFM Tracker/DAW   ",!MAPMODE,!ROMTYPE,!ROMSIZE,!SRAMSIZE,!COUNTRY,!DEVNAME,!VERSION
dw !CHECKSUM,!CHECKSUMCOMPLEMENT
org $00Ffb2
db "SNES"
org $00FFE4 ;native interrupt vectors
dw !NAT_COP, !NAT_BRK, !NAT_ABORT, !NAT_NMI, $0000, !NAT_IRQ
org $00FFF4
dw !EMU_COP, $0000, !EMU_ABORT, !EMU_NMI, !EMU_RES, !EMU_IRQBRK
