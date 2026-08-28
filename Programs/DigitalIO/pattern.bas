10 PRINT "Enter the required state of the LEDs"
20 PRINT "as a string of 8 1s and 0s where 1 is"
30 PRINT "on and 0 is off"
40 INPUT "LEDs: "; L$
50 IF LEN(L$) <> 8 THEN PRINT "Invalid input": GOTO 40
60 REM Initialise the OUT value to 0 and iterate
70 REM over the string to set the bits
80 B = 0
90 FOR I = 1 TO 8
100 D$ = MID$(L$, I, 1)
110 IF D$ <> "0" AND D$ <> "1" THEN PRINT "Invalid input": GOTO 40
120 IF D$ = "1" THEN B = B + 2 ^ (8 - I)
130 NEXT I
140 PRINT "The value to output is "; B
150 M$ = "" : PRINT "More (Y/N): ";: INPUT M$
160 IF M$ = "Y" OR M$ = "y" THEN GOTO 10
170 END