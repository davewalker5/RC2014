# Moonlight Sonata

An RC2014 SID-Ulator arrangement of the first movement of Ludwig van Beethoven's *Piano Sonata No. 14 in C-sharp minor, Op. 27 No. 2* — commonly known as the *Moonlight Sonata* (1801).

## Files

| Filename              | Description                                                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `MoonlightSonata.mid` | Original MIDI source downloaded from [NotaGen](https://www.notagen.ai/)                                                       |
| `MoonlightSonata.bas` | RC2014 BASIC arrangement generated from the MIDI file using this repository's [MIDI Converter](../../MIDIConverter/README.md) |

The converter reads the MIDI notes and timing, quantises the music, reduces its polyphony to the SID's three voices, converts each selected pitch into a SID frequency word, and writes a self-contained Microsoft BASIC player followed by the music as `DATA` statements.

The checked-in conversion uses the settings recorded at the top of the BASIC file:

- Four steps per quarter note;
- Nominal 1 MHz SID clock;
- Triangle waveforms;
- Master volume 10.

The conversion can be regenerated from the repository root with:

```sh
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MoonlightSonata/MoonlightSonata.mid \
  --output Programs/MoonlightSonata/MoonlightSonata.bas \
  --overwrite true
```

The generated program requires an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `MoonlightSonata.bas`, then enter:

```text
RUN
```

## Source and Attribution

### *Moonlight Sonata*

**Composer:** Ludwig van Beethoven
**Work:** Piano Sonata No. 14 in C-sharp minor, Op. 27 No. 2
**Movement:** I — *Adagio sostenuto*
**Composed:** 1801
**MIDI source:** [NotaGen](https://www.notagen.ai/)
**Source page:** [Moonlight Sonata — NotaGen](https://www.notagen.ai/sheet-music/moonlight-sonata)
**Status:** Public domain / freely usable as stated by NotaGen

The source MIDI file was downloaded from NotaGen's *Moonlight Sonata* page.

Beethoven's Piano Sonata No. 14, Op. 27 No. 2 was composed in 1801 and is in the public domain. The NotaGen download represents the famous first movement, *Adagio sostenuto*, commonly referred to as the *Moonlight Sonata*.

NotaGen states that this score was converted from a public-domain MIDI source. Its sheet-music library consists of public-domain works and provides downloadable MIDI and PDF versions without charge.

The source MIDI represents the complete 69-bar first movement. NotaGen describes it as a clean reading score containing the notes, rhythms, key and time signature, while omitting some interpretive markings such as dynamics, pedalling, phrasing slurs and fingering.

The MIDI file is retained in this repository as the source material required to reproduce the RC2014 BASIC conversion.

Although attribution is not required for public-domain material, acknowledgement is included here to document the provenance of the source and to credit NotaGen for making the MIDI file available.

## References

- [NotaGen](https://www.notagen.ai/)
- [NotaGen — Free Sheet Music](https://www.notagen.ai/sheet-music)
- [NotaGen — Moonlight Sonata](https://www.notagen.ai/sheet-music/moonlight-sonata)
