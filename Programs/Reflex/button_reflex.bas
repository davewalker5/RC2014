10 REM Configuration
20 LET MX = 20 : REM Number of rounds
30 LET ST = 1200 : REM Starting response limit
40 LET DC = 40 : REM Limit reduction after each round
50 LET ML = 300 : REM Minimum response limit
60 LET GP = 75 : REM Gap before each target
70 LET DB = 20 : REM Button debounce delay
100 REM Display instructions
110 PRINT ""
120 PRINT "BUTTON REFLEX"
130 PRINT "============="
140 PRINT "Press the button matching the illuminated LED before"
150 PRINT "the time limit expires. A wrong button or timeout costs"
160 PRINT "one life. The response limit gets shorter each round."
170 PRINT "Complete all "; MX; " rounds with three lives."
180 PRINT ""
200 REM Start a new game
210 LET SC = 0 : LET LF = 3 : LET RN = 1 : LET TL = ST
220 GOSUB 1000
300 REM Display one random target and read a timed response
310 PRINT "Round "; RN; "  Score "; SC; "  Lives "; LF
320 OUT 1, 0
330 LET U = GP : GOSUB 5000
340 LET LV = 2 ^ INT(RND(1) * 8)
350 OUT 1, LV
360 GOSUB 2000
370 OUT 1, 0
380 IF K = 0 THEN PRINT "Too slow!" : LET LF = LF - 1 : GOTO 430
390 GOSUB 3000
400 IF K <> LV THEN PRINT "Wrong button!" : LET LF = LF - 1 : GOTO 430
410 LET SC = SC + 1
420 PRINT "Correct - response score "; RP
430 IF LF = 0 THEN GOTO 600
440 IF RN = MX THEN GOTO 700
450 LET RN = RN + 1
460 LET TL = TL - DC
470 IF TL < ML THEN LET TL = ML
480 GOTO 300
600 REM The player has lost all three lives
610 PRINT "Game over after round "; RN
620 GOTO 800
700 REM The player survived every round
710 PRINT "You completed all "; MX; " rounds!"
800 REM Show the final score and offer another game
810 OUT 1, 0
820 PRINT "Final score: "; SC; " out of "; MX
830 PRINT ""
840 PRINT "Play again? (Y/N) ";
850 INPUT M$
860 IF M$ = "Y" OR M$ = "y" THEN GOTO 200
870 IF M$ <> "N" AND M$ <> "n" THEN GOTO 840
880 OUT 1, 0
890 END
1000 REM Wait for a start press and use its timing as entropy
1010 OUT 1, 0
1020 PRINT "Press any button on the digital I/O card to start"
1030 LET SD = 1
1040 LET K = INP(1)
1050 IF K <> 0 THEN GOTO 1090
1060 LET SD = SD + 1
1070 IF SD > 100 THEN LET SD = 1
1080 GOTO 1040
1090 GOSUB 3000
1100 FOR I = 1 TO SD
1110 LET R = RND(1)
1120 NEXT I
1130 PRINT ""
1140 RETURN
2000 REM Poll up to TL times; return K and elapsed polls in RP
2010 LET RP = 0
2020 LET RP = RP + 1
2030 LET K = INP(1)
2040 IF K <> 0 THEN RETURN
2050 IF RP < TL THEN GOTO 2020
2060 LET K = 0
2070 RETURN
3000 REM Wait for all buttons to be released and debounce them
3010 LET X = INP(1) : IF X <> 0 THEN GOTO 3010
3020 LET U = DB : GOSUB 5000
3030 RETURN
5000 REM Wait for U approximate delay units
5010 FOR Z = 1 TO U : NEXT Z
5020 RETURN
