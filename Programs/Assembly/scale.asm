; SCALE.ASM - Play C major, C4 to C5, once on SID-Ulator voice 1.
;
; Register port D4, data port D5. Nominal SID clock: 1 MHz.
; Triangle wave, volume 10
; Clears registers 0-24 and mutes on completion
; At 7.3728 MHz: about 0.46 seconds per note and 0.058 seconds per gap.
;
; Uses AF, B, DE and HL; returns to SCM with its existing stack.
LD B,$19
; CLEAR at 8002
DEC B
LD A,B
OUT ($D4),A
XOR A
OUT ($D5),A
LD A,B
OR A
JP NZ,$8002
; Voice 1 envelope: fastest attack/decay/release, maximum sustain.
LD A,$05
OUT ($D4),A
LD A,$00
OUT ($D5),A
LD A,$06
OUT ($D4),A
LD A,$F0
OUT ($D5),A
LD A,$18
OUT ($D4),A
LD A,$0A
OUT ($D5),A
; C4: frequency word 4389.
LD HL,$1125
CALL $8065
; D4: frequency word 4927.
LD HL,$133F
CALL $8065
; E4: frequency word 5530.
LD HL,$159A
CALL $8065
; F4: frequency word 5859.
LD HL,$16E3
CALL $8065
; G4: frequency word 6577.
LD HL,$19B1
CALL $8065
; A4: frequency word 7382.
LD HL,$1CD6
CALL $8065
; B4: frequency word 8286.
LD HL,$205E
CALL $8065
; C5: frequency word 8779.
LD HL,$224B
CALL $8065
; Stop voice 1 and mute master volume before returning to SCM.
LD A,$04
OUT ($D4),A
XOR A
OUT ($D5),A
LD A,$18
OUT ($D4),A
XOR A
OUT ($D5),A
RET
; PLAY at 8065
; HL = frequency word; low byte to register 0, high byte to register 1.
XOR A
OUT ($D4),A
LD A,L
OUT ($D5),A
LD A,$01
OUT ($D4),A
LD A,H
OUT ($D5),A
LD A,$04
OUT ($D4),A
LD A,$11
OUT ($D5),A
; Two long delays hold the note; change both DE values to change length.
LD DE,$FFFF
CALL $8095
LD DE,$FFFF
CALL $8095
; Gate off, preserving triangle waveform; allow envelope to release.
LD A,$04
OUT ($D4),A
LD A,$10
OUT ($D5),A
LD DE,$4000
CALL $8095
RET
; DELAY at 8095
; 26 T-states per iteration; DE must be nonzero. Destroys A and DE.
DEC DE
LD A,D
OR E
JP NZ,$8095
RET
