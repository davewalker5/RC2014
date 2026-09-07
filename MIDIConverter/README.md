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

Format 2 MIDI files are not supported. They may contain independent sequences or patterns that aren’t necessarily intended to play together while the reader currently combines every track’s notes and tempo changes, so doing that to a format 2 MIDI file could overlay unrelated patterns.

The current implementation supports _pulses per quarter note_ (PPQN) timing. For example, at 480 PPQN, 480 ticks represent one quarter note, whose real duration depends on the tempo, the latter translating ticks into elapsed time.

In contrast, SMPTE timing defines ticks using frames per second and ticks per frame, measuring elapsed time directly. To support it, the converter would require a separate tick-to-time calculation, correct handling of frame-rate encodings and a design decision about quantisation:

- Preserve the original timing or;
- Use a millisecond grid or;
- Derive a musical grid

This is outside the scope of the current implementation.

Percussion, program changes, pitch bend, sustain, expression and other controllers are not synthesised., though percussion and controller events are counted in the conversion summary.

When more than three pitched notes overlap, the converter retains stable assigned voices and favours melody, bass and the strongest inner note for available voices.

The result is a SID arrangement rather than a General MIDI reproduction. Dense piano and orchestral files will lose notes and instrument detail.

## Conversion Overview

The conversion pipeline in the `MIDIConverterService` has three main stages:

```csharp
var midi = await _reader.ReadAsync(input, cancellationToken).ConfigureAwait(false);
var arrangement = _arranger.Arrange(midi, settings);
var basic = _generator.Generate(Path.GetFileName(input), arrangement.Steps, settings);
```

The reader produces notes and timing information, the arranger reduces those notes to three SID voices, and the generator turns the resulting playback states into a BASIC program. All MIDI interpretation and pitch calculations happen during conversion; the RC2014 only needs to read data, update SID registers and wait.

---

## Reading the MIDI File

### MIDI File Structure

A Standard MIDI File stores timed musical instructions rather than recorded audio:

- A note-on event starts a numbered pitch on a channel, with a velocity describing the strength of the attack, roughly how hard a note is struck
- A later note-off event ends the note
- Tracks hold event sequences
- Channels identify parts within those sequences
- A track can contain more than one channel, so tracks do not correspond directly to SID voices

`MIDIFileReader.ReadAsync` loads the file into memory asynchronously, then parses its binary _chunks_. A _chunk_ is a labelled block of bytes within the file, each chunk having three parts:

| Part     | Length         | Comments                      |
| -------- | -------------- | ----------------------------- |
| Type     | 4 bytes        | Identifier for the chunk      |
| Length   | 4 bytes        | How many content bytes follow |
| Contents | `Length` bytes | Chunk contents                |

MIDI files use two main chunk types:

| Type   | Description                                                                                                         |
| ------ | ------------------------------------------------------------------------------------------------------------------- |
| `MThd` | Declares the format, track count and timing resolution                                                              |
| `MTrk` | Contains events preceded by variable-length delta times, the number of ticks since the previous event in that track |

Format 0 has one track while format 1 has multiple tracks sharing a timeline. 

A two-track file therefore looks like:

```text
[MThd | length | file information]
[MTrk | length | events for track 1]
[MTrk | length | events for track 2]
```

The reader accumulates the delta-times into absolute tick positions, counted from the start of the track.

The MIDI file structure allows the reader to check the boundaries of each chunk and its payload and reject files with truncated data or missing declared tracks. It also allows chunks with unrecognised identifiers to be skipped.

### Running Status

Running status lets consecutive channel events omit a repeated status byte: A channel event normally starts with a **status byte**, which identifies the event type and channel. For example, `90` means “note-on, channel 1”. Two data bytes then supply the note number and velocity.

For example, three note-on events could be stored as:

```text
90 3C 64    Note-on, channel 1: note 60, velocity 100
90 40 64    Note-on, channel 1: note 64, velocity 100
90 43 64    Note-on, channel 1: note 67, velocity 100
```

