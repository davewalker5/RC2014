#!/usr/bin/env python3
"""Run an existing BASIC listing through the real emulator and capture its audio."""
import os, pty, select, subprocess, sys, time, fcntl, termios, signal
from pathlib import Path
root=Path(__file__).resolve().parents[1]
program=Path(sys.argv[1]).resolve()
recording=Path(sys.argv[2]).resolve()
completion=sys.argv[3].encode()
master,slave=pty.openpty()
env=dict(os.environ,RC2014_SID=os.environ.get('RC2014_SID','8580'),
         RC2014_SID_OUTPUT=os.environ.get('RC2014_SID_OUTPUT','wav'),RC2014_SID_WAV=str(recording))
def terminal_session():
    os.setsid()
    fcntl.ioctl(slave,termios.TIOCSCTTY,0)
p=subprocess.Popen([str(root/'bin/rc2014-sid'),'-a','-r',str(root/'roms/mini-ii-v1.2.bin'),'-e','0'],stdin=slave,stdout=slave,stderr=slave,env=env,preexec_fn=terminal_session)
os.close(slave)
def until(marker,timeout=90):
    output=b'';end=time.monotonic()+timeout
    while time.monotonic()<end:
        if select.select([master],[],[],.1)[0]:
            try: output+=os.read(master,65536)
            except OSError: break
        if marker in output:return output
        if p.poll() is not None: break
    raise RuntimeError(f'Expected {marker!r}: {output[-1500:]!r}')
try:
    print(until(b'Memory top?').decode(errors='replace'))
    os.write(master,b'\r');until(b'Ok')
    # Individual lines with modest pacing keep this audio test focused on sound.
    for line in program.read_text().splitlines():
        if line.strip():
            os.write(master,line.encode()+b'\r');until(line.encode(),10)
    os.write(master,b'RUN\r')
    result=until(completion);print(result.decode(errors='replace')[-600:])
    time.sleep(.4)
finally:
    if p.poll() is None:
        os.write(master,b'\x1c')
        try:p.wait(timeout=5)
        except subprocess.TimeoutExpired:
            p.kill();p.wait()
            raise RuntimeError('Emulator did not exit on Control-backslash')
    os.close(master)
print(recording)
