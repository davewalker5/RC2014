"""Regression checks for full-arrangement MIDI and speech extraction."""

import struct
import subprocess
import sys
import unittest
from io import BytesIO
from pathlib import Path
from tempfile import TemporaryDirectory

import generate


def _midi_file(events: bytes, resolution: int = 480) -> bytes:
    """
    Wrap track events in a minimal format-1 MIDI file with a 120 BPM tempo.

    :param events: Encoded track events, including delta times.
    :param resolution: Header ticks per quarter note.
    :return: Complete MIDI bytes for parser boundary tests.
    """
    # Build fixtures independently of the generator under test. The opening
    # event has zero delta time, meta-event type 51, and three bytes encoding
    # 500,000 microseconds per quarter note (120 BPM). The closing FF 2F event
    # marks end-of-track, so callers only need to supply the events of interest.
    track = b"\x00\xff\x51\x03\x07\xa1\x20" + events + b"\x00\xff\x2f\x00"
    # MIDI chunk lengths and header fields are big-endian. The six-byte header
    # payload declares format 1, one track, and the requested tick resolution.
    # Keeping these wrappers valid isolates errors deliberately placed inside
    # the track rather than accidentally testing an unrelated header failure.
    header = b"MThd" + struct.pack(">IHHH", 6, 1, 1, resolution)
    return header + b"MTrk" + struct.pack(">I", len(track)) + track


