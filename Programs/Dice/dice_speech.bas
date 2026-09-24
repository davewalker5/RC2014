10 REM Configuration
20 LET DL = 35 : REM Rolling animation delay
30 LET DB = 20 : REM Button debounce delay
40 REM Speech requires the MG005 SP0256-AL2 on port 31
50 REM Load exact digit sequences, including their final PA1 pause
60 DIM A(9,6), L(9)
70 RESTORE
80 FOR D = 0 TO 9
85 READ L(D)
90 FOR P = 1 TO L(D) : READ A(D,P) : NEXT P
95 NEXT D
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
210 OUT 1, 0
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
505 REM Speak coin results as zero for tails or one for heads
510 IF R = 0 THEN LET V = 85 : PRINT "TAILS" : GOTO 700
520 LET V = 170 : PRINT "HEADS"
530 GOTO 700
600 LET V = R : PRINT "D6: "; R
610 GOTO 700
620 LET V = R : PRINT "D8: "; R
630 GOTO 700
640 LET V = R : PRINT "BYTE: "; R
690 REM Keep the result on the LEDs while speaking its number
700 OUT 1, V
705 GOSUB 5000
710 GOTO 300
800 REM Clear the LEDs before leaving the program
810 OUT 1, 0
820 PRINT "Done"
830 END
1000 REM Wait for one button press and return its byte value in K
1010 LET SD = 1
1020 LET K = INP(1)
1030 IF K <> 0 THEN GOTO 1070
1040 LET SD = SD + 1
1050 IF SD > 100 THEN LET SD = 1
1060 GOTO 1020
1070 LET X = INP(1) : IF X <> 0 THEN GOTO 1070
1080 LET U = DB : GOSUB 4000
1090 RETURN
2000 REM Show a rolling animation across all eight LEDs
2010 PRINT "ROLLING..."
2020 FOR J = 1 TO 2
2030 FOR I = 0 TO 7
2040 OUT 1, 2 ^ I
2050 LET U = DL : GOSUB 4000
2060 NEXT I
2070 FOR I = 7 TO 0 STEP -1
2080 OUT 1, 2 ^ I
2090 LET U = DL : GOSUB 4000
2100 NEXT I
2110 NEXT J
2120 OUT 1, 0
2130 RETURN
3000 REM Flash all LEDs to indicate an invalid button choice
3010 OUT 1, 255
3020 LET U = DL * 3 : GOSUB 4000
3030 OUT 1, 0
3040 RETURN
4000 REM Wait for U approximate delay units
4010 FOR Z = 1 TO U : NEXT Z
4020 RETURN
5000 REM Speak R as decimal digits without changing the dice result
5010 REM Byte values use digits: 105 is spoken as one zero five
5020 LET N = R
5030 IF N < 100 THEN GOTO 5070
5040 LET D = INT(N / 100) : GOSUB 6000
5050 LET N = N - D * 100
5060 GOTO 5080
5070 IF N < 10 THEN GOTO 5100
5080 LET D = INT(N / 10) : GOSUB 6000
5090 LET N = N - D * 10
5100 LET D = N : GOSUB 6000
5110 RETURN
6000 REM Send the exact allophones for digit D to the speech card
6010 FOR P = 1 TO L(D)
6020 REM Wait for ready bit 1 before writing each allophone
6030 IF (INP(31) AND 2) = 0 THEN GOTO 6030
6040 OUT 31, A(D,P)
6050 NEXT P
6060 RETURN
7000 REM Digit data copied from Programs/Speech/Numbers/0.bas to 9.bas
7010 REM Each DATA row starts with a count, followed by exact codes
7100 REM 0: ZZ IY RR1 OW PA1
7110 DATA 5,43,19,14,53,0
7120 REM 1: WW AX NN1 PA1
7130 DATA 4,46,15,11,0
7140 REM 2: TT2 UW1 PA1
7150 DATA 3,13,22,0
7160 REM 3: TH RR1 IY PA1
7170 DATA 4,29,14,19,0
7180 REM 4: FF OR1 PA1
7190 DATA 3,40,58,0
7200 REM 5: FF AY VV PA1
7210 DATA 4,40,6,35,0
7220 REM 6: SS IH KK1 SS PA1
7230 DATA 5,55,12,42,55,0
7240 REM 7: SS EH VV EH NN1 PA1
7250 DATA 6,55,7,35,7,11,0
7260 REM 8: EY TT2 PA1
7270 DATA 3,20,13,0
7280 REM 9: NN1 AY NN1 PA1
7290 DATA 4,11,6,11,0
