# Daisy Bell

An original three-voice MIDI arrangement of the familiar chorus of **Daisy Bell (Bicycle Built for Two)**, composed by **Harry Dacre** and published in **1892**. This is an original arrangement created for the RC2014 project on 24th September 2026.

> [!NOTE]
> “Original arrangement” refers to the newly created accompaniment, voicing, introduction, ending, and MIDI programming. The historic melody is Dacre's work; no claim of authorship or new ownership is made over the underlying song. The MIDI was generated specifically for this project, not downloaded from an existing MIDI collection or copied from a modern recording or arrangement.

## Files

| File               | Description                                                                                  |
| ------------------ | -------------------------------------------------------------------------------------------- |
| `DaisyBell.mid`    | Standard MIDI File, format 1: conductor track plus three musical tracks                      |
| `DaisyBell.bas`    | RC2014 BASIC arrangement generated from the MIDI file using this repository's MIDI Converter |
| `generate_midi.py` | Editable arrangement and deterministic MIDI generator; Python 3 standard library only        |

To regenerate the MIDI file from the repository root:

```sh
python3 Programs/MIDI/DaisyBell/generate_midi.py
```

The conversion can then be regenerated from the repository root with:

```sh
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MIDI/DaisyBell/DaisyBell.mid \
  --output Programs/MIDI/DaisyBell/DaisyBell.bas \
  --overwrite true
```

The generated program requires an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `DaisyBell.bas`, then enter:

```text
RUN
```

## Arrangement

- C major, 3/4 time, 120 quarter notes per minute
- Two-bar introduction, one 32-bar chorus, and a two-bar closing tonic
- 36 bars / 54 seconds, including the final release
- Melody, sustained bass, and a single-note offbeat waltz accompaniment
- At most three simultaneous notes, intended to suit the SID-Ulator's three voices
- General MIDI acoustic grand piano on channels 1–3; no percussion or sound samples

This is a short instrumental chorus arrangement, not the complete song with verses. The three lines have separate tracks and channels so they can be edited or assigned to different instruments. A MIDI synthesizer supplies the playback sound.

## Attribution and licensing

**Underlying composition:** Harry Dacre, *Daisy Bell*, 1892. Dacre died in 1922. The original composition is in the public domain in the UK and US.

**New material:** The MIDI arrangement, generator, and this README are included under the repository's [MIT licence](../../../LICENSE), to the extent that copyright subsists in these contributions. This explicitly includes the MIDI asset; it does not impose new restrictions on the public-domain composition.

Historical score reference: [University of Wisconsin–Madison Libraries, 1892 edition](https://digital.library.wisc.edu/1711.dl/N22C7MP6ACVCM8H). The historical reference documents the song's provenance; this MIDI does not reproduce the printed piano accompaniment.

Copyright-term references: [UK guidance](https://www.gov.uk/copyright/how-long-copyright-lasts) and [US Copyright Office Circular 15A](https://www.copyright.gov/circs/circ15a.pdf).
