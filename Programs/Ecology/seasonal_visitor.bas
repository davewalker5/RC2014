10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using a choice of integration methods
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "SEASONAL VISITOR"
80 PRINT "================"
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
1000 REM Seasonal model parameter initialisation
1010 REM 1. GROWTH
1020 REM 2. DECAY
1030 REM 3. OOS_DECAY
1040 REM 4. POST_PEAK_DECAY
1050 REM 5. POST_PEAK_SHARPNESS
1060 REM 6. SEASON_START
1070 REM 7. SEASON_END
1080 REM 8. SHARPNESS
1090 REM 9. FORCING_PEAK
1100 REM The following is the data for the Bluebell
1110 REM (Hyacinthoides non-scripta)
1120 DATA 3.345, 1.582, 4.536, 2.828, 5.42, 4.185, 5.595
1130 DATA 8.554, 4.88
1140 DIM MP(9)
1150 RESTORE
1160 FOR X = 1 TO 9
1170 READ MP(X)
1180 NEXT X
1190 RETURN
2000 REM Seasonal Model. Y relaxes towards a periodic
2010 REM winter target. This avoids the hard year-boundary
2020 REM problem seen when a single-year seasonal presence
2030 REM model starts from zero in January.
2040 REM T will run from e.g. 0 to 12 months in small steps
2050 REM so it's offset from the true month number by 1.
2060 REM Also, wrap it onto a 1..12 month cycle
2070 LET TM = T(I) + 1
2080 LET MO = (TM - 1) - 12 * INT((TM - 1) / 12) + 1
2090 REM Calculate the seasonal activity window
2100 GOSUB 2220
2110 REM Calculate the decay factor
2120 GOSUB 2370
2130 REM Seasonal forcing (pure Decimal raised cosine).
2140 REM This gives a smooth 0..1 annual forcing curve with
2150 REM its maximum at FORCING_PEAK (MP(9)), avoiding a
2160 REM hard zero in the first months of the year.
2170 LET TA = 6.2831853
2180 LET SF = (1.0 + COS(TA * (MO - MP(9)) / 12.0)) / 2.0
2190 REM Final ODE
2200 LET F = MP(1) * SF * AW - ED * Y(I)
2210 RETURN
2220 REM Generate a smooth seasonal activity window for
2230 REM non-winter seasonal species. The window is
2240 REM constructed from two sigmoid components:
2250 REM "rise", controlling the smooth onset of the
2260 REM season and "fall", controlling the smooth decline
2270 REM at the end of the season
2280 LET RI = 1.0 / (1.0 + EXP(-MP(8) * (MO - MP(6))))
2290 LET FA = 1.0 / (1.0 + EXP(MP(8) * (MO - MP(7))))
2300 REM The final seasonal gate is produced by mlutiplying
2310 REM the two together to give a smooth plateau-like
2320 REM activity region bounded by gradual transitions. It
2330 REM represents how strongly the species is to be
2340 REM considered "in season"
2350 LET AW = RI * FA
2360 RETURN
2370 REM Calculate the effective decay rate for the
2380 REM seasonal presence model. This is how quickly the
2390 REM model state declines at a given time of year by
2400 REM combining multiple decay mechanisms:
2410 REM - baseline decay
2420 REM - enhanced out-of-season decay
2430 REM - additional post-peak suppression decay
2440 LET PG = 1.0 / (1.0 + EXP(-MP(5) * (T(I) - MP(9))))
2450 LET ED = MP(2) + MP(3) * (1.0 - AW) + MP(4) * PG
2460 RETURN
3000 REM Euler integration: y = y + st * f(t, y)
3010 LET I = I + 1
3020 LET Y(I) = Y(I - 1) + ST * F
3030 RETURN
3100 REM Predict : Euler integration: y = y + st * f(t, y)
3110 LET OT = T(I)
3120 LET OY = Y(I)
3130 LET FY = F
3140 LET Y(I) = Y(I) + ST * F
3150 REM Correct
3160 LET T(I) = T(I) + ST : GOSUB 2000
3170 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
3180 LET Y(I) = OY : LET T(I) = OT : LET I = I + 1
3190 RETURN
3200 REM 4th-Order Runge-Kutta integration
3210 LET OY = Y(I) : LET OT = T(I)
3220 GOSUB 2000 : LET K1 = ST * F
3230 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K1 / 2.0
3240 GOSUB 2000 : LET K2 = ST * F
3250 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K2 / 2.0
3260 GOSUB 2000 : LET K3 = ST * F
3270 LET T(I) = OT + ST : LET Y(I) = OY + K3
3280 GOSUB 2000 : LET K4 = ST * F
3290 LET Y(I + 1) = OY + (K1 + 2 * K2 + 2 * K3 + K4) / 6.0
3300 LET T(I) = OT : LET Y(I) = OY : LET I = I + 1
3310 RETURN
3400 REM Integration with adaptive step size. Calculate the
3410 REM difference between full and half-step solutions,
3420 REM reducing the step size between each pass if the
3430 REM difference is > tolerance
3440 OI = I : OS = ST : AY = Y(I) : AT = T(I)
3450 REM Calculate for the full step first
3455 GOSUB 2000
3460 IF MT$ = "E" OR MT$ = "e" THEN GOSUB 3000
3470 IF MT$ = "P" OR MT$ = "p" THEN GOSUB 3100
3480 IF MT$ = "R" OR MT$ = "r" THEN GOSUB 3200
3490 REM Capture the result and reset the index and Y
3500 REM T remains unchanged by the integrators
3510 Y1 = Y(I) : I = OI : Y(I) = AY : T(I) = AT
3520 REM Now calculate for two half-steps
3530 ST = ST / 2.0
3535 IF AT + ST = AT THEN PRINT "Step size too small" : END
3540 REM First half-step
3545 GOSUB 2000
3550 IF MT$ = "E" OR MT$ = "e" THEN GOSUB 3000
3560 IF MT$ = "P" OR MT$ = "p" THEN GOSUB 3100
3570 IF MT$ = "R" OR MT$ = "r" THEN GOSUB 3200
3580 REM Copy the mid-point Y value back, as this is the
3590 REM starting point for the next half-step, reset the
3600 REM index and increment T
3610 Y(OI) = Y(I) : I = OI : T(I) = AT + ST
3620 REM Second half-step
3625 GOSUB 2000
3630 IF MT$ = "E" OR MT$ = "e" THEN GOSUB 3000
3640 IF MT$ = "P" OR MT$ = "p" THEN GOSUB 3100
3650 IF MT$ = "R" OR MT$ = "r" THEN GOSUB 3200
3660 REM Capture the result and calculate the difference
3670 T2 = AT + OS : Y2 = Y(I) : DY = ABS(Y2 - Y1)
3680 REM Restore the original values
3690 I = OI : ST = OS : Y(I) = AY : T(I) = AT
3700 REM If the difference is > tolerance, halve the step
3710 REM size and try again
3720 IF DY > DL THEN ST = ST / 2.0 : GOTO 3400
3730 REM Step size has produced a difference lying within
3740 REM the required tolerance - capture the values as
3750 REM the next step in the solution
3760 LET I = I + 1
3770 LET T(I) = T2
3780 LET Y(I) = Y2
3790 RETURN
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
