# Daisy Bell: Speech and SID Prototype

## Hardware

The program requires:

- An RC2014 running Microsoft BASIC for the BASIC version, or Small Computer Monitor (SCM) for the assembly version
- A nominal **7.3728 MHz Z80** for the supplied assembly timing settings
- A SID-Ulator with register/data ports **D4/D5 hexadecimal** (212/213 decimal), using a **1 MHz SID clock** for the generated pitches
- An MG005 speech synthesiser at port **1F hexadecimal** (31 decimal), with readiness reported by bit 1
- Audio connections for both cards, using separate speakers or suitable mixer inputs
- A serial terminal for loading programs and displaying messages

Host-side generation requires **Python 3.10 or later** and its standard library. Building the assembly output additionally requires standalone `z80asm`; prebuilt HEX playback does not require Python or an assembler on the RC2014.

## Program Files

| File                           | Description                                                             |
| ------------------------------ | ----------------------------------------------------------------------- |
| `daisy-line-1.asm`             | Generated, self-contained Z80 source for standalone `z80asm`            |
| `daisy-line-1.bas`             | Generated BASIC player with music and speech DATA                       |
| `daisy-line-1.bin`             | Raw assembled bytes; local build output ignored by Git                  |
| `daisy-line-1.hex`             | Intel HEX image with load addresses and checksums, ready to send to SCM |
| `generate.py`                  | Generator for BASIC or Z80 assembly, with an optional binary/HEX build  |
| `player.asm.template`          | Editable Z80 Assembly player                                            |
| `player.bas.template`          | Editable BASIC player template                                          |
| `test_generate.py`             | MIDI parsing and BASIC generation tests                                 |
| `test_asm.py`                  | Assembly generation, build and execution tests                          |
| `test_player.c`                | CPU execution harness compiled by `test_asm.py`                         |

---

## BASIC Version

The program uses an **approximate software tick**, not a real clock. It preloads all data, updates due SID events, and attempts one eligible allophone per pass. A busy speech card never traps the player in a waiting loop. SID and speech cues share the same counter, so neither has an independent delay chain. BASIC processing still adds variable overhead, especially at note changes: 25 ms is the event-table unit, not a guaranteed real-time interval.

Make persistent timing changes on line 40 of `player.bas.template`, then regenerate the BASIC listing:

- `TA` is how many table ticks to advance per pass (default 1.25) - increasing it speeds up playback; decreasing it slows it down
- Larger values of `TA` reduce speech polling opportunities and so reduce cue precision
- `DL` is the extra delay-loop count per pass (currently 0); increasing it adds slowing
- `SO` shifts every speech cue in nominal 25 ms units (currently 0); negative values advance speech and positive values delay it
- `DL` should be non-negative and `TA` positive

SID volume is set separately on line 160: `OUT RP,24:OUT DP,2`. Choose a final value between 0 (silent) and 15 (maximum); this does not change speech volume.

The generator's `CUES` table is shared by both versions and contains individual syllable timings and codes. Times are nominal score times relative to the chorus, after the three-second introduction; actual elapsed times depend on playback calibration:

| Seconds | Syllable | Allophones (before terminating PA1) |
| ------: | -------- | ----------------------------------- |
|       0 | Dai      | DD2 EY                              |
|     1.5 | sy       | SS IY                               |
|       3 | Dai      | DD2 EY                              |
|     4.5 | sy       | SS IY                               |
|     5.9 | give     | GG1 IH VV                           |
|     6.4 | me       | MM EY                               |
|       7 | your     | YY1 OR1                             |
|     7.5 | an       | AE NN1                              |
|     8.5 | swer     | SS WW ER1                           |
|       9 | do       | DD1 UW2                             |

The original line's allophones are preserved in order; its sentence pauses are replaced by separately cued groups with short PA1 terminations. Vowels finish naturally, leaving space during held notes. The chip's readiness means it can accept a command, not necessarily that the previous sound has ended.

If speech falls behind, codes remain in order and are sent when possible. The music does not wait. Any codes still pending when the submission timeout is reached are left unsent.

`LATE SYLLABLES` counts groups whose first code was submitted more than four software ticks after its cue; this is a diagnostic, not a measurement of audible latency.

After the music ends, pending speech gets up to four nominal seconds to finish submitting.

A card that remains unready therefore produces a timeout rather than an infinite wait. An absent card cannot reliably be detected from an unconnected input port.

A final short drain delay follows successful submission; the program cannot confirm acoustic completion from the ready bit alone.

If you interrupt playback, mute the SID with:

```text
OUT 212,24:OUT 213,0
```

### Generating the BASIC Program

