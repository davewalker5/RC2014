#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ ! -f sid-prefix/lib/libresidfp.a ]; then
    echo 'Build libresidfp first; see the project brief.' >&2
    exit 1
fi
make -C source rc2014 rc2014-sid CFLAGS='-Wall -g3 -O2 -DSOL_TCP=IPPROTO_TCP -I../include'
mkdir -p bin
cp source/rc2014 bin/rc2014
cp source/rc2014-sid bin/rc2014-sid
