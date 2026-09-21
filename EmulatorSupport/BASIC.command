#!/bin/sh
set -eu
cd "$(dirname "$0")"
printf 'RC2014 Mini II BASIC — press Return at Memory top; Ctrl-\\ exits.\n'
saved_settings=$(stty -g)
trap 'stty "$saved_settings"' EXIT HUP INT TERM
stty -onlcr
. ./sound.conf
. ./display.conf
. ./digitalio.conf
. ./speech.conf
emulator=./bin/rc2014-sid
if [ "$RC2014_SID" = off ] && [ "$RC2014_LCD" = off ] && [ "$RC2014_DIO" = off ] && [ "$RC2014_SPEECH" = off ]; then emulator=./bin/rc2014; fi
"$emulator" -a -r roms/mini-ii-v1.2.bin -e 0
