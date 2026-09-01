10 REM Wind component calculator
20 LET PI = 3.14159265
30 LET RD = PI / 180 : REM Degrees to radians
100 PRINT "WIND COMPONENT CALCULATOR"
110 PRINT "========================="
120 PRINT ""
130 PRINT "Wind direction is where wind is from."
140 PRINT ""
200 REM Read and validate inputs
210 PRINT "Runway heading (0 to 359 degrees)"
220 INPUT RH
230 IF RH < 0 OR RH >= 360 THEN PRINT "Invalid runway heading" : GOTO 210
240 PRINT "Wind direction (0 to 359 degrees)"
250 INPUT WD
260 IF WD < 0 OR WD >= 360 THEN PRINT "Invalid wind direction" : GOTO 240
270 PRINT "Wind speed (knots)"
280 INPUT WS
290 IF WS < 0 THEN PRINT "Wind speed cannot be negative" : GOTO 270
300 REM Calculate wind components
310 LET WA = (WD - RH) * RD
320 LET HW = WS * COS(WA)
330 LET CW = WS * SIN(WA)
340 LET HA = ABS(HW)
350 LET CA = ABS(CW)
360 LET HA = INT(HA * 10 + .5) / 10
370 LET CA = INT(CA * 10 + .5) / 10
400 REM Display component directions and magnitudes
410 PRINT ""
420 IF HA = 0 THEN PRINT "Head/tailwind: 0 knots" : GOTO 450
430 IF HW > 0 THEN PRINT "Headwind: "; HA; " knots" : GOTO 450
440 PRINT "Tailwind: "; HA; " knots"
450 IF CA = 0 THEN PRINT "Crosswind: 0 knots" : GOTO 500
460 IF CW > 0 THEN PRINT "Crosswind: "; CA; " knots from right" : GOTO 500
470 PRINT "Crosswind: "; CA; " knots from left"
500 REM Offer another calculation
510 PRINT ""
520 PRINT "More? (Y/N) ";
530 INPUT M$
540 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
550 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 520
560 END
