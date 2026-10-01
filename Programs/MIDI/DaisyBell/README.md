# Daisy Bell

An original three-voice MIDI arrangement of the familiar chorus of **Daisy Bell (Bicycle Built for Two)**, composed by **Harry Dacre** and published in **1892**. This is an original arrangement created for the RC2014 project on 24th September 2026.

> [!NOTE]
> “Original arrangement” refers to the newly created accompaniment, voicing, introduction, ending, and MIDI programming. The historic melody is Dacre's work; no claim of authorship or new ownership is made over the underlying song. The MIDI was generated specifically for this project, not downloaded from an existing MIDI collection or copied from a modern recording or arrangement.

## Files

| File                      | Description                                                                                                            |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `DaisyBell.mid`           | Three-voice MIDI arrangement with a two-bar introduction, chorus melody, waltz accompaniment and closing chord         |
| `DaisyBellSimplified.mid` | Simplified MIDI arrangement preserving the introduction, followed by the sung melody alone for easier BASIC conversion |
| `DaisyBell.bas`           | RC2014 BASIC arrangement generated from the MIDI file using the MIDI Converter                                         |
| `DaisyBellSimplified.bas` | RC2014 BASIC arrangement generated from the simplified MIDI file using the MIDI Converter                              |
| `generate_midi.py`        | Generates the original three-voice MIDI arrangement                                                                    |
| `generate_midi_simple.py` | Generates the simplified MIDI arrangement with the original introduction and unaccompanied chorus melody               |

To regenerate the MIDI files from the repository root:

```bash
python3 Programs/MIDI/DaisyBell/generate_midi.py
python3 Programs/MIDI/DaisyBell/generate_midi_simple.py
```

The conversion can then be regenerated from the repository root with:

```bash
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MIDI/DaisyBell/DaisyBell.mid \
  --output Programs/MIDI/DaisyBell/DaisyBell.bas \
  --overwrite true

dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MIDI/DaisyBell/DaisyBellSimplified.mid \
  --output Programs/MIDI/DaisyBell/DaisyBellSimplified.bas \
  --overwrite true
```

The generated programs require an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `DaisyBell.bas` or `DaisyBellSimplified.bas`, then enter:

```text
RUN
```

## Arrangement

The chorus pitches and rhythms follow the vocal line on printed page 5 of the
[1892 sheet music](https://www.sheetmusicsinger.com/wp-content/uploads/2022/08/Daisy-Bell.pdf),
transposed from G major to C major. Tied notes are combined, written rests are
preserved, and the small ornamental turn on “marriage” is omitted.

- C major, 3/4 time, 120 quarter notes per minute
- Two-bar introduction, one 32-bar chorus, and a two-bar closing tonic
- 36 bars / 54 seconds, including the final release
- Melody, sustained bass, and a single-note offbeat waltz accompaniment
- At most three simultaneous notes, intended to suit the SID-Ulator's three voices
- General MIDI acoustic grand piano on channels 1–3; no percussion or sound samples

This is a short instrumental chorus arrangement, not the complete song with verses. The three lines have separate tracks and channels so they can be edited or assigned to different instruments. A MIDI synthesizer supplies the playback sound.

The simplified version keeps the same two-bar introduction, then plays only
the chorus melody, with no closing chord. It spans 34 bars / 51 seconds,
including a final one-second rest; the MIDI Converter omits that trailing rest,
so its BASIC playback lasts 50 seconds before interpreter overhead.

## Attribution and licensing

**Underlying composition:** Harry Dacre, *Daisy Bell*, 1892. Dacre died in 1922. The original composition is in the public domain in the UK and US.

**New material:** The MIDI arrangement, generator, and this README are included under the repository's [MIT licence](../../../LICENSE), to the extent that copyright subsists in these contributions. This explicitly includes the MIDI asset; it does not impose new restrictions on the public-domain composition.

Historical score reference: [University of Wisconsin–Madison Libraries, 1892 edition](https://digital.library.wisc.edu/1711.dl/N22C7MP6ACVCM8H). The historical reference documents the song's provenance; this MIDI does not reproduce the printed piano accompaniment.

Copyright-term references: [UK guidance](https://www.gov.uk/copyright/how-long-copyright-lasts) and [US Copyright Office Circular 15A](https://www.copyright.gov/circs/circ15a.pdf).
