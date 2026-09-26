# Daisy Bell: Full Chorus with Speech and SID

This assembly player combines the complete Daisy Bell MIDI arrangement with MG005 speech for all seven lyric lines for the chorus.

## Hardware and Tools

- RC2014 with Small Computer Monitor (SCM)
- SID-Ulator sound card
- MG005 speech synthesiser
- Audio connections for both cards and a serial terminal for loading
- Python 3.10 or later for program generation
- Standalone `z80asm` for binary/HEX builds.

The generator supports assembly only. The earlier BASIC experiment remains in [Prototype](../Prototype/README.md).

## Source and Generated Files

| File                  | Purpose                                                              |
| --------------------- | -------------------------------------------------------------------- |
| `generate.py`         | Read MIDI and speech data, generate assembly, optionally assemble it |
| `player.asm.template` | Editable uppercase Z80 source, with comments in ordinary case        |
| `daisy-chorus.asm`    | Generated self-contained assembly source                             |
| `daisy-chorus.hex`    | Generated Intel HEX image for SCM                                    |
| `test_generate.py`    | MIDI parsing, chorus boundaries, speech extraction and CLI tests     |
| `test_asm.py`         | Assembly tables, build validation, HEX and CPU execution tests       |
| `test_player.c`       | CPU execution harness used by the Python tests                       |

Music comes from [DaisyBell.mid](../../MIDI/DaisyBell/DaisyBell.mid). The generator reads all tracks through their final event, including trailing silence; it does not cut playback after the first chorus line. The supported arrangement uses format-1 MIDI, a single initial 120 BPM tempo and three monophonic channels.

Speech comes from the seven tuned `daisy-chorus-line-1.bas` through `daisy-chorus-line-7.bas` files in [Speech/DaisyBell](../../Speech/DaisyBell). These are input data sources only: the generator reads their DATA records and neither generates nor executes a BASIC player.

`CUE_GROUPS` assigns each lyric group a chorus-relative time and a count of spoken allophones to consume from its source line. Original pause codes 0–4 are replaced by musical cue spacing and a PA1 after each group. All non-pause codes retain their source order. Pronunciation-length changes fail generation until the corresponding group counts are updated, preventing silent omissions.

| Lyric line                              | First cue after chorus begins |
| --------------------------------------- | ----------------------------: |
| Daisy, Daisy, give me your answer, do   |                     0 seconds |
| I'm half crazy, all for the love of you |                    12 seconds |
| It won't be a stylish marriage          |                  23.5 seconds |
| I can't afford a carriage               |                  28.5 seconds |
| But you'll look sweet                   |                  35.5 seconds |
| Upon the seat                           |                  38.5 seconds |
| Of a bicycle made for two               |                    41 seconds |

The last “two” starts at chorus-relative 45 seconds. Add three seconds to these values for time from program start. The first line retains the prototype's slightly early “give” and “me” cues. Later cues are aligned to melody onsets.

## Generate and Build

From the repository root:

```sh
python3 -B Programs/Singing/DaisyBell/generate.py --assemble
```

This writes `.asm`, `.bin` and `.hex` beside the generator. To generate source only, omit `--assemble`. Use `--assembler /path/to/z80asm` to select the assembler executable. The default tool is the standalone `z80asm`, as used by the [machine-code example](../../MachineCode/README.md).

No host packages beyond the Python standard library are required.

## Load and Run in SCM

1. Boot into SCM and wait for its `*` prompt
2. Send `daisy-chorus.hex` as plain text
3. If you're using the repository's `Serial Sender`:

   ```sh
   SerialSender --send Programs/Singing/DaisyBell/daisy-chorus.hex --sendreset false
   ```

4. Let the entire HEX file, including `:00000001FF`, finish
7. Wait for `Ready` and the monitor prompt
6. Enter `M E000` to inspect the start of the image
7. Before its first run the first seven bytes should be `C3 07 E0 FF 00 00 00`
10. Press **Escape** to leave the memory display and return to the `*` prompt.
11. Enter:

    ```text
    G E000
    ```

