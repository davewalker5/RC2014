# RC2014 LCD Driver Module

This program displays a message on a two-line LCD connected through the RC2014 LCD Driver Module. Text fills the first line before continuing onto the second line.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- An RC2014 LCD Driver Module
- A compatible two-line character LCD
- A serial terminal for entering the message

## Program Files

| File               | Description                                                        |
| ------------------ | ------------------------------------------------------------------ |
| static_message.bas | Displays a message across both lines of an LCD Driver Module display |

## Running the Program

Load `static_message.bas` into BASIC and enter `RUN`.

At the prompt, enter the message to display. The program writes up to two lines of text, filling the first line before continuing onto the second. Any text beyond the capacity of both lines is ignored.

The display width defaults to 16 characters. To use a display with a different width, change the value of `W` on line 50. For example, use `W=20` for a 20-character display.

## Implementation Notes

The LCD Driver Module uses port 218 (`0xDA`) for register commands and port 219 (`0xDB`) for character data. The program configures the display for an eight-bit interface, two lines, and a 5-by-8 dot character font.

Character LCD controllers do not normally place the second display line immediately after the visible end of the first line in display memory. After writing `W` characters, the program sends command 192 (`0xC0`) to move the cursor to address `0x40`, the start of the second line.

## Acknowledgements

The program is based on the example program published on the RC2014 website for the LCD Driver Module.

## References

- [RC2014 LCD Driver Module](https://rc2014.co.uk/modules/lcd-driver-module/), RC2014
