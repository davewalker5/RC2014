# Maple Leaf Rag

An RC2014 SID-Ulator arrangement of Scott Joplin's *Maple Leaf Rag* (1899).

## Files

| Filename           | Description                                                                                                                   |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `MapleLeafRag.mid` | Original MIDI source downloaded from [NotaGen](https://www.notagen.ai/)                                                       |
| `MapleLeafRag.bas` | RC2014 BASIC arrangement generated from the MIDI file using this repository's [MIDI Converter](../../MIDIConverter/README.md) |

The converter reads the MIDI notes and timing, quantises the music, reduces its polyphony to the SID's three voices, converts each selected pitch into a SID frequency word, and writes a self-contained Microsoft BASIC player followed by the music as `DATA` statements.

The checked-in conversion uses the settings recorded at the top of the BASIC file:

- Four steps per quarter note
- Nominal 1 MHz SID clock
- Triangle waveforms
- Master volume 10

The conversion can be regenerated from the repository root with:

```sh
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MapleLeafRag/MapleLeafRag.mid \
  --output Programs/MapleLeafRag/MapleLeafRag.bas \
  --overwrite true
```

The generated program requires an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `MapleLeafRag.bas`, then enter:

```text
RUN
```

## Source and Attribution

### *Maple Leaf Rag*

**Composer:** Scott Joplin
**Published:** 1899
**MIDI source:** [NotaGen](https://www.notagen.ai/)
**Source page:** [Maple Leaf Rag — NotaGen](https://www.notagen.ai/sheet-music/maple-leaf-rag)
**Status:** Public domain / freely usable as stated by NotaGen

The source MIDI file was downloaded from NotaGen's *Maple Leaf Rag* page.

Scott Joplin's *Maple Leaf Rag*, first published in 1899, is in the public domain. NotaGen describes its sheet-music library as consisting of public-domain works and states that the arrangements on the site may be freely printed, copied, performed and used for teaching.

NotaGen specifically describes its *Maple Leaf Rag* score as having been converted from a public-domain MIDI source and provides that score for free download in MIDI format.

The MIDI file is retained in this repository as the source material required to reproduce the RC2014 BASIC conversion.

Although attribution is not required for public-domain material, acknowledgement is included here to document the provenance of the source and to credit NotaGen for making the MIDI file available.

## References

- [NotaGen](https://www.notagen.ai/)
- [NotaGen — Free Sheet Music](https://www.notagen.ai/sheet-music)
- [NotaGen — Maple Leaf Rag](https://www.notagen.ai/sheet-music/maple-leaf-rag)
