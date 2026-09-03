10 REM Animated custom glyph for the RC2014 LCD Driver Module
20 R=218     : REM 0xDA - Register
30 D=219     : REM 0xDB - Data
40 W=16      : REM Display width in characters
50 DL=300    : REM Delay between animation frames
60 OUT R,56  : REM 8 bit, 2 lines, 5x8 dot font
70 OUT R,12  : REM Display on, cursor off, no blink
80 OUT R,6   : REM Increment address after each data write
90 OUT R,1   : REM Clear display
100 GOSUB 500
110 OUT R,64 : REM Select CGRAM address for custom character 0
120 GOSUB 500
130 FOR A=1 TO 16
140 READ B
150 OUT D,B
160 GOSUB 500
170 NEXT A
180 REM Move across line 1, alternating custom characters 0 and 1
190 FOR P=0 TO W-1
200 IF P=0 THEN 240
210 OUT R,128+P-1 : REM Select previous display position
220 GOSUB 500
230 OUT D,32 : REM Erase the previous glyph with a space
235 GOSUB 500
240 OUT R,128+P : REM Select the next display position
250 GOSUB 500
260 C=P-2*INT(P/2) : REM Alternate between character 0 and 1
270 OUT D,C
280 FOR Z=1 TO DL:NEXT Z
290 NEXT P
300 OUT R,128+W-1 : REM Erase the glyph before restarting
310 GOSUB 500
320 OUT D,32
330 FOR Z=1 TO DL:NEXT Z
340 GOTO 190
400 REM OCTOPUS FRAME 1
410 REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  .#.#.
420 DATA 14,21,31,31,14,21,21,10
430 REM OCTOPUS FRAME 2
440 REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  #.#.#
450 DATA 14,21,31,31,14,21,21,21
500 REM Conservative LCD command and data delay
510 FOR Q=1 TO 100:NEXT Q
520 RETURN
