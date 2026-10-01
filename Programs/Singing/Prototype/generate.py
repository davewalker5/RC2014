"""
Build the Daisy Bell singing prototype from MIDI and BASIC or assembly templates
"""

import argparse
import struct
import subprocess
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
from tempfile import TemporaryDirectory

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent.parent / "MIDI/DaisyBell/DaisyBell.mid"
TEMPLATE = HERE / "player.bas.template"
OUTPUT = HERE / "daisy-line-1.bas"
ASM_TEMPLATE = HERE / "player.asm.template"
ASM_OUTPUT = HERE / "daisy-line-1.asm"
ASM_ORIGIN = 0xE000
ASM_RAM_END = 0xFC00  # SCM reserves RAM from FC00 upwards.
ASM_TICK_MS = 5
SID_WAVEFORM = 16
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


def _sid_writes(record: MusicRecord, previous_mask: int) -> list[tuple[int, int]]:
    """
    Precompute the SID writes performed by BASIC's three voice subroutine calls.

    :param record: Time, three frequencies, active mask and retrigger mask.
    :param previous_mask: Active voices before this event (bits 0-2).
    :return: Ordered register/value pairs, including gate transitions.
    """
    _, *frequencies, active_mask, retrigger_mask = record
    writes: list[tuple[int, int]] = []
    for voice, frequency in enumerate(frequencies):
        voice_bit = 1 << voice
        register_base = voice * 7
        control_register = register_base + 4
        active = bool(active_mask & voice_bit)
        previous = bool(previous_mask & voice_bit)
        retrigger = bool(retrigger_mask & voice_bit)
        if previous and not active:
            writes.append((control_register, SID_WAVEFORM))
        if retrigger:
            writes.append((control_register, SID_WAVEFORM))
        if active:
            writes.extend(
                ((register_base, frequency & 255), (register_base + 1, frequency >> 8))
            )
            if not previous or retrigger:
                writes.append((control_register, SID_WAVEFORM + 1))
    return writes


def _assembly_music(music: list[MusicRecord]) -> str:
    """
    Encode SID events as standalone z80asm directives with 5 ms timestamps.

    :param music: Ordered BASIC-compatible SID state records.
    :return: Assembly table including a FFFF end marker.
    """
    lines = []
    previous_mask = 0
    for record in music:
        writes = _sid_writes(record, previous_mask)
        tick = record[0] * TICK_MS // ASM_TICK_MS
        lines.extend(
            (
                f"    dw {tick} ; {record[0] * TICK_MS} ms",
                f"    db {len(writes)} ; register/value pair count",
            )
        )
        for register, value in writes:
            # Keep waveform selection editable in the assembly template.
            encoded = str(value)
            if register in (4, 11, 18):
                encoded = "WAVEFORM+1" if value & 1 else "WAVEFORM"
            lines.append(f"    db {register},{encoded}")
        previous_mask = record[4]
    lines.append("    dw 65535 ; end of music")
    return "\n".join(lines)


def _assembly_speech(speech: list[SpeechRecord]) -> str:
    """
    Encode allophones with a flag identifying the first code of each syllable.

    :param speech: Ordered absolute BASIC tick/allophone pairs.
    :return: Assembly table with 5 ms timestamps and a FFFF end marker.
    """
    lines = []
    previous_tick = None
    for tick, code in speech:
        first_code = int(tick != previous_tick)
        lines.extend(
            (
                f"    dw {tick * TICK_MS // ASM_TICK_MS}",
                f"    db {code},{first_code} ; allophone, first-code flag",
            )
        )
        previous_tick = tick
    lines.append("    dw 65535 ; end of speech")
    return "\n".join(lines)


