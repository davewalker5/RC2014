# Emulator support licences

This folder contains material under several licences. The repository's default MIT licence does not override the file-specific licences listed below. This notice also applies when this folder is distributed separately.

## Licence map

| Files                                                                                             | Applicable licence                                                                                |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `local/sidulator.cpp`, `local/sidulator.h`                                                        | GPL-2.0-or-later                                                                                  |
| `local/lcd.cpp`, `local/lcd.h`, `local/lcd_model.cpp`, `local/lcd_model.h`                        | GPL-2.0-or-later                                                                                  |
| `local/digitalio.cpp`, `local/digitalio.h`                                                        | GPL-2.0-or-later                                                                                  |
| `local/speech.cpp`, `local/speech.h`                                                              | GPL-2.0-or-later                                                                                  |
| `tests/digitalio-window.cpp`                                                                      | GPL-2.0-or-later, as stated in its source                                                         |
| `macos-local.patch`                                                                               | GPL-3.0 under the pinned EmulatorKit source's project licence; see [patch provenance](PATCHES.md) |
| `local/lcd_font.h`                                                                                | Adafruit's BSD terms in [local/LICENSE.font](local/LICENSE.font)                                  |
| Other original support files, including scripts, configuration, documentation and remaining tests | [MIT](../LICENSE), except where an individual file states otherwise                               |
| Licence texts and third-party notices                                                             | Retain their original text and notices; they are not relicensed by the repository's MIT licence   |

The full [GPLv2 text](COPYING.libresidfp) is included for the GPL-2.0-or-later components. “Or later” permits use under a later GPL version, including GPLv3. The full [GPLv3 text from EmulatorKit](COPYING.EmulatorKit) is included for the upstream patch. Preserve these texts and the Adafruit notice when redistributing the support bundle.

## Separately downloaded dependencies

- **EmulatorKit:** [EtchedPixels/EmulatorKit](https://github.com/EtchedPixels/EmulatorKit), pinned to `b145b9003d94af73f92cca7f73c0ab1c6be6951d`. Its top-level `COPYING` contains GPLv3. Individual bundled components retain their own notices
- **libresidfp:** [libsidplayfp/libresidfp](https://github.com/libsidplayfp/libresidfp), pinned to `7c54a5988f9f1918439ee1180316a78c7a7729bb` (`v1.2.2`), GPL-2.0-or-later
- **SDL and SDL compatibility libraries:** installed separately. Retain and consult the notices supplied with the versions you use
- **RC2014 firmware:** downloaded separately from [RC2014Z80/RC2014](https://github.com/RC2014Z80/RC2014). Firmware is not included in this bundle and is not granted an MIT licence by this repository
- **SP0256-AL2 allophone recordings:** the optional [sample pack recorded by Sebastian Tomczak](https://little-scale.blogspot.com/2009/02/sp0256-al2-creative-commons-sample-pack.html) is separate from this source bundle. The ZIP's embedded readme states [CC BY-NC 3.0](https://creativecommons.org/licenses/by-nc/3.0/). `prepare-speech-samples.py` retains that readme and writes `SOURCE.txt` beside the local WAV files, identifying their creator, source, licence and the conversion performed

You do not need to add the WAV files to this repository for private local use. This notice documents the optional dependency; it does not relicense the recordings. If you share a build **with** the WAV files, keep the creator credit and licence notice with them and follow the pack's noncommercial terms. Sharing the source bundle without the WAV files does not distribute the recordings.

The licence map describes the distributed support files. It does not make the resulting linked emulator MIT-licensed. Distribution of a built emulator must also satisfy the applicable upstream and linked-library terms, including source-distribution requirements. The documented source-only publication excludes downloaded sources, ROMs and compiled output under `build/`.