With **running status**, the repeated `90` bytes can be omitted:

```text
90 3C 64    Establish note-on, channel 1
   40 64    Reuse that event type and channel
   43 64    Reuse them again
```

The reader remembers the most recent channel status. A new channel status replaces it. A meta or system event clears that remembered value, so the next channel event must explicitly include its status byte again.

### Event Content Handling

The converter applies the event content handling rules outlined below, resulting in an in-memory `MIDIFileData` object containing the _combined_ time-ordered notes, tempo map and other meta-data about the source MIDI file and the conversion process.

_Combined_ in this context means the notes from all tracks gathered into one list sorted by start time.

The tempo map has the following conceptual structure:

| Tick range |   Tempo |
| ---------- | ------: |
| 0–479      | 120 BPM |
| 480 onward |  90 BPM |

Note times are still musical ticks at this stage.

#### Pitched Notes

Note-on and note-off events are paired within each track by channel and pitch and a note-on with velocity zero is also a note-off.

The reader maintains a separate queue for each channel and pitch within each track and every pitched note-on with non-zero velocity is added to the appropriate queue.

Usually, a queue contains just one note waiting for its note-off but the queue matters when the same pitch starts again before its earlier occurrence ends:

```text
Tick 0:   Note-on C4   → queue: [first C4]
Tick 100: Note-on C4   → queue: [first C4, second C4]
Tick 200: Note-off C4  → closes first C4; queue: [second C4]
Tick 300: Note-off C4  → closes second C4; queue: []
```

This produces two overlapping notes: one spanning ticks **0–200**, the other **100–300**.

A note-off identifies the channel and pitch, but doesn’t say *which occurrence* it ends. The converter resolves that ambiguity by closing the **oldest matching note first**. Notes on different pitches, channels or tracks are paired independently.

Percussion notes on MIDI channel 10 are excluded. Note-off velocity is not used.

Each resulting note retains its identity, track, channel, pitch, starting velocity and start/end ticks.

#### Incomplete Notes

- An unmatched note-off produces a warning
- A note still open at the end of a track is closed there with a warning
- Notes are given at least one tick of duration including same-tick note-on/off pairs

#### Tempo

Tempo meta events supply microseconds per quarter note and are sorted using three successive rules:

1. **Tick** - earlier events come first
2. **Track** - if events have the same tick, the event from the earlier track comes first
3. **Source order** - if both tick and track match, events stay in the order they appeared within that track

For example:

| Tick | Track | Order within track |   Tempo |
| ---: | ----: | -----------------: | ------: |
|    0 |     1 |                  1 | 120 BPM |
|  480 |     1 |                  5 | 100 BPM |
|  480 |     1 |                  6 | 110 BPM |
|  480 |     2 |                  3 |  90 BPM |

At tick 480, the converter processes all three tempo changes in that order. **The last one wins**, so 90 BPM applies from tick 480 onward.

The track and source-order rules give the converter a consistent way to resolve tempo changes at exactly the same time.

#### Metadata

- Track-name information is collected but does not choose voices or instruments
- End-of-track stops parsing that track
- Other meta events, such as time signatures, key signatures and lyrics, are skipped

#### Performance and Instrument Controls

- Control changes, polyphonic pressure, channel pressure and pitch bend are ignored
- This includes sustain, expression and channel-volume controls
- Program changes are consumed without selecting an instrument

#### System Messages

Length-prefixed system-exclusive payloads are skipped; other system status messages are rejected.

---

## Arranging for Three SID Voices

`MIDIArranger.Arrange` quantises the timeline and uses heuristics to allocate notes to the three available SID voices, turning the combined notes into a sequence of `PlaybackStep` objects.

### Musical Grid

With `--steps 4`, each quarter note is divided into four steps, equivalent to sixteenth notes:

```text
Tick:  0       120       240       360       480
       |--------|---------|---------|---------|
       Start                            Next quarter note
```