12. The tune starts with the two-bar introduction

The player mutes the SID and returns to the monitor when finished. Enter `G E000` again to replay. After it returns, enter `M E000` and inspect the header bytes (then press **Escape** to return to the prompt):

| Address     | Meaning                                                                                           |
| ----------- | ------------------------------------------------------------------------------------------------- |
| `E003`      | Result: `00` completed, `01` speech timeout, `FF` running/not yet run                             |
| `E004`      | Number of syllables whose first code was submitted over 20 software ticks late (nominally 100 ms) |
| `E005–E006` | Final software tick, low byte first; nominally 5 ms per tick                                      |

The player records these results in RAM rather than printing through a firmware API. At the default settings, normal completion is usually tick 11000 (`F8 2A` in memory): the 54-second arrangement plus a nominal one-second tail. Pending speech times out at tick 11600 (`50 2D`), nominally 58 seconds from the start. The generator sets this deadline to the MIDI duration plus four seconds. If speech finishes submitting after the music, the tail starts later. Result `00` confirms submission, not measured acoustic completion.

**Do not send the generated `.asm` file to SCM's `A` command.** It uses labels, `ORG`, `EQU`, `DB` and `DW` directives for the host cross-assembler. Send the Intel HEX image instead. A raw `.bin` also cannot be transferred as terminal text.

The supplied build occupies **E000–F06E**, including code, state and tables (**4,207 bytes**). The build rejects an image extending into FC00 or above, using the existing SCM workspace assumption. Confirm that boundary for the actual firmware; a successful size check does not allocate or reserve RAM.

The routine preserves AF, BC, DE, HL, IX and IY, leaves alternate registers and interrupt mode/enable state unchanged, and uses the caller's stack. It resets its own state on every entry. It does not poll Ctrl-C.

### Constraining the Program to Available Memory

Query SCM's recorded top-of-free-memory address at the `*` prompt:

```text
API $28
```

In the case of the current development machine, the results look like this:

```text
28 FBFF
```

The development setup is recorded as SCM v1.0 configuration R4 reporting `FBFF`. The command displays A followed by DE; **DE (`FBFF`) is the address to use**, not the leading `28`. The generator's limit is **exclusive**, so it must be one byte beyond that inclusive top address: `FBFF + 1 = FC00`. Check the value for the target firmware and update the constant accordingly:

```python
ASM_RAM_END = 0xFC00  # SCM reserves RAM from FC00 upwards.
```

API `$28` reads the monitor's recorded ceiling; it does not scan for unused RAM or allocate space. The [official SCM API reference](https://smallcomputercentral.com/small-computer-monitor/small-computer-monitor-v1-3/scm-v1-3-reference/) documents the result in DE. Confirm that the entire image range is writable and does not overlap another program, live BASIC data or the caller's stack before loading.

The build enforces `binary_size <= ASM_RAM_END - ASM_ORIGIN`. At E000 with an exclusive ceiling of FC00, the allowance is **1C00 hexadecimal / 7,168 bytes**. The current 4,207-byte image fits, leaving **2,961 bytes** below the ceiling. This is spare address space, not a separately reserved stack. If the ceiling changes, update the size assertions and permitted memory ranges in the tests as well as `ASM_RAM_END`; never raise the limit merely to bypass a failed build.

### Relocating the Program

For example, to load the program at D000 instead of E000:

