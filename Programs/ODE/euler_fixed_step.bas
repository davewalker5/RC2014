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
1000 REM Function parameter initialisation
1010 PRINT "A "; : INPUT A
1020 RETURN
2000 REM Function to Solve : dy/dt = Ay
2010 LET F = A * Y(I)
2020 RETURN
3000 REM Euler integration: y = y + st * f(t, y)
3010 LET I = I + 1
3020 LET Y(I) = Y(I - 1) + ST * F
3030 RETURN
4000 REM Tabulate the results
4010 PRINT : PRINT
4020 REM Print table column headers
4030 LET PD$ = " "
4040 LET V$ = "Step" : GOSUB 4200 : PRINT " ";
4050 LET V$ = "T" : GOSUB 4200 : PRINT " ";
4060 LET V$ = "Y" : GOSUB 4200 : PRINT
4070 REM Print table header separator
4080 LET PD$ = "-"
4090 LET V$ = "-" : GOSUB 4200 : PRINT " ";
4100 LET V$ = "-" : GOSUB 4200 : PRINT " ";
4110 LET V$ = "-" : GOSUB 4200 : PRINT
4120 LET PD$ = " "
4130 REM Iterate over and tabulate the results
4140 FOR X = 1 TO I - 1
4150 LET V$ = STR$(X) : GOSUB 4200 : PRINT " ";
4160 LET V$ = STR$(T(X)) : GOSUB 4200 : PRINT " ";
4170 LET V$ = STR$(Y(X)) : GOSUB 4200 : PRINT
4180 NEXT X
4190 RETURN
4200 REM Format and print one column
4210 IF LEFT$(V$,1) = " " THEN V$ = MID$(V$,2)
4220 IF LEN(V$) <= CW THEN GOTO 4250
4230 V$ = ""
4240 IF LEN(V$) < CW THEN V$ = V$ + "*" : GOTO 4240
4250 IF LEN(V$) < CW THEN V$ = PD$ + V$ : GOTO 4250
4260 PRINT V$;
4270 RETURN
