10 REM Blinking message for the RC2014 LCD Driver Module
20 R=218     : REM 0xDA - Register
30 D=219     : REM 0xDB - Data
40 W=16      : REM Display width in characters
50 DL=300    : REM Delay for each visible and blank interval
60 OUT R,56  : REM 8 bit, 2 lines, 5x8 dot font
70 OUT R,12  : REM Display on, cursor off, no blink
80 OUT R,6   : REM Increment address after each data write
90 OUT R,1   : REM Clear display
100 GOSUB 500
110 INPUT "Message to display";T$
120 L=LEN(T$)
130 IF L>W*2 THEN L=W*2
140 FOR A=1 TO L
150 IF A=W+1 THEN OUT R,192:GOSUB 500
160 REM PRINT MID$(T$,A,1);
170 OUT D,ASC(MID$(T$,A,1))
180 GOSUB 500
190 NEXT A
200 FOR Z=1 TO DL:NEXT Z
210 OUT R,8 : REM Display off without clearing its contents
220 GOSUB 500
230 FOR Z=1 TO DL:NEXT Z
240 OUT R,12 : REM Restore the preserved display contents
250 GOSUB 500
260 GOTO 200
500 REM Conservative LCD command and data delay
510 FOR Q=1 TO 100:NEXT Q
520 RETURN
