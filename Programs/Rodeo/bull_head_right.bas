10 REM Rodeo Rumble - right pose bull head over 2x2 cells
20 R=218:D=219:REM LCD command and data ports
30 DL=100:REM Delay after every LCD command and data write
40 X=7:REM Left column, zero based; 7 centres on a 16-column LCD
50 GOSUB 900
60 C=56:GOSUB 1000:REM 8 bit, 2 lines, 5x8 font
70 C=12:GOSUB 1000:REM Display on, cursor and blink off
80 C=6:GOSUB 1000:REM Increment address, no shift
90 C=1:GOSUB 1000
100 RESTORE
110 C=64:GOSUB 1000:REM CGRAM slots 0 to 3
120 FOR I=1 TO 32
130 READ B:GOSUB 1100
140 NEXT I
150 C=128+X:GOSUB 1000:REM Top row, return to display memory
160 B=0:GOSUB 1100
170 B=1:GOSUB 1100
180 C=192+X:GOSUB 1000:REM Bottom row at same column
190 B=2:GOSUB 1100
200 B=3:GOSUB 1100
210 PRINT "RODEO RUMBLE - HEAD RIGHT"
220 PRINT "STATIC HEAD LEFT ON LCD - RUN TO RELOAD"
230 END
900 REM Conservative LCD settling and write delay
910 FOR Z=1 TO DL:NEXT Z
920 RETURN
1000 OUT R,C:GOSUB 900:RETURN
1100 OUT D,B:GOSUB 900:RETURN
2000 REM Slot 0 - top left
2010 REM #.... #.... ##... .##.. ..### ....# ..### ..###
2020 DATA 16,16,24,12,7,1,7,7
2030 REM Slot 1 - top right
2040 REM ....# ....# ...## ..##. ###.. ###.. ##### #####
2050 DATA 1,1,3,6,28,28,31,31
2060 REM Slot 2 - bottom left
2070 REM ...#. ...## ...## ..... ....# ....# ....# .....
2080 DATA 2,3,3,0,1,1,1,0
2090 REM Slot 3 - bottom right
2100 REM ##.#. ####. ####. ####. ##### .##.# ##### ####.
2110 DATA 26,30,30,30,31,13,31,30
