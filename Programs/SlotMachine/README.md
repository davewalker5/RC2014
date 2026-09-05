# LCD Slot Machine

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/SlotMachine/slot_machine.gif" alt="LCD Slot Machine" width="600">

A three-reel slot machine for the RC2014 LCD Driver Module. Six custom graphical symbols cycle independently, slow down, and stop from left to right. The LCD shows the reels and result; the terminal accepts controls and reports payouts and credits.

## Hardware

- RC2014 Mini II running 32 KB Microsoft BASIC
- RC2014 LCD Driver Module with an HD44780-compatible 16-by-2 character LCD
- Serial terminal for loading the program and entering commands; ANSI support is not required

No Digital I/O card is required.

## Program Files

| File               | Description                                                            |
| ------------------ | ---------------------------------------------------------------------- |
| `slot_machine.bas` | Animated LCD reels with custom symbols, win detection and play credits |

## Running the Program

Load `slot_machine.bas` into BASIC and enter `RUN`.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/SlotMachine/slot_machine.png" alt="LCD Slot Machine" width="600">

Enter `S` followed by Return to spin, or `Q` followed by Return to quit. Lowercase commands also work. Invalid choices repeat the prompt without spending credits. Each spin runs to completion automatically; there are no hold or manual stop controls.

You start with 20 play credits. The terminal prints all three symbol names, the payout and the updated balance after each spin. The LCD keeps the stopped reels and result visible while you choose your next action. When credits run out or reach the 9,999-credit ceiling, enter `Y` to start a new game or `N` to quit. Quitting leaves the final reels and balance on the LCD. Credits exist only for the current run and have no cash value.

## Symbols and Payouts

The symbols are cherry, lemon, bell, diamond, heart and seven. Every spin costs one credit, deducted before the reels move. Only one payout is awarded:

| Result                                         | Credits returned | Net change including spin cost |
| ---------------------------------------------- | ---------------: | -----------------------------: |
| Three sevens                                   |               20 |                            +19 |
| Any other three matching symbols               |                8 |                             +7 |
| Exactly two matching symbols, in any positions |                2 |                             +1 |
| No matching symbols                            |                0 |                             -1 |

The balance is capped at 9,999 after a payout.

## Port Configuration and Timing

Configuration is grouped at the start of the source:

| Variable |      Default | Purpose                                                         |
| -------- | -----------: | --------------------------------------------------------------- |
| `LR`     | 218 (`0xDA`) | LCD command/register port                                       |
| `LD`     | 219 (`0xDB`) | LCD data port                                                   |
| `W`      |           16 | Visible width; use 16-40 with compatible two-line addressing    |
| `CD`     |          100 | Loop iterations after every LCD command and data write          |
| `DL`     |          100 | Base delay between animation frames                             |
| `SF`     |           12 | Frame on which the first reel stops; positive integer           |
| `SG`     |            8 | Additional frames before each subsequent stop; positive integer |
| `IC`     |           20 | Starting credits; integer from 1 to `MX`                        |
| `MX`     |         9999 | Credit ceiling; keep between `IC` and 9999                      |

The default stop frames are 12, 20 and 28. Larger `DL` values slow the animation; an additional five loop iterations per frame produce gradual deceleration. Timing is approximate and depends on CPU speed and BASIC overhead. `CD` is a separate conservative hardware delay, including after clear-display commands.

The layout requires at least 16 visible columns and uses the conventional line-start commands 128 (`0x80`) and 192 (`0xC0`). Wider compatible displays retain the same reel positions. Other display geometries require layout/address changes, not just a different width.

## Implementation Notes

The LCD is initialised for an eight-bit interface, two lines and a 5-by-8 font, with the cursor and blinking disabled. Six eight-byte patterns are loaded into CGRAM slots 0-5, then display RAM is selected again. Each `DATA` value describes one pixel row using its lowest five bits. Symbol names precede the pixel data and must remain in the same order.

The first line contains three brackets with reel symbols at zero-based columns 3, 7 and 11. Animation updates only these character cells. Once a reel stops, its symbol is left untouched while the others continue. Status writes pad the second line with spaces so shorter messages erase previous text without clearing the whole display.

Each reel starts with a separate `RND(1)` choice and advances by a random step of one to five symbols, wrapping across the six-symbol set. This guarantees a changing glyph on every active frame. Scoring uses the actual final displayed symbols. The program uses BASIC's existing pseudo-random sequence without a clock seed; a fresh interpreter session can repeat a sequence.

Subroutines separate animation (1000), scoring (2000), LCD initialisation (3000), padded text output (3200), credit formatting (3400) and hardware delay (3500).
