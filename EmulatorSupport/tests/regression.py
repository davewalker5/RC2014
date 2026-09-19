#!/usr/bin/env python3
"""Check long BASIC pastes with SID pacing, plus silent and SCM boot modes."""
import fcntl, os, pty, select, subprocess, termios, threading, time
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def run(bank,model,check):
    master,slave=pty.openpty()
    def session():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
    p=subprocess.Popen([str(root/'bin/rc2014-sid'),'-a','-r',str(root/'roms/mini-ii-v1.2.bin'),'-e',str(bank)],
        stdin=slave,stdout=slave,stderr=slave,preexec_fn=session,
        env=dict(os.environ,RC2014_SID=model,SDL_AUDIODRIVER='dummy',RC2014_SID_OUTPUT='audio'))
    os.close(slave)
    def until(marker,timeout=90):
        data=b'';end=time.monotonic()+timeout
        while time.monotonic()<end:
            if select.select([master],[],[],.1)[0]:data+=os.read(master,65536)
            if marker in data:return data
        raise RuntimeError((marker,data[-500:]))
    def send(data):
        while data:data=data[os.write(master,data):]
    try:check(until,send)
    finally:
        os.write(master,b'\x1c')
        try:p.wait(timeout=5)
        except subprocess.TimeoutExpired:p.kill();p.wait();raise
        os.close(master)

def basic(until,send):
    until(b'Memory top?');send(b'\r');until(b'Ok')
    send(b'LINES 1000\r');until(b'Ok')
    lines=[f'{i*10} REM PASTE TEST LINE {i:03d} ABCDEFGHIJKLMNOPQRSTUVWXYZ' for i in range(1,401)]
    lines+=['4010 PRINT "PASTE COMPLETE"']
    payload=('\r'.join(lines)+'\rLIST\r').encode()
    writer=threading.Thread(target=send,args=(payload,),daemon=True);writer.start()
    output=until(b'Ok').replace(b'\r',b'').decode();writer.join(1)
    assert not writer.is_alive()
    assert all(output.count(line)==2 for line in lines),'Missing/duplicate program line'
    send(b'RUN\r');assert b'PASTE COMPLETE' in until(b'Ok')
    print(f'PASS: {len(lines)} lines / {len(payload)} bytes pasted, listed and run with SID audio pacing')
def scm(until,send):
    until(b'*');send(b'HELP\r');assert b'configuration R1' in until(b'\n*')
    print('PASS: SCM with SID enabled')
def silent(until,send):
    until(b'Memory top?');send(b'\r');assert b'31948 Bytes free' in until(b'Ok')
    print('PASS: SID disabled')
run(0,'8580',basic);run(14,'8580',scm);run(0,'off',silent)
