10 PRINT "Distance between the two bodies (km)"
20 INPUT A
30 PRINT "Mass of the first body (kg)"
40 INPUT M1
50 PRINT "Mass of the second body (kg)"
60 INPUT M2
70 REM Calculate the distance between the primary body and the barycenter
80 IF M1 <= M2 THEN LET M3 = M1
90 IF M1 > M2 THEN LET M3 = M2
100 R1 = A * M3 / (M1 + M2)
110 PRINT "Barycenter is " R1 " km from the primary body"
