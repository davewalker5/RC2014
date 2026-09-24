"""
Build the Daisy Bell singing prototype from MIDI and a BASIC template
"""

import struct
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / "MIDI/DaisyBell/DaisyBell.mid"
TEMPLATE = HERE / "player.bas.template"
OUTPUT = HERE / "daisy-line-1.bas"
TICK_MS = 25
TEMPO_MICROSECONDS = 500_000  # 120 quarter notes per minute.
INTRO_SECONDS = 3
EXCERPT_BEATS = 30  # Two introduction bars and eight chorus bars.
SID_CLOCK_HZ = 1_000_000
VOICE_COUNT = 3
DATA_START_LINE = 1000
DATA_LINE_INCREMENT = 10

# Seconds from chorus start and the existing line-1 allophones. PA1 terminates
# independently cued syllables; the timeline replaces the sentence pauses.
CUES = (
    (0, "Dai", (33, 20, 0)),
    (1.5, "sy", (55, 19, 0)),
    (3, "Dai", (33, 20, 0)),
    (4.5, "sy", (55, 19, 0)),
    (5.9, "give", (36, 12, 35, 0)),
    (6.4, "me", (16, 20, 0)),
    (7, "your", (49, 58, 0)),
    (7.5, "an", (26, 11, 0)),
    (8.5, "swer", (55, 46, 51, 0)),
    (9, "do", (21, 31, 0)),
)

# BASIC DATA records: tick, three frequencies, active mask, retrigger mask.
MusicRecord = tuple[int, int, int, int, int, int]
SpeechRecord = tuple[int, int]
SpeechCue = tuple[float, str, tuple[int, ...]]


@dataclass(frozen=True)
class NoteEvent:
    """A note transition at an absolute MIDI tick on one SID-mapped channel."""

    tick: int
    channel: int
    pitch: int
    is_on: bool


def _read_bytes(stream: BytesIO, count: int) -> bytes:
    """
    Consume an exact byte count from a MIDI chunk.

    :param stream: MIDI stream, advanced by this operation.
    :param count: Nonnegative number of bytes to consume.
    :return: Requested bytes.
    :raises ValueError: The chunk is truncated.
    """
    payload = stream.read(count)
    if len(payload) != count:
        raise ValueError("Truncated MIDI chunk")
    return payload


def _read_variable_length(stream: BytesIO) -> int:
    """
    Consume a MIDI variable-length quantity, limited to four bytes.

    :param stream: Track stream, advanced by this operation.
    :return: Decoded nonnegative integer.
    :raises ValueError: The quantity is truncated or longer than four bytes.
    """
    value = 0
    for _ in range(4):
        byte = _read_bytes(stream, 1)[0]
        value = (value << 7) | (byte & 0x7F)
        if byte < 0x80:
            return value
    raise ValueError("MIDI variable-length quantity exceeds four bytes")


def _read_chunk(stream: BytesIO, expected_tag: bytes) -> bytes:
    """
    Consume one tagged MIDI chunk.

    :param stream: File stream, advanced past the chunk.
    :param expected_tag: Required four-byte chunk identifier.
    :return: Chunk payload without its tag and length.
    :raises ValueError: The tag is unexpected or the chunk is truncated.
    """
    if _read_bytes(stream, 4) != expected_tag:
        raise ValueError(f"Expected MIDI chunk {expected_tag!r}")
    length = int.from_bytes(_read_bytes(stream, 4), "big")
    return _read_bytes(stream, length)


