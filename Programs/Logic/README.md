# Logic Gate Demonstrator

The Logic Gate Demonstrator shows how the AND, OR, XOR and NOT Boolean operations respond to false (`0`) and true (`1`) inputs. It includes a terminal-only truth-table program and an interactive version for the RC2014 Digital I/O card.

## Hardware

The terminal-only program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for instructions and results

The Digital I/O program additionally requires an RC2014 Digital I/O card configured to use port 1.

## Program Files

| File             | Description                                                          |
| ---------------- | -------------------------------------------------------------------- |
| `logic_text.bas` | Prints complete AND, OR, XOR and NOT truth tables                    |
| `logic_io.bas`   | Reads two button inputs and displays all five gate results using LEDs |

## Running the Programs

Load the required `.bas` file into BASIC and enter `RUN`.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Logic/logic_text.png" alt="Text-based Logic Gate Demonstration" width="600">

`logic_text.bas` prints the complete truth tables and then returns to BASIC. In each table, `A` and `B` are inputs and `Q` is the result.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Logic/logic_io.png" alt="Digital I/O Logic Gate Demonstration" width="600">

For `logic_io.bas`, hold button 0 to make input A true and hold button 1 to make input B true. The LEDs update whenever either input changes. Press button 7 to finish; the program clears all LEDs before returning to BASIC.

## Digital I/O Assignments

The Digital I/O version uses the following bit assignments:

| Card control | Byte value | Purpose     |
| ------------ | ---------- | ----------- |
| Button 0     | 1          | Input A     |
| Button 1     | 2          | Input B     |
| Button 7     | 128        | Exit        |
| LED 0        | 1          | A AND B     |
| LED 1        | 2          | A OR B      |
| LED 2        | 4          | A XOR B     |
| LED 3        | 8          | NOT A       |
| LED 4        | 16         | NOT B       |

Buttons and LEDs are separate electrical lines, so a button and an LED may use the same byte value without conflict. Buttons 2 through 6 are ignored.

## Implementation Notes

Microsoft BASIC on the RC2014 does not provide an `XOR` keyword. For one-bit inputs the programs calculate XOR as `(A OR B) - (A AND B)`. NOT is calculated as `1 - A` or `1 - B` so its result remains the Boolean value 0 or 1.

To use a Digital I/O card configured for a port other than 1, change `IP = 1` on line 20 of `logic_io.bas` to the required port number.

## References

- [Truth Tables](https://www.allaboutcircuits.com/textbook/digital/chpt-7/truth-tables/), All About Circuits
- [RC2014 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
