10 REM Solve an Ordinary Differential Equation (ODE)
20 REM using a choice of integration methods
30 REM Allocate more string space before dimensioning arrays
40 CLEAR 2000
50 LET MS = 1000 : DIM Y(1000), T(1000)
60 PRINT
70 PRINT "RESIDENT DETECTABILITY"
80 PRINT "======================"
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
1000 REM Resident detectability model parameter
1010 REM initialisation
1020 REM 1. GROWTH_RATE
1030 REM 2. DECAY_RATE
1040 REM 3. SUMMER_DECAY_BOOST
1050 REM 4. PRE_SUMMER_DECAY_REDUCTION
1060 REM 5. PRE_SUMMER_DECAY_END
1070 REM 6. PRE_SUMMER_DECAY_SHARPNESS
1080 REM 7. SPRING_CARRYOVER_WEIGHT
1090 REM 8. SPRING_CARRYOVER_END
1100 REM 9. SPRING_CARRYOVER_SHARPNESS
1110 REM 10. BASELINE
1120 REM 11. WINTER_WEIGHT
1130 REM 12. AUTUMN_WEIGHT
1140 REM 13. WINTER_PEAK
1150 REM 14. AUTUMN_PEAK
1160 REM 15. AUTUMN_ONSET
1170 REM 16. AUTUMN_GATE_SHARPNESS
1180 REM 17. WINTER_WIDTH
1190 REM 18. WINTER_RISE_WIDTH
1200 REM 19. WINTER_FALL_WIDTH
1210 REM 20. AUTUMN_WIDTH
1220 REM 21. AUTUMN_RISE_WIDTH
1230 REM 22. AUTUMN_FALL_WIDTH
1240 REM 23. SUMMER_DIP
1250 REM 24. SUMMER_LOW
1260 REM 25. SUMMER_ONSET
1270 REM 26. SUMMER_GATE_SHARPNESS
1280 REM 27. SUMMER_DECAY_ONSET
1290 REM 28. SUMMER_DECAY_GATE_SHARPNESS
1300 REM 29. SUMMER_WIDTH
1310 REM 30. SUMMER_RISE_WIDTH
1320 REM 31. SUMMER_FALL_WIDTH
1330 REM 32. SCALE
1340 REM 33. YEAR_END_WEIGHT
1350 REM 34. YEAR_END_PEAK
1360 REM 35. YEAR_END_WIDTH
1370 REM 36. YEAR_END_RISE_WIDTH
1380 REM 37. YEAR_END_FALL_WIDTH
1390 REM The following is the data for the Blackbird
1400 REM (Turdus merula)
1410 DATA 2.04, 2.477, 4.388, 0.486, 7.245, 6.676, 0.285
1420 DATA 7.14, 17.608, 0.369, 0.316, 0.02, 3.165, 10.955
1430 DATA 10.815, 7.04, 11.35, 11.584, 11.882, 6.309, 5.614
1440 DATA 6.913, 0.182, 8.965, 7.125, 3.458, 7.13, 13.265
1450 DATA 26.087, 41.09, 12.577, 1.316, 0.182, 12.154
1460 DATA 86.954, 162.556, 11.63
1470 DIM MP(37)
1480 RESTORE
1490 FOR X = 1 TO 37
1500 READ MP(X)
1510 NEXT X
1520 RETURN
2000 REM Resident detectability ODE. Y relaxes towards a
2010 REM seasonal target with separate growth/decay rates
2020 REM Wrap solver time onto the repeating month cycle
2030 LET TM = T(I) + 1
2040 LET MO = (TM - 1) - 12 * INT((TM - 1) / 12) + 1
2050 GOSUB 2300
2060 LET RT = MP(1)
2070 IF TG > Y(I) THEN GOTO 2250
2080 REM Reduce decay before the pre-summer retention end
2090 LET GN = MP(5) : LET SH = MP(6) : LET IV = 1
2100 GOSUB 2800
2110 LET DR = MP(4)
2120 IF DR < 0.0 THEN LET DR = 0.0
2130 IF DR > 0.95 THEN LET DR = 0.95
2140 LET ED = MP(2) * (1.0 - DR * GA)
2150 REM Gate summer decay acceleration independently
2160 REM from the summer target suppression component
2170 LET GN = MP(27) : LET SH = MP(28) : LET IV = 0
2180 GOSUB 2800
2190 LET RT = ED + MP(3) * SU * GA
2250 LET F = RT * (TG - Y(I))
2260 RETURN
2300 REM Construct the resident seasonal target curve
2310 REM Main winter detectability support
2320 LET PK = MP(13) : LET RW = MP(18) : LET FW = MP(19)
2330 GOSUB 2650 : LET WI = BU
2340 REM Autumn recovery with a direct, one-way onset gate
2350 LET PK = MP(14) : LET RW = MP(21) : LET FW = MP(22)
2360 GOSUB 2650 : LET AU = BU
2370 LET GN = MP(15) : LET SH = MP(16) : LET IV = 0
2380 LET MD = MO - GN : GOSUB 2850
2390 LET AU = AU * GA
2400 REM Summer suppression with a circular onset gate
2410 LET PK = MP(24) : LET RW = MP(30) : LET FW = MP(31)
2420 GOSUB 2650 : LET SU = BU
2430 LET GN = MP(25) : LET SH = MP(26) : LET IV = 0
2440 GOSUB 2800 : LET SU = SU * GA
2450 REM Additional year-end detectability reinforcement
2460 LET PK = MP(34) : LET RW = MP(36) : LET FW = MP(37)
2470 GOSUB 2650 : LET YE = BU
2480 REM Spring carry-over uses the inverted circular gate
2490 LET GN = MP(8) : LET SH = MP(9) : LET IV = 1
2500 GOSUB 2800 : LET SC = GA
2510 LET TG = MP(10) + MP(11) * WI + MP(12) * AU
2520 LET TG = TG + MP(33) * YE + MP(7) * SC - MP(23) * SU
2530 IF TG < 0.0 THEN LET TG = 0.0
2540 RETURN
2650 REM Asymmetric annual bump: PK = peak month,
2660 REM RW/FW = rise/fall widths, BU = returned bump
2670 LET TA = 6.2831853
2680 LET AG = TA * (MO - PK) / 12.0
2690 LET PO = (1.0 + COS(AG)) / 2.0
2700 IF PO <= 0.0 THEN LET BU = 0.0 : RETURN
2710 IF PO >= 1.0 THEN LET BU = 1.0 : RETURN
2720 LET MD = MO - PK : GOSUB 2950
2730 LET WD = RW
2740 IF MD > 0.0 THEN LET WD = FW
2750 LET BU = EXP(WD * LOG(PO))
2760 RETURN
2800 REM Circular onset gate: GN = onset, SH = sharpness,
2810 REM IV = invert flag (0/1), GA = returned gate
2820 LET MD = MO - GN : GOSUB 2950
2830 GOSUB 2850
2840 RETURN
2850 REM Logistic gate using month distance MD. A zero
2860 REM or negative sharpness disables the gate
2870 LET GA = 1.0
2880 IF SH <= 0.0 THEN RETURN
2890 LET GX = SH * MD
2900 IF GX > 40.0 THEN RETURN
2910 IF GX < -40.0 THEN LET GA = 0.0 : RETURN
2920 LET GA = 1.0 / (1.0 + EXP(-GX))
2930 IF IV <> 0 THEN LET GA = 1.0 - GA
2940 RETURN
2950 REM Signed shortest month distance, -6 to +6
2960 LET MD = MD + 6.0
2970 LET MD = MD - 12.0 * INT(MD / 12.0) - 6.0
2980 RETURN
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
