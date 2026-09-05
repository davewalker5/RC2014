# Z80 Assembly Examples

Small Z80 assembly programs for the RC2014 Mini II running Small Computer Monitor (SCM).

## Hardware

The programs require:

- An RC2014 Mini II running SCM
- A serial terminal for entering monitor commands and viewing output
- A way to send text files over the serial connection, such as the [Serial Sender application](../../SerialSender/README.md)

| File              | RC2014 | Digital I/O | LCD Driver | SID-Ulator Sound Card |
| ----------------- | ------ | ----------- | ---------- | --------------------- |
| `message.asm`     | Yes    | No          | No         | No                    |
| `message_lcd.asm` | Yes    | No          | Yes        | No                    |
| `led.asm`         | Yes    | Yes         | No         | No                    |
| `buttons.asm`     | Yes    | Yes         | No         | No                    |

## Program Files

| File              | Description                                                                       |
| ----------------- | --------------------------------------------------------------------------------- |
| `message.asm`     | Prints a message from memory to the serial console, followed by a new line        |
| `message_lcd.asm` | Initialises and clears the LCD, then prints up to 16 characters on the first line |
| `led.asm`         | Displays an alternating LED pattern on the Digital I/O card                       |
| `buttons.asm`     | Reads the Digital I/O buttons once and displays their state on the LEDs           |

## Running the Programs

### Before Sending

Review the comments at the top of the selected file for any pre-send instructions. Complete those instructions at the SCM prompt before entering the assembler.

### Entering a Message into Memory

At the SCM prompt, enter:

```text
E 8100
```

SCM displays the existing contents of memory and prompts for replacement data. Enter the message with an opening double quote, then press Enter:

```text
"Hello, Z80!
```

Do not add a closing quote. At the next address, enter the zero byte that marks the end of the message:

```text
00
```

Press **Escape** to leave the memory editor. The message is now ready for either `message.asm` or `message_lcd.asm`. The LCD example displays only the first 16 characters.

To change the message later, repeat these steps, including the terminating `00`. There is no need to reload the program if it is still in memory.

### Sending and Running a File

All the program files contain assembly instructions to be loaded starting at address `8000`.

1. At the SCM prompt, enter `A 8000` and press Enter once to start the assembler
2. Do not press Enter again before sending the file
3. Send the selected `.asm` file using your normal serial-port and transfer settings
4. When using Serial Sender, for example:

   ```text
   SerialSender --send /path/to/message_lcd.asm --sendreset false
   ```

5. After sending completes, press **Escape** to leave the assembler
6. Enter `G 8000` to run the program

The sequence is **`A 8000` → send file → Escape → `G 8000`**.

The program returns to SCM when finished. Enter `G 8000` again to repeat it, or repeat the loading sequence to replace it with another example. Code and message data are stored in RAM and are lost when power is removed.

For `buttons.asm`, hold the desired buttons while entering `G 8000`. The program samples them once, rather than continuously monitoring them. The resulting LED pattern remains visible after it returns.

### Comments and Blank Lines

The text transmitted to SCM's assembler must not contain `;` comments or blank lines. SCM does not accept assembly comments, and a blank line advances past the instruction currently in memory. This can shift the loaded program and invalidate its call and jump addresses.

The Serial Sender application automatically removes the following from `.asm` files. Extension matching is case-insensitive, so `.ASM` and `.asm` behave identically:

- Whole comment lines whose first non-whitespace character is `;`
- Empty lines and lines containing only whitespace, including spaces or tabs

These lines are omitted completely, including their line endings. You can therefore keep header instructions, whole-line comments, and blank lines in the saved files when using the updated Serial Sender.

Inline comments, such as `LD A,$55 ; LED pattern`, are not removed. Put comments on their own lines instead. Semicolons within message text are preserved. Files with other extensions retain their comment lines and blank lines.

If sending with another tool, remove comments and blank lines from the transmitted text yourself, or configure equivalent filtering.

## Implementation Notes

SCM assembles each instruction directly into RAM. The LCD example uses fixed numeric call and jump addresses, so it must be assembled at `8000`. Adding instructions or changing their lengths requires recalculating those addresses.

Both message programs read a zero-terminated string at `8100`. The console example uses SCM's string-output and new-line functions. The LCD example initialises the controller, checks its busy flag before subsequent writes, and limits output to the first display line.

The Digital I/O examples use Z80 `IN` and `OUT` instructions. Change the port operands if the card is configured for another address. In `led.asm`, the value loaded into register A determines the eight-LED pattern; the file header lists example values.

To inspect a loaded program, enter `D 8000` at the SCM prompt and press Escape when finished. For `message_lcd.asm`, the first instruction should be `CALL $8054` at address `8000`. If it appears at a later address, reload without transmitting blank lines or extra Enter keystrokes.

## References

- [Zilog Z80 CPU User Manual (PDF)](https://www.zilog.com/docs/z80/um0080.pdf) — Official reference for the Z80 instruction set, registers, addressing modes, flags, and instruction timings.
- [Serial Sender application](../../SerialSender/README.md)
- [Small Computer Monitor documentation](https://rc2014.co.uk/troubleshooting/small-computer-monitor/)
- [Digital I/O examples](../DigitalIO/README.md)
- [LCD examples](../LCD/README.md)
