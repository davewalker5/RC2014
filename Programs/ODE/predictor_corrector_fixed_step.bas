10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the Euler Predictor-Corrector method
30 LET MS = 1000 : DIM Y(1000), T(1000)
40 PRINT
50 PRINT "ODE SOLVER (EULER PREDICTOR-CORRECTOR)"
60 PRINT "======================================"
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
170 LET I = 1 : LET Y(I) = Y0 : LET CW=15
180 REM Solution loop
190 FOR Z = 0.0 TO TL STEP ST
200 PRINT "."; : LET T(I) = Z
210 REM Evaluate f() for this step
220 GOSUB 2000
230 REM Predict : Euler integration: y = y + st * f(t, y)
240 LET OY = Y(I) : LET FY = F : LET Y(I) = Y(I) + ST * F
250 REM Correct
260 LET T(I) = T(I) + ST : GOSUB 2000
270 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
280 LET Y(I) = OY : LET T = T - ST : LET I = I + 1
290 NEXT Z
300 REM Tabulate the results
310 PRINT : PRINT
320 REM Print table column headers
330 LET PD$ = " "
340 LET V$ = "Step" : GOSUB 500 : PRINT " ";
350 LET V$ = "T" : GOSUB 500 : PRINT " ";
360 LET V$ = "Y" : GOSUB 500 : PRINT
370 REM Print table header separator
380 LET PD$ = "-"
390 LET V$ = "-" : GOSUB 500 : PRINT " ";
400 LET V$ = "-" : GOSUB 500 : PRINT " ";
410 LET V$ = "-" : GOSUB 500 : PRINT
420 LET PD$ = " "
430 REM Iterate over and tabulate the results
440 FOR X = 1 TO I - 1
450 LET V$ = STR$(X) : GOSUB 500 : PRINT " ";
460 LET V$ = STR$(T(X)) : GOSUB 500 : PRINT " ";
470 LET V$ = STR$(Y(X)) : GOSUB 500 : PRINT
480 NEXT X
490 END
500 REM Format and print one column
510 IF LEFT$(V$,1) = " " THEN V$ = MID$(V$,2)
520 IF LEN(V$) <= CW THEN GOTO 550
530 V$ = ""
540 IF LEN(V$) < CW THEN V$ = V$ + "*" : GOTO 540
550 IF LEN(V$) < CW THEN V$ = PD$ + V$ : GOTO 550
560 PRINT V$;
570 RETURN
1000 REM Function parameter initialisation
1010 PRINT "A "; : INPUT A
1020 RETURN
2000 REM Function to Solve : dy/dt = Ay
2010 LET F = A * Y(I)
2020 RETURN
