10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the 4th-Order Runge-Kutta method
30 LET MS = 1000 : DIM Y(1000), T(1000)
40 PRINT
50 PRINT "ODE SOLVER (RK4)"
60 PRINT "================"
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
230 LET OY = Y(I) : LET OT = T(I)
240 REM 4th-Order Runge-Kutta integration
250 GOSUB 2000 : LET K1 = ST * F
260 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K1 / 2.0
270 GOSUB 2000 : LET K2 = ST * F
280 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K2 / 2.0
290 GOSUB 2000 : LET K3 = ST * F
300 LET T(I) = OT + ST : LET Y(I) = OY + K3
310 GOSUB 2000 : LET K4 = ST * F
320 LET Y(I + 1) = OY + (K1 + 2 * K2 + 2 * K3 + K4) / 6.0
330 LET T(I) = OT : LET Y(I) = OY : LET I = I + 1
340 NEXT Z
350 REM Tabulate the results
360 PRINT : PRINT
370 REM Print table column headers
380 LET PD$ = " "
390 LET V$ = "Step" : GOSUB 550 : PRINT " ";
400 LET V$ = "T" : GOSUB 550 : PRINT " ";
410 LET V$ = "Y" : GOSUB 550 : PRINT
420 REM Print table header separator
430 LET PD$ = "-"
440 LET V$ = "-" : GOSUB 550 : PRINT " ";
450 LET V$ = "-" : GOSUB 550 : PRINT " ";
460 LET V$ = "-" : GOSUB 550 : PRINT
470 LET PD$ = " "
480 REM Iterate over and tabulate the results
490 FOR X = 1 TO I - 1
500 LET V$ = STR$(X) : GOSUB 550 : PRINT " ";
510 LET V$ = STR$(T(X)) : GOSUB 550 : PRINT " ";
520 LET V$ = STR$(Y(X)) : GOSUB 550 : PRINT
530 NEXT X
540 END
550 REM Format and print one column
560 IF LEFT$(V$,1) = " " THEN V$ = MID$(V$,2)
570 IF LEN(V$) <= CW THEN GOTO 600
580 V$ = ""
590 IF LEN(V$) < CW THEN V$ = V$ + "*" : GOTO 590
600 IF LEN(V$) < CW THEN V$ = PD$ + V$ : GOTO 600
610 PRINT V$;
620 RETURN
1000 REM Function parameter initialisation
1010 PRINT "A "; : INPUT A
1020 RETURN
2000 REM Function to Solve : dy/dt = Ay
2010 LET F = A * Y(I)
2020 RETURN
