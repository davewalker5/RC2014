; LED.ASM
;
; Light LEDs on the digital I/O card
;
; | Value | LED pattern               |
; | ----- | ------------------------- |
; | $AA   | Opposite alternating LEDs |
; | $FF   | All on                    |
; | $00   | All off                   |
; | $01   | Only bit 0 on             |
; 
; The first parameter to OUT supplies the Digital I/O card port number
;
LD A,$55
OUT ($01),A
RET