| Location                         | Required change for D000                                                                                                                                                                                              |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `player.asm.template`            | Change `PLAYER_ORIGIN` from `0E000H` to `0D000H`.                                                                                                                                                                     |
| `generate.py`                    | Change `ASM_ORIGIN` from `0xE000` to `0xD000`. Keep `ASM_RAM_END = 0xFC00` if the firmware ceiling is unchanged.                                                                                                      |
| Build validation in `assemble()` | Change the expected opening bytes to `bytes((0xC3, 0x07, 0xD0))`, representing `JP D007`.                                                                                                                             |
| Loading instructions             | Use `G D000` and `M D000`; the initial seven bytes become `C3 07 D0 FF 00 00 00`.                                                                                                                                     |
| Diagnostic addresses             | Result becomes **D003**, late count **D004**, and tick count **D005–D006**.                                                                                                                                           |
| `test_asm.py`                    | Update the expected entry bytes and size allowance to `0x2C00`. Change the intentional wrong-origin fixture to relocate away from D000, for example to E000, so it still tests rejection.                             |
| `test_player.c`                  | Change the image load address, initial PC, permitted image-write range and diagnostic reads to D000-based addresses; change the load capacity from `0x1C00` to `0x2C00`. Move its synthetic stack as described below. |

The HEX round-trip unit test uses E000 as an independent sample address; it may retain that fixture because it does not load the player.

For the C harness, one suitable replacement stack is **C000**, with permitted stack writes in **BF00–C001**. Update initial SP, the two synthetic return-address bytes, the expected final SP (**C002**) and the stack-write guard together. The current stack at D000 would overwrite the relocated player's entry bytes. This is a test-harness change: the real player continues to use SCM's caller stack and must not set SP to C000 merely because the test does.

After changing the origin, regenerate **and reassemble**; labels and absolute references inside the assembly are then recalculated automatically. Changing only the Intel HEX load addresses would move the bytes without fixing those references. Update address-related comments and error messages, then run the assembly and CPU execution tests with the revised addresses.

## Timing Controls

Settings near the top of `player.asm.template` include:

| Setting        | Current value | Meaning                                                                                                        | Adjustment guidance                                                                                                                           |
| -------------- | ------------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `VOLUME`       | `2`           | SID accompaniment volume.                                                                                      | Range **0–15**: 0 is silent; 15 is loudest. Does not affect speech volume.                                                                    |
| `DELAY_LOOPS`  | `1416`        | Sets the delay between scheduler passes: approximately **5 ms on a 7.3728 MHz Z80**, plus processing overhead. | Increase to slow playback; decrease to speed it up. Valid range **1–65535**. Avoid 0: the counter wraps around, producing a long delay.       |
| `SID_REGISTER` | `0D4h` (212)  | Port used to select a SID register.                                                                            | Change only if the SID-Ulator’s configured port addresses change.                                                                             |
| `SID_DATA`     | `0D5h` (213)  | Port used to write a value to the selected SID register.                                                       | Must match the SID-Ulator’s data port.                                                                                                        |
| `SPEECH_PORT`  | `01Fh` (31)   | Port used to send allophone codes and read speech-card status.                                                 | Must match the MG005’s configured port.                                                                                                       |
| `SPEECH_READY` | `2`           | Status-bit mask: bit 1 indicates that the speech card can accept another allophone.                            | This is a **bit mask**, not a port number. Leave unchanged for the current MG005 interface.                                                   |
| `WAVEFORM`     | `16` (`10h`)  | Selects the SID triangle waveform.                                                                             | Bit 0 controls the gate and is managed by the player. Other waveforms may require additional setup, particularly pulse width for pulse waves. |

The delay loop costs `26 * DELAY_LOOPS + 32` Z80 T-states (processor clock cycles) including its call and return: 36,848 cycles at the default value, approximately 4.998 ms at 7.3728 MHz. Scheduler work, interrupts and wait states add time. Changing the CPU clock or `DELAY_LOOPS` scales the cue times, lateness threshold, tail and timeout; the separate SID clock determines musical pitch.

Change `CUE_GROUPS` in `generate.py` for speech alignment, or the assembly delay for overall pace. Assembly does not speed up the MG005's pronunciation; dense passages may still need cue or pronunciation changes.

## Testing

The test suite covers full-chorus MIDI and speech extraction, assembly generation, assembly builds, Intel HEX output and execution of the assembled Z80 player.