def generate_asm(
    source: Path = SOURCE,
    template: Path = ASM_TEMPLATE,
    output: Path = ASM_OUTPUT,
) -> Path:
    """
    Insert shared MIDI and speech data into the commented assembly template.

    :param source: MIDI arrangement to extract.
    :param template: UTF-8 z80asm template with one marker per event table.
    :param output: Assembly source file to create or replace.
    :return: Generated source path; assembly is a separate optional step.
    :raises OSError: An input cannot be read or output cannot be written.
    :raises ValueError: Input data or template markers are invalid.
    """
    music = _assembly_music(music_records(source))
    speech = _assembly_speech(_speech_records(CUES))
    listing = template.read_text(encoding="utf-8")
    for marker, table in (("@MUSIC_DATA@", music), ("@SPEECH_DATA@", speech)):
        if listing.count(marker) != 1:
            raise ValueError(f"Assembly template requires exactly one {marker}")
        listing = listing.replace(marker, table)
    output.write_text(listing, encoding="utf-8")
    return output


def _intel_hex(binary: bytes, origin: int) -> str:
    """
    Encode a contiguous binary as checked, 16-byte Intel HEX records.

    :param binary: Machine-code image to encode.
    :param origin: Unsigned 16-bit load address.
    :return: ASCII Intel HEX text with an end-of-file record.
    :raises ValueError: The image is empty or exceeds the 16-bit address space.
    """
    if not binary or not 0 <= origin < 65536 or origin + len(binary) > 65536:
        raise ValueError("Binary must fit within the 16-bit load address space")
    lines = []
    for offset in range(0, len(binary), 16):
        payload = binary[offset : offset + 16]
        address = origin + offset
        record = bytes((len(payload), address >> 8, address & 255, 0)) + payload
        checksum = (-sum(record)) & 255
        lines.append(":" + (record + bytes((checksum,))).hex().upper())
    lines.append(":00000001FF")
    return "\n".join(lines) + "\n"


def assemble(source: Path, assembler: str = "z80asm") -> tuple[Path, Path]:
    """
    Build a checked E000-FBFF binary and an SCM-loadable Intel HEX file.

    :param source: Generated assembly source to assemble.
    :param assembler: Standalone z80asm executable name or path.
    :return: Binary and Intel HEX paths beside the source.
    :raises OSError: The assembler or files cannot be accessed.
    :raises subprocess.CalledProcessError: Assembly fails.
    :raises ValueError: The image has a wrong origin/header or exceeds safe RAM.
    """
    with TemporaryDirectory() as directory:
        temporary_binary = Path(directory) / "player.bin"
        subprocess.run(
            [assembler, "-o", str(temporary_binary), str(source.resolve())],
            check=True,
        )
        binary = temporary_binary.read_bytes()
    # The fixed public header is JP E007, result, late count and tick word.
    # Reject relocations unless the loading contract is deliberately updated.
    if binary[:3] != bytes((0xC3, 0x07, 0xE0)):
        raise ValueError("Player must retain its E000 origin and seven-byte header")
    if len(binary) > ASM_RAM_END - ASM_ORIGIN:
        raise ValueError("Player exceeds E000-FBFF; SCM workspace must stay intact")
    binary_path = source.with_suffix(".bin")
    hex_path = source.with_suffix(".hex")
    hex_text = _intel_hex(binary, ASM_ORIGIN)
    binary_path.write_bytes(binary)
    hex_path.write_text(hex_text, encoding="ascii")
    return binary_path, hex_path


def main() -> None:
    """
    Generate BASIC by default, or assembly and optional loadable artifacts.

    Command-line errors are reported by argparse; generation/build errors retain
    their original exception and a nonzero exit status.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("basic", "asm"), default="basic")
    parser.add_argument(
        "--assemble",
        action="store_true",
        help="also build .bin and Intel .hex (requires --format asm)",
    )
    parser.add_argument("--assembler", default="z80asm", help="z80asm executable")
    args = parser.parse_args()
    if args.assemble and args.format != "asm":
        parser.error("--assemble requires --format asm")
    generated_path = generate_asm() if args.format == "asm" else generate()
    print(f"Generated {generated_path}")
    if args.assemble:
        for path in assemble(generated_path, args.assembler):
            print(f"Built {path}")


if __name__ == "__main__":
    main()