def _read_track(payload: bytes) -> tuple[list[NoteEvent], list[tuple[int, int]]]:
    """
    Decode note transitions and tempo changes from one MIDI track.

    :param payload: Track bytes without their chunk header.
    :return: Note events and (absolute tick, microseconds per beat) tempo pairs.
    :raises ValueError: An event is malformed or notes use channels beyond 0-2.
    """
    stream = BytesIO(payload)
    notes: list[NoteEvent] = []
    tempos: list[tuple[int, int]] = []
    tick = 0
    running_status: int | None = None
    while stream.tell() < len(payload):
        tick += _read_variable_length(stream)
        status = _read_bytes(stream, 1)[0]
        if status < 0x80:
            if running_status is None:
                raise ValueError("MIDI data byte has no preceding channel status")
            stream.seek(-1, 1)
            status = running_status
        if status == 0xFF:
            kind = _read_bytes(stream, 1)[0]
            event_data = _read_bytes(stream, _read_variable_length(stream))
            if kind == 0x51:  # Set Tempo meta-event.
                if len(event_data) != 3:
                    raise ValueError("MIDI tempo must contain three bytes")
                tempos.append((tick, int.from_bytes(event_data, "big")))
            running_status = None
        elif status in (0xF0, 0xF7):  # Length-prefixed system-exclusive data.
            _read_bytes(stream, _read_variable_length(stream))
            running_status = None
        else:
            if not 0x80 <= status < 0xF0:
                raise ValueError(f"Unsupported MIDI status: {status:#x}")
            running_status = status
            kind, channel = status >> 4, status & 0x0F
            count = 1 if kind in (0xC, 0xD) else 2
            event_data = _read_bytes(stream, count)
            if any(byte >= 0x80 for byte in event_data):
                raise ValueError("MIDI channel data must contain seven-bit values")
            if kind in (0x8, 0x9):
                if channel >= VOICE_COUNT:
                    raise ValueError("Expected melody, bass and accompaniment only")
                is_on = kind == 0x9 and event_data[1] != 0
                notes.append(NoteEvent(tick, channel, event_data[0], is_on))
    return notes, tempos


def read_midi(path: Path) -> tuple[int, list[NoteEvent]]:
    """
    Read the prototype's format-1, constant-120-BPM MIDI arrangement.

    :param path: Source MIDI file with positive quarter-note tick resolution.
    :return: Ticks per quarter note and note transitions across all tracks.
    :raises OSError: The source cannot be read.
    :raises ValueError: MIDI data or its layout/timing is unsupported.
    """
    stream = BytesIO(path.read_bytes())
    header = _read_chunk(stream, b"MThd")
    if len(header) < 6:
        raise ValueError("MIDI header must contain at least six bytes")
    file_format, track_count, ticks_per_quarter = struct.unpack(">HHH", header[:6])
    if file_format != 1 or track_count == 0:
        raise ValueError("Expected format-1 MIDI with at least one track")
    if ticks_per_quarter == 0 or ticks_per_quarter & 0x8000:
        raise ValueError("Expected positive quarter-note MIDI tick resolution")
    notes: list[NoteEvent] = []
    tempos: list[tuple[int, int]] = []
    for _ in range(track_count):
        track_notes, track_tempos = _read_track(_read_chunk(stream, b"MTrk"))
        notes.extend(track_notes)
        tempos.extend(track_tempos)
    if tempos != [(0, TEMPO_MICROSECONDS)]:
        raise ValueError("Prototype expects one initial tempo of 120 BPM")
    return ticks_per_quarter, notes


def _sid_frequency(pitch: int | None) -> int:
    """
    Convert an equal-tempered MIDI pitch to the 1 MHz SID frequency register.

    :param pitch: MIDI note number, or None for an inactive voice.
    :return: Rounded SID register value, or zero for an inactive voice.
    :raises ValueError: The pitch cannot fit in the SID's 16-bit register.
    """
    if pitch is None:
        return 0
    frequency_hz = 440 * 2 ** ((pitch - 69) / 12)
    register_value = round(frequency_hz * 2**24 / SID_CLOCK_HZ)
    if not 0 <= register_value <= 0xFFFF:
        raise ValueError(f"MIDI pitch {pitch} exceeds the SID frequency range")
    return register_value