To generate the BASIC program, run the following from the repository root:

```bash
python3 Programs/Singing/generate.py --format basic
```

The standard-library-only generator reads `Programs/MIDI/DaisyBell/DaisyBell.mid` directly and extracts its first 30 quarter-note beats, excluding the next phrase. It expects the existing constant 120 BPM arrangement and three monophonic MIDI channels.

Channels map consistently to SID voices: melody, bass, accompaniment. Note events are rounded to the nearest 25 ms table tick (at most 12.5 ms error).

The final event releases all three voices. Omitting `--format basic` also generates BASIC; it is the default output format. Input and template paths resolve relative to the script, so generation is independent of the current working directory.

Regeneration resets manual edits to `daisy-line-1.bas` so persistent player edits, including line 40, should be made in `player.bas.template`.

Syllable cues should be edited in `generate.py`.

Template lines must be numbered in ascending order within 1–999; the generator appends the counts and playback `DATA` from line 1000 onwards.

### Running the Program

Load `daisy-line-1.bas` into BASIC. If using Serial Sender from the repository root, use:

```bash
SerialSender --send Programs/Singing/daisy-line-1.bas
```

Once the program has been transferred, enter `RUN`. The program plays the MIDI's two-bar introduction, then speaks the first chorus line over its melody, bass and waltz accompaniment. The intended musical length is 15 seconds at 120 BPM. This is rhythmically cued speech, not pitched singing.

---

## Z80 Assembly Version

The assembly player uses the same MIDI excerpt and `CUES` as the BASIC version. It replaces interpreted playback with precomputed SID register writes and a small Z80 scheduler.

It polls the speech card approximately every 5 ms at the default clock and delay settings, always servicing due music first. The music events still come from the shared 25 ms quantisation grid; faster polling does not restore timing detail discarded during that conversion.

Busy speech never blocks music; late allophones stay in order.

The final music event releases the SID voices, pending speech has a bounded timeout, and normal completion allows a nominal one-second speech tail after both streams have been submitted.

### Generating and Building the Assembly Program

To generate and assemble the Assembly program, run the following from the repository root:

```bash
python3 Programs/Singing/generate.py --format asm --assemble
```

To generate the Assembly program without assembling it, run the following from the repository root:

```bash
python3 Programs/Singing/generate.py --format asm
```

The build uses the standalone **z80asm** also used by the repository's [MachineCode example](../MachineCode/README.md), not z88dk's similarly named tool. On macOS, install it with `brew install z80asm` if necessary. An alternative executable path can be supplied with `--assembler /path/to/z80asm`.

Make persistent assembly changes in `player.asm.template` and rebuild with `--format asm --assemble`. That command produces `.asm`, `.bin` and `.hex` files; source-only generation does **not** refresh an existing binary or HEX file. Generated files are overwritten. ASM generation leaves the BASIC files unchanged, and vice versa; timing and volume settings in the two templates are independent.

### Running the Program

1. Boot the RC2014 into **SCM**
2. Wait for the `*` prompt
3. Send `daisy-line-1.hex` as plain text
4. If using the repository's Serial Sender from the repository root, use:

    ```bash
    SerialSender --send Programs/Singing/daisy-line-1.hex --sendreset false
    ```

5. SCM recognises the leading colon of Intel HEX records and loads their addressed bytes silently; the record text is not normally echoed
6. Let the complete file, including its final `:00000001FF` record, finish
7. Wait for `Ready` and the monitor prompt
8. Enter `M E000` to inspect the start of the image
9. Before its first run the first seven bytes should be `C3 07 E0 FF 00 00 00`
10. Press **Escape** to leave the memory display and return to the `*` prompt.
11. Enter:

    ```text
    G E000
    ```

12. The tune starts with the two-bar introduction

The player mutes the SID and returns to the monitor when finished. Enter `G E000` again to replay. After it returns, enter `M E000` and inspect the header bytes (then press **Escape** to return to the prompt):

| Address     | Meaning                                                               |
| ----------- | --------------------------------------------------------------------- |
| `E003`      | Result: `00` completed, `01` speech timeout, `FF` running/not yet run |
| `E004`      | Number of syllables whose first code was submitted over 20 software ticks late (nominally 100 ms)   |
| `E005–E006` | Final software tick, low byte first; nominally 5 ms per tick          |

The player records these results in RAM rather than printing through a firmware API. At the default settings, normal completion is usually tick 3200 (`80 0C` in memory): the 15-second score plus a nominal one-second tail. Pending speech times out at tick 3800 (`D8 0E`), nominally 19 seconds from the start. If speech finishes submitting after the music, the tail starts later. Result `00` confirms submission, not measured acoustic completion.

