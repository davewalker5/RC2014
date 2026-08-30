# Electronic Dice

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Dice/dice.gif" alt="Memory" width="600">

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Dice/dice.png" alt="Memory" width="600">

Electronic Dice turns the RC2014 Digital I/O card into a coin, a D6, a D8, or an eight-bit random-number generator. Each button press starts a rolling LED animation, after which the LEDs show the result and the terminal prints it.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- An RC2014 Digital I/O card configured to use port 0
- A serial terminal for instructions and results

No other expansion hardware is required. The implementation notes include details on how to change the programs to use a card configured for a different port.

## Program Files

| File     | Description                           |
| -------- | ------------------------------------- |
| dice.bas | Implementation of the electronic dice |

## Running the Program

Load `dice.bas` into BASIC and enter `RUN`

## Using the Dice

When prompted, press one of these Digital I/O buttons:

| Button Number | Button Value | Mode        | LED Result                                           |
| ------------- | ------------ | ----------- | ---------------------------------------------------- |
| `0`           | `1`          | Coin        | Alternating pattern: `85` for tails, `170` for heads |
| `1`           | `2`          | D6          | Result from 1 to 6 as a binary byte                  |
| `2`           | `4`          | D8          | Result from 1 to 8 as a binary byte                  |
| `3`           | `8`          | Random byte | Result from 0 to 255 as a binary byte                |
| `7`           | `128`        | Quit        | Clears all LEDs and ends the program                 |

The byte values identify the card inputs independently of their physical left-to-right arrangement. The terminal also prints `HEADS`, `TAILS`, or the numeric result, so no binary conversion is required to use the program.

Pressing multiple buttons together or an unlisted button flashes all eight LEDs and returns to the prompt. The program waits for the buttons to be released and applies a short debounce delay before continuing.

## Configuration

The configuration values are at the start of `dice.bas`:

| Line | Variable | Default | Purpose                              |
| ---- | -------- | ------- | ------------------------------------ |
| 20   | `DL`     | 35      | Delay between rolling animation LEDs |
| 30   | `DB`     | 20      | Debounce delay after button release  |

These values are BASIC loop counts, not exact time units. Adjust them if the animation is too fast or slow, or if physical button bounce causes unwanted input on the target machine.

## Implementation Notes

### Dice Randomness and Program Control

- D6 and D8 results use `1 + INT(RND(1) * N)`; the random-byte mode uses `INT(RND(1) * 256)`
- The program counts while waiting for a button and discards that many random values before each roll
- This allows the timing of the player's press to vary the otherwise deterministic random sequence without a real-time clock
- The rolling animation uses every LED. The final result remains visible until another mode is selected
- Choosing Quit clears the output port before the program ends

### Using a Different I/O Port

To use a Digital I/O card configured for port `P` instead of port 0, replace every `INP(0)` in `dice.bas` with `INP(P)`, and replace every `OUT 0, value` statement with `OUT P, value`. For example, for a card configured for port 1, use `INP(1)` and `OUT 1, value`.

## References

- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
