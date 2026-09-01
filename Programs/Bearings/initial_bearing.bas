10 REM Initial great-circle bearing calculator
20 LET PI = 3.14159265
30 LET RD = PI / 180 : REM Degrees to radians
100 REM Read and validate the first position
110 PRINT "INITIAL BEARING"
120 PRINT "==============="
130 PRINT ""
140 PRINT "First latitude (-90 to 90)"
150 INPUT L1
160 IF L1 < -90 OR L1 > 90 THEN PRINT "Invalid latitude" : GOTO 140
170 PRINT "First longitude (-180 to 180)"
180 INPUT O1
190 IF O1 < -180 OR O1 > 180 THEN PRINT "Invalid longitude" : GOTO 170
200 REM Read and validate the second position
210 PRINT "Second latitude (-90 to 90)"
220 INPUT L2
230 IF L2 < -90 OR L2 > 90 THEN PRINT "Invalid latitude" : GOTO 210
240 PRINT "Second longitude (-180 to 180)"
250 INPUT O2
260 IF O2 < -180 OR O2 > 180 THEN PRINT "Invalid longitude" : GOTO 240
300 REM Calculate and display the initial bearing
310 GOSUB 1000
320 PRINT ""
330 IF UN = 1 THEN PRINT "Initial bearing is undefined" : GOTO 400
340 PRINT "Initial bearing: "; BR; " degrees true"
400 REM Offer another calculation
410 PRINT ""
420 PRINT "More? (Y/N) ";
430 INPUT M$
440 IF M$ = "Y" OR M$ = "y" THEN GOTO 130
450 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 420
460 END
1000 REM Calculate initial bearing from L1,O1 to L2,O2
1010 LET D1 = (O2 - O1) * RD
1020 LET Y1 = SIN(D1) * COS(L2 * RD)
1030 LET X1 = COS(L1 * RD) * SIN(L2 * RD)
1040 LET X1 = X1 - SIN(L1 * RD) * COS(L2 * RD) * COS(D1)
1050 LET UN = 0
1060 LET H1 = SIN((L2 - L1) * RD / 2) ^ 2
1070 LET H1 = H1 + COS(L1 * RD) * COS(L2 * RD) * SIN(D1 / 2) ^ 2
1080 IF H1 < 0 THEN LET H1 = 0
1090 IF H1 > 1 THEN LET H1 = 1
1100 IF H1 = 0 OR H1 = 1 THEN LET UN = 1 : RETURN
1110 IF X1 = 0 AND Y1 > 0 THEN LET AN = PI / 2 : GOTO 1160
1120 IF X1 = 0 AND Y1 < 0 THEN LET AN = 3 * PI / 2 : GOTO 1160
1130 LET AN = ATN(Y1 / X1)
1140 IF X1 < 0 THEN LET AN = AN + PI
1150 IF X1 > 0 AND Y1 < 0 THEN LET AN = AN + 2 * PI
1160 LET BR = AN / RD
1170 IF BR >= 360 THEN LET BR = BR - 360
1180 IF BR < 0 THEN LET BR = BR + 360
1190 RETURN
