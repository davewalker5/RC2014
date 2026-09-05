; BUTTONS.ASM
;
; Read the state of the Digital I/O card buttons and light the corresponding
; LEDs for any that are pressed
;
; The second parameter to IN supplies the Digital I/O card input port number
; The first parameter to OUT supplies the Digital I/O card output port number
;
IN A,($01)
OUT ($01),A
RET
