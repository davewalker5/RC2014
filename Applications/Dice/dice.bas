10 REM Configuration
20 LET DL = 35 : REM Rolling animation delay
30 LET DB = 20 : REM Button debounce delay
100 REM Display instructions
110 PRINT ""
120 PRINT "ELECTRONIC DICE"
130 PRINT "==============="
140 PRINT "Press one button on the digital I/O card:"
150 PRINT "  Number 0 - Value 1   - flip a coin"
160 PRINT "  Number 1 - Value 2   - roll a D6"
170 PRINT "  Number 2 - Value 4   - roll a D8"
180 PRINT "  Number 3 - Value 8   - generate a random byte"
190 PRINT "  Number 7 - Value 128 - quit"
200 PRINT ""
210 OUT 0, 0
300 REM Wait for a mode button and use its timing as entropy
310 PRINT "Press a button to choose the mode";
320 GOSUB 1000
330 IF K = 128 THEN GOTO 800
340 IF K = 1 THEN LET M = 1 : GOTO 400
350 IF K = 2 THEN LET M = 2 : GOTO 400
360 IF K = 4 THEN LET M = 3 : GOTO 400
370 IF K = 8 THEN LET M = 4 : GOTO 400
380 PRINT "Press exactly one of the listed buttons"
390 GOSUB 3000 : GOTO 300
400 REM Advance the random sequence by the variable wait count
410 FOR I = 1 TO SD
420 LET R = RND(1)
430 NEXT I
440 GOSUB 2000
450 REM Generate and display the selected result
460 IF M = 1 THEN GOTO 500
470 IF M = 2 THEN LET R = 1 + INT(RND(1) * 6) : GOTO 600
480 IF M = 3 THEN LET R = 1 + INT(RND(1) * 8) : GOTO 620
490 LET R = INT(RND(1) * 256) : GOTO 640
500 LET R = INT(RND(1) * 2)
510 IF R = 0 THEN LET V = 85 : PRINT "TAILS" : GOTO 700
520 LET V = 170 : PRINT "HEADS"
530 GOTO 700
600 LET V = R : PRINT "D6: "; R
610 GOTO 700
620 LET V = R : PRINT "D8: "; R
630 GOTO 700
640 LET V = R : PRINT "BYTE: "; R
700 OUT 0, V
710 GOTO 300
800 REM Clear the LEDs before leaving the program
810 OUT 0, 0
820 PRINT "Done"
830 END
1000 REM Wait for one button press and return its byte value in K
1010 LET SD = 1
1020 LET K = INP(0)
1030 IF K <> 0 THEN GOTO 1070
1040 LET SD = SD + 1
1050 IF SD > 100 THEN LET SD = 1
1060 GOTO 1020
1070 LET X = INP(0) : IF X <> 0 THEN GOTO 1070
1080 LET U = DB : GOSUB 4000
1090 RETURN
2000 REM Show a rolling animation across all eight LEDs
2010 PRINT "ROLLING..."
2020 FOR J = 1 TO 2
2030 FOR I = 0 TO 7
2040 OUT 0, 2 ^ I
2050 LET U = DL : GOSUB 4000
2060 NEXT I
2070 FOR I = 7 TO 0 STEP -1
2080 OUT 0, 2 ^ I
2090 LET U = DL : GOSUB 4000
2100 NEXT I
2110 NEXT J
2120 OUT 0, 0
2130 RETURN
3000 REM Flash all LEDs to indicate an invalid button choice
3010 OUT 0, 255
3020 LET U = DL * 3 : GOSUB 4000
3030 OUT 0, 0
3040 RETURN
4000 REM Wait for U approximate delay units
4010 FOR Z = 1 TO U : NEXT Z
4020 RETURN
