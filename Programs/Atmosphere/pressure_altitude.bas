10 REM Pressure altitude calculator
20 LET SP = 1013.25 : REM Standard pressure, hPa
30 LET PF = 29.53 : REM Feet per hPa
100 PRINT "PRESSURE ALTITUDE CALCULATOR"
110 PRINT "============================"
120 PRINT ""
130 PRINT "Uses QNH pressure in hPa"
200 REM Read and validate inputs
210 PRINT ""
220 PRINT "Airfield elevation (-2000 to 20000 feet)"
230 INPUT EL
240 IF EL < -2000 OR EL > 20000 THEN PRINT "Invalid airfield elevation" : GOTO 220
250 PRINT "QNH pressure setting (800 to 1100 hPa)"
260 INPUT QN
270 IF QN < 800 OR QN > 1100 THEN PRINT "Invalid pressure setting" : GOTO 250
300 REM Apply rule-of-thumb pressure correction
310 LET PA = EL + (SP - QN) * PF
320 IF PA < 0 THEN LET PA = -INT(-PA + .5) : GOTO 400
330 LET PA = INT(PA + .5)
400 PRINT ""
410 PRINT "Pressure altitude: "; PA; " feet"
500 REM Offer another calculation
510 PRINT ""
520 PRINT "More? (Y/N) ";
530 INPUT M$
540 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
550 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 520
560 END
