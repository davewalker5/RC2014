10 REM Ask the user how many numbers they want to print
20 PRINT "How many Fibonacci numbers do you want to print? (2 or more) "
30 INPUT N
40 IF N < 2 THEN PRINT "The number must be >= 2": GOTO 20
50 REM Initialise and print the first two numbers in the series
60 LET A = 0
70 LET B = 1
80 PRINT A
90 PRINT B
100 REM Finish if the user only wanted 2 numbers
110 IF N = 2 THEN GOTO 190
120 REM Print the rest of the numbers in the series
130 FOR I = 3 TO N
140 LET C = A + B
150 PRINT C
160 LET A = B
170 LET B = C
180 NEXT I
190 END