With 480 PPQN, those grid points are 120 ticks apart, as shown. More steps create a finer grid that preserves more timing detail while fewer steps produce coarser timing. When PPQN is not evenly divisible by the step count, grid positions are rounded to whole ticks.

For example, if PPQN were 100 and the number of steps were 3: 

```text
Ideal: 0       33⅓       66⅔       100
Tick:  0       33        67        100
       |--------|---------|---------|
       Start                 Next quarter note
```

Each note's start and end are rounded independently to the nearest configured musical grid position with halfway values rounding away from zero. For example, with the first musical grid shown above, a note starting at tick 130 will move to 120 and a note ending at 350 will move to 360.

If a note's rounded end is no later than its rounded start, the end advances to the next grid position.

### Determining Interval Boundaries

The arranger sorts the quantised note start and end times, together with tick zero, to arrive at a set of _interval boundaries_ Suppose two notes have these quantised times:

```text
Note A: starts at 0,   ends at 240
Note B: starts at 120, ends at 360
```

The boundaries are **0, 120, 240, 360**, giving these intervals:

| Interval | Active notes |
| -------- | ------------ |
| 0–120    | A            |
| 120–240  | A and B      |
| 240–360  | B            |

Within each interval, no note starts or ends, so the set of active notes stays unchanged. At a boundary, notes starting there become active and notes ending there become inactive so these are _note boundaries_, rather than every point on the musical grid and grid points where nothing starts or ends don’t create an interval boundary.

Each interval therefore has a fixed set of active notes.

### Calculating Pitch

`SIDPitchConverter` converts each selected MIDI note number into an equal-tempered frequency.

MIDI note 69 is used as the reference point for converting note numbers into frequencies. It corresponds to A4, the A above middle C, and has a frequency of 440 Hz.

MIDI note numbers advance by one for each _semitone_ — one adjacent piano key, counting both white and black keys. An octave contains 12 semitones, and moving up an octave doubles the frequency.

So, if `n` is the MIDI note number then its frequency in Hz, `f` is given by:

$$
f = 440 \cdot 2^{\frac{n-69}{12}}
$$

The expression `(n - 69)` counts semitones above or below A4 and dividing by 12 expresses that distance in octaves. Raising 2 to that power gives the frequency multiplier.

| MIDI note | Musical note | Distance from A4 | Frequency |
| --------: | ------------ | ---------------- | --------: |
|        57 | A3           | One octave below |    220 Hz |
|        69 | A4           | Reference note   |    440 Hz |
|        81 | A5           | One octave above |    880 Hz |

So, for example, for note 70, just one semitone above A4, the frequency is:

