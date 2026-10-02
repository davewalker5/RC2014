10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using a choice of integration methods
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "ODE SOLVER"
80 PRINT "=========="
90 PRINT
100 PRINT "Integration methods:" : PRINT
110 PRINT "E) Euler" : PRINT "P) Predictor-Corrector"
120 PRINT "R) 4th-Order Runge-Kutta" : PRINT
130 PRINT "Which method do you want to use ";
140 INPUT MT$
150 IF MT$ = "E" OR MT$ = "e" THEN GOTO 190
160 IF MT$ = "P" OR MT$ = "p" THEN GOTO 190
170 IF MT$ = "R" OR MT$ = "r" THEN GOTO 190
180 PRINT "Invalid method" : GOTO 130
190 PRINT "Adaptive or fixed step size (A/F) ";
200 INPUT AS$
210 IF AS$ = "A" OR AS$ = "a" THEN GOTO 240
220 IF AS$ = "F" OR AS$ = "f" THEN GOTO 260
230 PRINT "Invalid step size type" : GOTO 190
240 PRINT "Tolerance "; : INPUT DL
250 IF DL <= 0 THEN PRINT "Invalid tolerance" : GOTO 240
260 PRINT "Initial Y "; : INPUT Y0
270 PRINT "Limit of T "; : INPUT TL
280 IF TL <= 0 THEN PRINT "Invalid limit" : GOTO 180
290 PRINT "Step Size "; : INPUT ST
300 IF ST <= 0 THEN PRINT "Invalid step size" : GOTO 180
310 IF (TL / ST) > MS THEN PRINT "Too many steps" : GOTO 180
320 PRINT "Tabulated or charted output (T/C) "; : INPUT OP$
330 IF OP$ = "T" OR OP$ = "t" THEN GOTO 360
340 IF OP$ = "C" OR OP$ = "c" THEN GOTO 360
350 PRINT "Invalid output type" : GOTO 320
360 REM f() Parameter Initialisation
370 GOSUB 1000
380 REM First step initialisation
390 LET I = 1
400 LET Y(I) = Y0 : LET Z = 0
410 LET CW=15
420 REM Solution loop
430 IF Z > TL THEN GOTO 560
440 IF I >= MS THEN PRINT "Point limit reached" : GOTO 560
450 PRINT "."; : LET T(I) = Z
460 REM Output the current parameters
470 REM Evaluate f() for this step
480 GOSUB 2000
490 REM Integrate : Adaptive step size
500 IF AS$ = "A" OR AS$ = "a" THEN GOSUB 3400 : GOTO 550
510 REM Integrate : Fixed step size
520 IF MT$ = "E" OR MT$ = "e" THEN GOSUB 3000
530 IF MT$ = "P" OR MT$ = "p" THEN GOSUB 3100
540 IF MT$ = "R" OR MT$ = "r" THEN GOSUB 3200
550 LET Z = T(I - 1) + ST : GOTO 430
560 REM Tabulate the results
570 IF OP$ = "T" OR OP$ = "t" THEN GOSUB 4000
580 REM Chart the results
590 IF OP$ = "C" OR OP$ = "c" THEN GOSUB 5000
600 END
