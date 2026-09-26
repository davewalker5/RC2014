; Daisy Bell: SID-Ulator plus MG005, Z80 player for the RC2014 Mini II.
; Assemble the GENERATED daisy-chorus.asm with standalone z80asm.
; This labelled source is NOT input for SCM's interactive assembler.
;
; Python inserts music and speech tables at the two markers below. Musical
; timestamps come from the full MIDI arrangement and tuned speech lines. Python
; also calculates SID frequency bytes and gate changes: no floating-point
; arithmetic or string processing occurs during playback.
;
; Entry: CALL PLAYER_ORIGIN (or SCM G E000), with a valid caller stack.
; Exit: RET, preserving AF/BC/DE/HL/IX/IY and leaving alternate registers alone.
; Interrupt mode and enable state are untouched. No firmware calls are made.
; Caller interrupts/wait states add time; use the normal 7.3728 MHz CPU clock.
; The image and private variables must be in writable RAM reserved from BASIC.
;
; Fixed header, useful from SCM's M command or a future BASIC USR loader:
;   E000: JP start
;   E003: result (255 = running, 0 = complete, 1 = speech timeout)
;   E004: count of syllables submitted more than 100 ms after their cue
;   E005: current tick, little-endian; one tick is nominally 5 ms
; All state is reset on every entry, so G E000 can replay the loaded image.

PLAYER_ORIGIN: EQU 0E000H
SID_REGISTER:  EQU 0D4H
SID_DATA:      EQU 0D5H
SPEECH_PORT:   EQU 01FH
SPEECH_READY:  EQU 2
WAVEFORM:      EQU 16             ; Triangle, with gate bit initially clear.
VOLUME:        EQU 2              ; SID master volume 0-15.

; Delay calibration: DEC BC / LD A,B / OR C / JR NZ costs 26 T-states
; per iteration, except the final branch (5 fewer). Including CALL, LD BC
; and RET, the complete delay costs 26 * DELAY_LOOPS + 32 T-states.
; 1416 gives 36848 T-states, about 4.998 ms at 7.3728 MHz.
; The scheduler adds a small, variable overhead. This is NOT a hardware clock
; or a fully cycle-balanced loop. Increase DELAY_LOOPS to slow the tune and
; allow more time for speech; decrease it to speed up. Use 1-65535, never 0.
; Changing CPU speed requires proportional recalibration; SID pitch still
; assumes a separate 1 MHz SID clock.
DELAY_LOOPS:   EQU 1416
LATE_TICKS:    EQU 20             ; More than 20 ticks = more than 100 ms late.
DRAIN_TICKS:   EQU 200            ; Nominal second after the final command.
TIMEOUT_TICK:  EQU 11600 ; Music duration plus 4 seconds backlog.

    ORG PLAYER_ORIGIN
    JP START
RESULT:
    DB 255
LATE_SYLLABLES:
    DB 0
CURRENT_TICK:
    DW 0

START:
    ; Keep the caller's stack and register values so SCM can resume normally.
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    PUSH IX
    PUSH IY

    XOR A
    LD (LATE_SYLLABLES),A
    LD (MUSIC_DONE),A
    LD (SPEECH_DONE),A
    LD HL,0
    LD (CURRENT_TICK),HL
    LD (DRAIN_UNTIL),HL
    LD A,255
    LD (RESULT),A
    LD IX,MUSIC_DATA
    LD IY,SPEECH_DATA

    ; Clear all 25 SID registers, including volume and gates, before setup.
    ; OUT uses the low eight address bits, as in the project's BASIC examples.
    LD B,25
    LD C,0
CLEAR_SID:
    LD A,C
    OUT (SID_REGISTER),A
    XOR A
    OUT (SID_DATA),A
    INC C
    DJNZ CLEAR_SID

    ; Three identical envelopes: immediate attack/decay, full sustain and
    ; immediate release. The tables carry the per-voice triangle/gate writes.
    LD A,6
    OUT (SID_REGISTER),A
    LD A,240
    OUT (SID_DATA),A
    LD A,13
    OUT (SID_REGISTER),A
    LD A,240
    OUT (SID_DATA),A
    LD A,20
    OUT (SID_REGISTER),A
    LD A,240
    OUT (SID_DATA),A
    LD A,24
    OUT (SID_REGISTER),A
    LD A,VOLUME
    OUT (SID_DATA),A

