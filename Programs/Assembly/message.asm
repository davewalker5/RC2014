; MESSAGE.ASM
;
; Display a message on the console.
;
; Enter the message into memory at address 8100, per the README, before running
; the program.
;
LD DE,$8100
LD C,6
CALL $30
LD C,7
CALL $30
RET
