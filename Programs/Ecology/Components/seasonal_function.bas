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
