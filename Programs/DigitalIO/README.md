# RC2014 Digital I/O Card

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/DigitalIO/led.gif" alt="LED Pattern Display" width="600">

_Digital I/O card mounted on the RC2014 Mini II running the LED pattern display program_

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- An RC2014 Digital I/O card configured to use port 0
- A serial terminal for instructions and results

No other expansion hardware is required.

## Program Files

| Filename     | Program                                                                                                       |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| pattern.bas  | Enter a pattern of 1s and 0s to determine the value to write to the I/O card to match the pattern on the LEDs |
| keypress.bas | Read keypresses on the I/O card to toggle on/off the corresponding LED                                        |
| led.bas      | Given a set of DATA statements defining the LED pattern sequence, repeatedly display that pattern             |

## Running the Program

Load the required program, from the table above, into BASIC and enter `RUN`

## RC2014 Digital I/O Card

The Digital I/O card is an additional kit plugging into the 40 pin bus header of the RC2014 Mini II and providing 8 lines of digial input via keys mounted on the card and 8 lines of digital output via LEDs, also mounted on the card (see the references for details).

## Implementation Notes

### Using a Different I/O Port

To use a Digital I/O card configured for port `P` instead of port 0:

- In `keypress.bas`, replace every `INP(0)` with `INP(P)`, and replace `OUT 0, B` with `OUT P, B`.
- In `led.bas`, replace `OUT 0, LED(I)` with `OUT P, LED(I)`.
- `pattern.bas` does not access the Digital I/O card directly, so it requires no change.

For example, for a card configured for port 1, use `INP(1)` and `OUT 1, value`.

## References

- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