Run all commands below from the **repository root**.

### Available Tests

| Test group                 | Location                             | Requirements                                             | Coverage                                                                                                                                                                                                                                                                        |
| -------------------------- | ------------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MIDI and speech generation | `test_generate.py`                   | Python standard library                                  | Full arrangement boundaries, all seven speech lines, pronunciation edits and mismatched cue groups, assembly-only CLI from another working directory, running-status MIDI, zero-velocity releases, malformed MIDI, variable-length quantities and rejection of polyphonic input |
| Assembly generation        | `test_asm.py`                        | Python standard library                                  | SID gate transitions, speech group flags and tick conversion, template insertion markers, and Intel HEX checksums, addresses and round-trip decoding                                                                                                                            |
| Assembly build             | `test_asm.py`                        | Python and standalone `z80asm` on `PATH`                 | Successful assembly, expected entry jump, image size limit, EOF record, and rejection of a changed origin without replacing the existing binary                                                                                                                                 |
| Z80 execution              | `test_asm.py`, using `test_player.c` | Python, `z80asm`, `cc`, and the emulator's libz80 source | Actual instruction execution with immediately ready, 120 ms busy and permanently busy speech-card models                                                                                                                                                                        |

The Z80 execution test checks SID register writes, allophone order, cues not being sent early, full-chorus duration, completion/timeout status and final muting. Its C harness also checks stack balance, register and interrupt-state preservation, and that memory writes stay inside the player and stack regions. The Python test compiles and invokes the harness automatically; no separate manual C build is needed.

### Running All the Tests

To run all available tests:

```sh
python3 -B -m unittest discover -s Programs/Singing/DaisyBell -p 'test_*.py' -v
```

The build test runs when `z80asm` is installed; the execution test also needs `cc` and `SINGING_Z80_SOURCE`. Missing optional prerequisites produce explicit `skipped` results. `OK (skipped=...)` does not mean the machine-code execution checks ran.

To enable all the tests, point `SINGING_Z80_SOURCE` at the emulator's `libz80` source directory, containing `z80.c`, `z80.h` and the `codegen` folder. The tests compile that code directly; a built emulator application is not required:

```sh
SINGING_Z80_SOURCE=/path/to/Emulator/source/libz80 \
  python3 -B -m unittest discover -s Programs/Singing/DaisyBell -p 'test_*.py' -v
```

When the execution test is enabled, an incorrect source path or a compiler/assembler failure is a test failure, not a skip. The execution assertions assume the supplied origin, triangle waveform, cue data and timing settings; deliberate changes to these may require matching test updates.

The automated tests use temporary build/output directories and do not send anything to the physical RC2014 or overwrite the working playback files. The speech models check command submission rather than acoustic output.

### Run a Subset of Tests

For just MIDI parsing, full-chorus speech extraction and generator CLI tests:

```sh
python3 -B -m unittest discover -s Programs/Singing/DaisyBell -p 'test_generate.py' -v
```

For just assembly generation, build and execution tests:

```sh
SINGING_Z80_SOURCE=/path/to/Emulator/source/libz80 \
  python3 -B -m unittest discover -s Programs/Singing/DaisyBell -p 'test_asm.py' -v
```

The same optional-tool skip rules apply when running a subset.

### Python Style Checks

With Ruff installed, check formatting, imports, lint rules and annotation presence without modifying the files:

```sh
ruff check --select E,F,I,ANN Programs/Singing/DaisyBell/generate.py Programs/Singing/DaisyBell/test_generate.py Programs/Singing/DaisyBell/test_asm.py
ruff format --check Programs/Singing/DaisyBell/generate.py Programs/Singing/DaisyBell/test_generate.py Programs/Singing/DaisyBell/test_asm.py
```

Ruff is a development tool, not a runtime dependency of the generator. These commands report style issues separately from the functional tests; they do not perform static type checking.
