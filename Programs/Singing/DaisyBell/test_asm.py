"""Check assembly generation, Intel HEX loading data and optional Z80 execution."""

import os
import shutil
import subprocess
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import generate


class AssemblyTests(unittest.TestCase):
    """Verify the generated machine-code path without changing user artifacts."""

    def test_sid_gate_transitions(self) -> None:
        """Preserve held notes, retrigger repeated notes and release ended voices."""
        # Use an easily recognised frequency word to expose byte-order bugs:
        # register 0 takes 34 (low byte), register 1 takes 12 (high byte).
        # Control register 4 uses 16 for triangle/gate-off and 17 for gate-on.
        # A newly triggered note must lower the gate, set pitch, then raise it.
        self.assertEqual(
            generate._sid_writes((0, 0x1234, 0, 0, 1, 1), 0),
            [(4, 16), (0, 0x34), (1, 0x12), (4, 17)],
        )
        # A held note may rewrite its frequency, but must not toggle the gate:
        # doing so would restart the envelope at every accompaniment event.
        self.assertEqual(
            generate._sid_writes((1, 0x1234, 0, 0, 1, 0), 1),
            [(0, 0x34), (1, 0x12)],
        )
        # Conversely, an explicit retrigger must restart the envelope even
        # when both the pitch and active-voice mask are unchanged.
        self.assertEqual(
            generate._sid_writes((2, 0x1234, 0, 0, 1, 1), 1),
            [(4, 16), (0, 0x34), (1, 0x12), (4, 17)],
        )
        # Previous mask 7 means all three voices were sounding. Release their
        # control registers (4, 11, 18); do not send meaningless frequency data.
        self.assertEqual(
            generate._sid_writes((3, 0, 0, 0, 0, 0), 7),
            [(4, 16), (11, 16), (18, 16)],
        )
        # Silence followed by silence requires no writes at all. The assembly
        # consumer must be able to encounter such a zero-pair record safely.
        self.assertEqual(generate._sid_writes((4, 0, 0, 0, 0, 0), 0), [])

    def test_speech_group_flags(self) -> None:
        """Identify first codes and convert 25 ms cue units to 5 ms ticks."""
        # Two allophones share the first syllable's cue; the third begins a
        # different syllable. Only first codes should count towards lateness.
        # Scaling by five preserves real time when moving from 25 ms to 5 ms.
        table = generate._assembly_speech([(120, 33), (120, 20), (180, 55)])
        self.assertIn("DW 600\n    DB 33,1", table)
        self.assertIn("DW 600\n    DB 20,0", table)
        self.assertIn("DW 900\n    DB 55,1", table)
        # The sentinel stops the assembly routine walking into unrelated RAM.
        self.assertTrue(table.endswith("DW 65535 ; end of speech"))

    def test_template_markers(self) -> None:
        """Require exactly one insertion point for each assembly table."""
        # Empty/missing markers would omit data; duplicate markers could
        # produce duplicated labels or tables. None should leave an output
        # file that could be mistaken for successfully generated assembly.
        with TemporaryDirectory() as directory:
            template = Path(directory) / "bad.template"
            output = Path(directory) / "player.asm"
            for listing in ("", "@MUSIC_DATA@", "@MUSIC_DATA@" * 2 + "@SPEECH_DATA@"):
                with self.subTest(listing=listing):
                    template.write_text(listing, encoding="utf-8")
                    with self.assertRaisesRegex(ValueError, "exactly one"):
                        generate.generate_asm(template=template, output=output)
                    self.assertFalse(output.exists())

    def test_intel_hex_round_trip(self) -> None:
        """Decode checksummed Intel HEX records and recover the complete image."""
        # This payload spans several full records and a short final record,
        # exercising length calculation without depending on assembled code.
        binary = bytes(range(255))
        encoded = generate._intel_hex(binary, 0xE000)
        recovered = bytearray()
        for line in encoded.splitlines():
            # Decode independently of the writer. After the colon, a record
            # contains count, two address bytes, type, payload and checksum.
            # All decoded bytes, including checksum, must sum to zero mod 256.
            record = bytes.fromhex(line[1:])
            self.assertEqual(sum(record) & 255, 0)
            self.assertEqual(len(record), record[0] + 5)
            # Type 1 is EOF, not image data. Check its canonical encoding and
            # leave it out of the reconstructed binary.
            if record[3] == 1:
                self.assertEqual(line, ":00000001FF")
                continue
            # Record addresses must remain contiguous, with no gaps, repeats
            # or overlaps, including the shorter final data record.
            address = int.from_bytes(record[1:3], "big")
            self.assertEqual(address, 0xE000 + len(recovered))
            recovered.extend(record[4:-1])
        # Correct checksums alone do not establish correct content: compare
        # every reconstructed byte with the independently supplied payload.
        self.assertEqual(recovered, binary)
        # Reject empty images, address-space overflow, and negative origins
        # rather than wrapping addresses or emitting an apparently valid file.
        for payload, origin in ((b"", 0), (b"xx", 65535), (b"x", -1)):
            with self.assertRaises(ValueError):
                generate._intel_hex(payload, origin)

    @unittest.skipUnless(shutil.which("z80asm"), "standalone z80asm is not installed")
    def test_assembly_build(self) -> None:
        """Build a loadable RAM image and reject a mismatched relocation."""
        # Use the real cross-assembler, but keep every artifact temporary so
        # neither success nor intentional failure changes the user's files.
        with TemporaryDirectory() as directory:
            source = Path(directory) / "player.asm"
            generate.generate_asm(output=source)
            binary, hex_file = generate.assemble(source)
            # C3 07 E0 is JP E007: execution skips the seven-byte public header.
            # FC00-E000 gives 1C00 bytes before reaching SCM's reserved RAM.
            self.assertEqual(binary.read_bytes()[:3], b"\xc3\x07\xe0")
            self.assertLessEqual(binary.stat().st_size, 0x1C00)
            self.assertTrue(hex_file.read_text().endswith(":00000001FF\n"))
            # Relocate only the source, deliberately leaving the generator's
            # loading contract at E000. The mismatched jump must be rejected,
            # and the binary from the preceding successful build must survive.
            original = binary.read_bytes()
            source.write_text(source.read_text().replace("EQU 0E000H", "EQU 0D000H"))
            with self.assertRaisesRegex(ValueError, "origin"):
                generate.assemble(source)
            self.assertEqual(binary.read_bytes(), original)

    @unittest.skipUnless(
        os.environ.get("SINGING_Z80_SOURCE")
        and shutil.which("cc")
        and shutil.which("z80asm"),
        "set SINGING_Z80_SOURCE to libz80 directory for CPU execution checks",
    )
    def test_cpu_execution(self) -> None:
        """Run actual Z80 code with ready, slow and permanently busy speech cards."""
        # The dependency is EmulatorKit's libz80 source, not a running emulator
        # or ROM. The harness provides memory and port callbacks itself.
        core = Path(os.environ["SINGING_Z80_SOURCE"])
        with TemporaryDirectory() as directory:
            source = Path(directory) / "player.asm"
            runner = Path(directory) / "runner"
            generate.generate_asm(output=source)
            binary, _ = generate.assemble(source)
            # Compile the C harness and CPU core into a private executable.
            # Compilation errors remain test failures, rather than being
            # mistaken for an unavailable optional tool and silently skipped.
            subprocess.run(
                [
                    "cc",
                    "-O2",
                    "-I",
                    str(core),
                    str(generate.HERE / "test_player.c"),
                    str(core / "z80.c"),
                    "-o",
                    str(runner),
                ],
                check=True,
                capture_output=True,
            )
            # Each new process starts with clean CPU/RAM state. Mode 0 always
            # accepts speech; mode 1 holds ready low for 120 ms after a code;
            # mode 2 never becomes ready and must exercise the timeout path.
            for mode in (0, 1, 2):
                with self.subTest(speech_mode=mode):
                    # The wall-clock timeout is a second guard against a hung
                    # harness. Its own execution loop also bounds Z80 cycles.
                    # check=True exposes register/stack/I/O failures reported
                    # by the C process before the Python trace checks begin.
                    result = subprocess.run(
                        [str(runner), str(binary), str(mode)],
                        check=True,
                        capture_output=True,
                        text=True,
                        timeout=30,
                    )
                    self._check_execution(result.stdout, mode)

    def _check_execution(self, trace: str, mode: int) -> None:
        """
        Check emitted commands, cue timing, duration and bounded completion.

        :param trace: CSV output from the cycle-counting Z80 harness.
        :param mode: Speech readiness model: immediate, 120 ms, or never ready.
        """
        # CSV tags distinguish S (SID writes), P (speech writes), and the final
        # R (result). Timestamps count emulated CPU cycles, not host wall time.
        rows = [line.split(",") for line in trace.splitlines()]
        speech = [row for row in rows if row[0] == "P"]
        expected_speech = generate._speech_records(generate.speech_cues())
        # A permanently busy card must receive no writes. Other modes must
        # receive every allophone exactly once and in its original order.
        if mode == 2:
            self.assertEqual(speech, [])
        else:
            self.assertEqual(
                [int(row[2]) for row in speech], [code for _, code in expected_speech]
            )
            # Compare in seconds: trace timestamps use the 7.3728 MHz CPU
            # clock, while shared generator records use 25 ms table ticks.
            # Late submission is permitted; submission before a cue is not.
            for row, (tick, _) in zip(speech, expected_speech):
                self.assertGreaterEqual(int(row[1]) / 7372800, tick * 0.025)
        # The result row contains cycles, status, late count and final tick.
        # At the supplied settings, success ends at 11000 * 5 ms (including
        # the tail); a permanently busy card times out at 11600 * 5 ms.
        # These assertions do not claim an exact SP0256 acoustic model.
        self.assertEqual(int(rows[-1][2]), 1 if mode == 2 else 0)
        self.assertEqual(int(rows[-1][4]), 11600 if mode == 2 else 11000)
        # Allow bounded scheduler overhead above the nominal 55/58 seconds.
        # This catches gross delay-loop or clock-conversion errors while not
        # requiring all control-flow paths to consume identical cycle counts.
        elapsed = int(rows[-1][1]) / 7372800
        self.assertGreater(elapsed, 58 if mode == 2 else 55)
        self.assertLess(elapsed, 59.5 if mode == 2 else 56.5)
        sid = [row for row in rows if row[0] == "S"]
        # Startup is 25 cleared registers, three envelopes and volume. Remove
        # those 29 writes and the four cleanup writes to isolate musical events.
        commands = [(int(row[2]), int(row[3])) for row in sid[29:-4]]
        expected_commands = []
        previous_mask = 0
        # Compare actual executed I/O against generator event semantics, with
        # the previous voice mask carried between records. Separate unit tests
        # above check the gate-writing helper with independently stated values.
        for record in generate.music_records():
            expected_commands.extend(generate._sid_writes(record, previous_mask))
            previous_mask = record[4]
        self.assertEqual(commands, expected_commands)
        # Both success and timeout must drop all gates and mute master volume;
        # returning to the caller alone would not stop a hardware SID sounding.
        self.assertEqual(
            [(int(row[2]), int(row[3])) for row in sid[-4:]],
            [(4, 16), (11, 16), (18, 16), (24, 0)],
        )


if __name__ == "__main__":
    unittest.main()
