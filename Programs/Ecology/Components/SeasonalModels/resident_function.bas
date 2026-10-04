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
