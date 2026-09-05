; MESSAGE_LCD.ASM
;
; Print a zero-terminated message at 8100 on the LCD (first line, max 16 chars).
; RC2014 LCD Driver Module: command/status DA, data DB; 16x2 HD44780 display.
;
; Enter the message into memory at address 8100, per the README, before running
; the program.
;
CALL $8054
LD A,$30
OUT ($DA),A
CALL $8054
LD A,$30
OUT ($DA),A
CALL $8054
LD A,$30
OUT ($DA),A
CALL $8054
; Configure two lines, blank the display, clear it, increment cursor, display on.
LD A,$38
CALL $8044
LD A,$08
CALL $8044
LD A,$01
CALL $8044
LD A,$06
CALL $8044
LD A,$0C
CALL $8044
; Print at most 16 characters from the zero-terminated message at 8100.
LD HL,$8100
LD B,$10
LD A,(HL)
OR A
RET Z
CALL $804A
OUT ($DB),A
INC HL
DEC B
JP NZ,$8036
RET
; Send the command in A after waiting for the LCD.
CALL $804A
OUT ($DA),A
RET
; Wait for busy flag (bit 7) to clear, preserving A and the flags.
PUSH AF
IN A,($DA)
AND $80
JP NZ,$804B
POP AF
RET
; Startup delay: approximately 0.23 seconds at 7.3728 MHz. Destroys A and DE.
LD DE,$FFFF
DEC DE
LD A,D
OR E
JP NZ,$8057
RET
