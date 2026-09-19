#!/usr/bin/env python3
"""Exercise an unchanged LCD BASIC example; capture controller state and pixels."""
import fcntl,json,os,pty,select,subprocess,sys,termios,time
from pathlib import Path
root=Path(__file__).resolve().parents[1]
program=Path(sys.argv[1]).resolve();stem=Path(sys.argv[2]).resolve()
master,slave=pty.openpty()
def session():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
env=dict(os.environ,RC2014_LCD='on',RC2014_SID=os.environ.get('RC2014_SID','off'),RC2014_LCD_DUMP=str(stem)+'.json',RC2014_LCD_SNAPSHOT=str(stem)+'.bmp')
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
 else:time.sleep(4)
 time.sleep(.2)
finally:
 if p.poll() is None:
  os.write(master,b'\x1c')
  try:p.wait(timeout=5)
  except subprocess.TimeoutExpired:p.kill();p.wait();raise
 os.close(master)
d=json.loads(Path(str(stem)+'.json').read_text())
if program.stem=='custom_glyph':
 assert d['rows'][0][:14]==list(b'CUSTOM GLYPH ')+[0],d
 assert d['cgram'][:8]==[14,21,31,31,14,21,21,21],d
elif program.stem=='static_message':
 assert bytes(d['rows'][0])==b'Hello from Mac! ',d
 assert bytes(d['rows'][1])==b' LCD line two   ',d
elif program.stem in ('animated_glyph','moving_glyph'):
 assert d['cgram'][:8]==[14,21,31,31,14,21,21,10],d
 if program.stem=='animated_glyph':assert any(c<8 for c in d['rows'][0]),d
 else:
  # Sampling can land between erasing one cell and drawing the next.
  assert all(c in (0,1,32) for c in d['rows'][0]),d
  assert d['cgram'][8:16]==[14,21,31,31,14,21,21,21],d
elif program.stem=='blinking_message':
 assert bytes(d['rows'][0])==b'Hello from Mac! ',d
print('PASS:',program.name,d)
