10 LET W = 12 : LET H = 12 : REM Grid width and height
20 REM The extra cells form a permanently dead border
30 DIM CG(W + 1, H + 1), NG(W + 1, H + 1)
40 IF W < 6 OR H < 6 THEN PRINT "Grid must be at least 6 by 6." : END
100 REM Choose the display mode
110 PRINT "CONWAY'S GAME OF LIFE"
120 PRINT "Use ANSI screen control (Y/N) ";
130 INPUT A$
140 IF A$ = "Y" OR A$ = "y" THEN LET AN = 1 : GOTO 170
150 IF A$ = "N" OR A$ = "n" THEN LET AN = 0 : GOTO 170
160 PRINT "Please enter Y or N." : GOTO 120
170 GOSUB 1000
175 GOSUB 1200
180 GOSUB 1500
190 PRINT "How many generations to show (1-999) ";
200 INPUT LM
210 IF LM < 1 OR LM > 999 THEN PRINT "Enter 1 to 999." : GOTO 190
220 LET G = 0
230 IF AN = 1 THEN GOSUB 4500
240 GOSUB 4000
300 REM Calculate and display successive generations
310 IF G >= LM - 1 THEN GOTO 500
320 GOSUB 2000
330 GOSUB 3000
340 LET G = G + 1
350 GOSUB 4000
360 IF CH = 0 THEN PRINT "Pattern is stable." : GOTO 500
370 GOTO 310
500 REM Offer another run
510 PRINT ""
520 PRINT "Try another pattern (Y/N) ";
530 INPUT A$
540 IF A$ = "Y" OR A$ = "y" THEN GOTO 100
550 IF A$ = "N" OR A$ = "n" THEN END
560 PRINT "Please enter Y or N." : GOTO 520
1000 REM Clear both generations, including their dead borders
1010 FOR Y = 0 TO H + 1
1020 FOR X = 0 TO W + 1
1030 LET CG(X, Y) = 0 : LET NG(X, Y) = 0
1040 NEXT X
1050 NEXT Y
1060 RETURN
1200 REM Prepare values that depend on the configured grid size
1210 LET CX = INT((W + 1) / 2) : LET CY = INT((H + 1) / 2)
1220 LET BD$ = "+"
1230 FOR X = 1 TO W
1240 LET BD$ = BD$ + "-"
1250 NEXT X
1260 LET BD$ = BD$ + "+"
1270 RETURN
1500 REM Select and create the starting pattern
1510 PRINT ""
1520 PRINT "Starting pattern:"
1530 PRINT "1 - Glider"
1540 PRINT "2 - Blinker"
1550 PRINT "3 - Toad"
1560 PRINT "4 - Beacon"
1570 PRINT "5 - Enter cells manually"
1580 PRINT "Choose 1 to 5 ";
1590 INPUT P
1600 IF P < 1 OR P > 5 THEN PRINT "Enter 1 to 5." : GOTO 1580
1610 IF P = 1 THEN GOSUB 1700 : RETURN
1620 IF P = 2 THEN GOSUB 1750 : RETURN
1630 IF P = 3 THEN GOSUB 1800 : RETURN
1640 IF P = 4 THEN GOSUB 1850 : RETURN
1650 GOSUB 1900
1660 RETURN
1700 REM Place a glider near the centre
1710 LET CG(CX, CY - 1) = 1 : LET CG(CX + 1, CY) = 1
1720 LET CG(CX - 1, CY + 1) = 1
1730 LET CG(CX, CY + 1) = 1 : LET CG(CX + 1, CY + 1) = 1
1740 RETURN
1750 REM Place a period-two blinker
1760 LET CG(CX - 1, CY) = 1 : LET CG(CX, CY) = 1
1770 LET CG(CX + 1, CY) = 1
1780 RETURN
1800 REM Place a period-two toad
1810 LET CG(CX - 1, CY) = 1 : LET CG(CX, CY) = 1
1820 LET CG(CX + 1, CY) = 1 : LET CG(CX - 2, CY + 1) = 1
1830 LET CG(CX - 1, CY + 1) = 1 : LET CG(CX, CY + 1) = 1
1840 RETURN
1850 REM Place a period-two beacon
1860 LET CG(CX - 1, CY - 1) = 1 : LET CG(CX, CY - 1) = 1
1870 LET CG(CX - 1, CY) = 1 : LET CG(CX + 2, CY + 1) = 1
1880 LET CG(CX + 1, CY + 2) = 1 : LET CG(CX + 2, CY + 2) = 1
1890 RETURN
1900 REM Read live cells as row and column pairs
1910 PRINT "Enter each live cell as row,column."
1920 PRINT "Rows are 1-"; H; " and columns are 1-"; W; "."
1930 PRINT "Enter 0,0 when finished."
1940 PRINT "Cell ";
1950 INPUT Y, X
1960 IF Y = 0 AND X = 0 THEN RETURN
1970 IF Y < 1 OR Y > H THEN PRINT "Row must be 1-"; H; "." : GOTO 1940
1980 IF X < 1 OR X > W THEN PRINT "Column must be 1-"; W; "." : GOTO 1940
1990 LET CG(X, Y) = 1 : GOTO 1940
2000 REM Calculate the next generation into NG()
2010 LET CH = 0
2020 FOR Y = 1 TO H
2030 FOR X = 1 TO W
2040 LET N = CG(X - 1, Y - 1) + CG(X, Y - 1)
2050 LET N = N + CG(X + 1, Y - 1) + CG(X - 1, Y)
2060 LET N = N + CG(X + 1, Y) + CG(X - 1, Y + 1)
2070 LET N = N + CG(X, Y + 1) + CG(X + 1, Y + 1)
2080 LET NG(X, Y) = 0
2090 IF N = 3 THEN LET NG(X, Y) = 1 : GOTO 2110
2100 IF N = 2 AND CG(X, Y) = 1 THEN LET NG(X, Y) = 1
2110 IF NG(X, Y) <> CG(X, Y) THEN LET CH = CH + 1
2120 NEXT X
2130 NEXT Y
2140 RETURN
3000 REM Copy the completed next generation into the current one
3010 FOR Y = 1 TO H
3020 FOR X = 1 TO W
3030 LET CG(X, Y) = NG(X, Y)
3040 NEXT X
3050 NEXT Y
3060 RETURN
4000 REM Display one buffered string for each board row
4010 IF AN = 1 THEN PRINT CHR$(27); "[H";
4020 IF AN = 0 THEN PRINT ""
4030 PRINT "Generation "; G
4110 PRINT BD$
4120 FOR Y = 1 TO H
4130 LET S$ = "|"
4140 FOR X = 1 TO W
4150 IF CG(X, Y) = 1 THEN LET S$ = S$ + "#" : GOTO 4170
4160 LET S$ = S$ + " "
4170 NEXT X
4180 PRINT S$; "|"
4190 NEXT Y
4200 PRINT BD$
4210 RETURN
4500 REM Clear the ANSI terminal once before animation
4510 PRINT CHR$(27); "[2J"; CHR$(27); "[H";
4520 RETURN
