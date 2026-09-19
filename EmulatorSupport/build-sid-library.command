#!/bin/sh
set -eu
cd "$(dirname "$0")"
prefix="$PWD/sid-prefix"
cd libresidfp
autoreconf -vfi
./configure --disable-shared --enable-static --disable-tests --prefix="$prefix"
make -j4
make install
