10 REM Based on the example program from the RC2014 web site at:
20 REM https://rc2014.co.uk/modules/lcd-driver-module/
30 R=218    : REM 0xDA - Register
40 D=219    : REM 0xDB - Data
50 W=16     : REM Display width in characters
60 OUT R,56 : REM 0011 1000 - Function 8 bit, 2 lines, 5x8 dot font
70 OUT R,14 : REM 0000 1110 - Display on, cursor on, no blink
80 OUT R,1  : REM 0000 0001 - Clear display
90 INPUT "Message to display";T$
100 L=LEN(T$)
110 IF L>W*2 THEN L=W*2
120 FOR A=1 TO L
130 IF A=W+1 THEN OUT R,192: REM Move to start of line 2 (0x40)
140 REM PRINT MID$(T$,A,1);
150 OUT D,ASC (MID$(T$,A,1))
160 NEXT A
