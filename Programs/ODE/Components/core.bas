10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the Euler method
30 LET MS = 1000 : DIM Y(1000), T(1000)
40 PRINT
50 PRINT "ODE SOLVER (EULER)"
60 PRINT "=================="
70 PRINT
80 PRINT "Initial Y "; : INPUT Y0
90 PRINT "Limit of T "; : INPUT TL
100 IF TL <= 0 THEN PRINT "Invalid limit" : GOTO 50
110 PRINT "Step Size "; : INPUT ST
120 IF ST <= 0 THEN PRINT "Invalid step size" : GOTO 50
130 IF (TL / ST) > MS THEN PRINT "Too many steps" : GOTO 50
140 REM f() Parameter Initialisation
150 GOSUB 1000
160 REM First step initialisation
170 LET I = 1
171 LET Y(I) = Y0
172 LET CW=15
180 REM Solution loop
190 FOR Z = 0.0 TO TL STEP ST
200 PRINT "."; : LET T(I) = Z
210 REM Output the current parameters
220 REM Evaluate f() for this step
230 GOSUB 2000
240 REM Integrate
250 GOSUB 3000
260 NEXT Z
270 REM Tabulate the results
280 GOSUB 4000
290 END

