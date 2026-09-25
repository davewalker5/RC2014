#!/usr/bin/env python3
"""Check real SerialSender output over a Unix pseudo-terminal, without hardware."""

import argparse
import os
import pty
import select
import subprocess
import time
import tty
from pathlib import Path
from tempfile import TemporaryDirectory


def verify_serial_bytes(sender: Path) -> None:
    """
    Send two HEX records through the actual port wrapper and compare every byte.

    :param sender: Built SerialSender executable, or DLL to launch with dotnet.
    :raises AssertionError: Extra/missing bytes or a reported sender error occur.
    :raises TimeoutError: The sender does not finish within ten seconds.
    :raises OSError: The executable or pseudo-terminal cannot be accessed.
    """
    records = [":01E00000C956", ":00000001FF"]
    expected = "\r\n".join(records).encode("ascii") + b"\r\n"
    command = [str(sender.resolve())]
    if sender.suffix.lower() == ".dll":
        command.insert(0, "dotnet")
    master, slave = pty.openpty()
    process = None
    try:
        tty.setraw(slave)
        with TemporaryDirectory() as directory:
            source = Path(directory) / "sample.hex"
            source.write_text("\n".join(records) + "\n", encoding="ascii")
            command.extend(
                [
                    "--send",
                    str(source),
                    "--port",
                    os.ttyname(slave),
                    "--sendreset",
                    "false",
                    "--blockdelay",
                    "0",
                    "--linedelay",
                    "0",
                    "--lineending",
                    "\r\n",
                ]
            )
            process = subprocess.Popen(
                command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
            )
            received = bytearray()
            deadline = time.monotonic() + 10
            while True:
                if time.monotonic() > deadline:
                    raise TimeoutError("SerialSender did not finish within ten seconds")
                if select.select([master], [], [], 0.1)[0]:
                    received.extend(os.read(master, 65536))
                elif process.poll() is not None:
                    break
            output = process.communicate(timeout=1)[0].decode(errors="replace")
            # The current CLI catches exceptions, so exit status alone is not
            # sufficient to detect a serial-port opening or writing failure.
            assert process.returncode == 0 and "Error:" not in output, output
            assert received == expected, (
                f"Expected {expected!r}; received {bytes(received)!r}"
            )
    finally:
        if process is not None and process.poll() is None:
            process.kill()
            process.wait()
        os.close(master)
        os.close(slave)


def main() -> None:
    """Read the executable path and report the byte-level regression result."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "sender", type=Path, help="built SerialSender executable or DLL"
    )
    args = parser.parse_args()
    verify_serial_bytes(args.sender)
    print("PASS: exact HEX bytes, with one configured line ending per record")


if __name__ == "__main__":
    main()
