10 REM Choose the code to break : A set of random numbers in the range 1-9
20 DIM C(4), M(4), A(4)
30 FOR I = 1 TO 4
40 LET C(I) = 1 + INT(RND(1) * 9.0)
50 NEXT I
60 PRINT "I have selected a random 4-digit code for you to break"
70 REM Prompt for the next attempt
80 FOR N = 1 TO 10
90 PRINT "Enter your guess: ";
100 INPUT A$
110 REM Capture and validate the digits and initialise the marking array
120 IF LEN(A$) <> 4 THEN PRINT "The code has 4 digits" : GOTO 90
130 FOR I = 1 TO 4
140 LET D$ = MID$(A$, I, 1)
150 IF D$ < "1" OR D$ > "9" THEN PRINT "Digits are in the range 1-9" : GOTO 90
160 LET A(I) = VAL(MID$(A$, I, 1))
170 LET M(I) = C(I)
180 NEXT I
190 REM Mark the guess
200 LET B = 0 : LET C = 0
210 REM First, count the bulls
220 FOR I = 1 TO 4
230 REM If there is a match at this position, increment the number of
240 REM bulls and set the marking array and the attempt to 0 at this
250 REM position to avoid double counting when the cows are counted
260 IF A(I) = M(I) THEN LET B = B + 1 : LET M(I) = 0 : LET A(I) = 0
270 NEXT I
280 REM If there are 4 bulls, the code has been broken
290 IF B = 4 THEN GOTO 420
300 REM Now count the cows
310 FOR I = 1 TO 4
320 IF A(I) = 0 THEN GOTO 360
330 FOR J = 1 TO 4
340 IF A(I) = M(J) THEN LET C = C + 1 : LET M(J) = 0 : GOTO 360
350 NEXT J
360 NEXT I
370 REM Report the result of the attempt
380 PRINT "Attempt "; N; " : "; A$; " : ";STR$(B); "B"; STR$(C); "C"
390 NEXT N
400 PRINT "Out of attempts! The code was: ";
410 GOTO 440
420 PRINT "You have broken the code: ";
430 REM Print the code
440 FOR I = 1 TO 4
450 PRINT C(I);
460 NEXT I
470 PRINT ""
480 REM Any more?
490 Z$ = "": PRINT "More? ";: INPUT Z$
500 IF Z$ = "Y" OR Z$ = "y" THEN GOTO 30
510 END
