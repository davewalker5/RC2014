10 DIM CG(31), NG(31)
20 REM Ideally, let the width be an odd number so the
30 REM middle cell has the same number of cells to its
40 REM left and right. The CG() and NG() arrays must be
50 REM dimensioned to the same width.
60 LET W = 31
70 PRINT "How many generations do you want to see?"
80 INPUT NUMG
90 IF NUMG < 1 THEN PRINT "You must specify at least 1 generation" : GOTO 70
100 REM Initialize the current generation with a single
110 REM cell in the middle
120 FOR I = 1 TO W : LET CG(I) = 0 : NEXT I
130 LET I = 1 + INT(W / 2)
140 LET CG(I) = 1
150 REM Print the current generation
160 GOSUB 490
170 REM Generate and print the next NUMG generations
180 FOR G = 1 TO NUMG - 1
190 REM Initialize the next generation
200 FOR I = 1 TO W : LET NG(I) = 0 : NEXT I
210 REM Populate the next generation
220 FOR I = 1 TO W
230 REM Calculate each component of the Rule 30. First,
240 REM calculate the states of the left, current, and
250 REM right cells
260 IF I = 1 THEN LET LC = 0
270 IF I > 1 THEN LET LC = CG(I - 1)
280 LET CC = CG(I)
290 IF I = W THEN LET RC = 0
300 IF I < W THEN LET RC = CG(I + 1)
310 REM Initialse the components of the Rule
320 LET A = 0 : LET B = 0 : LET C = 0 : LET D = 0
330 REM Calculate the components of rule 30
340 IF LC = 1 AND CC = 0 AND RC = 0 THEN LET A = 1
350 IF LC = 0 AND CC = 1 AND RC = 1 THEN LET B = 1
360 IF LC = 0 AND CC = 1 AND RC = 0 THEN LET C = 1
370 IF LC = 0 AND CC = 0 AND RC = 1 THEN LET D = 1
380 REM The next state of the current cell is alive if
390 REM any of A, B, C, or D is set to 1
400 IF A = 1 OR B = 1 OR C = 1 OR D = 1 THEN LET NG(I) = 1
410 NEXT I
420 REM Copy the next generation into the current one and print it
430 FOR I = 1 TO W : CG(I) = NG(I) : NEXT i
440 GOSUB 490
470 NEXT G
480 END
490 REM Print the current generation
500 FOR I = 1 TO W
510 IF CG(I) = 1 THEN PRINT "#";
520 IF CG(I) = 0 THEN PRINT " ";
530 NEXT I
540 PRINT ""
550 RETURN
