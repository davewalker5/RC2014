# Rodeo Rumble — Graphics, Animation and Sound

Phase 1 and Phase 2 of the [project brief](../../docs/Project%20Briefs/Project%20Brief%20-%20Rodeo%20Rumble.md) use a front-facing bull head made from four 5×8 LCD characters: a 10×16-pixel image. The folder contains individual pose studies, single- and four-bull animations, and a filtered SID-Ulator moo prototype. Game logic and scoring remain later work.

## Programs

| File                        | Purpose                                                            |
| --------------------------- | ------------------------------------------------------------------ |
| `bull_head_straight.bas`    | Static standing / neutral head                                     |
| `bull_head_left.bas`        | Static lean towards the viewer's left                              |
| `bull_head_right.bas`       | Static lean towards the viewer's right                             |
| `bull_head_down.bas`        | Static lowered head                                                |
| `bull_animation.bas`        | Repeating pose and horizontal movement demonstration               |
| `four_bulls_animation.bas`  | Four synchronised heads with two-column gaps                       |
| `four_bulls_random.bas`     | Four heads with separate, hardware-constrained random pose choices |
| `moo.bas`                   | Standalone filtered cartoon moo; SID-Ulator required, no LCD       |
| `four_bulls_random_moo.bas` | Random bulls with periodic moo; LCD and SID-Ulator required        |

## Hardware and running

Use an RC2014 Mini II running Microsoft BASIC and a serial terminal. Graphics programs require an RC2014 LCD Driver Module with a two-line, 16-character HD44780-compatible LCD. `moo.bas` requires only the SID-Ulator; `four_bulls_random_moo.bas` requires both modules. No Digital I/O card is needed.

Configure the SID-Ulator for D4/D5 (ports 212/213), with headphones or powered speakers connected. If Ctrl-C leaves sound playing, enter `OUT 212,24 : OUT 213,0` to mute it.

Enter `NEW`, load one of the programs, then enter `RUN`. The static studies leave the head centred on the LCD and end. The animations repeat continuously; press Ctrl-C at the terminal to stop and `RUN` to restart. An interruption can leave a partly updated head; restarting clears and redraws it. Terminal instructions do not occupy LCD space.

The LCD programs follow the existing [LCD examples](../LCD/README.md): command port `R=218` (`0xDA`), data port `D=219` (`0xDB`), eight-bit interface, two lines, incrementing writes, and no cursor or blink. Both LCD rows are occupied by the head. Line starts are display-memory addresses `0x00` and `0x40`.

In the LCD programs, `DL=100` on line 30 controls the delay after every LCD command and data write. Increase it if the controller or CPU speed requires more settling time. Timing uses BASIC loops and is not calibrated in seconds.

## Single-bull animation

The 16-step sequence starts with gentle left/right rocking, adds two short head dips, moves further left, then sweeps right and dips again before returning to centre. Pauses vary between steps so the motion is less mechanical. This is a fixed repeating demonstration for tuning motion.

Configuration in `bull_animation.bas`:

| Setting                  | Meaning                                                                                        |
| ------------------------ | ---------------------------------------------------------------------------------------------- |
| `DL` (line 30)           | LCD settling delay; separate from the artistic timing                                          |
| `FD` (line 30)           | Frame hold unit, initially 150 iterations; larger values slow the holds                        |
| `W` (line 40)            | Visible width, initially 16; use an integer from 2 to 40 with the standard two-line addressing |
| `XC` (line 40)           | Automatically calculated centre column, zero based                                             |
| `NS` (line 50)           | Number of sequence steps, initially 16                                                         |
| `DATA` (lines 3020–3050) | Triples of pose number, column offset from centre, and positive hold multiplier                |

Pose numbers are `0` straight, `1` left, `2` right and `3` down. For example, `1,-2,2` shows the left pose two columns left of centre and holds it for `FD*2` iterations. Keep `NS` equal to the number of triples. Positions are clamped so both character columns fit. Keep `DL` and `FD` positive.

Frame preparation and LCD writes add time beyond the hold loop. With smaller `FD` values, these writes increasingly determine the pace. A cached pose requires no CGRAM reload, so preparation time can vary between steps.

### Four-cell frame updates

Storing all four poses as separate four-character groups would require 16 slots, while the LCD provides eight (even sharing identical tiles still needs 14 distinct characters). The demo keeps all 128 row values in BASIC memory and alternates between slots 0–3 and 4–7. While one group is visible, it loads the next pose into the other group. It then explicitly selects display memory and writes the four new character codes.

This avoids changing the pixels of a visible custom character during its definition. LCD cell writes are still sequential, so the transition is not atomic and may show a brief mixed frame. After drawing, the demo clears only the old columns outside the new two-column footprint, preserving overlapping cells. It never clears the whole screen during the loop. Each group's last pose is cached to avoid redundant uploads. All eight custom slots are used.

## Four synchronised bulls