class GeneratorTests(unittest.TestCase):
    """Exercise supported MIDI, rejected input and template-based generation."""

    def test_full_arrangement_boundaries(self) -> None:
        """Include the intro, all chorus phrases, closing tonic and final silence."""
        records = generate.music_records()
        self.assertEqual(records[0], (0, 0, 2195, 0, 2, 2))
        self.assertEqual(next(row for row in records if row[0] == 120),
                         (120, 13153, 2195, 0, 3, 3))
        for seconds in (15, 27, 39, 51):
            with self.subTest(seconds=seconds):
                row = next(row for row in records if row[0] == seconds * 40)
                self.assertTrue(row[4] & 1)
        self.assertEqual(records[-1], (2160, 0, 0, 0, 0, 0))
        self.assertEqual(records[-2][4], 0)  # Closing notes release at 53.75 s.
        self.assertEqual(records[-2][0], 2150)

    def test_speech_sources_and_full_lyrics(self) -> None:
        """Consume every tuned line's spoken codes, with explicit musical cues."""
        cues = generate.speech_cues()
        self.assertEqual(len(cues), 51)
        self.assertEqual(cues[0], (0, "Dai", (33, 20, 0)))
        self.assertEqual(cues[-1], (45, "two", (13, 22, 0)))
        records = generate._speech_records(cues)
        self.assertEqual(records[0], (120, 33))
        self.assertEqual(records[-1], (1920, 0))
        self.assertEqual([tick for tick, _ in records], sorted(tick for tick, _ in records))
        # Independently extract only voiced codes: sentence pauses are replaced
        # by the cue timeline, but pronunciation order must survive unchanged.
        expected = []
        for path in sorted(generate.SPEECH_SOURCE.glob("daisy-chorus-line-*.bas")):
            for line in path.read_text().splitlines():
                if " DATA " in line:
                    expected.extend(int(code) for code in line.split(" DATA ")[1].split(",")
                                    if int(code) > 4)
        self.assertEqual([code for _, code in records if code > 4], expected)

    def test_changed_speech_is_read_and_mismatched_groups_rejected(self) -> None:
        """Read pronunciation edits from source and reject incompatible lengths."""
        with TemporaryDirectory() as directory:
            target = Path(directory)
            for path in generate.SPEECH_SOURCE.glob("daisy-chorus-line-*.bas"):
                (target / path.name).write_bytes(path.read_bytes())
            first = target / "daisy-chorus-line-1.bas"
            first.write_text(first.read_text().replace("33,20", "33,19", 1))
            self.assertEqual(generate.speech_cues(target)[0][2], (33, 19, 0))
            first.write_text(first.read_text().replace("33,19", "33", 1))
            with self.assertRaisesRegex(ValueError, "cue groups"):
                generate.speech_cues(target)

    def test_cli_from_another_directory(self) -> None:
        """Default CLI generates assembly only and resolves inputs from its file."""
        with TemporaryDirectory() as directory:
            root = Path(directory)
            singing = root / "Programs/Singing/DaisyBell"
            midi = root / "Programs/MIDI/DaisyBell"
            speech = root / "Programs/Speech/DaisyBell"
            for folder in (singing, midi, speech):
                folder.mkdir(parents=True)
            for path in (Path(generate.__file__), generate.ASM_TEMPLATE):
                (singing / path.name).write_bytes(path.read_bytes())
            (midi / "DaisyBell.mid").write_bytes(generate.SOURCE.read_bytes())
            for path in generate.SPEECH_SOURCE.glob("daisy-chorus-line-*.bas"):
                (speech / path.name).write_bytes(path.read_bytes())
            subprocess.run([sys.executable, "-B", str(singing / "generate.py")],
                           cwd=root, check=True, capture_output=True)
            listing = (singing / "daisy-chorus.asm").read_text()
            self.assertIn("DW 10800 ; 54000 ms", listing)
            self.assertIn("EQU 11600", listing)
            self.assertNotIn("@", listing)
            self.assertEqual(list(singing.glob("*.bas")), [])

    def test_running_status_and_zero_velocity(self) -> None:
        """Interpret a zero-velocity running-status note as a release."""
        # At tick 0, status 90 starts middle C (3C) at velocity 40. One tick
        # later the status byte is omitted: running status reuses 90, but a
        # velocity of zero must be interpreted as note-off, not another start.
        events = b"\x00\x90\x3c\x40\x01\x3c\x00"
        with TemporaryDirectory() as directory:
            source = Path(directory) / "notes.mid"
            source.write_bytes(_midi_file(events))
            resolution, notes, end_tick = generate.read_midi(source)
        self.assertEqual(end_tick, 1)
        # Check absolute event times and semantics, not just the number of
        # decoded events. Either mistake could leave a SID note stuck on.
        self.assertEqual(resolution, 480)
        self.assertEqual(
            notes,
            [
                generate.NoteEvent(0, 0, 60, True),
                generate.NoteEvent(1, 0, 60, False),
            ],
        )

    def test_invalid_midi(self) -> None:
        """Reject truncation, invalid timing and malformed event encodings."""
        # Each fixture breaks one supported-format rule. The expected text
        # checks that callers receive a meaningful ValueError rather than an
        # obscure indexing/unpacking exception from deeper inside the parser.
        cases = (
            # Remove a byte while retaining the original declared chunk size.
            (_midi_file(b"")[:-1], "Truncated"),
            # Zero resolution cannot convert ticks to time; the high bit
            # instead selects SMPTE timing, which this player does not use.
            (_midi_file(b"", resolution=0), "resolution"),
            (_midi_file(b"", resolution=0x8001), "resolution"),
            # Data without a prior status, an unsupported fourth note channel,
            # and a channel-data byte with its forbidden high bit set.
            (_midi_file(b"\x00\x3c\x40"), "preceding channel status"),
            (_midi_file(b"\x00\x93\x3c\x40"), "accompaniment"),
            (_midi_file(b"\x00\x90\x80\x40"), "seven-bit"),
            # A second tempo event changes the rate to 400,000 us per beat;
            # this player requires the single initial 120 BPM tempo instead.
            (_midi_file(b"\x00\xff\x51\x03\x06\x1a\x80"), "120 BPM"),
        )
        with TemporaryDirectory() as directory:
            source = Path(directory) / "invalid.mid"
            for payload, message in cases:
                # subTest reports each malformed fixture separately, allowing
                # the remaining cases to run even if one validation regresses.
                with self.subTest(message=message):
                    source.write_bytes(payload)
                    with self.assertRaisesRegex(ValueError, message):
                        generate.read_midi(source)

    def test_variable_length_boundaries(self) -> None:
        """Accept four-byte quantities and reject overlong or incomplete ones."""
        # A MIDI variable-length quantity contributes seven value bits per
        # byte. The high bit requests another byte; four bytes are the limit.
        # This is the largest legal value: all 28 payload bits are one.
        self.assertEqual(
            generate._read_variable_length(BytesIO(b"\xff\xff\xff\x7f")),
            0x0FFFFFFF,
        )
        # The first input ends while promising another byte. The second
        # demands a fifth byte, even though its decoded value would be small.
        # Reject both so malformed lengths cannot make the reader run onward.
        for payload in (b"\x80", b"\x80\x80\x80\x80\x00"):
            with self.assertRaises(ValueError):
                generate._read_variable_length(BytesIO(payload))

    def test_polyphonic_input(self) -> None:
        """Reject overlapping notes on a single SID-mapped MIDI channel."""
        # Both zero-delta note-ons use channel 0: C and E begin together,
        # without a release between them. One SID voice cannot represent both;
        # silently replacing the first pitch would conceal an unsupported MIDI.
        with TemporaryDirectory() as directory:
            source = Path(directory) / "chord.mid"
            source.write_bytes(_midi_file(b"\x00\x90\x3c\x40\x00\x90\x40\x40"))
            with self.assertRaisesRegex(ValueError, "monophonic"):
                generate.music_records(source)



if __name__ == "__main__":
    unittest.main()
