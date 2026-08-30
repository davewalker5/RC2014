# RC2014 Digital I/O Card

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/DigitalIO/led.gif" alt="LED Pattern Display" width="600">

_Digital I/O card mounted on the RC2014 Mini II running the LED pattern display program_

The programs demonstrate direct input and output and include an LED Animation Suite whose patterns are generated algorithmically rather than read from `DATA` statements.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- An RC2014 Digital I/O card configured to use port 0
- A serial terminal for instructions and results

No other expansion hardware is required.

## Program Files

| File          | Description                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| bounce.bas    | Bounces one lit LED between the ends of the eight-LED row                                                     |
| bincount.bas  | Displays an eight-bit binary count from 0 to 255                                                              |
| graycode.bas  | Displays a reflected Gray-code count in which only one LED changes at each step                              |
| keypress.bas  | Reads button presses and toggles the corresponding LED                                                        |
| larson.bas    | Sweeps a three-LED Larson scanner eye from side to side                                                       |
| led.bas       | Repeatedly displays an LED sequence defined in `DATA` statements                                              |
| lfsr.bas      | Generates pseudo-random LED patterns with an eight-bit linear-feedback shift register                         |
| pattern.bas   | Converts an entered pattern of eight binary digits to the corresponding output value                          |

## Running the Program

Load the required `.bas` file into BASIC and enter `RUN`.

The LED Animation Suite programs prompt for a delay-loop count. Larger values make each frame remain visible for longer. Loop timing is approximate and depends on the computer; start with the default displayed by the program and adjust it to suit the hardware.

Each animation also asks how long it should run. On completion it switches all LEDs off and returns to BASIC.

## LED Animation Algorithms

- `larson.bas` calculates a three-bit value and shifts it across the output byte, then reverses direction.
- `bounce.bas` raises 2 to successive powers to move a single set bit across the output byte and back.
- `bincount.bas` writes each integer from 0 through 255 directly to the output port.
- `graycode.bas` calculates each reflected Gray-code value using the equivalent expression `(count OR shifted-count) - (count AND shifted-count)` because this BASIC has no `XOR` keyword.
- `lfsr.bas` uses an eight-bit maximal-length linear-feedback shift register. A non-zero seed selects the starting point in its 255-value cycle.

## RC2014 Digital I/O Card

The Digital I/O card is an additional kit plugging into the 40-pin bus header of the RC2014 Mini II and providing eight lines of digital input via keys mounted on the card and eight lines of digital output via LEDs, also mounted on the card (see the references for details).

## Implementation Notes

### Using a Different I/O Port

To use a Digital I/O card configured for port `P` instead of port 0:

- In `keypress.bas`, replace every `INP(0)` with `INP(P)`, and replace `OUT 0, B` with `OUT P, B`.
- In `led.bas`, replace `OUT 0, LED(I)` with `OUT P, LED(I)`.
- In each LED Animation Suite file, change `OP = 0` on line 20 to the required port number.
- `pattern.bas` does not access the Digital I/O card directly, so it requires no change.

For example, for a card configured for port 1, use `INP(1)` and `OUT 1, value`.

## References

- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
- [Gray Code](https://mathworld.wolfram.com/GrayCode.html), Wolfram MathWorld
- [Larson Scanner](https://wiki.evilmadscientist.com/Larson_Scanner), Evil Mad Scientist Laboratories
- [Pseudo-Random Number Generation Using Linear Feedback Shift Registers](https://www.analog.com/en/resources/design-notes/random-number-generation-using-lfsr.html), Analog Devices
- [Linear-Feedback Shift Register Primer](https://users.ece.utexas.edu/~bevans/courses/realtime/lectures/laboratory/stm32h735gdk/lab4/primer.html), University of Texas at Austin