def music_records(source: Path = SOURCE) -> list[MusicRecord]:
    """
    Build three-voice SID states for the introduction and first chorus line.

    :param source: Constant-120-BPM MIDI with three monophonic channels.
    :return: Absolute 25 ms tick records ending with an all-voices-off record.
    :raises OSError: The MIDI source cannot be read.
    :raises ValueError: MIDI is unsupported, polyphonic, or outside SID range.
    """
    ticks_per_quarter, notes = read_midi(source)
    events: dict[int, list[NoteEvent]] = {}
    for note in notes:
        if note.tick >= EXCERPT_BEATS * ticks_per_quarter:
            continue
        step = round(
            note.tick * TEMPO_MICROSECONDS / 1000 / ticks_per_quarter / TICK_MS
        )
        events.setdefault(step, []).append(note)
    active: list[int | None] = [None] * VOICE_COUNT
    records: list[MusicRecord] = []
    for step, changes in sorted(events.items()):
        retrigger_mask = 0
        # Release notes before replacements that share the same quantised tick.
        for note in sorted(changes, key=_note_order):
            if note.is_on:
                if active[note.channel] is not None:
                    raise ValueError("Expected monophonic MIDI channels")
                active[note.channel] = note.pitch
                retrigger_mask |= 1 << note.channel
            elif active[note.channel] == note.pitch:
                active[note.channel] = None
        frequencies = [_sid_frequency(pitch) for pitch in active]
        active_mask = sum(
            1 << channel for channel, pitch in enumerate(active) if pitch is not None
        )
        records.append(
            (
                step,
                frequencies[0],
                frequencies[1],
                frequencies[2],
                active_mask,
                retrigger_mask,
            )
        )
    end_step = round(EXCERPT_BEATS * TEMPO_MICROSECONDS / 1000 / TICK_MS)
    records.append((end_step, 0, 0, 0, 0, 0))
    return records


def _note_order(note: NoteEvent) -> tuple[bool, int, int]:
    """
    Supply deterministic note-off-before-note-on ordering within one tick.

    :param note: Note transition to order.
    :return: Sort key of on/off state, channel and pitch.
    """
    return note.is_on, note.channel, note.pitch


def _speech_records(cues: tuple[SpeechCue, ...]) -> list[SpeechRecord]:
    """
    Expand syllables into ordered allophone commands on the musical timeline.

    :param cues: Ordered chorus-relative seconds, labels and allophone tuples.
    :return: Absolute 25 ms tick and allophone-code pairs including the intro.
    :raises ValueError: Cue times are unordered/negative or codes exceed 0-63.
    """
    records: list[SpeechRecord] = []
    previous_seconds = 0.0
    for seconds, label, codes in cues:
        if seconds < previous_seconds:
            raise ValueError(f"Cue {label!r} has a negative or unordered time")
        if not codes or any(not 0 <= code <= 63 for code in codes):
            raise ValueError(f"Cue {label!r} needs allophone codes in range 0-63")
        step = round((INTRO_SECONDS + seconds) * 1000 / TICK_MS)
        records.extend((step, code) for code in codes)
        previous_seconds = seconds
    return records


def generate(
    source: Path = SOURCE,
    template: Path = TEMPLATE,
    output: Path = OUTPUT,
) -> Path:
    """
    Append generated DATA records to the external BASIC player template.

    :param source: MIDI arrangement to extract.
    :param template: UTF-8 BASIC player, with numbered lines below 1000.
    :param output: BASIC file to create or replace after successful generation.
    :return: Path of the generated BASIC program.
    :raises OSError: A source/template cannot be read or output cannot be written.
    :raises ValueError: MIDI, speech cues or template line numbers are invalid.
    """
    music = music_records(source)
    speech = _speech_records(CUES)
    listing = template.read_text(encoding="utf-8").rstrip("\n") + "\n"
    _validate_template(listing)
    rows = [(len(music), len(speech)), *music, *speech]
    for index, row in enumerate(rows):
        line_number = DATA_START_LINE + index * DATA_LINE_INCREMENT
        listing += f"{line_number} DATA " + ",".join(map(str, row)) + "\n"
    output.write_text(listing, encoding="utf-8")
    return output


def _validate_template(listing: str) -> None:
    """
    Check that player lines cannot collide with appended BASIC DATA lines.

    :param listing: Nonempty line-numbered BASIC player text.
    :raises ValueError: Lines are unnumbered, unordered, duplicated or too high.
    """
    previous_line = 0
    for line in listing.splitlines():
        fields = line.split(maxsplit=1)
        if len(fields) != 2 or not fields[0].isdigit():
            raise ValueError("BASIC template requires a number and statement per line")
        line_number = int(fields[0])
        if not previous_line < line_number < DATA_START_LINE:
            raise ValueError("BASIC template lines must increase within 1-999")
        previous_line = line_number


if __name__ == "__main__":
    generated_path = generate()
    print(f"Generated {generated_path}")
