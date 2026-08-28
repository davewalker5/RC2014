10 REM The data statements contain the patterns of three adjacent cells
20 REM that will lead to the current cell being alive in the next generation
30 REM End the patterns with the value 999
40 DATA 110, 100, 011, 001, 999
50 DIM CG(31), NG(31), LCP(8), CCP(8), RCP(8)
60 REM Read the patterns. At the end of this process, LCP contains the left
70 REM cell pattern values, CCP contains the current cell pattern values and
80 REM RCP contains the right cell pattern values
90 NP = 0
100 READ P : IF P > 111 THEN GOTO 160
110 NP = NP + 1
120 LET LCP(NP) = INT(P / 100)
130 LET CCP(NP) = INT((P - 100 * LCP(NP)) / 10)
140 LET RCP(NP) = P - 100 * LCP(NP) - 10 * CCP(NP)
150 GOTO 100
160 REM Ideally, let the width be an odd number so the
170 REM middle cell has the same number of cells to its
180 REM left and right. The CG() and NG() arrays must be
190 REM dimensioned to the same width.
200 LET W = 31
210 REM The following is the ANSI colour code for each cell
220 LET AC = 32
230 PRINT "How many generations do you want to see?"
240 INPUT NUMG
250 IF NUMG < 1 THEN PRINT "You must specify at least 1 generation" : GOTO 230
260 REM Initialize the current generation with a single
270 REM cell in the middle
280 FOR I = 1 TO W : LET CG(I) = 0 : NEXT I
290 LET I = 1 + INT(W / 2)
300 LET CG(I) = 1
310 REM Print the current generation
320 GOSUB 590
330 REM Generate and print the next NUMG generations
340 FOR G = 1 TO NUMG - 1
350 REM Initialize the next generation
360 FOR I = 1 TO W : LET NG(I) = 0 : NEXT I
370 REM Populate the next generation
380 FOR I = 1 TO W
390 REM Calculate the states of the left, current, and right cells
400 IF I = 1 THEN LET LC = 0
410 IF I > 1 THEN LET LC = CG(I - 1)
420 LET CC = CG(I)
430 IF I = W THEN LET RC = 0
440 IF I < W THEN LET RC = CG(I + 1)
450 REM Compare the states to the patterns
460 FOR J = 1 TO NP
470 IF LC <> LCP(J) OR CC <> CCP(J) OR RC <> RCP(J) THEN GOTO 520
480 REM Found a match, so the current cell is alive in the next
490 REM generation
500 NG(I) = 1
510 GOTO 530
520 NEXT J
530 NEXT I
540 REM Copy the next generation into the current one and print it
550 FOR I = 1 TO W : CG(I) = NG(I) : NEXT i
560 GOSUB 590
570 NEXT G
580 END
590 REM Print the current generation
600 FOR I = 1 TO W
610 IF CG(I) = 0 THEN PRINT " "; : GOTO 690
620 REM Create a text representation of the colour code
630 REM STR$() will add a leading space that must be
640 REM removed
650 LET AC$ = STR$(AC)
660 LET AC$ = RIGHT$(AC$, LEN(AC$) - 1)
670 PRINT CHR$(27);"[";AC$;";7m";" ";
680 PRINT CHR$(27);"[0m";
690 NEXT I
700 PRINT ""
710 RETURN
