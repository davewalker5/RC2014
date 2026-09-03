# RC2014 LCD Driver Module

These programs display text on a two-line LCD connected through the RC2014 LCD Driver Module. One displays a fixed message across both lines, while the other repeatedly scrolls a message across the first line.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- An RC2014 LCD Driver Module
- A compatible two-line character LCD
- A serial terminal for entering the message

## Program Files

| File                   | Description                                                           |
| ---------------------- | --------------------------------------------------------------------- |
| `static_message.bas`   | Displays a fixed message across both lines                            |
| `scrolling_ticker.bas` | Scrolls a message from right to left across the first line repeatedly |

## Running the Program

Load the required program into BASIC and enter `RUN`.

### Static Message

Run `static_message.bas`, then enter the message to display when prompted. The program writes up to two lines of text, filling the first line before continuing onto the second. Any text beyond the capacity of both lines is ignored.

### Scrolling News Ticker

Run `scrolling_ticker.bas`, then enter the message to scroll when prompted. The message enters from the right of the first line, moves left one character at a time, and disappears at the left. It then starts again and continues until the program is interrupted.

The delay between movements defaults to 100 loop iterations. Change `DL` on line 60 of `scrolling_ticker.bas` to adjust the speed: a larger value scrolls more slowly, while a smaller value scrolls more quickly.

Both programs default to a 16-character-wide display. To use a display with a different width, change the value of `W` on line 50. For example, use `W=20` for a 20-character display.

## Implementation Notes

The LCD Driver Module uses port 218 (`0xDA`) for register commands and port 219 (`0xDB`) for character data. The program configures the display for an eight-bit interface, two lines, and a 5-by-8 dot character font.

Character LCD controllers do not normally place the second display line immediately after the visible end of the first line in display memory. After writing `W` characters, the program sends command 192 (`0xC0`) to move the cursor to address `0x40`, the start of the second line.

The scrolling ticker sends command 128 (`0x80`) before each frame to return to the start of the first line. It writes exactly `W` characters per frame, adding spaces before and after the message so the text enters and leaves a blank display cleanly. Rewriting the visible line also avoids relying on the LCD controller's internal display-shift behaviour, which can vary with display geometry.

## References

- [RC2014 LCD Driver Module](https://rc2014.co.uk/modules/lcd-driver-module/), RC2014