**Do not send the generated `.asm` file to SCM's `A` command.** It uses labels, `ORG`, `EQU`, `DB` and `DW` directives for the host cross-assembler. Send the Intel HEX image instead. A raw `.bin` also cannot be transferred as terminal text.

The player loads at **E000** (decimal 57344) and the current build occupies **E000–E528** (1,321 bytes), including all tables and private state. Its first seven bytes contain a jump to the playback code, followed by the result, late-syllable count and tick counter. Recheck the binary size after changing the code or tables; the stated end address describes this build.

The Python generator checks that:

- The image remains below **FC00**, to confine the code to the upper limit of available RAM
- The opening instruction is still JP E007

The opening-jump check compares only the first three bytes against `C3 07 E0` (`JP E007`); it does not validate every header field or independently prove the assembly origin. A normal origin or header-size change alters that jump and is rejected. Both checks run when using `--assemble`, before replacing the final `.bin` and `.hex` files. Instructions on relocating the program are given below.

No BASIC memory is reserved by this monitor-loading procedure so it should not be transplanted into a running BASIC session without a matching RAM reservation and a loader for that BASIC ROM's `USR` convention.

This repository's [MachineCode example](../MachineCode/README.md) explains why those conventions are firmware-specific.

### Constraining the Program to Available Memory

The upper limit of available RAM can be confirmed by entering the following at the SCM `*` prompt, to determine the highest currently free RAM address:

```text
API $28
```

In the case of the current development machine, the results look like this:

```text
28 FBFF
```

The confirmed physical setup uses SCM v1.0 configuration R4 and reports `FBFF`. The generator's limit is **exclusive**, so it must be one byte beyond that inclusive top address: `FBFF + 1 = FC00`. Check the value for the target firmware and update the constant accordingly:

```python
ASM_RAM_END = 0xFC00  # SCM reserves RAM from FC00 upwards.
```

This API reports the monitor's free-memory ceiling; it is not an allocation or a check that the whole E000 region is unused. Confirm that the image does not overlap another program, live BASIC data or the caller's stack.

### Relocating the Program

For example, to load the program at D000 instead of E000:

| Location              | Required change for D000                                                                            |
| --------------------- | --------------------------------------------------------------------------------------------------- |
| `player.asm.template` | Change `PLAYER_ORIGIN` from `0E000h` to `0D000h`.                                                   |
| `generate.py`         | Change `ASM_ORIGIN` from `0xE000` to `0xD000`, so the HEX file loads the bytes at the new address.  |
| Build validation      | Change the expected opening jump from `JP E007` to `JP D007`: bytes `C3 07 D0`.                     |
| Loading instructions  | Use `G D000` to run and `M D000` to inspect the header.                                             |
| Diagnostic addresses  | Result becomes **D003**, late count **D004**, and tick count **D005–D006**.                         |
| Tests                 | Update hardcoded addresses and any test memory or stack locations that conflict with the new image. |

After changing the origin, regenerate **and reassemble**; labels and absolute references inside the assembly are then recalculated automatically. Changing only the Intel HEX load addresses would move the bytes without fixing those references. For a move to D000, also relocate the C harness's synthetic stack at D000 so it does not overlap the player. Update address-related comments and error messages alongside the executable checks.

### Timing Controls

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

Additional assembly settings are `LATE_TICKS=20` (lateness threshold), `DRAIN_TICKS=200` (tail delay), and `TIMEOUT_TICK=3800` (absolute submission deadline). All use the nominal 5 ms software tick. Keep the timeout beyond the final music cue if extending the excerpt.

The delay loop costs `26 * DELAY_LOOPS + 32` Z80 T-states (processor clock cycles) including its call and return: 36,848 cycles at the default value, approximately 4.998 ms at 7.3728 MHz. Scheduler work, interrupts and wait states add time. Changing the CPU clock or `DELAY_LOOPS` scales the cue times, lateness threshold, tail and timeout; the separate SID clock determines musical pitch.

BASIC's `TA`, `DL` and `SO` settings do not apply to assembly playback. Change the shared `CUES` for speech alignment, or the assembly delay for overall pace. Assembly does not speed up the MG005's pronunciation; dense passages may still need cue or pronunciation changes.

The routine saves and restores AF, BC, DE, HL, IX and IY, leaves the alternate register set untouched, and does not change the interrupt-enable/mode state. It does **not** poll Ctrl-C. Let it finish or use hardware reset if necessary. If the SID remains audible after reset, mute it at the SCM prompt with:

```text
O D4 18
O D5 00
```

SCM values here are hexadecimal: `18` selects SID register 24.