$$
f = (440 \cdot 2^{1/12} \approx 466.16 Hz
$$

This is **equal temperament**: each semitone multiplies frequency by the same ratio rather than adding a fixed number of hertz.

The SID produces a frequency according to:

$$
f = \frac{W \cdot f_{\mathrm{clk}}}{2^{24}}
$$

So the converter needs the SID clock frequency to calculate the word `W` that will produce the intended note. The `--sidclock` setting specifies the clock used by the hardware uses. If that setting is wrong, playback will be sharp or flat.

The resulting frequency is converted to the SID frequency word as follows:

$$
W = round\left(\frac{f \cdot 2^{24}}{f_{\mathrm{clk}}}\right)
$$

That's then constrained as follows:

$$
1 \leq W \leq 65535\
$$

### Calculating Duration

The interval boundaries are converted from ticks to elapsed milliseconds using the tempo map and interval durations are calculated as the difference between the two boundary times, rounded to the nearest millisecond and constrained as follows:

$$
1 \leq duration
$$

The calculation adds the elapsed time in each tempo segment, including changes inside an interval where the notes remain unchanged.

The default tempo, before any tempo events, is set to 500,000 microseconds per quarter note, or 120 BPM.

`--tempo` replaces the entire tempo map with a fixed BPM.

Each calculated duration tells the player **how long to hold the current three-voice state before applying the next state**. It is the duration of an interval, rather than necessarily the duration of a complete note: a long note can continue across several intervals while other notes start or end around it.

For example, with 480 ticks per quarter note at 120 BPM, one tick represents approximately 1.042 milliseconds. Suppose note A runs from tick 0 to 480 and note B runs from tick 240 to 480. The boundaries produce two intervals:

| Interval (ticks) | Active notes | Duration |
| ---------------- | ------------ | -------: |
| 0–240            | A            |   250 ms |
| 240–480          | A and B      |   250 ms |

The player starts A and waits for the first interval. It then starts B while leaving A sounding, and waits for the second interval. At the end of the music, both voices are released. A therefore sounds across both intervals for a nominal total of 500 ms, while B sounds for 250 ms. An interval with no active notes similarly holds silence for its calculated duration.

The generator stores the duration as the first value in each playback `DATA` record. Adjacent intervals with identical voice states can be combined by adding their durations, provided no new note attack needs to be preserved. The BASIC player reads each record into `D,F1,F2,F3,A,G`, updates the three voices, then executes:

```basic
FOR T=1 TO D*DF:NEXT T
```

Here, `D` is the duration in milliseconds and `DF` is the configured number of delay-loop iterations per millisecond (`--delayfactor`). The SID continues producing the selected sounds independently while BASIC runs this loop. When the loop finishes, the player reads the next record and applies any note starts, releases or retriggers. Continuing notes keep their gates set, so they are not restarted at every interval boundary. A zero-duration record is reserved for the end-of-music marker.

A slower tempo produces longer interval durations and therefore longer waits; a faster tempo produces shorter waits. This changes the pacing of the music without changing the SID frequency words or the pitch of the notes.

These durations are target timings, not precise wall-clock guarantees. The delay loop depends on the CPU and BASIC interpreter, and reading records and writing SID registers add overhead. The delay factor therefore needs the adjustment described in [Timing Calibration](#timing-calibration). Whole-millisecond rounding also introduces small timing differences, especially with short intervals.

### Choosing and Assigning Notes

At each interval boundary, ended notes release their SID voices and continuing notes that are already assigned a voice retain it. That leaves the following cases:

- Notes starting at the boundary
- Notes that started earlier but haven’t received a voice because all three were occupied

Any free voices are filled from the remaining active notes using the pitch and velocity priorities:

1. The highest pitch, as a simple melody preference
2. The lowest pitch, as a bass preference
3. The note with the highest velocity, to retain a strong inner part
4. A newly arriving high or low note will not interrupt three continuing assigned notes
5. Ties use source timing, channel, pitch or note identity in fixed order so repeated conversions produce the same arrangement

So a previously omitted note can be selected and begin sounding partway through its duration when a voice becomes available before that note ends.

Note that these are pitch and velocity heuristics, not an analysis of musical parts, and it should be noted that velocity affects this selection process only - it does not become per-note SID volume.

After selection using these rules, a note is assigned to the first free voice. Voice 1 is therefore not permanently the melody, nor is any voice tied to a MIDI track or channel. Distinct notes of the same pitch can occupy separate voices.

### Encoding Playback States

Each step contains a duration, three frequency words and two masks. Bits with values 1, 2 and 4 represent voices 1, 2 and 3:

- The **active mask** says which voices should sound, for example 5 enables voices 1 and 3
- The **retrigger mask** says which voices have a newly assigned note and need a fresh attack
- A repeated note at the same pitch is a new note identity, so it retriggers instead of becoming a continuous tone

Adjacent steps with identical frequencies and active masks are merged by adding their durations, provided the later step has no retrigger. This reduces the number of `DATA` records without losing repeated attacks. The arrangement result includes these compressed steps, the discarded-note count, parser warnings and pitch-clamping warnings.

---

## Generating the BASIC Program

_To be completed_

---

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

## References

_To be completed_
