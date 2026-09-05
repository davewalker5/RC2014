# Pineapple Rag

An RC2014 SID-Ulator arrangement of Scott Joplin's *Pineapple Rag* (1908).

## Files

| Filename           | Description                                                                                                                           |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `PineappleRag.mid` | Original MIDI source downloaded from the [Mutopia Project](https://www.mutopiaproject.org/)                                           |
| `PineappleRag.bas` | RC2014 BASIC arrangement generated from the MIDI file using this repository's [MIDI Converter](../../MIDIConverter/README.md) |

The converter reads the MIDI notes and timing, quantises the music, reduces its polyphony to the SID's three voices, converts each selected pitch into a SID frequency word, and writes a self-contained Microsoft BASIC player followed by the music as `DATA` statements.

The checked-in conversion uses the settings recorded at the top of the BASIC file:

- Four steps per quarter note;
- Nominal 1 MHz SID clock;
- Triangle waveforms;
- Master volume 10.

The conversion can be regenerated from the repository root with:

```sh
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/PineappleRag/PineappleRag.mid \
  --output Programs/PineappleRag/PineappleRag.bas \
  --overwrite true
```

The generated program requires an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `PineappleRag.bas`, then enter:

```text
RUN
```

## Source and Attribution

### *Pineapple Rag*

**Composer:** Scott Joplin
**Published:** 1908
**MIDI source:** [The Mutopia Project](https://www.mutopiaproject.org/)
**Mutopia reference:** 1899
**Contributor / typesetter:** Coyau
**Licence:** Public Domain

The source MIDI file was obtained from the Mutopia Project's [Jazz catalogue](https://www.mutopiaproject.org/cgibin/make-table.cgi?Style=Jazz).

The Mutopia listing identifies both the composition and the contributor's digital typesetting as public domain. The MIDI file is retained in this repository as the source material required to reproduce the RC2014 BASIC conversion.

Although attribution is not required for public-domain material, acknowledgement is included here to document the provenance of the source and to credit the Mutopia Project and its contributor.

## References

- [The Mutopia Project](https://www.mutopiaproject.org/)
- [Mutopia Jazz catalogue](https://www.mutopiaproject.org/cgibin/make-table.cgi?Style=Jazz)