### Testing

The test suite covers both generators, MIDI parsing, assembly builds, Intel HEX output and execution of the assembled Z80 player. Run all commands below from the **repository root**.

#### Available Tests

| Test group                                        | Location                             | Requirements                                             | Coverage                                                                                                                                                                                                                                                                     |
| ------------------------------------------------- | ------------------------------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MIDI and BASIC generator: 7 tests                 | `test_generate.py`                   | Python standard library                                  | Excerpt boundaries, template changes, generation from another working directory, running-status MIDI, zero-velocity note releases, malformed MIDI, variable-length quantities, rejection of polyphonic input, and preservation of existing output when a template is invalid |
| Assembly generation: 4 tests                      | `test_asm.py`                        | Python standard library                                  | SID gate transitions, speech group flags and tick conversion, template insertion markers, and Intel HEX checksums, addresses and round-trip decoding                                                                                                                         |
| Assembly build: 1 test                            | `test_asm.py`                        | Python and standalone `z80asm` on `PATH`                 | Successful assembly, expected entry jump, image size limit, EOF record, and rejection of a changed origin without replacing the existing binary                                                                                                                              |
| Z80 execution: 1 test with three speech scenarios | `test_asm.py`, using `test_player.c` | Python, `z80asm`, `cc`, and the emulator's libz80 source | Actual instruction execution with immediately ready, 120 ms busy and permanently busy speech-card models                                                                                                                                                                     |

The Z80 execution test checks SID register writes, allophone order, cues not being sent early, overall duration, completion/timeout status and final muting. Its C harness also checks stack balance, register and interrupt-state preservation, and that memory writes stay inside the player and stack regions. The Python test compiles and invokes the harness automatically; there is no separate manual C build step.

#### Running All the Tests

To run all the available tests:

```bash
python3 -B -m unittest discover -s Programs/Singing -p 'test_*.py' -v
```

There are currently **13 tests**. Without additional tools, the 11 Python-only tests run.

The build test runs when `z80asm` is installed; the execution test also needs `cc` and `SINGING_Z80_SOURCE`. Missing optional prerequisites produce explicit `skipped` results. `OK (skipped=...)` therefore does not mean the machine-code execution checks ran.

To enable all 13 tests, point `SINGING_Z80_SOURCE` at the `libz80` directory in an [EtchedPixels EmulatorKit](https://github.com/EtchedPixels/EmulatorKit) source checkout. This contains Gabriel Gambetta's Z80 CPU core (`z80.c`, `z80.h` and the `codegen` folder). The tests compile that core directly; a built emulator application is not required:

```bash
SINGING_Z80_SOURCE=/path/to/Emulator/source/libz80 \
  python3 -B -m unittest discover -s Programs/Singing -p 'test_*.py' -v
```

An incorrect `SINGING_Z80_SOURCE` path or a compiler/assembler failure is a test failure, not a skip. The execution assertions assume the supplied origin, triangle waveform, cue data and timing settings; deliberate changes to these may require matching test updates.

The automated tests use temporary build/output directories and do not send anything to the physical RC2014 or overwrite the working playback files.

#### Run a Subset of Tests

For just the MIDI and BASIC generator tests:

```bash
python3 -B -m unittest discover -s Programs/Singing -p 'test_generate.py' -v
```

For just assembly generation, build and execution tests:

```bash
SINGING_Z80_SOURCE=/path/to/Emulator/source/libz80 \
  python3 -B -m unittest discover -s Programs/Singing -p 'test_asm.py' -v
```

The same optional-tool skip rules apply when running a subset.

#### Python Style Checks

With Ruff installed, check formatting, imports, lint rules and type annotations without modifying the files:

```bash
ruff check --select E,F,I,ANN Programs/Singing/generate.py Programs/Singing/test_generate.py Programs/Singing/test_asm.py
ruff format --check Programs/Singing/generate.py Programs/Singing/test_generate.py Programs/Singing/test_asm.py
```

Ruff is a development tool, not a runtime dependency of the generator.

#### What the Tests Do Not Establish

The CPU harness does not boot SCM, synthesise audio or reproduce the physical
SP0256's buffering and allophone durations. Separately verify HEX loading,
playback, return to the monitor, result bytes and repeat playback through SCM.
Listen on the real cards to assess pronunciation, alignment and volume after
changing cues or settings.

Both versions have been played successfully on the physical RC2014, with the
assembly version reported to sound better. The original CPU-harness run took
approximately 16.18 seconds including the tail, and completed with no late
syllables under its uniform 120 ms speech-busy model. That is an emulator result
for the supplied settings, not a guarantee of identical physical-card timing.
