10 DIM CG(31), NG(31)
20 REM Ideally, let the width be an odd number so the
30 REM middle cell has the same number of cells to its
40 REM left and right. The CG() and NG() arrays must be
50 REM dimensioned to the same width.
60 LET W = 31
70 REM The following is the ANSI colour code for each cell
80 LET AC = 32
90 PRINT "How many generations do you want to see?"
100 INPUT NUMG
110 IF NUMG < 1 THEN PRINT "You must specify at least 1 generation" : GOTO 90
120 REM Initialize the current generation with a single
130 REM cell in the middle
140 FOR I = 1 TO W : LET CG(I) = 0 : NEXT I
150 LET I = 1 + INT(W / 2)
160 LET CG(I) = 1
170 REM Print the current generation
180 GOSUB 490
190 REM Generate and print the next NUMG generations
200 FOR G = 1 TO NUMG - 1
210 REM Initialize the next generation
220 FOR I = 1 TO W : LET NG(I) = 0 : NEXT I
230 REM Populate the next generation
240 FOR I = 1 TO W
250 REM Calculate each component of the Rule 30. First,
260 REM calculate the states of the left, current, and
270 REM right cells
280 IF I = 1 THEN LET LC = 0
290 IF I > 1 THEN LET LC = CG(I - 1)
300 LET CC = CG(I)
310 IF I = W THEN LET RC = 0
320 IF I < W THEN LET RC = CG(I + 1)
330 REM Initialse the components of the Rule
340 LET A = 0 : LET B = 0 : LET C = 0 : LET D = 0
350 REM Calculate the components of rule 30
360 IF LC = 1 AND CC = 0 AND RC = 0 THEN LET A = 1
370 IF LC = 0 AND CC = 1 AND RC = 1 THEN LET B = 1
380 IF LC = 0 AND CC = 1 AND RC = 0 THEN LET C = 1
390 IF LC = 0 AND CC = 0 AND RC = 1 THEN LET D = 1
400 REM The next state of the current cell is alive if
410 REM any of A, B, C, or D is set to 1
420 IF A = 1 OR B = 1 OR C = 1 OR D = 1 THEN LET NG(I) = 1
430 NEXT I
440 REM Copy the next generation into the current one and print it
450 FOR I = 1 TO W : CG(I) = NG(I) : NEXT i
460 GOSUB 490
470 NEXT G
480 END
490 REM Print the current generation
500 FOR I = 1 TO W
510 IF CG(I) = 0 THEN PRINT " "; : GOTO 590
520 REM Create a text representation of the colour code
530 REM STR$() will add a leading space that must be
540 REM removed
550 LET AC$ = STR$(AC)
560 LET AC$ = RIGHT$(AC$, LEN(AC$) - 1)
570 PRINT CHR$(27);"[";AC$;";7m";" ";
580 PRINT CHR$(27);"[0m";
590 NEXT I
600 PRINT ""
610 RETURN
