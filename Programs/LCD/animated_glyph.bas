10 REM Animated custom glyph for the RC2014 LCD Driver Module
20 R=218     : REM 0xDA - Register
30 D=219     : REM 0xDB - Data
40 DL=300    : REM Delay between animation frames
50 OUT R,56  : REM 8 bit, 2 lines, 5x8 dot font
60 OUT R,12  : REM Display on, cursor off, no blink
70 OUT R,6   : REM Increment address after each data write
80 OUT R,1   : REM Clear display
90 GOSUB 500
100 OUT R,64 : REM Select CGRAM address for custom character 0
110 GOSUB 500
120 FOR A=1 TO 24
130 READ B
140 OUT D,B
150 GOSUB 500
160 NEXT A
170 OUT R,128 : REM Return to start of display line 1
180 GOSUB 500
190 T$="CUSTOM GLYPH "
200 FOR A=1 TO LEN(T$)
210 OUT D,ASC(MID$(T$,A,1))
220 GOSUB 500
230 NEXT A
240 C=0
250 OUT R,128+LEN(T$) : REM Keep the glyph after the message
260 GOSUB 500
270 OUT D,C
280 FOR Z=1 TO DL:NEXT Z
290 C=C+1:IF C=3 THEN C=0 : REM Cycle through characters 0, 1 and 2
300 GOTO 250
400 REM OCTOPUS FRAME 1
410 REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  .#.#.
420 DATA 14,21,31,31,14,21,21,10
430 REM OCTOPUS FRAME 2
440 REM .###.  #.#.#  #####  #####  .###.  #.#.#  .###.  .#.#.
450 DATA 14,21,31,31,14,21,14,10
460 REM OCTOPUS FRAME 3
470 REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  #.#.#
480 DATA 14,21,31,31,14,21,21,21
500 REM Conservative LCD command and data delay
510 FOR Q=1 TO 100:NEXT Q
520 RETURN
