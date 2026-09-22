# Greensleaves

An RC2014 SID-Ulator arrangement of *Greensleaves*, a traditional tune.

## Files

| Filename           | Description                                                                                                             |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| `Greensleaves.mid` | Original MIDI source downloaded from [The Mutopia Project](https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=109) |
| `Greensleaves.bas` | RC2014 BASIC arrangement generated from the MIDI file using this repository's MIDI Converter                            |

The converter reads the MIDI notes and timing, quantises the music, reduces its polyphony to the SID's three voices, converts each selected pitch into a SID frequency word, and writes a self-contained Microsoft BASIC player followed by the music as `DATA` statements.

The checked-in conversion uses the settings recorded at the top of the BASIC file:

- Four steps per quarter note;
- Nominal 1 MHz SID clock;
- Triangle waveforms;
- Master volume 10.

The conversion can be regenerated from the repository root with:

```sh
dotnet run --project MIDIConverter/MIDIConverter -- \
  --convert Programs/MIDI/Greensleaves/Greensleaves.mid \
  --output Programs/MIDI/Greensleaves/Greensleaves.bas \
  --overwrite true
```

The generated program requires an RC2014 Mini II running Microsoft BASIC and a SID-Ulator sound module configured for register port D4 and data port D5.

Load `Greensleaves.bas`, then enter:

```text
RUN
```

## Source and Attribution

**Work:** *Greensleaves*  
**Composer:** Traditional  
**MIDI source:** [The Mutopia Project](https://www.mutopiaproject.org/)  
**Download page:** [Greensleaves — The Mutopia Project](https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=109)  
**License:** Public Domain

The MIDI file is retained in this repository as the source material required to reproduce the RC2014 BASIC conversion. The Mutopia Project lists this edition as Public Domain; attribution is included to document its provenance.

## References

- [The Mutopia Project](https://www.mutopiaproject.org/)
- [The Mutopia Project — Greensleaves](https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=109)
