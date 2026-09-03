10 REM Custom glyph for the RC2014 LCD Driver Module
20 R=218    : REM 0xDA - Register
30 D=219    : REM 0xDB - Data
40 OUT R,56 : REM 8 bit, 2 lines, 5x8 dot font
50 OUT R,12 : REM Display on, cursor off, no blink
60 OUT R,6  : REM Increment address after each data write
70 OUT R,1  : REM Clear display
80 GOSUB 300
90 OUT R,64 : REM Select CGRAM address for custom character 0
100 GOSUB 300
110 FOR A=1 TO 8
120 READ B
130 OUT D,B
140 GOSUB 300
150 NEXT A
160 OUT R,128 : REM Return to start of display line 1
170 GOSUB 300
180 T$="CUSTOM GLYPH "
190 FOR A=1 TO LEN(T$)
200 OUT D,ASC(MID$(T$,A,1))
210 GOSUB 300
220 NEXT A
230 OUT D,0 : REM Display custom character 0
240 END
245 REM OCTOPUS
250 REM .###.  #.#.#  #####  #####  .###.  #.#.#  #.#.#  #.#.#
260 DATA 14,21,31,31,14,21,21,21
300 REM Conservative LCD command and data delay
310 FOR Z=1 TO 100:NEXT Z
320 RETURN
