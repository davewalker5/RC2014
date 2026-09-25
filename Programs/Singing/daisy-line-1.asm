; Daisy Bell: SID-Ulator plus MG005, Z80 player for the RC2014 Mini II.
; Assemble the GENERATED daisy-line-1.asm with standalone z80asm.
; This labelled source is NOT input for SCM's interactive assembler.
;
; Python inserts music and speech tables at the two markers below. Musical
; timestamps come from the same MIDI and CUES as the BASIC version. Python
; also calculates SID frequency bytes and gate changes: no floating-point
; arithmetic, BASIC array lookup or string processing occurs during playback.
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

PLAYER_ORIGIN: equ 0e000h
SID_REGISTER:  equ 0d4h
SID_DATA:      equ 0d5h
SPEECH_PORT:   equ 01fh
SPEECH_READY:  equ 2
WAVEFORM:      equ 16             ; Triangle, with gate bit initially clear.
VOLUME:        equ 2              ; SID master volume 0-15; matches BASIC tuning.

; Delay calibration: DEC BC / LD A,B / OR C / JR NZ costs 26 T-states
; per iteration, except the final branch (5 fewer). Including CALL, LD BC
; and RET, the complete delay costs 26 * DELAY_LOOPS + 32 T-states.
; 1416 gives 36848 T-states, about 4.998 ms at 7.3728 MHz.
; The scheduler adds a small, variable overhead. This is NOT a hardware clock
; or a fully cycle-balanced loop. Increase DELAY_LOOPS to slow the tune and
; allow more time for speech; decrease it to speed up. Use 1-65535, never 0.
; Changing CPU speed requires proportional recalibration; SID pitch still
; assumes a separate 1 MHz SID clock. BASIC's TA/DL do not apply to this player.
DELAY_LOOPS:   equ 1416
LATE_TICKS:    equ 20             ; More than 20 ticks = more than 100 ms late.
DRAIN_TICKS:   equ 200            ; Nominal second after the final command.
TIMEOUT_TICK:  equ 3800           ; 15 seconds of music plus 4 seconds backlog.

    org PLAYER_ORIGIN
    jp start
result:
    db 255
late_syllables:
    db 0
current_tick:
    dw 0

start:
    ; Keep the caller's stack and register values so SCM can resume normally.
    push af
    push bc
    push de
    push hl
    push ix
    push iy

    xor a
    ld (late_syllables),a
    ld (music_done),a
    ld (speech_done),a
    ld hl,0
    ld (current_tick),hl
    ld (drain_until),hl
    ld a,255
    ld (result),a
    ld ix,music_data
    ld iy,speech_data

    ; Clear all 25 SID registers, including volume and gates, before setup.
    ; OUT uses the low eight address bits, as in the project's BASIC examples.
    ld b,25
    ld c,0

clear_sid:
    ld a,c
    out (SID_REGISTER),a
    xor a
    out (SID_DATA),a
    inc c
    djnz clear_sid

    ; Three identical envelopes: immediate attack/decay, full sustain and
    ; immediate release. The tables carry the per-voice triangle/gate writes.
    ld a,6
    out (SID_REGISTER),a
    ld a,240
    out (SID_DATA),a
    ld a,13
    out (SID_REGISTER),a
    ld a,240
    out (SID_DATA),a
    ld a,20
    out (SID_REGISTER),a
    ld a,240
    out (SID_DATA),a
    ld a,24
    out (SID_REGISTER),a
    ld a,VOLUME
    out (SID_DATA),a

playback_loop:
    ; Always service due SID events first. A busy speech chip must never
    ; hold up music. IX and IY retain the next unconsumed table positions.
    call service_music
    call service_speech

    ld a,(music_done)
    ld b,a
    ld a,(speech_done)
    and b
    jr z,check_timeout

    ; Both streams are submitted, but ready is not an acoustic completion
    ; signal. Allow a short tail for the final allophone and terminating PA1.
    ld hl,(drain_until)
    ld a,h
    or l
    jr nz,check_drain
    ld hl,(current_tick)
    ld de,DRAIN_TICKS
    add hl,de
    ld (drain_until),hl

check_drain:
    ld de,(drain_until)
    ld hl,(current_tick)
    or a                        ; Clear carry before unsigned subtraction.
    sbc hl,de
    jr c,next_tick
    xor a                       ; Result 0: all commands submitted.
    jr finish

check_timeout:
    ; The music table ends at tick 3000. Keep servicing any remaining speech
    ; until tick 3800, then return instead of hanging on a permanently busy card.
    ld hl,(current_tick)
    ld de,TIMEOUT_TICK
    or a
    sbc hl,de
    jr c,next_tick
    ld a,1                      ; Result 1: speech still pending at the deadline.
    jr finish

