10 REM Great circle distance calculator
20 LET PI = 3.14159265
30 LET RD = PI / 180 : REM Degrees to radians
40 LET NK = 1.852 : REM Kilometres in one nautical mile
100 REM Read and validate the first position
110 PRINT "GREAT CIRCLE DISTANCE"
115 PRINT "====================="
120 PRINT ""
130 PRINT "First latitude (-90 to 90)"
140 INPUT L1
150 IF L1 < -90 OR L1 > 90 THEN PRINT "Invalid latitude" : GOTO 130
160 PRINT "First longitude (-180 to 180)"
170 INPUT O1
180 IF O1 < -180 OR O1 > 180 THEN PRINT "Invalid longitude" : GOTO 160
200 REM Read and validate the second position
210 PRINT "Second latitude (-90 to 90)"
220 INPUT L2
230 IF L2 < -90 OR L2 > 90 THEN PRINT "Invalid latitude" : GOTO 210
240 PRINT "Second longitude (-180 to 180)"
250 INPUT O2
260 IF O2 < -180 OR O2 > 180 THEN PRINT "Invalid longitude" : GOTO 240
300 REM Calculate distance with the haversine formula
310 GOSUB 1000
320 PRINT ""
330 PRINT "Distance: "; DS; " nautical miles"
340 PRINT "          "; DS * NK; " kilometres"
400 REM Offer another calculation
410 PRINT ""
420 PRINT "More? (Y/N) ";
430 INPUT M$
440 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
450 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 420
460 END
1000 REM Calculate distance from L1,O1 to L2,O2 in nautical miles
1010 LET DL = (L2 - L1) * RD
1020 LET DO = (O2 - O1) * RD
1030 LET HA = SIN(DL / 2) ^ 2
1040 LET HA = HA + COS(L1 * RD) * COS(L2 * RD) * SIN(DO / 2) ^ 2
1050 IF HA < 0 THEN LET HA = 0
1060 IF HA > 1 THEN LET HA = 1
1070 IF HA = 1 THEN LET AN = PI : GOTO 1090
1080 LET AN = 2 * ATN(SQR(HA / (1 - HA)))
1090 LET DS = 3440.065 * AN
1100 RETURN
