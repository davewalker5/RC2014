1 PRINT "Distance between the two bodies (km)"
2 INPUT A
3 PRINT "Mass of the first body (kg)"
4 INPUT M1
10 R1 = A * M3 / (M1 + M2)
5 PRINT "Mass of the second body (kg)"
6 INPUT M2
7 REM Calculate the distance between the primary body and the barycenter
8 IF M1 <= M2 THEN LET M3 = M1
9 IF M1 > M2 THEN LET M3 = M2
11 PRINT "Barycenter is " R1 " km from the primary body"
12 M$ = "": PRINT "More? ";: INPUT M$
13 IF M$ = "Y" OR M$ = "y" THEN GOTO 1
14 END