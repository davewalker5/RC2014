# Reflex Games

Reflex games for the RC2014 with Digital I/O card.

## Hardware

Both programs require:

- An RC2014 Mini II running BASIC
- An RC2014 Digital I/O card configured to use port 1
- A serial terminal for instructions and scores

All eight buttons and LEDs are used. Each LED has a corresponding button with the same byte value: 1, 2, 4, 8, 16, 32, 64, or 128. Press only one button at a time.

## Program Files

| Filename             | Program                                                               |
| -------------------- | --------------------------------------------------------------------- |
| `reaction_timer.bas` | A single-attempt reaction timer with false-start detection and a best score |
| `button_reflex.bas`  | A 20-round game with random targets, increasing difficulty, score, and lives |

## Running the Program

Load the required program, from the table above, into BASIC and enter `RUN`.

## Reaction Timer

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Reflex/reaction_timer.png" alt="Reaction Timer" width="600">

When prompted, press and release any button to arm the timer. After a random pause, one LED lights. Press its matching button as quickly as possible.

Pressing a button during the random pause is a false start. Pressing the wrong button, including multiple buttons at once, also invalidates the attempt. A valid response is reported as a polling-loop count, and the lowest valid count is retained as the best score for the current run. Choose `Y` after an attempt to arm the timer again.

## Button Reflex Game

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Reflex/button_reflex.png" alt="Reaction Timer" width="600">

When prompted, press and release any button to begin. In each round, a randomly selected LED lights. Press the matching button before the response limit expires.

The game has 20 rounds and starts with three lives. A correct response adds one point. A timeout, wrong button, or simultaneous button press costs one life. The response limit decreases after every round, making later targets harder. The game ends when all lives are lost or all 20 rounds are complete.

## Configuration

The settings are grouped at the beginning of each source file.

### `reaction_timer.bas`

| Line | Variable | Default | Purpose                         |
| ---- | -------- | ------- | ------------------------------- |
| 20   | `MN`     | 300     | Minimum random pre-light delay  |
| 30   | `MX`     | 1200    | Maximum random pre-light delay  |
| 40   | `DB`     | 20      | Button debounce delay           |

### `button_reflex.bas`

| Line | Variable | Default | Purpose                                  |
| ---- | -------- | ------- | ---------------------------------------- |
| 20   | `MX`     | 20      | Number of rounds                         |
| 30   | `ST`     | 1200    | Response limit in the first round        |
| 40   | `DC`     | 40      | Response-limit reduction per round       |
| 50   | `ML`     | 300     | Minimum response limit                   |
| 60   | `GP`     | 75      | Unlit gap before displaying each target  |
| 70   | `DB`     | 20      | Button debounce delay                    |

All delay and response values are BASIC loop or polling counts, not milliseconds. Their real duration varies with the machine and BASIC configuration. Calibrate `MN`, `MX`, `ST`, `DC`, `ML`, `GP`, and `DB` on the target RC2014 if either game feels too fast or slow.

## Implementation Notes

### Program Implementation Details

- Target LEDs are stored as single-bit byte values, so the same value can be written to the output port and compared directly with the input port.
- Both programs vary the deterministic `RND` sequence using the time taken to press the start or arm button.
- The reaction timer checks the input throughout its random delay to detect false starts.
- The multi-round game measures each response with a bounded polling loop, which also supplies its time limit.
- Input routines wait for all buttons to be released and apply a short debounce delay.
- Multiple simultaneous buttons produce a byte value different from the single target and are treated as a wrong response.
- Both programs clear all LEDs before replay and before exiting.

Timing is intentionally described as approximate because the standard RC2014 Mini II configuration does not provide an accurate application timer to BASIC.

### Using a Different I/O Port

To use a Digital I/O card configured for port `P` instead of port 1, make the following changes in both `reaction_timer.bas` and `button_reflex.bas`:

- Replace every `INP(1)` with `INP(P)`.
- Replace every `OUT 1, value` statement with `OUT P, value`.

For example, for a card configured for port 0, use `INP(0)` and `OUT 0, value`.

## Reference

- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
