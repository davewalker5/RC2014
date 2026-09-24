"""Regression checks for MIDI extraction and the external BASIC template."""

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
    track = b"\x00\xff\x51\x03\x07\xa1\x20" + events + b"\x00\xff\x2f\x00"
    header = b"MThd" + struct.pack(">IHHH", 6, 1, 1, resolution)
    return header + b"MTrk" + struct.pack(">I", len(track)) + track


class GeneratorTests(unittest.TestCase):
    """Exercise supported MIDI, rejected input and template-based generation."""

    def test_excerpt_boundaries(self) -> None:
        """Keep the introduction, chorus entry and exact first-line cutoff."""
        records = generate.music_records()
        self.assertEqual(len(records), 61)
        self.assertEqual(records[0], (0, 0, 2195, 0, 2, 2))
        chorus_entry = next(row for row in records if row[0] == 120)
        self.assertEqual(chorus_entry, (120, 13153, 2195, 0, 3, 3))
        self.assertEqual(records[-1], (600, 0, 0, 0, 0, 0))

    def test_external_template_and_working_directory(self) -> None:
        """Read custom template changes and run the CLI outside its directory."""
        with TemporaryDirectory() as directory:
            temporary = Path(directory)
            template = temporary / "player.bas.template"
            output = temporary / "result.bas"
            template.write_text("10 REM CUSTOM PLAYER\n20 END\n", encoding="utf-8")
            generate.generate(template=template, output=output)
            self.assertTrue(
                output.read_text().startswith(
                    "10 REM CUSTOM PLAYER\n20 END\n1000 DATA 61,32\n"
                )
            )
            # Copy all inputs to an isolated tree so CLI verification never
            # rewrites a user's tuned listing in the working directory.
            singing = temporary / "Programs/Singing"
            midi = temporary / "Programs/MIDI/DaisyBell"
            singing.mkdir(parents=True)
            midi.mkdir(parents=True)
            for source in (Path(generate.__file__), generate.TEMPLATE):
                (singing / source.name).write_bytes(source.read_bytes())
            (midi / "DaisyBell.mid").write_bytes(generate.SOURCE.read_bytes())
            subprocess.run(
                [sys.executable, "-B", str(singing / "generate.py")],
                cwd=temporary,
                check=True,
                capture_output=True,
            )
            result = (singing / "daisy-line-1.bas").read_text()
            self.assertTrue(
                result.startswith(generate.TEMPLATE.read_text(encoding="utf-8"))
            )
            self.assertIn(" DATA 356,36\n", result)  # Earlier "give" cue.
            self.assertIn(" DATA 376,16\n", result)  # Earlier "me" cue.

    def test_running_status_and_zero_velocity(self) -> None:
        """Interpret a zero-velocity running-status note as a release."""
        events = b"\x00\x90\x3c\x40\x01\x3c\x00"
        with TemporaryDirectory() as directory:
            source = Path(directory) / "notes.mid"
            source.write_bytes(_midi_file(events))
            resolution, notes = generate.read_midi(source)
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
        cases = (
            (_midi_file(b"")[:-1], "Truncated"),
            (_midi_file(b"", resolution=0), "resolution"),
            (_midi_file(b"", resolution=0x8001), "resolution"),
            (_midi_file(b"\x00\x3c\x40"), "preceding channel status"),
            (_midi_file(b"\x00\x93\x3c\x40"), "accompaniment"),
            (_midi_file(b"\x00\x90\x80\x40"), "seven-bit"),
            (_midi_file(b"\x00\xff\x51\x03\x06\x1a\x80"), "120 BPM"),
        )
        with TemporaryDirectory() as directory:
            source = Path(directory) / "invalid.mid"
            for payload, message in cases:
                with self.subTest(message=message):
                    source.write_bytes(payload)
                    with self.assertRaisesRegex(ValueError, message):
                        generate.read_midi(source)

    def test_variable_length_boundaries(self) -> None:
        """Accept four-byte quantities and reject overlong or incomplete ones."""
        self.assertEqual(
            generate._read_variable_length(BytesIO(b"\xff\xff\xff\x7f")),
            0x0FFFFFFF,
        )
        for payload in (b"\x80", b"\x80\x80\x80\x80\x00"):
            with self.assertRaises(ValueError):
                generate._read_variable_length(BytesIO(payload))

    def test_polyphonic_input(self) -> None:
        """Reject overlapping notes on a single SID-mapped MIDI channel."""
        with TemporaryDirectory() as directory:
            source = Path(directory) / "chord.mid"
            source.write_bytes(_midi_file(b"\x00\x90\x3c\x40\x00\x90\x40\x40"))
            with self.assertRaisesRegex(ValueError, "monophonic"):
                generate.music_records(source)

    def test_invalid_template_preserves_output(self) -> None:
        """Reject DATA collisions before replacing an existing BASIC file."""
        with TemporaryDirectory() as directory:
            template = Path(directory) / "bad.template"
            output = Path(directory) / "existing.bas"
            output.write_text("original", encoding="utf-8")
            for listing in ("", "REM NO NUMBER", "10 END\n10 END", "1000 END"):
                with self.subTest(listing=listing):
                    template.write_text(listing, encoding="utf-8")
                    with self.assertRaises(ValueError):
                        generate.generate(template=template, output=output)
                    self.assertEqual(output.read_text(), "original")


if __name__ == "__main__":
    unittest.main()
