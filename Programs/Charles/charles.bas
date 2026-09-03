10 REM Charles the Feisty Octopus
20 REM Core needs simulation for RC2014 BASIC
30 LET DL = 200 : REM Approximate delay between simulation ticks
40 LET DI = 5 : REM Ticks between diagnostic displays
50 LET NH = 160 : REM Hunger threshold
60 LET NB = 160 : REM Boredom threshold
70 LET NE = 80 : REM Low-energy threshold
80 LET CH = 200 : REM Cross hunger threshold
90 LET CM = 80 : REM Cross happiness threshold
100 REM Initialise Charles's needs on a zero-to-255 scale
110 LET HU = 40 : REM Hunger: higher means hungrier
120 LET HA = 180 : REM Happiness: higher means happier
130 LET EN = 220 : REM Energy: higher means more energetic
140 LET BO = 20 : REM Boredom: higher means more bored
150 LET IR = 20 : REM Irritation: higher means more irritated
160 LET TK = 0 : REM Simulation tick
170 LET DC = 0 : REM Display interval counter
180 LET EC = 0 : REM Energy interval counter
190 PRINT "CHARLES HAS NEEDS"
200 PRINT "PRESS CTRL-C TO STOP"
210 GOSUB 2000
300 REM Main simulation loop
310 GOSUB 1000
320 LET TK = TK + 1
330 LET DC = DC + 1
340 IF DC < DI THEN GOTO 370
350 LET DC = 0
360 GOSUB 2000
370 GOSUB 3000
380 GOTO 300
1000 REM Update Charles's internal state for one simulation tick
1010 LET HU = HU + 3
1020 IF HU > 255 THEN LET HU = 255
1030 LET BO = BO + 2
1040 IF BO > 255 THEN LET BO = 255
1050 LET EC = EC + 1
1060 IF EC < 2 THEN GOTO 1100
1070 LET EC = 0
1080 LET EN = EN - 3
1090 IF EN < 0 THEN LET EN = 0
1100 REM Happiness tends to neutral, then unmet needs reduce it
1110 IF HA > 128 THEN LET HA = HA - 1
1120 IF HA < 128 AND HU < 120 AND BO < 120 THEN LET HA = HA + 1
1130 IF HU > 140 THEN LET HA = HA - 2
1140 IF BO > 140 THEN LET HA = HA - 1
1150 IF HA < 0 THEN LET HA = 0
1160 REM Irritation fades unless prolonged hunger makes it rise
1170 IF HU <= 180 AND IR > 0 THEN LET IR = IR - 1
1180 IF HU > 180 THEN LET IR = IR + 2
1190 IF IR > 255 THEN LET IR = 255
1200 RETURN
2000 REM Display the state and derived need conditions
2010 PRINT
2020 PRINT "TKCK "; TK
2030 PRINT "HUNGER "; HU; "  HAPPY "; HA
2040 PRINT "ENERGY "; EN; "  BORED "; BO
2050 PRINT "IRRIT. "; IR
2060 PRINT "NEEDS: ";
2070 LET NS = 0
2080 IF HU >= NH THEN PRINT "HUNGRY "; : LET NS = 1
2090 IF BO >= NB THEN PRINT "BORED "; : LET NS = 1
2100 IF EN <= NE THEN PRINT "TKRED "; : LET NS = 1
2110 IF HU >= CH AND HA <= CM THEN PRINT "CROSS "; : LET NS = 1
2120 IF NS = 0 THEN PRINT "NONE" : RETURN
2130 PRINT
2140 RETURN
3000 REM Wait for an approximate simulation interval
3010 FOR DE = 1 TO DL
3020 NEXT DE
3030 RETURN
