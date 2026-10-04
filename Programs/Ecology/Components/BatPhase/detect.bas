3300 REM Detect behavioural phases within a bat pulse
3310 REM sequence using pulse timing structure, classifying
3320 REM each pulse as one of SEARCH, APPROACH, BUZZ or
3330 REM EXIT.
3340 REM Inputs:  NP, UM, P(), PV(), D(), DV()
3350 REM Outputs: PH$(), plus regions from subroutine 3000
3360 REM The caller must dimension input/output arrays to
3370 REM at least NP and UM must be calculated from the
3380 REM valid PRIs first
3390 LET NR = 0 : LET BF = 0
3400 IF NP < 1 THEN RETURN
3410 FOR I = 1 TO NP
3420 LET PH$(I) = "SEARCH"
3430 NEXT I
3440 IF NP < 6 THEN GOTO 4000
3450 REM No valid PRI means there is no baseline
3460 LET VC = 0
3470 FOR I = 1 TO NP
3480 IF PV(I) <> 0 THEN LET VC = VC + 1
3490 NEXT I
3500 IF VC = 0 THEN GOTO 4000
3510 LET BT = UM * 0.70 : LET AT = UM * 0.90
3520 LET RL = 0 : LET NC = 0 : LET SU = 0
3530 LET BF = 0
3540 REM Find and score runs of compressed PRIs
3550 FOR I = 1 TO NP
3560 IF PV(I) = 0 THEN GOTO 3640
3570 IF P(I) > BT THEN GOTO 3640
3580 IF RL > 0 THEN GOTO 3600
3590 LET RS = I
3600 LET RL = RL + 1 : LET SU = SU + P(I)
3610 IF DV(I) = 0 THEN GOTO 3660
3620 IF D(I) < 0 THEN LET NC = NC + 1
3630 GOTO 3660
3640 IF RL >= 4 THEN GOSUB 3930
3650 LET RL = 0 : LET NC = 0 : LET SU = 0
3660 NEXT I
3670 REM Catch a run reaching the end
3680 LET I = NP + 1
3690 IF RL >= 4 THEN GOSUB 3930
3700 IF BF = 0 THEN GOTO 4000
3710 REM Include the pulse following the final buzz PRI
3720 LET BE = BE + 1
3730 IF BE > NP THEN LET BE = NP
3740 FOR I = BS TO BE
3750 LET PH$(I) = "BUZZ"
3760 NEXT I
3770 REM Walk backwards to label the approach
3780 LET I = BS - 1
3790 IF I < 1 THEN GOTO 3870
3800 IF PV(I) = 0 THEN GOTO 3820
3810 IF P(I) <= AT THEN GOTO 3840
3820 IF DV(I) = 0 THEN GOTO 3870
3830 IF D(I) >= 0 THEN GOTO 3870
3840 LET PH$(I) = "APPROACH"
3850 LET I = I - 1
3860 GOTO 3790
3870 REM Label pulses after the buzz as exit
3880 IF BE >= NP THEN GOTO 4000
3890 FOR I = BE + 1 TO NP
3900 LET PH$(I) = "EXIT"
3910 NEXT I
3920 GOTO 4000
3930 REM Score current run; I is one past its final PRI
3940 LET SC = RL * 10 + NC * 2 + ((RS - 1) / NP) * 3 - SU / RL
3950 IF BF = 0 THEN GOTO 3970
3960 IF SC <= BC THEN RETURN
3970 LET BF = 1 : LET BC = SC
3980 LET BS = RS : LET BE = I - 1
3990 RETURN
4000 GOSUB 3000
4010 RETURN
