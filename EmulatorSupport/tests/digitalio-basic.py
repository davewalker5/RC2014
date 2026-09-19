#!/usr/bin/env python3
"""Run an existing Digital I/O BASIC example and check its output latch."""
import fcntl,json,os,pty,select,subprocess,sys,termios,time
from pathlib import Path
root=Path(__file__).resolve().parents[1]
program=Path(sys.argv[1]).resolve();stem=Path(sys.argv[2]).resolve()
master,slave=pty.openpty()
def session():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
env=dict(os.environ,RC2014_LCD='on',RC2014_DIO='on',RC2014_DIO_DUMP=str(stem)+'.dio.json',RC2014_SID=os.environ.get('RC2014_SID','off'),RC2014_LCD_DUMP=str(stem)+'.json',RC2014_LCD_SNAPSHOT=str(stem)+'.bmp')
p=subprocess.Popen([str(root/'bin/rc2014-sid'),'-a','-r',str(root/'roms/mini-ii-v1.2.bin'),'-e','0'],stdin=slave,stdout=slave,stderr=slave,preexec_fn=session,env=env)
os.close(slave)
def until(marker,timeout=30):
 output=b'';end=time.monotonic()+timeout
 while time.monotonic()<end:
  if select.select([master],[],[],.1)[0]:
   try:output+=os.read(master,65536)
   except OSError:break
  if marker in output:return output
 raise RuntimeError((marker,output[-1000:]))
try:
 print(until(b'Memory top?').decode(errors='replace'))
 os.write(master,b'\r');until(b'Ok')
 for line in program.read_text().splitlines():
  os.write(master,line.encode()+b'\r');until(line.encode())
 os.write(master,b'RUN\r')
 if 'INPUT' in program.read_text():
  until(b'?');os.write(master,b'Hello from Mac!  LCD line two\r')
 if program.stem in ('custom_glyph','static_message'):until(b'Ok')
 else:until(b'0 0 |');time.sleep(.2)
 time.sleep(.2)
finally:
 if p.poll() is None:
  os.write(master,b'\x1c')
  try:
   end=time.monotonic()+5
   while p.poll() is None and time.monotonic()<end:
    if select.select([master],[],[],.1)[0]:
     try:os.read(master,65536)
     except OSError:break
   p.wait(timeout=1)
  except subprocess.TimeoutExpired:p.kill();p.wait();raise
 os.close(master)
d=json.loads(Path(str(stem)+'.dio.json').read_text())
assert d == {'input':0, 'output':24},d
print('PASS: unchanged logic_io.bas, no inputs -> NOT-A and NOT-B LEDs',d)
