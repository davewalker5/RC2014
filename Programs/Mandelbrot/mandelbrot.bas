10 REM Text Mandelbrot set - display and detail settings
20 LET W = 64 : LET H = 24 : LET LM = 32
30 LET XL = -2 : LET XR = 1
40 LET AR = 2 : REM Character height divided by width
50 LET P$ = " .:-=+*#%"
100 REM Validate settings and centre the view on the real axis
110 IF W < 2 OR W > 79 OR W <> INT(W) THEN GOTO 800
120 IF H < 2 OR H > 100 OR H <> INT(H) THEN GOTO 800
130 IF LM < 1 OR LM > 255 OR LM <> INT(LM) THEN GOTO 810
140 IF XR <= XL OR AR <= 0 THEN GOTO 820
145 IF LEN(P$) = 0 THEN PRINT "Use a non-empty shade palette." : END
150 LET DX = (XR - XL) / (W - 1)
160 LET DY = DX * AR
170 LET YT = DY * (H - 1) / 2
180 PRINT "MANDELBROT SET"
190 PRINT "Rendering one character at a time..."
200 REM Map each character position to c = CR + CI * i
210 FOR Y = 0 TO H - 1
220 LET CI = YT - Y * DY
230 REM Print directly to avoid allocating a growing row string
240 FOR X = 0 TO W - 1
250 LET CR = XL + X * DX
260 GOSUB 1000
270 PRINT C$;
280 NEXT X
290 PRINT ""
300 NEXT Y
320 END
800 PRINT "Use integer width 2-79 and height 2-100." : END
810 PRINT "Use an integer iteration limit of 1-255." : END
820 PRINT "Right bound must exceed left; aspect must be positive."
830 END
1000 REM Iterate z = z squared + c, starting with z = 0
1010 LET ZR = 0 : LET ZI = 0
1020 LET AA = 0 : LET BB = 0 : LET N = 0
1030 REM Use both old components before replacing their squares
1040 LET ZI = 2 * ZR * ZI + CI
1050 LET ZR = AA - BB + CR
1060 LET AA = ZR * ZR : LET BB = ZI * ZI
1070 LET N = N + 1
1080 IF AA + BB > 4 THEN GOTO 1120
1090 IF N < LM THEN GOTO 1040
1100 LET C$ = " "
1110 RETURN
1120 REM Later escapes use denser characters; cap at the last shade
1130 LET K = N
1140 IF K > LEN(P$) THEN LET K = LEN(P$)
1150 LET C$ = MID$(P$, K, 1)
1160 RETURN
