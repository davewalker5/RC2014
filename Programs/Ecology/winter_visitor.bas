10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using a choice of integration methods
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "WINTER VISITOR"
80 PRINT "=============="
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
1000 REM Winter visitor model parameter initialisation
1010 REM 1. GROWTH_RATE
1020 REM 2. DECAY_RATE
1030 REM 3. BASELINE
1040 REM 4. WINTER_WEIGHT
1050 REM 5. AUTUMN_WEIGHT
1060 REM 6. WINTER_PEAK
1070 REM 7. AUTUMN_PEAK
1080 REM 8. WINTER_WIDTH
1090 REM 9. AUTUMN_WIDTH
1100 REM 10. SUMMER_DIP
1110 REM 11. SUMMER_LOW
1120 REM 12. SUMMER_WIDTH
1130 REM The following is the data for the Redwing
1140 REM (Turdus iliacus)
1150 DATA 0.617, 2.297, 0, 0.986, 0.262, 1.53, 11.67
1160 DATA 3.074, 4.105, 0.188, 6.55, 3.288
1170 DIM MP(12)
1180 RESTORE
1190 FOR X = 1 TO 12
1200 READ MP(X)
1210 NEXT X
1220 RETURN
2000 REM Winter Visitor ODE. Y relaxes towards a periodic
2010 REM winter target. This avoids the hard year-boundary
2020 REM problem seen when a single-year seasonal presence
2030 REM model starts from zero in January.
2040 REM T will run from e.g. 0 to 12 months in small steps
2050 REM so it's offset from the true month number by 1.
2060 REM Also, wrap it onto a 1..12 month cycle
2070 LET TM = T(I) + 1
2080 LET MO = (TM - 1) - 12 * INT((TM - 1) / 12) + 1
2090 REM Calculate the target value at time 't' and use it
2100 REM to determine the growth/decay rate
2110 GOSUB 2200
2120 IF TG > Y(I) THEN LET RT = MP(1)
2130 IF TG <= Y(I) THEN LET RT = MP(2)
2140 LET F = RT * ( TG - Y(I) )
2150 RETURN
2200 REM Construct the seasonal target curve for a winter
2210 REM visitor species. The model assumes that winter
2220 REM visitor dynamics can be approximated as:
2230 REM - a dominant winter residency peak
2240 REM - an autumn arrival/build-up phase
2250 REM - a summer suppression component
2260 REM - a low baseline detectability level
2270 REM Calculate the main winter residency component,
2280 REM peaking around the core winter months and
2290 REM representing the primary period of detectability
2300 LET PK = MP(6) : LET WD = MP(8) : GOSUB 2500
2310 LET WI = BU
2320 REM Calculate the secondary autumn arrival/build-up
2330 REM component, representing pre-winter arrival,
2340 REM migration build-up, or early seasonal movement
2350 REM before the main winter peak is reached.
2360 LET PK = MP(7) : LET WD = MP(9) : GOSUB 2500
2370 LET AU = BU
2380 REM Calculate the ummer suppression component. This
2390 REM component is subtracted from the target to reduce
2400 REM simulated presence during the summer period when
2410 REM winter visitors are typically absent
2420 LET PK = MP(11) : LET WD = MP(12) : GOSUB 2500
2430 LET SU = BU
2440 REM Calculate the seasonal target
2450 TG = MP(3) + MP(4) * WI + MP(5) * AU - MP(10) * SU
2460 IF TG < 0.0 THEN LET TG = 0.0
2470 RETURN
2500 REM Generate a smooth cyclic seasonal bump centred
2510 REM on a specified month
2520 LET TA = 6.2831853
2530 AG = TA * (MO - PK) / 12.0
2540 PO = (1.0 + COS(AG)) / 2.0
2550 IF PO <= 0.0 THEN LET BU = 0.0 : RETURN
2560 IF PO >= 1.0 THEN LET BU = 1.0 : RETURN
2570 LET BU = EXP(WD * LOG(PO))
2580 RETURN
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