PLAYBACK_LOOP:
    ; Always service due SID events first. A busy speech chip must never
    ; hold up music. IX and IY retain the next unconsumed table positions.
    CALL SERVICE_MUSIC
    CALL SERVICE_SPEECH

    LD A,(MUSIC_DONE)
    LD B,A
    LD A,(SPEECH_DONE)
    AND B
    JR Z,CHECK_TIMEOUT

    ; Both streams are submitted, but ready is not an acoustic completion
    ; signal. Allow a short tail for the final allophone and terminating PA1.
    LD HL,(DRAIN_UNTIL)
    LD A,H
    OR L
    JR NZ,CHECK_DRAIN
    LD HL,(CURRENT_TICK)
    LD DE,DRAIN_TICKS
    ADD HL,DE
    LD (DRAIN_UNTIL),HL
CHECK_DRAIN:
    LD DE,(DRAIN_UNTIL)
    LD HL,(CURRENT_TICK)
    OR A                        ; Clear carry before unsigned subtraction.
    SBC HL,DE
    JR C,NEXT_TICK
    XOR A                       ; Result 0: all commands submitted.
    JR FINISH

CHECK_TIMEOUT:
    ; Allow four seconds after the full arrangement for pending speech,
    ; then return instead of hanging on a permanently busy card.
    LD HL,(CURRENT_TICK)
    LD DE,TIMEOUT_TICK
    OR A
    SBC HL,DE
    JR C,NEXT_TICK
    LD A,1                      ; Result 1: speech still pending at the deadline.
    JR FINISH

NEXT_TICK:
    CALL WAIT_TICK
    LD HL,(CURRENT_TICK)
    INC HL
    LD (CURRENT_TICK),HL
    JR PLAYBACK_LOOP

FINISH:
    LD (RESULT),A
    ; Every exit releases all gates and mutes the SID. A speech command already
    ; accepted by the MG005 cannot be cancelled through this interface.
    LD A,4
    OUT (SID_REGISTER),A
    LD A,WAVEFORM
    OUT (SID_DATA),A
    LD A,11
    OUT (SID_REGISTER),A
    LD A,WAVEFORM
    OUT (SID_DATA),A
    LD A,18
    OUT (SID_REGISTER),A
    LD A,WAVEFORM
    OUT (SID_DATA),A
    LD A,24
    OUT (SID_REGISTER),A
    XOR A
    OUT (SID_DATA),A
    POP IY
    POP IX
    POP HL
    POP DE
    POP BC
    POP AF
    RET

SERVICE_MUSIC:
    ; Record: DW absolute tick, DB pair count, then register/value byte pairs.
    ; FFFF is an end marker, never a real cue. IX advances only after an event
    ; is due. Registers changed: AF, BC, HL, IX. Other table state is untouched.
    LD A,(MUSIC_DONE)
    OR A
    RET NZ
MUSIC_NEXT:
    LD C,(IX+0)
    LD B,(IX+1)
    LD A,B
    AND C
    CP 255
    JR Z,MUSIC_FINISHED
    LD HL,(CURRENT_TICK)
    OR A
    SBC HL,BC
    RET C                       ; The next event belongs to a future tick.
    LD B,(IX+2)
    INC IX
    INC IX
    INC IX
    LD A,B
    OR A
    JR Z,MUSIC_NEXT              ; A no-op event is valid; avoid DJNZ underflow.
MUSIC_WRITE:
    LD A,(IX+0)
    OUT (SID_REGISTER),A
    LD A,(IX+1)
    OUT (SID_DATA),A
    INC IX
    INC IX
    DJNZ MUSIC_WRITE
    JR MUSIC_NEXT               ; Consume every event due at this tick.
MUSIC_FINISHED:
    LD A,1
    LD (MUSIC_DONE),A
    RET

