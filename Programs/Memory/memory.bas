10 REM Configuration
20 LET DL = 200 : REM LED display delay
30 LET GP = 75 : REM Gap between LED displays
40 LET DB = 20 : REM Button debounce delay
50 LET MX = 20 : REM Maximum sequence length
60 DIM SQ(MX)
100 REM Display the instructions
105 PRINT ""
110 PRINT "MEMORY"
120 PRINT "======"
125 PRINT ""
130 PRINT "Watch the LED sequence, then repeat it using the buttons"
140 PRINT "numbered 0, 1, 2 and 3 on the digital I/O card. Press only"
150 PRINT "one button at a time."
160 PRINT ""
200 REM Start a new game
210 GOSUB 1000
220 LET RN = 1 : LET SC = 0
300 REM Add, display and read the sequence for this round
310 GOSUB 2000
320 GOSUB 3000
330 PRINT ": Repeat the sequence " ; 
340 FOR P = 1 TO RN
350 GOSUB 4000
360 IF IV = 1 THEN GOTO 500
370 IF K <> SQ(P) THEN GOTO 500
380 NEXT P
390 LET SC = RN
400 PRINT ": Correct!"
410 IF RN = MX THEN GOTO 600
420 LET RN = RN + 1
430 GOTO 300
500 REM The player entered an incorrect value
510 PRINT ": Incorrect - you scored "; SC
520 GOSUB 5000
530 GOTO 700
600 REM The player completed the maximum sequence
610 PRINT "You completed all "; MX; " rounds!"
620 GOSUB 5500
700 REM Ask whether to play again
710 OUT 1, 0
720 PRINT ""
730 PRINT "Play again? (Y/N) ";
740 INPUT M$
750 IF M$ = "Y" OR M$ = "y" THEN GOTO 200
760 IF M$ <> "N" AND M$ <> "n" THEN GOTO 730
770 OUT 1, 0
780 END
1000 REM Wait for a start press and vary the random sequence
1010 PRINT "Press any button on the digital I/O card to start"
1020 LET SD = 1
1030 LET K = INP(1)
1040 IF K <> 0 THEN GOTO 1080
1050 LET SD = SD + 1
1060 IF SD > 100 THEN LET SD = 1
1070 GOTO 1030
1080 REM Wait for all buttons to be released
1090 LET X = INP(1) : IF X <> 0 THEN GOTO 1090
1100 REM Advance RND by an amount based on the start delay
1110 FOR I = 1 TO SD
1120 LET R = RND(1)
1130 NEXT I
1140 PRINT ""
1150 RETURN
2000 REM Add one random LED value to the sequence
2010 LET SQ(RN) = 2 ^ INT(RND(1) * 4)
2020 RETURN
3000 REM Display the sequence from 1 to RN
3010 PRINT "Round "; RN ; ": Sequence length " ; RN ; 
3020 OUT 1, 0
3030 LET U = GP : GOSUB 6000
3040 FOR I = 1 TO RN
3050 OUT 1, SQ(I)
3060 LET U = DL : GOSUB 6000
3070 OUT 1, 0
3080 LET U = GP : GOSUB 6000
3090 NEXT I
3100 RETURN
4000 REM Read one valid button press into K
4010 LET IV = 0
4020 LET K = INP(1) : IF K = 0 THEN GOTO 4020
4030 IF K = 1 THEN GOTO 4110
4040 IF K = 2 THEN GOTO 4110
4050 IF K = 4 THEN GOTO 4110
4060 IF K = 8 THEN GOTO 4110
4070 REM More than one or an unsupported button was pressed
4080 LET IV = 1
4090 OUT 1, 255 : GOTO 4110
4110 REM Wait for all buttons to be released
4120 LET X = INP(1) : IF X <> 0 THEN GOTO 4120
4130 OUT 1, 0
4140 LET U = DB : GOSUB 6000
4150 RETURN
5000 REM Display the incorrect-answer pattern three times
5010 FOR I = 1 TO 3
5020 OUT 1, 255
5030 LET U = DL : GOSUB 6000
5040 OUT 1, 0
5050 LET U = GP : GOSUB 6000
5060 NEXT I
5070 RETURN
5500 REM Display the completed-game pattern twice
5510 FOR J = 1 TO 2
5520 FOR I = 0 TO 3
5530 OUT 1, 2 ^ I
5540 LET U = GP : GOSUB 6000
5550 NEXT I
5560 FOR I = 3 TO 0 STEP -1
5570 OUT 1, 2 ^ I
5580 LET U = GP : GOSUB 6000
5590 NEXT I
5600 NEXT J
5610 OUT 1, 0
5620 RETURN
6000 REM Wait for U approximate delay units
6010 FOR Z = 1 TO U : NEXT Z
6020 RETURN
