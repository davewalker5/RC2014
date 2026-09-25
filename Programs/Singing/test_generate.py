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

    def test_excerpt_boundaries(self) -> None:
        """Keep the introduction, chorus entry and exact first-line cutoff."""
        # Use the real arrangement here: these fixed landmarks protect the
        # chosen excerpt against an accidental change in start time or length.
        # Rows contain tick, three frequencies, active mask and retrigger mask.
        records = generate.music_records()
        # The introduction begins with bass only (voice 2, mask bit value 2).
        self.assertEqual(len(records), 61)
        self.assertEqual(records[0], (0, 0, 2195, 0, 2, 2))
        # 120 * 25 ms = 3 seconds: melody joins the bass after the two-bar intro.
        # Mask 3 selects voices 1 and 2; both must be triggered at this point.
        chorus_entry = next(row for row in records if row[0] == 120)
        self.assertEqual(chorus_entry, (120, 13153, 2195, 0, 3, 3))
        # 600 * 25 ms = 15 seconds. A silent final state must release every
        # voice instead of allowing the next chorus phrase to leak through.
        self.assertEqual(records[-1], (600, 0, 0, 0, 0, 0))

    def test_external_template_and_working_directory(self) -> None:
        """Read custom template changes and run the CLI outside its directory."""
        # A deliberately tiny player makes it obvious whether generation
        # actually reads the supplied template or still uses embedded BASIC.
        with TemporaryDirectory() as directory:
            temporary = Path(directory)
            template = temporary / "player.bas.template"
            output = temporary / "result.bas"
            template.write_text("10 REM CUSTOM PLAYER\n20 END\n", encoding="utf-8")
            generate.generate(template=template, output=output)
            # The template must precede the generated counts: 61 music events
            # and 32 speech codes. DATA still starts at the reserved line 1000.
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
            # Launch a fresh Python process with its working directory outside
            # Programs/Singing. Relative input paths must resolve from the
            # script's location, not whichever directory the caller happens
            # to be in. Reuse this interpreter to avoid Python-version drift.
            subprocess.run(
                [sys.executable, "-B", str(singing / "generate.py")],
                cwd=temporary,
                check=True,
                capture_output=True,
            )
            # Compare against the current template, rather than hardcoding
            # adjustable settings such as DL, TA or volume. Cue assertions
            # below retain the intentional early starts for "give" and "me":
            # (3 + 5.9) / .025 = 356 and (3 + 6.4) / .025 = 376.
            result = (singing / "daisy-line-1.bas").read_text()
            self.assertTrue(
                result.startswith(generate.TEMPLATE.read_text(encoding="utf-8"))
            )
            self.assertIn(" DATA 356,36\n", result)  # Earlier "give" cue.
            self.assertIn(" DATA 376,16\n", result)  # Earlier "me" cue.

    def test_running_status_and_zero_velocity(self) -> None:
        """Interpret a zero-velocity running-status note as a release."""
        # At tick 0, status 90 starts middle C (3C) at velocity 40. One tick
        # later the status byte is omitted: running status reuses 90, but a
        # velocity of zero must be interpreted as note-off, not another start.
        events = b"\x00\x90\x3c\x40\x01\x3c\x00"
        with TemporaryDirectory() as directory:
            source = Path(directory) / "notes.mid"
            source.write_bytes(_midi_file(events))
            resolution, notes = generate.read_midi(source)
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
            # instead selects SMPTE timing, which this prototype does not use.
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

    def test_invalid_template_preserves_output(self) -> None:
        """Reject DATA collisions before replacing an existing BASIC file."""
        # Existing output represents a previously usable program. Invalid
        # templates must be rejected before opening that file for replacement.
        with TemporaryDirectory() as directory:
            template = Path(directory) / "bad.template"
            output = Path(directory) / "existing.bas"
            output.write_text("original", encoding="utf-8")
            # Exercise an empty file, an unnumbered statement, duplicate line
            # numbers, and collision with the generated DATA range at 1000.
            for listing in ("", "REM NO NUMBER", "10 END\n10 END", "1000 END"):
                with self.subTest(listing=listing):
                    template.write_text(listing, encoding="utf-8")
                    with self.assertRaises(ValueError):
                        generate.generate(template=template, output=output)
                    # Merely raising is insufficient: a late validation could
                    # already have truncated or partially overwritten output.
                    self.assertEqual(output.read_text(), "original")


if __name__ == "__main__":
    unittest.main()
