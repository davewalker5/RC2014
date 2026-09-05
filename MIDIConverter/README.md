# MIDI Converter

MIDI Converter turns a Standard MIDI File into a self-contained Microsoft BASIC program for the RC2014 SID-Ulator sound module. Conversion takes place on a modern computer; the generated `.bas` file contains a three-voice player and its music in `DATA` statements.

The converter targets .NET 10 and runs on Windows, macOS and Linux.

## Capabilities and Limitations

The current converter supports:

- Standard MIDI File formats 0 and 1
- Pulses-per-quarter-note timing and MIDI tempo changes
- Note-on, note-off, running status and note-on velocity zero
- Configurable quantisation from 1 to 32 steps per quarter note
- Deterministic reduction to the SID's three voices
- Triangle, sawtooth or pulse output
- Configurable SID clock, master volume, pulse width and BASIC timing
- Safe output replacement and a conversion summary

MIDI format 2 and SMPTE timing are rejected. Percussion, program changes, pitch bend, sustain, expression and other controllers are not synthesised. Percussion and controller events are counted in the conversion summary. When more than three pitched notes overlap, the converter retains stable assigned voices and favours melody, bass and the strongest inner note for available voices.

The result is an SID arrangement rather than a General MIDI reproduction. Dense piano and orchestral files will lose notes and instrument detail.

## Converting a File

From the application output directory:

```sh
./MIDIConverter --convert /path/to/music.mid
```

The default output is `/path/to/music.bas`. Select another output path with:

```sh
./MIDIConverter --convert /path/to/music.mid --output /path/to/result.bas
```

An existing output file is protected by default. Replace it explicitly with:

```sh
./MIDIConverter --convert music.mid --overwrite true
```

## Options

| Setting                     | Long option       | Short option |                 Default |
| --------------------------- | ----------------- | ------------ | ----------------------: |
| Input MIDI file             | `--convert`       | `-c`         |                Required |
| Output BASIC file           | `--output`        | `-o`         | Source name with `.bas` |
| Steps per quarter note      | `--steps`         | `-q`         |                       4 |
| Tempo override in BPM       | `--tempo`         | `-t`         |          MIDI tempo map |
| SID clock in hertz          | `--sidclock`      | `-sc`        |                 1000000 |
| Master volume               | `--volume`        | `-v`         |                      10 |
| Waveform                    | `--waveform`      | `-w`         |                Triangle |
| Pulse width                 | `--pulsewidth`    | `-pw`        |                    2048 |
| Delay loops per millisecond | `--delayfactor`   | `-df`        |                       1 |
| First BASIC line number     | `--startline`     | `-sl`        |                      10 |
| BASIC line increment        | `--lineincrement` | `-li`        |                      10 |
| Replace existing output     | `--overwrite`     | `-f`         |                   false |
| Detailed output             | `--verbose`       | `-d`         |                   false |

Long and short option names and waveform values are case-insensitive. Boolean options require an explicit `true` or `false` value.

Defaults are stored under `ApplicationSettings` in `appsettings.json`. Command-line values override those defaults for one run.

## Timing Calibration

Pitch comes from the SID clock setting and is independent of BASIC timing. Note duration uses a BASIC delay loop, so playback speed depends on the RC2014 CPU and BASIC interpreter.

Start with `DelayLoopIterationsPerMillisecond` set to 1. Convert a short file whose expected duration is known, time playback, then calculate:

```text
new delay factor = current delay factor * expected duration / measured duration
```

Round to a positive whole number and convert the file again. BASIC loop overhead means this remains an approximation, especially for music with many short notes. A machine-code or interrupt-driven player would be required for precise timing.

## Loading and Playing

The generated program expects:

- An RC2014 Mini II running Microsoft BASIC with the `OUT` statement.
- A SID-Ulator configured for register port D4 and data port D5.
- Powered speakers or headphones connected to the module.

Transfer the generated `.bas` file with the repository's SerialSender or a serial terminal, then enter `RUN` in BASIC.

If playback is interrupted and a note remains sounding, enter:

```basic
OUT 212,24 : OUT 213,0
```

## Output Format

Every generated program begins with a data-format version comment. Version 1 uses one record per playback state:

```basic
REM DURATION,FREQUENCY1,FREQUENCY2,FREQUENCY3,ACTIVE MASK,RETRIGGER MASK
DATA 500,4389,5530,6577,7,7
```

Duration is in milliseconds before BASIC delay calibration. Frequencies are precalculated SID words. The active mask selects voices and the retrigger mask distinguishes a repeated note from a continued one. A zero-duration record ends the music.

## BASIC Player Template

The fixed player is stored in `MIDIConverter.Logic/Templates/SIDPlayer.bas.template` and is copied to the `Templates` directory when the application is built or published. `BasicProgramGenerator` reads it at conversion time before appending the generated music data.

Template values use double-braced tokens such as `{{MASTER_VOLUME}}`. Branch and subroutine destinations use `@NAME@`, while the target statement is marked with a `[[NAME]]` prefix. The generator removes the prefix and replaces references with the correct generated line number. Template lines must therefore remain unnumbered; blank lines are ignored.

## Exit Codes

- `0`: the BASIC file was generated successfully
- `1`: command-line, configuration, input, conversion or output failure
- `2`: conversion was cancelled with Ctrl+C

Expected errors are printed without a stack trace
