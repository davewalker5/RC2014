10 REM Roman numerals for units, tens, hundreds and thousands. Within each set, the numerals
20 REM are in order length of the numeral
30 DATA "VIII", 8, "III", 3, "VII", 7, "II", 2,  "IV", 4, "VI", 6
35 DATA "IX", 9, "I", 1, "V", 5
40 DATA "LXXX", 80, "XXX", 30, "LXX", 70, "XX", 20, "XL", 40
45 DATA "LX", 60, "XC", 90, "X", 10, "L", 50
50 DATA "DCCC", 800, "CCC", 300, "DCC", 700, "CC", 200, "CD", 400
55 DATA "DC", 600, "CM", 900, "C", 100, "D", 500
60 DATA "MMM", 3000, "MM", 2000, "M", 1000
70 REM Read the numerals into arrays
80 DIM U$(9), T$(9), H$(9), M$(4)
90 DIM U(9), T(9), H(9), M(4)
100 FOR I = 1 TO 9 : READ U$(I), U(I) : NEXT I
110 FOR I = 1 TO 9 : READ T$(I), T(I) : NEXT I
120 FOR I = 1 TO 9 : READ H$(I), H(I) : NEXT I
130 FOR I = 1 TO 3 : READ M$(I), M(I) : NEXT I
140 REM Prompt for the Roman Numeral to converted
150 PRINT "Enter a Roman Numeral in the range I to MMMCMXCIX"
160 INPUT R$
170 REM Initialise the decimal result
180 LET R = 0
500 REM Convert the units, tens, hundreds and thousands in that order
510 LET D = 1 : LET N = 9 : GOSUB 1000
520 LET D = 2 : LET N = 9 : GOSUB 1000
530 LET D = 3 : LET N = 9 : GOSUB 1000
540 LET D = 4 : LET N = 3 : GOSUB 1000
550 REM If there is anything left, the input was invalid
560 IF R$ <> "" THEN PRINT "Invalid input" : GOTO 920
900 REM Print the result
910 PRINT "The decimal equivalent is "; R
920 PRINT "More (Y/N): ";: INPUT M$
930 IF M$ = "Y" OR M$ = "y" THEN GOTO 10
940 END
1000 REM Find the numeral that matches the end of the current input string
1010 FOR I = 1 TO N
1020 REM Get the current numeral and its value
1030 IF D = 1 THEN LET C$ = U$(I) : LET V = U(I)
1040 IF D = 2 THEN LET C$ = T$(I) : LET V = T(I)
1050 IF D = 3 THEN LET C$ = H$(I) : LET V = H(I)
1060 IF D = 4 THEN LET C$ = M$(I) : LET V = M(I)
1100 REM Look for a match at the end of the current input string
1110 IF LEN(R$) < LEN(C$) THEN GOTO 1500
1120 IF RIGHT$(R$, LEN(C$)) <> C$ THEN GOTO 1500
1130 REM Found a match, so add the value to the result and remove the numeral from the input string
1140 LET R = R + V
1150 LET R$ = LEFT$(R$, LEN(R$) - LEN(C$))
1160 GOTO 1510
1500 NEXT I
1510 RETURN