next_tick:
    call wait_tick
    ld hl,(current_tick)
    inc hl
    ld (current_tick),hl
    jr playback_loop

finish:
    ld (result),a
    ; Every exit releases all gates and mutes the SID. A speech command already
    ; accepted by the MG005 cannot be cancelled through this interface.
    ld a,4
    out (SID_REGISTER),a
    ld a,WAVEFORM
    out (SID_DATA),a
    ld a,11
    out (SID_REGISTER),a
    ld a,WAVEFORM
    out (SID_DATA),a
    ld a,18
    out (SID_REGISTER),a
    ld a,WAVEFORM
    out (SID_DATA),a
    ld a,24
    out (SID_REGISTER),a
    xor a
    out (SID_DATA),a
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret

service_music:
    ; Record: DW absolute tick, DB pair count, then register/value byte pairs.
    ; FFFF is an end marker, never a real cue. IX advances only after an event
    ; is due. Registers changed: AF, BC, HL, IX. Other table state is untouched.
    ld a,(music_done)
    or a
    ret nz

music_next:
    ld c,(ix+0)
    ld b,(ix+1)
    ld a,b
    and c
    cp 255
    jr z,music_finished
    ld hl,(current_tick)
    or a
    sbc hl,bc
    ret c                       ; The next event belongs to a future tick.
    ld b,(ix+2)
    inc ix
    inc ix
    inc ix
    ld a,b
    or a
    jr z,music_next              ; A no-op event is valid; avoid DJNZ underflow.

music_write:
    ld a,(ix+0)
    out (SID_REGISTER),a
    ld a,(ix+1)
    out (SID_DATA),a
    inc ix
    inc ix
    djnz music_write
    jr music_next               ; Consume every event due at this tick.

music_finished:
    ld a,1
    ld (music_done),a
    ret

service_speech:
    ; Record: DW absolute tick, DB allophone, DB first-code flag (0 or 1).
    ; All codes of a syllable share a cue. Send at most one per scheduler pass:
    ; the next pass checks readiness again, leaving time for the hardware
    ; handshake. Never spin waiting for the chip, or drop a late allophone.
    ; Registers changed: AF, BC, DE, HL, IY.
    ld a,(speech_done)
    or a
    ret nz
    ld c,(iy+0)
    ld b,(iy+1)
    ld a,b
    and c
    cp 255
    jr z,speech_finished
    ld hl,(current_tick)
    or a
    sbc hl,bc
    ret c
    in a,(SPEECH_PORT)
    and SPEECH_READY
    ret z                       ; Card cannot accept another allophone yet.
    ld a,(iy+3)
    or a
    jr z,speech_send
    ; HL is current_tick - due_tick. Count only the first code of each group,
    ; once, when it is actually submitted. Equality at 100 ms is not late.
    ld de,LATE_TICKS+1
    or a
    sbc hl,de
    jr c,speech_send
    ld a,(late_syllables)
    inc a
    ld (late_syllables),a

speech_send:
    ld a,(iy+2)
    out (SPEECH_PORT),a
    inc iy
    inc iy
    inc iy
    inc iy
    ret

speech_finished:
    ld a,1
    ld (speech_done),a
    ret

wait_tick:
    ; Busy-loop delay uses BC and AF only. Interrupts remain in the caller's
    ; state. Ctrl-C is not polled: let playback return, or use hardware reset.
    ld bc,DELAY_LOOPS

wait_tick_loop:
    dec bc
    ld a,b
    or c
    jr nz,wait_tick_loop
    ret

; Private writable state follows code. Tables are read-only during playback.
music_done:
    db 0
speech_done:
    db 0
drain_until:
    dw 0