SERVICE_SPEECH:
    ; Record: DW absolute tick, DB allophone, DB first-code flag (0 or 1).
    ; All codes of a syllable share a cue. Send at most one per scheduler pass:
    ; the next pass checks readiness again, leaving time for the hardware
    ; handshake. Never spin waiting for the chip, or drop a late allophone.
    ; Registers changed: AF, BC, DE, HL, IY.
    LD A,(SPEECH_DONE)
    OR A
    RET NZ
    LD C,(IY+0)
    LD B,(IY+1)
    LD A,B
    AND C
    CP 255
    JR Z,SPEECH_FINISHED
    LD HL,(CURRENT_TICK)
    OR A
    SBC HL,BC
    RET C
    IN A,(SPEECH_PORT)
    AND SPEECH_READY
    RET Z                       ; Card cannot accept another allophone yet.
    LD A,(IY+3)
    OR A
    JR Z,SPEECH_SEND
    ; HL is current_tick - due_tick. Count only the first code of each group,
    ; once, when it is actually submitted. Equality at 100 ms is not late.
    LD DE,LATE_TICKS+1
    OR A
    SBC HL,DE
    JR C,SPEECH_SEND
    LD A,(LATE_SYLLABLES)
    INC A
    LD (LATE_SYLLABLES),A
SPEECH_SEND:
    LD A,(IY+2)
    OUT (SPEECH_PORT),A
    INC IY
    INC IY
    INC IY
    INC IY
    RET
SPEECH_FINISHED:
    LD A,1
    LD (SPEECH_DONE),A
    RET

WAIT_TICK:
    ; Busy-loop delay uses BC and AF only. Interrupts remain in the caller's
    ; state. Ctrl-C is not polled: let playback return, or use hardware reset.
    LD BC,DELAY_LOOPS
WAIT_TICK_LOOP:
    DEC BC
    LD A,B
    OR C
    JR NZ,WAIT_TICK_LOOP
    RET

; Private writable state follows code. Tables are read-only during playback.
MUSIC_DONE:
    DB 0
SPEECH_DONE:
    DB 0
DRAIN_UNTIL:
    DW 0

