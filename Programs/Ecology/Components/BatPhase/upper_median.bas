2300 REM Calculate the median of the upper half of VP(),
2310 REM the valid PRI values. Recordings of bat call
2320 REM sequences may contain:
2330 REM - Very short PRI bursts
2340 REM - Buzz fragments
2350 REM - Dense calling
2360 REM - Pulse splitting
2370 REM - Heterodyne artefacts
2380 REM - Partial attack sequences
2390 REM Lots of tiny PRI values may make rapid calling look
2400 REM normal and cause the analysis to miss feeding
2410 REM buzzes. If VP() is sorted, the upper half will
2420 REM contain *longer* intervals and corresponds to more
2430 REM relaxed search behaviour. The median of those is
2440 REM a better baseline for detecting fast buzzes.
2450 LET HF = INT(NV / 2)
2460 LET NU = NV - HF
2470 LET MI = INT(NU / 2)
2480 IF NU - 2 * MI = 1 THEN UM = VP(HF + MI + 1) : RETURN
2490 LET UM = (VP(HF + MI) + VP(HF + MI + 1)) / 2
2500 RETURN
