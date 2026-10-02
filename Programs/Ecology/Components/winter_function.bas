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