MUSIC_DATA:
    DW 0 ; 0 ms
    DB 4 ; register/value pair count
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 100 ; 500 ms
    DB 6 ; register/value pair count
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 175 ; 875 ms
    DB 3 ; register/value pair count
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 200 ; 1000 ms
    DB 6 ; register/value pair count
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 275 ; 1375 ms
    DB 2 ; register/value pair count
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 300 ; 1500 ms
    DB 4 ; register/value pair count
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 400 ; 2000 ms
    DB 6 ; register/value pair count
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 475 ; 2375 ms
    DB 3 ; register/value pair count
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 500 ; 2500 ms
    DB 6 ; register/value pair count
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 575 ; 2875 ms
    DB 2 ; register/value pair count
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 600 ; 3000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,97
    DB 1,51
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 700 ; 3500 ms
    DB 8 ; register/value pair count
    DB 0,97
    DB 1,51
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 775 ; 3875 ms
    DB 5 ; register/value pair count
    DB 0,97
    DB 1,51
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 800 ; 4000 ms
    DB 8 ; register/value pair count
    DB 0,97
    DB 1,51
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 875 ; 4375 ms
    DB 4 ; register/value pair count
    DB 0,97
    DB 1,51
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 890 ; 4450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 900 ; 4500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 1000 ; 5000 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 1075 ; 5375 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 1100 ; 5500 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 1175 ; 5875 ms
    DB 4 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 1190 ; 5950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 1200 ; 6000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 1300 ; 6500 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 1375 ; 6875 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 1400 ; 7000 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 1475 ; 7375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 1490 ; 7450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 1500 ; 7500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 1600 ; 8000 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 1675 ; 8375 ms
    DB 5 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 1700 ; 8500 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 1775 ; 8875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 1790 ; 8950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 1800 ; 9000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 1890 ; 9450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 1900 ; 9500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,94
    DB 1,32
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 1975 ; 9875 ms
    DB 5 ; register/value pair count
    DB 0,94
    DB 1,32
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 1990 ; 9950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 2000 ; 10000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 2075 ; 10375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 2090 ; 10450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 2100 ; 10500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 2200 ; 11000 ms
    DB 8 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 2275 ; 11375 ms
    DB 5 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 2290 ; 11450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 2300 ; 11500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 2375 ; 11875 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 2390 ; 11950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 2400 ; 12000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 2500 ; 12500 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,63
    DB 15,19
    DB 18,WAVEFORM+1
    DW 2575 ; 12875 ms
    DB 5 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 2600 ; 13000 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 2675 ; 13375 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 2700 ; 13500 ms
    DB 6 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 2800 ; 14000 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,63
    DB 15,19
    DB 18,WAVEFORM+1
    DW 2875 ; 14375 ms
    DB 5 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 2900 ; 14500 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 2975 ; 14875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 2990 ; 14950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 3000 ; 15000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 3100 ; 15500 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,63
    DB 15,19
    DB 18,WAVEFORM+1
    DW 3175 ; 15875 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 3200 ; 16000 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 3275 ; 16375 ms
    DB 4 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 3290 ; 16450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 3300 ; 16500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 3400 ; 17000 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 3475 ; 17375 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 3500 ; 17500 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 3575 ; 17875 ms
    DB 4 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 3590 ; 17950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 3600 ; 18000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,53
    DB 8,7
    DB 11,WAVEFORM+1
    DW 3700 ; 18500 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,53
    DB 8,7
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 3775 ; 18875 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,53
    DB 8,7
    DB 18,WAVEFORM
    DW 3800 ; 19000 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,53
    DB 8,7
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 3875 ; 19375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 3890 ; 19450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 3900 ; 19500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 4000 ; 20000 ms
    DB 8 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 4075 ; 20375 ms
    DB 5 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 4100 ; 20500 ms
    DB 8 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 4175 ; 20875 ms
    DB 4 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 4190 ; 20950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 4200 ; 21000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 4290 ; 21450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 4300 ; 21500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,94
    DB 1,32
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 4375 ; 21875 ms
    DB 5 ; register/value pair count
    DB 0,94
    DB 1,32
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 4390 ; 21950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 4400 ; 22000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 4475 ; 22375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 4490 ; 22450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 4500 ; 22500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,159
    DB 8,9
    DB 11,WAVEFORM+1
    DW 4600 ; 23000 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,159
    DB 8,9
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 4675 ; 23375 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,159
    DB 8,9
    DB 18,WAVEFORM
    DW 4690 ; 23450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,159
    DB 8,9
    DW 4700 ; 23500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 7,159
    DB 8,9
    DB 18,WAVEFORM
    DB 14,214
    DB 15,28
    DB 18,WAVEFORM+1
    DW 4775 ; 23875 ms
    DB 4 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 4790 ; 23950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 4800 ; 24000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 4900 ; 24500 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,63
    DB 15,19
    DB 18,WAVEFORM+1
    DW 4975 ; 24875 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 5000 ; 25000 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 5075 ; 25375 ms
    DB 4 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 5100 ; 25500 ms
    DB 6 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 5200 ; 26000 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 5275 ; 26375 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 5290 ; 26450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 5300 ; 26500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 5375 ; 26875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 5390 ; 26950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 5400 ; 27000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 5490 ; 27450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 5500 ; 27500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 5575 ; 27875 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 5590 ; 27950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 5600 ; 28000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 5675 ; 28375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 5690 ; 28450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 5700 ; 28500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 5800 ; 29000 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 5875 ; 29375 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 5890 ; 29450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 5900 ; 29500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 5975 ; 29875 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 5990 ; 29950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 6000 ; 30000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 6100 ; 30500 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 6175 ; 30875 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 6190 ; 30950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 6200 ; 31000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 6275 ; 31375 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 6290 ; 31450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 6300 ; 31500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 6400 ; 32000 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 6475 ; 32375 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 6490 ; 32450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 6500 ; 32500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,94
    DB 1,32
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 6575 ; 32875 ms
    DB 4 ; register/value pair count
    DB 0,94
    DB 1,32
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 6590 ; 32950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 6600 ; 33000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 6690 ; 33450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 6700 ; 33500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,94
    DB 1,32
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 6775 ; 33875 ms
    DB 5 ; register/value pair count
    DB 0,94
    DB 1,32
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 6790 ; 33950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 6800 ; 34000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 6875 ; 34375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 6890 ; 34450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 6900 ; 34500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,214
    DB 1,28
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,185
    DB 8,5
    DB 11,WAVEFORM+1
    DW 7000 ; 35000 ms
    DB 8 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,37
    DB 15,17
    DB 18,WAVEFORM+1
    DW 7075 ; 35375 ms
    DB 5 ; register/value pair count
    DB 0,214
    DB 1,28
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DW 7090 ; 35450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,185
    DB 8,5
    DW 7100 ; 35500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 7,185
    DB 8,5
    DB 18,WAVEFORM
    DB 14,107
    DB 15,14
    DB 18,WAVEFORM+1
    DW 7175 ; 35875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 7190 ; 35950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 7200 ; 36000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 7300 ; 36500 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,63
    DB 15,19
    DB 18,WAVEFORM+1
    DW 7375 ; 36875 ms
    DB 5 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 7400 ; 37000 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 7475 ; 37375 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 7490 ; 37450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 7500 ; 37500 ms
    DB 4 ; register/value pair count
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 7600 ; 38000 ms
    DB 6 ; register/value pair count
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 7675 ; 38375 ms
    DB 3 ; register/value pair count
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 7700 ; 38500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 7775 ; 38875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 7790 ; 38950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 7800 ; 39000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 7900 ; 39500 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 7975 ; 39875 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 7990 ; 39950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 8000 ; 40000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 8075 ; 40375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 8090 ; 40450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 8100 ; 40500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 8200 ; 41000 ms
    DB 8 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 8275 ; 41375 ms
    DB 5 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 8290 ; 41450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 8300 ; 41500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 8375 ; 41875 ms
    DB 4 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 8390 ; 41950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 8400 ; 42000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 8500 ; 42500 ms
    DB 8 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 8575 ; 42875 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 8590 ; 42950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 8600 ; 43000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 8675 ; 43375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 8690 ; 43450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 8700 ; 43500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 8790 ; 43950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 8800 ; 44000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 8875 ; 44375 ms
    DB 5 ; register/value pair count
    DB 0,52
    DB 1,43
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 8890 ; 44450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 8900 ; 44500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,198
    DB 1,45
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 8975 ; 44875 ms
    DB 4 ; register/value pair count
    DB 0,198
    DB 1,45
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 8990 ; 44950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 9000 ; 45000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,52
    DB 1,43
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 9090 ; 45450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 9100 ; 45500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 9175 ; 45875 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 9190 ; 45950 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,147
    DB 8,8
    DW 9200 ; 46000 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,126
    DB 1,38
    DB 4,WAVEFORM+1
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 9275 ; 46375 ms
    DB 4 ; register/value pair count
    DB 0,126
    DB 1,38
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 9290 ; 46450 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 9300 ; 46500 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,177
    DB 1,25
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,108
    DB 8,6
    DB 11,WAVEFORM+1
    DW 9400 ; 47000 ms
    DB 8 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,227
    DB 15,22
    DB 18,WAVEFORM+1
    DW 9475 ; 47375 ms
    DB 5 ; register/value pair count
    DB 0,177
    DB 1,25
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DW 9490 ; 47450 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 7,108
    DB 8,6
    DW 9500 ; 47500 ms
    DB 10 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,94
    DB 1,32
    DB 4,WAVEFORM+1
    DB 7,108
    DB 8,6
    DB 18,WAVEFORM
    DB 14,47
    DB 15,16
    DB 18,WAVEFORM+1
    DW 9575 ; 47875 ms
    DB 4 ; register/value pair count
    DB 0,94
    DB 1,32
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 9590 ; 47950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 9600 ; 48000 ms
    DB 8 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 9700 ; 48500 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 9775 ; 48875 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 9800 ; 49000 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 9875 ; 49375 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 9900 ; 49500 ms
    DB 6 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DW 10000 ; 50000 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 10075 ; 50375 ms
    DB 5 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DW 10100 ; 50500 ms
    DB 8 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 7,147
    DB 8,8
    DB 18,WAVEFORM
    DB 14,177
    DB 15,25
    DB 18,WAVEFORM+1
    DW 10175 ; 50875 ms
    DB 4 ; register/value pair count
    DB 0,75
    DB 1,34
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 10190 ; 50950 ms
    DB 1 ; register/value pair count
    DB 4,WAVEFORM
    DW 10200 ; 51000 ms
    DB 12 ; register/value pair count
    DB 4,WAVEFORM
    DB 0,75
    DB 1,34
    DB 4,WAVEFORM+1
    DB 11,WAVEFORM
    DB 7,147
    DB 8,8
    DB 11,WAVEFORM+1
    DB 18,WAVEFORM
    DB 14,154
    DB 15,21
    DB 18,WAVEFORM+1
    DW 10750 ; 53750 ms
    DB 3 ; register/value pair count
    DB 4,WAVEFORM
    DB 11,WAVEFORM
    DB 18,WAVEFORM
    DW 10800 ; 54000 ms
    DB 0 ; register/value pair count
    DW 65535 ; end of music

