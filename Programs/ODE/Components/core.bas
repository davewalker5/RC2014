10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the Euler method
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
190 PRINT "Initial Y "; : INPUT Y0
200 PRINT "Limit of T "; : INPUT TL
210 IF TL <= 0 THEN PRINT "Invalid limit" : GOTO 180
220 PRINT "Step Size "; : INPUT ST
230 IF ST <= 0 THEN PRINT "Invalid step size" : GOTO 180
240 IF (TL / ST) > MS THEN PRINT "Too many steps" : GOTO 180
250 PRINT "Tabulated or charted output (T/C) "; : INPUT OP$
260 IF OP$ = "T" OR OP$ = "t" THEN GOTO 290
270 IF OP$ = "C" OR OP$ = "c" THEN GOTO 290
280 PRINT "Invalid output type" : GOTO 250
290 REM f() Parameter Initialisation
300 GOSUB 1000
310 REM First step initialisation
320 LET I = 1
330 LET Y(I) = Y0
340 LET CW=15
350 REM Solution loop
360 FOR Z = 0.0 TO TL STEP ST
370 PRINT "."; : LET T(I) = Z
380 REM Output the current parameters
390 REM Evaluate f() for this step
400 GOSUB 2000
410 REM Integrate
420 IF MT$ = "E" OR MT$ = "e" THEN GOSUB 3000
430 IF MT$ = "P" OR MT$ = "p" THEN GOSUB 3100
440 IF MT$ = "R" OR MT$ = "r" THEN GOSUB 3200
450 NEXT Z
460 REM Tabulate the results
470 IF OP$ = "T" OR OP$ = "t" THEN GOSUB 4000
480 REM Chart the results
490 IF OP$ = "C" OR OP$ = "c" THEN GOSUB 5000
500 END
