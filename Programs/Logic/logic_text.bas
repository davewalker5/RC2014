10 REM Display truth tables for common logic gates
100 PRINT ""
110 PRINT "LOGIC GATE DEMONSTRATOR"
120 PRINT "======================="
130 PRINT ""
140 PRINT "A and B use 0 for false and 1 for true."
150 PRINT ""
200 LET G$ = "AND" : GOSUB 1000
210 LET G$ = "OR" : GOSUB 1000
220 LET G$ = "XOR" : GOSUB 1000
230 GOSUB 2000
240 END
1000 REM Print the two-input truth table selected by G$
1010 PRINT G$; " GATE"
1020 PRINT "A B | Q"
1030 PRINT "------"
1040 FOR A = 0 TO 1
1050 FOR B = 0 TO 1
1060 IF G$ = "AND" THEN LET Q = A AND B
1070 IF G$ = "OR" THEN LET Q = A OR B
1080 IF G$ = "XOR" THEN LET Q = (A OR B) - (A AND B)
1090 PRINT CHR$(48 + A); " "; CHR$(48 + B); " | "; CHR$(48 + Q)
1100 NEXT B
1110 NEXT A
1120 PRINT ""
1130 RETURN
2000 REM Print the single-input NOT truth table
2010 PRINT "NOT GATE"
2020 PRINT "A | Q"
2030 PRINT "-----"
2040 FOR A = 0 TO 1
2050 LET Q = 1 - A
2060 PRINT CHR$(48 + A); " | "; CHR$(48 + Q)
2070 NEXT A
2080 PRINT ""
2090 RETURN