SPEECH_DATA:
    DW 600
    DB 33,1 ; allophone, first-code flag
    DW 600
    DB 20,0 ; allophone, first-code flag
    DW 600
    DB 0,0 ; allophone, first-code flag
    DW 900
    DB 55,1 ; allophone, first-code flag
    DW 900
    DB 19,0 ; allophone, first-code flag
    DW 900
    DB 0,0 ; allophone, first-code flag
    DW 1200
    DB 33,1 ; allophone, first-code flag
    DW 1200
    DB 20,0 ; allophone, first-code flag
    DW 1200
    DB 0,0 ; allophone, first-code flag
    DW 1500
    DB 55,1 ; allophone, first-code flag
    DW 1500
    DB 19,0 ; allophone, first-code flag
    DW 1500
    DB 0,0 ; allophone, first-code flag
    DW 1780
    DB 36,1 ; allophone, first-code flag
    DW 1780
    DB 12,0 ; allophone, first-code flag
    DW 1780
    DB 35,0 ; allophone, first-code flag
    DW 1780
    DB 0,0 ; allophone, first-code flag
    DW 1880
    DB 16,1 ; allophone, first-code flag
    DW 1880
    DB 20,0 ; allophone, first-code flag
    DW 1880
    DB 0,0 ; allophone, first-code flag
    DW 2000
    DB 49,1 ; allophone, first-code flag
    DW 2000
    DB 58,0 ; allophone, first-code flag
    DW 2000
    DB 0,0 ; allophone, first-code flag
    DW 2100
    DB 26,1 ; allophone, first-code flag
    DW 2100
    DB 11,0 ; allophone, first-code flag
    DW 2100
    DB 0,0 ; allophone, first-code flag
    DW 2300
    DB 55,1 ; allophone, first-code flag
    DW 2300
    DB 46,0 ; allophone, first-code flag
    DW 2300
    DB 51,0 ; allophone, first-code flag
    DW 2300
    DB 0,0 ; allophone, first-code flag
    DW 2400
    DB 21,1 ; allophone, first-code flag
    DW 2400
    DB 31,0 ; allophone, first-code flag
    DW 2400
    DB 0,0 ; allophone, first-code flag
    DW 3000
    DB 6,1 ; allophone, first-code flag
    DW 3000
    DB 16,0 ; allophone, first-code flag
    DW 3000
    DB 0,0 ; allophone, first-code flag
    DW 3300
    DB 27,1 ; allophone, first-code flag
    DW 3300
    DB 24,0 ; allophone, first-code flag
    DW 3300
    DB 40,0 ; allophone, first-code flag
    DW 3300
    DB 0,0 ; allophone, first-code flag
    DW 3600
    DB 42,1 ; allophone, first-code flag
    DW 3600
    DB 14,0 ; allophone, first-code flag
    DW 3600
    DB 20,0 ; allophone, first-code flag
    DW 3600
    DB 0,0 ; allophone, first-code flag
    DW 3900
    DB 43,1 ; allophone, first-code flag
    DW 3900
    DB 49,0 ; allophone, first-code flag
    DW 3900
    DB 0,0 ; allophone, first-code flag
    DW 4200
    DB 23,1 ; allophone, first-code flag
    DW 4200
    DB 45,0 ; allophone, first-code flag
    DW 4200
    DB 0,0 ; allophone, first-code flag
    DW 4300
    DB 40,1 ; allophone, first-code flag
    DW 4300
    DB 58,0 ; allophone, first-code flag
    DW 4300
    DB 0,0 ; allophone, first-code flag
    DW 4400
    DB 18,1 ; allophone, first-code flag
    DW 4400
    DB 15,0 ; allophone, first-code flag
    DW 4400
    DB 0,0 ; allophone, first-code flag
    DW 4500
    DB 45,1 ; allophone, first-code flag
    DW 4500
    DB 23,0 ; allophone, first-code flag
    DW 4500
    DB 35,0 ; allophone, first-code flag
    DW 4500
    DB 0,0 ; allophone, first-code flag
    DW 4700
    DB 23,1 ; allophone, first-code flag
    DW 4700
    DB 40,0 ; allophone, first-code flag
    DW 4700
    DB 0,0 ; allophone, first-code flag
    DW 4800
    DB 49,1 ; allophone, first-code flag
    DW 4800
    DB 22,0 ; allophone, first-code flag
    DW 4800
    DB 0,0 ; allophone, first-code flag
    DW 5300
    DB 12,1 ; allophone, first-code flag
    DW 5300
    DB 13,0 ; allophone, first-code flag
    DW 5300
    DB 0,0 ; allophone, first-code flag
    DW 5400
    DB 46,1 ; allophone, first-code flag
    DW 5400
    DB 23,0 ; allophone, first-code flag
    DW 5400
    DB 11,0 ; allophone, first-code flag
    DW 5400
    DB 13,0 ; allophone, first-code flag
    DW 5400
    DB 0,0 ; allophone, first-code flag
    DW 5500
    DB 28,1 ; allophone, first-code flag
    DW 5500
    DB 19,0 ; allophone, first-code flag
    DW 5500
    DB 0,0 ; allophone, first-code flag
    DW 5600
    DB 15,1 ; allophone, first-code flag
    DW 5600
    DB 0,0 ; allophone, first-code flag
    DW 5700
    DB 55,1 ; allophone, first-code flag
    DW 5700
    DB 13,0 ; allophone, first-code flag
    DW 5700
    DB 6,0 ; allophone, first-code flag
    DW 5700
    DB 0,0 ; allophone, first-code flag
    DW 5900
    DB 45,1 ; allophone, first-code flag
    DW 5900
    DB 12,0 ; allophone, first-code flag
    DW 5900
    DB 37,0 ; allophone, first-code flag
    DW 5900
    DB 0,0 ; allophone, first-code flag
    DW 6000
    DB 16,1 ; allophone, first-code flag
    DW 6000
    DB 24,0 ; allophone, first-code flag
    DW 6000
    DB 14,0 ; allophone, first-code flag
    DW 6000
    DB 0,0 ; allophone, first-code flag
    DW 6200
    DB 20,1 ; allophone, first-code flag
    DW 6200
    DB 10,0 ; allophone, first-code flag
    DW 6200
    DB 0,0 ; allophone, first-code flag
    DW 6300
    DB 6,1 ; allophone, first-code flag
    DW 6300
    DB 0,0 ; allophone, first-code flag
    DW 6500
    DB 42,1 ; allophone, first-code flag
    DW 6500
    DB 26,0 ; allophone, first-code flag
    DW 6500
    DB 11,0 ; allophone, first-code flag
    DW 6500
    DB 13,0 ; allophone, first-code flag
    DW 6500
    DB 0,0 ; allophone, first-code flag
    DW 6600
    DB 26,1 ; allophone, first-code flag
    DW 6600
    DB 40,0 ; allophone, first-code flag
    DW 6600
    DB 0,0 ; allophone, first-code flag
    DW 6700
    DB 40,1 ; allophone, first-code flag
    DW 6700
    DB 58,0 ; allophone, first-code flag
    DW 6700
    DB 21,0 ; allophone, first-code flag
    DW 6700
    DB 0,0 ; allophone, first-code flag
    DW 6800
    DB 15,1 ; allophone, first-code flag
    DW 6800
    DB 0,0 ; allophone, first-code flag
    DW 6900
    DB 42,1 ; allophone, first-code flag
    DW 6900
    DB 24,0 ; allophone, first-code flag
    DW 6900
    DB 14,0 ; allophone, first-code flag
    DW 6900
    DB 0,0 ; allophone, first-code flag
    DW 7100
    DB 20,1 ; allophone, first-code flag
    DW 7100
    DB 10,0 ; allophone, first-code flag
    DW 7100
    DB 0,0 ; allophone, first-code flag
    DW 7700
    DB 28,1 ; allophone, first-code flag
    DW 7700
    DB 30,0 ; allophone, first-code flag
    DW 7700
    DB 13,0 ; allophone, first-code flag
    DW 7700
    DB 0,0 ; allophone, first-code flag
    DW 7800
    DB 49,1 ; allophone, first-code flag
    DW 7800
    DB 22,0 ; allophone, first-code flag
    DW 7800
    DB 45,0 ; allophone, first-code flag
    DW 7800
    DB 45,0 ; allophone, first-code flag
    DW 7800
    DB 0,0 ; allophone, first-code flag
    DW 8000
    DB 45,1 ; allophone, first-code flag
    DW 8000
    DB 22,0 ; allophone, first-code flag
    DW 8000
    DB 42,0 ; allophone, first-code flag
    DW 8000
    DB 0,0 ; allophone, first-code flag
    DW 8100
    DB 55,1 ; allophone, first-code flag
    DW 8100
    DB 46,0 ; allophone, first-code flag
    DW 8100
    DB 19,0 ; allophone, first-code flag
    DW 8100
    DB 13,0 ; allophone, first-code flag
    DW 8100
    DB 0,0 ; allophone, first-code flag
    DW 8300
    DB 30,1 ; allophone, first-code flag
    DW 8300
    DB 9,0 ; allophone, first-code flag
    DW 8300
    DB 0,0 ; allophone, first-code flag
    DW 8400
    DB 23,1 ; allophone, first-code flag
    DW 8400
    DB 11,0 ; allophone, first-code flag
    DW 8400
    DB 0,0 ; allophone, first-code flag
    DW 8600
    DB 18,1 ; allophone, first-code flag
    DW 8600
    DB 15,0 ; allophone, first-code flag
    DW 8600
    DB 0,0 ; allophone, first-code flag
    DW 8700
    DB 55,1 ; allophone, first-code flag
    DW 8700
    DB 19,0 ; allophone, first-code flag
    DW 8700
    DB 13,0 ; allophone, first-code flag
    DW 8700
    DB 0,0 ; allophone, first-code flag
    DW 8800
    DB 23,1 ; allophone, first-code flag
    DW 8800
    DB 40,0 ; allophone, first-code flag
    DW 8800
    DB 0,0 ; allophone, first-code flag
    DW 8900
    DB 15,1 ; allophone, first-code flag
    DW 8900
    DB 0,0 ; allophone, first-code flag
    DW 9000
    DB 28,1 ; allophone, first-code flag
    DW 9000
    DB 6,0 ; allophone, first-code flag
    DW 9000
    DB 0,0 ; allophone, first-code flag
    DW 9100
    DB 55,1 ; allophone, first-code flag
    DW 9100
    DB 12,0 ; allophone, first-code flag
    DW 9100
    DB 0,0 ; allophone, first-code flag
    DW 9200
    DB 42,1 ; allophone, first-code flag
    DW 9200
    DB 45,0 ; allophone, first-code flag
    DW 9200
    DB 0,0 ; allophone, first-code flag
    DW 9300
    DB 16,1 ; allophone, first-code flag
    DW 9300
    DB 26,0 ; allophone, first-code flag
    DW 9300
    DB 21,0 ; allophone, first-code flag
    DW 9300
    DB 0,0 ; allophone, first-code flag
    DW 9500
    DB 40,1 ; allophone, first-code flag
    DW 9500
    DB 58,0 ; allophone, first-code flag
    DW 9500
    DB 0,0 ; allophone, first-code flag
    DW 9600
    DB 13,1 ; allophone, first-code flag
    DW 9600
    DB 22,0 ; allophone, first-code flag
    DW 9600
    DB 0,0 ; allophone, first-code flag
    DW 65535 ; end of speech

IMAGE_END:
