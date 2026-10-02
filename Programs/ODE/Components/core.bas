10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the Euler method
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "ODE SOLVER (RK4)"
80 PRINT "================"
90 PRINT
100 PRINT "Initial Y "; : INPUT Y0
110 PRINT "Limit of T "; : INPUT TL
120 IF TL <= 0 THEN PRINT "Invalid limit" : GOTO 100
130 PRINT "Step Size "; : INPUT ST
140 IF ST <= 0 THEN PRINT "Invalid step size" : GOTO 100
150 IF (TL / ST) > MS THEN PRINT "Too many steps" : GOTO 100
160 PRINT "Tabulated or charted output (T/C) "; : INPUT OP$
170 IF OP$ = "T" OR OP$ = "t" THEN GOTO 200
180 IF OP$ = "C" OR OP$ = "c" THEN GOTO 200
190 PRINT "Invalid output type" : GOTO 160
200 REM f() Parameter Initialisation
210 GOSUB 1000
220 REM First step initialisation
230 LET I = 1
240 LET Y(I) = Y0
250 LET CW=15
260 REM Solution loop
270 FOR Z = 0.0 TO TL STEP ST
280 PRINT "."; : LET T(I) = Z
290 REM Output the current parameters
300 REM Evaluate f() for this step
310 GOSUB 2000
320 REM Integrate
330 GOSUB 3000
340 NEXT Z
350 REM Tabulate the results
360 IF OP$ = "T" OR OP$ = "t" THEN GOSUB 4000
370 REM Chart the results
380 IF OP$ = "C" OR OP$ = "c" THEN GOSUB 5000
390 END
