10 REM Wind correction calculator
20 LET PI = 3.14159265
30 LET RD = PI / 180 : REM Degrees to radians
100 PRINT "WIND CORRECTION CALCULATOR"
110 PRINT "=========================="
120 PRINT ""
130 PRINT "Wind direction is where wind is from."
140 PRINT ""
200 REM Read and validate inputs
210 PRINT "Desired track (0 to 359 degrees true)"
220 INPUT TR
230 IF TR < 0 OR TR >= 360 THEN PRINT "Invalid track" : GOTO 210
240 PRINT "True airspeed (knots)"
250 INPUT TS
260 IF TS <= 0 THEN PRINT "Airspeed must be greater than zero" : GOTO 240
270 PRINT "Wind direction (0 to 359 degrees true)"
280 INPUT WD
290 IF WD < 0 OR WD >= 360 THEN PRINT "Invalid wind direction" : GOTO 270
300 PRINT "Wind speed (knots)"
310 INPUT WS
320 IF WS < 0 THEN PRINT "Wind speed cannot be negative" : GOTO 300
400 REM Calculate wind-correction angle
410 LET WA = (WD - TR) * RD
420 LET SR = WS * SIN(WA) / TS
430 IF ABS(SR) > 1 THEN GOTO 650
440 IF SR = 1 THEN LET WC = PI / 2 : GOTO 470
450 IF SR = -1 THEN LET WC = -PI / 2 : GOTO 470
460 LET WC = ATN(SR / SQR(1 - SR * SR))
470 LET HD = TR + WC / RD
480 IF HD >= 360 THEN LET HD = HD - 360
490 IF HD < 0 THEN LET HD = HD + 360
500 LET GS = TS * COS(WC) - WS * COS(WA)
510 IF GS <= 0 THEN GOTO 650
520 LET WC = WC / RD
530 IF WC < 0 THEN LET WC = -INT(-WC * 10 + .5) / 10 : GOTO 550
540 LET WC = INT(WC * 10 + .5) / 10
550 LET HD = INT(HD * 10 + .5) / 10
560 IF HD >= 360 THEN LET HD = 0
570 LET GS = INT(GS * 10 + .5) / 10
580 PRINT ""
590 PRINT "Wind-correction angle: "; WC; " degrees"
600 PRINT "Required heading: "; HD; " degrees true"
610 PRINT "Groundspeed: "; GS; " knots" : GOTO 700
650 PRINT ""
660 PRINT "Desired track cannot be maintained"
670 PRINT "with this airspeed and wind."
700 REM Offer another calculation
710 PRINT ""
720 PRINT "More? (Y/N) ";
730 INPUT M$
740 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
750 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 720
760 END
