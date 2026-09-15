10 REM Interactive neuron with Digital I/O and 16x2 LCD output
20 LET W = 2
30 LET B = -6
40 LET IP = 1 : REM Digital I/O port
50 OUT IP, 0
60 LET LR = 218 : LET LD = 219 : REM LCD command and data ports
70 GOSUB 3000
100 PRINT ""
110 PRINT "A SINGLE NEURON ON A Z80"
120 PRINT "======================="
130 PRINT "Z = (W * X) + B"
140 PRINT "Weight W = "; W; "  Bias B = "; B
150 PRINT "Output is 1 when Z > 0, otherwise 0."
160 PRINT "Weight and bias stay fixed. No learning!"
170 PRINT "LED 0 shows output; LEDs 1-7 stay off."
180 PRINT "Binary: 00000000 = off, 00000001 = on."
200 GOTO 360
300 REM Try further inputs with the same fixed neuron
310 PRINT ""
320 PRINT "Try another input? (Y/N) ";
330 INPUT A$
340 IF A$ = "N" OR A$ = "n" THEN GOTO 500
350 IF A$ <> "Y" AND A$ <> "y" THEN PRINT "Enter Y or N" : GOTO 320
360 PRINT "Input X (e.g. 2.9, 3 or 3.1) ";
370 INPUT X
380 GOSUB 1000
390 GOSUB 2000
400 GOTO 310
500 REM Clear the LEDs before returning to BASIC
510 OUT IP, 0
515 OUT LR, 1 : GOSUB 3900
520 PRINT "LEDs and LCD cleared."
530 END
1000 REM Forward pass: X in, weighted input V, sum Z, output Y
1010 LET V = W * X
1020 LET Z = V + B
1030 LET Y = 0
1040 IF Z > 0 THEN LET Y = 1
1050 RETURN
2000 REM Inspect every stage of the forward pass
2005 OUT IP, Y
2010 PRINT ""
2020 PRINT "Input X:        "; X
2030 PRINT "Weighted W * X: "; V
2040 PRINT "Bias B:         "; B
2050 PRINT "Sum Z:          "; Z
2060 PRINT "Output STEP(Z): "; Y
2070 LET TX$ = "NEURON OUTPUT: " + CHR$(48 + Y)
2080 LET LC = 128 : GOSUB 3500
2090 LET TX$ = "BINARY: 0000000" + CHR$(48 + Y)
2100 LET LC = 192 : GOSUB 3500
2110 RETURN
3000 REM Initialise LCD: 8 bit, two lines, cursor off
3010 OUT LR, 56 : GOSUB 3900
3020 OUT LR, 12 : GOSUB 3900
3030 OUT LR, 6 : GOSUB 3900
3040 OUT LR, 1 : GOSUB 3900
3050 LET TX$ = "SINGLE NEURON"
3060 LET LC = 128 : GOSUB 3500
3070 LET TX$ = "ENTER X ON PC"
3080 LET LC = 192 : GOSUB 3500
3090 RETURN
3500 REM Write TX$ padded to 16 characters at LCD address LC
3510 OUT LR, LC : GOSUB 3900
3520 FOR J = 1 TO 16
3530 LET C = 32
3540 IF J <= LEN(TX$) THEN LET C = ASC(MID$(TX$, J, 1))
3550 OUT LD, C : GOSUB 3900
3560 NEXT J
3570 RETURN
3900 REM Conservative delay after each LCD command or data write
3910 FOR Q = 1 TO 100 : NEXT Q
3920 RETURN
