10 REM Trainable single-input sigmoid neuron - full-batch learning
20 LET W = 0 : LET B = 0
30 LET RA = .1 : LET NE = 200 : LET NF = 20
40 LET N = 6
80 DIM XX(100), TT(100)
100 PRINT ""
110 PRINT "A TRAINABLE NEURON ON A Z80"
120 PRINT "==========================="
130 PRINT "P = SIGMOID(W * X + B)"
140 PRINT "Mean binary cross-entropy; full-batch updates."
150 PRINT "Class is 1 when P > .5, otherwise 0."
160 PRINT "Learning rate:"; RA; "  Updates:"; NE
170 GOSUB 4000
180 RESTORE
190 FOR I = 1 TO N
200 READ XX(I), TT(I)
210 IF ABS(XX(I)) > 1000 THEN GOTO 4500
220 IF TT(I) <> 0 AND TT(I) <> 1 THEN GOTO 4500
230 NEXT I
240 PRINT ""
250 PRINT "TRAINING: LOSS AND GRADIENTS ARE BEFORE EACH UPDATE"
255 PRINT "One dot per completed update; please wait."
260 LET FL = 1 : GOSUB 1200
270 PRINT "Initial loss:"; LS
280 IF NE = 0 THEN GOTO 390
290 FOR EP = 1 TO NE
300 LET NW = W - RA * DW : LET NB = B - RA * DB
310 IF EP = 1 THEN GOSUB 1600 : GOTO 330
320 IF EP / NF = INT(EP / NF) THEN GOSUB 1600
330 LET W = NW : LET B = NB
335 PRINT ".";
336 LET FL = 0
337 IF (EP+1) / NF = INT((EP+1) / NF) THEN LET FL = 1
338 IF EP = NE THEN LET FL = 1
340 GOSUB 1200
350 NEXT EP
390 PRINT ""
400 PRINT "TRAINING COMPLETE"
410 PRINT "Final loss:"; LS
420 PRINT "Learned weight:"; W; "  Bias:"; B
430 IF W <> 0 THEN PRINT "Learned threshold (-B/W):"; -B / W
440 IF W = 0 THEN PRINT "No input-dependent threshold: W is zero."
450 PRINT "Class 1 when probability > .5; ties choose class 0."
460 PRINT ""
470 PRINT "TRAINING EXAMPLES WITH THE LEARNED PARAMETERS"
480 FOR I = 1 TO N
490 LET X = XX(I) : GOSUB 1000
500 PRINT "Target:"; TT(I)
510 GOSUB 2000
530 NEXT I
600 PRINT ""
610 PRINT "Try your own input? (Y/N) ";
620 INPUT A$
630 IF A$ = "N" OR A$ = "n" THEN GOTO 800
640 IF A$ <> "Y" AND A$ <> "y" THEN PRINT "Enter Y or N" : GOTO 610
650 PRINT "Input X (-1000 to 1000) ";
660 INPUT X
670 IF ABS(X) > 1000 THEN PRINT "Use -1000 to 1000." : GOTO 650
680 GOSUB 1000
690 GOSUB 2000
700 GOTO 600
800 REM Finish; hardware versions also clear their outputs
830 PRINT "Finished. RUN trains again from the initial settings."
840 END
1000 REM Forward pass: X in; V, Z, Q, P and Y out
1010 LET V = W * X : LET Z = V + B
1020 LET Q = 0
1030 IF ABS(Z) <= 50 THEN LET Q = EXP(-ABS(Z))
1040 LET P = 1 / (1 + Q)
1050 IF Z < 0 THEN LET P = Q / (1 + Q)
1060 LET Y = 0
1070 IF P > .5 THEN LET Y = 1
1080 RETURN
1200 REM Batch gradients; FL=1 also calculates loss for display
1210 LET LS = 0 : LET DW = 0 : LET DB = 0
1220 FOR K = 1 TO N
1230 LET X = XX(K) : LET Z = W * X + B : LET Q = 0
1240 IF ABS(Z) <= 50 THEN LET Q = EXP(-ABS(Z))
1242 LET P = 1 / (1 + Q)
1244 IF Z < 0 THEN LET P = Q / (1 + Q)
1250 IF FL = 0 THEN GOTO 1270
1255 LET T = TT(K) : GOSUB 1400
1260 LET LS = LS + SL
1270 LET ER = P - TT(K)
1280 LET DW = DW + ER * X : LET DB = DB + ER
1290 NEXT K
1300 LET LS = LS / N : LET DW = DW / N : LET DB = DB / N
1310 RETURN
1400 REM Stable sample loss: MAX(0,S) + LOG(1+EXP(-ABS(Z)))
1410 LET S = Z
1420 IF T = 1 THEN LET S = -Z
1430 LET SL = Q * (1 - Q / 2)
1440 IF Q >= .0001 THEN LET SL = LOG(1 + Q)
1450 IF S > 0 THEN LET SL = SL + S
1460 RETURN
1600 REM Inspect pre-update state and the proposed new parameters
1610 PRINT ""
1620 PRINT "Update:"; EP; "  Loss:"; LS
1630 PRINT "W:"; W; "  B:"; B
1640 PRINT "DW:"; DW; "  DB:"; DB
1650 PRINT "Next W:"; NW; "  Next B:"; NB
1690 RETURN
2000 REM Inspect a prediction; interactive inputs do not retrain
2010 PRINT "Input X:        "; X
2020 PRINT "Weighted W * X: "; V
2030 PRINT "Bias B:         "; B
2040 PRINT "Sum Z:          "; Z
2050 PRINT "Probability:    "; P
2060 PRINT "Predicted class:"; Y
2110 RETURN
4000 REM Bound the demonstration to modest values on an 8-bit BASIC
4010 IF N < 1 OR N > 100 OR N <> INT(N) THEN GOTO 4500
4020 IF NE < 0 OR NE > 10000 OR NE <> INT(NE) THEN GOTO 4500
4030 IF NF < 1 OR NF > 10000 OR NF <> INT(NF) THEN GOTO 4500
4040 IF RA <= 0 OR RA > 10 THEN GOTO 4500
4050 IF ABS(W) > 1000 OR ABS(B) > 1000 THEN GOTO 4500
4060 RETURN
4500 PRINT "Invalid settings or training data. See README limits."
4510 GOTO 800
5000 DATA 0,0,1,0,2,0,4,1,5,1,6,1
