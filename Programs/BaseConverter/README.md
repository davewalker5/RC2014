# Base Converter

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/BaseConverter/base_converter_text.png" alt="Base Converter" width="600">

Base Converter converts one-byte values between binary, octal, decimal, and hexadecimal. It includes a terminal-only version and a Digital I/O version that also displays the value on the eight LEDs.

## Hardware

The terminal-only program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for instructions and results

The Digital I/O program additionally requires an RC2014 Digital I/O card configured to use port 1.

## Program Files

| File                      | Description                                                     |
| ------------------------- | --------------------------------------------------------------- |
| `base_converter_text.bas` | Converts values and displays all four representations           |
| `base_converter_io.bas`   | Also displays the converted byte on the Digital I/O card's LEDs |

## Running the Programs

Load the required `.bas` file into BASIC and enter `RUN`.

Choose the base of the value you want to enter, then enter a value between 0 and 255. Binary input may contain `0` and `1`; octal input may contain digits `0` through `7`; decimal input may contain digits `0` through `9`; and hexadecimal input may also contain letters `A` through `F` in either case.

The program prints the value in all four bases. Enter `Q` at the source-base prompt to return to BASIC.

## Digital I/O Display

In `base_converter_io.bas`, the eight LEDs represent the eight bits of the converted value. LED 0 is the least-significant bit with byte value 1, and LED 7 is the most-significant bit with byte value 128. For example, decimal 129 lights LEDs 0 and 7.

The display remains lit while the next value is entered. All LEDs are cleared when `Q` is entered at the source-base prompt.

## Implementation Notes

Both versions deliberately accept values from 0 through 255 so every result fits exactly on the eight-bit Digital I/O display. Input is checked one character at a time before it changes the accumulated value. This prevents unsupported digits, empty values, and values above 255 from being accepted.

The output routine uses repeated division and the digit string `0123456789ABCDEF`. It does not rely on dialect-specific binary, octal, or hexadecimal formatting functions.

To use a Digital I/O card configured for a port other than 0, change `IP = 1` on line 20 of `base_converter_io.bas` to the required port number.

## References

- [Positional notation](https://en.wikipedia.org/wiki/Positional_notation), Wikipedia
- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