music_data:
    dw 0 ; 0 ms
    db 4 ; register/value pair count
    db 11,WAVEFORM
    db 7,147
    db 8,8
    db 11,WAVEFORM+1
    dw 100 ; 500 ms
    db 6 ; register/value pair count
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,154
    db 15,21
    db 18,WAVEFORM+1
    dw 175 ; 875 ms
    db 3 ; register/value pair count
    db 7,147
    db 8,8
    db 18,WAVEFORM
    dw 200 ; 1000 ms
    db 6 ; register/value pair count
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,177
    db 15,25
    db 18,WAVEFORM+1
    dw 275 ; 1375 ms
    db 2 ; register/value pair count
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 300 ; 1500 ms
    db 4 ; register/value pair count
    db 11,WAVEFORM
    db 7,108
    db 8,6
    db 11,WAVEFORM+1
    dw 400 ; 2000 ms
    db 6 ; register/value pair count
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,227
    db 15,22
    db 18,WAVEFORM+1
    dw 475 ; 2375 ms
    db 3 ; register/value pair count
    db 7,108
    db 8,6
    db 18,WAVEFORM
    dw 500 ; 2500 ms
    db 6 ; register/value pair count
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,47
    db 15,16
    db 18,WAVEFORM+1
    dw 575 ; 2875 ms
    db 2 ; register/value pair count
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 600 ; 3000 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,97
    db 1,51
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,147
    db 8,8
    db 11,WAVEFORM+1
    dw 700 ; 3500 ms
    db 8 ; register/value pair count
    db 0,97
    db 1,51
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,154
    db 15,21
    db 18,WAVEFORM+1
    dw 775 ; 3875 ms
    db 5 ; register/value pair count
    db 0,97
    db 1,51
    db 7,147
    db 8,8
    db 18,WAVEFORM
    dw 800 ; 4000 ms
    db 8 ; register/value pair count
    db 0,97
    db 1,51
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,177
    db 15,25
    db 18,WAVEFORM+1
    dw 875 ; 4375 ms
    db 4 ; register/value pair count
    db 0,97
    db 1,51
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 890 ; 4450 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 900 ; 4500 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,52
    db 1,43
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,147
    db 8,8
    db 11,WAVEFORM+1
    dw 1000 ; 5000 ms
    db 8 ; register/value pair count
    db 0,52
    db 1,43
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,154
    db 15,21
    db 18,WAVEFORM+1
    dw 1075 ; 5375 ms
    db 5 ; register/value pair count
    db 0,52
    db 1,43
    db 7,147
    db 8,8
    db 18,WAVEFORM
    dw 1100 ; 5500 ms
    db 8 ; register/value pair count
    db 0,52
    db 1,43
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,177
    db 15,25
    db 18,WAVEFORM+1
    dw 1175 ; 5875 ms
    db 4 ; register/value pair count
    db 0,52
    db 1,43
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 1190 ; 5950 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 1200 ; 6000 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,75
    db 1,34
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,185
    db 8,5
    db 11,WAVEFORM+1
    dw 1300 ; 6500 ms
    db 8 ; register/value pair count
    db 0,75
    db 1,34
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,37
    db 15,17
    db 18,WAVEFORM+1
    dw 1375 ; 6875 ms
    db 5 ; register/value pair count
    db 0,75
    db 1,34
    db 7,185
    db 8,5
    db 18,WAVEFORM
    dw 1400 ; 7000 ms
    db 8 ; register/value pair count
    db 0,75
    db 1,34
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,107
    db 15,14
    db 18,WAVEFORM+1
    dw 1475 ; 7375 ms
    db 4 ; register/value pair count
    db 0,75
    db 1,34
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 1490 ; 7450 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 1500 ; 7500 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,177
    db 1,25
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,147
    db 8,8
    db 11,WAVEFORM+1
    dw 1600 ; 8000 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,154
    db 15,21
    db 18,WAVEFORM+1
    dw 1675 ; 8375 ms
    db 5 ; register/value pair count
    db 0,177
    db 1,25
    db 7,147
    db 8,8
    db 18,WAVEFORM
    dw 1700 ; 8500 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,147
    db 8,8
    db 18,WAVEFORM
    db 14,177
    db 15,25
    db 18,WAVEFORM+1
    dw 1775 ; 8875 ms
    db 4 ; register/value pair count
    db 0,177
    db 1,25
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 1790 ; 8950 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 1800 ; 9000 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,214
    db 1,28
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,185
    db 8,5
    db 11,WAVEFORM+1
    dw 1890 ; 9450 ms
    db 3 ; register/value pair count
    db 4,WAVEFORM
    db 7,185
    db 8,5
    dw 1900 ; 9500 ms
    db 10 ; register/value pair count
    db 4,WAVEFORM
    db 0,94
    db 1,32
    db 4,WAVEFORM+1
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,37
    db 15,17
    db 18,WAVEFORM+1
    dw 1975 ; 9875 ms
    db 5 ; register/value pair count
    db 0,94
    db 1,32
    db 7,185
    db 8,5
    db 18,WAVEFORM
    dw 1990 ; 9950 ms
    db 3 ; register/value pair count
    db 4,WAVEFORM
    db 7,185
    db 8,5
    dw 2000 ; 10000 ms
    db 10 ; register/value pair count
    db 4,WAVEFORM
    db 0,75
    db 1,34
    db 4,WAVEFORM+1
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,107
    db 15,14
    db 18,WAVEFORM+1
    dw 2075 ; 10375 ms
    db 4 ; register/value pair count
    db 0,75
    db 1,34
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 2090 ; 10450 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 2100 ; 10500 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,214
    db 1,28
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,185
    db 8,5
    db 11,WAVEFORM+1
    dw 2200 ; 11000 ms
    db 8 ; register/value pair count
    db 0,214
    db 1,28
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,37
    db 15,17
    db 18,WAVEFORM+1
    dw 2275 ; 11375 ms
    db 5 ; register/value pair count
    db 0,214
    db 1,28
    db 7,185
    db 8,5
    db 18,WAVEFORM
    dw 2290 ; 11450 ms
    db 3 ; register/value pair count
    db 4,WAVEFORM
    db 7,185
    db 8,5
    dw 2300 ; 11500 ms
    db 10 ; register/value pair count
    db 4,WAVEFORM
    db 0,75
    db 1,34
    db 4,WAVEFORM+1
    db 7,185
    db 8,5
    db 18,WAVEFORM
    db 14,107
    db 15,14
    db 18,WAVEFORM+1
    dw 2375 ; 11875 ms
    db 4 ; register/value pair count
    db 0,75
    db 1,34
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 2390 ; 11950 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 2400 ; 12000 ms
    db 8 ; register/value pair count
    db 4,WAVEFORM
    db 0,177
    db 1,25
    db 4,WAVEFORM+1
    db 11,WAVEFORM
    db 7,108
    db 8,6
    db 11,WAVEFORM+1
    dw 2500 ; 12500 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,63
    db 15,19
    db 18,WAVEFORM+1
    dw 2575 ; 12875 ms
    db 5 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    dw 2600 ; 13000 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,47
    db 15,16
    db 18,WAVEFORM+1
    dw 2675 ; 13375 ms
    db 4 ; register/value pair count
    db 0,177
    db 1,25
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 2700 ; 13500 ms
    db 6 ; register/value pair count
    db 0,177
    db 1,25
    db 11,WAVEFORM
    db 7,108
    db 8,6
    db 11,WAVEFORM+1
    dw 2800 ; 14000 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,63
    db 15,19
    db 18,WAVEFORM+1
    dw 2875 ; 14375 ms
    db 5 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    dw 2900 ; 14500 ms
    db 8 ; register/value pair count
    db 0,177
    db 1,25
    db 7,108
    db 8,6
    db 18,WAVEFORM
    db 14,47
    db 15,16
    db 18,WAVEFORM+1
    dw 2975 ; 14875 ms
    db 4 ; register/value pair count
    db 0,177
    db 1,25
    db 11,WAVEFORM
    db 18,WAVEFORM
    dw 2990 ; 14950 ms
    db 1 ; register/value pair count
    db 4,WAVEFORM
    dw 3000 ; 15000 ms
    db 0 ; register/value pair count
    dw 65535 ; end of music