`four_bulls_animation.bas` repeats the same 16-step pose sequence across four
heads in fixed positions. Their left columns are 1, 5, 9 and 13 (zero based),
leaving two blank columns between neighbours and a one-column outer margin.
All four share the same pose, so the program can alternate between two
four-slot character banks. A bank is reused only after every bull switches
away from it.

Line 30 sets `DL=100` for LCD writes and `FD=150` for frame holds. Line 40
sets `X0=1` (first column) and `SP=4` (distance between head starts). Keep all
four two-column heads inside the display. Unlike the single-bull demo, its
sequence uses **pairs** of pose number and hold multiplier at lines
3020–3050. `NS=16` must match the number of pairs. There is no sideways
movement in this version.

## Four random bulls

Load `four_bulls_random.bas` into a fresh BASIC program (`NEW`), then enter
`RUN`. Press Ctrl-C to stop.

Four 2×2 heads occupy columns 1–2, 5–6, 9–10 and 13–14 (zero based) on the
16×2 LCD, leaving two blank columns between neighbours. The same RC2014 LCD
ports (218/219) and glyph artwork are used as in the other studies.

Each bull has its own countdown of one to four scheduler ticks. When it
expires, that bull randomly chooses straight, left, right or down and starts
a new countdown. Choosing its current pose simply extends the hold.

The LCD can hold only two of these four-character poses at once. A bull can
switch to either loaded pose. A new pose is loaded only when an entire
four-slot bank has no visible users. If both banks are occupied, a request
for a third pose leaves the bull unchanged until its next random choice.
As bulls switch to a shared pose, the other bank becomes available again.
Consequently the bulls have separate random choices and timings, but their
available poses are constrained by the shared hardware. There is no fixed
sequence or forced synchronised change.

The program counts visible users of each bank and never redefines a visible
bank. Only the selected bull's four display cells are rewritten. Changes
are sequential LCD writes, so a brief mixed frame is still possible.

Line 30 sets `DL=100` for LCD write settling and `FD=150` for the pause after
each scheduler pass. Reduce `FD` for shorter pauses. Actual tick duration
also includes any glyph uploads and display writes during that pass; timing
is not calibrated. Line 40 controls the left column and spacing; defaults
fit a 16-column display. Keep each two-column head within the display and
leave space between heads.

Random choices use Microsoft BASIC's `RND(1)` generator without a custom
seed prompt. A fresh BASIC session may reproduce the same pseudo-random
stream. This is a visual demonstration, not a source of unpredictable data.

Source checks and a model of the bank allocation/display writes validate
pose data, spacing and safe bank reuse. On hardware, watch several cycles
for separate pose changes, clean gaps and absence of unintended changes to
neighbouring bulls. Check that all four poses eventually appear; no fixed
maximum wait is guaranteed. LCD timing and visual quality still need that
physical check.

## Filtered cartoon moo

Load `moo.bas` into a fresh Microsoft BASIC program (`NEW`) and enter `RUN`.
It plays three moos and then mutes. Use the SID-Ulator at D4/D5 (decimal
ports 212/213) with speakers or headphones. No LCD is required.

The sound keeps the low rising and
longer falling pitch contour, but sends one fixed-width pulse voice through
a moving resonant low-pass filter: muffled “mm”, an opening “OO”, then a
closing “oo”. The added noise, random pulse-width changes and large pitch
jitter are removed. Only a small irregular pitch variation remains during
the sustained middle.

