#!/usr/bin/env python3
"""Convert Sebastian Tomczak's SP0256-AL2 WAV pack for the MG005 emulator."""
from io import BytesIO
from pathlib import Path
import argparse
import hashlib
import wave
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("archive", type=Path, help="Original little-scale_SP0256-AL2.zip")
parser.add_argument("output", type=Path, help="Destination speech-samples directory")
args = parser.parse_args()

expected_sha256 = "f7752bf8642e867e6b230e40e3511900ce3b1dca92f2a25771ab697b82d83cbb"
archive_bytes = args.archive.read_bytes()
if hashlib.sha256(archive_bytes).hexdigest() != expected_sha256:
    raise SystemExit("Archive hash differs from the verified original; check the source before using it")

names = (
    "OY AY EH KK3 PP JH NN1 IH TT2 RR1 AX MM TT1 DH1 IY EY DD1 UW1 AO AA "
    "YY2 AE HH1 BB1 TH UH UW2 AW DD2 GG3 VV GOT SH ZH RR2 FF KK2 KK1 ZZ NG "
    "LL WW XR WH YY1 CH ER1 ER2 OW DH2 SS NN2 HH2 OR AR YR GG2 EL BB2"
).split()
assert len(names) == 59
prefix = "little-scale_SP0256-AL2/"
with zipfile.ZipFile(BytesIO(archive_bytes)) as archive:
    samples = []
    for name in names:
        data = archive.read(prefix + name + ".wav")
        with wave.open(BytesIO(data)) as wav:
            if wav.getnchannels() != 1 or wav.getsampwidth() != 2 or wav.getframerate() != 44100:
                raise SystemExit(f"Unexpected audio format for {name}.wav")
        samples.append(data)
    notice = archive.read(prefix + "00_read_me.pdf")

destination = args.output.resolve()
destination.mkdir(parents=True, exist_ok=True)
for code, milliseconds in enumerate((10, 30, 50, 100, 200)):
    buffer = BytesIO()
    with wave.open(buffer, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(44100)
        wav.writeframes(b"\0\0" * (44100 * milliseconds // 1000))
    (destination / f"{code:02}.wav").write_bytes(buffer.getvalue())
for code, data in enumerate(samples, 5):
    (destination / f"{code:02}.wav").write_bytes(data)
(destination / "00_read_me.pdf").write_bytes(notice)
(destination / "SOURCE.txt").write_text(
    "SP0256-AL2 allophones recorded by Sebastian Tomczak (little-scale).\n"
    "Original post: https://little-scale.blogspot.com/2009/02/sp0256-al2-creative-commons-sample-pack.html\n"
    "Archived original ZIP: https://web.archive.org/web/20180331044917id_/http://milkcrate.com.au/_other/downloads/sample_sets/little-scale_SP0256-AL2.zip\n"
    f"ZIP SHA-256: {expected_sha256}\n"
    "The ZIP's embedded readme states Creative Commons BY-NC 3.0. Retained as 00_read_me.pdf.\n"
    "Files 05.wav–63.wav are renamed originals; 00.wav–04.wav are generated silence.\n"
    "The pack names GG1 as GOT.wav (example word 'Got'); it is mapped to code 36.\n"
)
print(f"Prepared 64 SP0256 allophone/pause files in {destination}")