speech_data:
    dw 600
    db 33,1 ; allophone, first-code flag
    dw 600
    db 20,0 ; allophone, first-code flag
    dw 600
    db 0,0 ; allophone, first-code flag
    dw 900
    db 55,1 ; allophone, first-code flag
    dw 900
    db 19,0 ; allophone, first-code flag
    dw 900
    db 0,0 ; allophone, first-code flag
    dw 1200
    db 33,1 ; allophone, first-code flag
    dw 1200
    db 20,0 ; allophone, first-code flag
    dw 1200
    db 0,0 ; allophone, first-code flag
    dw 1500
    db 55,1 ; allophone, first-code flag
    dw 1500
    db 19,0 ; allophone, first-code flag
    dw 1500
    db 0,0 ; allophone, first-code flag
    dw 1780
    db 36,1 ; allophone, first-code flag
    dw 1780
    db 12,0 ; allophone, first-code flag
    dw 1780
    db 35,0 ; allophone, first-code flag
    dw 1780
    db 0,0 ; allophone, first-code flag
    dw 1880
    db 16,1 ; allophone, first-code flag
    dw 1880
    db 20,0 ; allophone, first-code flag
    dw 1880
    db 0,0 ; allophone, first-code flag
    dw 2000
    db 49,1 ; allophone, first-code flag
    dw 2000
    db 58,0 ; allophone, first-code flag
    dw 2000
    db 0,0 ; allophone, first-code flag
    dw 2100
    db 26,1 ; allophone, first-code flag
    dw 2100
    db 11,0 ; allophone, first-code flag
    dw 2100
    db 0,0 ; allophone, first-code flag
    dw 2300
    db 55,1 ; allophone, first-code flag
    dw 2300
    db 46,0 ; allophone, first-code flag
    dw 2300
    db 51,0 ; allophone, first-code flag
    dw 2300
    db 0,0 ; allophone, first-code flag
    dw 2400
    db 21,1 ; allophone, first-code flag
    dw 2400
    db 31,0 ; allophone, first-code flag
    dw 2400
    db 0,0 ; allophone, first-code flag
    dw 65535 ; end of speech

image_end:
