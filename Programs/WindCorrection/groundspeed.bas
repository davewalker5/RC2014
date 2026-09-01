10 REM Groundspeed calculator
20 LET PI = 3.14159265
30 LET RD = PI / 180 : REM Degrees to radians
100 PRINT "GROUNDSPEED CALCULATOR"
110 PRINT "======================"
120 PRINT ""
130 PRINT "Wind direction is where wind is from."
140 PRINT ""
200 REM Read and validate inputs
210 PRINT "Aircraft heading (0 to 359 degrees true)"
220 INPUT HD
230 IF HD < 0 OR HD >= 360 THEN PRINT "Invalid heading" : GOTO 210
240 PRINT "True airspeed (knots)"
250 INPUT TS
260 IF TS <= 0 THEN PRINT "Airspeed must be greater than zero" : GOTO 240
270 PRINT "Wind direction (0 to 359 degrees true)"
280 INPUT WD
290 IF WD < 0 OR WD >= 360 THEN PRINT "Invalid wind direction" : GOTO 270
300 PRINT "Wind speed (knots)"
310 INPUT WS
320 IF WS < 0 THEN PRINT "Wind speed cannot be negative" : GOTO 300
400 REM Add north and east velocity components
410 LET AN = HD * RD
420 LET WN = (WD + 180) * RD
430 LET NV = TS * COS(AN) + WS * COS(WN)
440 LET EV = TS * SIN(AN) + WS * SIN(WN)
450 LET GS = SQR(NV * NV + EV * EV)
460 IF GS < .001 THEN GOTO 650
500 REM Find track with an ATN2 equivalent
510 IF NV = 0 AND EV > 0 THEN LET TR = 90 : GOTO 560
520 IF NV = 0 AND EV < 0 THEN LET TR = 270 : GOTO 560
530 LET TR = ATN(EV / NV) / RD
540 IF NV < 0 THEN LET TR = TR + 180
550 IF NV > 0 AND EV < 0 THEN LET TR = TR + 360
560 LET TR = INT(TR * 10 + .5) / 10
570 IF TR >= 360 THEN LET TR = 0
580 LET GS = INT(GS * 10 + .5) / 10
590 PRINT ""
600 PRINT "Ground track: "; TR; " degrees true"
610 PRINT "Groundspeed: "; GS; " knots" : GOTO 700
650 PRINT ""
660 PRINT "Groundspeed: 0 knots"
670 PRINT "Ground track is undefined."
700 REM Offer another calculation
710 PRINT ""
720 PRINT "More? (Y/N) ";
730 INPUT M$
740 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
750 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 720
760 END
