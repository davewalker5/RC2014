5000 REM Tabulate the PRI and DPRI data
5010 LET CW = 15 : PRINT
5020 REM Print PRI/DPRI table column headers
5030 LET PD$ = " "
5040 LET V$ = "Pulse" : GOSUB 6030 : PRINT " ";
5050 LET V$ = "PRI" : GOSUB 6030 : PRINT " ";
5060 LET V$ = "Validity" : GOSUB 6030 : PRINT " ";
5070 LET V$ = "DPRI" : GOSUB 6030 : PRINT " ";
5080 LET V$ = "Validity" : GOSUB 6030 : PRINT
5090 REM Print table header separator
5100 LET PD$ = "-"
5110 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5120 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5130 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5140 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5150 LET V$ = "-" : GOSUB 6030 : PRINT
5160 LET PD$ = " "
5170 REM Iterate over and tabulate PRI and DPRI
5180 FOR X = 1 TO NP
5190 LET V$ = STR$(X) : GOSUB 6000 : PRINT " ";
5200 LET V$ = STR$(P(X)) : GOSUB 6000 : PRINT " ";
5210 LET V$ = STR$(PV(X)) : GOSUB 6000 : PRINT " ";
5220 LET V$ = STR$(D(X)) : GOSUB 6000 : PRINT " ";
5230 LET V$ = STR$(DV(X)) : GOSUB 6000 : PRINT
5240 NEXT X
5250 RETURN

