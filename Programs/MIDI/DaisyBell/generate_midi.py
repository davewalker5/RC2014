#!/usr/bin/env python3
"""Generate the original RC2014 three-voice Daisy Bell arrangement (MIT).

Python standard library only. Durations are quarter-note beats; C4 is middle C.
The historic chorus melody is public domain; accompaniment is newly arranged.
"""
from pathlib import Path
import struct

PPQN = 480
BPM = 120
# Four eight-bar phrases of the familiar chorus, transposed to C major.
PHRASES = [
    'G5:3 E5:3 C5:3 G4:3 A4:1 B4:1 C5:1 A4:2 C5:1 G4:6',
    'D5:3 E5:3 C5:3 A4:3 A4:1 B4:1 C5:1 D5:2 E5:1 D5:5 G4:1',
    'C5:1 C5:1 C5:1 E5:2 C5:1 D5:2 G4:1 C5:2 B4:1 '
    'A4:1 B4:1 C5:1 A4:2 G4:1 G4:3 R:2 G4:1',
    'E5:2 C5:1 D5:2 G4:1 E5:2 C5:1 D5:1 E5:1 F5:1 '
    'E5:1 C5:1 D5:1 G4:2 B4:1 C5:6',
]
# Each harmony supplies a bass root and two separate offbeat notes.
HARMONY = {
    'C': ('C3', 'E4', 'G4'), 'G': ('G2', 'D4', 'B3'),
    'F': ('F2', 'C4', 'A3'), 'Am': ('A2', 'C4', 'E4'),
    'Dm': ('D3', 'F4', 'A4'), 'G7': ('G2', 'F4', 'B3'),
}
CHORDS = (
    'C C F C F F G G '
    'G C Am F F Dm G G7 '
    'C C G7 C F F G G7 '
    'C G7 C G7 C G7 C C'
).split()


def pitch(name):
    return 12 * (int(name[-1]) + 1) + {'C': 0, 'D': 2, 'E': 4,
        'F': 5, 'G': 7, 'A': 9, 'B': 11}[name[0]]


def vlq(value):
    result = [value & 127]
    while value >> 7:
        value >>= 7
        result.insert(0, (value & 127) | 128)
    return bytes(result)


def meta(kind, payload):
    return bytes([255, kind]) + vlq(len(payload)) + payload


def track(events, end):
    data = bytearray()
    previous = 0
    for tick, priority, event in sorted(events, key=lambda e: (e[0], e[1])):
        data.extend(vlq(tick - previous))
        data.extend(event)
        previous = tick
    data.extend(vlq(end - previous) + b'\xff\x2f\x00')
    return b'MTrk' + struct.pack('>I', len(data)) + data


def generate():
    parts = [[] for _ in range(3)]
    note_count = 0

    def note(part, start, duration, name, velocity):
        nonlocal note_count
        p = pitch(name)
        on, off = round(start * PPQN), round((start + duration) * PPQN)
        parts[part].extend([(on, 2, bytes([0x90 + part, p, velocity])),
                            (off, 1, bytes([0x80 + part, p, 0]))])
        note_count += 1

    # Two-bar introduction establishes the waltz pulse.
    progression = ['C', 'G7'] + CHORDS
    for bar, chord in enumerate(progression):
        root, third, fifth = HARMONY[chord]
        note(1, bar * 3, 2.75, root, 62)
        note(2, bar * 3 + 1, 0.75, third, 49)
        note(2, bar * 3 + 2, 0.75, fifth, 45)

    position = 6
    for phrase in PHRASES:
        start = position
        for token in phrase.split():
            name, beats = token.split(':')
            duration = int(beats)
            if name != 'R':
                note(0, position, duration - 0.125, name, 88)
            position += duration
        assert position - start == 24
    assert len(CHORDS) == 32 and position == 102

    # Two-bar closing tonic, with all three voices sustained and released.
    for part, name, velocity in [(0, 'C5', 76), (1, 'C3', 58), (2, 'E4', 46)]:
        note(part, position, 5.5, name, velocity)
    end = (position + 6) * PPQN
    conductor = [
        (0, 0, meta(3, b'Daisy Bell - original RC2014 arrangement')),
        (0, 0, meta(1, b'Harry Dacre (1892); public-domain composition. '
                       b'New RC2014 arrangement, September 2026; MIT.')),
        (0, 0, meta(0x51, (60_000_000 // BPM).to_bytes(3, 'big'))),
        (0, 0, meta(0x58, bytes([3, 2, 24, 8]))),
        (0, 0, meta(0x59, bytes([0, 0]))),
        (6 * PPQN, 0, meta(6, b'Chorus')),
        (102 * PPQN, 0, meta(6, b'Closing tonic')),
    ]
    chunks = [track(conductor, end)]
    for channel, name in enumerate(['Melody', 'Bass', 'Waltz accompaniment']):
        setup = [(0, 0, meta(3, name.encode())),
                 (0, 0, bytes([0xC0 + channel, 0]))]  # GM acoustic grand piano
        chunks.append(track(setup + parts[channel], end))
    output = Path(__file__).with_name('DaisyBell.mid')
    output.write_bytes(b'MThd' + struct.pack('>IHHH', 6, 1, len(chunks), PPQN)
                       + b''.join(chunks))
    print(f'{output.name}: {note_count} notes, 36 bars, 54 seconds, 3 voices')


if __name__ == '__main__':
    generate()
