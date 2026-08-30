10 REM Configuration
20 LET MX = 255 : REM Largest value accepted
30 LET DG$ = "0123456789ABCDEF"
100 REM Display instructions
110 PRINT ""
120 PRINT "BASE CONVERTER"
130 PRINT "=============="
140 PRINT "Converts one-byte values between bases."
150 PRINT ""
200 REM Read and validate conversions until the user quits
210 PRINT "Source base (2, 8, 10, 16 or Q to quit)";
220 INPUT B$
230 IF B$ = "Q" OR B$ = "q" THEN GOTO 500
240 LET BS = VAL(B$)
250 IF B$ = "2" OR B$ = "8" THEN GOTO 280
260 IF B$ = "10" OR B$ = "16" THEN GOTO 280
270 PRINT "Please enter 2, 8, 10, 16 or Q." : GOTO 210
280 PRINT "Value (0 to 255)";
290 INPUT V$
300 GOSUB 1000
310 IF OK = 0 THEN PRINT "Invalid value for that base or above 255." : GOTO 280
320 PRINT ""
330 LET TB = 2 : GOSUB 2000 : PRINT "Binary:      "; R$
340 LET TB = 8 : GOSUB 2000 : PRINT "Octal:       "; R$
350 LET TB = 10 : GOSUB 2000 : PRINT "Decimal:     "; R$
360 LET TB = 16 : GOSUB 2000 : PRINT "Hexadecimal: "; R$
370 PRINT ""
380 GOTO 210
500 PRINT "Done"
510 END
1000 REM Convert V$ in base BS to N and return validity in OK
1010 LET OK = 0 : LET N = 0
1020 IF LEN(V$) = 0 THEN RETURN
1030 LET I = 1
1040 LET C$ = MID$(V$, I, 1) : LET C = ASC(C$) : LET D = -1
1050 IF C >= 48 AND C <= 57 THEN LET D = C - 48
1060 IF C >= 65 AND C <= 70 THEN LET D = C - 55
1070 IF C >= 97 AND C <= 102 THEN LET D = C - 87
1080 IF D < 0 OR D >= BS THEN RETURN
1090 IF N > INT((MX - D) / BS) THEN RETURN
1100 LET N = N * BS + D
1110 LET I = I + 1
1120 IF I <= LEN(V$) THEN GOTO 1040
1130 LET OK = 1
1140 RETURN
2000 REM Convert N to base TB and return the text in R$
2010 LET W = N : LET R$ = ""
2020 IF W <> 0 THEN GOTO 2050
2030 LET R$ = "0"
2040 RETURN
2050 LET Q = INT(W / TB)
2060 LET D = W - Q * TB
2070 LET R$ = MID$(DG$, D + 1, 1) + R$
2080 LET W = Q
2090 IF W > 0 THEN GOTO 2050
2100 RETURN
