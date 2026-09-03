10 REM Hardware-scrolling news ticker for the RC2014 LCD Driver Module
20 R=218     : REM 0xDA - Register
30 D=219     : REM 0xDB - Data
40 W=16      : REM Visible display width
50 M=40      : REM HD44780 display-memory width per line
60 DL=100    : REM Delay between shifts
70 DR=1      : REM 1 moves text left, -1 moves text right
80 OUT R,56  : REM 8 bit, 2 lines, 5x8 dot font
90 OUT R,12  : REM Display on, cursor off, no blink
100 OUT R,6  : REM Increment address after each data write
110 OUT R,1  : REM Clear display and hidden display memory
120 GOSUB 1000
130 INPUT "Message to scroll";T$
140 L=LEN(T$)
150 IF L<1 THEN 130
160 IF L<=M-W THEN 180
170 L=M-W : REM Limit message to available hidden memory
180 S=W:IF DR=-1 THEN S=M-L
190 OUT R,128+S : REM Position message outside the visible window
200 GOSUB 1000
210 FOR A=1 TO L
220 OUT D,ASC(MID$(T$,A,1))
230 GOSUB 1000
240 NEXT A
250 OUT R,2 : REM Restore the unshifted, blank display window
260 GOSUB 1000
270 FOR P=1 TO W+L
280 IF DR=-1 THEN 310
290 OUT R,24 : REM Shift the entire display left
300 GOTO 320
310 OUT R,28 : REM Shift the entire display right
320 GOSUB 1000
330 FOR Z=1 TO DL:NEXT Z
340 NEXT P
350 OUT R,2 : REM Return display shift home before repeating
360 GOSUB 1000
370 FOR Z=1 TO DL:NEXT Z
380 GOTO 270
1000 REM Conservative LCD command and data delay
1010 FOR Q=1 TO 100:NEXT Q
1020 RETURN
