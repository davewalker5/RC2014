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
170 LET I = 1 : LET Y(I) = Y0 : LET CW=15
180 REM Solution loop
190 FOR Z = 0.0 TO TL STEP ST
200 PRINT "."; : LET T(I) = Z
210 REM Output the current parameters
220 REM Evaluate f() for this step
230 GOSUB 2000
240 REM Euler integration: y = y + st * f(t, y)
250 LET I = I + 1: LET Y(I) = Y(I - 1) + ST * F
260 NEXT Z
270 REM Tabulate the results
280 PRINT : PRINT
290 REM Print table column headers
300 LET PD$ = " "
310 LET V$ = "Step" : GOSUB 470 : PRINT " ";
320 LET V$ = "T" : GOSUB 470 : PRINT " ";
330 LET V$ = "Y" : GOSUB 470 : PRINT
340 REM Print table header separator
350 LET PD$ = "-"
360 LET V$ = "-" : GOSUB 470 : PRINT " ";
370 LET V$ = "-" : GOSUB 470 : PRINT " ";
380 LET V$ = "-" : GOSUB 470 : PRINT
390 LET PD$ = " "
400 REM Iterate over and tabulate the results
410 FOR X = 1 TO I - 1
420 LET V$ = STR$(X) : GOSUB 470 : PRINT " ";
430 LET V$ = STR$(T(X)) : GOSUB 470 : PRINT " ";
440 LET V$ = STR$(Y(X)) : GOSUB 470 : PRINT
450 NEXT X
460 END
470 REM Format and print one column
480 IF LEFT$(V$,1) = " " THEN V$ = MID$(V$,2)
490 IF LEN(V$) <= CW THEN GOTO 520
500 V$ = ""
510 IF LEN(V$) < CW THEN V$ = V$ + "*" : GOTO 510
520 IF LEN(V$) < CW THEN V$ = PD$ + V$ : GOTO 520
530 PRINT V$;
540 RETURN
1000 REM Function parameter initialisation
1010 PRINT "A "; : INPUT A
1020 RETURN
2000 REM Function to Solve : dy/dt = Ay
2010 LET F = A * Y(I)
2020 RETURN
