10 REM Configuration
20 LET MN = 300 : REM Minimum random delay units
30 LET MX = 1200 : REM Maximum random delay units
40 LET DB = 20 : REM Button debounce delay
100 REM Display instructions and initialise the best score
110 PRINT ""
120 PRINT "REACTION TIMER"
130 PRINT "=============="
135 PRINT ""
140 PRINT "Press any button to arm the timer, then release it."
150 PRINT "After a random pause, one LED will light. Press the"
160 PRINT "matching button as quickly as possible."
165 PRINT ""
170 PRINT "Pressing before the LED lights is a false start."
175 PRINT ""
180 PRINT "Scores are approximate polling-loop counts; lower is better."
190 PRINT ""
200 LET BT = 0
300 REM Arm and run one reaction attempt
310 GOSUB 1000
320 GOSUB 2000
330 IF FS = 1 THEN PRINT "False start - no score" : GOTO 500
340 OUT 1, LV
350 GOSUB 3000
360 OUT 1, 0
370 GOSUB 4000
380 IF K <> LV THEN PRINT "Wrong button - no score" : GOTO 500
390 PRINT "Reaction score: "; RC
400 IF BT = 0 OR RC < BT THEN LET BT = RC : PRINT "New best score!"
410 IF BT > 0 THEN PRINT "Best score: "; BT
500 REM Ask whether to make another attempt
510 PRINT ""
520 PRINT "Try again? (Y/N) ";
530 INPUT M$
540 IF M$ = "Y" OR M$ = "y" THEN GOTO 300
550 IF M$ <> "N" AND M$ <> "n" THEN GOTO 520
560 OUT 1, 0
570 END
1000 REM Wait for an arming press and use its timing as entropy
1010 OUT 1, 0
1020 PRINT "Press any button to arm the timer"
1030 LET SD = 1
1040 LET K = INP(1)
1050 IF K <> 0 THEN GOTO 1090
1060 LET SD = SD + 1
1070 IF SD > 100 THEN LET SD = 1
1080 GOTO 1040
1090 GOSUB 4000
1100 FOR I = 1 TO SD
1110 LET R = RND(1)
1120 NEXT I
1130 PRINT "Wait for the LED..."
1140 RETURN
2000 REM Choose a target and wait a random time while checking input
2010 LET LV = 2 ^ INT(RND(1) * 8)
2020 LET RD = MN + INT(RND(1) * (MX - MN + 1))
2030 LET FS = 0 : LET CT = 0
2040 LET K = INP(1)
2050 IF K <> 0 THEN LET FS = 1 : GOSUB 4000 : RETURN
2060 LET CT = CT + 1
2070 IF CT < RD THEN GOTO 2040
2080 RETURN
3000 REM Measure polls until a button is pressed; return K and RC
3010 LET RC = 0
3020 LET RC = RC + 1
3030 LET K = INP(1)
3040 IF K = 0 THEN GOTO 3020
3050 RETURN
4000 REM Wait for all buttons to be released and debounce them
4010 LET X = INP(1) : IF X <> 0 THEN GOTO 4010
4020 LET U = DB : GOSUB 5000
4030 RETURN
5000 REM Wait for U approximate delay units
5010 FOR Z = 1 TO U : NEXT Z
5020 RETURN
