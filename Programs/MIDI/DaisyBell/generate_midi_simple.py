"""Generate DaisyBellSimplified.mid for conversion to RC2014 BASIC.

Keep the original two-bar introduction, then play the sung chorus alone.
Full-length melody notes avoid extra release events between syllables; the
converter already retriggers repeated pitches. There are at most two notes
sounding in the introduction and one throughout the chorus (three-voice safe).

Notes and MIDI generation functions are imported from generate_midi.py.
"""

from pathlib import Path
import struct

from generate_midi import BPM, HARMONY, PHRASES, PPQN, meta, pitch, track


def generate():
    parts = [[] for _ in range(3)]
    note_count = 0

    def note(part, start, duration, name, velocity):
        nonlocal note_count
        number = pitch(name)
        on = round(start * PPQN)
        off = round((start + duration) * PPQN)
        # Release before attacking at the same tick, including repeated notes.
        parts[part].extend([
            (on, 2, bytes([0x90 + part, number, velocity])),
            (off, 1, bytes([0x80 + part, number, 0])),
        ])
        note_count += 1

    # Preserve the original introduction's pitches, timing and velocities.
    for bar, chord in enumerate(['C', 'G7']):
        root, third, fifth = HARMONY[chord]
        note(1, bar * 3, 2.75, root, 62)
        note(2, bar * 3 + 1, 0.75, third, 49)
        note(2, bar * 3 + 2, 0.75, fifth, 45)

    # The same four vocal phrases, without the continuing waltz accompaniment
    # or additional closing chord. The last sung tonic supplies the ending.
    position = 6
    for phrase in PHRASES:
        phrase_start = position
        for token in phrase.split():
            name, beats = token.split(':')
            duration = float(beats)
            if name != 'R':
                note(0, position, duration, name, 88)
            position += duration
        assert position - phrase_start == 24
    assert position == 102

    end = round(position * PPQN)
    conductor = [
        (0, 0, meta(3, b'Daisy Bell - simple RC2014 melody')),
        (0, 0, meta(1, b'Harry Dacre (1892); public-domain composition. '
                       b'Simple RC2014 arrangement; MIT.')),
        (0, 0, meta(0x51, (60_000_000 // BPM).to_bytes(3, 'big'))),
        (0, 0, meta(0x58, bytes([3, 2, 24, 8]))),
        (0, 0, meta(0x59, bytes([0, 0]))),
        (0, 0, meta(6, b'Introduction')),
        (6 * PPQN, 0, meta(6, b'Sung chorus')),
    ]
    chunks = [track(conductor, end)]
    for channel, name in enumerate(['Melody', 'Intro bass', 'Intro waltz']):
        setup = [
            (0, 0, meta(3, name.encode())),
            (0, 0, bytes([0xC0 + channel, 0])),
        ]
        chunks.append(track(setup + parts[channel], end))

    output = Path(__file__).with_name('DaisyBellSimplified.mid')
    output.write_bytes(
        b'MThd' + struct.pack('>IHHH', 6, 1, len(chunks), PPQN)
        + b''.join(chunks)
    )
    print(f'{output.name}: {note_count} notes, {position / 3:g} bars, '
          f'{position * 60 / BPM:g} seconds, maximum 2 simultaneous voices')


if __name__ == '__main__':
    generate()
