# Daisy Bell: Speech and SID Prototype

## Hardware

The program requires:

- An RC2014 computer running BASIC
- An RC2014 SID-Ulator sound module configured for **D4/D5** (hexadecimal)
- Headphones or powered speakers connected to the module's audio jack
- An MG005 speech synthesiser
- A serial terminal for loading programs and displaying messages

## Program Files

| File               | Description                                                       |
| ------------------ | ----------------------------------------------------------------- |
| `daisy-line-1.bas` | The Daisy Bell singing prototype BASIC program                    |
| `generate.py`      | Generator to build the Daisy Bell singing prototype BASIC program |

## Running the Program

Load `daisy-line-1.bas` into BASIC and enter `RUN`.

The program plays the MIDI's two-bar introduction, then speaks the first chorus line over its melody, bass and waltz accompaniment. The intended musical length is 15 seconds at 120 BPM. This is rhythmically cued speech, not pitched singing.

## Timing and Tuning

The program uses an **approximate software tick**, not a real clock. It preloads all data, updates due SID events, and attempts one eligible allophone per pass. A busy speech card never traps the player in a waiting loop. SID and speech cues share the same counter, so neither has an independent delay chain. BASIC processing still adds variable overhead, especially at note changes: 25 ms is the event-table unit, not a guaranteed real-time interval.

The values on line 40 can be adjusted to adjust the playback:

- `TA` is how many table ticks to advance per pass (default 1.25) - increasing it speeds up playback, decrease it slows it down
- Larger values of `TA` reduce speech polling opportunities and so reduce cue precision
- `DL` is the extra delay-loop count per pass with an increase adding additional slowing
- `SO` shifts every speech cue in nominal 25 ms units with negative values advancing speech and positive values delaying it
- `DL` should be non-negative and `TA` positive

The generator's `CUES` table contains individual syllable timings and codes. Times are relative to the chorus, after the three-second introduction:

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

If speech falls behind, codes remain in order and are sent when possible. The music does not wait.

`LATE SYLLABLES` counts groups whose first code was submitted more than four software ticks after its cue; this is a diagnostic, not a measurement of audible latency.

After the music ends, pending speech gets up to four nominal seconds to finish submitting.

A card that remains unready therefore produces a timeout rather than an infinite wait. An absent card cannot reliably be detected from an unconnected input port.

A final short drain delay follows successful submission; the program cannot confirm acoustic completion from the ready bit alone.

If you interrupt playback, mute the SID with:

```text
OUT 212,24:OUT 213,0
```

## Regeneration

From the repository root:

```sh
python3 Programs/Singing/generate.py
```

The standard-library-only generator reads `Programs/MIDI/DaisyBell/DaisyBell.mid` directly and extracts its first 30 quarter-note beats, excluding the next phrase. It expects the existing constant 120 BPM arrangement and three monophonic MIDI channels.

Channels map consistently to SID voices: melody, bass, accompaniment. Note events are rounded to the nearest 25 ms table tick (at most 12.5 ms error).

The final event releases all three voices.

Regeneration resets manual edits to `daisy-line-1.bas` so persistent player edits, including line 40, should be made in `player.bas.template`.

Syllable cues should be edited in in `generate.py`. 

Template lines must be numbered in ascending order within 1–999; the generator appends the counts and playback `DATA` from line 1000 onwards.

## Generator Tests

The generator uses only the Python standard library. Run its regression checks from the repository root:

```sh
python3 -B -m unittest discover -s Programs/Singing -p 'test_*.py' -v
```

The checks cover excerpt boundaries, running-status MIDI, malformed input, polyphonic input, template edits, output preservation on template errors, and launching from another directory.