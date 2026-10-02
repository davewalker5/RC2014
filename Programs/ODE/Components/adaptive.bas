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
