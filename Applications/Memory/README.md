# Memory


<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Memory/memory.gif" alt="Memory" width="600">

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Memory/memory.png" alt="Memory" width="600">

Memory is a memory game for the RC2014 Digital I/O card. The computer displays an increasingly long sequence using four LEDs. The player must repeat the sequence using the corresponding buttons.

## Hardware

The application requires:

- An RC2014 Mini II running Microsoft BASIC
- An RC2014 Digital I/O card configured to use port 0
- A serial terminal for instructions and scores

The four buttons and LEDs whose byte values are 1, 2, 4, and 8 are used. These correspond to the lowest four bits of the Digital I/O port. The program does not depend on whether those bits appear on the left or right of the physical card.

## Playing the Game

1. Run `memory.bas`.
2. Press any button on the Digital I/O card when prompted
3. Watch the sequence displayed on the four game LEDs
4. Repeat the sequence using the corresponding buttons
5. Press only one button at a time

The first round contains one value. One new random value is added after every successful round. The game finishes when the player enters an incorrect value or completes the maximum sequence of 20 values.

The terminal displays the current round and the number of completed rounds. All eight LEDs flash three times after an incorrect entry. A moving LED pattern is displayed after all 20 rounds are completed.

Pressing more than one button at once, or pressing one of the four unsupported buttons, counts as an incorrect entry.

## Configuration

The configuration values are at the start of `memory.bas`:

| Line | Variable | Default | Purpose                                           |
| ---- | -------- | ------- | ------------------------------------------------- |
| 20   | `DL`     | 200     | Length of time that each sequence LED remains lit |
| 30   | `GP`     | 75      | Gap between successive sequence LEDs              |
| 40   | `DB`     | 20      | Debounce delay after a button is released         |
| 50   | `MX`     | 20      | Maximum sequence length                           |

The delay values are BASIC loop counts rather than exact units of time. They may be adjusted if the display is too fast or slow on the target machine. If `MX` is changed, the `SQ` array dimension on line 60 must remain at least as large as the maximum sequence length.

## Implementation Notes

- Sequence values are stored as the single-bit values 1, 2, 4, and 8
- A stored value can therefore be written directly to the LED output port and compared directly with the button input port
- The program waits for all buttons to be released after each press with a short additional delay providing simple debouncing
- Button presses do not illuminate the LEDs during player input to keep input feedback visually separate from the sequence displayed at the start of the next round
- The time taken to press the initial start button determines how many random values are discarded before the game begins in order to vary the sequence without requiring a real-time clock
- The output port is cleared after each input, after each display pattern, before replay, and before the program ends
- Timing is approximate because the base RC2014 has no accurate timer available to BASIC

## Acknowledgements

_Memory_ is a memory game inspired by the pattern-repetition gameplay popularised by the Simon electronic game, created by Ralph H. Baer and Howard J. Morrison. Simon is a trademark of Hasbro, Inc. This project is independent and is not affiliated with or endorsed by Hasbro.

## References

- [Simon game](https://en.wikipedia.org/wiki/Simon_(game)), Wikipedia
- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
