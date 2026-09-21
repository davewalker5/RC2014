#!/usr/bin/env python3
"""Add MG005 support to an already patched EmulatorSupport local build."""
from pathlib import Path
import argparse
import shutil

support = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("build", type=Path, help="Folder containing source/, local/ and bin/")
args = parser.parse_args()
build = args.build.resolve()


def replace_once(path: Path, old: str, new: str) -> None:
    content = path.read_text()
    if new in content:
        return
    if content.count(old) != 1:
        raise RuntimeError(f"Unexpected contents in {path}; expected one matching location")
    path.write_text(content.replace(old, new))


def replace_twice(path: Path, old: str, new: str) -> None:
    content = path.read_text()
    if content.count(new) == 2:
        return
    if content.count(old) != 2:
        raise RuntimeError(f"Unexpected contents in {path}; expected two matching locations")
    path.write_text(content.replace(old, new))


makefile = build / "source/Makefile"
rc2014 = build / "source/rc2014.c"
if not makefile.is_file() or not rc2014.is_file() or not (build / "local/sidulator.h").is_file():
    raise SystemExit("Expected an existing patched EmulatorKit build with source/ and local/")

replace_once(makefile,
    "rc2014_sid.o: rc2014.c ../local/sidulator.h ../local/lcd.h ../local/digitalio.h",
    "rc2014_sid.o: rc2014.c ../local/sidulator.h ../local/lcd.h ../local/digitalio.h ../local/speech.h")
replace_once(makefile,
    "rc2014-sid: rc2014_sid.o sidulator.o lcd.o lcd_model.o digitalio.o $(SID_OBJECTS)",
    "speech.o: ../local/speech.cpp ../local/speech.h\n"
    "\t$(CXX) -std=c++17 -O2 -Wall `$(SDL_CONFIG) --cflags` -c ../local/speech.cpp -o $@\n"
    "rc2014-sid: rc2014_sid.o sidulator.o lcd.o lcd_model.o digitalio.o speech.o $(SID_OBJECTS)")
replace_once(makefile,
    "$(CXX) rc2014_sid.o sidulator.o lcd.o lcd_model.o digitalio.o $(SID_OBJECTS)",
    "$(CXX) rc2014_sid.o sidulator.o lcd.o lcd_model.o digitalio.o speech.o $(SID_OBJECTS)")

replace_once(rc2014,
    '#include "../local/sidulator.h"',
    '#include "../local/sidulator.h"\n#include "../local/speech.h"\nstatic int speech_enabled;')
replace_twice(rc2014,
    "if (sid_enabled || lcd_enabled || dio_enabled) {",
    "if (sid_enabled || lcd_enabled || dio_enabled || speech_enabled) {")
replace_once(rc2014,
    "if (lcd_enabled || dio_enabled) {",
    "if (lcd_enabled || dio_enabled || speech_enabled) {")
replace_twice(rc2014,
    "\t\tlcd_advance(cpu_z80.tstates - sid_chunk_cycles);\n"
    "\t\tsidulator_advance(cpu_z80.tstates - sid_chunk_cycles);",
    "\t\tspeech_advance(cpu_z80.tstates - sid_chunk_cycles);\n"
    "\t\tlcd_advance(cpu_z80.tstates - sid_chunk_cycles);\n"
    "\t\tsidulator_advance(cpu_z80.tstates - sid_chunk_cycles);")
replace_once(rc2014,
    "digitalio_write(addr, val) || lcd_write(addr, val) || sidulator_write(addr, val)",
    "digitalio_write(addr, val) || lcd_write(addr, val) || speech_write(addr, val) || sidulator_write(addr, val)")
replace_once(rc2014,
    "digitalio_read(addr, &value) || lcd_read(addr, &value)",
    "digitalio_read(addr, &value) || lcd_read(addr, &value) || speech_read(addr, &value)")
speech_off = 'strcmp(getenv("RC2014_SPEECH") ? getenv("RC2014_SPEECH") : "off", "off")) &&'
speech_on = 'strcmp(getenv("RC2014_SPEECH") ? getenv("RC2014_SPEECH") : "on", "off")) &&'
if speech_off in rc2014.read_text():
    replace_once(rc2014, speech_off, speech_on)
replace_once(rc2014,
    'strcmp(getenv("RC2014_DIO") ? getenv("RC2014_DIO") : "off", "off")) &&',
    'strcmp(getenv("RC2014_DIO") ? getenv("RC2014_DIO") : "off", "off") ||\n'
    '\t     ' + speech_on)
replace_once(rc2014,
    "SID/LCD/Digital I/O require", "SID/LCD/Digital I/O/MG005 require")
replace_once(rc2014,
    "\tdio_enabled = digitalio_init();", "\tdio_enabled = digitalio_init();\n\tspeech_enabled = speech_init();")
replace_once(rc2014,
    "\t\t\t\t\tsidulator_advance(cpu_z80.tstates - sid_chunk_cycles);",
    "\t\t\t\t\tspeech_advance(cpu_z80.tstates - sid_chunk_cycles);\n"
    "\t\t\t\t\tsidulator_advance(cpu_z80.tstates - sid_chunk_cycles);")

for name in ("BASIC.command", "SCM.command", "speech.conf", "macos-local.patch"):
    shutil.copy2(support / name, build / name)
for name in ("speech.cpp", "speech.h"):
    shutil.copy2(support / "local" / name, build / "local" / name)
shutil.copy2(support / "tests/speech-smoke.cpp", build / "tests/speech-smoke.cpp")
print(f"MG005 source and configuration installed in {build}")
