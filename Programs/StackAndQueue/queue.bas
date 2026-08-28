10 REM Implementation of a queue as a 2-dimensional array
20 LET QM = 100 : REM Maximum queue size
30 LET QD = 2 : REM Number of values per queue entry
40 LET QP = 0 : REM Queue pointer
40 DIM QU(QM, QD)
50 DIM V(QD)
200 REM Enqueue some values
210 FOR I = 1 TO 5
220 LET V(1) = I
230 LET V(2) = I * 10
240 GOSUB 1000
250 NEXT I
300 REM Dequeue the values
310 FOR I = 1 TO 5
320 GOSUB 1100
330 PRINT V(1), V(2)
340 NEXT I
350 END
1000 REM Enqueue a value held in V
1010 IF QP = QM THEN PRINT "Queue overflow" : STOP
1020 LET QP = QP + 1
1030 FOR D = 1 TO QD
1040 LET QU(QP, D) = V(D)
1050 NEXT D
1060 RETURN
1100 REM Dequeue a value from the queue
1110 IF QP = 0 THEN PRINT "Queue underflow" : STOP
1120 FOR D = 1 TO QD
1130 LET V(D) = QU(1, D)
1140 NEXT D
1150 FOR Q = 1 TO QP - 1
1160 FOR D = 1 TO QD
1170 LET QU(Q, D) = QU(Q + 1, D)
1180 NEXT D
1190 NEXT Q
1200 LET QP = QP - 1
1210 RETURN
