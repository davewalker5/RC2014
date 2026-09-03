10 REM Scrolling news ticker for the RC2014 LCD Driver Module
20 REM Text enters from the right and leaves at the left
30 R=218     : REM 0xDA - Register
40 D=219     : REM 0xDB - Data
50 W=16      : REM Display width in characters
60 DL=100    : REM Delay between frames
70 OUT R,56  : REM 8 bit, 2 lines, 5x8 dot font
80 OUT R,12  : REM Display on, cursor off, no blink
90 OUT R,1   : REM Clear display
100 INPUT "Message to scroll";T$
110 L=LEN(T$)
120 FOR P=1 TO L+W+1
130 OUT R,128 : REM Move to start of line 1 (0x00)
140 FOR A=0 TO W-1
150 C=P+A-W
160 IF C<1 OR C>L THEN OUT D,32:GOTO 180
170 OUT D,ASC(MID$(T$,C,1))
180 NEXT A
190 FOR Z=1 TO DL:NEXT Z
200 NEXT P
210 GOTO 120
