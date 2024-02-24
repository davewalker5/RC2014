10 LET SZ = 9 : REM Size of the board
20 LET SM = 1000 : REM Maximum stack size
30 LET SD = 2 : REM Number of values per stack entry
40 DIM B(SZ, SZ) : REM The board
50 DIM R(SZ, SZ) : REM The revealed board
60 DIM ST(SM, SD) : REM Stack

100 REM Control variable innitialisation
110 LET EV = 0  : REM Value used to represent an empty cell
120 LET MV = 10 : REM Value used to represent mines
130 LET NM = 10 : REM Number of mines
140 LET SP = 0 : REM Stack pointer
150 LET NR = 0 : REM Count of revealed cells
160 LET CB = SZ * SZ - NM : REM Number of cells to reveal to win

200 REM Board initialisation
210 GOSUB 1000 : REM Clear the board
220 GOSUB 1500 : REM Position the mines
230 GOSUB 2000 : REM Calculate the proximity values

300 REM Main loop
310 GOSUB 500
320 PRINT ""
330 PRINT "Do you want to play again? (Y/N) ";
340 INPUT Z$
350 IF Z$ = "Y" OR Z$ = "y" THEN GOTO 100
360 IF Z$ <> "N" AND Z$ <> "n" THEN GOTO 300
370 END

500 REM Main Loop
510 GOSUB 3000 : REM Display the board
520 GOSUB 4500 : REM Get the choice of next cell to reveal
530 IF B(X, Y) = MV THEN GOSUB 700 : RETURN
540 GOSUB 5000 : REM Reveal the cell at X, Y and any adjacent cells
550 IF NR < CB THEN GOTO 500
560 GOSUB 4650 : REM Reveal the whole board
570 PRINT "" : PRINT "You win!"
580 RETURN

700 REM Game over (player lost)
710 GOSUB 4650 : REM Reveal the whole board
720 PRINT "" : PRINT "Game over! You trod on a mine!"
730 RETURN

1000 REM Clear the board by setting each cell to 0 and clearing
1010 REM the revealed board
1020 FOR I = 1 TO SZ
1030 FOR J = 1 TO SZ
1040 LET B(I, J) = EV : LET R(I, J) = 0
1050 NEXT J
1060 NEXT I
1070 RETURN

1500 REM Position the mines. The maximum number of mines that
1510 REM can be placed around a single cell is 8 so use a value
1520 REM above that range (held in MV) to represent a mine to
1530 REM avoid conflicting with the proximity display
1540 X = 1 + INT(RND(1) * SZ)
1550 Y = 1 + INT(RND(1) * SZ)
1560 IF B(X, Y) <> EV THEN GOTO 1500
1570 LET B(X, Y) = MV
1580 NM = NM - 1 
1590 IF NM > 0 THEN GOTO 1500
1600 RETURN

2000 REM Calculate the proximity value for the whole board
2010 FOR I = 1 TO SZ
2020 FOR J = 1 TO SZ
2030 IF B(I, J) <> MV THEN GOSUB 2500
2040 NEXT J
2050 NEXT I
2060 RETURN

2500 REM Calculate the proximity value for a single cell with
2510 REM co-orindates I, J
2520 FOR C = I - 1 TO I + 1
2530 IF C < 1 OR C > SZ THEN GOTO 2590
2540 FOR R = J - 1 TO J + 1
2550 IF R < 1 OR R > SZ THEN GOTO 2580
2560 IF B(C, R) = MV THEN LET B(I, J) = B(I, J) + 1
2580 NEXT R
2590 NEXT C
2600 RETURN

3000 REM Display the board
3010 PRINT "" : PRINT NR; " of "; CB; " cells revealed" : PRINT ""
3020 GOSUB 6200
3030 PRINT "     1  2  3  4  5  6  7  8  9 ";
3040 GOSUB 6100 : PRINT "" : GOSUB 6200
3050 PRINT "   +---------------------------";
3060 GOSUB 6100 : PRINT ""
3070 FOR I = 1 TO SZ
3080 GOSUB 6200 : PRINT I;"|"; : GOSUB 6100
3090 FOR J = 1 TO SZ
3100 GOSUB 4000
3110 NEXT J
3120 PRINT ""
3130 NEXT I
3140 RETURN