The program clears all writable SID registers and uses voice 1. Register
23 routes it through the filter and sets resonance; register 24 enables
low-pass output while retaining master volume. Registers 21/22 receive the
11-bit cutoff split into three low bits and eight high bits. These follow
the [SID datasheet](https://www.waitingforfriday.com/?p=661).

### Tuning by ear

- Line 20: `NS=3` repetitions; `DL=40` hold per step. Increase it for a
  longer moo or reduce it for a shorter one. Filter register writes also
  contribute to the duration.
- Line 30: volume `VL=8`, attack `AT=7`, release `RL=9` (all 0–15).
  `GP=5000` leaves a release gap; increase it if the tail gets cut short.
- Line 40: starting frequency word `FL=1100`, peak `FH=1400`, final
  `FE=950`, step `FS=25`. Keep `20 < FE < FL < FH <= 65535` and choose
  a positive integer step that divides both sweep ranges exactly.
- Line 50: `CL=120` is the muffled cutoff, `CH=420` the open peak,
  `CM=300` the cutoff at the start of the falling tail. These are control
  values, not hertz. Keep `0 <= CL <= CM <= CH <= 2047`.
- Start by adjusting `CH`: increase it if too muffled, decrease it if too
  bright or buzzy. Adjust `CL` if the initial and final hum disappear.
- `RE=8` sets resonance (0–15). Increase it for a more pronounced hollow
  vowel; reduce it if the effect becomes whistle-like or too musical.

The SID-Ulator's emulated filter needs auditioning on the actual module;
these cutoff values are an initial experiment, not calibrated acoustic
frequencies. Source checks validate the register values and sweep bounds,
but the cartoon character must be judged by listening.

Timing depends on CPU speed. Normal completion releases the voice before
muting. If Ctrl-C leaves sound playing, enter `OUT 212,24 : OUT 213,0`.

## Four random bulls with moo

Load `four_bulls_random_moo.bas` into a fresh BASIC program (`NEW`) and enter
`RUN`. This standalone prototype combines the four random 2×2 bulls with
the current filtered moo. It requires both the LCD module (218/219) and
SID-Ulator (212/213).

The bulls use separate random choices and countdowns, with at most two
distinct poses visible at once, as in `four_bulls_random.bas`. They retain
the two-column gaps.

### Sound timing

This prototype prioritises the moo's established timing: the bulls briefly
hold their poses while it plays. No LCD writes or animation scheduling are
inserted into the sound's pitch/filter loops. On gate release, animation
resumes immediately while the SID generates the fading tail independently.
This is deliberately not simultaneous animation during the gated bellow.

The pitch/filter steps, envelope settings and delay of 40 are copied from
`moo.bas`. `SD` names the sound delay here; `DL` still controls LCD settling.
The small random middle-section pitch variation remains, so individual
calls vary. Absolute timing still depends on BASIC and CPU speed; moving
the routine into a larger program may add interpreter overhead and needs
an audition on the RC2014.

Between calls the program waits at least `INT(GP/FD)+1` animation passes,
plus a random 0–11 passes after each moo. Each pass includes `FD` delay
iterations, so there is at least the original `GP=5000` loop-iteration
budget for the release tail, with animation work adding more time. The first
moo occurs after the minimum interval. These are not calibrated seconds.

### Settings and stopping

- Line 30: LCD delay `DL=100` and animation pause `FD=150`.
- Line 3010: sound step delay `SD=40`; change this independently of `DL`.
- Lines 3020–3040: the same volume, envelope, pitch and filter settings
  documented under [Filtered cartoon moo](#filtered-cartoon-moo). Keep `FD`, `SD` and `GP` positive.
- Line 500: increase the added random pass count for less frequent calls.

Press Ctrl-C to stop. If sound remains, enter
`OUT 212,24 : OUT 213,0` to mute the SID. `RUN` reinitialises both devices.

Source checks verify that the sound-loop instructions match `moo.bas`
after line-number/delay-variable changes, that the glyph data is unchanged,
and that sound and LCD ports have separate variables. Hardware checks:
listen against `moo.bas`, confirm the short pose hold during each call,
and watch animation resume without cutting off the release tail.

## Glyph definitions

The individual files contain eight decimal row values per tile, alongside `REM` pixel previews, at lines 2000–2110. Values are 0–31, top to bottom, with bit 4 at the left. `#` is lit and `.` unlit. Tile order is:

```text
Top left     Top right
Bottom left  Bottom right
```

The animation copies those definitions unchanged at lines 2000–2640, in straight/left/right/down order. When revising a study, also update its four `DATA` rows in the animation. Custom definitions are volatile; rerun after power loss or after another program changes them.

The lean poses shift the face and muzzle sideways while keeping horn tips on the canvas. Right is the mirror of left. Head down lowers the horns two rows and compresses the forehead. Physical LCDs have gaps between cells and between display lines; assess the joins on the actual hardware.

## Verification on the RC2014

1. Run each static study to establish the expected pose.
2. Run the animation and check that all four poses match, both rows move together, and no old fragments remain after movement or the sequence restart.
3. Watch several cycles for corrupt pixels or flicker. Adjust `DL` for reliable writes, then tune `FD` and the hold multipliers for convincing movement.
4. Try a smaller display width setting to check the clamped positions, then restore the actual width.
5. Interrupt with Ctrl-C and rerun to confirm a clean restart.

Source/data checks and a display-memory simulation are used for software validation. BASIC execution, animation timing and appearance on the physical LCD still need verification.

Combined pixel previews (dividers indicate character boundaries):

### Head straight

```text
#....|....#
#....|....#
##...|...##
.##..|..##.
..###|###..
...##|##...
.####|####.
#####|#####
-----+-----
..#.#|#.#..
..###|###..
..###|###..
...##|##...
..###|###..
..#.#|#.#..
..###|###..
...##|##...
```

### Head left

```text
#....|....#
#....|....#
##...|...##
.##..|..##.
..###|###..
..###|#....
#####|###..
#####|###..
-----+-----
.#.##|.#...
.####|##...
.####|##...
.####|.....
#####|#....
#.##.|#....
#####|#....
.####|.....
```

### Head right

```text
#....|....#
#....|....#
##...|...##
.##..|..##.
..###|###..
....#|###..
..###|#####
..###|#####
-----+-----
...#.|##.#.
...##|####.
...##|####.
.....|####.
....#|#####
....#|.##.#
....#|#####
.....|####.
```

### Head down

```text
.....|.....
.....|.....
#....|....#
#....|....#
##...|...##
.##..|..##.
..###|###..
#####|#####
-----+-----
..#.#|#.#..
..###|###..
..###|###..
...##|##...
..###|###..
..#.#|#.#..
..###|###..
...##|##...
```
