10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using the Euler method
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "ODE SOLVER (EULER PREDICTOR-CORRECTOR)"
80 PRINT "======================================"
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
1000 REM Function parameter initialisation
1010 PRINT "A "; : INPUT A
1020 RETURN
2000 REM Function to Solve : dy/dt = Ay
2010 LET F = A * Y(I)
2020 RETURN
3000 REM Predict : Euler integration: y = y + st * f(t, y)
3010 LET OT = T(I)
3020 LET OY = Y(I)
3030 LET FY = F
3040 LET Y(I) = Y(I) + ST * F
3050 REM Correct
3060 LET T(I) = T(I) + ST : GOSUB 2000
3070 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
3080 LET Y(I) = OY : LET T(I) = OT : LET I = I + 1
3090 RETURN
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
5000 REM Text chart of T() and Y()
5010 REM SW = terminal width; PH = plot height
5020 SW = 80 : PH = 18 : PW = SW - 2
5030 NP = I - 1
5040 IF NP < 1 THEN RETURN
5050 REM Find the data limits
5060 TA = T(1) : TB = TA
5070 YA = Y(1) : YB = YA
5080 FOR J = 1 TO NP
5090 IF T(J) < TA THEN TA = T(J)
5100 IF T(J) > TB THEN TB = T(J)
5110 IF Y(J) < YA THEN YA = Y(J)
5120 IF Y(J) > YB THEN YB = Y(J)
5130 NEXT J
5140 REM Expand constant ranges to avoid division by zero
5150 IF TA = TB THEN TA = TA - 1 : TB = TB + 1
5160 IF YA = YB THEN YA = YA - 1 : YB = YB + 1
5170 REM Prepare blank row and horizontal axis
5180 BL$ = "" : AX$ = "+"
5190 FOR J = 1 TO PW
5200 BL$ = BL$ + " " : AX$ = AX$ + "-"
5210 NEXT J
5220 PRINT : PRINT
5230 PRINT "Y: "; YA; " to "; YB
5240 REM Print rows from highest Y to lowest Y
5250 FOR PR = PH - 1 TO 0 STEP -1
5260 LN$ = BL$
5270 FOR J = 1 TO NP
5280 QY = INT((Y(J)-YA)/(YB-YA)*(PH-1)+.5)
5290 IF QY <> PR THEN GOTO 5330
5300 QX = INT((T(J)-TA)/(TB-TA)*(PW-1)+.5)
5310 REM Replace the character at column QX with x
5320 LN$ = LEFT$(LN$,QX)+"x"+MID$(LN$,QX+2)
5330 NEXT J
5340 PRINT "|"; LN$
5350 NEXT PR
5360 PRINT AX$
5370 PRINT "T: "; TA; " to "; TB
5380 RETURN
