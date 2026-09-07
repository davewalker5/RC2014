10 REM Rodeo Rumble - filtered cartoon mm-OO-oo
20 RP=212:DP=213:NS=3:DL=40
30 VL=8:RL=9:AT=7:GP=5000
40 FL=1100:FH=1400:FE=950:FS=25
50 CL=120:CH=420:CM=300:RE=8
60 REM Clear SID; one pulse voice through resonant low-pass filter
70 FOR R=0 TO 24
80 OUT RP,R:OUT DP,0
90 NEXT R
100 OUT RP,2:OUT DP,0
110 OUT RP,3:OUT DP,6:REM Fixed pulse width, no random timbre jumps
120 OUT RP,5:OUT DP,AT*16
130 OUT RP,6:OUT DP,240+RL
140 OUT RP,23:OUT DP,RE*16+1:REM Resonance and voice 1 filter routing
150 OUT RP,24:OUT DP,16+VL:REM Low-pass output plus master volume
160 PRINT "RODEO RUMBLE - FILTERED MOO"
170 FOR N=1 TO NS
180 F=FL:CF=CL:GOSUB 600:GOSUB 700
190 OUT RP,4:OUT DP,65:REM Pulse gate on, muffled mm
200 REM Keep the pitch rise; open the mouth with the filter
210 FOR F=FL TO FH STEP FS
220 CF=CL+(CH-CL)*(F-FL)/(FH-FL)
230 GOSUB 600:GOSUB 700:GOSUB 800
240 NEXT F
250 REM Rounded OO, easing the filter back from its peak
260 FOR J=0 TO 15
270 F=FH-INT(RND(1)*21)
280 CF=CH+(CM-CH)*J/15
290 GOSUB 600:GOSUB 700:GOSUB 800
300 NEXT J
310 REM Longer falling oo, closing the filter towards a hum
320 FOR F=FH TO FE STEP -FS
330 CF=CL+(CM-CL)*(F-FE)/(FH-FE)
340 GOSUB 600:GOSUB 700:GOSUB 800:GOSUB 800
350 NEXT F
360 OUT RP,4:OUT DP,64:REM Release with the filter still closed
370 FOR T=1 TO GP:NEXT T
380 NEXT N
390 OUT RP,4:OUT DP,0
400 OUT RP,24:OUT DP,0
410 PRINT "MOOS COMPLETE"
420 END
600 REM Write voice 1 frequency; no added pitch jitter
610 H=INT(F/256):L=F-256*H
620 OUT RP,0:OUT DP,L
630 OUT RP,1:OUT DP,H
640 RETURN
700 REM Split 11-bit cutoff into low 3 bits and high 8 bits
710 V=INT(CF):H=INT(V/8):L=V-8*H
720 OUT RP,21:OUT DP,L
730 OUT RP,22:OUT DP,H
740 RETURN
800 REM Approximate pitch-step hold, dependent on CPU speed
810 FOR T=1 TO DL:NEXT T
820 RETURN
