# RC2014 emulator support

Source patches, peripheral emulation, build scripts and launchers for a local desktop RC2014 emulator based on [EtchedPixels EmulatorKit](https://github.com/EtchedPixels/EmulatorKit).

This directory contains **support source and instructions, not a prebuilt emulator**. Download the upstream emulator, SID library and official firmware separately, then build for your machine.

## Features

- Microsoft BASIC 4.7c and Small Computer Monitor (SCM), using separate Mini II ROM boot profiles
- Reliable long program pastes through ACIA flow control and a growing host input queue
- SID-Ulator-style sound through libresidfp, with host playback and optional WAV recording
- A separate HD44780-compatible 16×2 LCD window, including custom glyphs
- A Digital I/O window with eight buttons, eight LEDs and optional latched inputs

Interaction stays in Terminal; peripheral windows belong to the same emulator process. No browser or physical RC2014 is required.

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/lcd-preview.png" alt="LCD Window">

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/digitalio-preview.png" alt="Digital I/O Window">

## Platform support

The supplied scripts have been tested on **Apple Silicon macOS Tahoe 26.6.2**, using Apple's compiler and Homebrew SDL2 compatibility libraries. This is the tested configuration, not a claim that macOS Tahoe is the minimum supported version.

Intel Macs and other macOS releases need their own native build and validation. Linux is a potential port: the code uses C/C++17, SDL2, POSIX terminals and Autotools, but the supplied build flags and launch workflow were prepared for macOS. Native Windows is not supported by these instructions. See [adapting to another machine](#adapting-to-another-machine).

## Files in this bundle

| File                                                                                     | Purpose                                                                            |
| ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [macos-local.patch](macos-local.patch)                                                   | Serial fixes, peripheral hooks and build rules for the pinned EmulatorKit revision |
| [local/](local/)                                                                         | SID, LCD and Digital I/O implementations, interfaces and bitmap font               |
| [build-sid-library.command](build-sid-library.command)                                   | Builds and locally installs static libresidfp                                      |
| [build.command](build.command)                                                           | Builds the original `rc2014` and enhanced `rc2014-sid` executables                 |
| [BASIC.command](BASIC.command), [SCM.command](SCM.command)                               | Terminal setup, configuration loading and ROM-bank selection                       |
| [sound.conf](sound.conf), [display.conf](display.conf), [digitalio.conf](digitalio.conf) | Peripheral defaults, overridable through environment variables                     |
| [tests/](tests/)                                                                         | Controller, window, audio and BASIC/SCM checks                                     |
| [COPYING.libresidfp](COPYING.libresidfp), [local/LICENSE.font](local/LICENSE.font)       | Included third-party license texts                                                 |

The enhanced executable retains the name `rc2014-sid`, although it supports all three peripherals. The original executable has no SDL dependency.

## Build on macOS

Run the following steps in order, in the same Terminal session. Start **in the directory containing this README**: `EmulatorSupport/` if you cloned the full RC2014 project, or the repository root if you downloaded this bundle separately. Use a fresh `build/` directory; keep an existing installation separately when trying a new build.

### 1. Install prerequisites

Install Apple's Command Line Tools if needed:

```sh
xcode-select --install
```

Complete the installation before continuing. With [Homebrew](https://brew.sh/) installed and available in your `PATH`, install the remaining tools:

```sh
brew install sdl2-compat autoconf automake libtool autoconf-archive python
```

The tested SDL installation was `sdl2-compat` (SDL2 API 2.32.70 backed by SDL3). The build obtains include and library flags from `sdl2-config`; it does not hardcode `/opt/homebrew` or `/usr/local`.

Check that the tools are available:

```sh
xcrun --find clang
git --version
make --version
python3 --version
sdl2-config --version
autoreconf --version
```

### 2. Prepare a local build directory

From the directory containing this README:

```sh
mkdir build
cp *.command *.conf macos-local.patch build/
cp -R local tests build/
cd build
mkdir -p bin roms
chmod +x *.command
```

**All subsequent commands run from `build/`**, unless stated otherwise. The supplied `.gitignore` excludes this folder, including downloaded sources, firmware, binaries and test output.

### 3. Download pinned sources

These revisions reproduce the source versions used for the tested build. Newer upstream revisions may require patch changes.

| Component                                                                  | Revision                                              |
| -------------------------------------------------------------------------- | ----------------------------------------------------- |
| [EmulatorKit](https://github.com/EtchedPixels/EmulatorKit)                 | `b145b9003d94af73f92cca7f73c0ab1c6be6951d`            |
| [Official RC2014 firmware repository](https://github.com/RC2014Z80/RC2014) | `f5579dd14c0f46bba51544d64c1d4c8d5fed9a5c`            |
| [libresidfp](https://github.com/libsidplayfp/libresidfp)                   | `7c54a5988f9f1918439ee1180316a78c7a7729bb` (`v1.2.2`) |

```sh
git clone https://github.com/EtchedPixels/EmulatorKit.git source
git -C source checkout --detach b145b9003d94af73f92cca7f73c0ab1c6be6951d

git clone https://github.com/RC2014Z80/RC2014.git firmware-source
git -C firmware-source checkout --detach f5579dd14c0f46bba51544d64c1d4c8d5fed9a5c
cp 'firmware-source/ROMs/Factory/Mini II v1.2.HEX' roms/

git clone https://github.com/libsidplayfp/libresidfp.git libresidfp
git -C libresidfp checkout --detach 7c54a5988f9f1918439ee1180316a78c7a7729bb
```

Full clones allow checkout of the pinned historical commits. Firmware remains subject to its owners' terms; it is downloaded rather than included in this bundle.

### 4. Apply the patch and build libresidfp

```sh
git -C source apply --check ../macos-local.patch
git -C source apply ../macos-local.patch
./build-sid-library.command
```

Apply the patch **once** to the clean pinned checkout. The library script runs Autotools, configures a static-only library and installs it under `build/sid-prefix/`, without a global installation or `sudo`. The emulator links this library statically and SDL dynamically. Keep SDL installed after building.

### 5. Convert the firmware

The emulator expects a flat **128 KiB** ROM image. Run this Python converter from `build/`; it checks Intel HEX record lengths/checksums and fills unused addresses with `FF`.

```sh
python3 - <<'PYROM'
from pathlib import Path

source = Path('roms/Mini II v1.2.HEX')
output = bytearray([0xFF]) * (128 * 1024)
base = 0
eof = False
for line_number, line in enumerate(source.read_text().splitlines(), 1):
    line = line.strip()
    if not line:
        continue
    if eof or not line.startswith(':'):
        raise ValueError(f'Unexpected record at line {line_number}')
    record = bytes.fromhex(line[1:])
    if len(record) < 5 or len(record) != record[0] + 5:
        raise ValueError(f'Invalid record length at line {line_number}')
    if sum(record) & 0xFF:
        raise ValueError(f'Invalid checksum at line {line_number}')
    count = record[0]
    address = int.from_bytes(record[1:3], 'big')
    kind = record[3]
    data = record[4:4 + count]
    if kind == 0:
        start = base + address
        if start + count > len(output):
            raise ValueError(f'ROM address out of range at line {line_number}')
        output[start:start + count] = data
    elif kind == 1:
        if count != 0:
            raise ValueError('Invalid EOF record')
        eof = True
    elif kind in (2, 4):
        if count != 2:
            raise ValueError('Invalid extended-address record')
        base = int.from_bytes(data, 'big') << (4 if kind == 2 else 16)
    else:
        raise ValueError(f'Unsupported record type {kind}')
if not eof:
    raise ValueError('Missing EOF record')
destination = Path('roms/mini-ii-v1.2.bin')
destination.write_bytes(output)
print(f'Wrote {len(output)} bytes to {destination}')
PYROM

shasum -a 256 'roms/Mini II v1.2.HEX' roms/mini-ii-v1.2.bin
```

Expected SHA-256 values:

```text
18bcf33307ba878dbbde84eb1aad60905e6e2826086b63a29c9e6520d8a586e1  Mini II v1.2.HEX
350c386a98e0d251f905c4033c8d210d14eb178ee36a2ede6636013a99f51f4c  mini-ii-v1.2.bin
```

The HEX hash includes line endings; the binary hash checks the actual converted ROM contents.

### 6. Build and launch

```sh
./build.command
file bin/rc2014 bin/rc2014-sid
./BASIC.command
```

On Apple Silicon, both executables should report `arm64`. At BASIC's `Memory top?` prompt, press Return. Expect `31948 Bytes free` and `Ok`.

To use SCM instead, exit the emulator with **Ctrl-\** and run:

```sh
./SCM.command
```

Type `HELP` at its `*` prompt. BASIC uses ROM bank 0; SCM uses bank 14 (configuration R1). These are separate launch profiles; this SCM profile does not start BASIC internally.

## Everyday use

Type and paste in **Terminal**, not the peripheral windows. Paste a plain-text BASIC listing, then enter `RUN`. Use `NEW` before loading another program. Save your listings separately: the launchers do not persist RAM between sessions.

```basic
10 PRINT "HELLO FROM THE MAC"
20 GOTO 10
RUN
```

Ctrl-C interrupts a running BASIC program; Ctrl-\ exits the emulator. The launchers restore terminal settings on exit. Use `LINES 1000` before listing a long program if BASIC's default pagination appears to stop output.

The paste patch waits for the emulated ACIA to accept each byte and buffers incoming host input. This favours reliable interactive pasting over reproducing physical serial overruns; no paste-delay setting is needed.

## Configuration

Edit the `.conf` copies in `build/` for your installation. They are shell files sourced by both launchers. Environment overrides take precedence. All port settings below use **decimal** numbers.

### SID sound

| Variable            | Launcher default | Accepted values / meaning                            |
| ------------------- | ---------------- | ---------------------------------------------------- |
| `RC2014_SID`        | `8580`           | `8580`, `6581`, or `off`                             |
| `RC2014_SID_CLOCK`  | `1000000`        | Integer SID clock in Hz, 900000–1100000              |
| `RC2014_SID_PORT`   | `212`            | Register port: 212, 164, 84 or 36; data port is +1   |
| `RC2014_SID_GAIN`   | `0.5`            | Host gain, 0–1                                       |
| `RC2014_SID_OUTPUT` | `audio`          | `audio`, `wav`, or `both`                            |
| `RC2014_SID_WAV`    | Unset            | New recording filename; required for `wav` or `both` |

Default ports are D4/D5. Recording uses 48 kHz mono 16-bit PCM and refuses to overwrite an existing file. Exit normally to finalise its header.

```sh
RC2014_SID=6581 ./BASIC.command
RC2014_SID_OUTPUT=both RC2014_SID_WAV="$PWD/session.wav" ./BASIC.command
```

### LCD window

| Variable              | Launcher default | Accepted values / meaning                                |
| --------------------- | ---------------- | -------------------------------------------------------- |
| `RC2014_LCD`          | `on`             | `on` or `off`                                            |
| `RC2014_LCD_PORT`     | `218`            | Command/status port: 218, 170, 90 or 42; data port is +1 |
| `RC2014_LCD_DUMP`     | Unset            | New JSON filename for final controller state             |
| `RC2014_LCD_SNAPSHOT` | Unset            | New BMP filename for a final rendered snapshot           |

The default DA/DB ports match the RC2014 LCD module. The display supports DDRAM, custom glyphs in CGRAM, cursor/blink, display shifting and busy-status reads. Closing the window hides it while emulation continues; restart to show it again. Diagnostics are written on normal exit.

### Digital I/O window

| Variable                 | Launcher default | Accepted values / meaning                      |
| ------------------------ | ---------------- | ---------------------------------------------- |
| `RC2014_DIO`             | `on`             | `on` or `off`                                  |
| `RC2014_DIO_INPUT_PORT`  | `1`              | Input port, 0–3                                |
| `RC2014_DIO_OUTPUT_PORT` | `1`              | Output port, 0–3                               |
| `RC2014_DIO_DUMP`        | Unset            | New JSON filename for final input/output bytes |

Input and output ports are independent. Port 1 matches the programs in the parent RC2014 project; configure both to 0 for software that expects the hardware's usual port 0.

- Hold a numbered button with the mouse, or hold keys **0–7** while the panel has focus.
- Click **HOLD** to latch inputs and combine buttons. Click again to release.
- Press **Space** in the panel to release all inputs.
- Moving focus releases momentary input; HOLD selections remain set.
- Closing the panel releases all inputs and hides only that window.

Bits run from 7 to 0, left to right. `OUT 1,165` lights LEDs 7, 5, 2 and 0. `PRINT INP(1)` reads the active-high button byte. To mirror the buttons onto the LEDs:

```basic
10 OUT 1,INP(1)
20 GOTO 10
RUN
```

### Disable peripherals

```sh
# Keep windows, disable sound:
RC2014_SID=off ./BASIC.command
# Disable Digital I/O only:
RC2014_DIO=off ./BASIC.command
# Use the original terminal-only executable:
RC2014_SID=off RC2014_LCD=off RC2014_DIO=off ./BASIC.command
```

All three features default to off when invoking `bin/rc2014-sid` directly; the launchers enable them through configuration. Disabling them at runtime does not remove the enhanced binary's library dependencies.

## Check your build

Run from `build/`. The tests below are self-contained within this bundle plus the downloaded firmware and libraries. Python tests use the standard library and POSIX pseudo-terminals. Dummy SDL drivers allow automated checks without playing audio or opening windows.

```sh
mkdir -p test-output
c++ -std=c++17 -Wall tests/lcd-model.cpp local/lcd_model.cpp -o test-output/lcd-model
./test-output/lcd-model

c++ -std=c++17 -Wall $(sdl2-config --cflags) tests/digitalio-window.cpp local/lcd.cpp local/lcd_model.cpp $(sdl2-config --libs) -o test-output/digitalio-window
SDL_VIDEODRIVER=dummy ./test-output/digitalio-window

RC2014_DIO=on RC2014_LCD=on SDL_VIDEODRIVER=dummy python3 tests/regression.py

c++ -std=c++17 tests/sid-smoke.cpp source/sidulator.o sid-prefix/lib/libresidfp.a $(sdl2-config --libs) -o test-output/sid-smoke
RC2014_SID=8580 RC2014_SID_OUTPUT=wav RC2014_SID_WAV="$PWD/test-output/sid-8580.wav" ./test-output/sid-smoke
python3 tests/check-sid-wave.py test-output/sid-8580.wav
```

Choose a new WAV filename for each run. Repeat the audio check with `RC2014_SID=6581` and another filename to test that model. Omit `SDL_VIDEODRIVER=dummy` from the window test to open native windows briefly; also launch BASIC normally to check your actual audio device and desktop interaction.

The regression checks a 401-line paste/LIST/RUN, SCM boot and sound-disabled BASIC. The window test covers input combinations, focus changes, port handling and LCD coexistence; the sound check covers pitch, duration, voices, noise, muting and clipping. These checks passed on the recorded macOS configuration, along with a clean build from the pinned upstream source and patch. They do not establish support for other platforms.

`basic-sid.py`, `lcd-basic.py` and `digitalio-basic.py` are additional integration runners for specific BASIC examples in the parent project's `Programs/` tree. Those example files are **not part of this standalone bundle**. In particular, the Digital I/O runner expects `logic_io.bas` and its initial output of 24; these runners are not general-purpose test tools for arbitrary listings.

## Adapting to another machine

Build natively for the target architecture, with matching compiler and library architectures. The `.command` files are POSIX shell scripts; on systems without Finder integration, invoke them from a terminal.

The current [build script](build.command) passes these flags:

| Flag                    | Reason                                                                         |
| ----------------------- | ------------------------------------------------------------------------------ |
| `-Wall -g3 -O2`         | Compiler warnings, debug information and optimisation                          |
| `-DSOL_TCP=IPPROTO_TCP` | macOS compatibility for upstream debugger socket code                          |
| `-I../include`          | Retains the bundled floppy library include path when overriding upstream flags |

For a Linux port, review/remove the macOS `SOL_TCP` override and install your distribution's C/C++ compiler, Make, Git, Python 3, SDL2 development package and Autotools (including autoconf-archive). This is guidance for adapting the build, not a tested Linux recipe. Upstream's strict `-pedantic -Werror` defaults are omitted because Apple's compiler rejected a variadic-macro extension; upstream warnings may still occur.

The patched Makefile exposes `SDL_CONFIG` and `SID_PREFIX`, defaulting to `sdl2-config` and `../sid-prefix`. If your SDL tools or library prefix differ, adapt the build invocation accordingly. After changing toolchains or architectures, start with a fresh build directory to avoid reusing incompatible object files. If you move the installation and need to rebuild, rerun the library build script to update its absolute installation prefix.

To build **only the terminal emulator**, apply the patch and prepare the ROM as above, then run the following instead of the library and enhanced build steps:

```sh
make -C source rc2014 CFLAGS='-Wall -g3 -O2 -DSOL_TCP=IPPROTO_TCP -I../include'
cp source/rc2014 bin/rc2014
RC2014_SID=off RC2014_LCD=off RC2014_DIO=off ./BASIC.command
```

This macOS-only command needs no SDL or libresidfp; the supplied `build.command` intentionally builds both targets and therefore requires them.

## Limitations and troubleshooting

- Peripheral timing assumes the default 7.3728 MHz Z80 board. Enabled peripherals reject fast mode, alternate CPU boards and GDB mode
- SID synthesis approximates the hardware SID-Ulator/SwinSID sound. There is no SID readback, paddle input, second SID or C64 `.sid` file player. Only the default D4/D5 mapping has end-to-end validation; alternate ports can overlap other emulated devices
- LCD support is fixed at 16×2, 8-bit transfers and 5×8 glyphs. Four-bit mode, 5×10 fonts, exact power-on timing and the physical data-read prefetch pipeline are not modelled. The built-in font differs from some original LCD character ROMs
- Digital I/O represents one card, starts with zero outputs and omits switch bounce and external electrical signals. Roughly 20 ms refresh and host input scheduling make it unsuitable for precise reaction-time measurements; short LED pulses may not be visible
- MIDI, Compact Flash and other expansion devices have not been configured or validated by these launch profiles

| Symptom                                              | Check                                                                                          |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Patch fails or is already applied                    | Use the pinned clean EmulatorKit revision; do not apply twice                                  |
| `sdl2-config` or `autoreconf` missing                | Install the prerequisites and check your shell's `PATH`                                        |
| Architecture/linker errors                           | Build all dependencies for the same architecture                                               |
| No sound or window                                   | Check `.conf` settings and run in a normal desktop Terminal with access to audio/video devices |
| BASIC listing pauses                                 | Set `LINES 1000`; distinguish pagination from missing program lines                            |
| Cannot create WAV/dump                               | Choose a writable, previously unused filename                                                  |
| Terminal settings remain altered after a forced exit | Run `stty sane` in Terminal                                                                    |

## Attribution and licences

**This folder has mixed licensing.** See [LICENSE.md](LICENSE.md) for the file-by-file licence map and [PATCHES.md](PATCHES.md) for the EmulatorKit patch's origin and modification record. The parent repository's MIT licence does not override these exceptions.

The peripheral support combines custom code written for this project with existing libraries:

| Component       | Custom implementation                                                                                   | External code                                                                   |
| --------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **LCD**         | Controller model, memory/register handling, timing, port adapter and display rendering                  | SDL provides the window; Adafruit's bitmap font supplies ordinary characters    |
| **Digital I/O** | Port handling, input/output state, buttons, LEDs and interaction                                        | SDL provides windowing, drawing and input events; labels use the Adafruit font  |
| **SID-Ulator**  | RC2014 register-port adapter, clock conversion, audio buffering, playback integration and WAV recording | **libresidfp performs the actual SID sound synthesis**; SDL provides host audio |

The LCD and Digital I/O behaviour was implemented from the hardware's documented interfaces, rather than copied from another emulator. The SID-Ulator support connects an existing SID synthesis engine to the RC2014 emulator; it does not implement a new SID synthesis engine.

The underlying Z80/RC2014 emulator is **EtchedPixels EmulatorKit**, with local patches for serial input, peripheral integration and building on macOS. This project therefore provides custom peripheral support built on existing emulation and multimedia libraries.

EmulatorKit, official firmware and libresidfp are separate upstream projects; their files retain their own copyright and license notices. The local SID, LCD and Digital I/O implementations identify themselves as GPL-2.0-or-later. The bundle includes the [GPLv2 text distributed with libresidfp](COPYING.libresidfp) and the [GPLv3 text from the pinned EmulatorKit source](COPYING.EmulatorKit). The EmulatorKit patch follows its upstream GPLv3 terms.

The bitmap font is adapted from Adafruit GFX's classic font and retains its [BSD license notice](local/LICENSE.font). Keep that notice with the font. The support bundle does not relicense upstream code or firmware; consult each downloaded project's notices for its terms.