4000 REM Display the cell at I, J using text-only
4010 IF R(I, J) = 0 THEN GOSUB 6300 : RETURN
4020 IF B(I, J) = 0 THEN GOSUB 6400 : RETURN
4030 IF B(I, J) > 0 AND B(I, J) < 9 THEN GOSUB 6500 : RETURN
4040 IF B(I, J) = MV THEN GOSUB 6600
4050 RETURN

4500 REM Get the choice of next cell to reveal
4510 PRINT ""
4520 PRINT "Enter a row and column for the next cell to reveal"
4530 PRINT "e.g for row 3, column 4, enter 34: ";
4540 INPUT C$
4550 IF LEN(C$) <> 2 THEN GOTO 4500
4560 LET X = VAL(LEFT$(C$, 1))
4570 LET Y = VAL(RIGHT$(C$, 1))
4580 REM Check the selected coordinates are in range and
4590 REM the cell has not already been revealed
4600 IF X < 1 OR X > SZ OR Y < 1 OR Y > SZ THEN GOTO 4500
4610 IF R(X, Y) = 1 THEN GOTO 4500
4620 PRINT ""
4630 RETURN

4650 REM Reveal the whole board
4660 FOR I = 1 TO SZ
4670 FOR J = 1 TO SZ
4680 LET R(I, J) = 1 : LET NR = CB
4690 NEXT J
4700 NEXT I
4710 GOSUB 3000
4720 RETURN

5000 REM Reveal the cell at X, Y
5020 IF R(X,Y) = 0 THEN LET R(X, Y) = 1 : LET NR = NR + 1
5030 IF B(X, Y) > 0 THEN RETURN
5040 REM Reveal any adjacent cells up to the next cells with a
5050 REM proximity value > 0
5060 FOR C = X - 1 TO X + 1
5070 IF C < 1 OR C > SZ THEN GOTO 5180
5080 FOR W = Y - 1 TO Y + 1
5090 IF W < 1 OR W > SZ THEN GOTO 5170
5100 REM If this cell is already revealed, skip to the next row
5110 IF R(C, W) = 1 THEN GOTO 5170
5120 REM Reveal this cell. If it is empty, push it onto the
5130 REM stack so further reveals based on it can be processed
5140 REM later
5150 LET R(C, W) = 1 : LET NR = NR + 1
5160 IF B(C, W) = 0 THEN LET V(1) = C : LET V(2) = W : GOSUB 5500
5170 NEXT W
5180 NEXT C
5190 REM Pop the next cell to perform the reveal algorithm at off
5200 REM the stack and repeat
5210 IF SP = 0 THEN RETURN
5220 GOSUB 6000 : LET X = V(1) : LET Y = V(2) : GOSUB 5000

5500 REM Push a value held in V onto the stack
5510 IF SP = SM THEN PRINT "Stack overflow" : STOP
5520 LET SP = SP + 1
5530 FOR D = 1 TO SD
5540 LET ST(SP, D) = V(D)
5550 NEXT D
5560 RETURN

6000 REM Pop a value from the stack
6010 IF SP = 0 THEN PRINT "Stack underflow" : STOP
6020 FOR D = 1 TO SD
6030 LET V(D) = ST(SP, D)
6040 NEXT D
6050 LET SP = SP - 1
6060 RETURN

6100 REM Clear all ANSI codes
6110 PRINT CHR$(27);"[0m";
6120 RETURN

6200 REM Set the colours to black on white
6210 PRINT CHR$(27);"[47m";
6220 PRINT CHR$(27);"[30m";
6230 RETURN

6300 REM Print a non-revealed cell
6310 GOSUB 6200
6320 PRINT "   ";
6330 GOSUB 6100
6340 RETURN

6400 REM Print a revealed empty cell
6410 PRINT CHR$(27);"[42m";
6420 PRINT "   ";
6430 GOSUB 6100
6440 RETURN

6500 REM Print the proximity value at I, J
6510 PRINT CHR$(27);"[47m";
6520 IF B(I, J) = 1 THEN PRINT CHR$(27);"[94m";
6530 IF B(I, J) = 2 THEN PRINT CHR$(27);"[92m";
6540 IF B(I, J) > 2 THEN PRINT CHR$(27);"[91m";
6550 PRINT B(I, J);
6560 GOSUB 6100
6570 RETURN

6600 REM Print a mine
6610 PRINT CHR$(27);"[41m";
6620 PRINT CHR$(27);"[97m";
6630 PRINT " * ";
6640 GOSUB 6100
6650 RETURN
