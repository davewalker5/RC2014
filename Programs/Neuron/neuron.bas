10 REM Single-input neuron - fixed weight and bias, no training
20 LET W = 2
30 LET B = -6
100 PRINT ""
110 PRINT "A SINGLE NEURON ON A Z80"
120 PRINT "======================="
130 PRINT "Z = (W * X) + B"
140 PRINT "Weight W = "; W; "  Bias B = "; B
150 PRINT "Output is 1 when Z > 0, otherwise 0."
160 PRINT "Weight and bias stay fixed. No learning!"
200 REM Run the same five examples as the Python demonstration
210 PRINT ""
220 PRINT "EXAMPLE INPUTS"
230 RESTORE
240 FOR I = 1 TO 3
250 READ X
260 GOSUB 1000
270 GOSUB 2000
280 NEXT I
300 REM Try further inputs with the same fixed neuron
310 PRINT ""
320 PRINT "Try your own input? (Y/N) ";
330 INPUT A$
340 IF A$ = "N" OR A$ = "n" THEN END
350 IF A$ <> "Y" AND A$ <> "y" THEN PRINT "Enter Y or N" : GOTO 320
360 PRINT "Input X (e.g. 2.9, 3 or 3.1) ";
370 INPUT X
380 GOSUB 1000
390 GOSUB 2000
400 GOTO 310
1000 REM Forward pass: X in, weighted input V, sum Z, output Y
1010 LET V = W * X
1020 LET Z = V + B
1030 LET Y = 0
1040 IF Z > 0 THEN LET Y = 1
1050 RETURN
2000 REM Inspect every stage of the forward pass
2010 PRINT ""
2020 PRINT "Input X:        "; X
2030 PRINT "Weighted W * X: "; V
2040 PRINT "Bias B:         "; B
2050 PRINT "Sum Z:          "; Z
2060 PRINT "Output STEP(Z): "; Y
2070 RETURN
3000 DATA 2,3,4
