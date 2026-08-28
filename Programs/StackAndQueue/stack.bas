10 REM Implementation of a stack as a 2-dimensional array
20 LET SM = 100 : REM Maximum stack size
30 LET SD = 2 : REM Number of values per stack entry
40 LET SP = 0 : REM Stack pointer
50 DIM ST(SM, SD)
60 DIM V(SD)
200 REM Push some values onto the stack
210 FOR I = 1 TO 5
220 LET V(1) = I
230 LET V(2) = I * 10
240 GOSUB 1000
250 NEXT I
300 REM Pop the values from the stack
310 FOR I = 1 TO 5
320 GOSUB 1100
330 PRINT V(1), V(2)
340 NEXT I
350 END
1000 REM Push a value held in V onto the stack
1010 IF SP = SM THEN PRINT "Stack overflow" : STOP
1020 LET SP = SP + 1
1030 FOR D = 1 TO SD
1040 LET ST(SP, D) = V(D)
1050 NEXT D
1060 RETURN
1100 REM Pop a value from the stack
1110 IF SP = 0 THEN PRINT "Stack underflow" : STOP
1120 FOR D = 1 TO SD
1130 LET V(D) = ST(SP, D)
1140 NEXT D
1150 LET SP = SP - 1
1160 RETURN
