# RC2014 LCD Driver Module

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/LCD/animated_glyph.gif" alt="Animated Glyph" width="600">

_LCD Display Driver with 2x16 digit display mounted on the RC2014 Mini II running the animated glyph program_

These programs display text and custom characters on a two-line LCD connected through the RC2014 LCD Driver Module. They include fixed-message, scrolling-message, and custom-glyph demonstrations.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- An RC2014 LCD Driver Module with LCD display
- A serial terminal for entering the message

## Program Files

| File                   | Description                                                           |
| ---------------------- | --------------------------------------------------------------------- |
| `static_message.bas`   | Displays a fixed message across both lines                            |
| `blinking_message.bas` | Blinks a preserved message by enabling and disabling the display      |
| `scrolling_ticker.bas` | Scrolls a message from right to left across the first line repeatedly |
| `hardware_ticker.bas`  | Scrolls a message using the LCD controller's hardware display shift   |
| `custom_glyph.bas`     | Demonstrates defining and displaying a custom 5-by-8 glyph            |
| `animated_glyph.bas`   | Animates a two-frame custom glyph in a fixed display position         |
| `moving_glyph.bas`     | Moves an animated two-frame custom glyph across the first line        |

## Running the Program

Load the required program into BASIC and enter `RUN`.

### Static Message

Run `static_message.bas`, then enter the message to display when prompted. The program writes up to two lines of text, filling the first line before continuing onto the second. Any text beyond the capacity of both lines is ignored.

### Blinking Message

Run `blinking_message.bas`, then enter the message to display. The program writes up to two lines using the same layout as `static_message.bas`, then repeatedly disables and restores the visible display. Command 8 blanks the LCD without erasing display memory, so the original message reappears when command 12 enables the display again.

The visible and blank intervals both default to 300 loop iterations. Change `DL` on line 50 to adjust the blinking speed.

### Scrolling News Ticker

Run `scrolling_ticker.bas`, then enter the message to scroll when prompted. The message enters from the right of the first line, moves left one character at a time, and disappears at the left. It then starts again and continues until the program is interrupted.

The delay between movements defaults to 100 loop iterations. Change `DL` on line 60 of `scrolling_ticker.bas` to adjust the speed: a larger value scrolls more slowly, while a smaller value scrolls more quickly.

### Hardware News Ticker

Run `hardware_ticker.bas` to place a message in the LCD controller's hidden display memory and reveal it using hardware display-shift commands. Unlike `scrolling_ticker.bas`, it does not redraw every visible character for each frame.

Set `DR` on line 70 to configure the direction. Use `DR=1` to make the text enter from the right and move left, or `DR=-1` to make it enter from the left and move right. Change `DL` on line 60 to adjust the speed.

The program assumes the usual 40 display-memory positions per controller line. With a 16-character visible display, messages are therefore limited to 24 characters. Change `W` on line 40 for another visible width. The second display line should be left blank because a hardware display shift affects the entire display rather than one line independently.

### Custom Glyphs

Run `custom_glyph.bas` to define a glyph in custom-character slot 0 and display it after a text label. The supplied program uses an octopus pattern, but its `REM` and `DATA` statements can be replaced with any of the examples below. Change `T$` on line 180 if a different display label is wanted.

Each glyph is described by eight values from top to bottom. The lowest five bits of each value control the five pixels in that row. The `REM` statement gives a compact source-code preview in which `#` is a lit pixel and `.` is an unlit pixel.

```basic
REM OCTOPUS FRAME 1
REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  .#.#.
DATA 14,21,31,31,14,21,21,10

REM OCTOPUS FRAME 2
REM .###.  #.#.#  #####  #####  .###.  #.#.#  .###.  .#.#.
DATA 14,21,31,31,14,21,14,10

REM OCTOPUS FRAME 3
REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  #.#.#
DATA 14,21,31,31,14,21,21,21

REM SMILEY FACE
REM .....  .#.#.  .#.#.  .....  #...#  .###.  .....  .....
DATA 0,10,10,0,17,14,0,0
```

The glyph is stored in volatile character-generator RAM and must be defined again after the LCD loses power or is reset.

The program explicitly selects incrementing address mode and uses a conservative delay after every LCD command and data write. This accommodates controllers that remain busy longer than the BASIC instruction overhead on a particular RC2014 clock configuration.

### Animated Glyph

Run `animated_glyph.bas` to load three octopus frames into custom-character slots 0, 1 and 2. The program displays `CUSTOM GLYPH ` followed by the glyph, then cycles the character in that position through frames 1, 2 and 3 before returning to frame 1. Change `DL` on line 40 to adjust the animation speed.

### Moving Glyph

Run `moving_glyph.bas` to load two octopus frames into custom-character slots 0 and 1. The program starts at the left of the first display line, erases the previous position as it moves right, and alternates between the two frames at every step. After reaching the right edge it clears the glyph and starts again.

The program defaults to a 16-character-wide display. Change `W` on line 40 for a different display width. Change `DL` on line 50 to adjust the movement speed: a larger value moves more slowly, while a smaller value moves more quickly.

The static-message and scrolling-ticker programs default to a 16-character-wide display. To use a display with a different width, change the value of `W` on line 50. For example, use `W=20` for a 20-character display.

## Implementation Notes

The LCD Driver Module uses port 218 (`0xDA`) for register commands and port 219 (`0xDB`) for character data. The program configures the display for an eight-bit interface, two lines, and a 5-by-8 dot character font.

## Static Message
Character LCD controllers do not normally place the second display line immediately after the visible end of the first line in display memory. After writing `W` characters, the program sends command 192 (`0xC0`) to move the cursor to address `0x40`, the start of the second line.

## Blinking Message

The blinking-message program alternates display-control commands 8 (`0x08`) and 12 (`0x0C`). These commands change display visibility without modifying display data RAM, allowing the complete message to blink without being rewritten. The display is left enabled whenever the program is interrupted during its visible interval; if it is interrupted while blank, enter `OUT 218,12` at the BASIC prompt to restore it.

## Scrolling News Ticker

The scrolling ticker sends command 128 (`0x80`) before each frame to return to the start of the first line. It writes exactly `W` characters per frame, adding spaces before and after the message so the text enters and leaves a blank display cleanly. Rewriting the visible line also avoids relying on the LCD controller's internal display-shift behaviour, which can vary with display geometry.

## Hardware News Ticker

The hardware ticker stores its message outside the visible window in the first line's 40-character display-memory range. Command 24 (`0x18`) shifts the display left and command 28 (`0x1C`) shifts it right. Command 2 returns the shifted display window home between repetitions without rewriting the message. Hardware shifting moves both display lines together, and its address behaviour may vary on displays with a different geometry or controller implementation.

## Custom Glyphs

The LCD controller provides eight programmable 5-by-8 characters in character-generator RAM. Command 64 (`0x40`) selects the first custom-character definition, eight data writes supply its rows, and data value 0 subsequently displays it. A display-memory command such as 128 (`0x80`) must be sent after defining the character so that later data is written to the screen rather than to character-generator RAM.

## References

- [RC2014 LCD Driver Module](https://rc2014.co.uk/modules/lcd-driver-module/), RC2014
