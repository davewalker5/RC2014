# EmulatorKit patch provenance

## Base source and licence

[macos-local.patch](macos-local.patch) modifies [EtchedPixels EmulatorKit](https://github.com/EtchedPixels/EmulatorKit) at commit `b145b9003d94af73f92cca7f73c0ab1c6be6951d`.

The pinned checkout's top-level `COPYING` is reproduced verbatim as [COPYING.EmulatorKit](COPYING.EmulatorKit) (GNU GPL version 3). The patch is distributed under those GPLv3 terms, not the parent repository's MIT licence. Upstream material and any file-specific notices remain attributable to their original authors.

## Local modifications

The following changes were made for this RC2014 support project by Dave Walker. Modification record: **19 September 2026**.

| Upstream file     | Local change                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `Makefile`        | Adds the enhanced `rc2014-sid` target, peripheral object files and SDL/libresidfp build settings while retaining the original target |
| `acia.c`          | Waits for an empty receive register and honours RTS before accepting another input byte                                              |
| `ttycon.c`        | Buffers host input in a growing queue to support long terminal pastes                                                                |
| `ps2event_noui.c` | Removes an unused SDL include from the terminal-only keyboard stub                                                                   |
| `rc2014.c`        | Adds SID, LCD and Digital I/O initialisation, port access, timing, event handling and audio pacing                                   |

The additional peripheral implementations live in `local/`; their licences are listed separately in [LICENSE.md](LICENSE.md). They are copied alongside the upstream checkout rather than embedded in this patch.

Apply the patch once to the pinned clean source, following the [README](README.md). This notice identifies the modifications as local work; they are not an upstream EmulatorKit release. Keep this modification record with the patch and update it when publishing further changes.
