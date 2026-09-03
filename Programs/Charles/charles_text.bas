10 REM Charles the Feisty Octopus - Phases 1 and 2
20 REM Needs, behavioural states, and opinions for RC2014 BASIC
30 LET DL = 200 : REM Approximate delay between simulation ticks
40 LET DI = 5 : REM Ticks between diagnostic displays
50 LET MI = 10 : REM Ticks between Charles's messages
60 LET NH = 160 : REM Hunger threshold
70 LET NB = 80 : REM Boredom threshold
80 LET NE = 80 : REM Low-energy threshold
90 LET CH = 200 : REM Cross hunger threshold
100 LET CM = 80 : REM Cross happiness threshold
110 PRINT
120 PRINT "CHARLES THE FEISTY OCTOPUS"
130 PRINT "NEEDS AND OPINIONS - PHASE 2"
140 PRINT
150 PRINT "CHARLES CHANGES WITHOUT YOUR HELP."
160 PRINT "THERE ARE NO USER CONTROLS YET."
170 PRINT "PRESS CTRL-C TO STOP."
180 PRINT
190 DIM SN$(5), ME$(5, 3)
200 REM Each state record contains its name followed by three messages
210 DATA "CONTENT","THIS IS NICE","CHARLES HAPPY","ALL IS WELL"
220 DATA "HUNGRY","NEED CRAB","FEED ME","WHERE IS CRAB?"
230 DATA "BORED","CHARLES BORED","DO SOMETHING","PLAY WITH ME"
240 DATA "SLEEPY","CHARLES SLEEPY","ZZZ...","NAP REQUIRED"
250 DATA "CROSS","NO.","GO AWAY","CHARLES CROSS"
300 REM Initialise Charles's needs on a zero-to-255 scale
310 LET HU = 40 : REM Hunger: higher means hungrier
320 LET HA = 180 : REM Happiness: higher means happier
330 LET EN = 220 : REM Energy: higher means more energetic
340 LET BO = 20 : REM Boredom: higher means more bored
350 LET IR = 20 : REM Irritation: higher means more irritated
360 LET TK = 0 : REM Simulation tick
370 LET DC = 0 : REM Display interval counter
380 LET EC = 0 : REM Energy interval counter
390 LET MC = 0 : REM Message interval counter
400 LET PS = 0 : REM State shown with the previous message
410 LET LS = 0 : REM State used for the previous message choice
420 LET LM = 0 : REM Previous message number
430 GOSUB 3500
440 GOSUB 4000
450 GOSUB 2000
460 GOSUB 5000
500 REM Main simulation loop
510 GOSUB 1000
520 LET TK = TK + 1
530 GOSUB 4000
540 LET DC = DC + 1
550 IF DC < DI THEN GOTO 580
560 LET DC = 0
570 GOSUB 2000
580 LET MC = MC + 1
590 IF MO <> PS THEN GOTO 620
600 IF MC < MI THEN GOTO 640
620 GOSUB 5000
630 LET MC = 0
640 GOSUB 6000
650 GOTO 500
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
2020 PRINT "TICK "; TK; "  MOOD "; SN$(MO)
2030 PRINT "HUNGER "; HU; "  HAPPY "; HA
2040 PRINT "ENERGY "; EN; "  BORED "; BO
2050 PRINT "IRRIT. "; IR
2060 PRINT "NEEDS: ";
2070 LET NS = 0
2080 IF HU >= NH THEN PRINT "HUNGRY "; : LET NS = 1
2090 IF BO >= NB THEN PRINT "BORED "; : LET NS = 1
2100 IF EN <= NE THEN PRINT "TIRED "; : LET NS = 1
2110 IF HU >= CH AND HA <= CM THEN PRINT "CROSS "; : LET NS = 1
2120 IF NS = 0 THEN PRINT "NONE" : RETURN
2130 PRINT
2140 RETURN
3500 REM Read state names and their context-sensitive messages
3510 FOR RS = 1 TO 5
3520 READ SN$(RS)
3530 FOR RM = 1 TO 3
3540 READ ME$(RS, RM)
3550 NEXT RM
3560 NEXT RS
3570 RETURN
4000 REM Select the current behavioural state by priority
4010 LET MO = 1 : REM Content
4020 IF BO >= NB THEN LET MO = 3 : REM Bored
4030 IF HU >= NH THEN LET MO = 2 : REM Hungry
4040 IF HU >= CH AND HA <= CM THEN LET MO = 5 : REM Cross
4050 IF EN <= NE THEN LET MO = 4 : REM Sleepy
4060 RETURN
5000 REM Choose and display a non-repeating message for this state
5010 LET RN = 1 + INT(RND(1) * 3)
5020 IF MO <> LS THEN GOTO 5060
5030 IF RN <> LM THEN GOTO 5060
5040 LET RN = RN + 1
5050 IF RN > 3 THEN LET RN = 1
5060 PRINT "CHARLES: "; ME$(MO, RN)
5070 LET LS = MO
5080 LET LM = RN
5090 LET PS = MO
5100 RETURN
6000 REM Wait for an approximate simulation interval
6010 FOR DE = 1 TO DL
6020 NEXT DE
6030 RETURN
